import { useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import "../Css/AddRequest.css";

const decodeTokenPayload = (token) => {
  try {
    const payloadPart = token?.split(".")?.[1];
    if (!payloadPart) return null;

    const normalized = payloadPart.replace(/-/g, "+").replace(/_/g, "/");
    const padded = normalized.padEnd(Math.ceil(normalized.length / 4) * 4, "=");

    return JSON.parse(atob(padded));
  } catch {
    return null;
  }
};

const isTokenExpired = (token) => {
  const payload = decodeTokenPayload(token);
  if (!payload) return true;
  if (!payload.exp) return false;

  return payload.exp * 1000 < Date.now();
};

// Convert English numbers to Arabic
const toArabicNumbers = (str) => {
  if (!str) return "";
  const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabicNumbers = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  let result = String(str);
  englishNumbers.forEach((eng, i) => {
    result = result.replace(new RegExp(eng, 'g'), arabicNumbers[i]);
  });
  return result;
};

// Format time to 12-hour format with Arabic text
const formatTime12Hour = (time24) => {
  if (!time24) return "";
  const [hours, minutes] = time24.split(":");
  let h = parseInt(hours);
  const period = h >= 12 ? "م" : "ص";
  if (h > 12) h = h - 12;
  if (h === 0) h = 12;
  return toArabicNumbers(`${String(h).padStart(2, "0")}:${minutes} ${period}`);
};

// Convert 12-hour format back to 24-hour format
const convertTime24Hour = (time12) => {
  if (!time12) return "";
  const [timeStr, period] = time12.split(" ");
  let [h, m] = timeStr.split(":");
  h = parseInt(h);
  if (period === "م" && h !== 12) h = h + 12;
  if (period === "ص" && h === 12) h = 0;
  return `${String(h).padStart(2, "0")}:${m}`;
};

// Format date to Arabic
const formatDateArabic = (dateStr) => {
  if (!dateStr) return "";
  const date = new Date(dateStr + "T00:00:00");
  const arabicDays = ["الأحد", "الاثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"];
  const arabicMonths = ["يناير", "فبراير", "مارس", "أبريل", "مايو", "يونيو", "يوليو", "أغسطس", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"];
  return toArabicNumbers(`${arabicDays[date.getDay()]} ${date.getDate()} ${arabicMonths[date.getMonth()]} ${date.getFullYear()}`);
};

export default function AddRequest({ isOpen, onClose, onSuccess, specialization, categoryId }) {
  const { user, logout, refreshUserProfile } = useContext(AuthContext);
  const navigate = useNavigate();
  const [date, setDate] = useState("");
  const [time, setTime] = useState("");
  const [time12Display, setTime12Display] = useState("");
  const [description, setDescription] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  if (!isOpen) return null;

  const handleTimeChange = (e) => {
    const time24 = e.target.value;
    setTime(time24);
    setTime12Display(formatTime12Hour(time24));
  };

  const handleTime12Change = (e) => {
    const time12 = e.target.value;
    setTime12Display(time12);
    const time24 = convertTime24Hour(time12);
    setTime(time24);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const token = user?.token || localStorage.getItem("token");

      if (!token || isTokenExpired(token)) {
        logout();
        onClose();
        navigate("/login");
        return;
      }

      const dateTime = `${date}T${time}:00`;

      // ── Step 1: Update doctor category FIRST so backend assigns correct category ──
      if (specialization) {
        let currentDoctor = user;

        if (!currentDoctor?.firstName) {
          currentDoctor = await refreshUserProfile(token).catch(() => user);
        }

        if (currentDoctor?.firstName) {
          try {
            await fetch("https://thoutha.page/api/doctor/updateDoctor", {
              method: "PUT",
              headers: {
                "Content-Type": "application/json",
                Authorization: `Bearer ${token}`,
              },
              body: JSON.stringify({
                firstName:      currentDoctor.firstName || currentDoctor.first_name,
                lastName:       currentDoctor.lastName || currentDoctor.last_name,
                email:          currentDoctor.email,
                phoneNumber:    currentDoctor.phoneNumber || currentDoctor.phone,
                universityName: currentDoctor.universityName || currentDoctor.faculty,
                studyYear:      currentDoctor.studyYear || currentDoctor.year,
                cityName:       currentDoctor.cityName || currentDoctor.city,
                categoryName:   specialization,
              }),
            });
            await refreshUserProfile(token).catch(() => null);
          } catch {
            // Silent — continue to create request
          }
        }
      }
      // ─────────────────────────────────────────────────────────────────────────────

      // ── Step 2: Create the request ────────────────────────────────────────────────
      const body = {
        description,
        dateTime,
        categoryId,
        categoryName: specialization,
      };

      const response = await fetch("https://thoutha.page/api/request/createRequest", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(body),
      });
      const resData = await response.json().catch(() => ({}));
      if (!response.ok) {
        throw new Error(resData?.message || resData?.messageAr || "فشل إرسال الطلب");
      }
      // ─────────────────────────────────────────────────────────────────────────────

      setDate("");
      setTime("");
      setDescription("");
      if (onSuccess) onSuccess();
      onClose();
    } catch (err) {
      setError(err.message || "حدث خطأ، حاول مرة أخرى");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="add-request-overlay" onClick={onClose}>
      <div
        className="add-request-modal"
        dir="rtl"
        onClick={(e) => e.stopPropagation()}
      >
        <button className="add-request-close" onClick={onClose} aria-label="إغلاق">
          ✕
        </button>

        <h2 className="add-request-title">طلب جديد</h2>

        <form onSubmit={handleSubmit} className="add-request-form">
          <div className="add-request-field">
            <label>التخصص</label>
            <input type="text" value={specialization} readOnly />
          </div>

          <div className="add-request-field">
            <label>التاريخ</label>
            <div style={{ display: "flex", gap: "10px", alignItems: "center" }}>
              <input
                type="date"
                value={date}
                onChange={(e) => setDate(e.target.value)}
                required
                style={{ flex: 1 }}
              />
              {date && <span style={{ color: "#666", fontSize: "14px", whiteSpace: "nowrap" }}>{formatDateArabic(date)}</span>}
            </div>
          </div>

          <div className="add-request-field">
            <label>الوقت (12 ساعة)</label>
            <input
              type="time"
              value={time}
              onChange={handleTimeChange}
              required
            />
            {time12Display && (
              <div style={{ marginTop: "8px", fontSize: "14px", color: "#666", textAlign: "right" }}>
                {time12Display}
              </div>
            )}
          </div>

          <div className="add-request-field">
            <label>الوصف</label>
            <textarea
              placeholder="اكتب وصف الحالة هنا..."
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={4}
            />
          </div>

          <button type="submit" className="add-request-submit" disabled={loading}>
            {loading ? "جاري الإرسال..." : "نشر طلب جديد"}
          </button>

          {error && <p className="add-request-error">{error}</p>}
        </form>
      </div>
    </div>
  );
}

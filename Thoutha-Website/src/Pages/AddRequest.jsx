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

export default function AddRequest({ isOpen, onClose, onSuccess, specialization, categoryId }) {
  const { user, logout, refreshUserProfile } = useContext(AuthContext);
  const navigate = useNavigate();
  const [date, setDate] = useState("");
  const [time, setTime] = useState("");
  const [description, setDescription] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  if (!isOpen) return null;

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
        ...(categoryId ? { categoryId } : {}),
        ...(specialization ? { categoryName: specialization } : {}),
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
            <input
              type="date"
              value={date}
              onChange={(e) => setDate(e.target.value)}
              required
            />
          </div>

          <div className="add-request-field">
            <label>الوقت</label>
            <input
              type="time"
              value={time}
              onChange={(e) => setTime(e.target.value)}
              required
            />
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

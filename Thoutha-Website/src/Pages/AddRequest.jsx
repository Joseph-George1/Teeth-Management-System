import { useState, useContext } from "react";
import { AuthContext } from "../services/AuthContext";
import "../Css/AddRequest.css";

export default function AddRequest({ isOpen, onClose, onSuccess, specialization }) {
  const { user } = useContext(AuthContext);
  const [date, setDate] = useState("");
  const [time, setTime] = useState("");
  const [notes, setNotes] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  if (!isOpen) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    try {
      const token = user?.token || localStorage.getItem("token");
      const response = await fetch("https://thoutha.page/api/request/createRequest", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({
          specialization,
          date,
          time,
          notes,
        }),
      });
      if (!response.ok) {
        const data = await response.json().catch(() => ({}));
        throw new Error(data?.message || data?.messageAr || "فشل إرسال الطلب");
      }
      const submittedRequest = {
        name: `${user?.firstName || user?.first_name || ""} ${user?.lastName || user?.last_name || ""}`.trim() || "مجهول",
        university: user?.faculty || user?.universityName || "",
        city: user?.city || "",
        specialization,
        date,
        time,
        notes,
      };
      setDate("");
      setTime("");
      setNotes("");
      if (onSuccess) onSuccess(submittedRequest);
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
            <label>ملاحظات</label>
            <textarea
              placeholder="اكتب ملاحظاتك هنا..."
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
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

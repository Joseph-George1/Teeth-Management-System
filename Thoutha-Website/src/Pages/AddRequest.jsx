import { useState } from "react";
import "../Css/AddRequest.css";

export default function AddRequest({ isOpen, onClose, specialization }) {
  const [date, setDate] = useState("");
  const [time, setTime] = useState("");
  const [notes, setNotes] = useState("");

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log({ specialization, date, time, notes });
    setDate("");
    setTime("");
    setNotes("");
    onClose();
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

          <button type="submit" className="add-request-submit">
            نشر طلب جديد
          </button>
        </form>
      </div>
    </div>
  );
}

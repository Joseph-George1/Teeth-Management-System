import { useState } from "react";
import "../Css/DoctorBooking.css";

const initialBookings = [
  {
    id: 1,
    patientName: "زياد جمال",
    phone: "01012345678",
    service: "تقويم أسنان",
    time: "11:30 صباحاً",
    date: "2025-12-10",
    status: "قادم",
  },
  {
    id: 2,
    patientName: "عبد الحليم رمضان",
    phone: "01098765432",
    service: "حشو عصب",
    time: "02:45 مساءً",
    date: "2025-12-11",
    status: "قادم",
  },
  {
    id: 3,
    patientName: "محمد أشرف",
    phone: "01156781234",
    service: "تنظيف أسنان",
    time: "10:15 صباحاً",
    date: "2025-12-12",
    status: "قادم",
  },
  {
    id: 4,
    patientName: "جوزيف جورج",
    phone: "01234567890",
    service: "تركيب كوبري",
    time: "04:30 مساءً",
    date: "2025-12-13",
    status: "قادم",
  },
];

export default function DoctorBookings() {
  const [bookings, setBookings] = useState(initialBookings);
  const [selectedBooking, setSelectedBooking] = useState(null);
  const [notificationCount, setNotificationCount] = useState(3);
  const [toast, setToast] = useState(null);

  const showToast = (msg, type = "success") => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleAccept = (e, id) => {
    e.stopPropagation();
    setBookings((prev) =>
      prev.map((b) => (b.id === id ? { ...b, status: "مقبول", accepted: true, rejected: false } : b))
    );
    showToast("تم قبول الحجز بنجاح ✓", "success");
  };

  const handleReject = (e, id) => {
    e.stopPropagation();
    setBookings((prev) =>
      prev.map((b) => (b.id === id ? { ...b, status: "مرفوض", rejected: true, accepted: false } : b))
    );
    showToast("تم رفض الحجز", "error");
  };

  const handleMenuClick = () => {
    console.log("Menu clicked – open drawer");
  };

  const handleNotificationClick = () => {
    setNotificationCount(0);
    console.log("Notifications clicked");
  };

  const getStatusClass = (booking) => {
    if (booking.accepted) return "accepted";
    if (booking.rejected) return "rejected";
    return "upcoming";
  };

  return (
    <div className="dnb-page" dir="rtl">
      {toast && (
        <div className={`dnb-toast dnb-toast--${toast.type}`}>{toast.msg}</div>
      )}

      <main className="dnb-content">
        <h1 className="dnb-page-title">حجوزاتي القادمة</h1>

        {bookings.length === 0 ? (
          <p className="dnb-empty">لا توجد حجوزات قادمة</p>
        ) : (
          <div className="dnb-booking-list">
            {bookings.map((booking) => (
              <div
                key={booking.id}
                className={`dnb-booking-card ${booking.accepted ? "dnb-card--accepted" : ""} ${booking.rejected ? "dnb-card--rejected" : ""}`}
                onClick={() => setSelectedBooking(booking)}
              >
                <div className="dnb-card-top">
                  <div className="dnb-card-info">
                    <h3 className="dnb-patient-name">{booking.patientName}</h3>
                    <span className="dnb-service-text">{booking.service}</span>
                  </div>
                  <span className={`dnb-status-badge dnb-status--${getStatusClass(booking)}`}>
                    {booking.status}
                  </span>
                </div>

                <div className="dnb-card-meta">
                  <span className="dnb-meta-item">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#6b7280" strokeWidth="2">
                      <rect x="3" y="4" width="18" height="18" rx="2" />
                      <line x1="16" y1="2" x2="16" y2="6" />
                      <line x1="8" y1="2" x2="8" y2="6" />
                      <line x1="3" y1="10" x2="21" y2="10" />
                    </svg>
                    {booking.date}
                  </span>
                  <span className="dnb-meta-item">
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="#6b7280" strokeWidth="2">
                      <circle cx="12" cy="12" r="10" />
                      <polyline points="12 6 12 12 16 14" />
                    </svg>
                    {booking.time}
                  </span>
                </div>

                {!booking.accepted && !booking.rejected && (
                  <div className="dnb-card-actions" onClick={(e) => e.stopPropagation()}>
                    <button
                      className="dnb-action-btn dnb-action-btn--accept"
                      onClick={(e) => handleAccept(e, booking.id)}
                    >
                      قبول
                    </button>
                    <button
                      className="dnb-action-btn dnb-action-btn--reject"
                      onClick={(e) => handleReject(e, booking.id)}
                    >
                      رفض
                    </button>
                  </div>
                )}
              </div>
            ))}
          </div>
        )}
      </main>

      {selectedBooking && (
        <div className="dnb-overlay" onClick={() => setSelectedBooking(null)}>
          <div className="dnb-sheet" onClick={(e) => e.stopPropagation()}>
            <div className="dnb-sheet-handle" />

            <div className="dnb-sheet-header">
              <h2 className="dnb-sheet-name">{selectedBooking.patientName}</h2>
              <span className={`dnb-status-badge dnb-status--${getStatusClass(selectedBooking)}`}>
                {selectedBooking.status}
              </span>
            </div>

            <div className="dnb-sheet-divider" />

            {[
              { icon: "📞", label: "رقم الهاتف", value: selectedBooking.phone },
              { icon: "📅", label: "التاريخ", value: selectedBooking.date },
              { icon: "⏰", label: "الوقت", value: selectedBooking.time },
              { icon: "🦷", label: "التخصص", value: selectedBooking.service },
            ].map(({ icon, label, value }) => (
              <div key={label} className="dnb-detail-row">
                <div className="dnb-detail-icon">{icon}</div>
                <div className="dnb-detail-text">
                  <span className="dnb-detail-label">{label}</span>
                  <span className="dnb-detail-value">{value}</span>
                </div>
              </div>
            ))}

            <button className="dnb-close-btn" onClick={() => setSelectedBooking(null)}>
              إغلاق
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

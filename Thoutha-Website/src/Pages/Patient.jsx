import { useState, useEffect } from "react";
import "../Css/DoctorBooking.css";

export default function Patient() {
  const [bookings, setBookings] = useState([]);
  const [selectedBooking, setSelectedBooking] = useState(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);

  useEffect(() => {
    // التحميل الأولي والاستماع للتغييرات
    const loadBookings = () => {
      const accepted = JSON.parse(localStorage.getItem("acceptedPatients") || "[]");
      setBookings(accepted);
    };
    
    loadBookings();
    
    // الاستماع لتغييرات localStorage من نافذة أخرى أو tab آخر
    window.addEventListener("storage", loadBookings);
    // أيضاً يمكن فحص localStorage بشكل دوري
    const interval = setInterval(loadBookings, 500);
    
    return () => {
      window.removeEventListener("storage", loadBookings);
      clearInterval(interval);
    };
  }, []);

  const openDetails = (booking) => setSelectedBooking(booking);
  const closeDetails = () => setSelectedBooking(null);

  const handleDeleteAll = () => {
    setShowDeleteConfirm(true);
  };

  const confirmDeleteAll = () => {
    localStorage.setItem("acceptedPatients", JSON.stringify([]));
    setBookings([]);
    setSelectedBooking(null);
    setShowDeleteConfirm(false);
  };

  const cancelDeleteAll = () => {
    setShowDeleteConfirm(false);
  };

  const getStatusClass = (booking) => {
    if (booking.statusClass) return booking.statusClass;
    if (booking.status === "مكتمل") return "completed";
    if (booking.status === "ملغي" || booking.status === "ملغى") return "cancelled";
    if (booking.status === "انتظار") return "pending";
    return "pending";
  };

  return (
    <div className="doctor-booking-page" dir="rtl">
      <main className="doctor-booking-content">
        <div style={{ display: "flex", justifyContent: "space-between", alignItems: "center", marginBottom: "30px" }}>
          <h1 className="page-title">جميع المرضى</h1>
          {bookings.length > 0 && (
            <button
              onClick={handleDeleteAll}
              style={{
                padding: "10px 20px",
                background: "linear-gradient(90deg, #ef4444, #dc2626)",
                color: "white",
                border: "none",
                borderRadius: "10px",
                fontSize: "14px",
                fontWeight: "700",
                fontFamily: "'Cairo', sans-serif",
                cursor: "pointer",
                transition: "transform 0.2s ease",
              }}
              onMouseEnter={(e) => e.target.style.transform = "translateY(-2px)"}
              onMouseLeave={(e) => e.target.style.transform = "translateY(0)"}
            >
              حذف جميع المرضى
            </button>
          )}
        </div>

        <div className="booking-list">
          {bookings.length === 0 ? (
            <div style={{ textAlign: "center", padding: "40px 20px", color: "#999" }}>
              <p style={{ fontSize: "18px", fontWeight: "600" }}>لا توجد مرضى حالياً</p>
              <p style={{ fontSize: "14px", marginTop: "10px" }}>سيظهر المرضى هنا عندما تكمل حجوزات من سجل الحجوزات</p>
            </div>
          ) : (
            bookings.map((booking, index) => (
              <div
                key={index}
                className="booking-card"
                onClick={() => openDetails(booking)}
              >
                <div className="booking-card-right">
                  <span 
                    className={`status-badge ${getStatusClass(booking)}`}
                    style={(booking.status === "مكتمل" || booking.status === "ملغى") ? { color: "white" } : {}}
                  >
                    {booking.status}
                  </span>
                  <div className="booking-name-wrapper">
                    <h3 className="booking-name">{booking.patientName}</h3>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </main>

      {selectedBooking && (
        <div className="bottom-sheet-overlay" onClick={closeDetails}>
          <div className="bottom-sheet" onClick={(e) => e.stopPropagation()}>
            <div className="sheet-handle"></div>
            <div className="sheet-header">
              <h2 className="sheet-patient-name">{selectedBooking.patientName}</h2>
            </div>
            <div className="sheet-divider"></div>
            <div className="detail-row">
              <div className="detail-icon">📞</div>
              <div className="detail-text">
                <span className="detail-label">رقم الهاتف</span>
                <span className="detail-value">{selectedBooking.phone}</span>
              </div>
            </div>
            <div className="detail-row">
              <div className="detail-icon">📅</div>
              <div className="detail-text">
                <span className="detail-label">التاريخ</span>
                <span className="detail-value">{selectedBooking.date}</span>
              </div>
            </div>
            <div className="detail-row">
              <div className="detail-icon">⏰</div>
              <div className="detail-text">
                <span className="detail-label">الوقت</span>
                <span className="detail-value">{selectedBooking.time}</span>
              </div>
            </div>
            <div className="detail-row">
              <div className="detail-icon">🦷</div>
              <div className="detail-text">
                <span className="detail-label">التخصص</span>
                <span className="detail-value">{selectedBooking.service}</span>
              </div>
            </div>
          </div>
        </div>
      )}

      {showDeleteConfirm && (
        <div className="bottom-sheet-overlay" onClick={cancelDeleteAll}>
          <div className="bottom-sheet" onClick={(e) => e.stopPropagation()}>
            <div className="sheet-handle"></div>
            <div className="sheet-header">
              <h2 style={{ color: "#333", textAlign: "center", fontSize: "18px", fontWeight: "700" }}>
                حذف جميع المرضى
              </h2>
            </div>
            <div className="sheet-divider"></div>
            <div style={{ textAlign: "center", padding: "20px", color: "#666" }}>
              <p style={{ fontSize: "16px", marginBottom: "20px" }}>
                هل أنت متأكد من حذف جميع المرضى؟ لا يمكن التراجع عن هذا الإجراء.
              </p>
            </div>
            <div style={{ display: "flex", gap: "10px", padding: "20px" }}>
              <button
                onClick={confirmDeleteAll}
                style={{
                  flex: 1,
                  padding: "12px 20px",
                  background: "linear-gradient(90deg, #ef4444, #dc2626)",
                  color: "white",
                  border: "none",
                  borderRadius: "10px",
                  fontSize: "15px",
                  fontWeight: "700",
                  fontFamily: "'Cairo', sans-serif",
                  cursor: "pointer",
                  transition: "transform 0.2s ease",
                }}
                onMouseEnter={(e) => e.target.style.transform = "scale(0.98)"}
                onMouseLeave={(e) => e.target.style.transform = "scale(1)"}
              >
                تأكيد الحذف
              </button>
              <button
                onClick={cancelDeleteAll}
                style={{
                  flex: 1,
                  padding: "12px 20px",
                  background: "#e5e7eb",
                  color: "#333",
                  border: "none",
                  borderRadius: "10px",
                  fontSize: "15px",
                  fontWeight: "700",
                  fontFamily: "'Cairo', sans-serif",
                  cursor: "pointer",
                  transition: "transform 0.2s ease",
                }}
                onMouseEnter={(e) => e.target.style.transform = "scale(0.98)"}
                onMouseLeave={(e) => e.target.style.transform = "scale(1)"}
              >
                إلغاء
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
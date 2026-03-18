import { useState, useEffect, useContext } from "react";
import { AuthContext } from "../services/AuthContext";
import "../Css/DoctorBooking.css";

// Helper functions
const getDate = (dt) => dt ? dt.split('T')[0] : '';
const getTime = (dt) => {
  if (!dt) return '';
  const parts = dt.split('T');
  return parts[1] ? parts[1].slice(0, 5) : '';
};

const getTimePeriod = (dt) => {
  const t = getTime(dt);
  if (!t) return '';
  const [h] = t.split(':').map(Number);
  return h < 12 ? 'صباحاً' : h < 17 ? 'ظهراً' : 'مساءً';
};

const normalizeList = (payload) => {
  if (Array.isArray(payload)) return payload;
  if (Array.isArray(payload?.data)) return payload.data;
  if (Array.isArray(payload?.result)) return payload.result;
  if (Array.isArray(payload?.content)) return payload.content;
  return [];
};

export default function DoctorBookings() {
  const { user, authLoading, isLoggedIn } = useContext(AuthContext);
  const [bookings, setBookings] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedBooking, setSelectedBooking] = useState(null);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    if (!isLoggedIn || authLoading) return;

    let cancelled = false;
    setLoading(true);
    setError("");

    const token = user?.token || localStorage.getItem("token");
    if (!token) {
      setError("لم نتمكن من الحصول على بيانات المستخدم");
      setLoading(false);
      return;
    }

    // قراءة البيانات من localStorage بدلاً من API
    try {
      const approvedAppointments = JSON.parse(localStorage.getItem("approvedAppointments") || "[]");
      
      const processedData = approvedAppointments.map((appt) => ({
        id: appt.id || Math.random(),
        patientName: `${appt.patientFirstName || ""} ${appt.patientLastName || ""}`.trim() || "مريض",
        phone: appt.patientPhoneNumber || "",
        service: appt.categoryName || "",
        description: appt.requestDescription || "",
        time: `${getTime(appt.appointmentDate)} ${getTimePeriod(appt.appointmentDate)}`,
        date: getDate(appt.appointmentDate),
        status: "مقبول",
        ...appt,
      }));
      
      if (!cancelled) {
        setBookings(processedData);
      }
    } catch (err) {
      if (!cancelled) setError("حدث خطأ أثناء قراءة البيانات");
    } finally {
      if (!cancelled) setLoading(false);
    }

    return () => { cancelled = true; };
  }, [isLoggedIn, authLoading, user]);

  const showToast = (msg, type = "success") => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleComplete = async (e, appointmentId) => {
    e.stopPropagation();
    
    const token = user?.token || localStorage.getItem("token");
    
    try {
      const response = await fetch(
        `https://thoutha.page/api/appointment/updateStatus/${appointmentId}?status=DONE`,
        {
          method: "PUT",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) throw new Error("فشل تحديث حالة الحجز");

      // حذف من localStorage
      const approvedAppointments = JSON.parse(localStorage.getItem("approvedAppointments") || "[]");
      const updated = approvedAppointments.filter(appt => appt.id !== appointmentId);
      localStorage.setItem("approvedAppointments", JSON.stringify(updated));

      setBookings((prev) => prev.filter((b) => b.id !== appointmentId));
      setSelectedBooking(null);
      showToast("تم اكمال الحجز بنجاح ✓", "success");
    } catch (err) {
      showToast(err.message || "فشل التحديث", "error");
    }
  };

  const handleCancel = async (e, appointmentId) => {
    e.stopPropagation();
    
    const token = user?.token || localStorage.getItem("token");
    
    try {
      const response = await fetch(
        `https://thoutha.page/api/appointment/updateStatus/${appointmentId}?status=CANCELLED`,
        {
          method: "PUT",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) throw new Error("فشل تحديث حالة الحجز");

      // حذف من localStorage
      const approvedAppointments = JSON.parse(localStorage.getItem("approvedAppointments") || "[]");
      const updated = approvedAppointments.filter(appt => appt.id !== appointmentId);
      localStorage.setItem("approvedAppointments", JSON.stringify(updated));

      setBookings((prev) => prev.filter((b) => b.id !== appointmentId));
      setSelectedBooking(null);
      showToast("تم الغاء الحجز بنجاح ✓", "success");
    } catch (err) {
      showToast(err.message || "فشل الالغاء", "error");
    }
  };

  const getStatusClass = (booking) => {
    if (booking.status === "مقبول") return "completed";
    if (booking.status === "ملغى") return "cancelled";
    return "upcoming";
  };

  const handleDelete = async (e, appointmentId) => {
    e.stopPropagation();
    
    if (!window.confirm("هل أنت متأكد من حذف هذا الحجز؟")) {
      return;
    }

    const token = user?.token || localStorage.getItem("token");
    
    try {
      const response = await fetch(
        `https://thoutha.page/api/appointment/deleteAppointment/${appointmentId}`,
        {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) throw new Error("فشل حذف الحجز");

      // حذف من localStorage
      const approvedAppointments = JSON.parse(localStorage.getItem("approvedAppointments") || "[]");
      const updated = approvedAppointments.filter(appt => appt.id !== appointmentId);
      localStorage.setItem("approvedAppointments", JSON.stringify(updated));

      setBookings((prev) => prev.filter((b) => b.id !== appointmentId));
      setSelectedBooking(null);
      showToast("تم حذف الحجز بنجاح ✓", "success");
    } catch (err) {
      showToast(err.message || "فشل الحذف", "error");
    }
  };

  return (
    <div className="dnb-page" dir="rtl">
      {toast && (
        <div className={`dnb-toast dnb-toast--${toast.type}`}>{toast.msg}</div>
      )}

      <main className="dnb-content">
        <h1 className="dnb-page-title">حجوزاتي</h1>

        {loading ? (
          <p className="dnb-empty">جاري تحميل الحجوزات...</p>
        ) : error ? (
          <p className="dnb-empty dnb-error">{error}</p>
        ) : bookings.length === 0 ? (
          <p className="dnb-empty">لا توجد حجوزات حالياً</p>
        ) : (
          <div className="dnb-booking-list">
            {bookings.map((booking) => (
              <div
                key={booking.id}
                className={`dnb-booking-card dnb-card--${getStatusClass(booking)}`}
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

                <div className="dnb-card-actions" onClick={(e) => e.stopPropagation()}>
                  <button 
                    className="dnb-action-btn dnb-action-btn--accept" 
                    onClick={(e) => handleComplete(e, booking.id)}
                  >
                    مكتمل
                  </button>
                  <button 
                    className="dnb-action-btn dnb-action-btn--reject" 
                    onClick={(e) => handleCancel(e, booking.id)}
                  >
                    ملغي
                  </button>
                  <button 
                    className="dnb-action-btn dnb-action-btn--delete" 
                    onClick={(e) => handleDelete(e, booking.id)}
                  >
                    حذف
                  </button>
                </div>
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
              { icon: "🦷", label: "فئة الخدمة", value: selectedBooking.service },
              ...(selectedBooking.description ? [{ icon: "📝", label: "الوصف", value: selectedBooking.description }] : []),
            ].map(({ icon, label, value }) => (
              <div key={label} className="dnb-detail-row">
                <div className="dnb-detail-icon">{icon}</div>
                <div className="dnb-detail-text">
                  <span className="dnb-detail-label">{label}</span>
                  <span className="dnb-detail-value">{value}</span>
                </div>
              </div>
            ))}

            <div className="dnb-sheet-actions">
              <button className="dnb-close-btn" onClick={() => setSelectedBooking(null)}>
                إغلاق
              </button>
              <button 
                className="dnb-action-btn dnb-action-btn--accept" 
                onClick={(e) => handleComplete(e, selectedBooking.id)}
              >
                مكتمل
              </button>
              <button 
                className="dnb-action-btn dnb-action-btn--reject" 
                onClick={(e) => handleCancel(e, selectedBooking.id)}
              >
                ملغي
              </button>
              <button 
                className="dnb-delete-btn" 
                onClick={(e) => handleDelete(e, selectedBooking.id)}
              >
                🗑 حذف
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

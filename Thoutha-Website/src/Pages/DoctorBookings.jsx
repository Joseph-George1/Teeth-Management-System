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

    // جلب الحجوزات المقبولة من API
    fetch("https://thoutha.page/api/appointment/getApproved", {
      headers: { Authorization: `Bearer ${token}` }
    })
      .then(res => {
        if (!res.ok) throw new Error("فشل جلب الحجوزات");
        return res.json();
      })
      .then(data => {
        if (!cancelled) {
          const normalizedData = normalizeList(data);
          
          const processedData = normalizedData.map((appt) => ({
            id: appt.id,
            patientName: `${appt.patientFirstName || ""} ${appt.patientLastName || ""}`.trim() || "مريض",
            phone: appt.patientPhoneNumber || "",
            service: appt.categoryName || "",
            description: appt.requestDescription || "",
            time: `${getTime(appt.appointmentDate)} ${getTimePeriod(appt.appointmentDate)}`,
            date: getDate(appt.appointmentDate),
            status: "مقبول",
            ...appt,
          }));
          
          setBookings(processedData);
        }
      })
      .catch(err => {
        if (!cancelled) setError(err.message || "حدث خطأ أثناء جلب الحجوزات");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

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

      // حذف من قائمة الحجوزات المقبولة
      setBookings((prev) => prev.filter((b) => b.id !== appointmentId));
      setSelectedBooking(null);
      showToast("تم اكمال الحجز وإضافته للمرضى كحالة مكتملة ✓", "success");
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

      // حذف من قائمة الحجوزات المقبولة
      setBookings((prev) => prev.filter((b) => b.id !== appointmentId));
      setSelectedBooking(null);
      showToast("تم الغاء الحالة وحذفها من الحجوزات ✓", "success");
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
          <div className="dnb-empty-state">
            <h3 className="dnb-empty-title">لا توجد حجوزات حالياً</h3>
            <p className="dnb-empty-text">الحجوزات التي تقبلها ستظهر هنا</p>
            <p className="dnb-empty-text">بعد قبول حجز من صفحة "الحجوزات المعلقة" سيظهر هنا</p>
          </div>
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
              { icon: "phone", label: "رقم الهاتف", value: selectedBooking.phone },
              { icon: "calendar", label: "التاريخ", value: selectedBooking.date },
              { icon: "clock", label: "الوقت", value: selectedBooking.time },
              { icon: "tooth", label: "فئة الخدمة", value: selectedBooking.service },
              ...(selectedBooking.description ? [{ icon: "note", label: "الوصف", value: selectedBooking.description }] : []),
            ].map(({ icon, label, value }) => {
              const iconSVGs = {
                phone: <svg viewBox="0 0 24 24" className="dnb-icon-svg" aria-hidden="true"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>,
                tooth: <svg viewBox="0 0 24 24" className="dnb-icon-svg" aria-hidden="true"><path d="M12 2C12 2 10 4 10 8c0 2 1 4 2 5v5c0 1.1.9 2 2 2s2-.9 2-2v-5c1-1 2-3 2-5 0-4-2-6-2-6z" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /><circle cx="12" cy="8" r="1.5" fill="currentColor" /></svg>,
                note: <svg viewBox="0 0 24 24" className="dnb-icon-svg" aria-hidden="true"><path d="M9 11l3 3L22 4M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill="none" /></svg>,
                calendar: <svg viewBox="0 0 24 24" className="dnb-icon-svg" aria-hidden="true"><rect x="3" y="4" width="18" height="18" rx="2" stroke="currentColor" strokeWidth="2" fill="none" /><path d="M16 2v4M8 2v4M3 10h18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" /></svg>,
                clock: <svg viewBox="0 0 24 24" className="dnb-icon-svg" aria-hidden="true"><circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2" fill="none" /><polyline points="12 6 12 12 16 14" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>,
              };
              return (
                <div key={label} className="dnb-detail-row">
                  <div className="dnb-detail-icon" aria-hidden="true">{iconSVGs[icon]}</div>
                  <div className="dnb-detail-text">
                    <span className="dnb-detail-label">{label}</span>
                    <span className="dnb-detail-value">{value}</span>
                  </div>
                </div>
              );
            })}

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
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

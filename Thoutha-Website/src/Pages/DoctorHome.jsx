import { useState, useContext, useEffect } from "react";
import { AuthContext } from "../services/AuthContext";
import "../Css/DoctorHome.css";

// ─── Helper Functions ─────────────────────────────────────────────────────────
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
// ─────────────────────────────────────────────────────────────────────────────

export default function DoctorHome() {
  const { user, authLoading, isLoggedIn } = useContext(AuthContext);
  const [appointments, setAppointments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");
  const [selectedAppt, setSelectedAppt] = useState(null);
  const [toast, setToast] = useState(null);

  useEffect(() => {
    if (!isLoggedIn || authLoading) return;

    let cancelled = false;
    setLoading(true);
    setError("");

    const token = user?.token || localStorage.getItem("token");
    const headers = token ? { Authorization: `Bearer ${token}` } : {};

    fetch("https://thoutha.page/api/appointment/pendingAppointments", { headers })
      .then((res) => {
        if (!res.ok) throw new Error("فشل جلب الحجوزات");
        return res.json();
      })
      .then((data) => {
        if (!cancelled) {
          const normalizedData = normalizeList(data);
          // عرض فقط الـ PENDING appointments
          const pendingOnly = normalizedData.filter(appt => appt.status === "PENDING");
          const processedData = pendingOnly.map((appt, idx) => ({
            id: appt.id || idx,
            name: `${appt.patientFirstName || ""} ${appt.patientLastName || ""}`.trim() || "مريض",
            phone: appt.patientPhoneNumber || "",
            specialty: appt.categoryName || "",
            description: appt.requestDescription || "",
            time: getTime(appt.appointmentDate),
            period: getTimePeriod(appt.appointmentDate),
            dateTime: appt.appointmentDate || "",
            doctorName: `${appt.doctorFirstName || ""} ${appt.doctorLastName || ""}`.trim(),
            doctorPhone: appt.doctorPhoneNumber || "",
            doctorCity: appt.doctorCity || "",
            status: appt.status,
            ...appt,
          }));
          setAppointments(processedData);
        }
      })
      .catch((err) => {
        if (!cancelled) setError(err.message || "حدث خطأ أثناء جلب الحجوزات");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });

    return () => { cancelled = true; };
  }, [isLoggedIn, authLoading, user]);

  const showToast = (msg, type) => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleAccept = async (e, id) => {
    e.stopPropagation();
    const appt = appointments.find(a => a.id === id);
    if (!appt) return;

    const token = user?.token || localStorage.getItem("token");
    
    try {
      const response = await fetch(
        `https://thoutha.page/api/appointment/updateStatus/${id}?status=APPROVED`,
        {
          method: "PUT",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) throw new Error("فشل تحديث حالة الحجز");

      // حذف من قائمة المعلقة
      setAppointments((prev) => prev.filter((a) => a.id !== id));
      setSelectedAppt(null);
      
      showToast("تم إضافة المريض للحجوزات القادمة بنجاح ✓", "success");
    } catch (err) {
      showToast(err.message || "فشل القبول", "error");
    }
  };

  const handleReject = async (e, id) => {
    e.stopPropagation();
    const appt = appointments.find(a => a.id === id);
    if (!appt) return;

    const token = user?.token || localStorage.getItem("token");

    try {
      const response = await fetch(
        `https://thoutha.page/api/appointment/updateStatus/${id}?status=CANCELLED`,
        {
          method: "PUT",
          headers: {
            Authorization: `Bearer ${token}`,
            "Content-Type": "application/json",
          },
        }
      );

      if (!response.ok) throw new Error("فشل تحديث حالة الحجز");

      setAppointments((prev) => prev.filter((a) => a.id !== id));
      setSelectedAppt(null);
      showToast("تم رفض الحجز", "error");
    } catch (err) {
      showToast(err.message || "فشل الرفض", "error");
    }
  };

  const handleDelete = (e, id) => {
    e.stopPropagation();
    setAppointments((prev) => prev.filter((a) => a.id !== id));
    setSelectedAppt(null);
    showToast("تم حذف الحجز", "info");
  };

  const displayName = [
    user?.firstName || user?.first_name,
    user?.lastName  || user?.last_name,
  ]
    .filter(Boolean)
    .join(" ") || "دكتور";

  return (
    <div className="dh-page" dir="rtl">
      {toast && (
        <div className={`dh-toast dh-toast--${toast.type}`}>{toast.msg}</div>
      )}

      {/* Body */}
      <main className="dh-content">

        {/* Welcome */}
        <section className="dh-welcome">
          {authLoading ? (
            <div className="dh-skeleton dh-skeleton--name" />
          ) : (
            <h1 className="dh-greeting">
              مرحباً يا د/ {displayName}
            </h1>
          )}
          <p className="dh-subtitle">إليك نظرة عامة على حجوزاتك وأدائك</p>
        </section>

        {/* Appointments */}
        <section className="dh-section">
          <h2 className="dh-section-title">الحجوزات المعلقة</h2>

          {loading ? (
            <p className="dh-empty">جاري تحميل الحجوزات...</p>
          ) : error ? (
            <p className="dh-empty dh-error">{error}</p>
          ) : appointments.length === 0 ? (
            <div className="dh-empty-state-instructions">
              <h3 className="dh-instructions-title">لا توجد حجوزات حالياً</h3>
              <p className="dh-instructions-text">عند قيام أي مريض بحجز موعد، سيظهر هنا اسمه ورقم هاتفه.</p>
              <p className="dh-instructions-text">يمكنك التواصل معه للتأكيد، ثم:</p>
              
              <div className="dh-instructions-section">
                <p className="dh-instructions-item">• اضغط "قبول" لإضافة الحجز إلى سجل الحجوزات كـ حالة مؤكدة.</p>
                <p className="dh-instructions-item">• اضغط "حذف" لإلغاء الحجز وإزالته نهائياً.</p>
              </div>

              <p className="dh-instructions-section-title">داخل سجل الحجوزات:</p>
              <div className="dh-instructions-section">
                <p className="dh-instructions-item">• بعد حضور المريض وإتمام الحالة، اضغط "مكتمل" ليتم نقلها إلى صفحة المرضى كحالة مكتملة.</p>
                <p className="dh-instructions-item">• في حال عدم حضور المريض، اضغط "ملغى".</p>
              </div>
            </div>
          ) : (
            <div className="dh-appt-list">
              {appointments.map((appt) => (
                <AppointmentCard
                  key={appt.id}
                  appt={appt}
                  onClick={() => setSelectedAppt(appt)}
                  onAccept={(e) => handleAccept(e, appt.id)}
                  onReject={(e) => handleReject(e, appt.id)}
                  onDelete={(e) => handleDelete(e, appt.id)}
                />
              ))}
            </div>
          )}
        </section>

      </main>

      {/* Details bottom sheet */}
      {selectedAppt && (
        <div className="dh-overlay" onClick={() => setSelectedAppt(null)}>
          <div className="dh-sheet" onClick={(e) => e.stopPropagation()}>
            <div className="dh-sheet-handle" />
            <div className="dh-sheet-header">
              <h2 className="dh-sheet-name">{selectedAppt.name}</h2>
              <div className="dh-appt-time-block dh-sheet-time">
                <span className="dh-appt-time">{selectedAppt.time}</span>
                <span className="dh-appt-period">{selectedAppt.period}</span>
              </div>
            </div>
            <div className="dh-sheet-divider" />
            {[
              { icon: "phone", label: "رقم الهاتف",  value: selectedAppt.phone },
              { icon: "tooth", label: "فئة الخدمة", value: selectedAppt.specialty },
              { icon: "note", label: "الوصف", value: selectedAppt.description || "بدون وصف" },
              { icon: "calendar", label: "التاريخ",      value: getDate(selectedAppt.dateTime) },
            ].map(({ icon, label, value }) => {
              const iconSVGs = {
                phone: <svg viewBox="0 0 24 24" className="dh-icon-svg" aria-hidden="true"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /></svg>,
                tooth: <svg viewBox="0 0 24 24" className="dh-icon-svg" aria-hidden="true"><path d="M12 2C12 2 10 4 10 8c0 2 1 4 2 5v5c0 1.1.9 2 2 2s2-.9 2-2v-5c1-1 2-3 2-5 0-4-2-6-2-6z" stroke="currentColor" strokeWidth="2" fill="none" strokeLinecap="round" strokeLinejoin="round" /><circle cx="12" cy="8" r="1.5" fill="currentColor" /></svg>,
                note: <svg viewBox="0 0 24 24" className="dh-icon-svg" aria-hidden="true"><path d="M9 11l3 3L22 4M21 12v7a2 2 0 01-2 2H5a2 2 0 01-2-2V5a2 2 0 012-2h11" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" fill="none" /></svg>,
                calendar: <svg viewBox="0 0 24 24" className="dh-icon-svg" aria-hidden="true"><rect x="3" y="4" width="18" height="18" rx="2" stroke="currentColor" strokeWidth="2" fill="none" /><path d="M16 2v4M8 2v4M3 10h18" stroke="currentColor" strokeWidth="2" strokeLinecap="round" /></svg>,
              };
              return (
                <div key={label} className="dh-detail-row">
                  <div className="dh-detail-icon" aria-hidden="true">{iconSVGs[icon]}</div>
                  <div className="dh-detail-text">
                    <span className="dh-detail-label">{label}</span>
                    <span className="dh-detail-value">{value}</span>
                  </div>
                </div>
              );
            })}
            <button className="dh-close-btn" onClick={() => setSelectedAppt(null)}>إغلاق</button>
            {!selectedAppt.accepted && !selectedAppt.rejected && (
              <div className="dh-sheet-actions">
                <button className="dh-action-btn dh-action-btn--accept" onClick={(e) => handleAccept(e, selectedAppt.id)}>قبول</button>
                <button className="dh-action-btn dh-action-btn--reject" onClick={(e) => handleReject(e, selectedAppt.id)}>رفض</button>
              </div>
            )}
            {(selectedAppt.accepted || selectedAppt.rejected) && (
              <button className="dh-action-btn dh-action-btn--delete" onClick={(e) => handleDelete(e, selectedAppt.id)}>حذف</button>
            )}
          </div>
        </div>
      )}
    </div>
  );
}

function AppointmentCard({ appt, onClick, onAccept, onReject, onDelete }) {
  return (
    <div
      className={`dh-appt-card ${appt.accepted ? "dh-card--accepted" : ""} ${appt.rejected ? "dh-card--rejected" : ""}`}
      onClick={onClick}
    >
      <div className="dh-appt-card-top">
        <div className="dh-appt-time-block">
          <span className="dh-appt-time">{appt.time}</span>
          <span className="dh-appt-period">{appt.period}</span>
        </div>
        <div className="dh-appt-divider" />
        <div className="dh-appt-info">
          <span className="dh-appt-name">{appt.name}</span>
          <span className="dh-appt-specialty">{appt.specialty}</span>
        </div>
        {!appt.accepted && !appt.rejected && <span className="dh-card-status dh-card-status--pending">انتظار</span>}
        {appt.accepted && <span className="dh-card-status dh-card-status--accepted">مقبول</span>}
        {appt.rejected && <span className="dh-card-status dh-card-status--rejected">مرفوض</span>}
      </div>
      <div className="dh-card-actions" onClick={(e) => e.stopPropagation()}>
        {!appt.accepted && !appt.rejected && (
          <>
            <button className="dh-action-btn dh-action-btn--accept" onClick={onAccept}>قبول</button>
            <button className="dh-action-btn dh-action-btn--reject" onClick={onReject}>رفض</button>
          </>
        )}
        {(appt.accepted || appt.rejected) && (
          <button className="dh-action-btn dh-action-btn--delete" onClick={onDelete}>حذف</button>
        )}
      </div>
    </div>
  );
}
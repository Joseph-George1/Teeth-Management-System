import { useState, useEffect, useContext } from "react";
import { AuthContext } from "../services/AuthContext";
import "../Css/DoctorHome.css";

// ─── Mock API ─────────────────────────────────────────────────────────────────
const fetchDoctorProfile = async () => {
  await new Promise((r) => setTimeout(r, 700));
  // Replace with: const res = await fetch('/api/doctor/profile'); return res.json();
  return { firstName: "أحمد", lastName: "محمد" };
};

const mockAppointments = [
  { id: 1, name: "محمد أشرف",        specialty: "تقويم أسنان",   time: "09:00", period: "صباحاً", phone: "01012345678" },
  { id: 2, name: "عبد الحليم رمضان", specialty: "حشو عصب",      time: "10:30", period: "صباحاً", phone: "01098765432" },
  { id: 3, name: "زياد جمال",         specialty: "زراعة أسنان",   time: "12:00", period: "ظهراً",  phone: "01156781234" },
  { id: 4, name: "سارة عبد الله",    specialty: "تنظيف أسنان",  time: "02:15", period: "مساءً",  phone: "01234567890" },
  { id: 5, name: "خالد عمر محمود",   specialty: "تركيب كوبري",  time: "04:00", period: "مساءً",  phone: "01087654321" },
];
// ─────────────────────────────────────────────────────────────────────────────

export default function DoctorHome() {
  const { user } = useContext(AuthContext);
  const [firstName, setFirstName]       = useState("");
  const [isLoadingName, setIsLoadingName] = useState(true);
  const [unreadCount, setUnreadCount]   = useState(4);
  const [appointments, setAppointments]  = useState(mockAppointments);
  const [selectedAppt, setSelectedAppt] = useState(null);
  const [toast, setToast] = useState(null);

  const showToast = (msg, type) => {
    setToast({ msg, type });
    setTimeout(() => setToast(null), 3000);
  };

  const handleAccept = (e, id) => {
    e.stopPropagation();
    setAppointments((prev) =>
      prev.map((a) => (a.id === id ? { ...a, accepted: true, rejected: false } : a))
    );
    setSelectedAppt((prev) => prev?.id === id ? { ...prev, accepted: true, rejected: false } : prev);
    showToast("تم الإضافة لصفحة المرضى ✓", "success");
  };

  const handleReject = (e, id) => {
    e.stopPropagation();
    setAppointments((prev) =>
      prev.map((a) => (a.id === id ? { ...a, rejected: true, accepted: false } : a))
    );
    setSelectedAppt((prev) => prev?.id === id ? { ...prev, rejected: true, accepted: false } : prev);
    showToast("تم رفض الحجز", "error");
  };

  const handleDelete = (e, id) => {
    e.stopPropagation();
    const appt = appointments.find((a) => a.id === id);
    if (appt?.accepted) {
      const existing = JSON.parse(localStorage.getItem("acceptedPatients") || "[]");
      const newPatient = {
        patientName: appt.name,
        phone: appt.phone,
        service: appt.specialty,
        time: `${appt.time} ${appt.period}`,
        date: new Date().toISOString().split("T")[0],
        status: "انتظار",
        statusClass: "pending",
      };
      localStorage.setItem("acceptedPatients", JSON.stringify([...existing, newPatient]));
      showToast("تم إضافة المريض بنجاح ✓", "success");
    }
    setAppointments((prev) => prev.filter((a) => a.id !== id));
    setSelectedAppt(null);
  };

  useEffect(() => {
    const cached = localStorage.getItem("doctorFirstName");
    if (cached) {
      setFirstName(cached);
      setIsLoadingName(false);
      return;
    }
    fetchDoctorProfile()
      .then(({ firstName: fn, lastName: ln }) => {
        setFirstName(fn);
        localStorage.setItem("doctorFirstName", fn);
        if (ln) localStorage.setItem("doctorLastName", ln);
      })
      .catch(() => {
        const email = localStorage.getItem("userEmail") || "";
        const fallback = email.split("@")[0] || "دكتور";
        setFirstName(fallback);
      })
      .finally(() => setIsLoadingName(false));
  }, []);

  const handleMenuClick = () => console.log("Menu – open drawer");
  const handleNotificationClick = () => {
    setUnreadCount(0);
    console.log("Notifications clicked");
  };

  const displayName = [
    user?.firstName || user?.first_name || firstName,
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
          {isLoadingName ? (
            <div className="dh-skeleton dh-skeleton--name" />
          ) : (
            <h1 className="dh-greeting">
              مرحباً يا د/ {firstName || "دكتور"}
            </h1>
          )}
          <p className="dh-subtitle">إليك نظرة عامة على حجوزاتك وأدائك</p>
        </section>

        {/* Appointments */}
        <section className="dh-section">
          <h2 className="dh-section-title">الحجوزات القادمة اليوم</h2>

          {appointments.length === 0 ? (
            <p className="dh-empty">لا توجد حجوزات لهذا اليوم</p>
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
              { icon: "📞", label: "رقم الهاتف",  value: selectedAppt.phone },
              { icon: "🦷", label: "التخصص",    value: selectedAppt.specialty },
              { icon: "⏰", label: "الوقت",      value: `${selectedAppt.time} ${selectedAppt.period}` },
            ].map(({ icon, label, value }) => (
              <div key={label} className="dh-detail-row">
                <div className="dh-detail-icon">{icon}</div>
                <div className="dh-detail-text">
                  <span className="dh-detail-label">{label}</span>
                  <span className="dh-detail-value">{value}</span>
                </div>
              </div>
            ))}
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
import { useContext, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import "../Css/DoctorProfile.css";

/* ── SVG Icons ── */
const EmailIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
  </svg>
);

const PhoneIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M3 5a2 2 0 012-2h3.28a1 1 0 01.948.684l1.498 4.493a1 1 0 01-.502 1.21l-2.257 1.13a11.042 11.042 0 005.516 5.516l1.13-2.257a1 1 0 011.21-.502l4.493 1.498a1 1 0 01.684.949V19a2 2 0 01-2 2h-1C9.716 21 3 14.284 3 6V5z" />
  </svg>
);

const CollegeIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path d="M12 14l9-5-9-5-9 5 9 5z" />
    <path d="M12 14l6.16-3.422a12.083 12.083 0 01.665 6.479A11.952 11.952 0 0012 20.055a11.952 11.952 0 00-6.824-2.998 12.078 12.078 0 01.665-6.479L12 14z" />
  </svg>
);

const PinIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
    <path strokeLinecap="round" strokeLinejoin="round" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
  </svg>
);

const MedIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M4.318 6.318a4.5 4.5 0 000 6.364L12 20.364l7.682-7.682a4.5 4.5 0 00-6.364-6.364L12 7.636l-1.318-1.318a4.5 4.5 0 00-6.364 0z" />
  </svg>
);

const BookIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" />
  </svg>
);

const UpdateIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
  </svg>
);

const LockIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
  </svg>
);

const TrashIcon = () => (
  <svg width="18" height="18" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
    <path strokeLinecap="round" strokeLinejoin="round" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
  </svg>
);

/* ── Info Card Sub-component ── */
const InfoCard = ({ icon, label, value, accent, wide }) => {
  const [hovered, setHovered] = useState(false);

  return (
    <div
      className={`info-card ${wide ? "info-card--wide" : ""} ${hovered ? "info-card--hovered" : ""}`}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
    >
      <div className="icon-box" style={{ background: `${accent}15`, color: accent }}>
        {icon}
      </div>
      <div className="info-text">
        <span className="info-label">{label}</span>
        <span className="info-value">{value}</span>
      </div>
    </div>
  );
};

export default function DoctorProfile() {
  const { user, authLoading, refreshUserProfile } = useContext(AuthContext);
  const navigate = useNavigate();
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    if (authLoading) return;

    const token = localStorage.getItem("token");
    if (!token) {
      navigate("/login", { replace: true });
      return;
    }

    let cancelled = false;
    setLoading(true);
    setError("");

    refreshUserProfile(token)
      .catch((err) => {
        if (!cancelled) {
          setError(err.message || "تعذر تحميل بيانات الملف الشخصي");
        }
      })
      .finally(() => {
        if (!cancelled) {
          setLoading(false);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [authLoading, navigate, refreshUserProfile]);

  if (authLoading || loading) {
    return (
      <div className="dp-loading-screen" dir="rtl">
        <div className="dp-spinner"></div>
        <p>جاري تحميل البيانات...</p>
      </div>
    );
  }

  if (error && !user) {
    return (
      <div className="dp-error-screen" dir="rtl">
        <p>{error}</p>
        <button onClick={() => window.location.reload()} className="dp-retry-btn">
          إعادة المحاولة
        </button>
      </div>
    );
  }

  const getInitials = () => {
    const first = user?.firstName || user?.first_name || "U";
    return `${first[0]}`;
  };

  return (
    <div className="dp-root" dir="rtl">
      <style>{`
        @import url('https://fonts.googleapis.com/css2?family=Tajawal:wght@300;400;500;700;800&display=swap');

        @keyframes fadeInUp {
          from { opacity: 0; transform: translateY(24px); }
          to   { opacity: 1; transform: translateY(0); }
        }
        @keyframes floatBlob {
          0%, 100% { transform: translate(0, 0) scale(1); }
          50%       { transform: translate(20px, -20px) scale(1.05); }
        }
        @keyframes shimmer {
          0%   { opacity: 0.6; }
          50%  { opacity: 1; }
          100% { opacity: 0.6; }
        }
        @keyframes pulseRing {
          0%, 100% { box-shadow: 0 0 0 0 rgba(37,180,229,0.35); }
          50%       { box-shadow: 0 0 0 12px rgba(37,180,229,0); }
        }
      `}</style>

      {/* Background blobs */}
      <div className="dp-blob dp-blob1" />
      <div className="dp-blob dp-blob2" />

      <div className="dp-wrapper">
        {/* Profile Card */}
        <div className="dp-card">

          {/* Header */}
          <div className="dp-header-section">
            <div className="dp-header-glow" />
            <div className="dp-avatar-ring">
              <div className="dp-avatar">
                <span className="dp-initials">{getInitials()}</span>
              </div>
            </div>
            <h1 className="dp-full-name">{user?.firstName || user?.first_name} {user?.lastName || user?.last_name}</h1>
            <div className="dp-badge">
              <span className="dp-badge-dot" />
              <span className="dp-badge-text">{user?.specialization || user?.specialty || "تخصص"}</span>
            </div>
            <div className="dp-header-divider" />
          </div>

          {/* Info Grid */}
          <div className="dp-info-section">
            <h2 className="dp-section-title">المعلومات الشخصية</h2>

            <div className="dp-info-grid">
              <InfoCard
                icon={<EmailIcon />}
                label="البريد الإلكتروني"
                value={user?.email}
                accent="#1D61E7"
              />
              <InfoCard
                icon={<PhoneIcon />}
                label="رقم الهاتف"
                value={user?.phone}
                accent="#25B4E5"
              />
              <InfoCard
                icon={<CollegeIcon />}
                label="الكلية"
                value={user?.faculty || user?.universityName || "غير محدد"}
                accent="#1D61E7"
                wide
              />
              <InfoCard
                icon={<PinIcon />}
                label="المحافظة"
                value={user?.city || "غير محدد"}
                accent="#25B4E5"
              />
              <InfoCard
                icon={<MedIcon />}
                label="التخصص"
                value={user?.specialization || user?.specialty || "غير محدد"}
                accent="#1D61E7"
              />
              <InfoCard
                icon={<BookIcon />}
                label="السنة الدراسية"
                value={user?.year || user?.studyYear || "غير محدد"}
                accent="#25B4E5"
              />
            </div>
          </div>

          {/* Divider */}
          <div className="dp-divider" />

          {/* Buttons */}
          <div className="dp-buttons-section">
            <button
              className="dp-btn dp-btn--primary"
              onClick={() => navigate("/profile-update")}
              onMouseEnter={e => {
                e.currentTarget.style.transform = "translateY(-2px)";
                e.currentTarget.style.boxShadow = "0 12px 32px rgba(29,97,231,0.45)";
              }}
              onMouseLeave={e => {
                e.currentTarget.style.transform = "translateY(0)";
                e.currentTarget.style.boxShadow = "0 6px 20px rgba(29,97,231,0.3)";
              }}
            >
              <UpdateIcon />
              تحديث الملف الشخصي
            </button>

            <button
              className="dp-btn dp-btn--secondary"
              onClick={() => navigate("/forget-password")}
              onMouseEnter={e => {
                e.currentTarget.style.background = "rgba(29,97,231,0.08)";
                e.currentTarget.style.transform = "translateY(-2px)";
              }}
              onMouseLeave={e => {
                e.currentTarget.style.background = "transparent";
                e.currentTarget.style.transform = "translateY(0)";
              }}
            >
              <LockIcon />
              تغيير كلمة السر
            </button>

            <button
              className="dp-btn dp-btn--danger"
              onClick={() => navigate("/delete-my-account")}
              onMouseEnter={e => {
                e.currentTarget.style.background = "#EF4444";
                e.currentTarget.style.color = "#fff";
                e.currentTarget.style.transform = "translateY(-2px)";
                e.currentTarget.style.boxShadow = "0 8px 24px rgba(239,68,68,0.35)";
              }}
              onMouseLeave={e => {
                e.currentTarget.style.background = "transparent";
                e.currentTarget.style.color = "#EF4444";
                e.currentTarget.style.transform = "translateY(0)";
                e.currentTarget.style.boxShadow = "none";
              }}
            >
              <TrashIcon />
              حذف الحساب
            </button>
          </div>

        </div>
      </div>
    </div>
  );
}
import { useContext, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import "../Css/DoctorProfile.css";

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

  const infoItems = [
    { icon: "👤", label: "الاسم الأول",       value: user?.firstName || user?.first_name },
    { icon: "👤", label: "اسم العائلة",        value: user?.lastName  || user?.last_name  },
    { icon: "📧", label: "البريد الإلكتروني",  value: user?.email                         },
    { icon: "📞", label: "رقم الهاتف",         value: user?.phone                         },
    { icon: "🦷", label: "التخصص",             value: user?.specialization                },
    { icon: "🏫", label: "الكلية",             value: user?.faculty || user?.universityName },
    { icon: "📚", label: "السنة الدراسية",     value: user?.year || user?.studyYear       },
    { icon: "📍", label: "المحافظة",           value: user?.city                          },
  ];

  return (
    <div className="dp-page" dir="rtl">

      {/* Header */}
      <header className="dp-header">
        <span className="dp-header-title">الملف الشخصي</span>
      </header>

      <main className="dp-content">
        <div className="dp-card">
          {error && user ? <p className="dp-inline-error">{error}</p> : null}

          {/* Info rows */}
          <div className="dp-info-list">
            {infoItems.map(({ label, value }) =>
              value ? (
                <div key={label} className="dp-info-row">
                  <div className="dp-info-text">
                    <span className="dp-info-label">{label}</span>
                    <span className="dp-info-value">{value}</span>
                  </div>
                </div>
              ) : null
            )}
          </div>

          <div className="dp-divider" />

          {/* Action buttons */}
          <div className="dp-actions">
            <button
              className="dp-action-btn dp-action-btn--primary"
              onClick={() => navigate("/profile-update")}
            >
              تحديث الملف الشخصي
            </button>
            <button
              className="dp-action-btn dp-action-btn--primary"
              onClick={() => navigate("/forget-password")}
            >
              تغيير كلمة المرور
            </button>
            <button
              className="dp-action-btn dp-action-btn--danger"
              onClick={() => navigate("/delete-my-account")}
            >
              حذف الحساب
            </button>
          </div>

        </div>
      </main>
    </div>
  );
}


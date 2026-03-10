import { useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { AuthContext } from "../services/AuthContext";
import "../Css/DeleteMyAccount.css";

export default function DeleteMyAccount() {  const { logout, user } = useContext(AuthContext);
  const navigate = useNavigate();

  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleDelete = async () => {
    setLoading(true);
    setError(null);

    try {
      const token = user?.token || localStorage.getItem("token");

      if (!token) {
        throw new Error("لم يتم العثور على جلسة تسجيل الدخول");
      }

      console.log("token being sent:", token);

      const response = await fetch(
        "https://thoutha.page/api/doctor/deleteDoctor",
        {
          method: "DELETE",
          headers: {
            Authorization: `Bearer ${token}`,
          },
        }
      );

      console.log("deleteDoctor status:", response.status);

      if (!response.ok) {
        const data = await response.json().catch(() => ({}));
        console.log("deleteDoctor error body:", data);

        throw new Error(
          data?.message ||
          data?.messageAr ||
          "فشل حذف الحساب، حاول مرة أخرى"
        );
      }

      // تسجيل خروج بعد الحذف
      logout();

      // الرجوع للصفحة الرئيسية
      navigate("/", { replace: true });

    } catch (err) {
      setError(err.message || "حدث خطأ غير متوقع");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="da-page" dir="rtl">
      <header className="da-header">
        <span className="da-header-title">حذف الحساب الشخصي</span>
      </header>

      <main className="da-content">
        <div className="da-card">

          {/* Warning icon */}
          <div className="da-icon-wrap">
            <svg width="56" height="56" viewBox="0 0 24 24" fill="none">
              <circle cx="12" cy="12" r="11" stroke="#ef4444" strokeWidth="1.5" />
              <path d="M12 7v5" stroke="#ef4444" strokeWidth="2" strokeLinecap="round" />
              <circle cx="12" cy="16.5" r="1" fill="#ef4444" />
            </svg>
          </div>

          <h2 className="da-title">هل أنت متأكد؟</h2>

          <p className="da-desc">
            أنت على وشك حذف حسابك الشخصي نهائياً من منصة <strong>ثوثة</strong>.
            هذا الإجراء لا يمكن التراجع عنه.
          </p>

          <div className="da-info-box">
            <p>عند تأكيد الحذف سيتم:</p>
            <ul>
              <li>حذف جميع بياناتك الشخصية</li>
              <li>إلغاء جميع الحجوزات والطلبات المرتبطة بحسابك</li>
              <li>تسجيل خروجك فوراً</li>
            </ul>
          </div>

          {error && <p className="da-error">{error}</p>}

          <div className="da-actions">
            <button
              className="da-btn da-btn--danger"
              onClick={handleDelete}
              disabled={loading}
            >
              {loading ? "جاري الحذف..." : "تأكيد حذف الحساب"}
            </button>

            <button
              className="da-btn da-btn--cancel"
              onClick={() => navigate(-1)}
              disabled={loading}
            >
              إلغاء
            </button>
          </div>

        </div>
      </main>
    </div>
  );
}

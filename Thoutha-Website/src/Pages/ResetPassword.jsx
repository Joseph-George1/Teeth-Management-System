import { useState } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import "../Css/Otp.css";

const API_CHANGE_PASSWORD = "https://thoutha.page/api/password-reset/change-password";

export default function ResetPassword() {
  const navigate = useNavigate();
  const location = useLocation();

  const phone =
    location.state?.phone || sessionStorage.getItem("reset_phone") || "";

  const [newPassword, setNewPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [success, setSuccess] = useState("");

  const handleSubmit = async () => {
    setError("");

    if (!newPassword || !confirmPassword) {
      setError("يرجى تعبئة جميع الحقول");
      return;
    }

    if (newPassword !== confirmPassword) {
      setError("كلمتا المرور غير متطابقتين");
      return;
    }

    if (newPassword.length < 8) {
      setError("يجب أن تكون كلمة المرور 8 أحرف على الأقل");
      return;
    }

    try {
      setLoading(true);

      const response = await fetch(API_CHANGE_PASSWORD, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          phone_number: phone,
          new_password: newPassword,
          confirm_password: confirmPassword,
        }),
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        if (response.status === 403) {
          throw new Error("لم يتم التحقق من الكود بعد. يرجى إعادة المحاولة");
        }
        if (response.status === 410) {
          throw new Error("انتهت جلسة التحقق. يرجى بدء العملية من جديد");
        }
        throw new Error(data?.message || "فشل تغيير كلمة المرور");
      }

      sessionStorage.removeItem("reset_phone");
      setSuccess("تم تغيير كلمة المرور بنجاح");

      setTimeout(() => navigate("/login"), 1500);
    } catch (err) {
      setError(err.message || "حدث خطأ أثناء تغيير كلمة المرور");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="otp-page">
      <div className="otp-container2" style={{ height: "auto", padding: "24px 24px 28px" }}>
        <p className="otp-title">إعادة تعيين كلمة المرور</p>
        <p className="otp-subtitle">ادخل كلمة المرور الجديدة</p>

        <div className="otp-code">
          <p className="otp-text">تغيير كلمة المرور</p>
          <p className="otp-text-2">
            ادخل كلمة المرور الجديدة وتأكيدها لإتمام العملية
          </p>
        </div>

        <input
          type="password"
          className="otp-phone-input"
          placeholder="كلمة المرور الجديدة"
          value={newPassword}
          onChange={(e) => setNewPassword(e.target.value)}
          dir="rtl"
          disabled={loading}
        />

        <input
          type="password"
          className="otp-phone-input"
          placeholder="تأكيد كلمة المرور"
          value={confirmPassword}
          onChange={(e) => setConfirmPassword(e.target.value)}
          dir="rtl"
          disabled={loading}
        />

        <div className="otp-btn">
          <button
            className="otp-button"
            onClick={handleSubmit}
            disabled={loading}
          >
            {loading ? "جاري التنفيذ..." : "تغيير كلمة المرور"}
          </button>
        </div>

        {error && <p className="otp-status" style={{ color: "#d32f2f" }}>{error}</p>}
        {success && <p className="otp-status" style={{ color: "#2e7d32" }}>{success}</p>}
      </div>
    </div>
  );
}

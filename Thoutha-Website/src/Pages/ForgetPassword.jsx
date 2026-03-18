import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../Css/Otp.css";

const API_REQUEST_RESET = "https://thoutha.page/api/password-reset/request";

export default function ForgetPassword() {
  const navigate = useNavigate();
  const [phone, setPhone] = useState("+20");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  const normalizePhone = (value) => {
    let cleaned = value.replace(/[^\d+]/g, "");
    if (!cleaned.startsWith("+20")) {
      cleaned = "+20" + cleaned.replace(/\D/g, "").replace(/^20/, "");
    }
    return cleaned.trim();
  };

  const isValidEgyptPhone = (number) => /^\+20\d{10}$/.test(number);

  const handleChange = (e) => {
    setPhone(normalizePhone(e.target.value));
  };

  const handleSubmit = async () => {
    const normalizedPhone = normalizePhone(phone);

    if (!isValidEgyptPhone(normalizedPhone)) {
      setError("من فضلك ادخل رقم صحيح بصيغة +20XXXXXXXXXX");
      return;
    }

    try {
      setLoading(true);
      setError("");

      console.log("🔑 [RESET FLOW] Requesting password reset for:", normalizedPhone);

      const response = await fetch(API_REQUEST_RESET, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ phone_number: normalizedPhone }),
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        if (response.status === 404) {
          throw new Error("لا يوجد حساب مرتبط بهذا الرقم");
        }
        if (response.status === 429) {
          throw new Error("تجاوزت الحد المسموح. يرجى الانتظار قليلاً");
        }
        if (response.status === 500) {
          // Backend يرجع 500 بدل 404 للأرقام غير الموجودة
          throw new Error("لا يوجد حساب مرتبط بهذا الرقم");
        }
        throw new Error(data?.message || "فشل إرسال كود التحقق");
      }

      // Store flow type and phone in sessionStorage for Reset flow
      sessionStorage.setItem("flow_type", "reset");
      sessionStorage.setItem("reset_phone", normalizedPhone);

      console.log("✅ [RESET] Stored in sessionStorage - flow_type: reset, reset_phone:", normalizedPhone);

      navigate("/otp-verify", {
        state: { phone: normalizedPhone },
      });
    } catch (err) {
      setError(err.message || "حدث خطأ أثناء إرسال الكود");
      console.error("❌ [RESET] Error:", err);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="otp-page">
      <div className="otp-container2">
        <p className="otp-title">نسيت كلمة المرور</p>
        <p className="otp-subtitle">ادخل رقم هاتفك لإعادة تعيين كلمة المرور</p>

        <div className="otp-code">
          <p className="otp-text">إرسال كود التحقق عبر واتساب</p>
          <p className="otp-text-2">
            ادخل رقم الهاتف المسجل وسيتم إرسال كود التحقق على الواتساب
          </p>
        </div>

        <input
          type="tel"
          className="otp-phone-input"
          placeholder="+20XXXXXXXXXX"
          value={phone}
          onChange={handleChange}
          dir="rtl"
          disabled={loading}
        />

        <div className="otp-btn">
          <button
            className="otp-button"
            onClick={handleSubmit}
            disabled={loading}
          >
            {loading ? "جاري التنفيذ..." : "إرسال كود التحقق"}
          </button>
        </div>

        {error && <p className="otp-status">{error}</p>}
      </div>
    </div>
  );
}

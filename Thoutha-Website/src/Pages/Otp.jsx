import { useState, useEffect } from "react";
import { useNavigate, useLocation } from "react-router-dom";
import "../Css/Otp.css";

const API_SEND_OTP = "https://thoutha.page/api/otp/send";

export default function Otp() {
  const navigate = useNavigate();
  const location = useLocation();

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

  useEffect(() => {
    const phoneFromState = location.state?.phone;
    if (phoneFromState) {
      const normalized = normalizePhone(phoneFromState);
      setPhone(normalized);
    }
  }, []);

  const handleChange = (e) => {
    setPhone(normalizePhone(e.target.value));
  };

  const sendOtp = async (phoneNumber) => {
    const normalizedPhone = normalizePhone(phoneNumber || phone);

    if (!isValidEgyptPhone(normalizedPhone)) {
      setError("من فضلك ادخل رقم صحيح بصيغة +20XXXXXXXXXX");
      return;
    }

    try {
      setLoading(true);
      setError("");


      const response = await fetch(API_SEND_OTP, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          phone_number: normalizedPhone,
        }),
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        throw new Error(data?.message || "فشل إرسال الكود");
      }

      sessionStorage.setItem("flow_type", "signup");
      sessionStorage.setItem("otp_phone", normalizedPhone);


      navigate("/otp-verify", {
        state: { phone: normalizedPhone },
      });

    } catch (err) {
      setError(err.message || "حدث خطأ أثناء إرسال الكود");
    } finally {
      setLoading(false);
    }
  };

  const handleSendOtp = () => sendOtp(phone);

  return (
    <div className="otp-page">
      <div className="otp-container2">
        <p className="otp-title">كود التفعيل</p>
        <p className="otp-subtitle">فعل الحساب للمتابعه</p>

        <div className="otp-code">
          <p className="otp-text">تفعيل عبر واتساب</p>
          <p className="otp-text-2">
            ادخل رقم التليفون وسيتم ارسال كود التفعيل على الواتساب
          </p>
        </div>

        <input
          type="tel"
          className="otp-phone-input"
          placeholder="+20XXXXXXXXXX"
          value={phone}
          onChange={handleChange}
          dir="rtl"
        />

        <div className="otp-btn">
          <button
            className="otp-button"
            onClick={handleSendOtp}
            disabled={loading}
          >
            {loading ? "جاري التنفيذ..." : "ارسال كود التفعيل"}
          </button>
        </div>

        {error && <p className="otp-status">{error}</p>}
      </div>
    </div>
  );
}

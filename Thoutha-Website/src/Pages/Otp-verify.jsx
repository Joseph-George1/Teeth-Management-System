import { useRef, useState, useEffect } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import "../Css/Otp.css";

const API_VERIFY_OTP = "https://thoutha.page/api/otp/verify";
const API_SEND_OTP = "https://thoutha.page/api/otp/send";
const API_VERIFY_RESET_OTP = "https://thoutha.page/api/password-reset/verify-otp";
const API_REQUEST_RESET = "https://thoutha.page/api/password-reset/request";
const OTP_LENGTH = 6;

export default function OtpVerify() {
  const navigate = useNavigate();
  const location = useLocation();

  const flowType = sessionStorage.getItem("flow_type");
  const isResetFlow = flowType === "reset";

  const getVerifyUrl = () => {
    return isResetFlow ? API_VERIFY_RESET_OTP : API_VERIFY_OTP;
  };

  const getResendUrl = () => {
    return isResetFlow ? API_REQUEST_RESET : API_SEND_OTP;
  };

  const storedPhone = isResetFlow
    ? sessionStorage.getItem("reset_phone")
    : sessionStorage.getItem("otp_phone");

  const phone = (storedPhone || location.state?.phone || "").trim();

  const [otp, setOtp] = useState(Array(OTP_LENGTH).fill(""));
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(
    phone ? "" : "ادخل رقم التليفون اولا من صفحة الارسال"
  );

  const inputsRef = useRef([]);

  useEffect(() => {
    if (!phone) {
      navigate(isResetFlow ? "/forget-password" : "/otp", { replace: true });
    }
  }, [phone, isResetFlow, navigate]);

  const handleVerify = async () => {
    const code = otp.join("").trim();

    if (!phone) {
      setMessage("ادخل رقم التليفون اولا من صفحة الارسال");
      return;
    }

    if (code.length !== OTP_LENGTH) {
      setMessage("من فضلك ادخل كود التفعيل كامل");
      return;
    }

    try {
      setLoading(true);
      setMessage("");

      const verifyUrl = getVerifyUrl();

      const response = await fetch(verifyUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          phone_number: phone,
          otp: code,
        }),
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        if (response.status === 404) {
          throw new Error(
            isResetFlow
              ? "لا يوجد كود تحقق نشط لهذا الرقم. يرجى إعادة الطلب."
              : "لا يوجد كود تفعيل نشط لهذا الرقم. تأكد انك ارسلت الكود اولا."
          );
        }
        if (response.status === 410) {
          throw new Error("انتهت صلاحية الكود. يرجى طلب كود جديد");
        }
        if (response.status === 429) {
          throw new Error("تجاوزت عدد المحاولات المسموح بها. حاول لاحقاً");
        }
        throw new Error(data?.message || "الكود غير صحيح");
      }

      if (isResetFlow) {
        sessionStorage.removeItem("reset_phone");
        sessionStorage.removeItem("flow_type");
        navigate("/reset-password", { state: { phone } });
      } else {
        sessionStorage.removeItem("otp_phone");
        sessionStorage.removeItem("flow_type");
        navigate("/otp-done");
      }

    } catch (err) {
      setMessage(err.message || "حدث خطأ أثناء التحقق من الكود");
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    if (!phone) {
      setMessage("ادخل رقم التليفون اولا من صفحة الارسال");
      return;
    }

    try {
      setLoading(true);
      setMessage("");

      const resendUrl = getResendUrl();

      const response = await fetch(resendUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          phone_number: phone,
        }),
      });

      const data = await response.json().catch(() => ({}));

      if (!response.ok) {
        throw new Error(data?.message || "فشل إعادة إرسال الكود");
      }

      setMessage("✅ تم إعادة إرسال الكود بنجاح");

    } catch (err) {
      setMessage(err.message || "حدث خطأ أثناء إعادة الإرسال");
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (index, value) => {
    if (!/^\d?$/.test(value)) return;

    const updated = [...otp];
    updated[index] = value;
    setOtp(updated);

    if (value && index < OTP_LENGTH - 1) {
      inputsRef.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (index, e) => {
    if (e.key === "Backspace" && !otp[index] && index > 0) {
      inputsRef.current[index - 1]?.focus();
    }
  };

  return (
    <div className="otp-page">
      <div className="otp-container">
        <p className="otp-title">{isResetFlow ? "كود التحقق" : "كود التفعيل"}</p>
        <p className="otp-subtitle">
          {isResetFlow ? "ادخل الكود لإعادة تعيين كلمة المرور" : "فعل الحساب للمتابعه"}
        </p>

        <div className="otp-code">
          <p className="otp-text">
            {isResetFlow ? "تم ارسال كود التحقق" : "تم ارسال كود التفعيل"}
          </p>
          <p className="otp-text-2">
            {isResetFlow
              ? "لقد ارسلنا لك كود على الواتساب. ادخله لإعادة تعيين كلمة المرور"
              : "لقد ارسلنا لك كود اكتبه لكي تفعل الحساب الخاص بك"}
          </p>
          {phone && <p className="otp-text-2">{phone}</p>}
        </div>

        <div className="otp-inputs" dir="ltr">
          {otp.map((value, index) => (
            <input
              key={index}
              ref={(el) => (inputsRef.current[index] = el)}
              type="text"
              maxLength="1"
              value={value}
              onChange={(e) => handleChange(index, e.target.value)}
              onKeyDown={(e) => handleKeyDown(index, e)}
              className="otp-input"
              inputMode="numeric"
              disabled={loading}
            />
          ))}
        </div>

        <div className="otp-btn">
          <button
            className="otp-button"
            onClick={handleVerify}
            disabled={loading}
          >
            {loading ? "جاري التحقق..." : "تحقق من الرمز"}
          </button>
        </div>

        <div className="otp-resend">
          <a
            href="#"
            onClick={(e) => {
              e.preventDefault();
              if (!loading) handleResend();
            }}
          >
            ارسل الرمز مره اخرى
          </a>
        </div>

        {message && <p className="otp-status">{message}</p>}
      </div>
    </div>
  );
}

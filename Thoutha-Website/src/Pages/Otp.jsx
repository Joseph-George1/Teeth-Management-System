// import { useState } from "react";
// import { useNavigate } from "react-router-dom";
// import "../Css/Otp.css";

// const API_SEND_OTP = "https://thoutha.page/api/otp/send";

// export default function Otp() {
//   const navigate = useNavigate();
//   const [phone, setPhone] = useState("+20");
//   const [loading, setLoading] = useState(false);
//   const [error, setError] = useState("");

//   const isValidEgyptPhone = (number) => /^\+20\d{10}$/.test(number);

//   const handleChange = (e) => {
//     let value = e.target.value.replace(/[^\d+]/g, "");

//     if (!value.startsWith("+20")) {
//       value = "+20" + value.replace(/\D/g, "").replace(/^20/, "");
//     }

//     setPhone(value);
//   };

//   const handleSendOtp = async () => {
//     const trimmedPhone = phone.trim();

//     if (!isValidEgyptPhone(trimmedPhone)) {
//       setError("من فضلك ادخل رقم صحيح بصيغة +20XXXXXXXXXX");
//       return;
//     }

//     try {
//       setLoading(true);
//       setError("");

//       const response = await fetch(API_SEND_OTP, {
//         method: "POST",
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify({
//           phone_number: trimmedPhone,
//         }),
//       });

//       const data = await response.json().catch(() => ({}));

//       if (!response.ok) {
//         throw new Error(data?.message || "فشل إرسال الكود");
//       }

//       sessionStorage.setItem("otp_phone", trimmedPhone);

//       navigate("/otp-verify", {
//         state: { phone: trimmedPhone },
//       });

//     } catch (err) {
//       setError(err.message || "حدث خطأ أثناء إرسال الكود");
//     } finally {
//       setLoading(false);
//     }
//   };

//   return (
//     <div className="otp-page">
//       <div className="otp-container2">
//         <p className="otp-title">كود التفعيل</p>
//         <p className="otp-subtitle">فعل الحساب للمتابعه</p>

        

//         <div className="otp-code">
//           <p className="otp-text">تفعيل عبر واتساب</p>
//           <p className="otp-text-2">
//             ادخل رقم التليفون وسيتم ارسال كود التفعيل على الواتساب
//           </p>
//         </div>
// <input
//           type="tel"
//           className="otp-phone-input"
//           placeholder="+20XXXXXXXXXX"
//           value={phone}
//           onChange={handleChange}
//           dir="rtl"
//         />
//         <div className="otp-btn">
//           <button
//             className="otp-button"
//             onClick={handleSendOtp}
//             disabled={loading}
//           >
//             {loading ? "جاري التنفيذ..." : "ارسال كود التفعيل"}
//           </button>
//         </div>

//         {error && <p className="otp-status">{error}</p>}
//       </div>
//     </div>
//   );
// }

import { useState } from "react";
import { useNavigate } from "react-router-dom";
import "../Css/Otp.css";

const API_SEND_OTP = "https://thoutha.page/api/otp/send";

export default function Otp() {
  const navigate = useNavigate();

  const [phone, setPhone] = useState("+20");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");

  // Normalize the phone number
  const normalizePhone = (value) => {
    let cleaned = value.replace(/[^\d+]/g, "");
    if (!cleaned.startsWith("+20")) {
      cleaned = "+20" + cleaned.replace(/\D/g, "").replace(/^20/, "");
    }
    return cleaned.trim();
  };

  // Validate Egyptian phone number
  const isValidEgyptPhone = (number) => /^\+20\d{10}$/.test(number);

  const handleChange = (e) => {
    setPhone(normalizePhone(e.target.value));
  };

  const handleSendOtp = async () => {
    const normalizedPhone = normalizePhone(phone);

    if (!isValidEgyptPhone(normalizedPhone)) {
      setError("من فضلك ادخل رقم صحيح بصيغة +20XXXXXXXXXX");
      return;
    }

    try {
      setLoading(true);
      setError("");

      console.log("Sending OTP to:", normalizedPhone);

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
      console.log("Send OTP response:", data);

      if (!response.ok) {
        throw new Error(data?.message || "فشل إرسال الكود");
      }

      // Save the phone to session storage for verification page
      sessionStorage.setItem("otp_phone", normalizedPhone);

      // Navigate to OTP verification page
      navigate("/otp-verify", {
        state: { phone: normalizedPhone },
      });

    } catch (err) {
      setError(err.message || "حدث خطأ أثناء إرسال الكود");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

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
// import { useRef, useState } from "react";
// import { useLocation, useNavigate } from "react-router-dom";
// import "../Css/Otp.css";

// const API_VERIFY_OTP = "https://thoutha.page/api/otp/verify";
// const API_SEND_OTP = "https://thoutha.page/api/otp/send";
// const OTP_LENGTH = 6;

// export default function OtpVerify() {
//   const navigate = useNavigate();
//   const location = useLocation();

//   const phone =
//     location.state?.phone || sessionStorage.getItem("otp_phone") || "";

//   const [otp, setOtp] = useState(Array(OTP_LENGTH).fill(""));
//   const [loading, setLoading] = useState(false);
//   const [message, setMessage] = useState(
//     phone ? "" : "ادخل رقم التليفون اولا من صفحة الارسال"
//   );

//   const inputsRef = useRef([]);

//   const handleChange = (index, value) => {
//     if (!/^\d?$/.test(value)) return;

//     const updated = [...otp];
//     updated[index] = value;
//     setOtp(updated);

//     if (value && index < OTP_LENGTH - 1) {
//       inputsRef.current[index + 1]?.focus();
//     }
//   };

//   const handleKeyDown = (index, e) => {
//     if (e.key === "Backspace" && !otp[index] && index > 0) {
//       inputsRef.current[index - 1]?.focus();
//     }
//   };

//   const handleVerify = async () => {
//     const code = otp.join("");

//     if (!phone) {
//       setMessage("ادخل رقم التليفون اولا من صفحة الارسال");
//       return;
//     }

//     if (code.length !== OTP_LENGTH) {
//       setMessage("من فضلك ادخل كود التفعيل كامل");
//       return;
//     }

//     try {
//       setLoading(true);
//       setMessage("");

//       const response = await fetch(API_VERIFY_OTP, {
//         method: "POST",
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify({
//           phone_number: phone,
//           otp: code,
//         }),
//       });

//       const data = await response.json().catch(() => ({}));

//       if (!response.ok) {
//         if (response.status === 404) {
//           throw new Error(
//             "لا يوجد كود تفعيل نشط لهذا الرقم. اضغط ارسل الرمز مره اخرى."
//           );
//         }
//         throw new Error(data?.message || "الكود غير صحيح");
//       }

//       navigate("/otp-done");

//     } catch (err) {
//       setMessage(err.message || "حدث خطأ أثناء التحقق من الكود");
//     } finally {
//       setLoading(false);
//     }
//   };

//   const handleResend = async () => {
//     if (!phone) {
//       setMessage("ادخل رقم التليفون اولا من صفحة الارسال");
//       return;
//     }

//     try {
//       setLoading(true);
//       setMessage("");

//       const response = await fetch(API_SEND_OTP, {
//         method: "POST",
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: JSON.stringify({
//           phone_number: phone,
//         }),
//       });

//       const data = await response.json().catch(() => ({}));

//       if (!response.ok) {
//         throw new Error(data?.message || "فشل إعادة إرسال الكود");
//       }

//       setMessage(data?.message || "تم إعادة إرسال الكود");

//     } catch (err) {
//       setMessage(err.message || "حدث خطأ أثناء إعادة الإرسال");
//     } finally {
//       setLoading(false);
//     }
//   };

//   return (
//     <div className="otp-page">
//       <div className="otp-container">
//         <p className="otp-title">كود التفعيل</p>
//         <p className="otp-subtitle">فعل الحساب للمتابعه</p>

//         <div className="otp-code">
//           <p className="otp-text">تم ارسال كود التفعيل</p>
//           <p className="otp-text-2">
//             لقد ارسلنا لك كود اكتبه لكي تفعل الحساب الخاص بك للمتابعه
//           </p>
//           {phone && <p className="otp-text-2">{phone}</p>}
//         </div>

//         <div className="otp-inputs" dir="ltr">
//           {otp.map((value, index) => (
//             <input
//               key={index}
//               ref={(el) => (inputsRef.current[index] = el)}
//               type="text"
//               maxLength="1"
//               value={value}
//               onChange={(e) => handleChange(index, e.target.value)}
//               onKeyDown={(e) => handleKeyDown(index, e)}
//               className="otp-input"
//               inputMode="numeric"
//               disabled={loading}
//             />
//           ))}
//         </div>

//         <div className="otp-btn">
//           <button
//             className="otp-button"
//             onClick={handleVerify}
//             disabled={loading}
//           >
//             {loading ? "جاري التحقق..." : "تحقق من الرمز"}
//           </button>
//         </div>

//         <div className="otp-resend">
//           <a
//             href="#"
//             onClick={(e) => {
//               e.preventDefault();
//               if (!loading) handleResend();
//             }}
//           >
//             ارسل الرمز مره اخرى
//           </a>
//         </div>

//         {message && <p className="otp-status">{message}</p>}
//       </div>
//     </div>
//   );
// }

import { useRef, useState } from "react";
import { useLocation, useNavigate } from "react-router-dom";
import "../Css/Otp.css";

const API_VERIFY_OTP = "https://thoutha.page/api/otp/verify";
const API_SEND_OTP = "https://thoutha.page/api/otp/send";
const OTP_LENGTH = 6;

export default function OtpVerify() {
  const navigate = useNavigate();
  const location = useLocation();

  // جلب الرقم من صفحة الإرسال أو من sessionStorage
  const storedPhone =
    location.state?.phone || sessionStorage.getItem("otp_phone") || "";

  const phone = storedPhone.trim();

  const [otp, setOtp] = useState(Array(OTP_LENGTH).fill(""));
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState(
    phone ? "" : "ادخل رقم التليفون اولا من صفحة الارسال"
  );

  const inputsRef = useRef([]);

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

      console.log("Verifying phone:", phone);
      console.log("Verifying OTP:", code);

      const response = await fetch(API_VERIFY_OTP, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          phone_number: phone,
          otp: code, // ✅ التعديل هنا: اسم الحقل أصبح otp
        }),
      });

      const data = await response.json().catch(() => ({}));
      console.log("Verify response:", data);

      if (!response.ok) {
        if (response.status === 404) {
          throw new Error(
            "لا يوجد كود تفعيل نشط لهذا الرقم. تأكد انك ارسلت الكود اولا."
          );
        }
        throw new Error(data?.message || "الكود غير صحيح");
      }

      sessionStorage.removeItem("otp_phone");
      navigate("/otp-done");

    } catch (err) {
      setMessage(err.message || "حدث خطأ أثناء التحقق من الكود");
    } finally {
      setLoading(false);
    }
  };

  const handleResend = async () => {
    if (!phone) return;

    try {
      setLoading(true);
      setMessage("");

      const response = await fetch(API_SEND_OTP, {
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

      setMessage("تم إعادة إرسال الكود");

    } catch (err) {
      setMessage(err.message || "حدث خطأ أثناء إعادة الإرسال");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="otp-page">
      <div className="otp-container">
        <p className="otp-title">كود التفعيل</p>
        <p className="otp-subtitle">فعل الحساب للمتابعه</p>

        <div className="otp-code">
          <p className="otp-text">تم ارسال كود التفعيل</p>
          <p className="otp-text-2">
            لقد ارسلنا لك كود اكتبه لكي تفعل الحساب الخاص بك
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
import { Link } from "react-router-dom";
import "../Css/Otp.css";
import { useState } from "react";

export default function Otp(){
    const [otp, setOtp] = useState(['', '', '', '']);

    const handleOtpChange = (index, value) => {
        if (value.length > 1) return;
        const newOtp = [...otp];
        newOtp[index] = value;
        setOtp(newOtp);
        
        if (value && index < 3) {
            document.getElementById(`otp-${index + 1}`).focus();
        }
    };

    const handleSubmit = () => {
        const otpCode = otp.join('');
        console.log('OTP Code:', otpCode);
    };

    return(
        <>
        <div className="otp-page">
            <div className="otp-container">
                <p className="otp-title">كود التفعيل</p>
                <p className="otp-subtitle">فعل الحساب للمتابعه</p>
                <div className="otp-code">
                    <p className="otp-text">تم ارسال كود التفعيل</p>
                    <p className="otp-text-2">لقد ارسلنا لك كود اكتبه لكي تفعل الحساب الخاص بك للمتابعه</p>
                </div>

                <div className="otp-inputs">
                    {[0, 1, 2, 3].map((index) => (
                        <input
                            key={index}
                            id={`otp-${index}`}
                            type="text"
                            maxLength="1"
                            value={otp[index]}
                            onChange={(e) => handleOtpChange(index, e.target.value)}
                            className="otp-input"
                            inputMode="numeric"
                        />
                    ))}
                </div>
                <Link to="/otp-done" className="otp-btn">
                    <button className="otp-button" onClick={handleSubmit}>تحقق من الرمز</button>
                </Link>
                <div className="otp-resend">
                    <a href="#">ارسل الرمز مره اخرى</a>
                </div>
            </div>
        </div>
        </>
    );
}
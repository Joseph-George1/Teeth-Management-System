import { Link } from "react-router-dom";
import "../Css/OtpDone.css";

export default function OtpDone(){
    return(
        <div className="done-page">
            <div className="done-container">
                <div className="done-icon" aria-hidden>
                    <svg width="106" height="106" viewBox="0 0 96 96" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="48" cy="48" r="44" stroke="rgba(37, 180, 229, 1)" strokeWidth="3" fill="rgba(216, 243, 252, 1)" />
                        <path d="M36 52 L46 62 L66 42"
                            stroke="rgba(37, 180, 229, 1)"
                            strokeWidth="4"
                            strokeLinecap="round"
                            strokeLinejoin="round"
                            vectorEffect="non-scaling-stroke"
                            transform="translate(51 52) scale(1.092691167195638 1.3022193908691406) translate(-51 -52)"
                        />
                    </svg>
                </div>

                <h2 className="done-title">تم التفعيل بنجاح</h2>
                <p className="done-subtitle">تهانينا! تم التحقق من الحساب اضغط للمتابعة</p>

                <Link to="/login"><button className="done-button">تسجيل الدخول</button></Link>
            </div>
        </div>
    );
}
import { Link } from 'react-router-dom';
import '../Css/UnauthorizedPage.css';

export default function UnauthorizedPage(){
    return(
        <div className="unauthorized-container">
            <div className="unauthorized-content">
                <div className="unauthorized-header">
                    <h1 className="unauthorized-code">401</h1>
                    <h2 className="unauthorized-title">غير مصرح بالوصول</h2>
                    <p className="unauthorized-description">عذراً، يجب عليك تسجيل الدخول أولاً للوصول إلى هذه الصفحة.</p>
                </div>
                
                <div className="unauthorized-illustration">
                    <svg width="200" height="200" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="100" cy="100" r="90" stroke="#F39C12" strokeWidth="2" opacity="0.1"/>
                        <circle cx="100" cy="80" r="25" stroke="#F39C12" strokeWidth="2.5" fill="none"/>
                        <path d="M75 120 Q75 130 85 135 L115 135 Q125 130 125 120" stroke="#F39C12" strokeWidth="2.5" fill="none" strokeLinecap="round"/>
                        <path d="M85 110 Q85 105 90 105" stroke="#F39C12" strokeWidth="2" fill="none" strokeLinecap="round" opacity="0.6"/>
                        <path d="M110 110 Q110 105 115 105" stroke="#F39C12" strokeWidth="2" fill="none" strokeLinecap="round" opacity="0.6"/>
                        <path d="M100 125 L100 140 M85 132 L92 140 M115 132 L108 140" stroke="#F39C12" strokeWidth="2" strokeLinecap="round" opacity="0.4"/>
                    </svg>
                </div>

                <div className="unauthorized-actions">
                    <Link to="/login" className="unauthorized-btn btn-primary">
                        تسجيل الدخول
                    </Link>
                    <Link to="/register" className="unauthorized-btn btn-secondary">
                        إنشاء حساب جديد
                    </Link>
                </div>
            </div>
        </div>
    )
}

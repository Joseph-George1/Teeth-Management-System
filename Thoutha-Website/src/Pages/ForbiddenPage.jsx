import { Link } from 'react-router-dom';
import '../Css/ForbiddenPage.css';

export default function ForbiddenPage(){
    return(
        <div className="forbidden-container">
            <div className="forbidden-content">
                <div className="forbidden-header">
                    <h1 className="forbidden-code">403</h1>
                    <h2 className="forbidden-title">تم منع الوصول</h2>
                    <p className="forbidden-description">عذراً، ليس لديك صلاحيات كافية للوصول إلى هذه الصفحة.</p>
                </div>
                
                <div className="forbidden-illustration">
                    <svg width="200" height="200" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="100" cy="100" r="90" stroke="#E74C3C" strokeWidth="2" opacity="0.1"/>
                        <circle cx="100" cy="100" r="70" stroke="#E74C3C" strokeWidth="2" opacity="0.15"/>
                        <path d="M100 60 L100 140 M60 100 L140 100" stroke="#E74C3C" strokeWidth="3" strokeLinecap="round"/>
                        <circle cx="70" cy="70" r="8" fill="#E74C3C" opacity="0.3"/>
                        <circle cx="130" cy="130" r="6" fill="#E74C3C" opacity="0.2"/>
                        <path d="M75 80 L85 90 M85 80 L75 90" stroke="#E74C3C" strokeWidth="2" strokeLinecap="round" opacity="0.4"/>
                    </svg>
                </div>

                <div className="forbidden-actions">
                    <Link to="/" className="forbidden-btn btn-primary">
                        العودة للرئيسية
                    </Link>
                    <Link to="/login" className="forbidden-btn btn-secondary">
                        تسجيل الدخول
                    </Link>
                </div>
            </div>
        </div>
    )
}

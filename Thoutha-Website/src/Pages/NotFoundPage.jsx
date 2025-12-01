import { Link } from 'react-router-dom';
import '../Css/NotFoundPage.css';

export default function NotFoundPage(){
    return(
        <div className="not-found-container">
            <div className="not-found-content">
                <div className="not-found-header">
                    <h1 className="not-found-code">404</h1>
                    <h2 className="not-found-title">الصفحة غير موجودة</h2>
                    <p className="not-found-description">عذراً، الصفحة التي تبحث عنها غير موجودة أو تم حذفها.</p>
                </div>
                
                <div className="not-found-illustration">
                    <svg width="200" height="200" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <circle cx="100" cy="100" r="90" stroke="#1D61E7" strokeWidth="2" opacity="0.1"/>
                        <path d="M80 80 L120 120 M120 80 L80 120" stroke="#1D61E7" strokeWidth="3" strokeLinecap="round"/>
                        <circle cx="60" cy="60" r="8" fill="#1D61E7" opacity="0.3"/>
                        <circle cx="140" cy="140" r="6" fill="#1D61E7" opacity="0.2"/>
                    </svg>
                </div>

                <div className="not-found-actions">
                    <Link to="/" className="not-found-btn btn-primary">
                        العودة للرئيسية
                    </Link>
                    <Link to="/login" className="not-found-btn btn-secondary">
                        تسجيل الدخول
                    </Link>
                </div>
            </div>
        </div>
    )
}
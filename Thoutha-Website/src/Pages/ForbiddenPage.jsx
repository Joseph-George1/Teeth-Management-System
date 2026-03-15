import { Link } from "react-router-dom";
import "../Css/ForbiddenPage.css";

export default function ForbiddenPage() {
  return (
    <div className="forbidden-container">
      <div className="forbidden-card">
        <p className="forbidden-status">403</p>
        <h1 className="forbidden-title">الوصول مرفوض</h1>
        <p className="forbidden-subtitle"> السيرفر رفض الطلب . (Forbidden)</p>

        <div className="forbidden-meme" aria-label="Tech meme">
          <p className="meme-line">Me: " بطل لعب يا حبيبي"</p>
        </div>

        <div className="forbidden-actions">
          <Link to="/" className="forbidden-btn forbidden-btn-primary">
            العودة للرئيسية
          </Link>
          <Link to="/login" className="forbidden-btn forbidden-btn-secondary">
            تسجيل الدخول
          </Link>
        </div>
      </div>
    </div>
  );
}

import { Link } from "react-router-dom";
import "../Css/ForbiddenPage.css";

export default function ForbiddenPage() {
  return (
    <div className="forbidden-container">
      <div className="forbidden-card">
        <p className="forbidden-status">403</p>
        <h1 className="forbidden-title">الوصول مرفوض</h1>
        <p className="forbidden-subtitle"> السيرفر رفض الطلب، هذه صفحة مخصصة بطابع تقني بطل لعب يا حبيبي. (Forbidden)</p>

        <div className="forbidden-meme" aria-label="Tech meme">
          <p className="meme-line">Me: "I have the token 😎"</p>
          <p className="meme-line">Server: "403 Forbidden 🤖"</p>
          <p className="meme-line">Me: "Works on my machine... not on yours 😅"</p>
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

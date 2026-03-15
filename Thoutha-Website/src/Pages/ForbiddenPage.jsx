import { useNavigate } from "react-router-dom";
import "../Css/ForbiddenPage.css";
import { hideForbiddenPage } from "../services/forbiddenState";

export default function ForbiddenPage() {
  const navigate = useNavigate();

  const handleGoHome = () => {
    hideForbiddenPage();
    navigate("/");
  };

  const handleGoToLogin = () => {
    hideForbiddenPage();
    navigate("/login");
  };

  return (
    <div className="forbidden-container">
      <div className="forbidden-card">
        <p className="forbidden-status">403</p>
        <h1 className="forbidden-title">الوصول مرفوض</h1>
        <p className="forbidden-subtitle">السيرفر رفض الطلب (Forbidden)</p>

        <div className="forbidden-meme" aria-label="Tech meme">
          <p className="meme-line">Me: "I have the token 😎"</p>
          <p className="meme-line">Server: "403 Forbidden 🤖"</p>
          <p className="meme-line">Me: "Works on my machine... not on yours 😅"</p>
        </div>

        <div className="forbidden-actions">
          <button type="button" className="forbidden-btn forbidden-btn-primary" onClick={handleGoHome}>
            العودة للرئيسية
          </button>
          <button type="button" className="forbidden-btn forbidden-btn-secondary" onClick={handleGoToLogin}>
            تسجيل الدخول
          </button>
        </div>
      </div>
    </div>
  );
}

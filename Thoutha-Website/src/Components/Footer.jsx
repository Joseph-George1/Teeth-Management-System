import { Link, NavLink } from "react-router-dom";
import "../Css/footer.css";

export default function Footer() {
  return (
    <footer className="footer-container">
      <div className="footer-links">
        <NavLink to="/" className={({ isActive }) => (isActive ? "footer-active-link" : "")}>الصفحه الرئيسية</NavLink>
        <NavLink to="/profile" className={({ isActive }) => (isActive ? "footer-active-link" : "")}>الملف الشخصي</NavLink>
        <NavLink to="/chatbot" className={({ isActive }) => (isActive ? "footer-active-link" : "")}>الطبيب الذكي</NavLink>
        <NavLink to="/terms&conditions" className={({ isActive }) => (isActive ? "footer-active-link" : "")}>الشروط والاستخدام</NavLink>
        <NavLink to="/login" className={({ isActive }) => (isActive ? "footer-active-link" : "")}>تسجيل دخول / انشاء حساب</NavLink>
      </div>
      <div className="footer-copy">
        © 2025 ثوثة. جميع الحقوق محفوظة.
      </div>
    </footer>
  );
}

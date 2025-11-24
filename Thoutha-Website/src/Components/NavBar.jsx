import { Link, NavLink } from "react-router-dom";
import "../Css/NavBar.css";
import { useState } from "react";
import { Menu, X, Home, User, Bot, FileText, LogIn } from "lucide-react";

export default function NavBar() {
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      <nav className="navbar-container">
        <div className="nav-left">
          <Link to="/" className="logo-box">
            <img src="./ثوثة.png" alt="logo" width={55} />
            <span className="web-name">ثوثة</span>
          </Link>
        </div>

        {/* Desktop Menu */}
        <ul className="nav-links">
          <li>
            <NavLink to="/" className={({ isActive }) => (isActive ? "active-link" : "")}>الصفحه الرئيسية</NavLink>
          </li>
          <li>
            <NavLink to="/profile" className={({ isActive }) => (isActive ? "active-link" : "")}>الملف الشخصي</NavLink>
          </li>
          <li>
            <NavLink to="/chatbot" className={({ isActive }) => (isActive ? "active-link" : "")}>الطبيب الذكي</NavLink>
          </li>
          <li>
            <NavLink to="/terms&conditions" className={({ isActive }) => (isActive ? "active-link" : "")}>الشروط والاستخدام</NavLink>
          </li>
        </ul>

        <Link to="/login" className="login-btn">تسجيل دخول / انشاء حساب</Link>

        {/* Mobile Icon */}
        <button className="menu-icon" onClick={() => setIsOpen(!isOpen)}>
          {isOpen ? <X size={28} className="icon-animate"/> : <Menu size={28} className="icon-animate"/>}
        </button>
      </nav>

      {/* Mobile Menu */}
      {isOpen && (
        <div className="mobile-menu mobile-animate">
          <NavLink to="/" onClick={() => setIsOpen(false)} className={({ isActive }) => (isActive ? "active-link" : "")}><Home size={20}/> الصفحه الرئيسية</NavLink>
          <NavLink to="/profile" onClick={() => setIsOpen(false)} className={({ isActive }) => (isActive ? "active-link" : "")}><User size={20}/> الملف الشخصي</NavLink>
          <NavLink to="/chatbot" onClick={() => setIsOpen(false)} className={({ isActive }) => (isActive ? "active-link" : "")}><Bot size={20}/> الطبيب الذكي</NavLink>
          <NavLink to="/terms&conditions" onClick={() => setIsOpen(false)} className={({ isActive }) => (isActive ? "active-link" : "")}><FileText size={20}/> الشروط والاستخدام</NavLink>
          <NavLink to="/login" onClick={() => setIsOpen(false)} className="mobile-login-btn"><LogIn size={20}/> تسجيل دخول / انشاء حساب</NavLink>
        </div>
      )}
    </>
  );
}
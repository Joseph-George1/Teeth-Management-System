
import { useContext, useState } from "react";
import { Link, NavLink } from "react-router-dom";
import { Menu, X, Home, User, Bot, FileText, LogIn, LogOut, Users, Calendar } from "lucide-react";
import "../Css/NavBar.css";
import { AuthContext } from "../services/AuthContext";

export default function NavBar() {
  const { isLoggedIn, user, logout } = useContext(AuthContext);
  const [isOpen, setIsOpen] = useState(false);

  return (
    <>
      {/* Navbar  */}
      <nav className="navbar-container">
        <div className="nav-left">
          <Link to="/" className="logo-box">
            <img src="./ثوثة.png" alt="logo" width={80} />
            <span className="web-name">ثوثة</span>
          </Link>
        </div>

        {/* Overlay  */}
        {isOpen && <div className="overlay" onClick={() => setIsOpen(false)}></div>}

        {/* button */}
        <button className="menu-icon" onClick={() => setIsOpen(!isOpen)}>
          {isOpen ? <X size={28}/> : <Menu size={28} className="icon-animate"/>}
        </button>
      </nav>

      {/* Mobile Menu */}
      {isOpen && (
        <div className="mobile-menu mobile-animate">
          <div className="mobile-menu2">
            {isLoggedIn ? (
              <>
              <div className="menu-icon2">
                <button className="menu-icon3" onClick={() => setIsOpen(!isOpen)}> <span>القائمة</span>
                {isOpen ? <X size={28}/> : <Menu size={28} className="icon-animate"/>}
                </button>                
                <div className="user-info-circle">
                  <svg width="48" height="48" viewBox="0 0 48 48" fill="none" xmlns="http://www.w3.org/2000/svg">
                  <path d="M0 24C0 10.7452 10.7452 0 24 0C37.2548 0 48 10.7452 48 24C48 37.2548 37.2548 48 24 48C10.7452 48 0 37.2548 0 24Z" fill="white"/>
                  <path d="M31 33V31C31 29.9391 30.5786 28.9217 29.8284 28.1716C29.0783 27.4214 28.0609 27 27 27H21C19.9391 27 18.9217 27.4214 18.1716 28.1716C17.4214 28.9217 17 29.9391 17 31V33" stroke="#84E5F3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  <path d="M24 23C26.2091 23 28 21.2091 28 19C28 16.7909 26.2091 15 24 15C21.7909 15 20 16.7909 20 19C20 21.2091 21.7909 23 24 23Z" stroke="#84E5F3" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                  </svg>
                  <div className="user-info-email">
                    <span className="user-name">{user.first_name} {user.last_name}</span>
                    <p className="user-email">{user.faculty}</p>
                  </div>
                </div>
              </div>

                {/* user-link */}
                            {/* الرابط الرئيسي */}
                  <NavLink 
                    to="/doctor-home" 
                    onClick={() => setIsOpen(false)}
                    className={({ isActive }) => isActive ? "active-link" : "notactive-link"}
                  >
                    <Home size={20} className="icon-color"/> الصفحة الرئيسية
                  </NavLink>
                <NavLink to="/patients" onClick={() => setIsOpen(false)} className={({isActive}) => isActive ? "active-link" : "notactivelink"}>
                  <Users size={20} className="icon-color"/> المرضى
                </NavLink>

                <NavLink to="/doctor-bookings" onClick={() => setIsOpen(false)} className={({isActive}) => isActive ? "active-link" : "notactivelink"}>
                  <Calendar size={20} className="icon-color"/> سجل الحجوزات
                </NavLink>

                <NavLink to="/profile" onClick={() => setIsOpen(false)} className={({isActive}) => isActive ? "active-link" : "notactivelink"}>
                  <User size={20} className="icon-color"/> الملف الشخصي
                </NavLink>

                <NavLink to="/terms&conditions" onClick={() => setIsOpen(false)} className={({isActive}) => isActive ? "active-link" : "notactivelink"}>
                  <FileText size={20} className="icon-color"/> الشروط والاستخدام
                </NavLink>
                <Link to="/">  
                 <button 
                  onClick={() => { logout(); setIsOpen(false); }}
                  className="mobile-login-btn cursor "
                >
                  <LogOut size={20} className="icon-animate "/> تسجيل خروج
                </button></Link>
             
              </>
            ) : (
              <>
                <div className="menu-icon1">
                  <button className="menu-icon3" onClick={() => setIsOpen(!isOpen)}> <span>القائمة</span>
                    {isOpen ? <X size={28}/> : <Menu size={28} className="icon-animate"/>}
                  </button>
                </div>
                {/* patient link */}
                            {/* الرابط الرئيسي */}
                  <NavLink 
                    to="/" 
                    onClick={() => setIsOpen(false)}
                    className={({ isActive }) => isActive ? "active-link" : "notactive-link"}
                  >
                    <Home size={20} className="icon-color"/> الصفحة الرئيسية
                  </NavLink>
                <NavLink to="/chatbot" onClick={() => setIsOpen(false)} className={({isActive}) => isActive ? "active-link" : "notactivelink"}>
                  <Bot size={20} className="icon-color"/> الطبيب الذكي
                </NavLink>

                <NavLink to="/terms&conditions" onClick={() => setIsOpen(false)} className={({isActive}) => isActive ? "active-link" : "notactivelink"}>
                  <FileText size={20} className="icon-color"/> الشروط والاستخدام
                </NavLink>

                <NavLink to="/login" onClick={() => setIsOpen(false)} className={({isActive}) => isActive ? "active-link" : "notactivelink"}>
                  <LogIn size={20} className="icon-color"/> تسجيل دخول / إنشاء حساب
                </NavLink>
              </>
            )}
          </div>
        </div>
      )}
    </>
  );
}



import { Link, Outlet } from "react-router-dom";
import '../Css/NavBar.css';
export default function NavBar(){
  return(
    <>
    <nav>
      <div className="category">
      <div className="navbar">
        <Link to="/"><img src="./ثوثة.png" alt="logo" width={60} /></Link>
        <span className="webName">ثوثة</span>
      </div>
      <ul>
          <li><Link to="/">الصفحه الرئيسية</Link> </li>
          <li><Link to="/profile">الملف الشخصي</Link></li>
          <li><Link to="/chatbot">الطبيب الذكي</Link></li>
          <li><Link to="/terms&conditions">الشروط والاستخدام</Link></li>
      </ul>
      </div>
      <Link to="/login"><button className="buttonNav">تسجيل دخول / انشاء حساب</button></Link>
    </nav>
    <Outlet/>
    </>
  )
}
import '../Css/Home.css';
import { useRef } from "react";
import { Helmet } from "react-helmet-async";
import { Link} from 'react-router-dom';
// import DoctorsList from './DoctorsList';
export default function Home(){
  const aboutRef = useRef(null);
  return(
    <>
     <Helmet>
        <meta
          name="description"
          content="منصة ثوثة بتربط مرضى الأسنان بطلاب كليات طب الأسنان لعلاج الحالات مجانًا تحت الإشراف المباشر لأعضاء هيئة التدريس بالكلية، مع فرصة تعليمية عملية للطلاب"
        />
      </Helmet>
    {/* hero section */}
    <div className="hero-section">
      <div className="hero-container">
        <div className="hero-title-flex">
          <p className="hero-title-1">احجز وسجل</p>
          <p className="hero-title-2">مع افضل الاطباء فى نطاقك</p>
          <p onClick={() => aboutRef.current.scrollIntoView({ behavior: "smooth" })} className="hero-button"><span>احجز الان</span></p> 
        </div>
        <div className="hero-img">
          <img src="./hero-section.png" alt="img" />
        </div>
      </div> 
    </div>
      {/* category section */}
      <div className="category-section">
        <div className="category-container">
          <p className="category-title" ref={aboutRef}>الخدمات المتوفره</p>
          <div className="category-icons">
            <div className="category-icon">
            <div className="category-icon-1">
              <Link to="/teeth-whitening">
              <div className="circle-icon">
                <img src="./تبيض اسنان.svg" alt="" />
              <p className="icon-1-title">تبيض اسنان</p>
              </div>
              </Link>
            </div>
            <div className="category-icon-1"> 
              <Link to="/crowns&bridges">
              <div className="circle-icon">
                <img src="./تركيبات اسنان.svg" alt="" />                   
              <p className="icon-1-title">تركيبات اسنان</p> 
              </div>
              </Link>
            </div>
            </div>
            <div className="category-icon">
              <div className="category-icon-1">
                 <Link to="/braces">
              <div className="circle-icon">
                <img src="./تقويم اسنان.svg" alt="" />
              <p className="icon-1-title">تقويم اسنان</p>
              </div>
              </Link>
            </div>           
            <div className="category-icon-1"> 
              <Link to="/dental-filling">
              <div className="circle-icon">
                <img src="./حشو اسنان.svg" alt="" />
              <p className="icon-1-title">حشو اسنان</p>
              </div>
              </Link>
            </div>
            </div>
            <div className="category-icon">             
              <div className="category-icon-1"> 
                <Link to="/tooth-extraction">
                <div className="circle-icon">
                <img src="./خلع اسنان.svg" alt="" />
              <p className="icon-1-title">خلع اسنان</p>
              </div>
              </Link>
            </div>          
            <div className="category-icon-1"> 
              <Link to="/dental-implant">
              <div className="circle-icon">
                <img src="./زراعه اسنان.svg" alt="" />
              <p className="icon-1-title">زراعه اسنان</p>
              </div>
              </Link>
            </div>
            </div>          
            <div className="category-icon-1 center"> 
              <Link to="/dental-checkup">
              <div className="circle-icon">
                <img src="./فحص شامل.svg" alt="" />
              <p className="icon-1-title">فحص شامل</p> 
              </div>
              </Link>
            </div>
          </div>
        </div>
      </div>  
    </>
  )
}
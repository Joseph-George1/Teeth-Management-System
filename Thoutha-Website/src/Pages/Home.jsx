import '../Css/Home.css';
import DoctorsList from './DoctorsList';
export default function Home(){
  return(
    <>
    {/* hero section */}
    <div className="hero-section">
      <div className="hero-container">
        <div className="hero-title-flex">
          <p className="hero-title-1">احجز وسجل</p>
          <p className="hero-title-2">مع افضل الاطباء فى نطاقك</p>
          <p className="hero-button"><span>احجز الان</span></p> 
        </div>
        <div className="hero-img">
          <img src="./hero-section.png" alt="img" />
        </div>
      </div> 
    </div>
      {/* category section */}
      <div className="category-section">
        <div className="category-container">
          <p className="category-title">الخدمات المتوفره</p>
          <div className="category-icon">
            <div className="category-icon-1">
              <div className="circle-icon">
                <img src="./تبيض اسنان.svg" alt="" />
              </div>
              <p className="icon-1-title">تبيض اسنان</p>
            </div>
            <div className="category-icon-1">
              <div className="circle-icon">
                <img src="./تركيبات اسنان.svg" alt="" />
              </div>              
              <p className="icon-1-title">تركيبات اسنان</p>
            </div>
            <div className="category-icon-1">
              <div className="circle-icon">
                <img src="./تقويم اسنان.svg" alt="" />
              </div>              
              <p className="icon-1-title">تقويم اسنان</p>
            </div>
            <div className="category-icon-1">
              <div className="circle-icon">
                <img src="./حشو اسنان.svg" alt="" />
              </div>              
              <p className="icon-1-title">حشو اسنان</p>
            </div>
            <div className="category-icon-1">
                <div className="circle-icon">
                <img src="./خلع اسنان.svg" alt="" />
              </div>              
              <p className="icon-1-title">خلع اسنان</p>
            </div>
            <div className="category-icon-1">
              <div className="circle-icon">
                <img src="./زراعه اسنان.svg" alt="" />
              </div>              
              <p className="icon-1-title">زراعه اسنان</p>
            </div>
            <div className="category-icon-1">
              <div className="circle-icon">
                <img src="./فحص شامل.svg" alt="" />
              </div>
              <p className="icon-1-title">فحص شامل</p>
            </div>
          </div>
        </div>
      </div>
      <DoctorsList/>

    </>
  )
}
import "../Css/Category.css";
import DoctorsList from "./DoctorsList";
export default function TeethWhitening(){
    return(
    <>
    <div className="top-page">
        <div className="circle-img">
            <img src="./تبيض اسنان.svg" alt="img" /> 
        </div>
        <div className="page-name">
            <p>تبييض الأسنان</p>
        </div>
    </div>
    <DoctorsList categoryName="تبييض الأسنان" />
    </>
    )
}
import { AuthContext } from "../services/AuthContext";
import { useContext} from "react";
import "../Css/DoctorHome.css";

export default function DoctorHome(){
    const {  user } = useContext(AuthContext);
    return(
        <>
        
        <div className="doctorhome">
            <div className="doctor-title">
                <p className="doctor-name2">مرحباً, د. {user?.first_name} {user?.last_name}</p>
                <p className="doctor-subtitle">إليك نظرة عامة على حجوزاتك وأدائك</p>
            </div>
            <div className="doctor-work">
                <div className="doctor-last-patient">
                    <p className="last-patient-title">اخر المرضى</p>
                    <div className="last-patient-blog">
                        <div className="last-patient-details bottom ">
                            <div className="last-patient-img-name">
                                <div className="patient-img-circle">
                                    <img src="./doctor.jpg" alt="img" /> 
                                </div>
                                <p className="last-patient-name">سارة عبدالله حسن</p>
                            </div>
                            <p className="date">منذ يومين</p> 
                        </div>
                        <div className="last-patient-details bottom top">
                            <div className="last-patient-img-name">
                                <div className="patient-img-circle">
                                    <img src="./doctor.jpg" alt="img" /> 
                                </div>
                                <p className="last-patient-name">محمد حسن علي</p>
                            </div>
                            <p className="date">منذ 5 أيام</p> 
                        </div>
                        <div className="last-patient-details bottom top">
                            <div className="last-patient-img-name">
                                <div className="patient-img-circle">
                                    <img src="./doctor.jpg" alt="img" /> 
                                </div>
                                <p className="last-patient-name">منى جمال فهمي</p>
                            </div>
                            <p className="date">منذ أسبوع</p> 
                        </div>
                        <div className="last-patient-details top">
                            <div className="last-patient-img-name">
                                <div className="patient-img-circle">
                                    <img src="./doctor.jpg" alt="img" /> 
                                </div>
                                <p className="last-patient-name">خالد عمر محمود</p>
                            </div>
                            <p className="date">منذ أسبوعين</p> 
                        </div>
                    </div>
                </div>
            </div>
        </div>
        </>
    )
}
import { useContext } from "react";
import { AuthContext } from "../services/AuthContext";
import "../Css/DoctorHome.css";

export default function DoctorHome() {
  const { user } = useContext(AuthContext);

  return (
    <div className="doctorhome">
      {/* عنوان الطبيب */}
      <div className="doctor-title">
        <p className="doctor-name2">
          مرحباً, د. {user?.firstName || user?.first_name} {user?.lastName || user?.last_name}
        </p>
        <p className="doctor-subtitle">
          إليك نظرة عامة على حجوزاتك وأدائك
        </p>
      </div>

      {/* قسم العمل */}
      <div className="doctor-work">
        {/* اخر المرضى */}
        <div className="doctor-last-patient">
          <p className="last-patient-title">اخر المرضى</p>
          <div className="last-patient-blog">

            {/* مريض 1 */}
            <div className="last-patient-details bottom">
              <div className="last-patient-img-name">
                <div className="patient-img-circle">
                  <img src="./doctor.jpg" alt="img" /> 
                </div>
                <p className="last-patient-name">سارة عبدالله حسن</p>
              </div>
              <p className="date">منذ يومين</p> 
            </div>

            {/* مريض 2 */}
            <div className="last-patient-details bottom top">
              <div className="last-patient-img-name">
                <div className="patient-img-circle">
                  <img src="./doctor.jpg" alt="img" /> 
                </div>
                <p className="last-patient-name">محمد حسن علي</p>
              </div>
              <p className="date">منذ 5 أيام</p> 
            </div>

            {/* مريض 3 */}
            <div className="last-patient-details bottom top">
              <div className="last-patient-img-name">
                <div className="patient-img-circle">
                  <img src="./doctor.jpg" alt="img" /> 
                </div>
                <p className="last-patient-name">منى جمال فهمي</p>
              </div>
              <p className="date">منذ أسبوع</p> 
            </div>

            {/* مريض 4 */}
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
  );
}
import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import DoctorsList from "./DoctorsList";
import AddRequest from "./AddRequest";
import { AuthContext } from "../services/AuthContext";

export default function DentalImplant() {
  const [openModal, setOpenModal] = useState(false);
  const { isLoggedIn } = useContext(AuthContext);
  return (
    <>
      <div className="top-page">
        <div className="circle-img">
          <img src="./زراعه اسنان.svg" alt="img" />
        </div>
        <div className="page-name">
          <p>زراعة الأسنان</p>
        </div>
      </div>
      {isLoggedIn && (
        <button className="open-request-btn" onClick={() => setOpenModal(true)}>
          + اطلب جديد
        </button>
      )}
      <DoctorsList categoryName="زراعة الأسنان" />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        specialization="زراعة الأسنان"
      />
    </>
  );
}
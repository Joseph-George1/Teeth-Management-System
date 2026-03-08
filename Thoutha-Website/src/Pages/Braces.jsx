import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import DoctorsList from "./DoctorsList";
import AddRequest from "./AddRequest";
import { AuthContext } from "../services/AuthContext";

export default function Braces() {
  const [openModal, setOpenModal] = useState(false);
  const { isLoggedIn } = useContext(AuthContext);
  return (
    <>
      <div className="top-page">
        <div className="circle-img">
          <img src="./تقويم اسنان.svg" alt="img" />
        </div>
        <div className="page-name">
          <p>تقويم الأسنان</p>
        </div>
      </div>
      {isLoggedIn && (
        <button className="open-request-btn" onClick={() => setOpenModal(true)}>
          + اطلب جديد
        </button>
      )}
      <DoctorsList categoryName="تقويم الأسنان" />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        specialization="تقويم الأسنان"
      />
    </>
  );
}
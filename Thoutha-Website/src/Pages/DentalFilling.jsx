import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import DoctorsList from "./DoctorsList";
import AddRequest from "./AddRequest";
import RequestsList from "./RequestsList";
import { AuthContext } from "../services/AuthContext";

export default function DentalFilling() {
  const [openModal, setOpenModal] = useState(false);
  const [newRequest, setNewRequest] = useState(null);
  const { isLoggedIn } = useContext(AuthContext);
  return (
    <>
      <div className="top-page">
        <div className="circle-img">
          <img src="./حشو اسنان.svg" alt="img" />
        </div>
        <div className="page-name">
          <p>حشوات الأسنان</p>
        </div>
      </div>
      {isLoggedIn && (
        <button className="open-request-btn" onClick={() => setOpenModal(true)}>
          + اطلب جديد
        </button>
      )}
      <RequestsList categoryName="حشوات الأسنان" newRequest={newRequest} />
      <DoctorsList categoryName="حشوات الأسنان" />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        onSuccess={(req) => setNewRequest(req)}
        specialization="حشوات الأسنان"
      />
    </>
  );
}
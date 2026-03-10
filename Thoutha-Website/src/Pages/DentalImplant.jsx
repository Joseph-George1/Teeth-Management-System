import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import DoctorsList from "./DoctorsList";
import AddRequest from "./AddRequest";
import RequestsList from "./RequestsList";
import { AuthContext } from "../services/AuthContext";

export default function DentalImplant() {
  const [openModal, setOpenModal] = useState(false);
  const [newRequest, setNewRequest] = useState(null);
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
      <RequestsList categoryName="زراعة الأسنان" newRequest={newRequest} />
      <DoctorsList categoryName="زراعة الأسنان" />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        onSuccess={(req) => setNewRequest(req)}
        specialization="زراعة الأسنان"
      />
    </>
  );
}
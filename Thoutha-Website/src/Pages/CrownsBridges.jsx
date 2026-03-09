import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import DoctorsList from "./DoctorsList";
import AddRequest from "./AddRequest";
import RequestsList from "./RequestsList";
import { AuthContext } from "../services/AuthContext";

export default function CrownsBridges() {
  const [openModal, setOpenModal] = useState(false);
  const [newRequest, setNewRequest] = useState(null);
  const { isLoggedIn } = useContext(AuthContext);
  return (
    <>
      <div className="top-page">
        <div className="circle-img">
          <img src="./تركيبات اسنان.svg" alt="img" />
        </div>
        <div className="page-name">
          <p>تيجان الأسنان / التركيبات</p>
        </div>
      </div>
      {isLoggedIn && (
        <button className="open-request-btn" onClick={() => setOpenModal(true)}>
          + اطلب جديد
        </button>
      )}
      <RequestsList categoryName="تيجان الأسنان / التركيبات" newRequest={newRequest} />
      <DoctorsList categoryName="تيجان الأسنان / التركيبات" />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        onSuccess={(req) => setNewRequest(req)}
        specialization="تيجان الأسنان / التركيبات"
      />
    </>
  );
}
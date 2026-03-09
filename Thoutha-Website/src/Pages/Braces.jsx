import { useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import DoctorsList from "./DoctorsList";
import AddRequest from "./AddRequest";
import RequestsList from "./RequestsList";
import { AuthContext } from "../services/AuthContext";

export default function Braces() {
  const [openModal, setOpenModal] = useState(false);
  const [newRequest, setNewRequest] = useState(null);
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
      <RequestsList categoryName="تقويم الأسنان" newRequest={newRequest} />
      <DoctorsList categoryName="تقويم الأسنان" />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        onSuccess={(req) => setNewRequest(req)}
        specialization="تقويم الأسنان"
      />
    </>
  );
}
import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import AddRequest from "./AddRequest";
import RequestsList from "./RequestsList";
import { AuthContext } from "../services/AuthContext";

export default function RemovableProsthetics() {
  const [openModal, setOpenModal] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);
  const { isLoggedIn } = useContext(AuthContext);
  return (
    <>
    <div className="my-requests-container">
      <div className="top-page">
        <div className="circle-img">
          <img src="./تركيبات اسنان.svg" alt="img" />
        </div>
        <div className="page-name">
          <p>تركيبات متحركة</p>
        </div>
      </div>
      {isLoggedIn && (
        <button className="open-request-btn" onClick={() => setOpenModal(true)}>
          + اطلب جديد
        </button>
      )}
      <RequestsList categoryName="تركيبات متحركة" categoryId={5} refreshKey={refreshKey} />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        onSuccess={() => setRefreshKey(k => k + 1)}
        specialization="تركيبات متحركة"
        categoryId={5}
      />
    </div>
    </>
  );
}

import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import AddRequest from "./AddRequest";
import RequestsList from "./RequestsList";
import { AuthContext } from "../services/AuthContext";

export default function DentalFilling() {
  const [openModal, setOpenModal] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);
  const { isLoggedIn } = useContext(AuthContext);
  return (
    <>
    <div className="my-requests-container">
      <div className="top-page">
        <div className="circle-img">
          <img src="./حشو اسنان.svg" alt="img" />
        </div>
        <div className="page-name">
          <p>حشو تجميلي</p>
        </div>
      </div>
      {isLoggedIn && (
        <button className="open-request-btn" onClick={() => setOpenModal(true)}>
          + اطلب جديد
        </button>
      )}
      <RequestsList categoryName="حشو تجميلي" categoryId={1} refreshKey={refreshKey} />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        onSuccess={() => setRefreshKey(k => k + 1)}
        specialization="حشو تجميلي"
        categoryId={1}
      />
    </div>
    </>
  );
}
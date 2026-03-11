import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import AddRequest from "./AddRequest";
import RequestsList from "./RequestsList";
import { AuthContext } from "../services/AuthContext";

export default function TeethWhitening() {
  const [openModal, setOpenModal] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);
  const { isLoggedIn } = useContext(AuthContext);
  return (
    <>
      <div className="top-page">
        <div className="circle-img">
          <img src="./تبيض اسنان.svg" alt="img" />
        </div>
        <div className="page-name">
          <p>تبييض الأسنان</p>
        </div>
      </div>
      {isLoggedIn && (
        <button className="open-request-btn" onClick={() => setOpenModal(true)}>
          + اطلب جديد
        </button>
      )}
      <RequestsList categoryName="تبييض الأسنان" categoryId={3} refreshKey={refreshKey} />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        onSuccess={() => setRefreshKey(k => k + 1)}
        specialization="تبييض الأسنان"
        categoryId={3}
      />
    </>
  );
}
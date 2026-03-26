import { useState, useContext } from "react";
import "../Css/Category.css";
import "../Css/AddRequest.css";
import AddRequest from "./AddRequest";
import RequestsList from "./RequestsList";
import { AuthContext } from "../services/AuthContext";

export default function PediatricDentistry() {
  const [openModal, setOpenModal] = useState(false);
  const [refreshKey, setRefreshKey] = useState(0);
  const { isLoggedIn } = useContext(AuthContext);
  return (
    <>
      <div className="top-page">
        <div className="circle-img">
          <img src="./فحص شامل.svg" alt="img" />
        </div>
        <div className="page-name">
          <p>طب أسنان الأطفال</p>
        </div>
      </div>
      {isLoggedIn && (
        <button className="open-request-btn" onClick={() => setOpenModal(true)}>
          + اطلب جديد
        </button>
      )}
      <RequestsList categoryName="طب أسنان الأطفال" categoryId={10} refreshKey={refreshKey} />
      <AddRequest
        isOpen={openModal}
        onClose={() => setOpenModal(false)}
        onSuccess={() => setRefreshKey(k => k + 1)}
        specialization="طب أسنان الأطفال"
        categoryId={10}
      />
    </>
  );
}

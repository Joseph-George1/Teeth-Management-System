import { useContext } from "react";
import { AuthContext } from "../services/AuthContext";
import "../Css/AdminHomeScreen.css";

export default function AdminHomeScreen() {
  const { user } = useContext(AuthContext);
  const displayName = user?.email || user?.firstName || "";

  return (
    <div className="admin-home-page">
      <div className="admin-home-card">
        <p className="admin-welcome-text">أهلاً بك</p>
        <p className="admin-email-text">{displayName}</p>
      </div>
    </div>
  );
}

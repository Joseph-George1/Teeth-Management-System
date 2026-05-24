import { useEffect } from "react";
import { Bell } from "lucide-react";
import "../Css/NotificationToast.css";

export default function NotificationToast({ notification, onDismiss }) {
  useEffect(() => {
    if (!notification) return;
    const timer = setTimeout(onDismiss, 5000);
    return () => clearTimeout(timer);
  }, [notification, onDismiss]);

  if (!notification) return null;

  return (
    <div className="notif-toast" onClick={onDismiss}>
      <div className="notif-toast-icon">
        <Bell size={20} />
      </div>
      <div className="notif-toast-content">
        <p className="notif-toast-title">{notification.title}</p>
        {notification.body && <p className="notif-toast-body">{notification.body}</p>}
      </div>
    </div>
  );
}

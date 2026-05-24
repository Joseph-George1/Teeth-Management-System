import { useState, useRef, useEffect, useCallback, useContext } from "react";
import { Bell, Trash2 } from "lucide-react";
import { useNotificationsList } from "../services/useNotificationsList";
import { useNotifications } from "../services/useNotifications";
import { AuthContext } from "../services/AuthContext";
import NotificationToast from "./NotificationToast";
import "../Css/NotificationBell.css";

export default function NotificationBell() {
  const { user, isLoggedIn } = useContext(AuthContext);
  const { notifications, unreadCount, loading, newNotification, dismissToast, fetchNotifications, markAsRead, markAllAsRead, deleteNotification, deleteAllNotifications } = useNotificationsList();
  const { setupPushNotifications } = useNotifications({ user, isLoggedIn, onForegroundMessage: null });
  const [isOpen, setIsOpen] = useState(false);
  const bellRef = useRef(null);
  const dropdownRef = useRef(null);
  const [dropdownStyle, setDropdownStyle] = useState({});
  const permissionAskedRef = useRef(false);

  const updatePosition = useCallback(() => {
    if (!bellRef.current) return;
    const rect = bellRef.current.getBoundingClientRect();
    const dropdownWidth = Math.min(340, window.innerWidth - 24);
    let left = rect.left + rect.width / 2 - dropdownWidth / 2;

    if (left < 12) left = 12;
    if (left + dropdownWidth > window.innerWidth - 12) left = window.innerWidth - 12 - dropdownWidth;

    setDropdownStyle({
      top: rect.bottom + 10,
      left: left,
      width: dropdownWidth,
    });
  }, []);

  useEffect(() => {
    const handleClickOutside = (e) => {
      if (
        dropdownRef.current && !dropdownRef.current.contains(e.target) &&
        bellRef.current && !bellRef.current.contains(e.target)
      ) {
        setIsOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  useEffect(() => {
    if (isOpen) {
      updatePosition();
      window.addEventListener("resize", updatePosition);
      window.addEventListener("scroll", updatePosition, true);
      return () => {
        window.removeEventListener("resize", updatePosition);
        window.removeEventListener("scroll", updatePosition, true);
      };
    }
  }, [isOpen, updatePosition]);

  const handleToggle = () => {
    if (!isOpen) {
      updatePosition();
      if (!permissionAskedRef.current) {
        permissionAskedRef.current = true;
        setupPushNotifications();
      }
    }
    setIsOpen((prev) => !prev);
  };

  const handleNotificationClick = (notification) => {
    if (!notification.read && !notification.isRead) {
      markAsRead(notification.id);
    }
  };

  return (
    <div className="notification-bell-wrapper">
      <button ref={bellRef} className="notification-bell-btn" onClick={handleToggle} title="الإشعارات">
        <Bell size={22} />
        {unreadCount > 0 && (
          <span className="notification-badge">{unreadCount > 9 ? "9+" : unreadCount}</span>
        )}
      </button>

      {isOpen && (
        <div
          ref={dropdownRef}
          className="notification-dropdown"
          style={dropdownStyle}
        >
          <div className="notification-dropdown-header">
            <span className="notification-dropdown-title">الإشعارات</span>
            <div className="notification-header-actions">
              {unreadCount > 0 && (
                <button className="notification-mark-all" onClick={markAllAsRead}>
                  قراءة الكل
                </button>
              )}
              {notifications.length > 0 && (
                <button className="notification-delete-all" onClick={() => { deleteAllNotifications(); setIsOpen(false); }}>
                  حذف الكل
                </button>
              )}
            </div>
          </div>

          <div className="notification-dropdown-body">
            {loading && notifications.length === 0 ? (
              <div className="notification-empty">جاري التحميل...</div>
            ) : notifications.length === 0 ? (
              <div className="notification-empty">لا توجد إشعارات</div>
            ) : (
              notifications.slice(0, 20).map((n) => (
                <div
                  key={n.id}
                  className={`notification-item ${!n.read && !n.isRead ? "notification-unread" : ""}`}
                  onClick={() => handleNotificationClick(n)}
                >
                  <div className="notification-item-content">
                    <p className="notification-item-title">{n.title || "إشعار جديد"}</p>
                    <p className="notification-item-body">{n.body || n.message || ""}</p>
                  </div>
                  <div className="notification-item-actions">
                    {!n.read && !n.isRead && (
                      <div className="notification-item-dot">
                        <span className="unread-dot" />
                      </div>
                    )}
                    <button
                      className="notification-item-delete-btn"
                      onClick={(e) => {
                        e.stopPropagation();
                        deleteNotification(n.id);
                      }}
                      title="حذف"
                    >
                      <Trash2 size={14} />
                    </button>
                  </div>
                </div>
              ))
            )}
          </div>
        </div>
      )}
      <NotificationToast notification={newNotification} onDismiss={dismissToast} />
    </div>
  );
}

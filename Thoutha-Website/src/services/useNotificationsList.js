import { useState, useEffect, useCallback, useRef, useContext } from "react";
import { AuthContext } from "./AuthContext";

const API_BASE_URL = import.meta.env.DEV ? "/api" : "https://thoutha.page/api";

export function useNotificationsList() {
  const { user, isLoggedIn } = useContext(AuthContext);
  const [notifications, setNotifications] = useState([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const [loading, setLoading] = useState(false);
  const [newNotification, setNewNotification] = useState(null);
  const fetchedRef = useRef(false);
  const prevCountRef = useRef(0);
  const prevNotificationIdsRef = useRef(new Set());

  const authToken = user?.token || localStorage.getItem("token");

  const fetchNotifications = useCallback(async () => {
    if (!isLoggedIn || !authToken) return;
    setLoading(true);
    try {
      const res = await fetch(`${API_BASE_URL}/v1/notifications`, {
        headers: { Authorization: `Bearer ${authToken}` },
      });
      if (!res.ok) throw new Error();
      const data = await res.json();
      const list = Array.isArray(data) ? data : data?.data || data?.content || data?.result || [];
      
      // Map readStatus from Backend to read and isRead properties
      const mappedList = list.map((n) => ({
        ...n,
        read: n.readStatus !== undefined ? n.readStatus : (n.read || false),
        isRead: n.readStatus !== undefined ? n.readStatus : (n.isRead || false),
      }));

      const newUnread = mappedList.filter((n) => !n.read && !n.isRead).length;
      const currentNotificationIds = new Set(mappedList.map((n) => n.id));
      
      // Check if there are any NEW notifications (IDs not in previous set)
      const newNotificationIds = Array.from(currentNotificationIds).filter(
        (id) => !prevNotificationIdsRef.current.has(id)
      );
      
      // Show toast if there are new notifications
      if (newNotificationIds.length > 0) {
        const latest = mappedList[0];
        if (latest) {
          setNewNotification({
            id: Date.now(),
            title: latest.title || "إشعار جديد",
            body: latest.body || latest.message || "",
          });
        }
      }
      
      // Update refs for next comparison
      prevNotificationIdsRef.current = currentNotificationIds;
      prevCountRef.current = newUnread;

      setNotifications(mappedList);
      setUnreadCount(newUnread);
    } catch {
      setNotifications([]);
      setUnreadCount(0);
    } finally {
      setLoading(false);
    }
  }, [isLoggedIn, authToken]);

  const dismissToast = useCallback(() => {
    setNewNotification(null);
  }, []);

  const markAsRead = useCallback(async (id) => {
    if (!authToken) return;
    setNotifications((prev) =>
      prev.map((n) => (n.id === id ? { ...n, read: true, isRead: true } : n))
    );
    setUnreadCount((prev) => Math.max(0, prev - 1));
    try {
      await fetch(`${API_BASE_URL}/v1/notifications/${id}/read`, {
        method: "PUT",
        headers: {
          Authorization: `Bearer ${authToken}`,
          "Content-Type": "application/json",
        },
      });
    } catch {}
  }, [authToken]);

  const markAllAsRead = useCallback(async () => {
    if (!authToken) return;
    setNotifications((prev) =>
      prev.map((n) => ({ ...n, read: true, isRead: true }))
    );
    setUnreadCount(0);
    prevCountRef.current = 0;
    try {
      const response = await fetch(`${API_BASE_URL}/v1/notifications/read-all`, {
        method: "PUT",
        headers: {
          Authorization: `Bearer ${authToken}`,
          "Content-Type": "application/json",
        },
      });
      if (response.ok) {
        // Refetch to sync with backend after marking all as read
        await fetchNotifications();
      }
    } catch {}
  }, [authToken, fetchNotifications]);

  const deleteNotification = useCallback(async (id) => {
    if (!authToken) return;
    setNotifications((prev) => {
      const updated = prev.filter((n) => n.id !== id);
      const newUnread = updated.filter((n) => !n.read && !n.isRead).length;
      setUnreadCount(newUnread);
      prevCountRef.current = newUnread;
      
      // Update IDs set
      const updatedIds = new Set(updated.map((n) => n.id));
      prevNotificationIdsRef.current = updatedIds;
      
      return updated;
    });
    try {
      await fetch(`${API_BASE_URL}/v1/notifications/${id}`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${authToken}`,
          "Content-Type": "application/json",
        },
      });
    } catch {}
  }, [authToken]);

  const deleteAllNotifications = useCallback(async () => {
    if (!authToken) return;
    setNotifications([]);
    setUnreadCount(0);
    prevCountRef.current = 0;
    prevNotificationIdsRef.current = new Set();
    try {
      await fetch(`${API_BASE_URL}/v1/notifications`, {
        method: "DELETE",
        headers: {
          Authorization: `Bearer ${authToken}`,
          "Content-Type": "application/json",
        },
      });
    } catch {}
  }, [authToken]);

  useEffect(() => {
    if (isLoggedIn && !fetchedRef.current) {
      fetchedRef.current = true;
      fetchNotifications();
    }
    if (!isLoggedIn) {
      fetchedRef.current = false;
      setNotifications([]);
      setUnreadCount(0);
      prevCountRef.current = 0;
      prevNotificationIdsRef.current = new Set();
      return;
    }

    const interval = setInterval(fetchNotifications, 30000);
    return () => clearInterval(interval);
  }, [isLoggedIn, fetchNotifications]);

  return { notifications, unreadCount, loading, newNotification, dismissToast, fetchNotifications, markAsRead, markAllAsRead, deleteNotification, deleteAllNotifications };
}

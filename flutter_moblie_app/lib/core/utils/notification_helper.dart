class NotificationHelper {
  static bool hasUnreadNotifications = false;

  static int getUnreadCount() {
    // For now, return a dummy value. In real app, fetch from server or local storage.
    return hasUnreadNotifications ? 5 : 0; // Example: 5 unread if true
  }
}

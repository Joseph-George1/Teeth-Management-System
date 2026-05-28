import { useCallback } from 'react';

/**
 * useNotifications Hook
 * 
 * This hook has been stripped of all external push notification functionality.
 * External push notifications (Firebase Cloud Messaging, Web Push API, etc.) have been removed.
 * 
 * Local notifications (via useNotificationsList) are still fully functional and work
 * with the backend API to fetch and display notifications within the application.
 * 
 * The Notification Bell component will continue to work normally using useNotificationsList.
 */
export function useNotifications({ user, isLoggedIn, onForegroundMessage }) {
  // Stub function - external push notifications are disabled
  const setupPushNotifications = useCallback(async () => {
    // External push notifications have been completely removed
    // The application now uses only local in-app notifications from the API
    return false;
  }, []);

  return { setupPushNotifications };
}

import { useEffect, useRef, useCallback } from 'react';
import { getToken, onMessage, deleteToken } from 'firebase/messaging';
import { getFirebaseMessaging } from './firebaseConfig';

const API_BASE_URL = import.meta.env.DEV ? '/api' : 'https://thoutha.page/api';
const VAPID_KEY = import.meta.env.VITE_FIREBASE_VAPID_KEY;
const FCM_TOKEN_KEY = 'thoutha_fcm_token';

export function useNotifications({ user, isLoggedIn, onForegroundMessage }) {
  const unsubscribeRef = useRef(null);
  const tokenRegisteredRef = useRef(false);

  const registerTokenWithBackend = useCallback(async (fcmToken, authToken, doctorId) => {
    try {
      const response = await fetch(`${API_BASE_URL}/v1/device-tokens/register`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${authToken}`,
        },
        body: JSON.stringify({
          fcmToken: fcmToken,
          deviceType: 'WEB',
          deviceModel: navigator.userAgent.slice(0, 50),
          osVersion: navigator.platform || 'Web',
          ...(doctorId && !isNaN(Number(doctorId)) ? { user_id: Number(doctorId), userId: Number(doctorId) } : {}),
        }),
      });

      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        console.error('[Thoutha] Token registration failed:', errorData);
        return;
      }

      console.log('[Thoutha] FCM token registered successfully');
      localStorage.setItem(FCM_TOKEN_KEY, fcmToken);
      tokenRegisteredRef.current = true;
    } catch (err) {
      console.error('[Thoutha] Token registration error:', err);
    }
  }, []);

  const setupPushNotifications = useCallback(async () => {
    if (!isLoggedIn || !user) return false;
    if (tokenRegisteredRef.current) return true;

    if (!('Notification' in window) || !('serviceWorker' in navigator)) {
      console.warn('[Thoutha] Browser does not support notifications');
      return false;
    }

    try {
      const messaging = await getFirebaseMessaging();
      if (!messaging) {
        console.warn('[Thoutha] Firebase Messaging not supported');
        return false;
      }

      const permission = await Notification.requestPermission();
      console.log('[Thoutha] Permission:', permission);
      if (permission !== 'granted') return false;

      let swRegistration;
      try {
        swRegistration = await navigator.serviceWorker.register('/firebase-messaging-sw.js', { scope: '/' });
        await navigator.serviceWorker.ready;
        console.log('[Thoutha] Service worker ready');
      } catch (err) {
        console.error('[Thoutha] SW registration failed:', err);
        return false;
      }

      const authToken = user?.token || localStorage.getItem('token');
      const existingToken = localStorage.getItem(FCM_TOKEN_KEY);

      let fcmToken;
      try {
        fcmToken = await getToken(messaging, {
          vapidKey: VAPID_KEY,
          serviceWorkerRegistration: swRegistration,
        });
      } catch {
        try {
          await deleteToken(messaging);
          fcmToken = await getToken(messaging, {
            vapidKey: VAPID_KEY,
            serviceWorkerRegistration: swRegistration,
          });
        } catch (err) {
          console.error('[Thoutha] FCM token failed:', err);
          return false;
        }
      }

      if (!fcmToken) {
        console.warn('[Thoutha] No FCM token received');
        return false;
      }

      console.log('[Thoutha] FCM token acquired');

      if (fcmToken !== existingToken) {
        const doctorId = user?.id || user?.doctorId || user?.userId;
        await registerTokenWithBackend(fcmToken, authToken, doctorId);
      } else {
        console.log('[Thoutha] Token unchanged, already registered');
        tokenRegisteredRef.current = true;
      }

      if (onForegroundMessage && !unsubscribeRef.current) {
        unsubscribeRef.current = onMessage(messaging, (payload) => {
          console.log('[Thoutha] Foreground message:', payload);
          onForegroundMessage(payload);
        });
      }

      return true;
    } catch (err) {
      console.error('[Thoutha] Setup error:', err);
      return false;
    }
  }, [isLoggedIn, user, onForegroundMessage, registerTokenWithBackend]);

  useEffect(() => {
    if (isLoggedIn && user && Notification.permission === 'granted') {
      setupPushNotifications();
    }

    return () => {
      if (unsubscribeRef.current) {
        unsubscribeRef.current();
        unsubscribeRef.current = null;
      }
    };
  }, [isLoggedIn, user, setupPushNotifications]);

  useEffect(() => {
    if (!isLoggedIn) {
      tokenRegisteredRef.current = false;
    }
  }, [isLoggedIn]);

  return { setupPushNotifications };
}

// Push Notification Service for Thoutha Doctor PWA
// Location: Thoutha-Website/src/services/pushNotificationService.js
//
// Handles the full push notification lifecycle:
//   1. Register service worker
//   2. Request notification permission from the doctor
//   3. Get FCM registration token
//   4. Send token to Python notification microservice
//   5. Handle foreground notifications (when PWA is open)
//   6. Deregister token on logout

import { getFirebaseMessaging } from './firebaseConfig';
import { getToken, onMessage } from 'firebase/messaging';

const NOTIFICATION_API = 'https://thoutha.page';
const VAPID_KEY = import.meta.env.VITE_FIREBASE_VAPID_KEY;

// ============================================================================
// PUBLIC API
// ============================================================================

/**
 * Register for push notifications after the doctor logs in.
 *
 * Call this AFTER login succeeds and the doctor's user ID is known.
 * This function is intentionally fire-and-forget — failures are logged
 * but never break the login flow.
 *
 * @param {number} doctorId - The doctor's backend ID (from JWT payload)
 * @returns {Promise<string|null>} The FCM token, or null if denied/failed
 */
export async function registerForPushNotifications(doctorId) {
  try {
    // 1. Check browser support
    if (!('Notification' in window)) {
      console.warn('[Push] This browser does not support notifications');
      return null;
    }
    if (!('serviceWorker' in navigator)) {
      console.warn('[Push] Service workers not supported');
      return null;
    }

    // 2. Register or reuse active PWA service worker
    const registrations = await navigator.serviceWorker.getRegistrations();
    let swRegistration = registrations.find(r => r.active && (r.active.scriptURL.includes('sw.js') || r.active.scriptURL.includes('firebase-messaging-sw.js')));
    
    if (!swRegistration) {
      console.log('[Push] No active service worker found, registering firebase-messaging-sw.js');
      swRegistration = await navigator.serviceWorker.register('/firebase-messaging-sw.js', { scope: '/' });
    } else {
      console.log('[Push] Using active service worker:', swRegistration.active.scriptURL);
    }
    await navigator.serviceWorker.ready;

    // 3. Request notification permission from the user
    const permission = await Notification.requestPermission();
    if (permission !== 'granted') {
      console.warn('[Push] Notification permission denied by user');
      return null;
    }
    console.log('[Push] Notification permission granted');

    // 4. Get FCM registration token
    const messaging = await getFirebaseMessaging();
    if (!messaging) {
      console.warn('[Push] Firebase Messaging not supported');
      return null;
    }

    const fcmToken = await getToken(messaging, {
      vapidKey: VAPID_KEY,
      serviceWorkerRegistration: swRegistration,
    });

    if (!fcmToken) {
      console.error('[Push] Failed to get FCM token from Firebase');
      return null;
    }
    console.log('[Push] FCM token obtained:', fcmToken.substring(0, 20) + '...');

    // 5. Avoid re-registering the exact same token
    const storedToken = localStorage.getItem('fcmToken');
    if (storedToken === fcmToken) {
      console.log('[Push] Token already registered with backend, skipping');
      return fcmToken;
    }

    // 6. Register the token with the Python notification microservice
    await registerTokenWithBackend(doctorId, fcmToken);

    return fcmToken;
  } catch (error) {
    console.error('[Push] Error during push registration:', error);
    return null;
  }
}

/**
 * Set up foreground notification handler.
 * Shows a browser-level notification when a message arrives while the PWA is open.
 *
 * @param {function} onNotificationReceived - Callback with {title, body, data}
 */
export async function setupForegroundNotifications(onNotificationReceived) {
  const messaging = await getFirebaseMessaging();
  if (!messaging) return;

  onMessage(messaging, (payload) => {
    console.log('[Push] Foreground message received:', payload);

    const title = payload.notification?.title || payload.data?.title || 'ثوثة';
    const body  = payload.notification?.body  || payload.data?.body  || 'لديك إشعار جديد';

    if (onNotificationReceived) {
      onNotificationReceived({ title, body, data: payload.data });
    }
  });
}

/**
 * Deregister the FCM token (call on logout).
 * Tells the Python backend to mark the token as inactive so the doctor
 * stops receiving push notifications on this device.
 */
export async function deregisterPushNotifications() {
  try {
    const fcmToken = localStorage.getItem('fcmToken');
    if (!fcmToken) return;

    await fetch(
      `${NOTIFICATION_API}/api/v1/device-tokens/deregister?token=${encodeURIComponent(fcmToken)}`,
      { method: 'DELETE' }
    );

    localStorage.removeItem('fcmToken');
    console.log('[Push] Token deregistered from backend');
  } catch (error) {
    console.error('[Push] Error deregistering token:', error);
  }
}

// ============================================================================
// PRIVATE HELPERS
// ============================================================================

/**
 * Send the FCM token to the Python microservice for storage.
 * Uses the existing POST /api/v1/device-tokens/register endpoint.
 */
async function registerTokenWithBackend(doctorId, fcmToken) {
  try {
    const response = await fetch(`${NOTIFICATION_API}/api/v1/device-tokens/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        user_id:     doctorId,
        fcmToken:    fcmToken,
        deviceType:  'WEB',
        deviceModel: getBrowserInfo(),
        osVersion:   getOSInfo(),
      }),
    });

    const data = await response.json();
    if (data.success) {
      console.log('[Push] Token registered with backend:', data);
      localStorage.setItem('fcmToken', fcmToken);
    } else {
      console.error('[Push] Backend registration failed:', data);
    }
  } catch (error) {
    console.error('[Push] Error registering token with backend:', error);
  }
}

function getBrowserInfo() {
  const ua = navigator.userAgent;
  if (ua.includes('Safari') && !ua.includes('Chrome')) return 'Safari PWA';
  if (ua.includes('Chrome'))  return 'Chrome';
  if (ua.includes('Firefox')) return 'Firefox';
  return 'Web Browser';
}

function getOSInfo() {
  const ua = navigator.userAgent;
  if (ua.includes('iPhone') || ua.includes('iPad')) return 'iOS';
  if (ua.includes('Android')) return 'Android';
  if (ua.includes('Mac OS'))  return 'macOS';
  if (ua.includes('Windows')) return 'Windows';
  return 'Unknown';
}

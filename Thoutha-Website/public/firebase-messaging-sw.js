// Service Worker for Firebase Cloud Messaging (Background Push Notifications)
// Location: Thoutha-Website/public/firebase-messaging-sw.js
//
// This runs OUTSIDE the React app context. It handles notifications when:
//   - The PWA is in the background
//   - The browser tab is closed
//   - The device is locked (iOS Safari PWA)
//
// IMPORTANT: This file is served at the root path /firebase-messaging-sw.js.
// The Firebase JS SDK auto-discovers it at this location.

importScripts('https://www.gstatic.com/firebasejs/11.8.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.8.1/firebase-messaging-compat.js');

// ============================================================================
// FIREBASE CONFIGURATION
// ============================================================================
// These values must match your Firebase project.
// Copy from: Firebase Console → Project Settings → General → Web App
//
// NOTE: Service workers cannot access Vite's import.meta.env, so these
// must be hardcoded here. This is safe — Firebase Web config is public.
// ============================================================================
firebase.initializeApp({
  apiKey:            'YOUR_API_KEY',            // ← Replace with your Firebase API key
  authDomain:        'YOUR_PROJECT.firebaseapp.com',
  projectId:         'YOUR_PROJECT_ID',
  storageBucket:     'YOUR_PROJECT.appspot.com',
  messagingSenderId: 'YOUR_SENDER_ID',         // ← Replace with your Sender ID
  appId:             'YOUR_APP_ID',            // ← Replace with your App ID
});

const messaging = firebase.messaging();

// ============================================================================
// BACKGROUND MESSAGE HANDLER
// ============================================================================
// Called when the PWA is NOT in the foreground (minimized, screen locked, etc.)
// The FCM SDK automatically shows the notification using the data below.
// ============================================================================
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw] Background message received:', payload);

  const notificationTitle = payload.notification?.title || payload.data?.title || 'ثوثة';
  const notificationOptions = {
    body:  payload.notification?.body || payload.data?.body || 'لديك إشعار جديد',
    icon:  '/thoutha-180x180.png',
    badge: '/thoutha-48x48.png',
    tag:   payload.data?.appointmentId || 'thoutha-notification',
    data:  payload.data || {},
    // iOS Safari PWA requires these for proper display
    requireInteraction: true,
    renotify: true,
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// ============================================================================
// NOTIFICATION CLICK HANDLER
// ============================================================================
// When the doctor taps the notification, focus the existing PWA window
// or open a new one pointing to the doctor's dashboard.
// ============================================================================
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const targetUrl = '/doctor-home';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      // If the PWA is already open, focus it
      for (const client of clientList) {
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          return client.focus();
        }
      }
      // Otherwise, open a new window
      return clients.openWindow(targetUrl);
    })
  );
});

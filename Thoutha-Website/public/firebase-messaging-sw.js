/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyBX-D_TAYMzm9PBuQwsIgHBvvO56NARZL0',
  authDomain: 'teeth-management-system-b60a7.firebaseapp.com',
  projectId: 'teeth-management-system-b60a7',
  storageBucket: 'teeth-management-system-b60a7.firebasestorage.app',
  messagingSenderId: '386411267159',
  appId: '1:386411267159:web:2a7a5c34de936ee4b48f12',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const notificationTitle =
    payload.notification?.title ||
    payload.data?.title ||
    'حجز جديد - ثوثة';

  const notificationBody =
    payload.notification?.body ||
    payload.data?.body ||
    'لديك حجز جديد من مريض';

  const notificationOptions = {
    body: notificationBody,
    icon: '/ثوثة.png',
    badge: '/thoutha-48x48.png',
    dir: 'rtl',
    lang: 'ar',
    tag: 'thoutha-booking-' + Date.now(),
    renotify: true,
    data: {
      url: payload.data?.url || '/doctor-home',
      timestamp: Date.now(),
    },
    actions: [
      {
        action: 'open',
        title: 'عرض الحجز',
      },
    ],
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const targetUrl = event.notification.data?.url || '/doctor-home';

  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if (client.url.includes(self.location.origin) && 'focus' in client) {
          client.focus();
          client.navigate(targetUrl);
          return;
        }
      }
      return clients.openWindow(targetUrl);
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

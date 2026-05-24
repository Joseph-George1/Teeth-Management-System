// Firebase Web SDK configuration for Thoutha
// Location: Thoutha-Website/src/services/firebaseConfig.js
//
// Initializes the Firebase app and exports the messaging instance.
// The actual config values are loaded from environment variables (VITE_FIREBASE_*).
//
// To configure: create a .env file in Thoutha-Website/ with:
//   VITE_FIREBASE_API_KEY=AIzaSy...
//   VITE_FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
//   VITE_FIREBASE_PROJECT_ID=your-project-id
//   VITE_FIREBASE_STORAGE_BUCKET=your-project.appspot.com
//   VITE_FIREBASE_MESSAGING_SENDER_ID=123456789
//   VITE_FIREBASE_APP_ID=1:123456789:web:abc123
//   VITE_FIREBASE_VAPID_KEY=BPq7...
//
// Get these from: Firebase Console → Project Settings → General → Web App
// VAPID key from: Project Settings → Cloud Messaging → Web Push certificates

import { initializeApp } from 'firebase/app';
import { getMessaging, getToken, onMessage } from 'firebase/messaging';

const firebaseConfig = {
  apiKey:            import.meta.env.VITE_FIREBASE_API_KEY,
  authDomain:        import.meta.env.VITE_FIREBASE_AUTH_DOMAIN,
  projectId:         import.meta.env.VITE_FIREBASE_PROJECT_ID,
  storageBucket:     import.meta.env.VITE_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID,
  appId:             import.meta.env.VITE_FIREBASE_APP_ID,
};

const app = initializeApp(firebaseConfig);
const messaging = getMessaging(app);

export { app, messaging, getToken, onMessage };

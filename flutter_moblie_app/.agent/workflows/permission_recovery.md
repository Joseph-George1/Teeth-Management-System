---
description: Permission Settings Recovery Workflow
---

This workflow describes how to handle and recover from denied permissions by redirecting the user to the system app settings.

### 1. Detection
The app monitors permission status in the `SplashScreen` using `Geolocator` and `FirebaseMessaging`.

### 2. Prompting
If a permission is detected as `permanentlyDenied` (Location) or `denied` (Notifications), the app shows a custom dialog:
- **Location**: Uses `Geolocator`'s `_showLocationDialog`.
- **Notifications**: Uses `NotificationPermissionHelper.showPermanentlyDeniedDialog`.

### 3. Redirection
// turbo
1. Clicking "Go to Settings" (الذهاب للإعدادات) triggers `openAppSettings()`.
2. This opens the specific settings page for this app on the user's device.

### 4. Verification Loop
1. Once the user returns to the app from settings, the `SplashScreen`'s recursive check triggers again.
2. If permissions are now granted, the app proceeds to the next screen.
3. If not, the prompt is shown again (Sticky Enforcement).

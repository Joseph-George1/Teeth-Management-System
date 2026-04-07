# Notification Service Integration Guide

## Overview

The notification system now uses **synchronized user IDs** between the Java backend and Python notification service. This ensures:
- ✅ No user ID conflicts
- ✅ Notifications delivered to correct users
- ✅ Clear traceability and debugging
- ✅ Identical user identification across services

---

## Architecture Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        MOBILE APP (Flutter)                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌──────────────────────┐
                    │  Java Backend Login  │
                    │   POST /login        │
                    └──────────────────────┘
                              │
                Returns: user_id=454
                              │
                              ▼
        ┌──────────────────────────────────────────┐
        │ Save user_id in Flutter SharedPreferences│
        │ saveUserId(454) ← CRITICAL!              │
        └──────────────────────────────────────────┘
                              │
                    Get FCM token from Firebase
                              │
                              ▼
        ┌──────────────────────────────────────────┐
        │ Register Device Token                    │
        │ POST /api/v1/device-tokens/register     │
        │ {                                        │
        │   "user_id": 454,      ← From backend! │
        │   "fcmToken": "abc...", ← From Firebase │
        │   "deviceType": "ANDROID"                │
        │ }                                        │
        └──────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────┐
│  Python Notification Service                         │
│  Stores: user_id=454 linked to FCM token "abc..."   │
└──────────────────────────────────────────────────────┘
                              │
                              ▼
        ┌──────────────────────────────────────────┐
        │ Java Backend Sends Notification          │
        │ POST /api/v1/notifications/...           │
        │ {                                        │
        │   "user_id": 454,  ← Same user_id!      │
        │   "title": "Appointment Confirmed"       │
        │ }                                        │
        └──────────────────────────────────────────┘
                              │
                              ▼
        ┌──────────────────────────────────────────┐
        │ Queue Processor (Runs every 2 seconds)  │
        │ SELECT device tokens for user_id=454     │
        │ Finds: "abc..." ← FCM token linked!     │
        └──────────────────────────────────────────┘
                              │
                              ▼
        ┌──────────────────────────────────────────┐
        │ Firebase Admin SDK                       │
        │ send_to_device("abc...", notification)  │
        │ Returns: FCM message ID + success        │
        └──────────────────────────────────────────┘
                              │
                              ▼
        ┌──────────────────────────────────────────┐
        │ Firebase Cloud Messaging Service         │
        │ Routes to mobile device                  │
        └──────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Mobile Device Receives                         │
│         Push notification displayed in system tray               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Steps

### Step 1: Java Backend - Update Login Response

The backend login endpoint must return the user ID:

```java
@PostMapping("/login")
public ResponseEntity<?> login(@RequestBody LoginRequest request) {
    // ... validation and authentication ...
    
    User user = userRepository.findByEmail(request.getEmail());
    
    // CRITICAL: Return user_id to mobile app
    return ResponseEntity.ok(new LoginResponse(
        true,
        user.getId(),  // ← User's database ID
        user.getEmail(),
        generateJWT(user)
    ));
}
```

**Example Response:**
```json
{
  "success": true,
  "user_id": 454,
  "email": "doctor@clinic.com",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### Step 2: Mobile App (Flutter) - Save User ID After Login

After successful login, save the user_id:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = const FlutterSecureStorage();
  
  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/api/login'),
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      // CRITICAL: Save user_id from backend
      final userId = data['user_id'];
      await storage.write(
        key: 'user_id',
        value: userId.toString(),
      );
      
      // Save other data
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'email', value: data['email']);
      
      print('✓ Login successful. User ID: $userId');
      
      // NOW register device token with this user_id
      await registerDeviceToken(userId);
    }
  }
  
  Future<void> registerDeviceToken(int userId) async {
    final messaging = FirebaseMessaging.instance;
    final fcmToken = await messaging.getToken();
    
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    
    final response = await http.post(
      Uri.parse('http://10.0.2.2:9000/api/v1/device-tokens/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,  // ← FROM BACKEND LOGIN!
        'fcmToken': fcmToken,
        'deviceType': 'ANDROID',
        'deviceModel': androidInfo.model,
        'osVersion': androidInfo.version.toString(),
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✓ Device token registered');
      print('  User ID: ${data['user_id']}');
      print('  FCM Token: ${data['fcm_token']}');
      print('  Device: ${data['device_model']}');
    } else {
      print('✗ Device token registration failed: ${response.body}');
    }
  }
}
```

---

### Step 3: Java Backend - Send Notifications to Correct User ID

When sending notifications, use the user's actual ID:

```java
@PostMapping("/api/v1/notifications/appointment-confirmed")
public ResponseEntity<?> notifyAppointmentConfirmed(
    @RequestBody NotificationRequest request) {
    
    // Get the appointment
    Appointment appointment = appointmentRepository.findById(request.getAppointmentId());
    
    // Get the user (patient or doctor)
    long userId = appointment.getPatientId();  // ← Use correct user ID
    String title = "Appointment Confirmed";
    String body = "Your appointment on " + appointment.getDateTime() + " is confirmed";
    
    // Send to notification service with correct user_id
    RestTemplate restTemplate = new RestTemplate();
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    
    Map<String, Object> notificationPayload = new HashMap<>();
    notificationPayload.put("user_id", userId);  // ← CRITICAL: Use actual user ID
    notificationPayload.put("title", title);
    notificationPayload.put("body", body);
    notificationPayload.put("type", "appointment");
    notificationPayload.put("appointment_id", appointment.getId());
    
    HttpEntity<Map<String, Object>> request = new HttpEntity<>(
        notificationPayload, headers);
    
    restTemplate.postForObject(
        "http://notification-service:9000/api/v1/notifications/appointment-confirmed",
        request,
        ResponseEntity.class
    );
    
    return ResponseEntity.ok("Notification sent to user " + userId);
}
```

---

### Step 4: Python Notification Service - Device Token Registration

The registration endpoint now **requires** `user_id`:

```
POST /api/v1/device-tokens/register

Request:
{
  "user_id": 454,  ← REQUIRED (from backend login)
  "fcmToken": "eIydw6BlQjaIWMLGn1LO...",
  "deviceType": "ANDROID",
  "deviceModel": "Samsung Galaxy S21",
  "osVersion": "33"
}

Response (200 OK):
{
  "success": true,
  "message": "Device token registered successfully - ready to receive notifications",
  "user_id": 454,
  "device_type": "ANDROID",
  "device_model": "Samsung Galaxy S21",
  "fcm_token": "eIydw6BlQjaIWM..."
}

Error (400 Bad Request):
{
  "detail": "user_id is required. Please login to backend first and use the returned user_id"
}
```

---

## Testing the Flow

### Test Case 1: Complete Happy Path

```bash
# 1. Mobile app logs in
curl -X POST http://10.0.2.2:8080/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"doctor@clinic.com", "password":"pass123"}'

# Response includes: user_id=454

# 2. Mobile app registers device token (with user_id from step 1)
curl -X POST http://10.0.2.2:9000/api/v1/device-tokens/register \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 454,
    "fcmToken": "abc123xyz456...",
    "deviceType": "ANDROID",
    "deviceModel": "Samsung Galaxy S21",
    "osVersion": "33"
  }'

# Response: "success": true, "user_id": 454

# 3. Java backend sends notification
curl -X POST http://localhost:9000/api/v1/notifications/appointment-confirmed \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 454,
    "title": "Appointment Confirmed",
    "body": "Your appointment is confirmed"
  }'

# Queue processor finds token for user 454 and sends via Firebase ✓
```

### Expected Logs

**Python Notification Service:**
```
Device token registration: user_id=454, device=ANDROID
✓ Registered device token for user 454: eIydw6BlQjaIWM... (ANDROID)
POST /api/v1/device-tokens/register HTTP/1.1" 200 OK

POST /api/v1/notifications/appointment-confirmed HTTP/1.1" 200 OK
✓ Found device token for user 454 → Sent to Firebase
Notification 55 delivered successfully to user 454
```

---

## Troubleshooting

### Problem: "No active device tokens for user X"

**Cause:** Device registered with different user_id than notifications sent to

**Solution:**
1. Check mobile app login response - confirm user_id is correct
2. Check device token registration - confirm user_id matches login response
3. Check Java backend - confirm it's sending to correct user_id

```bash
# Check device tokens registered
SELECT user_id, fcm_token FROM PATIENT_DEVICE_TOKENS WHERE is_active = 1;

# Should show user_id=454 with FCM token registered
```

### Problem: Device token registration fails with 400

**Cause:** "user_id is required"

**Solution:** Mobile app calling endpoint without user_id from login. Fix:
```dart
// ❌ WRONG - no user_id
await http.post(
  Uri.parse('http://notification-service:9000/api/v1/device-tokens/register'),
  body: jsonEncode({
    'fcmToken': fcm Token,
    'deviceType': 'ANDROID',
  }),
);

// ✓ CORRECT - with user_id from login
await http.post(
  Uri.parse('http://notification-service:9000/api/v1/device-tokens/register'),
  body: jsonEncode({
    'user_id': 454,  // ← From backend login!
    'fcmToken': fcmToken,
    'deviceType': 'ANDROID',
  }),
);
```

### Problem: Notifications queued but never sent

**Cause:** Queue processor running but no device tokens found

**Solution:**
1. Check that device token registration returned 200 OK
2. Verify user_id in registration matches user_id in notification
3. Check that `is_active=1` in database

```bash
# Check pending notifications
SELECT id, user_id, status FROM NOTIFICATION_QUEUE WHERE status = 'PENDING';

# Check device tokens
SELECT user_id, is_active FROM PATIENT_DEVICE_TOKENS;

# They should have matching user_ids
```

---

## Key Points Summary

| Component | Requirement | Example |
|-----------|-------------|---------|
| **Backend Login** | Returns `user_id` | `{"user_id": 454}` |
| **Mobile App** | Saves `user_id` after login | `storage.write('user_id', '454')` |
| **Device Registration** | Sends `user_id` to Python | `POST /api/v1/device-tokens/register {"user_id": 454}` |
| **Backend Notifications** | Sends `user_id` in request | `POST /api/v1/notifications/... {"user_id": 454}` |
| **Queue Processor** | Queries tokens by `user_id` | `SELECT * WHERE user_id=454` |
| **Firebase** | Sends to FCM token | FCM routes to device ✓ |

---

## Database Schema

```sql
-- Device tokens linked to backend user IDs
SELECT 
    id,
    user_id,
    fcm_token,
    device_type,
    is_active,
    created_at
FROM PATIENT_DEVICE_TOKENS
WHERE is_active = 1
ORDER BY user_id;

-- Example output:
-- id=1, user_id=454, fcm_token=eIydw6..., device_type=ANDROID, is_active=1
-- id=2, user_id=454, fcm_token=fJzex7..., device_type=iOS, is_active=1
-- id=3, user_id=721, fcm_token=aAbcd12..., device_type=ANDROID, is_active=1
```

---

##Deployment Checklist

- [ ] Java backend updated to return `user_id` in login response
- [ ] Mobile app updated to save `user_id` after login
- [ ] Mobile app updated to send `user_id` when registering device token
- [ ] Mobile app waits for login before registering device token
- [ ] Java backend updated to use correct `user_id` when sending notifications
- [ ] Python notification service updated (commit c8c89a3)
- [ ] Database migration applied (PATIENT_DEVICE_TOKENS table)
- [ ] Testing completed end-to-end
- [ ] Logs show "Found device token for user X" messages
- [ ] Firebase dashboard shows delivered messages

---

## Support

For issues:
1. Check logs: `tail -f /var/log/notification-service.log`
2. Test device token endpoint: `curl -X POST http://notification-service:9000/api/v1/device-tokens/register`
3. Check database: `SELECT * FROM PATIENT_DEVICE_TOKENS;`
4. Verify user IDs match: `SELECT user_id FROM NOTIFICATION_QUEUE;`

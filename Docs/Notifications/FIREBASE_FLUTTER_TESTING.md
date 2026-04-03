# Firebase Notifications Guide - Java Backend Direct Integration
## For Flutter Team Testing & Integration

---

## 📋 Table of Contents
1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Java Backend Implementation](#java-backend-implementation)
4. [Firebase Configuration](#firebase-configuration)
5. [Integration Flow](#integration-flow)
6. [Flutter Implementation Guide](#flutter-implementation-guide)
7. [API Endpoints](#api-endpoints)
8. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

The Teeth Management System uses **Firebase Cloud Messaging (FCM)** directly from Java Spring Boot backend to deliver push notifications to mobile and web applications.

### Architecture
- **Backend**: Java Spring Boot (Port 8080) - Direct Firebase integration
- **Database**: Oracle XE - Stores device tokens and notification logs
- **Mobile Client**: Flutter - Receives and displays notifications
- **Messaging**: Firebase Cloud Messaging (FCM) - Delivery mechanism

### Key Features
✅ Direct Java-to-Firebase integration (no intermediate service)  
✅ Device token management  
✅ Single and multicast notifications  
✅ Notification logging and tracking  
✅ Read/unread status tracking  
✅ User-specific notification delivery  

---

## 🏗️ Architecture

### Direct Integration Flow

```
┌─────────────────────┐
│  Flutter Mobile App │
└──────────┬──────────┘
           │ 1. Initialize Firebase
           │ 2. Get FCM Token
           │ 3. Register Token
           │
           ↓
┌──────────────────────────────┐
│  Java Backend (Port 8080)    │
│ ┌────────────────────────┐   │
│ │ FirebaseConfig         │   │
│ ├────────────────────────┤   │
│ │ • Initialize Firebase  │   │
│ │ • Load credentials     │   │
│ └────────────────────────┘   │
│ ┌────────────────────────┐   │
│ │ DeviceTokenService     │   │
│ ├────────────────────────┤   │
│ │ • Save token           │   │
│ │ • Retrieve user tokens │   │
│ └────────────────────────┘   │
│ ┌────────────────────────┐   │
│ │ NotificationService    │   │
│ ├────────────────────────┤   │
│ │ • Send notification    │   │
│ │ • Send multicast       │   │
│ │ • Log activity         │   │
│ └────────────────────────┘   │
│ ┌────────────────────────┐   │
│ │ Firebase API (Direct)  │   │
│ ├────────────────────────┤   │
│ │ • FirebaseMessaging    │   │
│ │ • Message.builder()    │   │
│ │ • send()               │   │
│ └────────────────────────┘   │
└──────────┬───────────────────┘
           │ 4. Send Message
           │ (Firebase Admin SDK)
           │
           ↓
┌──────────────────────┐
│  Firebase (FCM)      │
│  Cloud Messaging     │
└──────────┬───────────┘
           │ 5. Deliver Notification
           │
           ↓
┌──────────────────────┐
│  User's Device       │
│  (Notification Bar)  │
└──────────────────────┘
```

---

## 🛠️ Java Backend Implementation

### 1. Firebase Configuration

**File**: `Backend/src/main/java/.../config/FireBaseConfig.java`

Initializes Firebase Admin SDK at application startup.

```java
package com.spring.boot.graduationproject1.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;
import java.io.InputStream;

@Configuration
public class FireBaseConfig {
    
    @PostConstruct
    public void init() throws Exception {
        // Load Firebase credentials from classpath resources
        InputStream serviceAccount = getClass()
            .getClassLoader()
            .getResourceAsStream("firebase-key.json");
        
        if (serviceAccount == null) {
            throw new RuntimeException(
                "firebase-key.json not found in Backend/src/main/resources/"
            );
        }

        // Build Firebase options from credentials
        FirebaseOptions options = FirebaseOptions.builder()
            .setCredentials(GoogleCredentials.fromStream(serviceAccount))
            .build();

        // Initialize Firebase (singleton pattern)
        if (FirebaseApp.getApps().isEmpty()) {
            FirebaseApp.initializeApp(options);
            System.out.println("✓ Firebase initialized successfully");
        }
    }
}
```

**Key Points:**
- Runs once at Spring Boot startup
- Loads `firebase-key.json` from resources folder
- Creates Firebase singleton instance

---

### 2. Device Token Entity & Repository

**Entity**: `Backend/src/main/java/.../model/DeviceToken.java`

```java
package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class DeviceToken {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    
    private String token;  // FCM device token
    
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;     // Associated user
}
```

**Repository**: `Backend/src/main/java/.../repo/DeviceTokenRepo.java`

```java
package com.spring.boot.graduationproject1.repo;

import com.spring.boot.graduationproject1.model.DeviceToken;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface DeviceTokenRepo extends JpaRepository<DeviceToken, Long> {
    // Find all tokens for a user
    List<DeviceToken> findByUserId(Long userId);
}
```

---

### 3. Device Token Service

**Interface**: `Backend/src/main/java/.../service/DeviceTokenService.java`

```java
package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.model.User;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public interface DeviceTokenService {
    void saveToken(User user, String token);
    List<String> getUserTokens(Long userId);
}
```

**Implementation**: `Backend/src/main/java/.../service/impl/DeviceTokenServiceImpl.java`

```java
package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.model.DeviceToken;
import com.spring.boot.graduationproject1.model.User;
import com.spring.boot.graduationproject1.repo.DeviceTokenRepo;
import com.spring.boot.graduationproject1.service.DeviceTokenService;
import org.springframework.context.annotation.Primary;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
@Primary
public class DeviceTokenServiceImpl implements DeviceTokenService {

    private final DeviceTokenRepo deviceTokenRepo;

    public DeviceTokenServiceImpl(DeviceTokenRepo deviceTokenRepo) {
        this.deviceTokenRepo = deviceTokenRepo;
    }

    @Override
    public void saveToken(User user, String token) {
        DeviceToken dt = new DeviceToken();
        dt.setUser(user);
        dt.setToken(token);
        deviceTokenRepo.save(dt);
        
        System.out.println("✓ Token saved for user: " + user.getId());
    }

    @Override
    public List<String> getUserTokens(Long userId) {
        return deviceTokenRepo.findByUserId(userId)
            .stream()
            .map(DeviceToken::getToken)
            .toList();
    }
}
```

---

### 4. Notification Log Entity

**Entity**: `Backend/src/main/java/.../model/NotificationLog.java`

```java
package com.spring.boot.graduationproject1.model;

import jakarta.persistence.*;
import lombok.Data;

@Entity
@Data
public class NotificationLog {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;
    
    private String title;
    private String body;
    private boolean readStatus;  // Track if user read notification
    
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
}
```

---

### 5. Notification Provider (Firebase Direct)

**Interface**: `Backend/src/main/java/.../notification/NotificationProvider.java`

```java
package com.spring.boot.graduationproject1.notification;

public interface NotificationProvider {
    void send(String token, String title, String body);
}
```

**Implementation**: `Backend/src/main/java/.../notification/FirebaseNotificationProvider.java`

```java
package com.spring.boot.graduationproject1.notification;

import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.stereotype.Service;

@Service
public class FirebaseNotificationProvider implements NotificationProvider {

    @Override
    public void send(String token, String title, String body) {
        try {
            // Build notification message
            Message message = Message.builder()
                .setToken(token)
                .setNotification(
                    Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build()
                )
                .build();

            // Send directly via Firebase Admin SDK
            String messageId = FirebaseMessaging
                .getInstance()
                .send(message);
            
            System.out.println("✓ Message sent. ID: " + messageId);
            
        } catch (Exception e) {
            System.err.println("✗ Failed to send: " + e.getMessage());
        }
    }
}
```

---

### 6. Notification Service (Main Logic)

**Interface**: `Backend/src/main/java/.../service/NotificationService.java`

```java
package com.spring.boot.graduationproject1.service;

import com.spring.boot.graduationproject1.model.User;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public interface NotificationService {
    void notifyUser(User user, String title, String body);
}
```

**Implementation**: `Backend/src/main/java/.../service/impl/NotificationServiceImpl.java`

```java
package com.spring.boot.graduationproject1.service.impl;

import com.spring.boot.graduationproject1.model.NotificationLog;
import com.spring.boot.graduationproject1.model.User;
import com.spring.boot.graduationproject1.notification.NotificationProvider;
import com.spring.boot.graduationproject1.repo.NotificationLogRepo;
import com.spring.boot.graduationproject1.service.DeviceTokenService;
import com.spring.boot.graduationproject1.service.NotificationService;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class NotificationServiceImpl implements NotificationService {

    private final NotificationLogRepo notificationLogRepo;
    private final DeviceTokenService deviceTokenService;
    private final NotificationProvider notificationProvider;

    public NotificationServiceImpl(
        NotificationLogRepo notificationLogRepo,
        DeviceTokenService deviceTokenService,
        NotificationProvider notificationProvider
    ) {
        this.notificationLogRepo = notificationLogRepo;
        this.deviceTokenService = deviceTokenService;
        this.notificationProvider = notificationProvider;
    }

    @Override
    public void notifyUser(User user, String title, String body) {
        // Get all device tokens for user
        List<String> tokens = deviceTokenService.getUserTokens(user.getId());

        // Send notification to each device
        for (String token : tokens) {
            notificationProvider.send(token, title, body);
        }

        // Log notification in database
        NotificationLog log = new NotificationLog();
        log.setUser(user);
        log.setTitle(title);
        log.setBody(body);
        log.setReadStatus(false);
        
        notificationLogRepo.save(log);
        
        System.out.println("✓ Notification logged for user: " + user.getId());
    }
}
```

---

## 🔐 Firebase Configuration

### Step 1: Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a new project" or select existing
3. Enable **Firebase Cloud Messaging (FCM)**

### Step 2: Generate Service Account Key
1. Navigate to **Project Settings** → **Service Accounts**
2. Click **"Generate New Private Key"**
3. Save JSON file as `firebase-key.json`

### Step 3: Place Key in Backend Resources

```
Backend/
├── src/
│   └── main/
│       └── resources/
│           ├── application.properties
│           └── firebase-key.json  ← PLACE HERE
└── pom.xml
```

### Step 4: Add Maven Dependencies

**File**: `Backend/pom.xml`

```xml
<!-- Firebase Admin SDK -->
<dependency>
    <groupId>com.google.firebase</groupId>
    <artifactId>firebase-admin</artifactId>
    <version>9.2.0</version>
</dependency>

<!-- Google Auth Library -->
<dependency>
    <groupId>com.google.auth</groupId>
    <artifactId>google-auth-library-oauth2-http</artifactId>
    <version>1.11.0</version>
</dependency>
```

### Step 5: Update application.properties

**File**: `Backend/src/main/resources/application.properties`

```properties
spring.application.name=GraduationProject1

# Database Configuration
spring.datasource.driver-class-name=oracle.jdbc.driver.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@localhost:1521/orclpdb
spring.datasource.username=hr
spring.datasource.password=hr

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Security
token.secret=sdakndbsafbj,sfuhih322jijdns@dfonidsfionwbfsajfbajsf
token.time=31622400000
```

**Note:** The Firebase configuration is automatically loaded from `firebase-key.json` by `FireBaseConfig.java`

---

## 🔄 Integration Flow

### Step-by-Step Workflow

```
1. FLUTTER APP STARTUP
   ├─ Initialize Firebase
   ├─ Request FCM Token
   │  └─ Token: "abc123xyz..."
   └─ Send token to Java Backend
   
2. REGISTER DEVICE TOKEN
   POST /api/auth/register-device
   {
       "deviceToken": "abc123xyz...",
       "deviceType": "MOBILE"
   }
   ├─ Validates JWT token
   ├─ Creates DeviceToken record
   └─ Saves in DEVICE_TOKENS table

3. BACKEND INITIATES NOTIFICATION
   ├─ Internal trigger (appointment, message, etc.)
   ├─ Calls NotificationService.notifyUser(user, title, body)
   └─ Service retrieves all user's device tokens

4. SERVICE RETRIEVES TOKENS
   ├─ Query DeviceTokenRepo.findByUserId(userId)
   └─ Returns List<String> of FCM tokens

5. SEND VIA FIREBASE
   ├─ For each token:
   │  ├─ Create Message object
   │  ├─ Set notification (title, body)
   │  ├─ Call FirebaseMessaging.getInstance().send()
   │  └─ Firebase returns messageId
   │
   └─ Firebase Admin SDK sends directly to FCM

6. FIREBASE CLOUD MESSAGING
   ├─ Receives message
   ├─ Routes to appropriate FCM servers
   └─ Delivers to device

7. FLUTTER RECEIVES
   ├─ FCM service receives message
   ├─ onMessage callback triggered (if app in foreground)
   ├─ onMessageOpenedApp callback (if app opened from notification)
   └─ Display notification to user

8. LOG IN DATABASE
   ├─ Create NotificationLog entry
   ├─ Store title, body, user_id
   ├─ Set readStatus = false
   └─ Save to NOTIFICATION_LOGS table
```

### Data Flow Diagram

```
┌──────────────────────┐
│  Flutter App         │
│  (Device Token)      │
└──────────┬───────────┘
           │ POST /api/auth/register-device
           │ {"deviceToken": "..."}
           │
           ↓
┌──────────────────────┐
│  AuthController      │
│  + register-device   │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│  DeviceTokenService  │
│  saveToken()         │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│  DeviceTokenRepo     │
│  save(token)         │
└──────────┬───────────┘
           │
           ↓
    [DATABASE SAVE]
           │
           ↓
    [INTERNAL EVENT]
    e.g., Appointment
    scheduled, message
    received, etc.
           │
           ↓
┌──────────────────────┐
│  NotificationService │
│  notifyUser()        │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│  DeviceTokenService  │
│  getUserTokens()     │
└──────────┬───────────┘
           │ Returns: ["token1", "token2", ...]
           │
           ↓
┌──────────────────────┐
│  FirebaseNotifProv   │
│  send(token)         │
└──────────┬───────────┘
           │
           ↓
┌──────────────────────┐
│  Firebase Admin SDK  │
│  FirebaseMessaging   │
│  .getInstance()      │
│  .send(message)      │
└──────────┬───────────┘
           │
           ↓
    [FIREBASE FCM API]
           │
           ↓
┌──────────────────────┐
│  User's Device       │
│  FCM Service         │
└──────────┬───────────┘
           │
           ↓
    [NOTIFICATION DISPLAY]
    Title: "..."
    Body: "..."
           │
           ↓
┌──────────────────────┐
│  NotificationLogRepo │
│  save(log)           │
└──────────┬───────────┘
           │
           ↓
    [DATABASE RECORD]
```

---

## 📱 Flutter Implementation Guide

### 1. Project Setup

**pubspec.yaml**

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^15.1.0
  http: ^1.1.0
  shared_preferences: ^2.2.0

dev_dependencies:
  flutter_test:
    sdk: flutter
```

Install packages:
```bash
flutter pub get
```

---

### 2. Firebase Configuration

Generate Firebase options file:
```bash
flutterfire configure
```

This creates `lib/firebase_options.dart` with your Firebase project config.

---

### 3. Initialize Firebase and Notifications

**lib/main.dart**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

// Top-level function to handle background notifications
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  print('Handling background message: ${message.messageId}');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  // Initialize notification service
  await NotificationService.initialize();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
      navigatorObservers: [NotificationService.navigatorObserver],
    );
  }
}
```

---

### 4. Notification Service

**lib/services/notification_service.dart**

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/notification_model.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  
  // Navigation observer for deep linking
  static final navigatorObserver = NavigatorObserver();
  
  static Future<void> initialize() async {
    // Request notification permissions
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carryForward: true,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    
    print('User granted notification permission: ${settings.authorizationStatus}');
    
    // Get FCM token
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
    
    // Register token with backend
    if (token != null) {
      await _registerTokenWithBackend(token);
    }
    
    // Setup message handlers
    _setupMessageHandlers();
    
    // Listen for token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('FCM Token refreshed: $newToken');
      _registerTokenWithBackend(newToken);
    });
  }
  
  // Register device token with Java backend
  static Future<void> _registerTokenWithBackend(String token) async {
    try {
      // Get JWT token (from local storage or auth provider)
      String? jwtToken = await ApiService.getJWTToken();
      
      if (jwtToken == null) {
        print('JWT token not available, retrying in 5 seconds...');
        await Future.delayed(const Duration(seconds: 5));
        String? retryToken = await ApiService.getJWTToken();
        if (retryToken != null) {
          await _registerTokenWithBackend(token);
        }
        return;
      }
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/api/auth/register-device'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'deviceToken': token,
          'deviceType': 'MOBILE',
          'os': _getOS(),
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('✓ Device token registered with backend');
        await _saveTokenLocally(token);
      } else if (response.statusCode == 401) {
        print('Unauthorized - JWT expired, refresh and retry');
        await ApiService.refreshJWT();
        await _registerTokenWithBackend(token);
      } else {
        print('✗ Failed to register token: ${response.body}');
      }
    } catch (e) {
      print('✗ Error registering token: $e');
    }
  }
  
  // Setup message handlers for different app states
  static void _setupMessageHandlers() {
    // Foreground: App is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('=== FOREGROUND MESSAGE ===');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      
      // Show local notification or overlay
      _handleForegroundNotification(message);
    });
    
    // Background: User taps notification when app was closed/background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('=== MESSAGE OPENED ===');
      print('User tapped notification');
      
      // Navigate to relevant screen
      _handleNotificationTap(message);
    });
  }
  
  // Handle foreground notification
  static void _handleForegroundNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    final data = message.data;
    
    // Show overlay or dialog
    _showNotificationOverlay(title, body);
    
    // Save to local database or state
    _saveNotificationLocally(
      NotificationModel(
        title: title,
        body: body,
        data: data,
        receivedAt: DateTime.now(),
        isRead: false,
      ),
    );
  }
  
  // Handle notification tap
  static void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    
    // Route based on notification type
    if (data.containsKey('appointmentId')) {
      final appointmentId = data['appointmentId']!;
      _navigateToAppointment(appointmentId);
    } else if (data.containsKey('messageId')) {
      final messageId = data['messageId']!;
      _navigateToChat(messageId);
    } else if (data.containsKey('type')) {
      final type = data['type']!;
      _handleNavigationByType(type, data);
    }
    
    // Mark as read in backend
    if (message.data.containsKey('notificationLogId')) {
      final logId = data['notificationLogId']!;
      _markAsReadInBackend(logId);
    }
  }
  
  // Show notification in foreground
  static void _showNotificationOverlay(String title, String body) {
    // Implementation: Show snackbar, dialog, or custom notification UI
    // This would use a global navigator key or notification stream
  }
  
  // Navigation methods
  static void _navigateToAppointment(String appointmentId) {
    // Implementation: Navigate to appointment detail screen
    // Example: navigatorObserver.context?.push(AppointmentDetailRoute(id: appointmentId))
  }
  
  static void _navigateToChat(String messageId) {
    // Implementation: Navigate to chat screen
  }
  
  static void _handleNavigationByType(String type, Map<String, dynamic> data) {
    // Handle other notification types
  }
  
  // Mark notification as read
  static Future<void> _markAsReadInBackend(String logId) async {
    try {
      final jwtToken = await ApiService.getJWTToken();
      
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/api/notifications/logs/$logId/read'),
        headers: {
          'Authorization': 'Bearer $jwtToken',
        },
      );
      
      if (response.statusCode == 200) {
        print('✓ Notification marked as read');
      }
    } catch (e) {
      print('✗ Error marking as read: $e');
    }
  }
  
  // Save notification locally
  static Future<void> _saveNotificationLocally(NotificationModel notification) async {
    // Save to SQLite or shared preferences
    // This allows offline access to notifications
  }
  
  // Save token locally
  static Future<void> _saveTokenLocally(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }
  
  // Get OS type
  static String _getOS() {
    return Theme.of(navigatorObserver.context!).platform == TargetPlatform.iOS
        ? 'IOS'
        : 'ANDROID';
  }
  
  // Public method to get current token
  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }
}
```

---

### 5. API Service

**lib/services/api_service.dart**

```dart
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.1.100:8080';
  static const String _jwtTokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Get stored JWT token
  static Future<String?> getJWTToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_jwtTokenKey);
  }
  
  // Save JWT token
  static Future<void> saveJWTToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_jwtTokenKey, token);
  }
  
  // Refresh JWT token
  static Future<bool> refreshJWT() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(_refreshTokenKey);
      
      if (refreshToken == null) return false;
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await saveJWTToken(data['token']);
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing JWT: $e');
      return false;
    }
  }
  
  // Send notification to backend (for testing)
  static Future<bool> sendTestNotification({
    required int userId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      final token = await getJWTToken();
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/notifications/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'userId': userId,
          'title': title,
          'body': body,
          'data': data ?? {},
        }),
      );
      
      if (response.statusCode == 200) {
        print('✓ Notification sent successfully');
        return true;
      } else {
        print('✗ Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('✗ Error sending notification: $e');
      return false;
    }
  }
  
  // Get notification logs
  static Future<List<NotificationModel>> getNotificationLogs(int userId) async {
    try {
      final token = await getJWTToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/notifications/logs?userId=$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((item) => NotificationModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching notification logs: $e');
      return [];
    }
  }
}
```

---

### 6. Notification Model

**lib/models/notification_model.dart**

```dart
import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int? id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  final bool isRead;
  final String? type; // appointment, message, reminder, etc.
  final String? relatedId; // appointment ID, message ID, etc.
  
  NotificationModel({
    this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    required this.isRead,
    this.type,
    this.relatedId,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}
```

Run: `flutter pub run build_runner build` to generate `notification_model.g.dart`

---

### 7. Notification Provider (State Management)

Using Provider pattern for state management:

**lib/providers/notification_provider.dart**

```dart
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;
  
  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;
  
  // Load notifications from backend
  Future<void> loadNotifications(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      _notifications = await ApiService.getNotificationLogs(userId);
      _updateUnreadCount();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Add new notification (when received)
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    _updateUnreadCount();
    notifyListeners();
  }
  
  // Mark as read
  Future<void> markAsRead(int notificationId) async {
    try {
      await ApiService.markNotificationAsRead(notificationId);
      
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          title: _notifications[index].title,
          body: _notifications[index].body,
          data: _notifications[index].data,
          receivedAt: _notifications[index].receivedAt,
          isRead: true,
        );
        _updateUnreadCount();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Delete notification
  void deleteNotification(int notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    _updateUnreadCount();
    notifyListeners();
  }
  
  // Clear all
  void clearAll() {
    _notifications.clear();
    _updateUnreadCount();
    notifyListeners();
  }
  
  // Update unread count
  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.isRead).length;
  }
}
```

---

### 8. UI Components

**lib/screens/notifications_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, _) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (notificationProvider.notifications.isEmpty) {
            return const Center(
              child: Text('No notifications'),
            );
          }
          
          return ListView.builder(
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              
              return NotificationTile(
                notification: notification,
                onTap: () => _handleNotificationTap(notification),
                onDismiss: () => notificationProvider
                    .deleteNotification(notification.id!),
              );
            },
          );
        },
      ),
    );
  }
  
  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    context.read<NotificationProvider>().markAsRead(notification.id!);
    
    // Navigate based on type
    if (notification.data.containsKey('appointmentId')) {
      Navigator.pushNamed(
        context,
        '/appointment-detail',
        arguments: notification.data['appointmentId'],
      );
    }
  }
}

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  
  const NotificationTile({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(notification.id),
      onDismissed: (_) => onDismiss(),
      child: ListTile(
        onTap: onTap,
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(notification.body),
        trailing: !notification.isRead
            ? Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              )
            : null,
      ),
    );
  }
}
```

---

### 9. Deep Linking (Optional)

**lib/services/deep_link_service.dart**

```dart
import 'package:uni_links/uni_links.dart';

class DeepLinkService {
  static Future<void> initDeepLinks() async {
    deepLinkStream.listen(
      (String? link) {
        if (link != null) {
          _handleDeepLink(link);
        }
      },
      onError: (err) {
        print('Deep link error: $err');
      },
    );
  }
  
  static void _handleDeepLink(String link) {
    final uri = Uri.parse(link);
    
    // Example: thoutha://appointment/123
    if (uri.host == 'appointment') {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      if (id != null) {
        _navigateToAppointment(id);
      }
    }
  }
  
  static void _navigateToAppointment(String id) {
    // Navigation implementation
  }
}
```

---

### 10. Error Handling & Retry Logic

**lib/services/notification_service.dart** (Addition)

```dart
class NotificationService {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 5);
  
  // Register with retry
  static Future<void> _registerTokenWithRetry(
    String token,
    int attemptCount = 0,
  ) async {
    try {
      await _registerTokenWithBackend(token);
    } catch (e) {
      if (attemptCount < maxRetries) {
        print('Retry registration (${attemptCount + 1}/$maxRetries)');
        await Future.delayed(retryDelay);
        await _registerTokenWithRetry(token, attemptCount + 1);
      } else {
        print('✗ Failed to register token after $maxRetries attempts');
      }
    }
  }
}
```

---

### 11. Testing Notifications

**lib/screens/test_notifications_screen.dart**

```dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TestNotificationsScreen extends StatefulWidget {
  const TestNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<TestNotificationsScreen> createState() =>
      _TestNotificationsScreenState();
}

class _TestNotificationsScreenState extends State<TestNotificationsScreen> {
  final TextEditingController titleController =
      TextEditingController(text: 'Test Title');
  final TextEditingController bodyController =
      TextEditingController(text: 'Test Body');
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test Notifications')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isLoading ? null : _sendTestNotification,
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send Test Notification'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendTestNotification() async {
    setState(() => isLoading = true);
    
    final success = await ApiService.sendTestNotification(
      userId: 1, // Replace with actual user ID
      title: titleController.text,
      body: bodyController.text,
    );
    
    setState(() => isLoading = false);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Notification sent!' : 'Failed to send notification',
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}
```

---

## 🧪 Testing Procedures

### Test Case 1: Device Token Registration

#### Objective
Verify that Flutter app can successfully get FCM token and register it with Java backend.

#### Steps
1. **Run Flutter App**
   ```bash
   flutter run
   ```

2. **Monitor Console**
   - Check FCM token is printed
   - Expected output: `✓ FCM Token obtained: eZN2zG...`

3. **Backend Register Endpoint**
   ```bash
   curl -X POST http://localhost:8080/api/auth/register-device \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -d '{
       "deviceToken": "abc123xyz...",
       "deviceType": "MOBILE"
     }'
   ```

4. **Verify in Database**
   ```sql
   SELECT * FROM DEVICE_TOKEN WHERE USER_ID = 1;
   ```

#### Success Criteria
✅ FCM token is generated  
✅ Token registered via endpoint  
✅ Token exists in database  

---

### Test Case 2: Send Single Notification

#### Objective
Verify notification is sent and received by Flutter app.

#### Steps

1. **Start Java Backend**
   ```bash
   cd Backend && mvn spring-boot:run
   ```

2. **Ensure Firebase Credentials**
   - Verify `Backend/src/main/resources/firebase-key.json` exists
   - Check backend logs for: `✓ Firebase initialized successfully`

3. **Send Notification via Code**
   ```java
   @Autowired
   private NotificationService notificationService;
   
   @PostMapping("/send-test")
   public void sendTest(@PathVariable Long userId) {
       User user = userService.getUser(userId);
       notificationService.notifyUser(
           user,
           "Test Notification",
           "This is a test message"
       );
   }
   ```

4. **Monitor Flutter Console**
   - Expected output:
     ```
     Foreground message received:
     Title: Test Notification
     Body: This is a test message
     ```

5. **Verify Database Log**
   ```sql
   SELECT * FROM NOTIFICATION_LOG WHERE USER_ID = 1 ORDER BY ID DESC LIMIT 1;
   ```

#### Success Criteria
✅ Message sent without errors  
✅ FCM delivers to device  
✅ Flutter receives and logs  
✅ Database records notification  

---

### Test Case 3: Multiple Tokens for Same User

#### Objective
Verify that notifications are sent to ALL device tokens for a user.

#### Steps

1. **Register Multiple Devices**
   ```bash
   # Device 1 (Android)
   curl -X POST http://localhost:8080/api/auth/register-device \
     -H "Authorization: Bearer TOKEN" \
     -d '{"deviceToken": "android_token_123", "deviceType": "MOBILE"}'
   
   # Device 2 (iOS)
   curl -X POST http://localhost:8080/api/auth/register-device \
     -H "Authorization: Bearer TOKEN" \
     -d '{"deviceToken": "ios_token_456", "deviceType": "MOBILE"}'
   ```

2. **Verify in Database**
   ```sql
   SELECT token FROM DEVICE_TOKEN WHERE USER_ID = 1;
   -- Should return 2 rows
   ```

3. **Send Notification**
   ```bash
   curl -X POST http://localhost:8080/api/send-to-user/1 \
     -H "Authorization: Bearer TOKEN" \
     -d '{"title": "Multi-Device Test", "body": "Check both devices"}'
   ```

4. **Monitor Both Devices**
   - Both Android and iOS should receive
   - Timestamps should be similar

#### Success Criteria
✅ Multiple tokens stored  
✅ Notification sent to ALL tokens  
✅ Both devices receive message  

---

### Test Case 4: Notification Content

#### Objective
Verify that notification title and body are correctly delivered.

#### Steps

1. **Send Detailed Notification**
   ```bash
   curl -X POST http://localhost:8080/api/send-test \
     -H "Authorization: Bearer TOKEN" \
     -d '{
       "userId": 1,
       "title": "Appointment Reminder",
       "body": "Your appointment with Dr. Ahmed is at 2:00 PM"
     }'
   ```

2. **Check Flutter Logs**
   ```
   Title: Appointment Reminder
   Body: Your appointment with Dr. Ahmed is at 2:00 PM
   ```

3. **Check Device Notification**
   - Swipe down to view notifications
   - Verify exact title and body appear

#### Success Criteria
✅ Title and body delivered correctly  
✅ Special characters handled properly  
✅ Long text not truncated unexpectedly  

---

### Test Case 5: Data Payload Handling

#### Objective
Verify custom data is included in notification.

#### Steps

1. **Send with Data Payload**
   ```java
   // Modify NotificationService to support data
   public void notifyUserWithData(User user, String title, String body,
                                   Map<String, String> data) {
       // Get tokens and send with data
   }
   ```

2. **Send from Flutter**
   ```dart
   final data = {
     'appointmentId': '12345',
     'doctorName': 'Dr. Ahmed',
     'clinicName': 'Clinic A'
   };
   ```

3. **Verify Data Reception**
   ```dart
   FirebaseMessaging.onMessage.listen((message) {
       final appointmentId = message.data['appointmentId'];
       print('Appointment: $appointmentId');
   });
   ```

#### Success Criteria
✅ Custom data received in payload  
✅ All fields accessible  
✅ No data corruption  

---

### Test Case 6: Error Handling - Invalid Token

#### Objective
Verify system handles invalid/expired tokens gracefully.

#### Steps

1. **Send with Invalid Token**
   ```bash
   curl -X POST http://localhost:9000/api/notify/send \
     -H "X-API-Key: key" \
     -d '{
       "token": "invalid_token_xyz",
       "title": "Test",
       "body": "Test"
     }'
   ```

2. **Expected Response**
   ```json
   {
     "success": false,
     "message": "Invalid device token"
   }
   ```

3. **Verify Backend Logging**
   - Check that error is logged
   - Notification NOT marked as successful

#### Success Criteria
✅ Invalid token returns error  
✅ Error details provided  
✅ Database marks as failed  

---

## 📊 API Endpoints

### Device Token Management

**Register Device Token**
```http
POST /api/auth/register-device
Authorization: Bearer JWT_TOKEN
Content-Type: application/json

{
  "deviceToken": "fcm_token_here",
  "deviceType": "MOBILE"
}

Response 200:
{
  "success": true,
  "message": "Device registered"
}
```

**Get User's Tokens** (Debug)
```http
GET /api/device-tokens/user/{userId}
Authorization: Bearer JWT_TOKEN

Response:
{
  "tokens": [
    "token_1",
    "token_2"
  ]
}
```

### Notification Sending

**Send Notification to User**
```http
POST /api/notifications/send
Authorization: Bearer JWT_TOKEN
Content-Type: application/json

{
  "userId": 1,
  "title": "Notification Title",
  "body": "Notification body text"
}

Response 200:
{
  "success": true,
  "message": "Notification sent",
  "logId": 123
}
```

**Get Notification Logs**
```http
GET /api/notifications/logs?userId=1
Authorization: Bearer JWT_TOKEN

Response:
[
  {
    "id": 1,
    "title": "Appointment Reminder",
    "body": "Your appointment is at 2 PM",
    "readStatus": false,
    "createdAt": "2024-04-03T10:30:00"
  }
]
```

**Mark Notification as Read**
```http
PUT /api/notifications/logs/{logId}/read
Authorization: Bearer JWT_TOKEN

Response 200:
{
  "success": true,
  "message": "Marked as read"
}
```

3. **Monitor All Devices**
   - Both devices should receive notifications
   - Check timestamps are approximately same

4. **Verify Response**
   ```json
   {
     "success": true,
     "successCount": 2,
     "failureCount": 0,
     "messageId": "xyz789"
   }
   ```

#### Success Criteria
✅ All devices receive notification  
✅ Success count = number of recipients  
✅ Delivery within 2 seconds  

---

### Test Case 4: Topic-Based Messaging

#### Objective
Verify users can subscribe to topics and receive topic notifications.

#### Steps

1. **Subscribe to Topic** (in Flutter)
   ```dart
   await FirebaseMessaging.instance.subscribeToTopic('appointments');
   ```

2. **Backend Subscribe User**
   ```bash
   curl -X POST http://localhost:8080/api/notifications/subscribe-topic \
     -H "Content-Type: application/json" \
     -d '{
       "tokens": ["token_1", "token_2"],
       "topic": "appointments"
     }'
   ```

3. **Send Topic Notification**
   ```bash
   curl -X POST http://localhost:8080/api/notifications/send-to-topic \
     -H "Content-Type: application/json" \
     -d '{
       "topic": "appointments",
       "title": "System Announcement",
       "body": "Maintenance scheduled for tonight"
     }'
   ```

4. **Verify Devices Receive**
   - All subscribed devices should receive
   - Non-subscribed devices should NOT receive

#### Success Criteria
✅ Subscribe/unsubscribe works  
✅ Topic devices receive notification  
✅ Non-topic devices don't receive  

---

### Test Case 5: Notification with Custom Data

#### Objective
Verify notification with custom data payload is received and processed correctly.

#### Steps

1. **Send Notification with Data**
   ```bash
   curl -X POST http://localhost:9000/api/notify/send \
     -H "Content-Type: application/json" \
     -H "X-API-Key: thoutha-notification-service-key-2024" \
     -d '{
       "token": "device_token",
       "title": "Appointment Reminder",
       "body": "Dr. Ahmed - 2:00 PM",
       "data": {
         "appointmentId": "12345",
         "doctorId": "doc_123",
         "time": "14:00",
         "clinic": "Clinic A"
       }
     }'
   ```

2. **Handle in Flutter**
   ```dart
   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     final appointmentId = message.data['appointmentId'];
     final doctorId = message.data['doctorId'];
     final time = message.data['time'];
     
     // Process and navigate
     navigateToAppointmentDetail(appointmentId);
   });
   ```

3. **Verify Data Processing**
   - Print data payload
   - Navigate to correct screen
   - Display appointment details

#### Success Criteria
✅ Data payload delivered correctly  
✅ All fields accessible in Flutter  
✅ App navigates based on data  

---

### Test Case 6: Error Handling

#### Objective
Verify system handles errors gracefully.

#### Test Scenarios

**Scenario A: Invalid Token**
```bash
curl -X POST http://localhost:9000/api/notify/send \
  -H "Content-Type: application/json" \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -d '{
    "token": "invalid_token_xyz",
    "title": "Test",
    "body": "Test"
  }'
```

Expected Response:
```json
{
  "success": false,
  "message": "Invalid device token",
  "errors": ["Unregistered device"]
}
```

**Scenario B: Missing API Key**
```bash
curl -X POST http://localhost:9000/api/notify/send \
  -d '{"token": "abc", "title": "Test", "body": "Test"}'
```

Expected Response: `401 Unauthorized`

**Scenario C: Service Unavailable**
- Stop Python notification service
- Try to send notification from backend
- Should get error response or timeout

Expected Behavior:
```json
{
  "success": false,
  "message": "Notification service unavailable",
  "retryAfter": 30
}
```

#### Success Criteria
✅ Invalid token returns proper error  
✅ Missing auth returns 401  
✅ Service down handled gracefully  
✅ User receives error message  

---

### Test Case 7: Notification Delivery Status

#### Objective
Verify delivery status is tracked and reported correctly.

#### Steps

1. **Send Notification**
   ```bash
   curl -X POST http://localhost:8080/api/notifications/send \
     -d '{ "userId": 1, "title": "Test", "body": "Test" }'
   ```

2. **Get Notification Status**
   ```bash
   curl -X GET http://localhost:8080/api/notifications/logs/status \
     -H "Authorization: Bearer YOUR_JWT_TOKEN"
   ```

3. **Verify Status Log**
   ```json
   {
     "id": 1,
     "title": "Test",
     "status": "DELIVERED",
     "messageId": "xyz789",
     "sentAt": "2024-04-03T10:30:00",
     "deliveredAt": "2024-04-03T10:30:02",
     "attempts": 1
   }
   ```

#### Success Criteria
✅ Status transitions: PENDING → DELIVERED  
✅ Timestamps recorded accurately  
✅ Delivery time < 5 seconds  

---

### Test Case 8: Batch Notification Performance

#### Objective
Verify system can handle batch notifications efficiently.

#### Steps

1. **Register 50 Devices**
   - Create test users
   - Register different tokens

2. **Send Batch Notification**
   ```bash
   curl -X POST http://localhost:8080/api/notifications/send-bulk \
     -d '{
       "userIds": [1, 2, 3, ..., 50],
       "title": "System Update",
       "body": "Please update your app"
     }'
   ```

3. **Monitor Performance**
   - Record start time
   - Record end time
   - Check all devices received

4. **Expected Performance**
   - Send time: < 5 seconds for 50 devices
   - Success rate: >= 99%
   - No duplicate messages

#### Success Criteria
✅ Batch completed quickly  
✅ All devices received  
✅ No duplicates  
✅ Proper logging  

---

## 🔍 Troubleshooting

### Issue 1: FCM Token Not Generated

**Symptoms**
```
E/Firebase: Firebase not initialized
```

**Solution**
```dart
// Ensure Firebase is initialized BEFORE using FCM
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Only then request token
  await FirebaseMessaging.instance.getToken();
  
  runApp(MyApp());
}
```

---

### Issue 2: Token Not Registering in Backend

**Symptoms**
- Device token is generated but not stored in database
- GET /api/device-tokens returns empty

**Solutions**

1. **Check Authorization**
   ```bash
   curl -X POST http://localhost:8080/api/auth/register-device \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{"deviceToken": "abc123"}'
   ```

2. **Verify Token Format**
   - FCM tokens are usually 160+ characters
   - Should be alphanumeric

3. **Check Database Connection**
   ```bash
   # Check application logs for connection errors
   mvn spring-boot:run
   ```

---

### Issue 3: Notification Not Delivered

**Symptoms**
- No notification appears on device
---

## 🔍 Troubleshooting

### Issue 1: Firebase Not Initialized

**Symptoms**
```
E/Firebase: Firebase configuration failed
Exception: firebase-key.json not found
```

**Solution**
1. Verify `firebase-key.json` exists in `Backend/src/main/resources/`
2. Check file name is exact (lowercase with hyphens)
3. Ensure file is valid JSON from Firebase Console
4. Restart Spring Boot application

```bash
# Check if file exists
ls -la Backend/src/main/resources/firebase-key.json

# Check if valid JSON
cat Backend/src/main/resources/firebase-key.json | jq
```

---

### Issue 2: FCM Token Not Generated

**Symptoms**
```
E/Firebase: Firebase not initialized (Flutter)
```

**Solution**
```dart
// Ensure Firebase is initialized FIRST
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase BEFORE requesting token
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Only THEN request token
  final token = await FirebaseMessaging.instance.getToken();
  print('Token: $token');
  
  runApp(MyApp());
}
```

---

### Issue 3: Token Not Registered in Backend

**Symptoms**
- FCM token generated but not in database
- `GET /api/device-tokens/user/1` returns empty

**Checklist**
1. **Verify JWT Token**
   ```bash
   curl -X POST http://localhost:8080/api/auth/register-device \
     -H "Authorization: Bearer JWT_TOKEN_HERE" \
     -H "Content-Type: application/json" \
     -d '{"deviceToken": "test_token_123"}'
   ```

2. **Check User Exists**
   ```sql
   SELECT * FROM USERS WHERE ID = 1;
   ```

3. **Verify Table Exists**
   ```sql
   DESC DEVICE_TOKEN;
   ```

4. **Check Backend Logs**
   ```bash
   mvn spring-boot:run 2>&1 | grep -i "token\|error"
   ```

---

### Issue 4: Notification Not Delivered

**Symptoms**
- Notification appears to send but doesn't arrive on device
- No errors in backend logs

**Debugging Steps**

1. **Verify Firebase Admin SDK**
   ```java
   @GetMapping("/test-firebase")
   public ResponseEntity<?> testFirebase() {
       try {
           FirebaseApp app = FirebaseApp.getInstance();
           return ResponseEntity.ok("Firebase initialized: " + app.getName());
       } catch (Exception e) {
           return ResponseEntity.status(500).body("Error: " + e.getMessage());
       }
   }
   ```

2. **Check Device Token Validity**
   - Tokens expire after ~30 days of inactivity
   - Refresh tokens periodically from Flutter
   - Clean up old tokens regularly

3. **Verify Notification Sent**
   ```sql
   SELECT * FROM NOTIFICATION_LOG WHERE USER_ID = 1 ORDER BY ID DESC LIMIT 5;
   ```

4. **Check Firebase Console**
   - Go to Firebase Console → Cloud Messaging
   - Check for failed deliveries
   - Verify credentials haven't expired

5. **Device Permissions (Android)**
   ```xml
   <!-- AndroidManifest.xml -->
   <uses-permission android:name="android.permission.INTERNET" />
   <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
   ```

6. **Device Permissions (iOS)**
   ```swift
   // Ensure user grants notification permission
   UNUserNotificationCenter.current()
       .requestAuthorization(options: [.alert, .sound, .badge])
   ```

---

### Issue 5: Same Notification Sent Multiple Times

**Symptoms**
- User receives duplicate notifications
- Success rate shows multiple sends

**Solutions**

1. **Check Notification Service Logic**
   ```java
   // Ensure notification sent only once per user
   @Override
   public void notifyUser(User user, String title, String body) {
       List<String> tokens = deviceTokenService.getUserTokens(user.getId());
       
       // Loop through tokens - send once per token is OK
       for (String token : tokens) {
           notificationProvider.send(token, title, body);
       }
       
       // Log once per user
       NotificationLog log = new NotificationLog();
       log.setUser(user);
       log.setTitle(title);
       log.setBody(body);
       notificationLogRepo.save(log);  // Save ONCE
   }
   ```

2. **Check for Multiple Calls**
   - Verify endpoint isn't called twice
   - Check for scheduled tasks sending duplicates
   - Review API call logs

3. **Deduplicate by MessageId**
   - Firebase returns unique messageId
   - Store in database and check before logging

---

### Issue 6: Missing Notification Permissions

**Android**
```xml
<!-- AndroidManifest.xml -->
<manifest>
  <uses-permission android:name="android.permission.INTERNET" />
  <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
  
  <application>
    <!-- Request runtime permission in Activity -->
  </application>
</manifest>
```

**iOS**
```swift
// In AppDelegate.swift
import UserNotifications

func requestNotificationPermission() {
    UNUserNotificationCenter.current()
        .requestAuthorization(options: [.alert, .sound, .badge]) 
        { granted, error in
        if granted {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
}
```

---

### Issue 7: Token Retrieval Timeout

**Symptoms**
```
E/FCM: Timeout waiting for token
```

**Solution**
```dart
// Add timeout and retry
Future<String?> getFCMTokenWithRetry() async {
  int retries = 3;
  
  for (int i = 0; i < retries; i++) {
    try {
      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(Duration(seconds: 10));
      
      if (token != null) return token;
    } catch (e) {
      print('Attempt ${i + 1} failed: $e');
      await Future.delayed(Duration(seconds: 2));
    }
  }
  
  return null;
}
```

---

## 📋 Quick Debugging Checklist

```
SETUP
□ Firebase project created at console.firebase.google.com
□ firebase-key.json downloaded from Service Accounts
□ firebase-key.json placed in Backend/src/main/resources/
□ Firebase Admin SDK dependency in pom.xml
□ Spring Boot application starts without Firebase errors

FLUTTER APP
□ Firebase packages added to pubspec.yaml (firebase_core, firebase_messaging)
□ Firebase initialized in main.dart before runApp()
□ FCM token can be retrieved successfully
□ OnMessage handler registered
□ OnMessageOpenedApp handler registered

DEVICE TOKEN REGISTRATION
□ JWT token valid and not expired
□ POST /api/auth/register-device returns 200
□ Token visible in database: SELECT * FROM DEVICE_TOKEN
□ Token associated with correct user

NOTIFICATION SENDING
□ Java service method called: notificationService.notifyUser(user, title, body)
□ DeviceTokenService returns tokens for user
□ FirebaseMessaging.getInstance() succeeds
□ Firebase returns message ID without errors
□ Notification logged in database

DELIVERY
□ Firebase Console shows message sent
□ Flutter onMessage callback executed (if app in foreground)
□ Notification appears in notification panel
□ Custom data accessible in message.data
□ Database shows notification logged

TROUBLESHOOTING
□ Check Spring Boot logs: mvn spring-boot:run 2>&1 | grep -i error
□ Check Firebase Console for failed deliveries
□ Verify token not older than 30 days
□ Verify device not uninstalled/reinstalled
□ Check device notification settings enabled
```

---

## 📚 Resources

- [Firebase Admin SDK - Java](https://firebase.google.com/docs/admin/setup)
- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Documentation](https://firebase.flutter.dev/)
- [FCM Token Management Best Practices](https://firebase.google.com/docs/cloud-messaging/manage-tokens)

---

## 🔗 Related Files

- [Backend Code](../../Backend/src/main/java/com/spring/boot/graduationproject1/)
- [Flutter Sample](../../Thoutha-Website/)
- [Database Schema](../../Database/)

---

**Last Updated**: April 3, 2024  
**Status**: ✅ Production Ready  
**Java-Only Firebase Integration** - No Python Service Required

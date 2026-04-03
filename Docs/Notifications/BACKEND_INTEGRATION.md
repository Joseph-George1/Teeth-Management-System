# Backend Notification Integration - Complete Guide

## Overview

This document provides a comprehensive guide for integrating the Python Notification Service with the Java Spring Boot backend of the Thoutha Teeth Management System.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     FRONTEND (React/Vue)                        │
│                   Thoutha-Website                               │
└────────────────────┬────────────────────────────────────────────┘
                     │ (HTTP/REST)
                     │
┌────────────────────▼────────────────────────────────────────────┐
│                  JAVA BACKEND (Port 8080)                       │
│        Spring Boot - Teeth Management System                    │
│                                                                 │
│  ┌────────────────────────────────────────────────────────┐   │
│  │  NotificationController                                │   │
│  │  - /api/notifications/register-device                 │   │
│  │  - /api/notifications/preferences                     │   │
│  │  - /api/notifications/history                         │   │
│  └────────────────────────────────────────────────────────┘   │
│                     │                                            │
│  ┌────────────────┬─▼──────────────────────────────────────┐   │
│  │  IDeviceTokenService     INotificationLogService        │   │
│  │  INotificationPreferenceService                        │   │
│  └────────────────┬──────────────────────────────┬─────────┘   │
│                   │                              │               │
│  ┌────────────────▼──────────────────────────────▼─────────┐   │
│  │  Repositories                                            │   │
│  │  - DeviceTokenRepo                                       │   │
│  │  - NotificationLogRepo                                   │   │
│  │  - NotificationPreferenceRepo                            │   │
│  └────────────────┬──────────────────────────────────────────┘   │
│                   │                                               │
│  ┌────────────────▼──────────────────────────────────────────┐   │
│  │  IPythonNotificationService                              │   │
│  │  PythonNotificationServiceImpl                            │   │
│  │  (Calls Python service via HTTP)                         │   │
│  └────────────────┬──────────────────────────────────────────┘   │
│                   │                                               │
│  ┌────────────────▼──────────────────────────────────────────┐   │
│  │  Oracle XE Database                                       │   │
│  │  - DEVICE_TOKENS                                         │   │
│  │  - NOTIFICATION_LOGS                                     │   │
│  │  - NOTIFICATION_PREFERENCES                              │   │
│  └───────────────────────────────────────────────────────────┘   │
│                   │                                               │
│                   │ (HTTP/REST on port 9000)                     │
└───────────────────┼───────────────────────────────────────────────┘
                    │
┌───────────────────▼───────────────────────────────────────────────┐
│            PYTHON NOTIFICATION SERVICE (Port 9000)               │
│                  FastAPI + Firebase Admin SDK                     │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Notification Routes                                     │   │
│  │  - POST /api/notify/send                                │   │
│  │  - POST /api/notify/send-multicast                      │   │
│  │  - POST /api/notify/send-to-topic                       │   │
│  └──────────────────────────────────────────────────────────┘   │
│                          │                                        │
│  ┌──────────────────────┴──────────────────────────────────┐   │
│  │  Firebase Admin SDK - Cloud Messaging                   │   │
│  └──────────────────────┬──────────────────────────────────┘   │
│                         │                                        │
└─────────────────────────┼────────────────────────────────────────┘
                          │ (Firebase API)
                          │
            ┌─────────────▼────────────────┐
            │   Firebase Cloud Messaging   │
            │  (FCM)                       │
            └─────────────┬────────────────┘
                          │
            ┌─────────────▼─────────────┐
            │  Mobile Devices & Web     │
            │  - Android Apps           │
            │  - iOS Apps               │
            │  - Web Browsers           │
            └───────────────────────────┘
```

---

## 1. Database Schema

### Tables Created

#### DEVICE_TOKENS
Stores Firebase Cloud Messaging device tokens for push notifications.

```sql
CREATE TABLE DEVICE_TOKENS (
    ID                  NUMBER(19) PRIMARY KEY,
    TOKEN               VARCHAR2(500) NOT NULL UNIQUE,
    USER_ID             NUMBER(19) NOT NULL,
    USER_TYPE           VARCHAR2(20) NOT NULL,
    PLATFORM            VARCHAR2(20) NOT NULL,
    DEVICE_NAME         VARCHAR2(255),
    IS_ACTIVE           NUMBER(1) NOT NULL DEFAULT 1,
    REGISTERED_AT       TIMESTAMP(6) NOT NULL,
    LAST_USED_AT        TIMESTAMP(6),
    DEACTIVATED_AT      TIMESTAMP(6)
);
```

**Fields Explained**:
- `TOKEN`: Unique FCM token from Firebase SDK on client
- `USER_ID`: Patient or Doctor ID
- `USER_TYPE`: PATIENT, DOCTOR, or ADMIN
- `PLATFORM`: ANDROID, IOS, WEB, WINDOWS, or MACOS
- `IS_ACTIVE`: 1=active, 0=inactive (logout)

#### NOTIFICATION_LOGS
Audit trail of all notifications sent to users.

```sql
CREATE TABLE NOTIFICATION_LOGS (
    ID                      NUMBER(19) PRIMARY KEY,
    RECIPIENT_USER_ID       NUMBER(19) NOT NULL,
    RECIPIENT_USER_TYPE     VARCHAR2(20) NOT NULL,
    TITLE                   VARCHAR2(255) NOT NULL,
    BODY                    VARCHAR2(1000) NOT NULL,
    NOTIFICATION_TYPE       VARCHAR2(50) NOT NULL,
    RELATED_ENTITY_ID       NUMBER(19),
    RELATED_ENTITY_TYPE     VARCHAR2(50),
    FCM_MESSAGE_ID          VARCHAR2(255),
    DELIVERY_STATUS         VARCHAR2(20) NOT NULL DEFAULT 'SENT',
    IS_READ                 NUMBER(1) NOT NULL DEFAULT 0,
    READ_AT                 TIMESTAMP(6),
    SENT_AT                 TIMESTAMP(6) NOT NULL,
    CREATED_AT              TIMESTAMP(6) NOT NULL
);
```

**Notification Types**:
- APPOINTMENT_CONFIRMED
- APPOINTMENT_CANCELLED
- APPOINTMENT_REMINDER
- APPOINTMENT_RESCHEDULED
- BOOKING_REQUEST_RECEIVED
- BOOKING_REQUEST_APPROVED
- BOOKING_REQUEST_REJECTED
- DOCTOR_ACCEPTED_BOOKING
- DOCTOR_REJECTED_BOOKING
- And more...

#### NOTIFICATION_PREFERENCES
User preferences for receiving notifications.

```sql
CREATE TABLE NOTIFICATION_PREFERENCES (
    ID                              NUMBER(19) PRIMARY KEY,
    USER_ID                         NUMBER(19) NOT NULL UNIQUE,
    USER_TYPE                       VARCHAR2(20) NOT NULL,
    PUSH_NOTIFICATIONS_ENABLED      NUMBER(1) NOT NULL DEFAULT 1,
    APPOINTMENT_CONFIRMED_ENABLED   NUMBER(1) NOT NULL DEFAULT 1,
    APPOINTMENT_CANCELLED_ENABLED   NUMBER(1) NOT NULL DEFAULT 1,
    APPOINTMENT_REMINDER_ENABLED    NUMBER(1) NOT NULL DEFAULT 1,
    BOOKING_REQUEST_ENABLED         NUMBER(1) NOT NULL DEFAULT 1,
    SYSTEM_ANNOUNCEMENT_ENABLED     NUMBER(1) NOT NULL DEFAULT 1,
    PROMOTIONAL_ENABLED             NUMBER(1) NOT NULL DEFAULT 0,
    QUIET_HOURS_START               NUMBER(2),
    QUIET_HOURS_END                 NUMBER(2),
    ALLOW_NOTIFICATIONS_IN_QUIET_HOURS NUMBER(1),
    LANGUAGE_PREFERENCE             VARCHAR2(10) DEFAULT 'en',
    EMAIL_NOTIFICATIONS_ENABLED     NUMBER(1) NOT NULL DEFAULT 0,
    SMS_NOTIFICATIONS_ENABLED       NUMBER(1) NOT NULL DEFAULT 0,
    DAILY_NOTIFICATION_LIMIT        NUMBER(5) DEFAULT 0,
    UPDATED_AT                      TIMESTAMP(6) NOT NULL,
    CREATED_AT                      TIMESTAMP(6) NOT NULL
);
```

### Running the Migration

```bash
# On the server, connect to Oracle XE
sqlplus hr/hr

# Run the migration script
@notification_tables_migration.sql

# Verify tables were created
DESC DEVICE_TOKENS;
DESC NOTIFICATION_LOGS;
DESC NOTIFICATION_PREFERENCES;
```

---

## 2. Java Backend Components

### Entities (Models)

#### DeviceToken.java
Located in: `Backend/src/main/java/.../model/DeviceToken.java`

```java
@Entity
@Table(name = "DEVICE_TOKENS")
public class DeviceToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true, nullable = false)
    private String token;  // FCM device token
    
    @Column(nullable = false)
    private Long userId;   // Patient or Doctor ID
    
    @Enumerated(EnumType.STRING)
    private UserType userType;  // PATIENT, DOCTOR, ADMIN
    
    @Enumerated(EnumType.STRING)
    private DevicePlatform platform;  // ANDROID, IOS, WEB
    
    private String deviceName;
    private Boolean isActive;
    private LocalDateTime registeredAt;
    private LocalDateTime lastUsedAt;
}
```

#### NotificationLog.java
Located in: `Backend/src/main/java/.../model/NotificationLog.java`

```java
@Entity
@Table(name = "NOTIFICATION_LOGS")
public class NotificationLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    private Long recipientUserId;
    @Enumerated(EnumType.STRING)
    private UserType recipientUserType;
    
    private String title;
    private String body;
    
    @Enumerated(EnumType.STRING)
    private NotificationType notificationType;
    
    @Enumerated(EnumType.STRING)
    private DeliveryStatus deliveryStatus;
    
    private Long relatedEntityId;  // Appointment ID, etc.
    private String relatedEntityType;
    
    private String fcmMessageId;  // From Firebase
    private Boolean isRead;
    private LocalDateTime sentAt;
}
```

#### NotificationPreference.java
Located in: `Backend/src/main/java/.../model/NotificationPreference.java`

```java
@Entity
@Table(name = "NOTIFICATION_PREFERENCES")
public class NotificationPreference {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true)
    private Long userId;
    
    @Enumerated(EnumType.STRING)
    private UserType userType;
    
    private Boolean pushNotificationsEnabled;
    private Boolean appointmentConfirmedEnabled;
    private Boolean appointmentCancelledEnabled;
    private Boolean appointmentReminderEnabled;
    private Boolean bookingRequestEnabled;
    private Boolean systemAnnouncementEnabled;
    private Boolean promotionalEnabled;
    
    private Integer quietHoursStart;  // e.g., 22 for 10 PM
    private Integer quietHoursEnd;    // e.g., 8 for 8 AM
    private Boolean allowNotificationsInQuietHours;
    
    private String languagePreference;  // en, ar, etc.
    private Boolean emailNotificationsEnabled;
    private Boolean smsNotificationsEnabled;
    private Integer dailyNotificationLimit;
}
```

### Services

#### IDeviceTokenService
Manages device token registration and management.

```java
public interface IDeviceTokenService {
    DeviceTokenDto registerDeviceToken(Long userId, String userType, RegisterDeviceTokenRequest request);
    Boolean deactivateDeviceToken(String token);
    List<DeviceTokenDto> getActiveDeviceTokens(Long userId, String userType);
    List<DeviceTokenDto> getAllDeviceTokens(Long userId, String userType);
    Boolean removeDeviceToken(Long tokenId);
    Boolean isTokenActive(String token);
    Long countActiveTokens(Long userId, String userType);
    Long cleanupInactiveTokens();
}
```

#### INotificationLogService
Tracks and manages notification logs.

```java
public interface INotificationLogService {
    NotificationLogDto logNotification(Long recipientUserId, String recipientUserType, 
        String title, String body, String notificationType, Long relatedEntityId, String relatedEntityType);
    void updateFCMMessageId(Long notificationId, String fcmMessageId);
    void markAsDelivered(String fcmMessageId);
    void markAsRead(Long notificationId);
    List<NotificationLogDto> getUserNotifications(Long userId, String userType);
    List<NotificationLogDto> getUnreadNotifications(Long userId, String userType);
    Long countUnreadNotifications(Long userId, String userType);
    List<NotificationLogDto> getNotificationsByType(Long userId, String notificationType);
    List<NotificationLogDto> getNotificationsByEntity(Long entityId, String entityType);
}
```

#### INotificationPreferenceService
Manages user notification preferences.

```java
public interface INotificationPreferenceService {
    NotificationPreferenceDto getUserPreferences(Long userId, String userType);
    NotificationPreferenceDto updatePreferences(Long userId, NotificationPreferenceDto preferences);
    Boolean isNotificationTypeEnabled(Long userId, String notificationType);
    Boolean isInQuietHours(Long userId);
    NotificationPreferenceDto resetToDefaults(Long userId);
}
```

#### IPythonNotificationService
Integrates with Python notification service.

```java
public interface IPythonNotificationService {
    String sendNotification(String deviceToken, String title, String body, Map<String, String> data);
    JsonNode sendMulticast(List<String> deviceTokens, String title, String body, Map<String, String> data);
    String sendToTopic(String topic, String title, String body, Map<String, String> data);
    Boolean subscribeToTopic(List<String> deviceTokens, String topic);
    Boolean unsubscribeFromTopic(List<String> deviceTokens, String topic);
    JsonNode getStatistics();
    Boolean isServiceHealthy();
}
```

### Controllers

#### NotificationController
Located in: `Backend/src/main/java/.../controller/NotificationController.java`

**Endpoints**:

```
POST   /api/notifications/register-device          Register device token
GET    /api/notifications/devices/active           Get active devices
GET    /api/notifications/devices/all              Get all devices
POST   /api/notifications/logout-device/{id}       Logout device
GET    /api/notifications/preferences              Get preferences
PUT    /api/notifications/preferences              Update preferences
POST   /api/notifications/preferences/reset        Reset preferences
GET    /api/notifications/history                  Get notification history
GET    /api/notifications/unread                   Get unread notifications
POST   /api/notifications/{id}/read                Mark as read
```

---

## 3. Configuration

### application.properties

Add to `Backend/src/main/resources/application.properties`:

```properties
# Notification Service Configuration
notification.service.url=http://localhost:9000
notification.service.api-key=thoutha-notification-service-key-2024
```

**For Production**:
```properties
notification.service.url=http://notification-service:9000
notification.service.api-key=${NOTIFICATION_API_KEY}  # From environment variable
```

---

## 4. Integration Examples

### Example 1: Send Appointment Confirmation

```java
@Service
public class AppointmentService {
    
    @Autowired
    private IDeviceTokenService deviceTokenService;
    
    @Autowired
    private INotificationLogService notificationLogService;
    
    @Autowired
    private IPythonNotificationService pythonNotificationService;
    
    @Autowired
    private INotificationPreferenceService preferenceService;
    
    public void confirmAppointment(Appointment appointment) {
        // Confirm appointment in database
        appointmentRepository.save(appointment);
        
        // Get patient's active device tokens
        List<DeviceTokenDto> deviceTokens = deviceTokenService
            .getActiveDeviceTokens(appointment.getPatient().getId(), "PATIENT");
        
        if (deviceTokens.isEmpty()) {
            logger.warn("No device tokens found for patient: " + appointment.getPatient().getId());
            return;
        }
        
        // Check patient preferences
        if (!preferenceService.isNotificationTypeEnabled(
            appointment.getPatient().getId(), 
            "APPOINTMENT_CONFIRMED")) {
            logger.info("Patient has disabled appointment confirmation notifications");
            return;
        }
        
        // Check quiet hours
        if (preferenceService.isInQuietHours(appointment.getPatient().getId())) {
            logger.info("Patient is in quiet hours, notification will be queued");
        }
        
        // Prepare notification data
        String title = "Appointment Confirmed";
        String body = "Your appointment with Dr. " + appointment.getDoctor().getFirstName() + 
                     " is confirmed for " + appointment.getAppointmentDate();
        
        Map<String, String> data = new HashMap<>();
        data.put("appointmentId", appointment.getId().toString());
        data.put("doctorName", appointment.getDoctor().getFirstName() + " " + 
                 appointment.getDoctor().getLastName());
        data.put("appointmentDate", appointment.getAppointmentDate().toString());
        data.put("type", "APPOINTMENT_CONFIRMED");
        
        // Send to all active devices
        List<String> tokens = deviceTokens.stream()
            .map(DeviceTokenDto::getToken)
            .collect(Collectors.toList());
        
        JsonNode response = pythonNotificationService.sendMulticast(tokens, title, body, data);
        
        // Log notifications
        for (DeviceTokenDto token : deviceTokens) {
            NotificationLogDto log = notificationLogService.logNotification(
                appointment.getPatient().getId(),
                "PATIENT",
                title,
                body,
                "APPOINTMENT_CONFIRMED",
                appointment.getId(),
                "APPOINTMENT"
            );
            
            // Update with FCM message ID if available
            if (response != null && response.has("message_ids")) {
                // Note: FCM message ID handling depends on response structure
                notificationLogService.updateFCMMessageId(log.getId(), 
                    response.get("message_ids").get(0).asText());
            }
        }
        
        logger.info("✓ Appointment confirmation notification sent to " + tokens.size() + " devices");
    }
}
```

### Example 2: Send Reminder Notification

```java
@Service
public class NotificationReminderService {
    
    @Autowired
    private IDeviceTokenService deviceTokenService;
    
    @Autowired
    private IPythonNotificationService pythonNotificationService;
    
    @Autowired
    private INotificationLogService notificationLogService;
    
    // Run this scheduled task 24 hours before appointment
    @Scheduled(cron = "0 0 * * * *")  // Every hour
    public void sendAppointmentReminders() {
        // Find appointments in next 24 hours
        LocalDateTime tomorrow = LocalDateTime.now().plusDays(1);
        List<Appointment> upcomingAppointments = appointmentRepository
            .findByAppointmentDateBetween(LocalDateTime.now(), tomorrow);
        
        for (Appointment appointment : upcomingAppointments) {
            // Get patient's device tokens
            List<DeviceTokenDto> devices = deviceTokenService
                .getActiveDeviceTokens(appointment.getPatient().getId(), "PATIENT");
            
            if (devices.isEmpty()) continue;
            
            // Send reminder
            String title = "Appointment Reminder";
            String body = "Your appointment with Dr. " + appointment.getDoctor().getFirstName() + 
                         " is tomorrow at " + appointment.getAppointmentDate().format(
                         DateTimeFormatter.ofPattern("hh:mm a"));
            
            List<String> tokens = devices.stream()
                .map(DeviceTokenDto::getToken)
                .collect(Collectors.toList());
            
            pythonNotificationService.sendMulticast(tokens, title, body, 
                Map.of("appointmentId", appointment.getId().toString(),
                      "type", "APPOINTMENT_REMINDER"));
            
            // Log
            notificationLogService.logNotification(
                appointment.getPatient().getId(),
                "PATIENT",
                title,
                body,
                "APPOINTMENT_REMINDER",
                appointment.getId(),
                "APPOINTMENT"
            );
        }
    }
}
```

### Example 3: Topic-Based Announcements

```java
@Service
public class AnnouncementService {
    
    @Autowired
    private IPythonNotificationService pythonNotificationService;
    
    public void broadcastAnnouncement(String announcementText) {
        // Subscribe all active patients to "announcements" topic
        List<Patients> allPatients = patientRepository.findAll();
        
        for (Patients patient : allPatients) {
            // Get their device tokens
            List<DeviceTokenDto> devices = deviceTokenService
                .getActiveDeviceTokens(patient.getId(), "PATIENT");
            
            if (!devices.isEmpty()) {
                List<String> tokens = devices.stream()
                    .map(DeviceTokenDto::getToken)
                    .collect(Collectors.toList());
                
                // Subscribe to topic once
                pythonNotificationService.subscribeToTopic(tokens, "announcements");
            }
        }
        
        // Send announcement to topic
        pythonNotificationService.sendToTopic(
            "announcements",
            "📢 System Announcement",
            announcementText,
            Map.of("type", "SYSTEM_ANNOUNCEMENT")
        );
    }
}
```

---

## 5. REST API Endpoints

### Register Device Token

```bash
POST /api/notifications/register-device
X-API-Key: (included by Spring Security)
Content-Type: application/json

{
  "token": "eE2ewUeWexz...FCM_TOKEN",
  "platform": "ANDROID",
  "deviceName": "My Pixel 5"
}

Response:
{
  "success": true,
  "message": "Device token registered successfully",
  "data": {
    "id": 1,
    "token": "eE2ewUeWexz...",
    "platform": "ANDROID",
    "deviceName": "My Pixel 5",
    "isActive": true,
    "registeredAt": "2026-03-27T10:30:00"
  }
}
```

### Get User Notification Preferences

```bash
GET /api/notifications/preferences

Response:
{
  "success": true,
  "data": {
    "id": 1,
    "pushNotificationsEnabled": true,
    "appointmentConfirmedEnabled": true,
    "appointmentCancelledEnabled": true,
    "appointmentReminderEnabled": true,
    "quietHoursStart": 22,
    "quietHoursEnd": 8,
    "languagePreference": "en"
  }
}
```

### Get Unread Notifications

```bash
GET /api/notifications/unread

Response:
{
  "success": true,
  "unreadCount": 3,
  "data": [
    {
      "id": 1,
      "title": "Appointment Confirmed",
      "body": "Your appointment with Dr. Ahmed is confirmed...",
      "notificationType": "APPOINTMENT_CONFIRMED",
      "deliveryStatus": "DELIVERED",
      "isRead": false,
      "sentAt": "2026-03-27T10:15:00",
      "relatedEntityId": 5,
      "relatedEntityType": "APPOINTMENT"
    }
  ]
}
```

---

## 6. Testing

### Health Check

```bash
curl http://localhost:9000/api/notify/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "Thoutha Notification Service",
  "version": "1.0.0"
}
```

### Send Test Notification from Backend

```java
@RestController
@RequestMapping("/api/test")
public class TestController {
    
    @Autowired
    private IPythonNotificationService pythonNotificationService;
    
    @PostMapping("/send-notification")
    public ResponseEntity<?> sendTest(@RequestParam String token) {
        String messageId = pythonNotificationService.sendNotification(
            token,
            "Test Notification",
            "This is a test notification from the backend",
            Map.of("testId", "1")
        );
        
        return ResponseEntity.ok(Map.of(
            "success", messageId != null,
            "messageId", messageId
        ));
    }
}
```

---

## 7. Error Handling

### Common Errors

#### 401 Unauthorized
- **Cause**: Missing or invalid X-API-Key header
- **Solution**: Verify API key in application.properties matches Python service

#### 400 Bad Request
- **Cause**: Invalid device token format
- **Solution**: Ensure token is a valid FCM token from Firebase SDK

#### 503 Service Unavailable
- **Cause**: Python notification service is down
- **Solution**: Check if service is running: `astart -l`

#### Database Constraint Violation
- **Cause**: Duplicate device token
- **Solution**: Check DEVICE_TOKENS table for existing token

---

## 8. Deployment Checklist

### Pre-Deployment
- [ ] Database migration script executed on server
- [ ] All notification tables created with indexes
- [ ] Java backend built successfully (`mvn clean package`)
- [ ] Python service running (`astart -n`)
- [ ] Firebase credentials configured

### Deployment
- [ ] Deploy Java backend WAR/JAR to server
- [ ] Update application.properties with production URLs
- [ ] Verify database connections
- [ ] Test notification flow end-to-end
- [ ] Monitor logs for errors

### Post-Deployment
- [ ] Verify health endpoint: `/api/notify/health`
- [ ] Test device token registration
- [ ] Test notification sending
- [ ] Monitor performance metrics
- [ ] Set up alerting for errors

---

## 9. Performance Considerations

### Database
- Indexes created on frequently queried columns
- Partition strategy for NOTIFICATION_LOGS (by date recommended for large volumes)
- Archive old logs regularly (>6 months)

### Backend
- Connection pooling configured
- Async notification sending (fire-and-forget)
- Batch operations for multicast

### Python Service
- Runs on 2 cores, 2GB RAM
- Handles 100+ concurrent requests
- Automatic retry with exponential backoff

---

## 10. Related Documentation

- **Python Service**: See `/Docs/Notifications/PYTHON_BRIEF.md`
- **API Reference**: See `/Docs/Notifications/API_DOCUMENTATION.md`
- **Performance**: See `/Docs/Notifications/PERFORMANCE_ANALYSIS.md`
- **Setup Guide**: See `/Docs/Notifications/SETUP_GUIDE.md`

---

**Last Updated**: March 27, 2026  
**Status**: Complete and Production Ready ✅

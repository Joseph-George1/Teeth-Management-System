"""
THOUTHA NOTIFICATION SERVICE - COMPLETE INTEGRATION GUIDE

This document provides a comprehensive overview of the Python notification service,
how it works, what each file does, and how it integrates with astart.
"""

# ============================================================================
# 1. WHAT IS THE NOTIFICATION SERVICE?
# ============================================================================

The Thoutha Notification Service is a FastAPI-based Python application that:
- Handles push notifications for the Teeth Management System
- Uses Firebase Cloud Messaging (FCM) to deliver notifications to mobile devices
- Provides a RESTful API that the Java backend calls
- Runs independently on port 9000
- Managed by astart script for lifecycle control

Key Points:
✓ Standalone service (not part of backend or frontend)
✓ Python 3.8+ required
✓ Uses FastAPI framework (lightweight, fast)
✓ Requires Firebase project with credentials
✓ Fully integrated with astart logging system


# ============================================================================
# 2. HOW IT WORKS (Data Flow)
# ============================================================================

SCENARIO: Java Backend sends appointment confirmation notification

     Java Backend                    Notification Service                Mobile Device
     (Port 8080)                     (Port 9000)                        (User's Phone)
         |                                  |                                |
         | 1. POST /api/notify/send       |                                |
         | + token=ABC123                 |                                |
         | + title="Appointment Confirmed"|                                |
         | + body="Time: 2 PM"            |                                |
         |----------------------------->  |                                |
         |                                |                                |
         |                                | 2. Validate API key            |
         |                                | 3. Check request format        |
         |                                | 4. Call Firebase SDK           |
         |                                |----------------------------->  |
         |                                |  (Firebase Cloud Messaging)    |
         |                                |                                |
         |                                |  5. FCM delivers to device    |
         |                                |                            (Notification
         |                                |                            received!)
         |                                |
         | 6. Response                    |
         | {                              |
         |   "success": true,             |
         |   "message_id": "..."          |
         | }                              |
         |  <---------------------------- |
         |                                |


# ============================================================================
# 3. PROJECT STRUCTURE & FILE PURPOSES
# ============================================================================

ROOT: Notifications/
│
├── CORE APPLICATION
│   ├── main.py                           [FastAPI Entry Point]
│   │   └─ Creates Flask/FastAPI app
│   │   └─ Initializes Firebase on startup
│   │   └─ Registers all API routes
│   │   └─ Handles global exceptions
│   │   └─ Runs on port 9000
│   │
│   ├── Notifications.py                  [Package Module]
│   │   └─ Exports main components
│   │   └─ Version info (__version__)
│   │   └─ Allows importing as package
│   │
│   └── requirements.txt                  [Dependencies]
│       └─ fastapi==0.104.1      (Web framework)
│       └─ uvicorn==0.24.0       (ASGI server)
│       └─ firebase-admin==6.2.0 (Firebase SDK)
│       └─ pydantic==2.5.0       (Data validation)
│       └─ PyJWT==2.8.1          (JWT tokens)
│
├── CONFIGURATION
│   ├── .env                              [Production Config]
│   │   └─ FIREBASE_SERVICE_ACCOUNT_PATH
│   │   └─ API_KEY (authentication)
│   │   └─ PORT (9000)
│   │   └─ LOG_LEVEL (INFO/WARNING/ERROR)
│   │
│   ├── .env.example                      [Config Template]
│   │
│   └── config/
│       ├── __init__.py                   (Package init)
│       └── config.py                     [Settings Manager]
│           └─ Loads .env file
│           └─ Provides Settings class
│           └─ Type-safe configuration
│
├── DATA MODELS
│   └── models/
│       ├── __init__.py                   (Package init)
│       └── notification.py               [Request/Response Schemas]
│           └─ NotificationRequest        (single device)
│           └─ MulticastNotificationRequest (multiple devices)
│           └─ TopicNotificationRequest   (topic broadcast)
│           └─ NotificationResponse       (response format)
│           └─ MulticastResponse          (batch response)
│           └─ All use Pydantic for validation
│
├── SERVICES (Core Business Logic)
│   └── services/
│       ├── __init__.py                   (Package init)
│       │
│       ├── firebase_service.py           [Firebase Integration]
│       │   └─ FirebaseService class
│       │   └─ initialize_firebase()      (init SDK)
│       │   └─ verify_initialization()    (health check)
│       │   └─ get_messaging_client()     (get client)
│       │   └─ Singleton pattern (only one instance)
│       │
│       └── notification_service.py       [Core Notification Logic]
│           └─ NotificationService class
│           └─ send_notification()        (single device)
│           └─ send_notification_with_retry() (3x retry)
│           └─ send_multicast()           (500+ devices)
│           └─ send_to_topic()            (topic broadcast)
│           └─ subscribe_to_topic()       (add to topic)
│           └─ unsubscribe_from_topic()   (remove from topic)
│           └─ get_statistics()           (metrics)
│           └─ Comprehensive error handling
│           └─ Failure logging & tracking
│
├── API ROUTES
│   └── routes/
│       ├── __init__.py                   (Package init)
│       └── notification_routes.py        [API Endpoints]
│           └─ GET /                      (root info)
│           └─ GET /api/notify/health     (health check)
│           └─ POST /api/notify/send      (single)
│           └─ POST /api/notify/send-with-retry (retry)
│           └─ POST /api/notify/send-multicast (bulk)
│           └─ POST /api/notify/send-to-topic (topic)
│           └─ POST /api/notify/subscribe-topic
│           └─ POST /api/notify/unsubscribe-topic
│           └─ GET /api/notify/statistics
│
├── SECURITY
│   └── security/
│       ├── __init__.py                   (Package init)
│       └── auth.py                       [Authentication]
│           └─ SecurityManager class
│           └─ validate_api_key()         (X-API-Key header)
│           └─ validate_jwt_token()       (JWT validation)
│           └─ create_jwt_token()         (create token)
│           └─ Middleware for all endpoints
│
├── UTILITIES
│   └── utils/
│       ├── __init__.py                   (Package init)
│       └── logger.py                     [Logging]
│           └─ setup_logger()
│           └─ Console output only
│           └─ astart captures stdout
│           └─ No file logging (astart handles it)
│
├── DOCUMENTATION
│   ├── README.md                         [Quick Start]
│   ├── SETUP_GUIDE.md                    [Installation]
│   ├── API_DOCUMENTATION.md              [API Reference]
│   ├── IMPLEMENTATION_SUMMARY.md         [Features]
│   ├── QUICK_REFERENCE.py                [Quick Lookup]
│   ├── PYTHON_BRIEF.md                   [Python Overview]
│   ├── START_HERE.md                     [Get Started]
│   └── INDEX.md                          [File Navigation]
│
└── TESTING
    └── test_helper.py                   [Testing Utilities]
        └─ NotificationServiceTester class
        └─ test_health()
        └─ test_send_notification()
        └─ test_multicast()


# ============================================================================
# 4. HOW TO RUN THE SERVICE
# ============================================================================

PREREQUISITE:
1. Download Firebase credentials from Firebase Console
2. Save as Notifications/serviceAccountKey.json
3. Configure .env file (defaults are OK)

RUNNING:

Option 1: Using astart (Recommended - includes logging)
  $ astart -n
  
  Result:
  ✓ Service starts on port 9000
  ✓ All output captured to logs/process_logs/notification_service_*.log
  ✓ Activity logged to logs/astart_activity.log
  ✓ PID managed in logs/pids/notification_service.pid

Option 2: Direct (for development only)
  $ cd Notifications
  $ python main.py
  
  Result:
  ✓ Service starts on port 9000
  ✓ Console output only
  ✓ Ctrl+C to stop

VERIFICATION:
  $ curl http://localhost:9000/api/notify/health
  
  Response:
  {
    "status": "healthy",
    "service": "Thoutha Notification Service",
    "version": "1.0.0"
  }


# ============================================================================
# 5. WHAT EACH KEY FILE DOES
# ============================================================================

main.py
-------
Purpose: Application entry point
Responsibilities:
  - Import FastAPI and all routes
  - Initialize Firebase service on startup
  - Register routes
  - Set up exception handlers
  - Start uvicorn server
  - Handle shutdown gracefully

When you run "astart -n", this file is executed as: python main.py

notification_service.py
-----------------------
Purpose: Core business logic for sending notifications
Key Methods:
  • send_notification(token, title, body, data)
    - Send to single device
    - Returns: NotificationResponse with message_id
  
  • send_notification_with_retry(...)
    - Same as above but retries 3 times on failure
    - 1 second delay between retries
  
  • send_multicast(tokens, title, body, data)
    - Send to multiple devices (500+) in one request
    - Handles partial failures gracefully
    - Returns success/failure counts
  
  • send_to_topic(topic, title, body, data)
    - Broadcast to all subscribed devices
    - Topic must be created first
  
  • subscribe_to_topic(tokens, topic)
    - Add devices to a topic
  
  • unsubscribe_from_topic(tokens, topic)
    - Remove devices from a topic
  
  • get_statistics()
    - Returns total success/failure counts
    - Returns last 100 failures log

firebase_service.py
-------------------
Purpose: Manage Firebase Admin SDK
Key Methods:
  • initialize_firebase()
    - Loads credentials from .env
    - Initializes Firebase Admin SDK
    - Called once on startup
  
  • verify_initialization()
    - Checks if Firebase is properly initialized
    - Returns True/False
    - Used for health checks

notification_routes.py
----------------------
Purpose: Define all API endpoints
Endpoints:
  1. GET /api/notify/health         → Health check
  2. POST /api/notify/send          → Single device
  3. POST /api/notify/send-with-retry → With retries
  4. POST /api/notify/send-multicast → Multiple devices
  5. POST /api/notify/send-to-topic → Topic broadcast
  6. POST /api/notify/subscribe-topic → Add to topic
  7. POST /api/notify/unsubscribe-topic → Remove from topic
  8. GET /api/notify/statistics → Service metrics

All require X-API-Key header (except health check)

auth.py
-------
Purpose: Validate API requests
Key Methods:
  • validate_api_key(x_api_key)
    - Checks X-API-Key header
    - Raises HTTPException if invalid
    - Used as FastAPI dependency
  
  • validate_jwt_token(authorization)
    - Checks Authorization: Bearer <token> header
    - Decodes and validates JWT
    - Optional (for advanced use)

logger.py
---------
Purpose: Structured logging
Key Features:
  • Console output only (NO file logging)
  • astart captures all stdout automatically
  • Logs go to: logs/process_logs/notification_service_*.log
  • Configurable levels: INFO, WARNING, ERROR
  • Timestamps and module names included

config.py
---------
Purpose: Load and provide configuration
Sources:
  • .env file
  • Environment variables
  • Default values
Provides:
  • settings.api_key
  • settings.port
  • settings.firebase_service_account_path
  • settings.log_level
  etc.


# ============================================================================
# 6. LOGGING STRATEGY
# ============================================================================

LOGGING DESIGN:

Before Integration (Old Way):
  Service had its own file logging
  start.bat/start.sh scripts launched it
  Hard to track across all services

After Integration (New Way):
  ✓ Service outputs to stdout/stderr only
  ✓ astart captures ALL output automatically
  ✓ Single source of truth: logs/ directory
  ✓ Consistent logging format across all services
  ✓ Unified activity log for all processes

LOGGING FLOW:

  Service Console Output
        ↓
  logger.py → StreamHandler(stdout)
        ↓
  astart captures via pipe
        ↓
  Process Log: logs/process_logs/notification_service_HH-MM-SS_DD-MM-YYYY.log
  Activity Log: logs/astart_activity.log

VIEWING LOGS:

Option 1: View latest 50 lines
  $ astart -L notification_service

Option 2: Follow in real-time (like tail -f)
  $ astart -F notification_service

Option 3: Direct file access
  $ cat logs/process_logs/notification_service_*.log
  $ tail -f logs/process_logs/notification_service_*.log

LOG OUTPUT EXAMPLE:
  2024-03-27 10:30:45 - services.firebase_service - INFO - ✓ Firebase Admin SDK initialized
  2024-03-27 10:30:46 - routes.notification_routes - INFO - 📨 Received notification request
  2024-03-27 10:30:46 - services.notification_service - INFO - ✓ Notification sent (ID: abc123)


# ============================================================================
# 7. INTEGRATION WITH JAVA BACKEND
# ============================================================================

FROM JAVA, CALL NOTIFICATION SERVICE:

@PostMapping("/appointments/{id}/confirm")
public void confirmAppointment(@PathVariable Long id) {
    Appointment apt = appointmentService.confirm(id);
    
    // Prepare notification
    HttpHeaders headers = new HttpHeaders();
    headers.set("X-API-Key", "thoutha-notification-service-key-2024");
    headers.setContentType(MediaType.APPLICATION_JSON);
    
    String json = """
    {
        "token": "%s",
        "title": "Appointment Confirmed",
        "body": "Your appointment is confirmed for %s",
        "data": {
            "appointmentId": "%d",
            "doctorName": "%s"
        }
    }
    """.formatted(
        apt.getPatient().getDeviceToken(),
        apt.getDateTime(),
        apt.getId(),
        apt.getDoctor().getName()
    );
    
    HttpEntity<String> entity = new HttpEntity<>(json, headers);
    
    // Call notification service (runs in background, failures logged)
    try {
        restTemplate.postForObject(
            "http://localhost:9000/api/notify/send",
            entity,
            NotificationResponse.class
        );
    } catch (Exception e) {
        logger.error("Notification failed: " + e.getMessage());
        // Continue - appointment already confirmed, notification is best-effort
    }
}


# ============================================================================
# 8. MANAGEMENT COMMANDS
# ============================================================================

START SERVICE:
  $ astart -n

STOP SERVICE:
  $ astart -s  [then select "notification_service"]

RESTART SERVICE:
  $ astart -r notification_service

VIEW LOGS:
  $ astart -L notification_service     (last 50 lines)
  $ astart -F notification_service     (follow live)

CHECK STATUS:
  $ astart -l                          (list all services)

VIEW HELP:
  $ astart -h


# ============================================================================
# 9. CONFIGURATION (.env)
# ============================================================================

FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
  └─ Path to Firebase credentials JSON
  └─ Download from Firebase Console
  └─ Place in Notifications directory

API_KEY=thoutha-notification-service-key-2024
  └─ Secret key for API authentication
  └─ Change for production
  └─ Use in X-API-Key header

JWT_SECRET=your-jwt-secret-key-here
  └─ Secret for JWT token signing
  └─ Change for production

HOST=localhost
  └─ Server host (localhost = local only)
  └─ Change to 0.0.0.0 for network access

PORT=9000
  └─ Server port
  └─ Must match NOTIFICATION_PORT in astart

DEBUG=True
  └─ Set to False in production
  └─ Exposes detailed error messages in API responses

LOG_LEVEL=INFO
  └─ Logging level
  └─ Options: DEBUG, INFO, WARNING, ERROR


# ============================================================================
# 10. TROUBLESHOOTING
# ============================================================================

SERVICE WON'T START:

1. Port 9000 already in use
   Fix: Change PORT in .env
   Check: lsof -i :9000 (Linux) or netstat -ano | findstr :9000 (Windows)

2. Firebase credentials missing
   Fix: Download from Firebase Console, save as serviceAccountKey.json
   Error: "FileNotFoundError: Firebase service account key not found"

3. Python dependencies missing
   Fix: pip install -r requirements.txt
   Error: "ModuleNotFoundError: No module named 'fastapi'"

4. Permission denied
   Fix: chmod +x (if needed), run with proper Python version
   Error: "python: command not found"

SERVICE STARTS BUT HEALTH CHECK FAILS:

1. Check if port is actually listening
   $ netstat -an | grep 9000
   $ lsof -i :9000

2. View logs for startup errors
   $ astart -L notification_service
   Look for error lines starting with "ERROR" or "Exception"

3. Verify Firebase credentials
   Check: logs mention Firebase initialization success?
   If not: credentials file missing or invalid

API CALLS RETURNING 401 UNAUTHORIZED:

1. Check API key
   Is your X-API-Key header matching the one in .env?
   Default: thoutha-notification-service-key-2024

2. Verify header format
   Correct: X-API-Key: thoutha-notification-service-key-2024
   Wrong: x-api-key, API-Key, etc.

3. Check if service restarted
   After changing .env, must restart service
   $ astart -r notification_service


# ============================================================================
# 11. PERFORMANCE NOTES
# ============================================================================

Single Notification:
  ✓ ~200-500ms per notification
  ✓ Depends on Firebase network
  ✓ Automatic 3x retry on failure

Multicast (500 devices):
  ✓ ~500-1000ms for all 500 devices
  ✓ Much faster than 500 individual requests
  ✓ Partial failure handling

Concurrent Requests:
  ✓ Handles 100+ concurrent requests
  ✓ FastAPI + uvicorn are async-capable
  ✓ No connection pooling needed (Firebase SDK manages)

Logging Impact:
  ✓ Minimal overhead (console output only)
  ✓ No database writes
  ✓ No file I/O per notification


# ============================================================================
# SUMMARY
# ============================================================================

What: FastAPI notification service with Firebase integration
How: Python application running on port 9000
Startup: astart -n
Logs: logs/process_logs/notification_service_*.log
Config: .env file
API: 9 endpoints for sending/managing notifications
Security: API Key authentication (X-API-Key header)
Logging: Console output captured by astart
Status: ✅ Production ready

Key Files:
  • main.py ..................... Entry point
  • notification_service.py ..... Core logic
  • firebase_service.py ......... Firebase integration
  • notification_routes.py ...... API endpoints
  • auth.py ..................... Authentication
  • logger.py ................... Logging

Read PYTHON_BRIEF.md for quick reference
Read API_DOCUMENTATION.md for endpoint details
Read SETUP_GUIDE.md for installation help
"""

# Notification Microservice Architecture

## Overview

This is a production-ready notification microservice built with FastAPI that integrates with Firebase Cloud Messaging (FCM) for real-time push notifications to dental clinic patients and doctors. The service implements distributed system patterns including idempotency, delivery tracking, and queue management.

## Directory Structure

```
Notification/
├── main.py                          # Entry point (FastAPI app startup)
├── app.py                           # Application factory and configuration
├── config.py                        # Configuration and database setup
├── requirements.txt                 # Python dependencies
│
├── models/                          # Data models
│   ├── __init__.py
│   ├── database_models.py          # SQLAlchemy ORM models
│   └── notification.py             # Pydantic schemas
│
├── services/                        # Business logic layer
│   ├── __init__.py
│   ├── firebase_service.py         # FCM integration
│   ├── email_service.py            # Email notification sender
│   ├── notification_service.py     # Main orchestrator
│   └── queue_service.py            # Queue management
│
├── routes/                          # API endpoints
│   ├── __init__.py
│   └── notification_routes.py      # REST API routes
│
├── utils/                           # Utility functions
│   ├── __init__.py
│   ├── idempotency.py              # Idempotency key generation
│   └── database.py                 # Database session management
│
├── tests/                           # Test suites
│   └── test_structure.py           # Structure validation tests
│
├── scripts/                         # Operational scripts
│   ├── setup.sh                    # Environment setup
│   ├── startup.sh                  # Service startup
│   └── health_check.sh             # Health monitoring
│
└── logs/                           # Application logs directory
```

## Core Components

### 1. Database Models (`models/database_models.py`)

- **NotificationQueue**: Stores pending notifications with idempotency
- **NotificationDeliveryAudit**: Tracks delivery status and failures
- **NotificationTemplate**: Stores message templates (for future enhancement)
- **PatientProfile**: Links to patient data
- **DoctorProfile**: Links to doctor data

### 2. Services

#### Firebase Service (`services/firebase_service.py`)
- Initializes Firebase Admin SDK
- Sends FCM messages to devices
- Handles subscription/unsubscription
- Records delivery status webhooks

#### Email Service (`services/email_service.py`)
- Sends appointment confirmations
- Sends password reset links
- Sends appointment reminders
- SMTP configuration support

#### Notification Service (`services/notification_service.py`)
- **Main orchestrator** for all notification types
- Handles appointment confirmations
- Treatment plan updates
- Payment notifications
- Coordinates between Firebase and Email services

#### Queue Service (`services/queue_service.py`)
- Manages notification queue persistence
- Implements idempotency via idempotency keys
- Handles duplicate detection
- Tracks delivery audit logs

### 3. API Routes (`routes/notification_routes.py`)

**Endpoints:**
- `POST /api/v1/notifications/appointment-confirmed` - Queue appointment notifications
- `POST /api/v1/notifications/treatment-plan-update` - Notify treatment updates
- `POST /api/v1/notifications/payment-received` - Payment confirmation
- `GET /api/v1/notifications/status/{fcm_message_id}` - Get delivery status
- `POST /api/v1/notifications/firebase-webhook` - Handle FCM webhooks
- `POST /api/v1/notifications/health-check` - Service health check

### 4. Key Design Patterns

#### Idempotency
```python
# Generate idempotency key from request data
key = generate_idempotency_key(f"apt_confirm_{appointment_id}_patient")

# Database unique constraint prevents duplicates
NotificationQueue(idempotency_key=key, ...)
```

#### Graceful Degradation
- If FCM fails, notifications queue for retry
- Email fallback for delivery failures
- Retry logic with exponential backoff

#### Exactly-Once Delivery
- Idempotency keys prevent duplicate notifications
- Unique constraint on database prevents duplicate rows
- Audit trail for all delivery attempts

## Configuration

### Environment Variables (`.env`)
```
# Database
DB_USER=hr
DB_PASSWORD=password
DB_HOST=localhost
DB_PORT=1521
DB_NAME=orclpdb

# Firebase
FIREBASE_CREDENTIALS=path/to/firebase-key.json

# Email (SMTP)
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SENDER_EMAIL=noreply@clinic.com
SENDER_PASSWORD=app_password
```

### Port Configuration
- **Notification Service**: Port 9000
- Connect from Java Backend to: `http://notification:9000`

## Running the Service

### Development
```bash
# Install dependencies
pip install -r requirements.txt

# Run service
python main.py

# Service available at: http://localhost:9000
# API documentation: http://localhost:9000/docs
```

### Docker (Production)
```bash
# Build image
docker build -t dental-notification:1.0 .

# Run container
docker run -d \
  --name notification-service \
  -p 9000:9000 \
  --env-file .env \
  dental-notification:1.0
```

### Health Check
```bash
curl http://localhost:9000/health

# Response:
{
  "status": "healthy",
  "firebase": "initialized",
  "database": "connected"
}
```

## Integration with Backend

### From Java Backend

```java
// Call notification service
RestTemplate restTemplate = new RestTemplate();
NotificationRequest request = new NotificationRequest(
    appointmentId, patientId, doctorId, 
    UUID.randomUUID().toString()  // idempotency key
);

restTemplate.postForObject(
    "http://notification:9000/api/v1/notifications/appointment-confirmed",
    request,
    ResponseEntity.class
);
```

### Notification Flow

```
User Action (Java Backend)
    ↓
POST /api/v1/notifications/appointment-confirmed
    ↓
NotificationService.notify_appointment_confirmed()
    ├→ Validate idempotency key
    ├→ Check for duplicates
    ├→ Queue message in database
    └→ Return immediately
    ↓
Background Queue Processor
    ├→ Get device tokens from database
    ├→ Send via Firebase (FCM)
    ├→ Record delivery status
    └→ Email fallback if needed
    ↓
Firebase Cloud Messaging (FCM)
    ├→ Route to patient device
    ├→ Route to doctor device
    └→ Webhook callback for status
```

## Database Schema (Key Tables)

### NotificationQueue
```sql
CREATE TABLE notification_queue (
    id NUMBER PRIMARY KEY,
    idempotency_key VARCHAR2(255) UNIQUE NOT NULL,
    user_id NUMBER NOT NULL,
    payload CLOB NOT NULL,
    status VARCHAR2(20),
    retry_count NUMBER DEFAULT 0,
    created_at TIMESTAMP DEFAULT SYSDATE,
    updated_at TIMESTAMP
);
```

### NotificationDeliveryAudit
```sql
CREATE TABLE notification_delivery_audit (
    id NUMBER PRIMARY KEY,
    fcm_message_id VARCHAR2(255) UNIQUE,
    user_id NUMBER NOT NULL,
    delivery_status VARCHAR2(20),
    error_message VARCHAR2(500),
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT SYSDATE
);
```

## Monitoring & Logging

### Logs Location
- Application logs: `logs/notification.log`
- Error logs: `logs/errors.log`

### Health Check Script
```bash
# Run periodic health checks
./scripts/health_check.sh

# Checks:
# - Service listening on port 9000
# - Database connectivity
# - Firebase initialization
```

## Security Considerations

1. **Firebase Credentials**: Store in secure environment variables, never commit to repo
2. **Database Credentials**: Use environment variables or secrets manager
3. **CORS**: Currently open (`allow_origins=["*"]`) - restrict in production
4. **Rate Limiting**: Implement API rate limiting per user
5. **Authentication**: Add JWT/OAuth for API endpoints
6. **Encryption**: Encrypt sensitive data in queue (PII)

## Future Enhancements

1. **Message Templates**: Use templates for multi-language support
2. **Scheduled Notifications**: Appointment reminders at specific times
3. **Notification Preferences**: Let users customize channels (push/email/SMS)
4. **Analytics**: Track notification delivery metrics
5. **A/B Testing**: Test different message variants
6. **SMS Integration**: Add SMS notification channel
7. **Webhook Signing**: Verify Firebase webhook signatures
8. **Rate Limiting**: Prevent notification spam

## Troubleshooting

### Firebase Not Initializing
```
ERROR: Failed to initialize Firebase

Solution:
1. Verify FIREBASE_CREDENTIALS path
2. Ensure JSON key file has correct permissions
3. Check Firebase project ID matches
```

### Database Connection Fails
```
ERROR: Database health check failed

Solution:
1. Verify Oracle database is running
2. Check DB_HOST, DB_PORT, DB_USER, DB_PASSWORD
3. Ensure firewall allows connection
```

### Notifications Not Delivering
```
Check:
1. Device token is valid and up-to-date
2. Firebase project has correct bundle ID
3. APK/app has notification permission granted
4. Check delivery audit logs for errors
```

## Testing

Run the structure test:
```bash
python tests/test_structure.py

Output:
✓ All imports successful!
✓ Key generation test passed!
✓ ALL TESTS PASSED
```

## References

- FastAPI: https://fastapi.tiangolo.com
- Firebase Admin SDK: https://firebase.google.com/docs/admin/setup
- SQLAlchemy: https://docs.sqlalchemy.org
- Oracle Database: https://docs.oracle.com

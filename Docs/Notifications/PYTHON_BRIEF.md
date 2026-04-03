# Python Notification Service - Brief Overview

## 🎯 What Is It?

A **FastAPI-based notification service** that handles push notifications for the Thoutha Teeth Management System using Firebase Cloud Messaging (FCM).

**Key Points:**
- Standalone Python service (FastAPI)
- Runs on port 9000
- Communicates with Java backend via HTTP API
- Manages Firebase Cloud Messaging integration
- Handles device tokens, multicast, topic-based messaging

---

## 📊 How It Works

```
Java Backend          Notification Service          Firebase          Mobile App
    |                      |                           |                  |
    |---(API Call)-------->|                           |                  |
    |  POST /api/notify/   |                           |                  |
    |  send                |---(send message)--------->|                  |
    |                      |                           |---(FCM Push)--->|
    |<-(Response)----------|                           |                  |
    |  {success: true}     |                           |                  |
```

### Flow:
1. **Java Backend** makes HTTP request to notification service
2. **Notification Service** validates request (API key, format)
3. **Service** calls Firebase SDK to send message
4. **Firebase** delivers via FCM to mobile devices
5. **Response** returned to Java backend

---

## 📁 File Structure & Purpose

### Core Application Files

| File | Purpose |
|------|---------|
| `main.py` | FastAPI application entry point; initializes service, registers routes, handles exceptions |
| `Notifications.py` | Package module; exports main components; version info |
| `startup.py` | Startup helper (python only); checks deps, validates Firebase creds |
| `requirements.txt` | Python dependencies (fastapi, uvicorn, firebase-admin, pydantic, etc.) |

### Configuration

| File | Purpose |
|------|---------|
| `.env` | Production configuration (API keys, ports, Firebase path) |
| `.env.example` | Template showing all configurable options |

### Core Modules (src code)

| Module | File | Purpose |
|--------|------|---------|
| **config** | `config/config.py` | Settings management; loads from `.env`; provides `settings` object |
| **models** | `models/notification.py` | Pydantic schemas for request/response validation |
| **services** | `services/firebase_service.py` | Firebase SDK init & management (singleton pattern) |
| **services** | `services/notification_service.py` | **Core logic**: send_notification(), send_multicast(), send_to_topic(), etc. |
| **routes** | `routes/notification_routes.py` | **API endpoints**: all 9 endpoints defined here |
| **security** | `security/auth.py` | API Key validation, JWT support |
| **utils** | `utils/logger.py` | Structured logging (INFO, WARNING, ERROR) |

### Documentation

| File | Purpose |
|------|---------|
| `README.md` | Quick start guide; features overview |
| `SETUP_GUIDE.md` | Installation; troubleshooting; production setup |
| `API_DOCUMENTATION.md` | Complete API reference; all endpoints; examples |
| `IMPLEMENTATION_SUMMARY.md` | Technical overview; what was built; architecture |
| `QUICK_REFERENCE.py` | Quick lookup guide; common commands; examples |
| `START_HERE.md` | Get started quickly |
| `INDEX.md` | Project index; file navigation |

### Testing

| File | Purpose |
|------|---------|
| `test_helper.py` | Testing utilities; health checks; example calls |

---

## 🚀 How to Run

### Before Running
1. Download Firebase credentials (JSON) from Firebase Console
2. Save as `serviceAccountKey.json` in Notifications directory
3. Configure `.env` (default values provided)

### Run Method 1: Direct (Old Way - Deprecated)
```bash
cd Notifications
python main.py
```

### Run Method 2: Using astart (New Way - Recommended)
```bash
astart -n
```

**That's it!** astart handles:
- Port checking
- Process logging (automatic)
- PID management
- Startup/shutdown

---

## 📊 API Endpoints (9 Total)

All require `X-API-Key` header (except root & health):

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/` | Service info |
| GET | `/api/notify/health` | Health check (no auth) |
| POST | `/api/notify/send` | Single device notification |
| POST | `/api/notify/send-with-retry` | With 3x retry logic |
| POST | `/api/notify/send-multicast` | Multiple devices (500+) |
| POST | `/api/notify/send-to-topic` | Topic broadcast |
| POST | `/api/notify/subscribe-topic` | Add devices to topic |
| POST | `/api/notify/unsubscribe-topic` | Remove from topic |
| GET | `/api/notify/statistics` | Service metrics |

---

## 🔐 Authentication

**API Key Method:**
```
Header: X-API-Key: thoutha-notification-service-key-2024
```

**JWT Method (optional):**
```
Header: Authorization: Bearer <token>
```

---

## 📝 Example Usage from Java Backend

```java
@PostMapping("/appointments/{id}/confirm")
public ResponseEntity<?> confirmAppointment(@PathVariable Long id) {
    Appointment apt = appointmentService.confirm(id);
    
    // Call notification service
    HttpHeaders headers = new HttpHeaders();
    headers.set("X-API-Key", "thoutha-notification-service-key-2024");
    headers.setContentType(MediaType.APPLICATION_JSON);
    
    String body = """
    {
        "token": "%s",
        "title": "Appointment Confirmed",
        "body": "Your appointment is confirmed",
        "data": {
            "appointmentId": "%d"
        }
    }
    """.formatted(apt.getPatient().getDeviceToken(), id);
    
    HttpEntity<String> entity = new HttpEntity<>(body, headers);
    restTemplate.postForObject(
        "http://localhost:9000/api/notify/send",
        entity,
        NotificationResponse.class
    );
    
    return ResponseEntity.ok(apt);
}
```

---

## 📊 Logging Strategy

### Current Setup (Before Integration)
- Service logs to console (configurable level)
- `.env` has `LOG_LEVEL=INFO`
- Logs include timestamps, module names, severity

### With astart Integration
- **astart handles process logging** automatically
- Service output captured to: `logs/process_logs/notification_service_<timestamp>.log`
- Activity logged to: `logs/astart_activity.log`
- Service **should NOT need its own file logging**

**Decision: Remove service's own logging?**
- ✅ **Yes** - astart provides comprehensive logging
- astart captures all stdout/stderr
- Single source of truth for logs
- Easier debugging

**Action Taken:**
- Keep console output (INFO level)
- Remove file-based logging from service
- Let astart handle log persistence

---

## 🔧 Configuration (.env)

```env
# Firebase
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json

# API Security
API_KEY=thoutha-notification-service-key-2024
JWT_SECRET=your-jwt-secret-key

# Server
HOST=localhost
PORT=9000
DEBUG=False
LOG_LEVEL=INFO
```

---

## ⚡ Service Components

### NotificationService (Core)
```python
notification_service.send_notification(token, title, body, data)
notification_service.send_multicast(tokens, title, body, data)
notification_service.send_to_topic(topic, title, body, data)
notification_service.get_statistics()
```

### FirebaseService (Integration)
```python
firebase_service.initialize_firebase()  # Init SDK
firebase_service.verify_initialization()  # Verify setup
firebase_service.get_messaging_client()  # Get client
```

### Security
```python
security_manager.validate_api_key(api_key)  # API key check
security_manager.validate_jwt_token(token)  # JWT validation
security_manager.create_jwt_token(data)  # Create token
```

---

## 🧪 Testing

### Health Check
```bash
curl http://localhost:9000/api/notify/health
```

### Send Notification
```bash
curl -X POST http://localhost:9000/api/notify/send \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "device_token_here",
    "title": "Test",
    "body": "Test message",
    "data": {"key": "value"}
  }'
```

### Python Testing
```bash
python test_helper.py
```

---

## 📈 Performance

- ✅ Handles concurrent requests
- ✅ Multicast: send to 500+ devices in one request
- ✅ Retry mechanism: automatic 3x retry
- ✅ Connection pooling: Firebase SDK manages
- ✅ Async ready: FastAPI native support

---

## 🔍 Troubleshooting

### Firebase Credentials Missing
- Download from Firebase Console
- Save as `serviceAccountKey.json`
- Restart service

### Port 9000 In Use
- Change in `.env`: `PORT=9001`
- Or kill process: `lsof -i :9000 | kill -9 <PID>`

### Authentication Failed
- Check API key in `.env`
- Verify header: `X-API-Key: <key>`

### Dependency Issues
```bash
pip install -r requirements.txt
```

---

## 📚 Files To Read

**Quick Start:** `START_HERE.md`  
**Installation:** `SETUP_GUIDE.md`  
**API Usage:** `API_DOCUMENTATION.md`  
**File Reference:** `QUICK_REFERENCE.py`  
**Architecture:** `IMPLEMENTATION_SUMMARY.md`

---

## 🎯 Integration Checklist

- [ ] Download Firebase credentials
- [ ] Place `serviceAccountKey.json`
- [ ] Configure `.env` (defaults OK)
- [ ] Add to Java backend configuration
- [ ] Create HTTP client in Java backend
- [ ] Test health endpoint
- [ ] Send test notification
- [ ] Monitor logs via `astart -L notification_service`

---

## 📊 Key Stats

| Metric | Value |
|--------|-------|
| Lines of Code | 2000+ |
| API Endpoints | 9 |
| Python Files | 20 |
| Data Models | 5 |
| Service Classes | 3 |
| Logging Points | 50+ |
| Error Handlers | 8+ |
| Documentation Files | 7 |

---

## 🚀 Next Steps

1. **Start Service:**
   ```bash
   astart -n
   ```

2. **Check Status:**
   ```bash
   astart -l
   ```

3. **View Logs:**
   ```bash
   astart -L notification_service
   ```

4. **Stop Service:**
   ```bash
   astart -s  # then select "notification_service"
   ```

---

**Status: ✅ Ready for Production**  
**Integration: With astart (-n flag)**  
**Logging: Via astart (automatic)**  
**Port: 9000**

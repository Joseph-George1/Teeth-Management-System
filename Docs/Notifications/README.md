# Thoutha Notification Service

A high-performance, Firebase Cloud Messaging (FCM) powered notification service for the Thoutha Teeth Management System.

## 🚀 Quick Start

### Prerequisites
- Python 3.8+
- Firebase Project with credentials

### Installation

**1. Install dependencies:**
```bash
pip install -r requirements.txt
```

**2. Download Firebase Credentials:**
- Go to [Firebase Console](https://console.firebase.google.com)
- Select your project → Project Settings → Service Accounts
- Click "Generate New Private Key"
- Save as `serviceAccountKey.json` in the Notifications directory

**3. Start the service:**

**Windows:**
```bash
start.bat
```

**Linux/macOS:**
```bash
chmod +x start.sh
./start.sh
```

**Manual:**
```bash
python main.py
```

Service will start on `http://localhost:9000`

## 📋 Features

✅ **Single Device Notifications** - Send to individual devices  
✅ **Multicast Notifications** - Bulk send to 500+ devices  
✅ **Topic-Based Messaging** - Broadcast to subscribed users  
✅ **Automatic Retries** - 3-attempt retry mechanism  
✅ **Error Handling** - Comprehensive error logging  
✅ **API Security** - API Key & JWT authentication  
✅ **Statistics Tracking** - Success/failure metrics  
✅ **Structured Logging** - Full operation visibility  

## 📁 Project Structure

```
Notifications/
├── main.py                      # FastAPI application
├── Notifications.py             # Package initialization
├── startup.py                   # Python startup script
├── start.sh                      # Linux/macOS startup
├── start.bat                     # Windows startup
├── requirements.txt             # Dependencies
├── .env                         # Environment variables
├── .env.example                 # Environment template
├── serviceAccountKey.json       # Firebase credentials
│
├── config/
│   ├── __init__.py
│   └── config.py               # Configuration management
│
├── models/
│   ├── __init__.py
│   └── notification.py         # Request/response models
│
├── services/
│   ├── __init__.py
│   ├── firebase_service.py     # Firebase initialization
│   └── notification_service.py # Core notification logic
│
├── routes/
│   ├── __init__.py
│   └── notification_routes.py  # API endpoints
│
├── security/
│   ├── __init__.py
│   └── auth.py                 # Authentication
│
├── utils/
│   ├── __init__.py
│   └── logger.py               # Logging utilities
│
├── SETUP_GUIDE.md              # Detailed setup guide
├── API_DOCUMENTATION.md        # API reference
├── test_helper.py              # Testing utilities
└── README.md                   # This file
```

## 🔌 API Endpoints

### Authentication
All endpoints require `X-API-Key` header (except `/health`):
```
X-API-Key: thoutha-notification-service-key-2024
```

### Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/notify/health` | Health check |
| GET | `/` | Root endpoint |
| POST | `/api/notify/send` | Send to single device |
| POST | `/api/notify/send-with-retry` | Send with retry |
| POST | `/api/notify/send-multicast` | Send to multiple devices |
| POST | `/api/notify/send-to-topic` | Send to topic subscribers |
| POST | `/api/notify/subscribe-topic` | Subscribe to topic |
| POST | `/api/notify/unsubscribe-topic` | Unsubscribe from topic |
| GET | `/api/notify/statistics` | Service statistics |

## 💻 Usage Examples

### Send Single Notification

```bash
curl -X POST http://localhost:9000/api/notify/send \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -H "Content-Type: application/json" \
  -d '{
    "token": "device_token",
    "title": "Appointment Reminder",
    "body": "Your appointment is in 1 hour",
    "data": {
      "appointment_id": "12345",
      "clinic": "Downtown"
    }
  }'
```

### Send to Multiple Devices

```bash
curl -X POST http://localhost:9000/api/notify/send-multicast \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -H "Content-Type: application/json" \
  -d '{
    "tokens": ["token1", "token2", "token3"],
    "title": "System Update",
    "body": "New features available"
  }'
```

### Send to Topic

```bash
curl -X POST http://localhost:9000/api/notify/send-to-topic \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -H "Content-Type: application/json" \
  -d '{
    "topic": "announcements",
    "title": "Important Notice",
    "body": "Clinic will be closed Monday"
  }'
```

### Get Statistics

```bash
curl http://localhost:9000/api/notify/statistics \
  -H "X-API-Key: thoutha-notification-service-key-2024"
```

## 🔐 Security

### API Key Authentication
- Default key: `thoutha-notification-service-key-2024`
- Configure in `.env` file
- Include in all requests: `X-API-Key: your-key`

### JWT Support
- Optional JWT authentication via `Authorization: Bearer <token>` header
- Configure `JWT_SECRET` in `.env`

### Environment Variables
```bash
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
API_KEY=thoutha-notification-service-key-2024
JWT_SECRET=your-jwt-secret-key
HOST=localhost
PORT=9000
DEBUG=True
LOG_LEVEL=INFO
```

## 📊 Monitoring

### Health Check
```bash
curl http://localhost:9000/api/notify/health
```

### Statistics
```bash
curl http://localhost:9000/api/notify/statistics \
  -H "X-API-Key: thoutha-notification-service-key-2024"
```

### Logs
Logs are printed to console with timestamps and log levels:
```
2024-03-27 10:30:45 - services.firebase_service - INFO - ✓ Firebase Admin SDK initialized successfully
2024-03-27 10:30:46 - routes.notification_routes - INFO - 📨 Received notification request...
```

## 🧪 Testing

### Health Check
```bash
python test_helper.py
```

### Manual Testing
```python
import requests

api_key = "thoutha-notification-service-key-2024"
headers = {"X-API-Key": api_key}

# Health check
response = requests.get(
    "http://localhost:9000/api/notify/health",
    headers=headers
)
print(response.json())
```

## 🚨 Troubleshooting

### Firebase Credentials Not Found
```
Error: FileNotFoundError: Firebase service account key not found
```
**Solution:**
1. Download service account JSON from Firebase Console
2. Save as `serviceAccountKey.json` in Notifications directory
3. Restart the service

### Port Already in Use
```
Error: Address already in use
```
**Solution:**
1. Change PORT in `.env` (default: 9000)
2. Or kill the process using that port:
   - Windows: `netstat -ano | findstr :9000` then `taskkill /PID <PID> /F`
   - Linux: `lsof -i :9000` then `kill -9 <PID>`

### Authentication Failed
```
Error: Invalid API key
```
**Solution:**
1. Verify API key in `.env` matches request header
2. Check `X-API-Key` header is correctly set
3. Update key if needed and restart

## 🔄 Advanced Features

### Retry Mechanism
- Automatic retry up to 3 times
- 1-second delay between attempts
- Configurable in `NotificationService.MAX_RETRIES`

### Partial Failure Handling
Multicast sends handle partial failures:
```json
{
  "success": true,
  "message": "Multicast completed",
  "successful": 299,
  "failed": 1,
  "errors": [
    {
      "token_index": 42,
      "error": "Unregistered device"
    }
  ]
}
```

### Topic Management
- Subscribe/unsubscribe devices from topics
- Broadcast to all topic subscribers
- Multiple topics per device supported

### Statistics & Logging
- Tracks success/failure counts
- Maintains failure log (last 100 failures)
- Structured logging with timestamps

## 📖 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Detailed installation and setup
- **[API_DOCUMENTATION.md](API_DOCUMENTATION.md)** - Complete API reference
- **[README.md](README.md)** - This file

## 🚀 Deployment

### Production Checklist
- [ ] Download Firebase credentials
- [ ] Configure `.env` with production values
- [ ] Change API key to secure value
- [ ] Change JWT_SECRET to secure value
- [ ] Set DEBUG=False
- [ ] Set LOG_LEVEL=WARNING
- [ ] Test all endpoints
- [ ] Setup monitoring/alerting
- [ ] Configure firewall rules
- [ ] Setup log rotation

### Running as Service

**Linux (systemd):**
```bash
sudo systemctl enable thoutha-notifications
sudo systemctl start thoutha-notifications
sudo systemctl status thoutha-notifications
```

**Windows (Task Scheduler):**
- Create scheduled task
- Set to run `start.bat` at startup
- Set to restart on failure

## 📈 Performance Optimization

1. **Use Multicast** - Send to multiple users in one request
2. **Batch Requests** - Group notifications when possible
3. **Monitor Statistics** - Track performance metrics regularly
4. **Adjust Log Level** - Use INFO in development, WARNING in production
5. **Connection Pooling** - Firebase SDK handles this automatically

## 🔗 Integration with Thoutha

Add to backend services:
```python
from Notifications import notification_service

# Send appointment reminder
notification_service.send_notification(
    token=user_device_token,
    title="Appointment Reminder",
    body=f"Your appointment with {dentist_name} at {appointment_time}",
    data={
        "appointment_id": str(appointment_id),
        "dentist_name": dentist_name,
        "clinic_id": str(clinic_id)
    }
)
```

## 📞 Support

For issues, feature requests, or questions:
1. Check documentation files
2. Review error logs
3. Check SETUP_GUIDE.md for troubleshooting
4. Contact development team

## 📄 License

Part of the Thoutha Teeth Management System

## 👥 Contributors

- Thoutha Development Team

---

**Version:** 1.0.0  
**Last Updated:** March 27, 2024  
**Status:** Production Ready ✅

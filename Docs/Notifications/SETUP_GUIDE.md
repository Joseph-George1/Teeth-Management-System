"""
Notification Service Setup & Installation Guide
"""

# Installation Steps

## Step 1: Install Dependencies

```bash
pip install -r requirements.txt
```

## Step 2: Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project or select existing one
3. Navigate to Project Settings > Service Accounts
4. Click "Generate New Private Key"
5. Save the JSON file as `serviceAccountKey.json` in the Notifications directory

```bash
# Place the downloaded JSON file here
Notifications/serviceAccountKey.json
```

## Step 3: Configure Environment

Create or update `.env` file:

```
FIREBASE_SERVICE_ACCOUNT_PATH=./serviceAccountKey.json
API_KEY=your-secure-api-key-here
JWT_SECRET=your-jwt-secret-key-here
HOST=localhost
PORT=9000
DEBUG=True
LOG_LEVEL=INFO
```

## Step 4: Verify Setup

Run the service:

```bash
cd Notifications
python main.py
```

Expected output:
```
============================================================
🚀 Starting Thoutha Notification Service
============================================================
✓ Firebase Admin SDK initialized successfully
✓ Firebase initialization verified
✓ Service running on localhost:9000
============================================================
```

## Step 5: Test Health Endpoint

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

# API Usage Examples

## 1. Send Single Notification

```bash
curl -X POST http://localhost:9000/api/notify/send \
  -H "Content-Type: application/json" \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -d '{
    "token": "device_registration_token",
    "title": "Appointment Reminder",
    "body": "Your appointment is in 1 hour",
    "data": {
      "appointment_id": "12345",
      "clinic": "Downtown"
    }
  }'
```

## 2. Send with Retry

```bash
curl -X POST http://localhost:9000/api/notify/send-with-retry \
  -H "Content-Type: application/json" \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -d '{
    "token": "device_registration_token",
    "title": "Test",
    "body": "Test message"
  }'
```

## 3. Send Multicast (Multiple Devices)

```bash
curl -X POST http://localhost:9000/api/notify/send-multicast \
  -H "Content-Type: application/json" \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -d '{
    "tokens": ["token1", "token2", "token3"],
    "title": "System Update",
    "body": "New features available",
    "data": {
      "version": "2.0.0"
    }
  }'
```

## 4. Send to Topic

```bash
curl -X POST http://localhost:9000/api/notify/send-to-topic \
  -H "Content-Type: application/json" \
  -H "X-API-Key: thoutha-notification-service-key-2024" \
  -d '{
    "topic": "announcements",
    "title": "Important Notice",
    "body": "Clinic will be closed on Monday"
  }'
```

## 5. Get Statistics

```bash
curl http://localhost:9000/api/notify/statistics \
  -H "X-API-Key: thoutha-notification-service-key-2024"
```

# Features

✓ **Single Device Notifications** - Send to individual devices  
✓ **Multicast Notifications** - Bulk send to multiple devices  
✓ **Topic-Based Notifications** - Send to all subscribers of a topic  
✓ **Retry Mechanism** - Automatic retries with configurable attempts  
✓ **Error Handling** - Comprehensive error handling and reporting  
✓ **Security** - API Key authentication & JWT support  
✓ **Logging** - Structured logging for all operations  
✓ **Statistics** - Track success/failure metrics  

# Project Structure

```
Notifications/
├── main.py                    # FastAPI application entry point
├── requirements.txt           # Python dependencies
├── .env                       # Environment variables
├── .env.example              # Environment template
├── serviceAccountKey.json    # Firebase credentials (download from console)
├── config/
│   ├── __init__.py
│   └── config.py            # Configuration management
├── models/
│   ├── __init__.py
│   └── notification.py      # Request/response models
├── services/
│   ├── __init__.py
│   ├── firebase_service.py  # Firebase initialization & management
│   └── notification_service.py  # Core notification logic
├── routes/
│   ├── __init__.py
│   └── notification_routes.py  # API endpoint definitions
├── security/
│   ├── __init__.py
│   └── auth.py              # Authentication & authorization
└── utils/
    ├── __init__.py
    └── logger.py            # Logging configuration
```

# Troubleshooting

## Firebase Service Account Not Found

**Error**: `FileNotFoundError: Firebase service account key not found`

**Solution**:
1. Download service account JSON from Firebase Console
2. Place it in `Notifications/serviceAccountKey.json`
3. Restart the service

## Invalid API Key

**Error**: `Invalid API key`

**Solution**:
1. Check the API key in `.env` file
2. Ensure it matches in request header: `X-API-Key: your-api-key`
3. Update key if needed and restart service

## Port Already in Use

**Error**: `Address already in use`

**Solution**:
1. Change `PORT` in `.env` (default: 9000)
2. Or kill the process using the port:
   - Windows: `netstat -ano | findstr :9000` then `taskkill /PID <PID> /F`
   - Linux/Mac: `lsof -i :9000` then `kill -9 <PID>`

## Failed to Verify Firebase

**Error**: `Firebase verification failed`

**Solution**:
1. Ensure `serviceAccountKey.json` is valid
2. Check internet connection
3. Verify Firebase project credentials
4. Check logs for specific error messages

# Running as Background Service

## Windows (PowerShell)

```powershell
# Start in background
Start-Process python -ArgumentList "main.py" -WindowStyle Hidden

# Stop service
Stop-Process -Name python -Force
```

## Linux/Mac (systemd)

Create `/etc/systemd/system/thoutha-notifications.service`:

```ini
[Unit]
Description=Thoutha Notification Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/Notifications
ExecStart=/usr/bin/python3 main.py
Restart=always

[Install]
WantedBy=multi-user.target
```

Then:
```bash
sudo systemctl daemon-reload
sudo systemctl enable thoutha-notifications
sudo systemctl start thoutha-notifications
```

# Performance Optimization Tips

1. **Batch Sending**: Use multicast endpoint for sending to multiple devices
2. **Async Operations**: Service is already built with async support
3. **Connection Pooling**: Firebase SDK handles connection pooling automatically
4. **Monitoring**: Check statistics endpoint regularly for performance metrics
5. **Logging**: Adjust log level to INFO for production to reduce overhead

# Support

For issues or questions, contact the development team.

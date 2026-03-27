# Thoutha Notification Service - API Documentation

## Overview

The Thoutha Notification Service is a FastAPI-based Firebase Cloud Messaging (FCM) service that handles push notifications for the Thoutha Teeth Management System.

**Base URL**: `http://localhost:9000`  
**API Version**: 1.0.0

## Authentication

All endpoints (except health check and root) require API authentication using one of these methods:

### API Key Authentication (Recommended)

Include the API key in the request header:

```
X-API-Key: thoutha-notification-service-key-2024
```

### JWT Token Authentication (Optional)

Include the JWT token in the Authorization header:

```
Authorization: Bearer <jwt_token>
```

## Endpoints

### 1. Health Check

**GET** `/api/notify/health`

Check service status.

**Response**:
```json
{
  "status": "healthy",
  "service": "Thoutha Notification Service",
  "version": "1.0.0"
}
```

---

### 2. Send Single Notification

**POST** `/api/notify/send`

Send a notification to a single device.

**Headers**:
```
X-API-Key: thoutha-notification-service-key-2024
Content-Type: application/json
```

**Request Body**:
```json
{
  "token": "device_registration_token",
  "title": "Appointment Reminder",
  "body": "Your appointment is in 1 hour",
  "data": {
    "appointment_id": "12345",
    "clinic": "Downtown Clinic",
    "time": "2:00 PM"
  }
}
```

**Response - Success**:
```json
{
  "success": true,
  "message": "Notification sent successfully",
  "message_id": "projects/thoutha-project/messages/123456"
}
```

**Response - Error**:
```json
{
  "success": false,
  "message": "Invalid request parameters",
  "errors": ["Unregistered device"]
}
```

---

### 3. Send Notification with Retry

**POST** `/api/notify/send-with-retry`

Send a notification with automatic retry mechanism (3 attempts by default).

**Headers**:
```
X-API-Key: thoutha-notification-service-key-2024
Content-Type: application/json
```

**Request Body**:
```json
{
  "token": "device_registration_token",
  "title": "System Update",
  "body": "New features available"
}
```

**Response**:
Same as single notification endpoint.

**Features**:
- Automatic retry up to 3 times
- 1-second delay between retries
- Logs each attempt

---

### 4. Send Multicast Notification

**POST** `/api/notify/send-multicast`

Send notifications to multiple devices. Handles partial failures gracefully.

**Headers**:
```
X-API-Key: thoutha-notification-service-key-2024
Content-Type: application/json
```

**Request Body**:
```json
{
  "tokens": ["token1", "token2", "token3", "token4"],
  "title": "New Treatment Plans",
  "body": "Check your updated treatment plan",
  "data": {
    "plan_id": "TP-2024-001"
  }
}
```

**Response**:
```json
{
  "success": true,
  "message": "Multicast completed",
  "successful": 3,
  "failed": 1,
  "message_ids": [
    "projects/thoutha-project/messages/123456",
    "projects/thoutha-project/messages/123457"
  ],
  "errors": [
    {
      "token_index": 2,
      "error": "Unregistered device"
    }
  ]
}
```

**Features**:
- Send to up to 500 devices in one request
- Partial failure handling
- Detailed error reporting per token
- Performance optimized

---

### 5. Send to Topic

**POST** `/api/notify/send-to-topic`

Send a notification to all devices subscribed to a topic.

**Headers**:
```
X-API-Key: thoutha-notification-service-key-2024
Content-Type: application/json
```

**Request Body**:
```json
{
  "topic": "clinic_announcements",
  "title": "Clinic Notice",
  "body": "Clinic will be closed on Monday for maintenance",
  "data": {
    "announcement_id": "ANN-001"
  }
}
```

**Response**:
```json
{
  "success": true,
  "message": "Topic notification sent successfully",
  "message_id": "projects/thoutha-project/messages/789012"
}
```

**Use Cases**:
- Broadcast announcements to all users
- System-wide notifications
- Clinic-specific updates

---

### 6. Subscribe Devices to Topic

**POST** `/api/notify/subscribe-topic`

Subscribe one or more devices to a topic.

**Headers**:
```
X-API-Key: thoutha-notification-service-key-2024
Content-Type: application/json
```

**Query Parameters**:
- `tokens` (array): List of device tokens
- `topic` (string): Topic name

**Request**:
```bash
POST /api/notify/subscribe-topic?topic=clinic_announcements
Content-Type: application/json

{
  "tokens": ["token1", "token2", "token3"]
}
```

**Response**:
```json
{
  "success": true,
  "message": "Successfully subscribed to topic: clinic_announcements",
  "subscribed_count": 3
}
```

---

### 7. Unsubscribe Devices from Topic

**POST** `/api/notify/unsubscribe-topic`

Unsubscribe devices from a topic.

**Headers**:
```
X-API-Key: thoutha-notification-service-key-2024
Content-Type: application/json
```

**Query Parameters**:
- `tokens` (array): List of device tokens
- `topic` (string): Topic name

**Response**:
```json
{
  "success": true,
  "message": "Successfully unsubscribed from topic: clinic_announcements",
  "unsubscribed_count": 3
}
```

---

### 8. Get Statistics

**GET** `/api/notify/statistics`

Retrieve notification service statistics.

**Headers**:
```
X-API-Key: thoutha-notification-service-key-2024
```

**Response**:
```json
{
  "total_success": 1542,
  "total_failures": 23,
  "failure_log": [
    "[token_abc123] Unregistered device",
    "[token_def456] Invalid argument"
  ]
}
```

---

## Error Codes

| Code | Status | Description |
|------|--------|-------------|
| 200 | OK | Request successful |
| 201 | Created | Resource created |
| 400 | Bad Request | Invalid request format |
| 401 | Unauthorized | Invalid or missing API key |
| 422 | Unprocessable Entity | Invalid data in request body |
| 500 | Server Error | Internal server error |

## Common Errors

### Invalid Token
```json
{
  "success": false,
  "message": "Invalid request parameters",
  "errors": ["Invalid token"]
}
```

**Solution**: Verify the device token is valid and properly formatted.

### Unregistered Device
```json
{
  "success": false,
  "message": "Device is not registered",
  "errors": ["Unregistered device"]
}
```

**Solution**: Device no longer has the app installed or has unsubscribed from notifications.

### Authentication Failed
```json
{
  "detail": "Invalid API key"
}
```

**Solution**: Check that the API key in the header matches the configured key.

## Rate Limiting

- No hard rate limits implemented
- Recommended: Max 1000 requests/minute per API key
- Batch requests when possible using multicast endpoint

## Best Practices

1. **Use Multicast**: Send to multiple users in one request for better performance
2. **Validate Tokens**: Maintain a list of valid device tokens
3. **Handle Failures**: Implement retry logic on the client side
4. **Monitor Statistics**: Check statistics endpoint regularly
5. **Secure Keys**: Never expose API keys in client-side code
6. **Use Topics**: For broadcast messages, use topic-based notifications
7. **Data Payload**: Keep data payload under 4KB
8. **Testing**: Use test tokens from Firebase Console first

## Request/Response Models

### NotificationRequest
```python
{
  "token": str,           # Required: Device token
  "title": str,           # Required: Notification title
  "body": str,            # Required: Notification body
  "data": dict (optional) # Optional: Key-value data payload
}
```

### MulticastNotificationRequest
```python
{
  "tokens": List[str],    # Required: List of device tokens
  "title": str,           # Required: Notification title
  "body": str,            # Required: Notification body
  "data": dict (optional) # Optional: Key-value data payload
}
```

### TopicNotificationRequest
```python
{
  "topic": str,           # Required: Topic name
  "title": str,           # Required: Notification title
  "body": str,            # Required: Notification body
  "data": dict (optional) # Optional: Key-value data payload
}
```

## Example Integration

### Python Client

```python
import requests

class TouthaNotificationClient:
    def __init__(self, api_key: str, base_url: str = "http://localhost:9000"):
        self.api_key = api_key
        self.base_url = base_url
        self.headers = {
            "X-API-Key": api_key,
            "Content-Type": "application/json"
        }
    
    def send_notification(self, token: str, title: str, body: str, data: dict = None):
        payload = {
            "token": token,
            "title": title,
            "body": body,
            "data": data or {}
        }
        response = requests.post(
            f"{self.base_url}/api/notify/send",
            json=payload,
            headers=self.headers
        )
        return response.json()

# Usage
client = TouthaNotificationClient("thoutha-notification-service-key-2024")
result = client.send_notification(
    token="device_token",
    title="Appointment",
    body="You have an appointment tomorrow"
)
```

---

## Support

For issues or feature requests, contact the development team.

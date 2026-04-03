"""
Quick reference guide for the Thoutha Notification Service
Use this for quick lookups and common tasks
"""

# ==============================================================================
# THOUTHA NOTIFICATION SERVICE - QUICK REFERENCE
# ==============================================================================

# STARTING THE SERVICE
# ==============================================================================
# Windows:
#   start.bat
#
# Linux/macOS:
#   ./start.sh
#
# Manual:
#   python main.py
#
# Service runs on: http://localhost:9000


# CONFIGURATION
# ==============================================================================
# Environment file: .env
#
# Key settings:
#   - FIREBASE_SERVICE_ACCOUNT_PATH: Path to Firebase credentials JSON
#   - API_KEY: API key for endpoints
#   - JWT_SECRET: Secret for JWT tokens
#   - HOST: Server host (default: localhost)
#   - PORT: Server port (default: 9000)
#   - LOG_LEVEL: Logging level (INFO, WARNING, ERROR)


# QUICK API EXAMPLES
# ==============================================================================

# 1. Health Check
# curl http://localhost:9000/api/notify/health

# 2. Send Single Notification
# curl -X POST http://localhost:9000/api/notify/send \
#   -H "X-API-Key: thoutha-notification-service-key-2024" \
#   -H "Content-Type: application/json" \
#   -d '{
#     "token": "device_token",
#     "title": "Title",
#     "body": "Message"
#   }'

# 3. Send Multicast
# curl -X POST http://localhost:9000/api/notify/send-multicast \
#   -H "X-API-Key: thoutha-notification-service-key-2024" \
#   -H "Content-Type: application/json" \
#   -d '{
#     "tokens": ["token1", "token2"],
#     "title": "Title",
#     "body": "Message"
#   }'

# 4. Send to Topic
# curl -X POST http://localhost:9000/api/notify/send-to-topic \
#   -H "X-API-Key: thoutha-notification-service-key-2024" \
#   -H "Content-Type: application/json" \
#   -d '{
#     "topic": "announcements",
#     "title": "Title",
#     "body": "Message"
#   }'

# 5. Get Statistics
# curl http://localhost:9000/api/notify/statistics \
#   -H "X-API-Key: thoutha-notification-service-key-2024"


# PYTHON INTEGRATION
# ==============================================================================
# from Notifications.services import notification_service
#
# # Send notification
# result = notification_service.send_notification(
#     token="device_token",
#     title="Title",
#     body="Message",
#     data={"key": "value"}
# )
#
# # Send to multiple devices
# result = notification_service.send_multicast(
#     tokens=["token1", "token2"],
#     title="Title",
#     body="Message"
# )
#
# # Send to topic
# result = notification_service.send_to_topic(
#     topic="announcements",
#     title="Title",
#     body="Message"
# )
#
# # Get stats
# stats = notification_service.get_statistics()


# ENDPOINTS REFERENCE
# ==============================================================================
# GET /                              - Root information
# GET /api/notify/health             - Health check
# POST /api/notify/send              - Send to single device
# POST /api/notify/send-with-retry   - Send with retry mechanism
# POST /api/notify/send-multicast    - Send to multiple devices
# POST /api/notify/send-to-topic     - Send to topic subscribers
# POST /api/notify/subscribe-topic   - Subscribe devices to topic
# POST /api/notify/unsubscribe-topic - Unsubscribe from topic
# GET /api/notify/statistics         - Get service statistics


# REQUEST MODELS
# ==============================================================================
# NotificationRequest:
#   {
#     "token": str,
#     "title": str,
#     "body": str,
#     "data": dict (optional)
#   }
#
# MulticastNotificationRequest:
#   {
#     "tokens": list[str],
#     "title": str,
#     "body": str,
#     "data": dict (optional)
#   }
#
# TopicNotificationRequest:
#   {
#     "topic": str,
#     "title": str,
#     "body": str,
#     "data": dict (optional)
#   }


# AUTHENTICATION
# ==============================================================================
# Method 1: API Key (Recommended)
#   Header: X-API-Key: thoutha-notification-service-key-2024
#
# Method 2: JWT Token (Optional)
#   Header: Authorization: Bearer <jwt_token>
#
# Unauthenticated endpoints:
#   - GET /
#   - GET /api/notify/health


# TROUBLESHOOTING
# ==============================================================================
# Firebase Credentials Not Found:
#   1. Download service account JSON from Firebase Console
#   2. Save as serviceAccountKey.json in Notifications directory
#   3. Restart service
#
# Port Already in Use:
#   1. Change PORT in .env (default: 9000)
#   2. Or kill process: netstat -ano | findstr :9000 (Windows)
#                      lsof -i :9000 (Linux/Mac)
#
# Authentication Failed:
#   1. Verify API key in .env
#   2. Check X-API-Key header matches
#   3. Update key if needed
#
# Dependency Issues:
#   pip install -r requirements.txt


# LOGGING & DEBUGGING
# ==============================================================================
# Log levels (in .env):
#   - INFO: Normal operations
#   - WARNING: Issues that need attention
#   - ERROR: Failures
#
# Log output: Console (stdout)
# Format: YYYY-MM-DD HH:MM:SS - module - LEVEL - message
#
# Example:
#   2024-03-27 10:30:45 - services.firebase_service - INFO - ✓ Firebase initialized


# PERFORMANCE TIPS
# ==============================================================================
# 1. Use multicast for sending to multiple users
# 2. Batch requests when possible
# 3. Monitor statistics regularly
# 4. Set LOG_LEVEL=WARNING for production
# 5. Firebase SDK handles connection pooling automatically


# FILE STRUCTURE
# ==============================================================================
# Notifications/
#   main.py                    - FastAPI app entry point
#   Notifications.py           - Module init
#   startup.py                 - Startup script
#   start.bat / start.sh       - OS-specific launchers
#   requirements.txt           - Dependencies
#   .env                       - Configuration
#   config/config.py           - Config management
#   models/notification.py     - Pydantic models
#   services/firebase_service.py   - Firebase SDK
#   services/notification_service.py - Core logic
#   routes/notification_routes.py   - API endpoints
#   security/auth.py           - Authentication
#   utils/logger.py            - Logging
#   SETUP_GUIDE.md            - Installation
#   API_DOCUMENTATION.md      - API reference
#   README.md                  - Overview


# DOCUMENTATION
# ==============================================================================
# README.md                  - Quick start guide
# SETUP_GUIDE.md            - Detailed installation
# API_DOCUMENTATION.md      - Complete API reference
# IMPLEMENTATION_SUMMARY.md - Features overview
# QUICK_REFERENCE.py        - This file


# RESPONSE EXAMPLES
# ==============================================================================
# Success Response:
#   {
#     "success": true,
#     "message": "Notification sent successfully",
#     "message_id": "projects/project/messages/123"
#   }
#
# Error Response:
#   {
#     "success": false,
#     "message": "Invalid request parameters",
#     "errors": ["Unregistered device"]
#   }
#
# Multicast Response:
#   {
#     "success": true,
#     "message": "Multicast completed",
#     "successful": 299,
#     "failed": 1,
#     "errors": [{"token_index": 0, "error": "..."}]
#   }
#
# Statistics Response:
#   {
#     "total_success": 1542,
#     "total_failures": 23,
#     "failure_log": ["[token] error", ...]
#   }


# ==============================================================================
# For complete documentation, see README.md, SETUP_GUIDE.md, or
# API_DOCUMENTATION.md in the Notifications directory
# ==============================================================================

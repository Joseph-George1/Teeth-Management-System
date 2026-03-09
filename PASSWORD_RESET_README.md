# Password Reset Service - Documentation

## Overview
The Password Reset Service provides a secure way for **Doctors** to reset their passwords using OTP (One-Time Password) verification via WhatsApp.

**Note:** This service currently only supports Doctor accounts. Admin accounts don't have phone numbers in the database schema, so they cannot use this password reset flow.

## Features
- **Phone-based authentication**: Uses phone number to identify users
- **OTP verification via WhatsApp**: Integrates with OTP_W.py service
- **Secure password hashing**: Uses BCrypt with 10 rounds (compatible with Spring Security)
- **Session management**: Temporary verification sessions with expiration
- **Doctor-only support**: Currently supports Doctor accounts (Admins lack phone numbers in schema)

## Architecture
```
┌─────────────┐      ┌──────────────────┐      ┌─────────────┐
│   Client    │─────>│ forgetpassword.py│─────>│ Oracle DB   │
└─────────────┘      └──────────────────┘      └─────────────┘
                            │
                            v
                     ┌──────────────┐      ┌─────────────┐
                     │  OTP_W.py    │─────>│  WhatsApp   │
                     │  (FastAPI)   │      │   (WAHA)    │
                     └──────────────┘      └─────────────┘
```

## API Endpoints

### 1. Request Password Reset
**POST** `/api/password-reset/request`

Sends an OTP to the user's WhatsApp number.

**Request Body:**
```json
{
  "phone_number": "+1234567890"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "OTP sent successfully to your WhatsApp",
  "expires_in_seconds": 300,
  "user_email": "user@example.com"
}
```

**Error Responses:**
- `400`: Invalid phone number format
- `404`: No account found with this phone number
- `429`: Too many requests (rate limited)
- `503`: OTP service unavailable

---

### 2. Verify OTP
**POST** `/api/password-reset/verify-otp`

Verifies the OTP code sent to the user.

**Request Body:**
```json
{
  "phone_number": "+1234567890",
  "otp": "123456"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "OTP verified successfully. You can now reset your password.",
  "session_expires_in_minutes": 10
}
```

**Error Responses:**
- `400`: Invalid OTP or missing fields
- `404`: No OTP found (need to request new one)
- `410`: OTP expired
- `429`: Maximum verification attempts exceeded

---

### 3. Change Password
**POST** `/api/password-reset/change-password`

Changes the user's password after successful OTP verification.

**Request Body:**
```json
{
  "phone_number": "+1234567890",
  "new_password": "newSecurePassword123",
  "confirm_password": "newSecurePassword123"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Password changed successfully. You can now login with your new password."
}
```

**Error Responses:**
- `400`: Validation errors (passwords don't match, too short, etc.)
- `403`: OTP not verified
- `410`: Verification session expired

---

### 4. Health Check
**GET** `/api/password-reset/health`

Check the service status and dependencies.

**Response (200):**
```json
{
  "service": "password-reset",
  "status": "running",
  "timestamp": "2026-03-09T10:30:00",
  "dependencies": {
    "database": "connected",
    "otp_service": "connected"
  }
}
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OTP_SERVICE_URL` | `http://127.0.0.1:8000` | URL of the OTP service (OTP_W.py) |
| `DB_USER` | `hr` | Oracle database username |
| `DB_PASSWORD` | `hr` | Oracle database password |
| `DB_DSN` | `localhost:1521/orclpdb` | Oracle database DSN |
| `FORGET_PASSWORD_PORT` | `7000` | Port for the password reset service |
| `SECRET_KEY` | Auto-generated | Flask secret key for sessions |
### Port Configuration

The system uses the following ports:
- **8080**: Spring Boot Backend
- **5010**: AI Chatbot Service  
- **8000**: OTP WhatsApp Service
- **6500**: Admin Dashboard
- **5173**: Proxy Server
- **7000**: Password Reset Service (this service)
### Example .env file
```bash
OTP_SERVICE_URL=http://127.0.0.1:8000
DB_USER=hr
DB_PASSWORD=hr
DB_DSN=localhost:1521/orclpdb
FORGET_PASSWORD_PORT=7000
SECRET_KEY=your-secret-key-here
```

---

## Installation & Setup

### 1. Install Dependencies
```bash
pip install -r requirements.txt
```

### 2. Verify Database Connection
Ensure Oracle database is running and accessible:
- Default user: `hr`
- Default password: `hr`
- Default DSN: `localhost:1521/orclpdb`

### 3. Start OTP Service
The password reset service depends on the OTP service. Start it first:
```bash
./astart -o
```

The OTP service will run on port 8000.

### 4. Start Password Reset Service
```bash
./astart -f
```

The service will run on port 7000 (or the configured port).

**Note:** If the OTP service is not running, the password reset service will automatically start it first.

### Alternative: Start All Services
To start all services including password reset:
```bash
./astart -w
```

---

## Usage Flow

### Complete Password Reset Flow

```
1. User Request
   └─> POST /api/password-reset/request
       Body: { "phone_number": "+1234567890" }
       ↓
   Response: OTP sent to WhatsApp

2. User Receives OTP
   └─> User checks WhatsApp
       ↓
   User gets 6-digit code (valid for 5 minutes)

3. User Verifies OTP
   └─> POST /api/password-reset/verify-otp
       Body: { "phone_number": "+1234567890", "otp": "123456" }
       ↓
   Response: OTP verified (session valid for 10 minutes)

4. User Changes Password
   └─> POST /api/password-reset/change-password
       Body: {
         "phone_number": "+1234567890",
         "new_password": "newPassword123",
         "confirm_password": "newPassword123"
       }
       ↓
   Response: Password changed successfully
```

---

## Security Features

1. **OTP Expiration**: OTPs expire after 5 minutes
2. **Rate Limiting**: Prevents OTP spam (60 seconds between requests)
3. **Attempt Limiting**: Maximum 3 OTP verification attempts
4. **Session Expiration**: Password change session expires after 10 minutes
5. **BCrypt Hashing**: Passwords are hashed using BCrypt (compatible with Spring Security)
6. **Phone Number Validation**: International format required (+country_code)
7. **Password Strength**: Minimum 8 characters required

---

## Database Schema

The service works with the following tables:

### DOCTOR Table (Password Reset Supported)
```sql
CREATE TABLE DOCTOR (
  ID NUMBER PRIMARY KEY,
  FIRST_NAME VARCHAR2(255) NOT NULL,
  LAST_NAME VARCHAR2(255) NOT NULL,
  EMAIL VARCHAR2(255) UNIQUE NOT NULL,
  PASSWORD VARCHAR2(255) NOT NULL,
  PHONE_NUMBER VARCHAR2(20) UNIQUE NOT NULL,
  -- other fields...
);
```

### PATIENTS Table (No Password Field)
```sql
CREATE TABLE PATIENTS (
  ID NUMBER PRIMARY KEY,
  FIRST_NAME VARCHAR2(255) NOT NULL,
  LAST_NAME VARCHAR2(255) NOT NULL,
  PHONE_NUMBER VARCHAR2(20) NOT NULL,
  -- Note: No EMAIL or PASSWORD fields in current schema
);
```

### ADMIN Table (No Phone Number Field)
```sql
CREATE TABLE ADMIN (
  ID NUMBER PRIMARY KEY,
  EMAIL VARCHAR2(255) UNIQUE NOT NULL,
  PASSWORD VARCHAR2(255) NOT NULL,
  -- Note: No PHONE_NUMBER field in current schema
  -- Admins cannot use phone-based password reset
);
```

---

## Testing

### Manual Testing with curl

1. **Request OTP:**
```bash
curl -X POST http://localhost:7000/api/password-reset/request \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+1234567890"}'
```

2. **Verify OTP:**
```bash
curl -X POST http://localhost:7000/api/password-reset/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone_number": "+1234567890", "otp": "123456"}'
```

3. **Change Password:**
```bash
curl -X POST http://localhost:7000/api/password-reset/change-password \
  -H "Content-Type: application/json" \
  -d '{
    "phone_number": "+1234567890",
    "new_password": "newPassword123",
    "confirm_password": "newPassword123"
  }'
```

4. **Health Check:**
```bash
curl http://localhost:7000/api/password-reset/health
```

### Using astart Script

```bash
# Start password reset service
./astart -f

# Start all services (includes password reset)
./astart -w

# Check service status
./astart -l

# Stop services interactively
./astart -s

# View password reset logs
./astart -L password_reset

# Follow password reset logs
./astart -F password_reset
```

---

## Error Handling

All errors follow a consistent format:

```json
{
  "success": false,
  "message": "Error description here"
}
```

Common HTTP status codes:
- `200`: Success
- `400`: Bad request / Validation error
- `403`: Forbidden (OTP not verified)
- `404`: Not found (user or OTP)
- `410`: Gone (expired OTP or session)
- `429`: Too many requests
- `500`: Internal server error
- `503`: Service unavailable (database or OTP service)

---

## Logging

The service logs important events:
- Database connections
- OTP requests and verifications
- Password changes
- Errors and exceptions

Log format:
```
2026-03-09 10:30:00 - forgetpassword - INFO - OTP sent successfully to +1234567890
```

---

## Integration with Frontend

### Example JavaScript/React Integration

```javascript
// Step 1: Request OTP
async function requestPasswordReset(phoneNumber) {
  const response = await fetch('http://localhost:7000/api/password-reset/request', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone_number: phoneNumber })
  });
  return await response.json();
}

// Step 2: Verify OTP
async function verifyOTP(phoneNumber, otp) {
  const response = await fetch('http://localhost:7000/api/password-reset/verify-otp', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone_number: phoneNumber, otp: otp })
  });
  return await response.json();
}

// Step 3: Change Password
async function changePassword(phoneNumber, newPassword, confirmPassword) {
  const response = await fetch('http://localhost:7000/api/password-reset/change-password', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      phone_number: phoneNumber,
      new_password: newPassword,
      confirm_password: confirmPassword
    })
  });
  return await response.json();
}
```

---

## Troubleshooting

### Common Issues

1. **"OTP service is currently unavailable"**
   - Ensure OTP_W.py is running on port 8000
   - Check OTP_SERVICE_URL environment variable

2. **"Database connection failed"**
   - Verify Oracle database is running
   - Check DB_USER, DB_PASSWORD, and DB_DSN settings
   - Ensure oracledb package is installed

3. **"No account found with this phone number"**
   - Phone number must exist in DOCTOR table with associated email and password
   - Phone number must be in international format (+country_code)
   - Note: Admin and Patient accounts cannot use this service

4. **"Password must be at least 8 characters long"**
   - Ensure new password meets minimum requirements

5. **"Verification session expired"**
   - Complete password change within 10 minutes of OTP verification
   - If expired, start over from Step 1

---

## Production Deployment

### Recommendations

1. **Use HTTPS**: Always use HTTPS in production
2. **Environment Variables**: Never hardcode credentials
3. **Database Connection Pooling**: Consider using connection pooling for better performance
4. **Monitoring**: Set up monitoring and alerting
5. **Rate Limiting**: Add additional rate limiting at nginx/reverse proxy level
6. **Logging**: Use proper logging service (e.g., ELK stack)
7. **Session Storage**: Consider Redis for session storage in multi-instance deployments

### Example systemd Service File

```ini
[Unit]
Description=Password Reset Service
After=network.target oracle.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/path/to/Teeth-Management-system
Environment="OTP_SERVICE_URL=http://127.0.0.1:8000"
Environment="DB_USER=hr"
Environment="DB_PASSWORD=hr"
Environment="DB_DSN=localhost:1521/orclpdb"
Environment="FORGET_PASSWORD_PORT=7000"
ExecStart=/usr/bin/python3 forgetpassword.py
Restart=always

[Install]
WantedBy=multi-user.target
```

---

## Support

For issues or questions, check:
1. Service logs for error details
2. Database connectivity
3. OTP service status
4. Network configuration

---

## License

This service is part of the Teeth Management System project.

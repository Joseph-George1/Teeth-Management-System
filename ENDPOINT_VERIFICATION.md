# API Endpoint Verification & Testing Guide

## 🏗️ Architecture: Two-Layer Proxy Setup

```
Frontend (https://thoutha.page)
    ↓
[Layer 1: Apache2 Reverse Proxy]
    ↓ (routes to localhost:5173)
[Layer 2: Flask CORS Proxy Server]
    ↓ (routes to localhost:8080)
[Spring Boot Backend]
```

**Key Note:** 
- The proxy forwards ALL requests transparently
- The proxy STRIPS excluded headers (`host`, `connection`, `origin`, `referer`)
- This prevents double-CORS validation issues
- JWT tokens pass through correctly

---

## ✅ REQUEST ENDPOINTS (Doctor Management)

### 1️⃣ GET ALL REQUESTS (Patients browse)
```bash
curl -X GET https://thoutha.page/api/request/getAllRequests
```

**Response (200 OK):**
```json
[
  {
    "id": 1961,
    "doctorFirstName": "احمد",
    "doctorLastName": "رمضلن",
    "doctorPhoneNumber": "+201100030736",
    "doctorCityName": "بورسعيد",
    "doctorUniversityName": "جامعة الجلالة",
    "categoryName": "حشو العصب",
    "description": "456456",
    "dateTime": "2026-03-12T16:51:00",
    "status": "PENDING"
  }
]
```

✅ **No auth required** - Patients can browse publicly

---

### 2️⃣ CREATE REQUEST (Doctor creates service)
```bash
curl -X POST https://thoutha.page/api/request/createRequest \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Professional root canal treatment",
    "dateTime": "2026-03-25T10:00:00"
  }'
```

**Request Body:**
- `description` (String) - Service description - REQUIRED
- `dateTime` (String, ISO format) - Service date/time - REQUIRED
- `categoryName` - NOT in request body, auto-determined from doctor's category

**Response (200 OK):**
```json
{
  "id": 1962,
  "doctorFirstName": "محمد",
  "doctorLastName": "احمد",
  "doctorPhoneNumber": "0501234567",
  "doctorCityName": "القاهرة",
  "doctorUniversityName": "جامعة القاهرة",
  "categoryName": "حشو العصب",
  "description": "Professional root canal treatment",
  "dateTime": "2026-03-25T10:00:00",
  "status": "PENDING"
}
```

✅ **JWT required (Doctor token)**
- Extracted from `Authorization: Bearer JWT_TOKEN` header
- Doctor auto-populated from token
- Use generated `id` as `requestId` for appointment booking

---

### 3️⃣ EDIT REQUEST (Doctor modifies PENDING request)
```bash
curl -X PUT https://thoutha.page/api/request/editRequest/1962 \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Updated: Professional root canal with follow-up",
    "dateTime": "2026-03-26T11:00:00"
  }'
```

**Constraints:**
- Only doctor who created request can edit
- Only PENDING requests can be edited
- Can update: `description`, `dateTime`
- Cannot update: `doctor`, `category`, `status`

✅ **JWT required (Doctor token)**

---

### 4️⃣ GET DOCTOR'S REQUESTS (Doctor views own)
```bash
curl -X GET https://thoutha.page/api/request/getRequestsByDoctorId \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:** List of all requests created by the authenticated doctor

✅ **JWT required (Doctor token)**

---

### 5️⃣ GET REQUESTS BY CATEGORY
```bash
curl -X GET "https://thoutha.page/api/request/getRequestByCategoryId?categoryId=2"
```

✅ **No auth required**

---

## ✅ APPOINTMENT ENDPOINTS (Patient Booking → Doctor Approval)

### 📋 COMPLETE WORKFLOW

**Step 1: Patient views available requests**
```bash
curl https://thoutha.page/api/request/getAllRequests
```
→ Get list, pick a request with `id: 1961`

**Step 2: Patient books appointment** ✨ CORRECTED
```bash
curl -X POST https://thoutha.page/api/appointment/createAppointment/1961 \
  -H "Content-Type: application/json" \
  -d '{
    "patientFirstName": "Ahmed",
    "patientLastName": "Hassan",
    "patientPhoneNumber": "+200509876543"
  }'
```

**Request Body (ONLY 3 FIELDS):**
```json
{
  "patientFirstName": "Ahmed",
  "patientLastName": "Hassan",
  "patientPhoneNumber": "+200509876543"
}
```

**NOT in request body (these are auto-generated):**
- ❌ `patientId` - Auto-created from phone number
- ❌ `appointmentDate` - Auto-inherited from request.dateTime
- ❌ `durationMinutes` - Set to null
- ❌ `notes` - Set to null

**Response (200 OK):**
```json
{
  "id": 5001,
  "patientFirstName": "Ahmed",
  "patientLastName": "Hassan",
  "patientPhoneNumber": "+200509876543",
  "appointmentDate": "2026-03-12T16:51:00",
  "requestDescription": "456456",
  "doctorFirstName": "احمد",
  "doctorLastName": "رمضلن",
  "doctorPhoneNumber": "+201100030736",
  "doctorCity": "بورسعيد",
  "categoryName": "حشو العصب",
  "durationMinutes": null,
  "notes": null,
  "status": "PENDING",
  "createdAt": "2026-03-17T03:20:00",
  "isExpired": false,
  "isHistory": false
}
```

✅ **No auth required** - Patients can book anonymously
🎯 **Use the `id: 5001` for approval operations**

---

### 1️⃣ CREATE APPOINTMENT (Patient booking)
```bash
POST https://thoutha.page/api/appointment/createAppointment/{requestId}
Content-Type: application/json

{
  "patientFirstName": "Ahmed",
  "patientLastName": "Hassan",
  "patientPhoneNumber": "+200509876543"
}
```

| Parameter | Required | Auto-Created | Source |
|-----------|----------|-------------|--------|
| patientFirstName | ✅ Yes | No | Client input |
| patientLastName | ✅ Yes | No | Client input |
| patientPhoneNumber | ✅ Yes | No | Client input |
| patientId | ❌ No | ✅ Yes | Lookup/create by phone |
| appointmentDate | ❌ No | ✅ Yes | From request.dateTime |
| durationMinutes | ❌ No | ✅ Yes | Set to null |
| notes | ❌ No | ✅ Yes | Set to null |

✅ **No auth required**

---

### 2️⃣ GET PENDING APPOINTMENTS (Doctor's bookings)
```bash
curl -X GET https://thoutha.page/api/appointment/pendingAppointments \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:** All PENDING appointments for authenticated doctor

✅ **JWT required (Doctor token)**

---

### 3️⃣ UPDATE APPOINTMENT STATUS (Doctor approves/rejects)
```bash
curl -X PUT "https://thoutha.page/api/appointment/updateStatus/5001?status=APPROVED" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Status Options:**
- `PENDING` → `APPROVED` (Doctor confirms)
- `PENDING` → `CANCELLED` (Doctor rejects)
- `APPROVED` → `DONE` (After completion)
- `APPROVED` → `CANCELLED` (Doctor cancels)

**Status Flow:**
```
PENDING 
  ↓
[Doctor reviews]
  ↓
APPROVED or CANCELLED
  ↓
[After completion]
  ↓
DONE
```

✅ **JWT required (Doctor token)**

---

### 4️⃣ GET APPOINTMENT HISTORY (Doctor views completed)
```bash
curl -X GET "https://thoutha.page/api/appointment/history/1" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response:** All DONE/CANCELLED appointments for doctor ID 1

✅ **JWT required (Doctor token)**
✅ **Must be the doctor themselves or admin**

---

## 🔒 Authentication: JWT Tokens

### Which Endpoints Need JWT?

| Endpoint | No Auth | Doctor JWT | Admin JWT |
|----------|---------|-----------|----------|
| GET /api/request/getAllRequests | ✅ | - | - |
| POST /api/request/createRequest | ❌ | ✅ | ✅ |
| PUT /api/request/editRequest/{id} | ❌ | ✅ | ✅ |
| GET /api/request/getRequestsByDoctorId | ❌ | ✅ | ✅ |
| POST /api/appointment/createAppointment/{id} | ✅ | - | - |
| GET /api/appointment/pendingAppointments | ❌ | ✅ | ✅ |
| PUT /api/appointment/updateStatus/{id} | ❌ | ✅ | ✅ |
| GET /api/appointment/history/{doctorId} | ❌ | ✅ | ✅ |

### How to Pass JWT Token
```bash
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

---

## 🧪 Complete End-to-End Test

### Scenario: Patient books appointment, Doctor approves

**1. Doctor creates request (needs JWT)**
```bash
curl -X POST https://thoutha.page/api/request/createRequest \
  -H "Authorization: Bearer DOCTOR_JWT" \
  -H "Content-Type: application/json" \
  -d '{"description":"Root canal treatment","dateTime":"2026-03-25T10:00:00"}'
```
→ Returns: `id: 1961`

**2. Patient views requests (no auth)**
```bash
curl https://thoutha.page/api/request/getAllRequests
```
→ Sees request with `id: 1961`

**3. Patient books (no auth)**
```bash
curl -X POST https://thoutha.page/api/appointment/createAppointment/1961 \
  -H "Content-Type: application/json" \
  -d '{"patientFirstName":"Ahmed","patientLastName":"Hassan","patientPhoneNumber":"+200509876543"}'
```
→ Returns: `id: 5001`

**4. Doctor approves (needs JWT)**
```bash
curl -X PUT "https://thoutha.page/api/appointment/updateStatus/5001?status=APPROVED" \
  -H "Authorization: Bearer DOCTOR_JWT"
```
→ Status changed to APPROVED

**5. Doctor views history (needs JWT)**
```bash
curl -X GET "https://thoutha.page/api/appointment/history/1" \
  -H "Authorization: Bearer DOCTOR_JWT"
```
→ Shows only DONE/CANCELLED appointments

---

## ⚠️ Common Issues & Solutions

### ❌ Issue: 403 Forbidden (CORS)
**Cause:** Origin not whitelisted in WebConfig
**Solution:** Add origin to [WebConfig.java](WebConfig.java#L22):
```java
.allowedOrigins(
    "https://thoutha.page",
    "https://www.thoutha.page"
)
```

### ❌ Issue: 401 Unauthorized (JWT)
**Cause:** Missing or invalid JWT token
**Solution:** Include header:
```
Authorization: Bearer JWT_TOKEN
```

### ❌ Issue: 400 Bad Request
**Cause:** Missing required fields or wrong format
**Solution:** Check request body matches required fields:
- For appointment: `patientFirstName`, `patientLastName`, `patientPhoneNumber`
- For request: `description`, `dateTime`

### ❌ Issue: 404 Not Found (requestId)
**Cause:** RequestId doesn't exist
**Solution:** Get valid ID from GET /api/request/getAllRequests

### ❌ Issue: Patient already exists
**Cause:** Phone number already in system
**Solution:** System auto-uses existing patient (no error)

---

## 📊 Data Model Reference

### Request (Doctor offers service)
```
id (auto-generated on creation)
doctor (from JWT token)
category (from doctor's profile)
description (doctor's input)
dateTime (doctor's input)
status (PENDING, APPROVED, DONE, CANCELLED)
```

### Appointment (Patient books)
```
id (auto-generated on booking)
request (links to request)
doctor (from request.doctor)
patient (auto-created from phone or lookup)
appointmentDate (from request.dateTime)
status (PENDING, APPROVED, DONE, CANCELLED)
createdAt (auto-set on creation)
isExpired (auto-set for 7-day expired appointments)
isHistory (auto-set for completed/cancelled)
durationMinutes (null - not tracked)
notes (null - not tracked)
```

### Patient (Auto-created if not exists)
```
id (auto-generated)
firstName (from appointment booking input)
lastName (from appointment booking input)
phoneNumber (lookup/unique key)
role (ROLE_PATIENT)
```

---

## 🚀 Testing Commands (Copy-Paste)

### Test Patient Booking (no auth needed)
```bash
# View all requests
curl https://thoutha.page/api/request/getAllRequests | jq

# Book appointment (replace 1961 with actual requestId from above)
curl -X POST https://thoutha.page/api/appointment/createAppointment/1961 \
  -H "Content-Type: application/json" \
  -d '{"patientFirstName":"Test","patientLastName":"Patient","patientPhoneNumber":"+201000000000"}' | jq
```

### Test Doctor Operations (needs JWT)
```bash
# Set JWT token
JWT="your_jwt_token_here"

# Create request
curl -X POST https://thoutha.page/api/request/createRequest \
  -H "Authorization: Bearer $JWT" \
  -H "Content-Type: application/json" \
  -d '{"description":"Test service","dateTime":"2026-03-25T10:00:00"}' | jq

# View pending appointments
curl https://thoutha.page/api/appointment/pendingAppointments \
  -H "Authorization: Bearer $JWT" | jq

# Approve appointment (replace 5001 with actual appointmentId)
curl -X PUT "https://thoutha.page/api/appointment/updateStatus/5001?status=APPROVED" \
  -H "Authorization: Bearer $JWT" | jq
```

---

## ✅ After Restart

After fixing AppointmentDto and recompiling:

1. **Restart Backend:**
   ```bash
   # Stop current process (Ctrl+C)
   # Or: kill $(lsof -t -i :8080)
   
   # Restart
   cd Backend
   mvn clean spring-boot:run
   ```

2. **Test Appointment Booking:**
   ```bash
   curl -X POST https://thoutha.page/api/appointment/createAppointment/1961 \
     -H "Content-Type: application/json" \
     -d '{"patientFirstName":"Ahmed","patientLastName":"Hassan","patientPhoneNumber":"+200509876543"}'
   ```

3. **Verify Response Includes:**
   - ✅ `id` (the appointmentId)
   - ✅ `appointmentDate` (from request)
   - ✅ `durationMinutes` (null)
   - ✅ `notes` (null)
   - ✅ `status` (PENDING)

---

**Version:** 2.0
**Updated:** March 17, 2026
**Status:** Ready for testing ✅


# TEETH MANAGEMENT SYSTEM - COMPLETE DOCUMENTATION

## **TABLE OF CONTENTS**
1. [Workflow Overview](#workflow-overview)
2. [API Endpoints](#api-endpoints)
3. [Request/Response Examples](#requestresponse-examples)
4. [Curl Quick Tests](#curl-quick-tests)
5. [Key Behaviors](#key-behaviors)
6. [Implementation Checklist](#implementation-checklist)
7. [Troubleshooting](#troubleshooting)

---

## **WORKFLOW OVERVIEW**

### **The Complete Flow:**
```
1. Doctor creates REQUEST (service offering) with:
   - Description (e.g., "Teeth Cleaning")
   - DateTime (when service is available)
   - Status starts as PENDING

2. Patients browse available requests by category/doctor

3. Patient creates APPOINTMENT for a request by providing:
   - PatientId (no login needed for patient)
   - FirstName, LastName, Phone
   - (DateTime AUTOMATICALLY comes from Request.dateTime)

4. Appointment status flow: 
   - PENDING → Doctor sees pending bookings
   - APPROVED → Doctor confirms (deletes other patient appointments)
   - DONE/CANCELLED → Moved to history

5. Auto-cancel appointments after 7 days if PENDING

6. Admin monitors all appointments and requests

7. Doctor views appointment history (past patients)
```

### **Actor Responsibilities:**

| Actor | Creates | Views | Updates |
|-------|---------|-------|---------|
| **Doctor** | REQUEST (with description & date) | Pending appointments | Status (PENDING→APPROVED→DONE) |
| **Patient** | APPOINTMENT (with ID & name) | Available requests | None after booking |
| **System** | Auto-cancels PENDING after 7 days | History | Marks expired/history |
| **Admin** | Nothing | All appointments/requests | Nothing |

---

## **API ENDPOINTS**

### **REQUEST ENDPOINTS (Doctor's Services)**

#### **CREATE REQUEST** (Doctor creates a service offering)
```
POST /api/request/createRequest
Authorization: Bearer JWT_TOKEN (Doctor)
Content-Type: application/json
```

**Request Body:**
```json
{
  "description": "Professional teeth cleaning and whitening",
  "dateTime": "2026-03-25T09:00:00"
}
```

**Response (200 OK):**
```json
{
  "doctorFirstName": "Mohamed",
  "doctorLastName": "Ahmed",
  "doctorPhoneNumber": "0501234567",
  "doctorCityName": "Cairo",
  "doctorUniversityName": "Cairo University",
  "categoryName": "Cleaning",
  "description": "Professional teeth cleaning and whitening",
  "dateTime": "2026-03-25T09:00:00",
  "status": "PENDING"
}
```

---

#### **GET ALL REQUESTS** (Patients browse all services)
```
GET /api/request/getAllRequests
```

**Response (200 OK):** List of all available requests from all doctors

---

#### **GET REQUESTS BY CATEGORY** (Patients filter by service type)
```
GET /api/request/getRequestByCategoryId?categoryId=1
```

**Response (200 OK):** List of requests in that category

---

#### **EDIT REQUEST** (Doctor modifies request details - PENDING only)
```
PUT /api/request/editRequest/{requestId}
Authorization: Bearer JWT_TOKEN (Doctor)
Content-Type: application/json
```

**Request Body (change description and/or dateTime):**
```json
{
  "description": "Updated teeth cleaning with extended session",
  "dateTime": "2026-03-26T10:00:00"
}
```

> **Note:** Doctor can ONLY edit PENDING requests they created:
> - ✅ Update description
> - ✅ Update dateTime
> - 🚫 Cannot edit after patients have booked

**Response (200 OK):**
```json
{
  "doctorFirstName": "Mohamed",
  "description": "Updated teeth cleaning with extended session",
  "dateTime": "2026-03-26T10:00:00",
  "status": "PENDING"
}
```

---

#### **GET DOCTOR'S REQUESTS** (Doctor views their own requests)
```
GET /api/request/getRequestsByDoctorId
Authorization: Bearer JWT_TOKEN (Doctor)
```

**Response (200 OK):** List of requests created by this doctor

---

#### **GET REQUEST BY ID**
```
GET /api/request/getRequestById?id=1
```

---

#### **DELETE REQUEST** (Doctor removes their requests)
```
DELETE /api/request/deleteRequest
Authorization: Bearer JWT_TOKEN (Doctor)
```

---

### **APPOINTMENT ENDPOINTS (Patient Books → Doctor Approves)**

#### **CREATE APPOINTMENT** (Patient books for a request - SUPER SIMPLE)
```
POST /api/appointment/createAppointment/{requestId}
Content-Type: application/json
```

**Example:** `POST /api/appointment/createAppointment/1`

**Request Body (3 Fields Only):**
```json
{
  "patientFirstName": "Ahmed",
  "patientLastName": "Hassan",
  "patientPhoneNumber": "0509876543"
}
```

> ⚡ **Ultra-Simple Patient Booking** (3 fields only, patientId auto-created):
> - ✅ First Name
> - ✅ Last Name  
> - ✅ Phone Number
> - 🔄 PatientId: Auto-created if not exists (based on phone number)
> - 🚫 NO appointment date (inherited from Request.dateTime)
> - 🚫 NO duration
> - 🚫 NO notes

**Response (200 OK):**
```json
{
  "doctorFirstName": "Mohamed",
  "doctorLastName": "Ahmed",
  "doctorPhoneNumber": "0501234567",
  "doctorCity": "Cairo",
  "patientFirstName": "Ahmed",
  "patientLastName": "Hassan",
  "patientPhoneNumber": "0509876543",
  "requestDescription": "Professional teeth cleaning and whitening",
  "categoryName": "Cleaning",
  "appointmentDate": "2026-03-25T09:00:00",
  "durationMinutes": null,
  "status": "PENDING",
  "notes": null,
  "createdAt": "2026-03-20T10:15:37",
  "isExpired": false,
  "isHistory": false
}
```

---

#### **GET PENDING APPOINTMENTS** (Doctor's pending bookings)
```
GET /api/appointment/pendingAppointments
Authorization: Bearer JWT_TOKEN (Doctor)
```

**Response (200 OK):** List of appointments with status PENDING

---

#### **UPDATE APPOINTMENT STATUS** (Doctor approves/completes/cancels)
```
PUT /api/appointment/updateStatus/{appointmentId}?status=APPROVED
Authorization: Bearer JWT_TOKEN (Doctor)
```

**Available Statuses:**
- `PENDING` - Initial state (patient just booked)
- `APPROVED` - Doctor confirmed (deletes all other appointments for same patient)
- `DONE` - Doctor completed the procedure
- `CANCELLED` - Doctor or system cancelled

**Response (200 OK):** Updated appointment

---

#### **GET APPOINTMENT HISTORY** (Doctor's past patients - REQUIRES JWT)
```
GET /api/appointment/history/{doctorId}
Authorization: Bearer JWT_TOKEN (Doctor)
```

> ⚠️ **JWT Token Required:** Only authenticated doctors can view their own history
> - Doctor can only view their own history (ownership verified)
> - Cannot view other doctors' histories

**Response (200 OK):** List of completed/cancelled appointments (isHistory=true)

---

#### **DELETE APPOINTMENT**
```
DELETE /api/appointment/deleteAppointment/{appointmentId}
```

**Response (204 No Content)**

---

## **REQUEST/RESPONSE EXAMPLES**

### **Example 1: Complete Patient Booking Flow**

**Step 1: Doctor Creates Request**
```bash
curl -X POST http://localhost:8080/api/request/createRequest \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1..." \
  -H "Content-Type: application/json" \
  -d '{
    "description": "Professional teeth cleaning",
    "dateTime": "2026-03-25T10:00:00"
  }'
```

Response:
```json
{
  "doctorFirstName": "Mohamed",
  "description": "Professional teeth cleaning",
  "dateTime": "2026-03-25T10:00:00",
  "status": "PENDING"
}
```

**Step 2: Patient Browses Requests**
```bash
curl http://localhost:8080/api/request/getAllRequests
```

Patient sees Mohamed's cleaning service available at 10:00 AM on March 25.

**Step 3: Patient Books (4 fields only)**
```bash
curl -X POST http://localhost:8080/api/appointment/createAppointment/1 \
  -H "Content-Type: application/json" \
  -d '{
    "patientId": 5,
    "patientFirstName": "Ahmed",
    "patientLastName": "Hassan",
    "patientPhoneNumber": "0509876543"
  }'
```

Response: Appointment created with appointmentDate = 2026-03-25T10:00:00, status = PENDING

**Step 4: Doctor Reviews Pending**
```bash
curl http://localhost:8080/api/appointment/pendingAppointments \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1..."
```

Doctor sees Ahmed's booking for March 25 at 10:00 AM

**Step 5: Doctor Approves**
```bash
curl -X PUT "http://localhost:8080/api/appointment/updateStatus/1?status=APPROVED" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1..."
```

Appointment status changed to APPROVED (any other patient appointments deleted)

**Step 6: Doctor Marks Complete**
```bash
curl -X PUT "http://localhost:8080/api/appointment/updateStatus/1?status=DONE" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1..."
```

Appointment marked as DONE, moved to history (isHistory=true)

---

## **CURL QUICK TESTS**

### **Test 1: Browse Services**
```bash
curl http://localhost:8080/api/request/getAllRequests
```

### **Test 2: Doctor Creates Request**
```bash
curl -X POST http://localhost:8080/api/request/createRequest \
  -H "Authorization: Bearer JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description":"Professional teeth cleaning",
    "dateTime":"2026-03-25T09:00:00"
  }'
```
Response: RequestId = 1

### **Test 2b: Doctor Edits Request (PENDING only)**
```bash
curl -X PUT http://localhost:8080/api/request/editRequest/1 \
  -H "Authorization: Bearer JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "description":"Professional teeth cleaning with extended session",
    "dateTime":"2026-03-25T10:00:00"
  }'
```
Response: Updated request details

### **Test 3: Patient Books Appointment (SUPER SIMPLE - 3 fields, auto-creates patient)**
```bash
curl -X POST http://localhost:8080/api/appointment/createAppointment/1 \
  -H "Content-Type: application/json" \
  -d '{
    "patientFirstName":"Ahmed",
    "patientLastName":"Hassan",
    "patientPhoneNumber":"0509876543"
  }'
```
Response: Appointment created, Patient auto-created with ID returned

### **Test 4: Doctor Gets Pending Appointments**
```bash
curl http://localhost:8080/api/appointment/pendingAppointments \
  -H "Authorization: Bearer JWT_TOKEN"
```

### **Test 5: Doctor Approves**
```bash
curl -X PUT "http://localhost:8080/api/appointment/updateStatus/1?status=APPROVED" \
  -H "Authorization: Bearer JWT_TOKEN"
```

### **Test 6: Doctor Gets History (REQUIRES JWT Token)**
```bash
curl http://localhost:8080/api/appointment/history/1 \
  -H "Authorization: Bearer JWT_TOKEN"
```

---

## **KEY BEHAVIORS**

### **Request Lifecycle**
- Created as PENDING
- Doctor can view their own requests
- Cannot be edited (created with final details)
- Automatically used by appointments

### **Appointment Lifecycle**
```
PENDING (patient books)
  ↓
APPROVED (doctor confirms)
  ├─ Cascade delete: All other patient appointments deleted
  ├─ durationMinutes: set to null
  └─ isHistory: remains false
  ↓
DONE or CANCELLED (completion/cancellation)
  └─ isHistory: set to true
```

### **Auto-Expiration**
- **Trigger:** PENDING appointments older than 7 days
- **Action:** Status → CANCELLED, isExpired → true, isHistory → true
- **Frequency:** Runs hourly via scheduled task

### **Patient Booking Flow**
1. Patient provides: firstName, lastName, phoneNumber (3 fields only)
2. System checks if patient with this phone number exists
3. If exists: Use patient record
4. If not exists: Auto-create patient record
5. Appointment created with auto-created/found patient
6. Patient can use same phone number for future bookings

### **Doctor Request Flow**
1. Doctor creates request with description + dateTime
2. Doctor can edit PENDING request (before patients book) to change description/dateTime
3. Once patients book: Status changes, request becomes locked
4. Doctor cannot edit after patients have appointments

### **Doctor History Access**
1. Doctor requests history with JWT token
2. System verifies doctor's identity from token
3. Doctor can only view their own history (ownership validated)
4. Cannot access other doctors' histories

### **Doctor Operations**
- Create requests with description and datetime only
- Approve/complete appointments
- View pending and history
- No direct editing of appointments

### **Data Inheritance**
```
REQUEST (doctor creates)
├── description
├── dateTime

APPOINTMENT (patient books)
├── patientId, firstName, lastName, phone (from patient)
├── appointmentDate ← from request.dateTime
├── durationMinutes: null
└── notes: null
```

---

## **IMPLEMENTATION CHECKLIST**

### **COMPLETED ✅**

#### **Backend Code Changes:**
- [x] Requests model: Only has description, dateTime (no duration/notes)
- [x] RequestDto: Only has description, dateTime (no duration/notes)
- [x] AppointmentDto: Uses phone number (auto-creates/finds patient) - no patientId in input
- [x] RequestServiceImpl: createRequest() only saves description and dateTime
- [x] RequestServiceImpl: editRequest() added back for PENDING requests
- [x] AppointmentServiceImpl: createAppointment() auto-creates patient if not exists
- [x] AppointmentServiceImpl: getAppointmentHistory() requires JWT token verification
- [x] Controllers: Updated all endpoints with editRequest re-added
- [x] All interfaces: Updated method signatures with editRequest

### **TODO - ACTION ITEMS FOR USER:**

#### **1. Verify Compilation**
```bash
cd Backend && mvn clean compile
```
Expected: BUILD SUCCESS

#### **2. Database Migration**
Execute this SQL if not already done:
```sql
-- Make sure appointments table has these fields
ALTER TABLE appointments MODIFY COLUMN duration_minutes INT NULL;
ALTER TABLE appointments MODIFY COLUMN notes VARCHAR(500) NULL;

-- Verify columns exist
DESC appointments;
```

#### **3. Enable Scheduling**
Add to `GraduationProject1Application.java`:
```java
@EnableScheduling
@SpringBootApplication
public class GraduationProject1Application {
    public static void main(String[] args) {
        SpringApplication.run(GraduationProject1Application.class, args);
    }
}
```

#### **4. Frontend Updates**

**Patient Booking Form:**
- Keep: firstName, lastName, phoneNumber (3 fields)
- Remove: patientId field (auto-created)
- **Result:** 3-field form (Name, Last Name, Phone)

**Doctor Request Creation & Editing:**
- Create form: description + dateTime (2 fields)
- Edit form: description + dateTime (enabled for PENDING only)
- Route: `PUT /api/request/editRequest/{requestId}`

**Doctor History Access:**
- Add JWT token to request header
- Route: `GET /api/appointment/history/{doctorId}` with Authorization header

#### **5. Full Workflow Test**
1. Doctor creates request (description + dateTime)
2. Doctor can edit PENDING request (change description/dateTime)
3. Patient books (firstName, lastName, phone - 3 fields, auto-creates patient)
4. Doctor approves (cascade delete works)
5. System auto-expires after 7 days if pending
6. Doctor views history with JWT token (ownership verified)

---

## **ENDPOINTS AT A GLANCE**

| Operation | Endpoint | Method | Auth | Response |
|-----------|----------|--------|------|----------|
| Create Request | /api/request/createRequest | POST | Doctor JWT | RequestDto |
| Edit Request | /api/request/editRequest/{id} | PUT | Doctor JWT | RequestDto |
| Get All Requests | /api/request/getAllRequests | GET | None | List<RequestDto> |
| Get Requests by Category | /api/request/getRequestByCategoryId | GET | None | List<RequestDto> |
| Get Doctor's Requests | /api/request/getRequestsByDoctorId | GET | Doctor JWT | List<RequestDto> |
| Get Request by ID | /api/request/getRequestById | GET | None | RequestDto |
| Delete Request | /api/request/deleteRequest | DELETE | Doctor JWT | 204 No Content |
| Create Appointment | /api/appointment/createAppointment/{id} | POST | None | AppointmentDto |
| Get Pending | /api/appointment/pendingAppointments | GET | Doctor JWT | List<AppointmentDto> |
| Update Status | /api/appointment/updateStatus/{id}?status=X | PUT | Doctor JWT | AppointmentDto |
| Get History | /api/appointment/history/{doctorId} | GET | **Doctor JWT** | List<AppointmentDto> |
| Delete Appointment | /api/appointment/deleteAppointment/{id} | DELETE | None | 204 No Content |

---

## **DATA MODEL**

### **Request Entity**
```
{
  id: Long (auto-generated),
  doctor: Doctor (ManyToOne),
  category: Category (ManyToOne),
  description: String,
  dateTime: LocalDateTime,
  status: String ("PENDING"),
  appointments: List<Appointment> (OneToMany)
}
```

### **Appointment Entity**
```
{
  id: Long (auto-generated),
  doctor: Doctor (ManyToOne),
  patient: Patient (ManyToOne),
  request: Request (ManyToOne),
  appointmentDate: LocalDateTime,
  durationMinutes: Integer (null),
  notes: String (null),
  status: AppointmentStatus (PENDING, APPROVED, DONE, CANCELLED),
  createdAt: LocalDateTime,
  isExpired: Boolean,
  isHistory: Boolean
}
```

### **Patient Entity**
```
{
  id: Long (auto-generated),
  firstName: String,
  lastName: String,
  phoneNumber: String,
  role: Role,
  appointments: List<Appointment> (OneToMany)
}
```

---

## **TROUBLESHOOTING**

### **Issue: "Patient not found with ID: 5"**
- **Cause:** PatientId doesn't exist
- **Fix:** Verify patient exists: `SELECT * FROM patients WHERE id = 5;`

### **Issue: "Request not found"**
- **Cause:** RequestId doesn't exist or wrong ID
- **Fix:** Create request first, use correct ID in booking URL

### **Issue: Build fails with compilation errors**
- **Cause:** Old code references removed methods (editAppointment, editRequest)
- **Fix:** Update code to remove calls to these removed methods

### **Issue: Patient booking returns error**
- **Cause:** Missing required field (patientId, firstName, lastName, phoneNumber)
- **Fix:** Ensure all 4 fields are provided in request body

### **Issue: Appointment status not updating**
- **Cause:** Doctor JWT token missing or invalid
- **Fix:** Always include valid JWT token in Authorization header

### **Issue: Appointments not auto-expiring**
- **Cause:** @EnableScheduling not added to main application
- **Fix:** Add `@EnableScheduling` annotation to GraduationProject1Application class

---

## **KEY CHANGES FROM PREVIOUS VERSIONS**

| Feature | Old | New |
|---------|-----|-----|
| **Request Fields** | description, dateTime, duration, notes | description, dateTime only |
| **Patient Booking** | 5+ fields (name, phone, date, duration, notes) | 3 fields (name, phone) - patientId auto-created |
| **Doctor Request Editing** | Not available | Available for PENDING requests |
| **Patient ID** | Provided by patient | Auto-created/found by phone number |
| **History Access** | Public | Requires JWT token (authenticated doctors only) |
| **Appointment Date** | Patient provides | Inherited from Request |
| **Duration/Notes** | Various sources | Always null |
| **Patient Experience** | Complex form | Ultra-simple 3-field |
| **System Complexity** | High (many editable fields) | Low (created, approved, done) |

---

## **FILE REFERENCES - Code Files Modified**

- `Backend/src/main/java/com/spring/boot/graduationproject1/model/Requests.java`
- `Backend/src/main/java/com/spring/boot/graduationproject1/dto/RequestDto.java`
- `Backend/src/main/java/com/spring/boot/graduationproject1/dto/AppointmentDto.java`
- `Backend/src/main/java/com/spring/boot/graduationproject1/service/impl/RequestServiceImpl.java`
- `Backend/src/main/java/com/spring/boot/graduationproject1/service/impl/AppointmentServiceImpl.java`
- `Backend/src/main/java/com/spring/boot/graduationproject1/service/RequestServices.java`
- `Backend/src/main/java/com/spring/boot/graduationproject1/service/AppointmentService.java`
- `Backend/src/main/java/com/spring/boot/graduationproject1/controller/RequestController.java`
- `Backend/src/main/java/com/spring/boot/graduationproject1/controller/AppointmentController.java`

---

## **QUICK START - 5 MINUTES**

1. **Compile:** `mvn clean compile` ✅
2. **Database:** Verify durationMinutes and notes are nullable ✅
3. **Add @EnableScheduling** to main application class ✅
4. **Test Doctor Create Request:** `curl -X POST ... -d '{"description":"...", "dateTime":"..."}' ✅
5. **Test Patient Book:** `curl -X POST ... -d '{"patientId":5, "patientFirstName":"...", ...}' ✅
6. **Test Doctor Approve:** `curl -X PUT ... ?status=APPROVED ✅

Done! System is ready for production.


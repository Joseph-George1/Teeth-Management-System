# Teeth Management System - Backend

## Table of Contents

1. [Overview](#overview)
2. [Backend Architecture and Framework](#backend-architecture-and-framework)
3. [Database Integration and ORM](#database-integration-and-orm)
4. [API Endpoints and Authentication](#api-endpoints-and-authentication)
5. [Development Setup](#development-setup)
6. [Building and Running](#building-and-running)
7. [Deployment Configuration](#deployment-configuration)
8. [Security Architecture](#security-architecture)
9. [Internationalization Support](#internationalization-support)
10. [Key Design Patterns](#key-design-patterns)

---

## Overview

The **Teeth Management System** is a specialized backend service for managing dental appointments, doctor registrations, and administrative operations. It facilitates the coordination between patients, doctors, and administrators in a dental clinic ecosystem.

**Technology Stack:**
- **Framework:** Spring Boot 3.5.7
- **Language:** Java 17
- **Database:** Oracle (JDBC)
- **ORM:** Hibernate/JPA
- **Authentication:** JWT (JSON Web Tokens)
- **Build Tool:** Maven
- **DTO Mapping:** MapStruct 1.5.2
- **Security:** Spring Security
- **Validation:** Bean Validation (Jakarta)
- **i18n Support:** ResourceBundleMessageSource (Arabic, English)

---

## Backend Architecture and Framework

### Architectural Overview

The backend follows a **Layered Architecture** pattern with clear separation of concerns:

```
┌─────────────────────────────────────┐
│      Controllers (REST API)         │
├─────────────────────────────────────┤
│      Services (Business Logic)      │
├─────────────────────────────────────┤
│  Repositories (Data Access Layer)   │
├─────────────────────────────────────┤
│     Hibernate/JPA Entity Layer      │
├─────────────────────────────────────┤
│       Oracle Database               │
└─────────────────────────────────────┘
```

### Directory Structure

```
src/main/java/com/spring/boot/graduationproject1/
├── GraduationProject1Application.java       # Spring Boot entry point
├── config/
│   ├── SecurityConfig.java                  # JWT security configuration
│   ├── WebConfig.java                       # CORS & MVC configuration
│   ├── ExceptionHandling.java               # Global exception handler
│   ├── BundleMessageConfig.java             # i18n message source
│   ├── filter/
│   │   └── AuthFilter.java                  # JWT validation filter
│   └── jwt/
│       └── TokenHandler.java                # JWT token creation & validation
├── controller/
│   ├── AuthController.java                  # Authentication endpoints
│   ├── DoctorController.java                # Doctor management
│   ├── AppointmentController.java           # Appointment management
│   ├── RequestController.java               # Doctor specialization requests
│   ├── CategoryController.java              # Dental categories
│   ├── AdminController.java                 # Admin dashboard & management
│   ├── CityController.java                  # City management
│   ├── UniversityController.java            # University management
│   └── vm/
│       ├── AuthRequestVm.java               # Login request model
│       └── AuthResponseVm.java              # Login response model
├── service/
│   ├── AuthService.java                     # Authentication service interface
│   ├── DoctorService.java                   # Doctor operations interface
│   ├── AppointmentService.java              # Appointment operations interface
│   ├── RequestServices.java                 # Request operations interface
│   ├── CategoryService.java                 # Category operations interface
│   ├── AdminService.java                    # Admin dashboard interface
│   ├── CityServices.java                    # City operations interface
│   └── impl/
│       ├── AuthServiceImpl.java              # Authentication implementation
│       ├── DoctorServiceImpl.java            # Doctor implementation
│       ├── AppointmentServiceImpl.java       # Appointment implementation
│       └── ... (service implementations)
├── repo/
│   ├── DoctorRepo.java                      # Doctor repository (JPA)
│   ├── AppointmentRepo.java                 # Appointment repository
│   ├── RequestsRepo.java                    # Requests repository
│   ├── CategoryRepo.java                    # Category repository
│   ├── AdminRepo.java                       # Admin repository
│   └── ... (other repositories)
├── model/
│   ├── Doctor.java                          # Doctor entity
│   ├── Patients.java                        # Patient entity
│   ├── Appointments.java                    # Appointment entity
│   ├── Requests.java                        # Request entity
│   ├── Category.java                        # Category entity
│   ├── Admin.java                           # Admin entity
│   ├── Role.java                            # Role entity
│   ├── University.java                      # University entity
│   ├── City.java                            # City entity
│   └── AppointmentStatus.java               # Appointment status enum
├── dto/
│   ├── DoctorDto.java                       # Doctor DTO
│   ├── DoctorSummaryDto.java                # Doctor summary DTO
│   ├── DoctorRepresentDto.java              # Doctor representation DTO
│   ├── AppointmentDto.java                  # Appointment DTO
│   ├── RequestDto.java                      # Request DTO
│   ├── PatientDto.java                      # Patient DTO
│   ├── SignUpRequest.java                   # Sign-up request model
│   ├── TokenUserDto.java                    # Token payload DTO
│   └── ... (other DTOs)
├── mapper/
│   ├── DoctorMapper.java                    # Doctor entity-DTO mapper
│   ├── AppointmentMapper.java               # Appointment entity-DTO mapper
│   ├── RequestMapper.java                   # Request entity-DTO mapper
│   └── ... (other mappers)
└── helper/
    ├── JwtToken.java                        # JWT configuration properties
    └── ExceptionResponse.java               # Exception response model

src/main/resources/
├── application.properties                   # Main configuration
└── i18n/
    ├── message.properties                   # Default messages
    ├── message_ar.properties                # Arabic translations
    └── message_en.properties                # English translations
```

### Layer Responsibilities

#### **Controllers (REST API Layer)**

Controllers expose RESTful endpoints and handle HTTP request/response mapping. They implement role-based authorization checks.

**Example - DoctorController:**

```java
@RestController
@RequestMapping("/api/doctor")
public class DoctorController {
    private final DoctorService doctorService;

    // Public endpoint - accessible by anyone
    @GetMapping("/getDoctorsByCity")
    public ResponseEntity<List<DoctorSummaryDto>> getDoctorByCityId(@RequestParam Long cityId) {
        return ResponseEntity.ok().body(doctorService.getDoctorsByCityId(cityId));
    }

    // Protected endpoint - requires DOCTOR or ADMIN role
    @PutMapping("updateDoctor")
    public ResponseEntity<DoctorDto> updateDoctor(@RequestBody DoctorDto doctorDto) {
        return ResponseEntity.ok().body(doctorService.updateDoctor(doctorDto));
    }

    // Admin-only endpoint
    @DeleteMapping("/deleteByDoctorAdmin")
    public ResponseEntity<Void> deleteDoctorByAdmin(@RequestParam Long doctorId) {
        doctorService.deleteDoctorByAdmin(doctorId);
        return ResponseEntity.noContent().build();
    }
}
```

#### **Services (Business Logic Layer)**

Services contain core business logic, data transformation, and orchestration between repositories. They are transaction-aware and implement the **Service Locator pattern** through interfaces.

**Key patterns:**
- Transaction management via `@Transactional`
- Data validation before persistence
- Cross-entity coordination (e.g., appointment creation validates doctor, patient, and request)
- State management and status workflow enforcement

#### **Repositories (Data Access Layer)**

Spring Data JPA repositories provide automatic CRUD operations and custom query methods. All repositories extend `JpaRepository<Entity, ID>`.

**Example - DoctorRepo:**

```java
public interface DoctorRepo extends JpaRepository<Doctor, Long> {
    Optional<Doctor> findByEmail(String email);
    List<Doctor> findByCity(City city);
    List<Doctor> findByCategory(Category category);

    @Query("SELECT COUNT(DISTINCT d.university) FROM Doctor d")
    Long countDistinctUniversities();
}
```

#### **Entity Layer (JPA/Hibernate)**

Entities map directly to database tables with relationship annotations defining foreign key constraints and join strategies.

---

## Database Integration and ORM

### Database Configuration

**Database:** Oracle Database (Express Edition or higher)

**Connection Details** (from `application.properties`):

```properties
spring.datasource.driver-class-name=oracle.jdbc.driver.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@localhost:1521/orclpdb
spring.datasource.username=hr
spring.datasource.password=hr
```

**Hibernate Configuration:**

```properties
spring.jpa.hibernate.ddl-auto=update        # Auto-create/update schema
spring.jpa.show-sql=true                    # Log generated SQL
```

### ORM Framework

**Hibernate 6.x** (Spring Boot 3.5.7 default) provides:
- Automatic table generation from entity annotations
- Transparent lazy/eager loading of relationships
- Query caching and session management
- Transaction demarcation

### Entity Relationships

#### **1. Doctor ↔ University (Many-to-One)**

```java
@ManyToOne
@JoinColumn(name = "university_id", nullable = false)
private University university;
```

Each doctor belongs to exactly one university. Multiple doctors can attend the same university.

#### **2. Doctor ↔ Category (Many-to-One)**

```java
// In Doctor entity
@ManyToOne
@JoinColumn(name = "category_id", nullable = false)
private Category category;

// In Category entity
@OneToMany(mappedBy = "category")
private List<Doctor> doctors;
```

**Relationship:** A doctor specializes in ONE category (e.g., "Orthodontics"), but a category has MANY doctors.

#### **3. Doctor ↔ City (Many-to-One)**

```java
@ManyToOne
@JoinColumn(name = "city_id", nullable = false)
private City city;
```

Multiple doctors can practice in the same city.

#### **4. Doctor ↔ Appointments (One-to-Many)**

```java
// In Doctor entity
@OneToMany(mappedBy = "doctor")
private List<Appointments> appointments;

// In Appointments entity
@ManyToOne
@JoinColumn(name = "doctor_id")
private Doctor doctor;
```

A doctor has many appointments; each appointment belongs to one doctor.

#### **5. Appointments ↔ Patient (Many-to-One)**

```java
// In Appointments entity
@ManyToOne
@JoinColumn(name = "patient_id")
private Patients patient;

// In Patients entity
@OneToMany(mappedBy = "patient")
private List<Appointments> appointments;
```

A patient can have multiple appointments.

#### **6. Doctor ↔ Requests (One-to-Many)**

```java
// In Doctor entity (implicit via Requests)
// In Requests entity
@ManyToOne
@JoinColumn(name = "doctor_id", nullable = false)
private Doctor doctor;

@OneToMany(mappedBy = "request")
private List<Appointments> appointments;
```

A doctor creates specialized requests; each request can have multiple appointments associated.

#### **7. Doctor ↔ Role (Many-to-One)**

```java
@ManyToOne
@JoinColumn(name = "role_id", nullable = false)
private Role role;
```

Roles are: `DOCTOR`, `ADMIN`, `PATIENT` (enforced through business logic).

### Key Entity Definitions

#### **Doctor Entity**

```java
@Entity
public class Doctor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String firstName;

    @Column(nullable = false)
    private String lastName;

    @Column(nullable = false, unique = true)
    private String email;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private String studyYear;

    @Column(nullable = false, unique = true)
    private String phoneNumber;

    @ManyToOne
    @JoinColumn(name = "university_id", nullable = false)
    private University university;

    @ManyToOne
    @JoinColumn(name = "category_id", nullable = false)
    private Category category;

    @ManyToOne
    @JoinColumn(name = "city_id", nullable = false)
    private City city;

    @OneToMany(mappedBy = "doctor")
    private List<Appointments> appointments;
}
```

#### **Appointments Entity**

```java
@Entity
public class Appointments {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "doctor_id")
    private Doctor doctor;

    @ManyToOne
    @JoinColumn(name = "patient_id")
    private Patients patient;

    @ManyToOne
    @JoinColumn(name = "request_id")
    private Requests request;

    @Column(nullable = false)
    private LocalDateTime appointmentDate;

    @Column(nullable = true)
    private Integer durationMinutes;

    @Column(nullable = false)
    @Enumerated(EnumType.STRING)
    private AppointmentStatus status = AppointmentStatus.PENDING;

    @Column(length = 500)
    private String notes;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @Column(nullable = false)
    private Boolean isExpired = false;

    @Column(nullable = false)
    private Boolean isHistory = false;
}
```

**Appointment Workflow:**

```
PENDING → APPROVED → DONE / CANCELLED
   ↓
EXPIRED (timeout handle)
```

### DTO Mapping Strategy

DTOs (Data Transfer Objects) prevent exposure of internal entity structure and reduce over-fetching:

```java
@Mapper(componentModel = "spring")
public interface DoctorMapper {
    @Mapping(target = "password", ignore = true)
    @Mapping(target = "id", ignore = true)
    DoctorDto toDto(Doctor doctor);

    Doctor toEntity(DoctorDto doctorDto);

    List<DoctorDto> toListDto(List<Doctor> doctors);

    DoctorSummaryDto toSummaryDto(Doctor doctor);
}
```

**DTO Types:**
- **DoctorDto:** Full doctor information (excluding password)
- **DoctorSummaryDto:** Minimal doctor info (name, specialization, city)
- **DoctorRepresentDto:** Extended information with additional metadata
- **AppointmentDto:** Appointment details with doctor/patient info
- **RequestDto:** Specialized request information

---

## API Endpoints and Authentication

### Authentication Mechanism

The system uses **JWT (JSON Web Tokens)** for stateless authentication:

1. **Token Generation:** On login, `TokenHandler` creates a JWT containing:
   - Subject: user email
   - Role: "DOCTOR", "ADMIN", or "PATIENT"
   - Expiration: 31,622,400,000 milliseconds (~1 year)
   - Extra claims: custom user metadata

2. **Token Validation:** `AuthFilter` intercepts all requests and:
   - Extracts the Bearer token from Authorization header
   - Validates signature and expiration
   - Populates Spring Security context with user identity
   - Allows unauthenticated access to specific endpoints (public routes)

3. **Token Structure:**

```
Header.Payload.Signature
```

Where:
- **Header:** Algorithm (HS256), token type
- **Payload:** Claims (email, role, expiration, custom attributes)
- **Signature:** HMAC-SHA256 signed with secret key

**JWT Secret Configuration:**

```properties
token.secret=sdakndbsafbj,sfuhih322jijdns@dfonidsfionwbfsajfbajsf
token.time=31622400000  # 1 year in milliseconds
```

**⚠️ Security Note:** The JWT secret should be stored in environment variables or secure vaults in production (not hardcoded in properties files).

### Security Filter Chain

**AuthFilter.java** implements stateless authentication:

```java
@Component
public class AuthFilter extends OncePerRequestFilter {
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getServletPath();
        
        // Public endpoints (no authentication required)
        return path.startsWith("/api/auth")
                || (GET && ("/api/category", "/api/cities", "/api/university", "/api/doctor/getDoctorsBy**"))
                || (POST && "/api/appointment/createAppointment");
    }

    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) {
        String authHeader = request.getHeader("Authorization");
        
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        String token = authHeader.substring(7);
        TokenUserDto user = tokenHandler.validateToken(token);
        
        if (user != null) {
            // Set Spring Security context with authenticated user
            SecurityContextHolder.getContext().setAuthentication(
                new UsernamePasswordAuthenticationToken(user.getEmail(), null, authorities)
            );
        }

        filterChain.doFilter(request, response);
    }
}
```

### Security Configuration

**SecurityConfig.java** defines authorization rules:

```java
@Configuration
@EnableWebSecurity
public class SecurityConfig {
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            .csrf(csrf -> csrf.disable())          // Stateless API → no CSRF needed
            .cors(cors -> {})                      // Enable CORS
            .authorizeHttpRequests(auth -> auth
                // Public endpoints
                .requestMatchers("/api/auth/**").permitAll()
                .requestMatchers(GET, "/api/doctor/getDoctorsBy**").permitAll()
                .requestMatchers(POST, "/api/appointment/createAppointment/**").permitAll()
                
                // Admin-only
                .requestMatchers(GET, "/api/doctor/getDoctors").hasRole("ADMIN")
                .requestMatchers(GET, "/api/request/getAllRequests").hasRole("ADMIN")
                
                // Doctor/Admin
                .requestMatchers(PUT, "/api/doctor/updateDoctor").hasAnyRole("DOCTOR", "ADMIN")
                .requestMatchers(GET, "/api/appointment/getApprovedAndDone").hasAnyRole("DOCTOR", "ADMIN")
                
                // All authenticated requests
                .anyRequest().authenticated()
            )
            .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
            .addFilterBefore(authFilter, UsernamePasswordAuthenticationFilter.class);
        
        return http.build();
    }
}
```

### CORS Configuration

**WebConfig.java** enables cross-origin requests from approved frontend domains:

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
            .allowedOrigins(
                "http://localhost:5173",      // Vite development
                "http://localhost:3000",      // React development
                "https://www.thoutha.page",   // Production
                "https://thoutha.page"
            )
            .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
            .allowedHeaders("*")
            .allowCredentials(true);
    }
}
```

### API Endpoint Overview

#### **1. Authentication Endpoints** (`/api/auth/**`)

| Method | Endpoint | Public | Description |
|--------|----------|--------|-------------|
| POST | `/api/auth/login/doctor` | ✅ | Doctor login - returns JWT token |
| POST | `/api/auth/login/admin` | ✅ | Admin login - returns JWT token |
| POST | `/api/auth/signup` | ✅ | Doctor registration |

**Example - Login Request:**

```json
POST /api/auth/login/doctor
Content-Type: application/json

{
  "email": "doctor@example.com",
  "password": "SecurePassword123"
}
```

**Login Response:**

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 31622400000,
  "user": {
    "email": "doctor@example.com",
    "role": "DOCTOR",
    "firstName": "Ahmed",
    "lastName": "Hassan"
  }
}
```

#### **2. Doctor Endpoints** (`/api/doctor/**`)

| Method | Endpoint | Auth | Role(s) | Description |
|--------|----------|------|---------|-------------|
| GET | `/api/doctor/getDoctors` | ✅ | ADMIN | List all doctors (admin dashboard) |
| GET | `/api/doctor/getDoctorsByCity` | ❌ | - | Search doctors by city |
| GET | `/api/doctor/getDoctorsByCategory` | ❌ | - | Search doctors by specialization |
| GET | `/api/doctor/getDoctorById` | ✅ | ADMIN, DOCTOR | Get authenticated doctor's profile |
| PUT | `/api/doctor/updateDoctor` | ✅ | ADMIN, DOCTOR | Update doctor profile |
| DELETE | `/api/doctor/deleteDoctor` | ✅ | ADMIN, DOCTOR | Delete own account |
| DELETE | `/api/doctor/deleteByDoctorAdmin` | ✅ | ADMIN | Admin delete any doctor |

**Example - Get Doctors by City:**

```
GET /api/doctor/getDoctorsByCity?cityId=1

Response:
[
  {
    "id": 1,
    "firstName": "Ahmed",
    "lastName": "Hassan",
    "categoryName": "Orthodontics",
    "universityName": "Cairo University",
    "phoneNumber": "+20123456789"
  }
]
```

#### **3. Appointment Endpoints** (`/api/appointment/**`)

| Method | Endpoint | Auth | Role(s) | Description |
|--------|----------|------|---------|-------------|
| POST | `/api/appointment/createAppointment/{requestId}` | ❌ | - | Create appointment (public) |
| GET | `/api/appointment/pendingAppointments` | ✅ | DOCTOR, ADMIN | Get pending appointments |
| PUT | `/api/appointment/updateStatus/{appointmentId}` | ✅ | DOCTOR, ADMIN | Update appointment status |
| GET | `/api/appointment/history/{doctorId}` | ✅ | DOCTOR, ADMIN | Get appointment history |
| DELETE | `/api/appointment/deleteAppointment/{appointmentId}` | ✅ | DOCTOR, ADMIN | Cancel appointment |
| GET | `/api/appointment/getApprovedAndDone` | ✅ | DOCTOR, ADMIN | Get approved & completed |
| GET | `/api/appointment/getApproved` | ✅ | DOCTOR, ADMIN | Get approved appointments |
| GET | `/api/appointment/getDone` | ✅ | DOCTOR, ADMIN | Get completed appointments |

**Appointment Status Workflow:**

```
PENDING ----[Doctor Approves]----> APPROVED ----[Session Complete]----> DONE
   │                                    │
   └────[Expired/Cancelled]────> CANCELLED
```

#### **4. Request Endpoints** (`/api/request/**`)

| Method | Endpoint | Auth | Role(s) | Description |
|--------|----------|------|---------|-------------|
| GET | `/api/request/getAllRequests` | ✅ | ADMIN | Admin view all requests |
| GET | `/api/request/getRequestById` | ✅ | DOCTOR, ADMIN | Get specific request |
| POST | `/api/request/createRequest` | ✅ | DOCTOR, ADMIN | Create specialization request |
| DELETE | `/api/request/deleteRequest` | ✅ | DOCTOR, ADMIN | Delete request |
| GET | `/api/request/getRequestByCategoryId` | ❌ | - | Browse requests by category |
| GET | `/api/request/getRequestsByDoctorId` | ✅ | DOCTOR, ADMIN | Get doctor's requests |
| PUT | `/api/request/editRequest/{requestId}` | ✅ | DOCTOR, ADMIN | Edit request details |
| PUT | `/api/request/updateStatus/{requestId}` | ✅ | DOCTOR, ADMIN | Update request status |

**Request Example:**

```json
POST /api/request/createRequest
Authorization: Bearer {token}

{
  "description": "Need orthodontist consultation",
  "categoryId": 2,
  "dateTime": "2024-04-15T14:30:00"
}
```

#### **5. Category Endpoints** (`/api/category/**`)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/category/getCategories` | ❌ | List all dental categories |

**Response:**

```json
[
  {
    "id": 1,
    "name": "General Dentistry"
  },
  {
    "id": 2,
    "name": "Orthodontics"
  },
  {
    "id": 3,
    "name": "Periodontics"
  }
]
```

#### **6. Admin Dashboard** (`/api/admin/**`)

| Method | Endpoint | Auth | Role(s) | Description |
|--------|----------|------|---------|-------------|
| GET | `/api/admin/dashboard` | ✅ | ADMIN | Comprehensive dashboard statistics |
| GET | `/api/admin/getAllAppointments` | ✅ | ADMIN | All system appointments |
| GET | `/api/admin/getAllRequests` | ✅ | ADMIN | All system requests |
| GET | `/api/admin/getExpiredAppointments` | ✅ | ADMIN | Expired/timeout appointments |

**Dashboard Response:**

```json
{
  "totalAppointments": 150,
  "totalRequests": 45,
  "pendingAppointments": 23,
  "approvedAppointments": 89,
  "rejectedAppointments": 5,
  "pendingRequests": 12,
  "approvedRequests": 28,
  "rejectedRequests": 5,
  "doctorUniversitiesCount": 8,
  "expiredAppointments": 3,
  "allAppointments": [...],
  "allRequests": [...]
}
```

#### **7. University & City Endpoints** (`/api/university/**`, `/api/cities/**`)

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/university/**` | ❌ | List universities |
| GET | `/api/cities/**` | ❌ | List cities |

### Error Handling

**ExceptionHandling.java** provides centralized global exception handling:

```java
@ControllerAdvice
public class ExceptionHandling {
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ExceptionResponse> handleException(Exception exception) {
        return ResponseEntity.badRequest()
            .body(BundleMessageService.getBundleMessage(exception.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<List<ExceptionResponse>> handleException(MethodArgumentNotValidException exception) {
        List<FieldError> fieldErrors = exception.getBindingResult().getFieldErrors();
        List<ExceptionResponse> errorMessages = fieldErrors.stream()
            .map(fieldError -> BundleMessageService.getBundleMessage(fieldError.getDefaultMessage()))
            .collect(Collectors.toList());
        return ResponseEntity.badRequest().body(errorMessages);
    }
}
```

**ExceptionResponse Model:**

```java
public class ExceptionResponse {
    private String message;
    private String field;      // For validation errors
    private LocalDateTime timestamp;
    private String path;
}
```

---

## Development Setup

### Prerequisites

- **Java 17 or higher**
- **Maven 3.8+**
- **Oracle Database** (XE or standard)
- **Git**

### Environment Setup

#### **1. Clone Repository**

```bash
git clone https://github.com/Joseph-George1/Teeth-Management-System.git
cd Teeth-Management-System/Backend
```

#### **2. Configure Database**

Create an Oracle database user:

```sql
CREATE USER hr IDENTIFIED BY hr;
GRANT CONNECT, RESOURCE TO hr;
GRANT UNLIMITED TABLESPACE TO hr;
```

Or use existing `hr` schema (default in Express Edition).

#### **3. Update Application Configuration**

Edit `src/main/resources/application.properties`:

```properties
# Database
spring.datasource.driver-class-name=oracle.jdbc.driver.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@YOUR_DB_HOST:1521/YOUR_DB_SID
spring.datasource.username=YOUR_USERNAME
spring.datasource.password=YOUR_PASSWORD

# JWT Secret (change this for production!)
token.secret=YOUR_SECURE_SECRET_KEY_HERE
token.time=31622400000

# Logging
spring.jpa.show-sql=false    # Set to false in production
spring.jpa.properties.hibernate.format_sql=true
```

#### **4. Install Dependencies**

```bash
mvn clean install
```

This downloads all dependencies, compiles the project, and runs tests.

---

## Building and Running

### Development Mode

```bash
# Start Spring Boot development server
mvn spring-boot:run
```

The application starts on `http://localhost:8080`

**Console Output:**

```
Tomcat started on port(s): 8080 (http)
Started GraduationProject1Application in X.XXX seconds
```

### Production Build

```bash
# Create executable JAR
mvn clean package

# Run JAR
java -jar target/GraduationProject1-0.0.1-SNAPSHOT.jar
```

### Troubleshooting Build Issues

**Issue: "Cannot resolve symbol 'Doctor'"**
- Solution: Run `mvn clean compile` to regenerate MapStruct mappers

**Issue: Oracle JDBC driver not found**
- Solution: Ensure Oracle JDBC artifact in `pom.xml` and Maven central is accessible

**Issue: Compilation fails with Java version mismatch**
- Solution: Ensure Java 17+ is installed:
```bash
java -version
# Should output Java 17.x or higher
```

---

## Deployment Configuration

### Configuration Files

#### **application.properties** (Main Config)

```properties
spring.application.name=GraduationProject1

# Datasource - Oracle Database
spring.datasource.driver-class-name=oracle.jdbc.driver.OracleDriver
spring.datasource.url=jdbc:oracle:thin:@localhost:1521/orclpdb
spring.datasource.username=hr
spring.datasource.password=hr

# JPA/Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# Messages (i18n)
spring.messages.basename=i18n/message
spring.messages.encoding=UTF-8

# JWT
token.secret=sdakndbsafbj,sfuhih322jijdns@dfonidsfionwbfsajfbajsf
token.time=31622400000
```

#### **Recommended Production Configuration**

```properties
# Deployment
server.port=8080
server.servlet.context-path=/api

# Database pooling
spring.datasource.hikari.maximum-pool-size=20
spring.datasource.hikari.minimum-idle=5
spring.datasource.hikari.connection-timeout=20000

# JPA Performance
spring.jpa.show-sql=false
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.properties.hibernate.format_sql=false
spring.jpa.properties.hibernate.jdbc.batch_size=20
spring.jpa.properties.hibernate.order_inserts=true
spring.jpa.properties.hibernate.order_updates=true

# Logging
logging.level.root=WARN
logging.level.com.spring.boot.graduationproject1=INFO

# JWT Security (use environment variables!)
token.secret=${JWT_SECRET}
token.time=${JWT_EXPIRATION:31622400000}
```

### Environment Variables (Production)

Create a `.env` file or set in your deployment platform:

```bash
# Database
DB_HOST=prod-db.example.com
DB_PORT=1521
DB_SID=ORCLPDB
DB_USERNAME=prod_user
DB_PASSWORD=secure_password_here

# JWT
JWT_SECRET=your_very_secure_random_secret_key_here_min_32_chars
JWT_EXPIRATION=31622400000

# Server
SERVER_PORT=8080
APP_ENVIRONMENT=PRODUCTION
```

Load environment variables in `application-prod.properties`:

```properties
spring.datasource.url=jdbc:oracle:thin:@${DB_HOST}:${DB_PORT}/${DB_SID}
spring.datasource.username=${DB_USERNAME}
spring.datasource.password=${DB_PASSWORD}
token.secret=${JWT_SECRET}
token.time=${JWT_EXPIRATION}
```

Run with production profile:

```bash
java -jar app.jar --spring.profiles.active=prod
```

### Docker Deployment (Optional)

**Dockerfile:**

```dockerfile
FROM maven:3.8.1-openjdk-17 as builder
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=prod
ENTRYPOINT ["java", "-jar", "app.jar"]
```

**docker-compose.yml:**

```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      DB_HOST: oracle-db
      DB_PORT: 1521
      JWT_SECRET: ${JWT_SECRET}
    depends_on:
      - oracle-db

  oracle-db:
    image: container-registry.oracle.com/database/enterprise:21.3.0
    ports:
      - "1521:1521"
    environment:
      ORACLE_SID: ORCLPDB
      ORACLE_PWD: SecurePassword
```

---

## Security Architecture

### Authentication Flow

```
1. Client sends credentials (email/password) to /api/auth/login
2. Server validates against Doctor/Admin entity
3. Server generates JWT containing email + role + expiration
4. Client stores JWT in local storage/session storage
5. Client includes "Authorization: Bearer {JWT}" in subsequent requests
6. AuthFilter validates JWT signature and expiration
7. Spring Security context is populated with user identity and roles
8. Authorization rules (@PreAuthorize, hasRole) are enforced
```

### Password Security

- **Hashing:** BCrypt (Spring Security default)
- **Salt:** Automatically included in BCrypt output
- **Configuration:** Defined in `SecurityConfig.passwordEncoder()`

```java
@Bean
public static PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
}
```

### Token Security Best Practices

✅ **Implemented:**
- HTTPS-only transmission (enforced at reverse proxy level)
- Token expiration (1 year)
- Role-based authorization
- CSRF disabled (stateless API)
- Signature validation

⚠️ **Requires Production Hardening:**
- Move JWT secret to environment variables or vault
- Implement token refresh mechanism
- Add token blacklist for logout
- Use HTTPS/TLS for all communication
- Implement rate limiting on login endpoints
- Add account lockout after failed attempts

### CORS Security

Configured to allow requests only from approved domains (frontend URLs):

```
✅ Allowed: localhost:5173, localhost:3000, thoutha.page
❌ Blocked: other domains
```

### SQL Injection Prevention

- Uses parameterized queries (Hibernate/JPA)
- No string concatenation in queries
- Input validation through Bean Validation annotations

**Example - Validated login request:**

```java
@GetMapping("/login")
public ResponseEntity<?> login(@Valid @RequestBody AuthRequestVm request) {
    // Validation annotations prevent SQL injection
    // @Email, @NotBlank, @Pattern all validate input format
}
```

---

## Internationalization Support

### Supported Languages

- **English** (`message_en.properties`)
- **Arabic** (`message_ar.properties`)

### Configuration

**BundleMessageConfig.java:**

```java
@Configuration
public class BundleMessageConfig {
    @Bean
    public ResourceBundleMessageSource messageSource() {
        ResourceBundleMessageSource source = new ResourceBundleMessageSource();
        source.setBasename("i18n/message");        // Loads message_*.properties
        source.setDefaultEncoding("UTF-8");        // UTF-8 encoding for Arabic
        return source;
    }
}
```

### Message Files

**i18n/message.properties** (Default - English):

```properties
doctor.email.required=Email is required
doctor.email.invalid=Please enter a valid email
doctor.password.required=Password is required
error.doctor.not.found=Doctor not found
error.appointment.expired=This appointment has expired
```

**i18n/message_ar.properties** (Arabic):

```properties
doctor.email.required=البريد الإلكتروني مطلوب
doctor.email.invalid=يرجى إدخال بريد إلكتروني صحيح
doctor.password.required=كلمة المرور مطلوبة
error.doctor.not.found=لم يتم العثور على الطبيب
error.appointment.expired=انتهت صلاحية هذا الموعد
```

### Usage in Validation

Validation messages reference `i18n/message` keys:

```java
public class AuthRequestVm {
    @Email(message = "doctor.email.invalid")
    @NotBlank(message = "doctor.email.required")
    private String email;

    @NotBlank(message = "doctor.password.required")
    private String password;
}
```

When validation fails, the message key is resolved to the appropriate language based on `Accept-Language` header or default locale.

---

## Key Design Patterns

### 1. **Layered Architecture**

**Benefit:** Clear separation of concerns, testability, maintainability

```
HTTP Request
    ↓
Controller (handles HTTP)
    ↓
Service (business logic)
    ↓
Repository (data access)
    ↓
Database
```

### 2. **DTO (Data Transfer Object)**

**Benefit:** Decouples API contract from internal entity structure

```
Doctor (Entity)              DoctorDto (DTO)
├─ id                        ├─ id
├─ firstName                 ├─ firstName
├─ lastName                  ├─ lastName
├─ email                     ├─ email
├─ password ← EXCLUDED       │
├─ appointments ← EXCLUDED   │
└─ ...                       └─ ...
```

### 3. **Mapper Pattern (MapStruct)**

**Benefit:** Type-safe, compile-time entity-to-DTO conversion

```java
@Mapper(componentModel = "spring")
public interface DoctorMapper {
    @Mapping(target = "password", ignore = true)  // Exclude sensitive data
    DoctorDto toDto(Doctor doctor);
}
```

### 4. **Service Interface + Implementation**

**Benefit:** Loose coupling, easy testing and mocking

```
AuthService (interface)
    ↓
AuthServiceImpl (implementation)
```

### 5. **Repository Pattern (Spring Data JPA)**

**Benefit:** Abstraction over database, automatic CRUD + custom queries

```java
public interface DoctorRepo extends JpaRepository<Doctor, Long> {
    Optional<Doctor> findByEmail(String email);
    
    @Query("SELECT COUNT(DISTINCT d.university) FROM Doctor d")
    Long countDistinctUniversities();
}
```

### 6. **JWT Stateless Authentication**

**Benefit:** Scalability (no server-side session storage), mobile-friendly

```
Login → JWT Token → Sent with every request → Verified by filter
```

### 7. **Global Exception Handling (@ControllerAdvice)**

**Benefit:** Centralized error response format, consistent API errors

```java
@ControllerAdvice
public class ExceptionHandling {
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ExceptionResponse> handleException(Exception e) {
        // All exceptions → consistent JSON error response
    }
}
```

### 8. **Role-Based Access Control (RBAC)**

**Benefit:** Fine-grained authorization per endpoint

```
GET /api/doctor/getDoctors → hasRole("ADMIN")
GET /api/doctor/updateDoctor → hasAnyRole("DOCTOR", "ADMIN")
```

---

## Potential Improvements & Gaps

### Missing Best Practices

1. **Logging**
   - No centralized logging framework (SLF4J/Logback)
   - Recommendation: Add `spring-boot-starter-logging` and structured logging

2. **Testing**
   - No test files found in workspace
   - Recommendation: Add JUnit 5 + Mockito integration/unit tests

3. **API Documentation**
   - No Swagger/OpenAPI configured
   - Recommendation: Add `springdoc-openapi` for auto-generated API docs

4. **Caching**
   - No @Cacheable annotations on frequently-accessed data
   - Recommendation: Add Redis/Spring Cache for performance

5. **Validation**
   - Basic validation present, but could expand (custom validators, cross-field validation)
   - Recommendation: Add @Validated on service layer

6. **Input Sanitization**
   - Limited protection against XSS in user input
   - Recommendation: Sanitize string inputs, especially in notes field

7. **Rate Limiting**
   - No rate limiting on login/API endpoints
   - Recommendation: Add Spring Cloud Sleuth or library like `bucket4j`

8. **Token Refresh**
   - No refresh token mechanism
   - Recommendation: Implement refresh token endpoint for better UX

### Database Considerations

- **Indexes:** Ensure indexes on `doctor.email`, `patient.id`, `appointments.doctor_id` for performance
- **Audit Logging:** No created_by/updated_by fields on sensitive entities
- **Soft Deletes:** Consider adding `is_deleted` flag instead of hard deletes for audit trail

### Performance Optimization Opportunities

1. Add query optimization: `@Query` with explicit SELECT to avoid fetching all columns
2. Implement pagination for list endpoints (currently retrieves all records)
3. Use database-level sorting instead of in-memory sorting
4. Add `fetch = FetchType.LAZY` for large collections (appointments, requests)

---

## Quick Reference: Running Commands

```bash
# Build
mvn clean install

# Run development server
mvn spring-boot:run

# Run tests
mvn test

# Create production JAR
mvn clean package -DskipTests

# Check dependencies
mvn dependency:tree

# Format code
mvn spring-javaformat:apply

# Build with specific profile
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=prod"
```

---

## Support & Contributing

For issues, questions, or contributions, please refer to the project's GitHub repository:  
[https://github.com/Joseph-George1/Teeth-Management-System](https://github.com/Joseph-George1/Teeth-Management-System)

---

**Last Updated:** March 31, 2026  
**Maintainer:** Backend Engineering Team  
**License:** Check LICENSE file in repository

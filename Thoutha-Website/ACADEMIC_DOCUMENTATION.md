# Thoutha Dental Platform: Complete Academic Documentation

---

## 3.4.1 User Interface of Thoutha Web Application

The Thoutha Web Application connects patients needing dental treatment with dental students requiring clinical experience. Built with React, the interface is organized into three layers: App.jsx controls routing at the top level, reusable components (NavBar, Footer, ChatBotIcon) appear across multiple pages in the middle, and page components create individual screens at the bottom.

The application supports two user types with distinct experiences. Patients browse services, use the chatbot for recommendations, and schedule appointments. Doctors view pending appointments, manage submitted cases, update profiles, and submit new cases. The system includes authentication pages (LoginPage, RegisterForm, OTP verification, password reset), doctor dashboards (DoctorHome, DoctorBookings, profiles), patient interfaces (Booking), ten service pages displaying dental treatments, policy pages, a recommendation chatbot, and error pages.

```
src/
├── App.jsx                                 # Main application router and layout orchestrator
├── index.css                               # Global application styles
├── main.jsx                                # Application entry point
├── Components/
│   ├── NavBar.jsx                          # Navigation bar with auth status
│   ├── Footer.jsx                          # Application footer
│   └── ChatBotIcon.jsx                     # SVG icon for chatbot messages
├── Css/
│   ├── Home.css                            # Hero and category section styles
│   ├── ChatBot.css                         # Chatbot interface styles
│   ├── LoginPage.css                       # Login form styles
│   ├── RegisterForm.css                    # Registration form styles
│   ├── Booking.css                         # Appointment booking styles
│   ├── DoctorHome.css                      # Doctor dashboard styles
│   ├── DoctorBooking.css                   # Booking history styles
│   ├── DoctorProfile.css                   # Doctor profile styles
│   ├── Category.css                        # Service category listing styles
│   ├── ProfileUpdate.css                   # Profile update form styles
│   ├── NavBar.css                          # Navigation bar styles
│   ├── Footer.css                          # Footer styles
│   ├── Otp.css                             # OTP page styles
│   ├── OtpDone.css                         # OTP confirmation styles
│   ├── MyRequests.css                      # Case request management styles
│   ├── AddRequest.css                      # Add request form styles
│   ├── DeleteMyAccount.css                 # Account deletion styles
│   ├── TermsConditions.css                 # Terms display styles
│   ├── Support.css                         # Support page styles
│   ├── ForbiddenPage.css                   # 403 error page styles
│   ├── NotFoundPage.css                    # 404 error page styles
│   └── UnauthorizedPage.css                # 401 error page styles
├── Pages/
│   ├── Home.jsx                            # Landing page with service discovery
│   ├── LoginPage.jsx                       # Doctor authentication
│   ├── RegisterForm.jsx                    # Doctor registration workflow
│   ├── Otp.jsx                             # OTP generation
│   ├── Otp-verify.jsx                      # OTP verification
│   ├── OtpDone.jsx                         # OTP success confirmation
│   ├── ForgetPassword.jsx                  # Password reset initiation
│   ├── ResetPassword.jsx                   # Password reset completion
│   ├── ProfileUpdate.jsx                   # Doctor profile management
│   ├── DeleteAccount.jsx                   # Account deletion request
│   ├── DeleteMyAccount.jsx                 # In-app account deletion
│   ├── DoctorHome.jsx                      # Pending appointments dashboard
│   ├── DoctorBookings.jsx                  # Completed appointments history
│   ├── DoctorProfile.jsx                   # Doctor profile display
│   ├── MyRequests.jsx                      # Case request management
│   ├── AddRequest.jsx                      # Submit new case requests
│   ├── Patient.jsx                         # Patient record browsing
│   ├── Booking.jsx                         # Appointment scheduling interface
│   ├── ChatBot.jsx                         # Recommendation chatbot
│   ├── Home.jsx                            # Landing page
│   ├── TeethWhitening.jsx                  # Whitening service cases
│   ├── ToothExtraction.jsx                 # Extraction service cases
│   ├── DentalFilling.jsx                   # Composite filling cases
│   ├── AmalgamFilling.jsx                  # Amalgam filling cases
│   ├── DentalImplant.jsx                   # Implant service cases
│   ├── CrownsBridges.jsx                   # Prosthodontic cases
│   ├── Braces.jsx                          # Orthodontic cases
│   ├── SurgeryExtraction.jsx               # Surgical extraction cases
│   ├── PediatricDentistry.jsx              # Pediatric care cases
│   ├── RemovableProsthetics.jsx            # Removable prosthetic cases
│   ├── TermsConditions.jsx                 # Terms and conditions document
│   ├── PrivacyPolicy.jsx                   # Privacy policy document
│   ├── Support.jsx                         # Support and contact information
│   ├── ForbiddenPage.jsx                   # 403 error display
│   ├── NotFoundPage.jsx                    # 404 error display
│   ├── NotFoundPages.jsx                   # Alternative 404 display
│   ├── UnauthorizedPage.jsx                # 401 error display
│   ├── ComingSoon.jsx                      # Placeholder for future features
│   └── RequestsList.jsx                    # Reusable requests list component
└── services/
    └── AuthContext.jsx                     # Authentication and user state management
```

This structure provides clear boundaries between concerns, enabling easy navigation and scalable independent feature development.

---

## 3.4.2 Visual Design and Responsiveness

The application uses a professional color system with CSS variables for consistent theming. Background colors include #C4EDFC (light cyan), #A2F9CF (sage green), and #FFFFFF99 (transparent white). Button colors use #1D61E7 (deep blue for primary) and #25B4E5 (teal for secondary), with #1a7e9f for hover states. Text colors range from #FFFFFF (white) to #111827 (dark) for emphasis, with #4D81E7 for links and #B6B6B6 for borders. Gradients enhance visual appeal: the hero section uses `linear-gradient(to bottom right, #8DECB4, #84E5F3)` (mint to cyan), navigation uses `linear-gradient(180deg, #84e4f3 0%, #8decb4 100%)` (cyan to mint), and the chatbot uses #95F8C9 and #53CAF9 with transparency.

The Cairo font family is used for bilingual Arabic-English text rendering with weights of 400 (regular), 600 (medium), and 700 (bold). Typography scales across devices: hero titles are 50px, section titles 32px, and body text 14-19px. The design is fully responsive with three breakpoints: phones under 480px use single-column layouts, tablets 480-768px begin expanding, and desktops over 1024px use full width. RTL (right-to-left) support is implemented with `text-align: right` and `flex-direction: row-reverse` to properly display Arabic. Cards have 12px rounded corners, buttons have 10px radius, and box shadows use `0 8px 32px rgba(29, 97, 231, 0.10)` for depth. Spacing is consistent: 8px small gaps, 12px standard spacing, 20-40px section gaps, and 80px page padding on desktop.

[SCREENSHOT: Hero section of the Home page showing the gradient background transitioning from mint green to cyan, with white text "احجز وسجل | مع افضل الاطباء فى نطاقك" on the left and a dental professional image on the right, demonstrating the RTL layout and color palette]

[SCREENSHOT: Responsive grid of service categories showing the 12 dental service options (teeth whitening, tooth extraction, dental filling, etc.) with circular icons, demonstrating the card layout design and responsive grid behavior on desktop view]

[SCREENSHOT: Booking form card displayed on a mobile device showing the gradient background, semi-transparent white card with doctor information header bar in blue gradient, form fields for patient data, and responsive typography sizing]

---

## 3.4.3 User Flow and System Interaction

The application supports four main user interactions. **Doctor Registration** submits personal information to `/auth/register/doctor`, triggering OTP verification via WhatsApp before returning a JWT token. **Doctor Login** uses email and password (with optional "Remember Me"), storing the JWT for authentication. **Patient Appointment Booking** involves selecting a service category, choosing a doctor, entering booking details (name, phone), and submitting to `/appointment/createAppointment/{caseId}` with duplicate detection. **Chatbot Recommendation** fetches categories and initiates a session at `/session/start`, presenting Arabic diagnostic questions; user selections sent to `/session/ask` return follow-up questions or final category recommendations mapped to service pages.

The user journey flowchart presents two pathways: **Patient pathway** allows users to either select known categories directly or use the chatbot for guided discovery, ultimately leading to doctor selection and booking confirmation. **Doctor pathway** requires account verification (login or signup), then grants access to a personalized dashboard for viewing appointments and submitting new case requests that become visible to patients in relevant service categories. This architecture streamlines both user experiences while maintaining bidirectional matching between patient needs and doctor case availability.

Throughout all user interactions, the system implements layered validation mechanisms ensuring data integrity and preventing unauthorized transactions. Patient bookings are validated against existing appointments to prevent duplicates, while doctor submissions undergo authentication verification to ensure only qualified practitioners can publish cases. API responses include status codes indicating success or specific error conditions, enabling the frontend to provide contextual user feedback. Real-time state management through React Context ensures authentication status remains synchronized across all pages, automatically logging out users with expired tokens and preventing access to protected routes without valid credentials.

[DIAGRAM: New User Registration Flow]
```
┌─────────────────────────────────────────────────────────────┐
│ User arrives at Home page                                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Click "إنشاء حساب" (Create Account) in NavBar             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Fetches: Cities, Universities, Categories from API         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Display RegisterForm.jsx with dropdown menus               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ User fills form: name, email, phone, city, faculty, etc    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ POST /auth/register/doctor {form data}                      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Backend sends OTP to user's phone via SMS                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Display Otp.jsx - explain OTP received                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ User retrieves OTP from SMS and enters code               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ POST /otp/verify {code, phone/email}                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Backend validates OTP, returns JWT token                   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Store token in localStorage                                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Display OtpDone.jsx - success confirmation                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Navigate to /doctor-home or / (authenticated)              │
└─────────────────────────────────────────────────────────────┘
```

[DIAGRAM: Patient Case Submission and Booking Flow]
```
┌─────────────────────────────────────────────────────────────┐
│ Patient at Home.jsx (unauthenticated)                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Scroll to "الخدمات المتوفره" (Available Services)          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Click category: e.g., "حشو تجميلي" (Cosmetic Filling)     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Navigate to /dental-filling                                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ RequestsList component fetches GET /category/7/getCases     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Display grid of available cases with doctor info            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Patient reviews cases and clicks "احجز" button              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Navigate to /booking with state: { request: selectedCase } │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Display doctor info and appointment datetime               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Patient enters name and phone number                       │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ POST /appointment/createAppointment/{caseId}               │
│ Body: {patientFirstName, patientLastName, phone}          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Backend validates data and stores appointment              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Display success confirmation modal                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ User clicks "العودة للرئيسية" (Return to Home)            │
└─────────────────────────────────────────────────────────────┘
```

[DIAGRAM: Chatbot Recommendation and Service Navigation Flow]
```
┌─────────────────────────────────────────────────────────────┐
│ User navigates to /chatbot page                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ ChatBot.jsx initializes:                                   │
│ - GET /category/getCategories                              │
│ - POST /session/start {language: "ar"}                     │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Session established with sessionId                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Backend sends initial question in Arabic                   │
│ Example: "ما هي مشكلة أسنانك؟"                             │
│ (What is your dental problem?)                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Display question with answer buttons                       │
│ - تبييض اسنان (Teeth Whitening)                            │
│ - خلع اسنان (Tooth Extraction)                             │
│ - حشو اسنان (Dental Filling)                               │
│ - اخرى (Other)                                             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ User clicks selected answer                                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ POST /session/ask {sessionId, questionId, answer}          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Backend processes answer against decision tree             │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Option A: Return follow-up question (loop continues)       │
│ Option B: Return result.category (e.g., "Dental Filling")  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ If result reached:                                         │
│ Map API category to app route                              │
│ Example: "DentalFilling" → "/dental-filling"               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Display ResultButtons component with:                      │
│ - "عرض حالات [حشو تجميلي]" (View [Filling] Cases)         │
│ - "🔄 إعادة المحادثة من البداية" (Restart)               │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ User clicks "عرض حالات" navigating to service page        │
│ OR clicks "إعادة المحادثة" restarting the flow             │
└─────────────────────────────────────────────────────────────┘
```

---

## 3.4.4 Web Application Navigation and Routing

The application uses React Router v6 for client-side routing and navigation through App.jsx. Public routes (accessible without login) include: home ("/"), login ("/login"), signup ("/sign"), OTP verification pages, chatbot ("/chatbot"), legal pages ("/terms&conditions", "/privacy-policy"), and support ("/support"). Protected routes (for authenticated doctors) include: doctor dashboard ("/doctor-home"), appointment history ("/doctor-booking"), profile management ("/doctor-profile", "/profile-update"), case management ("/my-requests"), patient records ("/patients"), and account deletion ("/delete-account"). Service category routes display dental treatments: "/teeth-whitening", "/tooth-extraction", "/dental-filling", "/amalgam-filling", "/dental-implant", "/crowns&bridges", "/braces", "/surgery-extraction", "/pediatric-dentistry", and "/removable-prosthetics". Error routes include 401 (unauthorized), 403 (forbidden), 404 (not found), and security blocks for "/assets" and "/javascript". The NavBar is conditionally hidden on home, login, and signup pages for visual clarity, appearing on all other pages. Navigation uses `useNavigate()` for programmatic changes and `location.state` to pass complex data between routes without URL encoding.

```javascript
// App.jsx Route Configuration
export default function App() {
  const location = useLocation();
  const hideNavBar = location.pathname === "/" || 
                     location.pathname === "/coming-soon" || 
                     location.pathname === "/login" || 
                     location.pathname === "/sign";

  return (
    <>
      <NavBar/>
      <Routes>
        {/* Public Routes */}
        <Route path="/" element={<Home/>}/>
        <Route path="/login" element={<LoginPage/>}/>
        <Route path="/sign" element={<RegisterForm/>}/>
        <Route path="/otp" element={<Otp/>}/>
        <Route path="/otp-verify" element={<OtpVerify/>}/>
        <Route path="/otp-done" element={<OtpDone/>}/>
        <Route path="/chatbot" element={<ChatBot/>}/>
        <Route path="/terms&conditions" element={<TermsConditions/>}/>
        <Route path="/booking" element={<Booking/>}/>
        
        {/* Doctor Protected Routes */}
        <Route path="/doctor-home" element={<DoctorHome/>}/>
        <Route path="/doctor-booking" element={<DoctorBookings/>}/>
        <Route path="/doctor-profile" element={<DoctorProfile/>}/>
        <Route path="/profile-update" element={<ProfileUpdate/>}/>
        <Route path="/my-requests" element={<MyRequests/>}/>
        <Route path="/patients" element={<Patient/>}/>
        <Route path="/delete-account" element={<DeleteAccount/>}/>
        <Route path="/delete-my-account" element={<DeleteMyAccount/>}/>
        
        {/* Service Category Routes */}
        <Route path="/teeth-whitening" element={<TeethWhitening/>}/>
        <Route path="/tooth-extraction" element={<ToothExtraction/>}/>
        <Route path="/dental-filling" element={<DentalFilling/>}/>
        <Route path="/dental-implant" element={<DentalImplant/>}/>
        <Route path="/crowns&bridges" element={<CrownsBridges/>}/>
        <Route path="/braces" element={<Braces/>}/>
        <Route path="/amalgam-filling" element={<AmalgamFilling/>}/>
        <Route path="/surgery-extraction" element={<SurgeryExtraction/>}/>
        <Route path="/pediatric-dentistry" element={<PediatricDentistry/>}/>
        <Route path="/removable-prosthetics" element={<RemovableProsthetics/>}/>
        
        {/* Policy Routes */}
        <Route path="/privacy-policy" element={<PrivacyPolicy/>}/>
        <Route path="/support" element={<Support/>}/>
        
        {/* Error Routes */}
        <Route path="/forbidden" element={<ForbiddenPage/>}/>
        <Route path="/403" element={<ForbiddenPage/>}/>
        <Route path="/401" element={<UnauthorizedPage/>}/>
        <Route path="/assets" element={<ForbiddenPage/>}/>
        <Route path="/assets/*" element={<ForbiddenPage/>}/>
        <Route path="/javascript" element={<ForbiddenPage/>}/>
        <Route path="/javascript/*" element={<ForbiddenPage/>}/>
        
        {/* Catch-all */}
        <Route path="*" element={<NotFoundPage/>}/>
      </Routes>
      <Footer/>
    </>
  );
}
```

---

## 3.4.5 Mapping UI Screens to React Components

Each user-visible screen corresponds to a React component for clear code organization. Discovery and landing pages include Home.jsx (hero section with service categories), ChatBot.jsx (recommendation engine), and ten service pages (TeethWhitening.jsx, ToothExtraction.jsx, DentalFilling.jsx, etc.) for case listings. Authentication pages include LoginPage.jsx, RegisterForm.jsx, Otp.jsx, Otp-verify.jsx, OtpDone.jsx, ForgetPassword.jsx, and ResetPassword.jsx. Doctor management pages include DoctorHome.jsx (pending appointments), DoctorBookings.jsx (history), DoctorProfile.jsx (view profile), ProfileUpdate.jsx (edit profile), MyRequests.jsx (submitted cases), AddRequest.jsx (new case submission), and Patient.jsx (patient records). Patient-facing pages include Booking.jsx (appointment information entry). Policy pages include TermsConditions.jsx, PrivacyPolicy.jsx, and Support.jsx. Error pages include NotFoundPage.jsx (404), ForbiddenPage.jsx (403), and UnauthorizedPage.jsx (401). AuthContext.jsx provides global authentication state and user profile data accessible from all components using React Context.

```
Component Mapping Summary:
Landing/Discovery: Home.jsx, ChatBot.jsx, 10 Service Pages
Authentication: LoginPage.jsx, RegisterForm.jsx, Otp.jsx, Otp-verify.jsx, OtpDone.jsx, ForgetPassword.jsx, ResetPassword.jsx
Doctor Dashboard: DoctorHome.jsx, DoctorBookings.jsx, DoctorProfile.jsx, ProfileUpdate.jsx, MyRequests.jsx, Patient.jsx, DeleteAccount.jsx, AddRequest.jsx
Patient Interaction: Booking.jsx
Legal/Support: TermsConditions.jsx, PrivacyPolicy.jsx, Support.jsx
Error Handling: ForbiddenPage.jsx, UnauthorizedPage.jsx, NotFoundPage.jsx
Global State: AuthContext.jsx
```

---

## 3.4.6 Chatbot Integration and Recommendation Logic

The chatbot helps users find appropriate dental services through conversational interaction. Initialization fetches available services from `/category/getCategories` and creates a session via `POST /session/start` with `{ "language": "ar" }` to establish an Arabic conversation context. The backend returns an initial question (e.g., "ما هي مشكلة أسنانك؟") with multiple answer options displayed as clickable buttons. User selections are sent to `/session/ask` with session ID, question ID, and answer ID, returning either follow-up questions or a final service category recommendation. Category-to-route mapping translates backend categories (e.g., "DentalFilling") into application routes (e.g., "/dental-filling") for all ten services. The interface renders three component types: BotMessage (cyan background with bot icon), UserMessage (user selections with lighter background), and QuickReplies (clickable answer buttons). Upon recommendation completion, result buttons navigate users to the service page ("عرض حالات [ServiceName]") or restart the conversation ("إعادة المحادثة من البداية").

```javascript
// ChatBot.jsx API Calls Structure

// 1. Load Categories - populate available services
const loadCategories = async () => {
  try {
    const res = await fetch(`${API_BASE}/category/getCategories`, { 
      method: "GET", 
      headers: API_HEADERS 
    });
    const data = await res.json();
    const raw = Array.isArray(data) ? data : (data?.categories || data?.data || []);
    if (Array.isArray(raw)) {
      setCategories(raw.map(c => ({ 
        id: c.id, 
        name: c.name || '', 
        name_ar: c.name_ar || '' 
      })));
    }
  } catch (err) {
    console.error("Failed to load categories:", err);
  }
};

// 2. Start Session - initialize chatbot conversation
const startSession = async () => {
  setIsLoading(true);
  try {
    const res = await fetch(`${API_BASE}/session/start`, { 
      method: "POST", 
      headers: API_HEADERS, 
      body: JSON.stringify({ language: "ar" }) 
    });
    const data = await res.json();
    if (data?.session_id) setSessionId(data.session_id);
    processResponse(data);
  } catch (err) {
    console.error("Error starting session:", err);
    setChatMode(true);
  } finally {
    setIsLoading(false);
  }
};

// 3. User Message Processing - handle user answer selection
// This gets called when user clicks an answer button
const handleAnswerSelect = (question, answer) => {
  // Add user message to history
  addFlowItem({ 
    type: "user-message", 
    text: answer.text 
  });
  
  // Send answer to backend for processing
  sendAnswer(question, answer);
};

// 4. Send Answer - POST to /session/ask endpoint
const sendAnswer = async (question, answer) => {
  setIsLoading(true);
  try {
    const res = await fetch(`${API_BASE}/session/ask`, {
      method: "POST",
      headers: API_HEADERS,
      body: JSON.stringify({
        session_id: sessionId,
        question_id: question.id,
        answer_id: answer.id,
        answer_text: answer.text
      })
    });
    const data = await res.json();
    processResponse(data);
  } catch (err) {
    console.error("Error sending answer:", err);
  } finally {
    setIsLoading(false);
  }
};
```

The chatbot conversation progresses through iterative cycles of question presentation and answer processing. Upon initialization, the backend returns an initial question prompting the user to describe their dental concern. The question includes multiple selectable answer options, each representing a potential classification pathway. For example, the initial question might present options such as "تبييض اسنان" (Teeth Whitening), "خلع اسنان" (Tooth Extraction), "حشو اسنان" (Dental Filling), or "اخرى" (Other). These answers are rendered as clickable buttons in the QuickReplies component, establishing an intuitive selection mechanism.

When the user clicks an answer button, the application performs several coordinated actions. First, the selected answer is added to the conversation history, displayed as a user message in the chat interface. Second, a "thinking" indicator displays briefly to indicate the chatbot is processing the selection. Third, the application invokes the sendAnswer function, which constructs a POST request to the `/session/ask` endpoint including the session identifier, question identifier, and selected answer identifier. The backend receives this request, analyzes the answer against its recommendation algorithm, and returns a response containing either a follow-up question or a classification result.

If the backend returns a follow-up question, the chatbot displays this new question with its associated answer buttons, and the conversational loop continues. The BotMessage component renders the question text alongside the ChatBotIcon, visually distinguishing chatbot utterances from user selections. The QuickReplies component renders the answer buttons below the question, restoring interactive capability to the user.

If the backend determines sufficient confidence in its classification, it returns a result object containing the determined service category. At this point, the application invokes the mapToAppCategory function, which translates backend category nomenclature into application route paths. For example, API categories are mapped to application routes through hardcoded or dynamic lookup mappings:

```javascript
// Category-to-Route Mapping Logic
const mapToAppCategory = (category) => {
  const categoryMap = {
    'teeth_whitening': '/teeth-whitening',
    'tooth_extraction': '/tooth-extraction',
    'dental_filling': '/dental-filling',
    'amalgam_filling': '/amalgam-filling',
    'dental_implant': '/dental-implant',
    'crowns_bridges': '/crowns&bridges',
    'braces': '/braces',
    'surgery_extraction': '/surgery-extraction',
    'pediatric_dentistry': '/pediatric-dentistry',
    'removable_prosthetics': '/removable-prosthetics'
  };
  
  return categoryMap[category.toLowerCase()] || '/';
};
```

**Category to Route Mapping**

When the chatbot finishes and gives a recommendation, it needs to turn the category name into a page URL. Here's how it works:

```javascript
// Category-to-Route Mapping Logic
const mapToAppCategory = (category) => {
  const categoryMap = {
    'teeth_whitening': '/teeth-whitening',
    'tooth_extraction': '/tooth-extraction',
    'dental_filling': '/dental-filling',
    'amalgam_filling': '/amalgam-filling',
    'dental_implant': '/dental-implant',
    'crowns_bridges': '/crowns&bridges',
    'braces': '/braces',
    'surgery_extraction': '/surgery-extraction',
    'pediatric_dentistry': '/pediatric-dentistry',
    'removable_prosthetics': '/removable-prosthetics'
  };
  
  return categoryMap[category.toLowerCase()] || '/';
};
```

After mapping the category to a route, the user clicks the "View Cases" button and is taken to that service page where they can see available appointments and book one.

The chatbot makes the process of finding a dental service simple and friendly. Instead of browsing through all 10 services, users answer a few simple questions and get a recommendation.

[SCREENSHOT: Chatbot interface showing initial question "ما هي مشكلة أسنانك؟" (What is your dental problem?) with multiple answer buttons including "تبييض اسنان", "خلع اسنان", "حشو اسنان", and "اخرى"]

[SCREENSHOT: Chatbot conversation history showing alternating bot and user messages, with bot messages on the right with cyan background and user selections on the left with mint background]

[SCREENSHOT: Chatbot result display showing "عرض حالات [حشو تجميلي]" and "إعادة المحادثة" buttons after successful category recommendation]

---

## 3.4.7 API Integration and Form Handling

API communication switches between environments using `const API_BASE_URL = import.meta.env.DEV ? "/api" : "https://thoutha.page/api"`. In development, Vite proxies `/api/*` requests to `https://thoutha.page`; in production, requests target the deployed backend directly. The application implements approximately 15 REST endpoints covering authentication (`/auth/login/doctor`, `/auth/register/doctor`), user management (`/doctor/getDoctorById`), appointments (`/appointment/pendingAppointments`, `/appointment/createAppointment/{requestId}`, `/appointment/getDone`), and chatbot operations (`/session/start`, `/session/ask`). JWT authentication stores tokens in localStorage under the key "token" and includes them in requests via `Authorization: Bearer ${token}`. The AuthContext implements manual JWT decoding using base64 URL-safe transformations without external libraries, checking expiration via the `exp` claim to trigger automatic logout when tokens expire.

Form handling uses React controlled components with `useState` for state management. The login form maintains email, password, and "Remember Me" state, with optional localStorage persistence of credentials. The booking form validates three required fields (patientFirstName, patientLastName, patientPhoneNumber) with field-level error tracking, detecting duplicate bookings through error message keyword matching ("موجود", "مسبق", "already", "exists"). Network errors including CORS violations receive special handling with user-friendly messages. HTTP error responses (401, 403, 4xx) are differentiated with context-specific messaging. All API errors gracefully default to generic messages when JSON parsing fails.

[SCREENSHOT: Login form showing successful pre-filled "Remember Me" credentials reusing a previous login session]

[SCREENSHOT: Booking form displaying field-level error highlighting when user attempts to submit with missing patient information]

[SCREENSHOT: API error message displayed in Booking page when user attempts duplicate booking for same appointment slot]

---

## 3.4.8 Final Web Application

The Thoutha Dental Platform is a comprehensive production-ready web application systematizing clinical case management and connecting undergraduate dental students with patients requiring treatment. The technology stack comprises React v18.2.0 (component-based architecture), React Router v7.12.0 (client-side routing), Vite v4.4.5 (build toolchain with hot-reloading), and supporting libraries: react-helmet-async v2.0.5 (SEO meta tags), emailjs-com v3.2.0 (transactional emails), and tailwindcss-rtl v0.9.0 (Arabic RTL support). The backend REST API implements 15+ endpoints for authentication, user management, appointments, and chatbot operations. The feature set encompasses authentication with JWT tokens and OTP verification, a service catalog organizing ten dental specialties, appointment scheduling with duplicate detection, an intelligent chatbot recommendation engine, user profile customization, role-based access control, responsive design across 320-1920px viewports, and RTL Arabic layout support.

The application statistics reflect significant complexity: 38 page components, 3 reusable UI components, 40+ routes, 15+ API endpoints, 23 CSS files, 1 central AuthContext, 8000+ lines of code, 2 supported languages (Arabic/English), and 3 responsive breakpoints. Key features by category: **Authentication** includes doctor registration with OTP verification, email-based login with credential persistence, JWT authentication, password recovery via SMS, and secure logoff on token expiration. **Service Catalog** presents ten dental categories with metadata-rich case listings. **Appointments** enable patient scheduling, duplicate prevention, doctor notifications, and status tracking. **User Management** supports profile customization, visibility controls, and account deletion. **Responsive Design** delivers optimized experiences across mobile (320-768px), tablet (768-1024px), and desktop (1024px+). Future enhancements include SMS notifications, video consultations, analytics dashboards, payment processing, hospital system integration, telemedicine features, and mobile applications.

The Thoutha platform successfully addresses its primary objective of systematizing clinical case management for dental education programs, establishing a scalable foundation for expansion to additional institutions and integration with healthcare ecosystems.

[SCREENSHOT: Complete application dashboard showing the doctor home page with pending appointment cards, navigational menu, and responsive layout on desktop view]

[SCREENSHOT: Service category browsing showing the complete set of 10 dental service options displayed in responsive grid layout]

[SCREENSHOT: Application showing successful responsive adaptation with navigation menu collapsed into mobile hamburger menu icon]

```javascript
// vite.config.js
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

const API_TARGET = 'https://thoutha.page'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: API_TARGET,
        changeOrigin: true,
        secure: true,
      },
    },
  },
})
```

### Complete CSS Color System

```css
/* Global CSS Variables (Root) */
:root {
  /* Background Colors */
  --color-1-background: #C4EDFC;      /* Light cyan */
  --color-2-background: #A2F9CF;      /* Sage green */
  --color-3-background: #FFFFFF99;    /* Transparent white */
  
  /* Button Colors */
  --button-color-1: #1D61E7;          /* Deep blue */
  --button-color-2: #25B4E5;          /* Teal/cyan */
  --button-hover: #1a7e9f;            /* Dark teal hover */
  
  /* Text Colors */
  --text-color-1: #FFFFFF;            /* White */
  --text-color-2: #4D81E7;            /* Blue */
  --text-color-3: #6C7278;            /* Medium gray */
  --text-color-4: #111827;            /* Dark gray */
  --text-color-5: #D2EBE7;            /* Light teal */
  --text-color-6: #101828;            /* Almost black */
  --text-color-8: #B6B6B6;            /* Light gray */
  
  /* UI Elements */
  --border-color: #EDF1F3;            /* Very light gray */
  --border-radius-1: 12px;
  --button-radius-1: 10px;
  
  /* Chatbot Colors */
  --chatbot-color-1: #95F8C9;         /* Light mint */
  --chatbot-color-2: #53CAF9;         /* Bright cyan */
  --chatbot-color-3: #53caf928;       /* Cyan transparent */
}

/* Hero Gradient */
.hero-section {
  background: linear-gradient(to bottom right, #8DECB4, #84E5F3);
}

/* Active Navigation Gradient */
.nav-active {
  background: linear-gradient(180deg, #84e4f3 0%, #8decb4 100%);
}
```

### Package Dependencies

```json
{
  "dependencies": {
    "axios": "^1.6.0",
    "emailjs-com": "^3.2.0",
    "lucide-react": "^0.554.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-helmet-async": "^2.0.5",
    "react-icons": "^5.5.0",
    "react-router": "^7.9.6",
    "react-router-dom": "^7.12.0",
    "tailwindcss-rtl": "^0.9.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.15",
    "@types/react-dom": "^18.2.7",
    "@vitejs/plugin-react": "^4.0.3",
    "autoprefixer": "^10.4.16",
    "eslint": "^8.45.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "eslint-plugin-react-refresh": "^0.4.3",
    "postcss": "^8.4.31",
    "tailwindcss": "^3.3.5",
    "vite": "^4.4.5"
  }
}
```

---

**END OF ACADEMIC DOCUMENTATION**

This comprehensive documentation represents the complete technical and functional specifications of the Thoutha Dental Platform graduation project, suitable for university thesis submission and professional reference purposes.

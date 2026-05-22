## 3.6 User Interface of Thoutha Mobile Application

The user interface of the Thoutha mobile application is built using the Flutter framework, adhering to Modern UI principles and Material Design 3 guidelines. The overall structure is conceptually organized to provide seamless experiences for two distinct user roles: Patients seeking dental care and Doctors providing these services. The interface focuses on clarity, minimizing cognitive load through structured layouts that prioritize essential actions. Patients can easily navigate to find a specialist, book an appointment, or exclusively utilize the AI diagnostic chatbot for preliminary assessments, while Doctors access a streamlined dashboard to manage incoming requests.

The principal composition of screens relies on a distinct hierarchy: a base `Scaffold` forming the foundational layer, followed by gradient background containers, and a `SafeArea` encapsulating scrollable regions (`SingleChildScrollView`). Within this structure, widgets are organized categorically. **Authentication screens** include `LoginScreen`, `SignUpScreen`, and `ForgotPasswordScreen`. **Core Functional screens** feature the `HomeScreen` and `ChatScreen`. **Dental Service screens** incorporate `AddCaseRequestScreen` and `BookingConfirmationScreen`, while **Doctor Management screens** handle incoming requests via `DoctorHomeScreen` and `DoctorBookingRecordsScreen`. Finally, **Policy and Error screens** provide essential supplementary information and state feedback. 

This organization translates into a coherent file directory, wherein the `lib` folder separates core utilities from feature modules. The following code snippet demonstrates this modular architectural structure inside the project:

```dart
lib/
├── core/
│   ├── di/
│   ├── helpers/
│   ├── networking/
│   ├── routing/
│   └── theming/
└── features/
    ├── auth/
    ├── booking/
    ├── chat/
    ├── doctor/
    ├── home_screen/
    ├── login/
    ├── requests/
    └── sign_up/
```

[SCREENSHOT: Display the main Doctor or Patient Home screen showing the organized UI layout with standard app bar and content containers.]

## 3.7 Visual Design and Responsiveness

The visual identity of the Thoutha application is driven by a carefully curated color palette that aims to instill trust and convey a modern healthcare aesthetic. The primary color is a vibrant blue (`#247CFF`), paired with subtle background tones such as light blue (`#F4F8FF`) and various grayscale shades ranging from dark blue (`#242424`) to light gray (`#C2C2C2`). To enhance depth, radial gradients are prominently applied to hero sections and authentication backgrounds utilizing semi-transparent accent colors like cyan (`#53CAF7`) and mint green (`#96F8C9`).

Typography plays a critical role in the Arabic-first interface. The "Cairo" font serves as the primary typeface ensuring high legibility for all UI copy, from headlines (`24.sp`) to body text (`14.sp`). Decorative headers occasionally leverage "Story Script" and "Vina Sans". To maintain impeccable responsiveness across varied Android and iOS display dimensions, the application utilizes the `flutter_screenutil` package, dynamically scaling dimensions (`.w`, `.h`) and fonts (`.sp`) based on a base design size of 375x812.

Furthermore, a critical requirement for proper localized rendering is the Right-to-Left (RTL) layout support. This is actively enforced throughout the application views using Flutter's native `Directionality` widget. Most screens encapsulate their layouts within this widget to assure Arabic alignments are respected structurally.

```dart
child: Directionality(
  textDirection: TextDirection.rtl,
  child: Form(
    key: _formKey,
    // Form fields and buttons follow RTL alignment
...
```

[SCREENSHOT: Display the Login Screen showcasing the gradient background, Cairo typography, and RTL aligned form fields.]

## 3.8 User Flow and System Interaction

The system interaction is primarily modeled through four consecutive user journeys. The **New User Registration flow** initiates at the splash screen, leading to the sign-up form, where demographic and university data are validated. This is subsequently followed by OTP verification, finalizing account creation. Conversely, the **Existing User Login flow** authenticates the user credentials, establishing a secure session via JWT token placement in secure storage, and navigating exclusively to either the patient or doctor route based on assigned privileges.

For patients, the **Case Submission flow** begins by navigating from the home categories to a specialized doctor list, examining a doctor's profile, and progressing into the booking confirmation step. This process effectively converts browsing intent into a confirmed appointment. Lastly, the patient-exclusive **ChatBot Recommendation flow** handles the diagnostic interaction. Upon starting the session, the AI system presents a series of questions. The user responds via quick-reply buttons, forming a conversational loop that concludes with identifying the proper dental service category.

The following represent sequence models for the major application flows:
- **Registration**: `Splash Screen -> Sign Up -> OTP Verification -> Welcome Dashboard`
- **Login**: `Splash Screen -> Login -> Auth Service (JWT) -> Patient/Doctor Dashboard`
- **Booking**: `Home -> Category Selection -> Doctor List -> Profile -> Booking Confirmation`
- **Chatbot Analysis**: `Session Start -> Load Categories -> Question/Answer Loop -> Category Resolution -> Matching Services`

[SCREENSHOT: Display the multi-step Patient Case Submission flow from category selection to the booking confirmation dialog.]

## 3.9 Mobile Application Navigation and Routing

Flutter's navigation within the Thoutha application is implemented utilizing the standard `Navigator` model managed through a centralized `AppRouter` mechanism alongside strongly typed string constants. Instead of direct widget-to-widget instantiations, the `onGenerateRoute` configuration in the primary `MaterialApp` intercepts navigation calls, parsing the route names and their optional arguments before yielding the correct `MaterialPageRoute`.

The route map is categorized systematically. **Public routes** include the Splash (`/splashScreen`), Onboarding, and Welcome screens. **Protected routes**—which require an authenticated session—include the Main Dashboard (`/home_screen`) and My Requests. **Service routes** act as deeper nested interactions, such as Chatbot (`/chatScreen`) and Appointment Booking (`/booking-confirmation`). Error handling is naturally incorporated inside the router's `switch` default case, directing the user to a generic fallback interface if an unregistered route is provoked.

```dart
class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return MaterialPageRoute(builder: (context) => const LoginScreen());
      case Routes.chatScreen:
        return MaterialPageRoute(builder: (context) => const ChatScreen());
      // Deep link with arguments
      case Routes.otpVerificationScreen:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            phone: args['phone'] ?? '',
            expiresInSeconds: args['expires_in'] ?? 300,
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(body: Center(child: Text('No route defined for ${settings.name}'))),
        );
    }
  }
}
```

[SCREENSHOT: Display the Welcome Dashboard visualizing the top-level navigational entry points to other application sections.]

## 3.10 Mapping UI Screens to Flutter Widgets

The translation of UI wireframes into code centers around pairing distinct screens with specific modular widgets, strictly separating UI code logic from domain operations. The hierarchy commences at `main.dart`, executing `runApp` with the root `DocApp` widget. This root encapsulates global providers, such as the `ThemeProvider` and `ScreenUtilInit`, forming the foundational global state map before delegating rendering to individual feature screens.

Each feature segment maps its screens to dedicated widgets located within respective `ui/` directories. For instance, the Chatbot feature correlates with `ChatScreen`, integrating sub-widgets like `BotMessageWidget` and `QuickReplyOptionsWidget`. The complex Doctor Dashboard coordinates across multiple encapsulated widgets, such as the `AppointmentCardWidget` and `Drawer` integrations.

```text
lib/
├── main.dart
├── doc_app.dart
├── core/
│   └── (shared components and networking helpers)
└── features/
    ├── booking/
    │   └── ui/
    │       ├── booking_confirmation_screen.dart
    │       └── otp_verification_dialog.dart
    ├── chat/
    │   └── ui/
    │       └── chat_screen.dart
    └── doctor/
        └── ui/
            ├── doctor_home_screen.dart
            └── doctor_booking_records_screen.dart
```

[SCREENSHOT: Display the widget tree structure conceptually overlaid on top of the Chatbot Screen, pointing out independent sub-widgets.]

## 3.11 Chatbot Integration and Recommendation Logic

The intelligent Chatbot module operates as a deterministic conversational engine designed specifically for patients, managing a specific lifecycle driven entirely by backend API configurations. The interaction initiates through the `ChatCubit` state manager calling the `/api/session/start` endpoint, establishing an active session block and fetching the initial diagnostic question. Simultaneously, all available service categories are preloaded via `/api/category/getCategories` to facilitate immediate mappings without secondary delays once the diagnostic loop finalizes.

The conversational progression executes by iterating the `submitAnswer` method, submitting the chosen Option ID to `/api/session/answer`. The application parses the subsequent JSON response, extracting either the next chronological question or terminating the loop upon receiving a final service recommendation string. When the recommendation is identified, the application maps the string output directly to local system category IDs via normalization expressions to ensure routing accuracy despite potential syntax discrepancies.

```dart
// The answer submission process integrating session management
Future<void> submitAnswer(ChatQuestion q, ChatAnswer a) async {
  final currentState = state;
  final result = await _chatRepo.submitAnswer(
    sessionId: currentState.sessionId!,
    questionId: q.id!,
    answerId: a.id!,
  );

  if (result['success'] == true) {
    final response = ChatResponse.fromJson(result['data']);
    _processResponse(response, flowItems, currentState.chatHistory, ...);
  }
}
```

[SCREENSHOT: Display the active Chatbot session showing a bot message, user response options (quick replies), and the loading indicator iteration.]

## 3.12 API Integration and Form Handling

Integration between the Flutter application and external services operates over a unified `Dio` networking layer configured via a Singleton pattern in `DioFactory`. The global connection targets an encrypted HTTPS Base URL (`https://thoutha.page`) mapping out multiple discrete JSON endpoints. The core identity component relies heavily on `FlutterSecureStorage` securely holding the standard JSON Web Token (JWT) acquired during authentication and programmatically injecting it alongside `Bearer` schemas as a global HTTP header for all protected route requests.

Intensive client-side validation acts as a preliminary defense layer prior to issuing REST commands. Form handlers utilize robust regular expressions to preempt faulty network overhead. For example, the `BookingConfirmationScreen` systematically evaluates phone inputs ensuring absolute conformance to regional format standards before generating an appointment reservation through `/api/appointment/createAppointment`. Simialry, the Login form isolates formatting from authentication errors.

```dart
validator: (value) {
  if (value == null || value.isEmpty) { return 'الرجاء إدخال رقم الجوال'; }
  String cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  
  if (cleanPhone.startsWith('01')) {
    if (cleanPhone.length != 11) { return 'رقم الجوال المصري يجب أن يكون 11 رقم'; }
    if (!RegExp(r'^01[0-2]\d{8}$').hasMatch(cleanPhone)) {
      return 'رقم الجوال المصري غير صحيح';
    }
  }
  return null;
}
```

[SCREENSHOT: Display a form interface, such as Patient Booking or Add Case Request, illustrating highlighted red validation text beneath an input field.]

## 3.13 Final Mobile Application

In summation, the Thoutha mobile application is a high-performance cross-platform utility engineered with precise architectural design. Utilizing the Flutter framework, it leverages state-of-the-art community packages, notably `flutter_bloc` for structured granular state management, `dio` paired with `retrofit_generator` for strongly-typed robust API bindings, and `freezed` for producing immutable models. This cohesive technology stack enables fluid rendering transitions and strict separation of business logics.

The robust delivery consists of over 118 individual Dart files articulating the entire system scope. It supports 22 complex navigation routes mapping user journeys that independently consume roughly 24 mapped API endpoints spanning Authorization, Dental Service Indexing, Secure Messaging, and Matchmaking functions.

Looking forward, future system enhancements target deeper AI utilization for parsing radiological image submissions within the chatbot directly, parallel adoption of real-time push events substituting polling mechanics in doctor dashboards, and extended accessibility provisions accommodating expanded localized dialects within the broader medical ecosystem.

[SCREENSHOT: Display a comprehensive summary viewpoint, potentially showing the User Profile dashboard or the complete notification list representing integrated capabilities.]

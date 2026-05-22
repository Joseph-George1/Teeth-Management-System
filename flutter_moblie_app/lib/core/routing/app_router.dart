import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:flutter/material.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/reset_password/ui/otp_verification_screen.dart';
import '../../features/sign_up/ui/sign_up_screen.dart';
import '../../features/splash_screen/splash_screen.dart';
import '../../features/chat/ui/chat_screen.dart';
import '../../features/forgot_password/ui/forgot_password_screen.dart';
import '../../features/forgot_password/ui/change_password_screen.dart';
import '../../features/reset_password/ui/reset_password_screen.dart';
import '../../features/home_screen/ui/home_screen.dart';
import '../../features/notifications/ui/notifications_screen.dart';
import '../../features/notifications/ui/patient_notifications_screen.dart';
import '../../features/doctor/ui/account_deletion_screen.dart';
import '../../features/doctor/ui/doctor_home_screen.dart';
import '../../features/doctor/ui/doctor_booking_records_screen.dart';
import '../../features/doctor/ui/doctor_confirmed_appointments_screen.dart';
import '../../features/doctor/ui/doctor_next_booking_screen.dart';
import '../../features/appointments/ui/appointments_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SplashScreen(),
        );
      case Routes.onBoardingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OnboardingScreen(),
        );
      case Routes.loginScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => LoginScreen(),
        );
      case Routes.signUpScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => SignUpScreen(),
        );
      case Routes.chatScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChatScreen(),
        );
      case Routes.forgotPasswordScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ForgotPasswordScreen(),
        );
      case Routes.changePasswordScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ChangePasswordScreen(),
        );
      case Routes.otpVerificationScreen:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => OtpVerificationScreen(
            phone: args['phone'] ?? '',
            expiresInSeconds: args['expires_in'] ?? 300,
          ),
        );
      case Routes.resetPasswordScreen:
        final resetArgs = settings.arguments as Map? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ResetPasswordScreen(
            phone: (resetArgs['phone'] ?? '').toString(),
          ),
        );
      case Routes.categoriesScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => HomeScreen(),
        );
      case Routes.notificationsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => NotificationsScreen(),
        );
      case Routes.patientNotificationsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => PatientNotificationsScreen(),
        );
      case Routes.accountDeletionScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => AccountDeletionScreen(),
        );
      case Routes.doctorBookingRecordsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DoctorBookingRecordsScreen(),
        );
      case Routes.doctorConfirmedAppointmentsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DoctorConfirmedAppointmentsScreen(),
        );
      case Routes.doctorHomeScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DoctorHomeScreen(),
        );
      case Routes.doctorNextBookingScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DoctorNextBookingScreen(),
        );
      case Routes.appointmentsScreen:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => AppointmentsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}

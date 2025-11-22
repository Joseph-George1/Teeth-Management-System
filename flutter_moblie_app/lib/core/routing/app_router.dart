import 'package:thotha_mobile_app/core/routing/routes.dart';
import 'package:flutter/material.dart';

import '../../features/login/ui/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/reset_password/ui/otp_verification_screen.dart';
import '../../features/sign_up/ui/sign_up_screen.dart';
import '../../features/splash_screen/splash_screen.dart';
import '../../features/chat/ui/chat_screen.dart';
import '../../features/forgot_password/ui/forgot_password_screen.dart';
import '../../features/reset_password/ui/reset_password_screen.dart';
import '../../features/categories/ui/categories_screen.dart';
import '../../features/doctors/ui/doctors_screen.dart';
import '../../features/main_layout/ui/main_layout_screen.dart';

class AppRouter {
  Route generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashScreen:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
        );
      case Routes.onBoardingScreen:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        );
      case Routes.loginScreen:
        return MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        );
      case Routes.signUpScreen:
        return MaterialPageRoute(
          builder: (context) => const SignUpScreen(),
        );
      case Routes.chatScreen:
        return MaterialPageRoute(
          builder: (context) => const ChatScreen(),
        );
      case Routes.forgotPasswordScreen:
        return MaterialPageRoute(
          builder: (context) => const ForgotPasswordScreen(),
        );
      case Routes.otpVerificationScreen:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          builder: (context) => OtpVerificationScreen(
            email: args['email'] ?? '',
          ),
        );
      case Routes.resetPasswordScreen:
        return MaterialPageRoute(
          builder: (context) => const ResetPasswordScreen(),
        );
      case Routes.categoriesScreen:
        return MaterialPageRoute(
          builder: (context) => const MainLayoutScreen(initialIndex: 0),
        );
      case Routes.chatScreen:
        return MaterialPageRoute(
          builder: (context) => const MainLayoutScreen(initialIndex: 1),
        );
      case Routes.doctorsScreen:
        return MaterialPageRoute(
          builder: (context) => const DoctorsScreen(),
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
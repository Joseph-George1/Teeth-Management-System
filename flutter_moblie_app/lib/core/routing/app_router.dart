import 'package:flutter/material.dart';
import 'package:flutter_moblie_app/core/routing/routes.dart';
import '../../features/login/ui/login_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/sign_up/ui/sign_up_screen.dart';
import '../../features/splash_screen/splash_screen.dart';
import '../../features/otp/ui/otp_screen.dart';
import '../../features/otp/ui/otp_success_screen.dart';
import '../../features/chat/ui/chat_screen.dart';

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
      case Routes.otpScreen:
        return MaterialPageRoute(
          builder: (context) => const OtpScreen(),
        );
      case Routes.otpSuccessScreen:
        return MaterialPageRoute(
          builder: (context) => const OtpSuccessScreen(),
        );
      case Routes.chatScreen:
        return MaterialPageRoute(
          builder: (context) => const ChatScreen(),
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
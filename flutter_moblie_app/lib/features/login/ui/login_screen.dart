import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';

// ============================================
// PURE UI SECTION - NO BUSINESS LOGIC HERE
// ============================================
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI State Variables (for demo purposes)
    bool isLoading = false;
    String? emailError;
    String? passwordError;

    // Form Controllers (normally these would be in a controller/cubit)
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.7), // Top-left quadrant
                radius: 1.5,
                colors: [
                  ColorsManager.layerBlur1.withOpacity(0.4),
                  ColorsManager.layerBlur1.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),
          // Bottom-right gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.7, 0.7), // Bottom-right quadrant
                radius: 1.5,
                colors: [
                  ColorsManager.layerBlur2.withOpacity(0.4),
                  ColorsManager.layerBlur2.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),

          Container(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Text(
                      'Welcome Back',
                      style: TextStyles.font24BlueBold,
                    ),
                    verticalSpace(8),
                    Text(
                      'We\'re excited to have you back, can\'t wait to see what you\'ve been up to since you last logged in.',
                      style: TextStyles.font14GrayRegular,
                    ),
                    verticalSpace(36),

                    // Login Form
                    Form(
                      // key: formKey, // Uncomment when implementing logic
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              errorText: emailError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          verticalSpace(16),

                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              errorText: passwordError,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.visibility_off),
                                onPressed: () {
                                  // Toggle password visibility
                                },
                              ),
                            ),
                            obscureText: true,
                          ),

                          verticalSpace(24),

                          // Forgot Password
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Forgot Password?',
                              style: TextStyles.font13BlueRegular,
                            ),
                          ),

                          verticalSpace(40),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            child: AppTextButton(
                              buttonText: "Login",
                              textStyle: TextStyles.font16WhiteSemiBold,
                              onPressed: () {},
                            ),
                          ),

                          verticalSpace(16),

                          // Terms & Conditions
                          Text(
                            'By logging in, you agree to our Terms & Conditions and Privacy Policy',
                            style: TextStyles.font13GrayRegular,
                            textAlign: TextAlign.center,
                          ),

                          verticalSpace(24),

                          // Don't have an account?
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Don\'t have an account?',
                                style: TextStyles.font13DarkBlueRegular,
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to signup
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyles.font13BlueSemiBold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================
// LOGIC SECTION - TO BE IMPLEMENTED LATER
// ============================================
/*
// 1. State Management (using Cubit)
class LoginCubit extends Cubit<LoginState> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Add login logic here
}

// 2. State Classes
abstract class LoginState {}
class LoginInitial extends LoginState {}
class LoginLoading extends LoginState {}
class LoginSuccess extends LoginState {}
class LoginError extends LoginState {
  final String message;
  LoginError(this.message);
}

// 3. Form Validation
bool validateForm(GlobalKey<FormState> formKey) {
  // Add form validation logic
  return formKey.currentState?.validate() ?? false;
}

// 4. API Calls
Future<void> loginUser(String email, String password) async {
  // Add API call logic
}
*/

// ============================================
// WIDGETS SECTION - SEPARATE FILES
// ============================================
/*
// Move these to separate widget files:
- EmailAndPassword()
- TermsAndConditionsText()
- DontHaveAccountText()
- LoginBlocListener()
*/
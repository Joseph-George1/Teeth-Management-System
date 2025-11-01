import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoading = false;
    String? passwordError;
    bool rememberMe = false;

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Full screen gradient overlay
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
                  stops: const [0.1, 0.3, 0.8],
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: EdgeInsets.all(24.0.w),
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.0.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          verticalSpace(10),
                          Image.asset(
                            'assets/images/splash-logo.png',
                            width: 80.w,
                            height: 80.h,
                          ),
                          Text(' تسجيل دخول', style: TextStyles.font24BlueBold,),
                          verticalSpace(8),
                          Text(
                            'ادخل الايميل او رقم الهاتف و كلمه المرور',
                            style: TextStyles.font14GrayRegular,
                            textAlign: TextAlign.right,
                          ),
                          verticalSpace(12),
                          // Login Form
                          Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: ' رقم الهاتف /البريد الإلكتروني',
                                    // errorText: emailError,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                verticalSpace(16),
                                TextFormField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور',
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
                                verticalSpace(5),
                                // Forgot Password & Remember Me
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        // Navigate to forgot password screen
                                        // Navigator.of(context).pushNamed(Routes.forgotPasswordScreen);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('سيتم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'هل نسيت كلمة المرور؟',
                                        style: TextStyles.font13BlueRegular.copyWith(
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        StatefulBuilder(
                                          builder: (context, setState) {
                                            return Transform.scale(
                                              scale: 0.9,
                                              child: Checkbox(
                                                value: rememberMe,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    rememberMe = value ?? false;
                                                    // Here you can save the login state to shared preferences
                                                    // SharedPreferences prefs = await SharedPreferences.getInstance();
                                                    // await prefs.setBool('rememberMe', rememberMe);
                                                  });
                                                },
                                                activeColor: ColorsManager.mainBlue,
                                              ),
                                            );
                                          },
                                        ),
                                        Text(
                                          'تذكرني',
                                          style: TextStyles.font13DarkBlueRegular,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                verticalSpace(10),
                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  child: AppTextButton(
                                      buttonText: "تسجيل الدخول",
                                      onPressed: () {
                                        Navigator.of(
                                          context,
                                        ).pushNamed(Routes.chatScreen);
                                      }, textStyle: TextStyle(color: Colors.white)
                                  ),
                                ),
                                verticalSpace(10),
                                // Terms & Conditions
                                Text(
                                  'بالدخول، أنت توافق على الشروط والأحكام.',
                                  style: TextStyles.font13GrayRegular,
                                  textAlign: TextAlign.center,
                                ),
                                verticalSpace(6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey[400],
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text('أو', style: TextStyle(color: Colors.grey[600])),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey[400],
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Social Login Buttons - Smaller and in a single row
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Google
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Image.asset(
                                              'assets/images/Google__G__logo.svg.png',
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.contain,
                                            ),
                                            onPressed: () {
                                              // Handle Google sign in
                                            },
                                            style: IconButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: Colors.grey[300]!),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Facebook
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.facebook, size: 24, color: Colors.blue),
                                            onPressed: () {
                                              // Handle Facebook sign in
                                            },
                                            style: IconButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: Colors.grey[300]!),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Apple
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                                            onPressed: () {
                                              // Handle Apple sign in
                                            },
                                            style: IconButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: Colors.grey[300]!),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      // Phone
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: Image.asset(
                                              'assets/images/eee.png',
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.contain,
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(Routes.otpScreen);
                                            },
                                            style: IconButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                                side: BorderSide(color: Colors.grey[300]!),
                                              ),
                                              backgroundColor: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ليس لديك حساب؟',
                                      style: TextStyles.font13DarkBlueRegular,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(Routes.signUpScreen);
                                      },
                                      child: Text(
                                        'إنشاء حساب',
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
            ),
          ],
        ),
      ),
    );
  }
}

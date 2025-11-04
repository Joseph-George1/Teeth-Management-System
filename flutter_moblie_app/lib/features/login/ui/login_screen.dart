import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String? passwordError;
  bool rememberMe = false;
  bool isObscureText = true;

  @override
  Widget build(BuildContext context) {

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: SizedBox(
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
                                    labelText: 'البريد الإلكتروني',
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
                                      icon: Icon(
                                        isObscureText ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isObscureText = !isObscureText;
                                        });
                                      },
                                    ),
                                  ),
                                  obscureText: isObscureText,
                                ),
                                verticalSpace(5),
                                // Forgot Password & Remember Me
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(Routes.forgotPasswordScreen);
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
                                        Transform.scale(
                                          scale: 0.9,
                                          child: Checkbox(
                                            value: rememberMe,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                rememberMe = value ?? false;
                                              });
                                            },
                                            activeColor: ColorsManager.mainBlue,
                                          ),
                                        ),
                                        Text(
                                          'تذكرني',
                                          style: TextStyles.font13DarkBlueMedium,
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
                                      },
                                      textStyle: TextStyle(color: Colors.white),
                                  ),
                                ),
                                verticalSpace(10),
                                // Terms & Conditions
                                Text(
                                  'بالدخول، أنت توافق على الشروط والأحكام.',
                                  style: TextStyles.font13GrayRegular,
                                  textAlign: TextAlign.center,
                                ),
                          ],
                            ),
                          ),
                    ]
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

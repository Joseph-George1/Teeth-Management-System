import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../../core/routing/routes.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {

    bool isLoading = false;
    String? emailError;
    String? passwordError;

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

          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
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
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      verticalSpace(80),

                      Text(
                        'مرحباً بعودتك',
                        style: TextStyles.font24BlueBold,
                      ),
                      verticalSpace(8),
                      Text(
                        'سعداء بعودتك! لا يسعنا الانتظار لمعرفة ما كنت تفعله منذ آخر مرة قمت فيها بتسجيل الدخول.',
                        style: TextStyles.font14GrayRegular,
                        textAlign: TextAlign.right,
                      ),
                      verticalSpace(36),

                      // Login Form
                      Form(

                        child: Column(
                          children: [

                            TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                errorText: emailError,
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
                            verticalSpace(24),

                            // Forgot Password
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                'هل نسيت كلمة المرور؟',
                                style: TextStyles.font13BlueRegular,
                              ),
                            ),
                            verticalSpace(40),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: AppTextButton(
                                buttonText: "تسجيل الدخول",
                                textStyle: TextStyles.font16WhiteSemiBold,
                                onPressed: () {
                                  Navigator.of(context).pushNamed(Routes.chatScreen);
                                },
                              ),
                            ),

                            // Terms & Conditions
                            Text(
                              'بالدخول، أنت توافق على الشروط والأحكام.',
                              style: TextStyles.font13GrayRegular,
                              textAlign: TextAlign.center,
                            ),

                            verticalSpace(24),

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
    );
  }
}
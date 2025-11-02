import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../../core/routing/routes.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top-left gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
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
          Center(
            child: SingleChildScrollView(
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
                        Text('نسيت كلمة المرور', style: TextStyles.font24BlueBold),
                        verticalSpace(8),
                        Text(
                          'ادخل بريدك الإلكتروني وسنرسل لك كود لإعادة تعيين كلمة المرور',
                          style: TextStyles.font14GrayRegular,
                          textAlign: TextAlign.center,
                        ),
                        verticalSpace(24),
                        Form(
                          child: Column(
                            children: [
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'رقم الهاتف / البريد الإلكتروني',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(color: Colors.blue, width: 1.3),
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                              ),
                              verticalSpace(32),
                              SizedBox(
                                width: double.infinity,
                                child: AppTextButton(
                                  buttonText: 'إرسال الكود',
                                  textStyle: TextStyles.font16WhiteSemiBold,
                                  onPressed: () {
                                    // Navigate to OTP screen with forgot password flag
                                    Navigator.of(context).pushNamed(
                                      Routes.otpScreen,
                                      arguments: {'isForgotPassword': true},
                                    );
                                  },
                                ),
                              ),
                              verticalSpace(16),
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'العودة لتسجيل الدخول',
                                    style: TextStyles.font13DarkBlueMedium,
                                  ),
                                ),
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
          ),
        ],
      ),
    );
  }
}

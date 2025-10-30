import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../../core/routing/routes.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [

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

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 30.h),
            child: SingleChildScrollView(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    verticalSpace(80),
                    Text(
                      'إنشاء حساب',
                      style: TextStyles.font24BlueBold,
                    ),
                    verticalSpace(8),
                    Text(
                      'أنشئ حسابك للبدء في استخدام التطبيق.',
                      style: TextStyles.font14GrayRegular,
                      textAlign: TextAlign.right,
                    ),
                    verticalSpace(36),

                    Form(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الكامل',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          verticalSpace(16),
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'البريد الإلكتروني',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                          ),
                          verticalSpace(16),
                          TextFormField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: const Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                            textInputAction: TextInputAction.next,
                          ),
                          verticalSpace(16),
                          TextFormField(
                            controller: confirmPasswordController,
                            decoration: InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: const Icon(Icons.lock_outline),
                            ),
                            obscureText: true,
                          ),

                          verticalSpace(40),
                          SizedBox(
                            width: double.infinity,
                            child: AppTextButton(
                              buttonText: 'إنشاء حساب',
                              textStyle: TextStyles.font16WhiteSemiBold,
                              onPressed: () {
                                Navigator.of(context).pushNamed(Routes.otpScreen);
                              },
                            ),
                          ),

                          verticalSpace(24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'لديك حساب بالفعل؟',
                                style: TextStyles.font13DarkBlueRegular,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(Routes.loginScreen);
                                },
                                child: Text(
                                  'تسجيل الدخول',
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

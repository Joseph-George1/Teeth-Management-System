import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../../core/routing/routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Full screen gradient overlay (same as login)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -0.7),
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
            // Bottom-right gradient overlay (same as login)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.7, 0.7),
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
                          Text(' إنشاء حساب', style: TextStyles.font24BlueBold),
                          verticalSpace(8),
                          Text(
                            'أنشئ حسابك للبدء في استخدام التطبيق.',
                            style: TextStyles.font14GrayRegular,
                            textAlign: TextAlign.right,
                          ),
                          verticalSpace(12),
                          // Sign Up Form (mirrors login field styling)
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
                                verticalSpace(10),
                                // Create Account Button (styled like login)
                                SizedBox(
                                  width: double.infinity,
                                  child: AppTextButton(
                                    buttonText: 'إنشاء حساب',
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(Routes.otpScreen);
                                    },
                                    textStyle: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                verticalSpace(10),
                                // Terms text (same spacing as login)
                                Text(
                                  'بالإنشاء، أنت توافق على الشروط والأحكام.',
                                  style: TextStyles.font13GrayRegular,
                                  textAlign: TextAlign.center,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
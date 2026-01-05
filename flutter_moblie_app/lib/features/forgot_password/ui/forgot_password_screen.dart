import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/booking/ui/otp_verification_dialog.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../../core/routing/routes.dart';
import '../data/forgot_password_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await ForgotPasswordService().sendOtp(_emailController.text.trim());
      
      if (response['success'] == true) {
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => OtpVerificationDialog(
              contactInfo: _emailController.text.trim(),
              isEmail: true,
              onVerified: (code) {
                // Navigate to Reset Password Screen with email and code
                 Navigator.pushNamed(
                  context,
                  Routes.resetPasswordScreen,
                  arguments: {
                    'email': _emailController.text.trim(),
                    'code': code,
                  },
                );
              },
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'حدث خطأ في إرسال رمز التحقق';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في إرسال رمز التحقق. الرجاء المحاولة مرة أخرى';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [
                  ColorsManager.layerBlur1.withValues(alpha: 0.5),
                  ColorsManager.layerBlur1.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.7, 0.7),
                radius: 1.5,
                colors: [
                  ColorsManager.layerBlur2.withValues(alpha: 0.4),
                  ColorsManager.layerBlur2.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
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
                        color: Colors.black.withValues(alpha: 0.1),
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
                          width: 85.w,
                          height: 85.h,
                        ),
                        Text('نسيت كلمة المرور', style: TextStyles.font24BlueBold),
                        verticalSpace(20),
                        Text(
                          'ادخل بريدك الإلكتروني وسنرسل لك كود لإعادة تعيين كلمة المرور',
                          style: TextStyles.font14GrayRegular,
                          textAlign: TextAlign.center,
                        ),
                        verticalSpace(30),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'البريد الإلكتروني',
                                  hintText: 'أدخل بريدك الإلكتروني',
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال البريد الإلكتروني';
                                  }
                                  if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$').hasMatch(value)) {
                                    return 'الرجاء إدخال بريد إلكتروني صالح';
                                  }
                                  return null;
                                },
                              ),
                              
                              if (_errorMessage != null) ...[
                                verticalSpace(30),
                                Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              verticalSpace(24),
                              SizedBox(
                                height: 50.h,
                                width: double.infinity,
                                child: _isLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : AppTextButton(
                                        buttonText: 'إرسال رمز التحقق',
                                        textStyle: TextStyles.font16WhiteSemiBold,
                                        onPressed: _sendOtp,
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

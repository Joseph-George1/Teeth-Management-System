import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/core/helpers/spacing.dart';
import 'package:thotha_mobile_app/core/networking/otp_service.dart';
import 'package:thotha_mobile_app/core/theming/colors.dart';
import 'package:thotha_mobile_app/core/theming/styles.dart';
import 'package:thotha_mobile_app/core/widgets/app_text_button.dart';
import 'package:thotha_mobile_app/core/routing/routes.dart';

class SignupOtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String email;

  const SignupOtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.email,
  }) : super(key: key);

  @override
  _SignupOtpVerificationScreenState createState() =>
      _SignupOtpVerificationScreenState();
}

class _SignupOtpVerificationScreenState
    extends State<SignupOtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  final OtpService _otpService = OtpService();
  
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    // Auto-focus the first OTP field
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final otp = _otpControllers.map((controller) => controller.text).join('');
      print('Verifying OTP: $otp for phone: ${widget.phoneNumber}');

      final result = await _otpService.verifyOtp(widget.phoneNumber, otp);

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // OTP verified successfully
        _showSuccessDialog();
      } else {
        // OTP verification failed
        _showErrorDialog(result['error'] ?? 'فشل التحقق من الرمز');
      }
    }
  }

  Future<void> _resendOtp() async {
    setState(() {
      _isResending = true;
    });

    final result = await _otpService.sendOtp(widget.phoneNumber);

    setState(() {
      _isResending = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'تم إعادة إرسال الرمز بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      _showErrorDialog(result['error'] ?? 'فشل إعادة إرسال الرمز');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28.sp),
            SizedBox(width: 8.w),
            Text('تم التحقق بنجاح', style: TextStyles.font18DarkBlueBold),
          ],
        ),
        content: Text(
          'تم التحقق من رقم هاتفك بنجاح. يمكنك الآن تسجيل الدخول.',
          style: TextStyles.font14GrayRegular,
        ),
        actions: [
          AppTextButton(
            buttonText: 'تسجيل الدخول',
            textStyle: TextStyles.font16WhiteSemiBold,
            onPressed: () {
              // Navigate to login screen and clear all previous routes
              Navigator.pushNamedAndRemoveUntil(
                context,
                Routes.loginScreen,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28.sp),
              SizedBox(width: 8.w),
              Text('خطأ', style: TextStyles.font18DarkBlueBold),
            ],
          ),
          content: Text(message, style: TextStyles.font14GrayRegular),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('حسناً', style: TextStyles.font13BlueSemiBold),
            ),
          ],
        ),
      ),
    );
  }

  void _onOtpChange(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تأكيد رقم الهاتف'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Gradient backgrounds
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.7, -0.7),
                  radius: 1.5,
                  colors: [
                    ColorsManager.layerBlur1.withOpacity(0.5),
                    ColorsManager.layerBlur1.withOpacity(0.1),
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
                    ColorsManager.layerBlur2.withOpacity(0.4),
                    ColorsManager.layerBlur2.withOpacity(0.1),
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
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            verticalSpace(20),
                            Icon(
                              Icons.phone_android,
                              size: 60,
                              color: ColorsManager.mainBlue,
                            ),
                            verticalSpace(16),
                            Text(
                              'أدخل رمز التحقق',
                              style: TextStyles.font24BlueBold,
                              textAlign: TextAlign.center,
                            ),
                            verticalSpace(8),
                            Text(
                              'لقد أرسلنا رمزًا مكونًا من 6 أرقام إلى\n${widget.phoneNumber}',
                              style: TextStyles.font14GrayRegular,
                              textAlign: TextAlign.center,
                            ),
                            verticalSpace(24),

                            // OTP Input Fields
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 45.w,
                                  child: TextFormField(
                                    controller: _otpControllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: TextStyles.font18DarkBlueBold,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                          color: ColorsManager.lighterGray,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderSide: BorderSide(
                                          color: ColorsManager.mainBlue,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) =>
                                        _onOtpChange(value, index),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '';
                                      }
                                      return null;
                                    },
                                  ),
                                );
                              }),
                            ),

                            verticalSpace(24),

                            // Verify Button
                            SizedBox(
                              width: double.infinity,
                              child: AppTextButton(
                                buttonText: _isLoading ? 'جاري التحقق...' : 'تحقق',
                                textStyle: TextStyles.font16WhiteSemiBold,
                                onPressed: _isLoading ? null : _verifyOtp,
                              ),
                            ),

                            verticalSpace(16),

                            // Resend Code
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'لم تستلم الرمز؟ ',
                                  style: TextStyles.font13DarkBlueMedium,
                                ),
                                TextButton(
                                  onPressed: _isResending ? null : _resendOtp,
                                  child: Text(
                                    _isResending ? 'جاري الإرسال...' : 'إعادة إرسال',
                                    style: TextStyles.font13BlueSemiBold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

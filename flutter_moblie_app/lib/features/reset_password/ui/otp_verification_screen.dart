import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;
  
  const OtpVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  @override
  _OtpVerificationScreenState createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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

  void _verifyOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // TODO: Implement OTP verification with your backend
      final otp = _otpControllers.map((controller) => controller.text).join('');
      print('Verifying OTP: $otp for email: ${widget.email}');
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });
        
        // Navigate to reset password screen on success
        Navigator.pushReplacementNamed(
          context,
          '/reset-password',
          arguments: {
            'email': widget.email,
            'otp': otp,
          },
        );
      });
    }
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
        title: const Text('تأكيد الرمز'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Gradient backgrounds...
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
            // Rest of the background...
            
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
                              Icons.verified_user_outlined,
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
                              'لقد أرسلنا رمزًا مكونًا من 6 أرقام إلى ${widget.email}',
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
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                    ),
                                    onChanged: (value) => _onOtpChange(value, index),
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
                                buttonText: 'تحقق',
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
                                  onPressed: () {
                                    // TODO: Implement resend OTP
                                  },
                                  child: Text(
                                    'إعادة إرسال',
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

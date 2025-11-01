import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../../core/routing/routes.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpValid = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() {
      final isValid = _otpController.text.length == 4;
      if (isValid != _isOtpValid) {
        setState(() => _isOtpValid = isValid);
      }
    });
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

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
                        Text('كود التفعيل', style: TextStyles.font24BlueBold),
                        verticalSpace(8),
                        Text(
                          'لقد ارسلنا لك كود اكتبه لكي تفعل الحساب الخاص بك للمتابعه',
                          style: TextStyles.font14GrayRegular,
                          textAlign: TextAlign.right,
                        ),
                        verticalSpace(12),
                        Form(
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _otpController,
                                maxLength: 4,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ],
                                onChanged: (val) {
                                  final isValid = val.length == 4;
                                  if (isValid != _isOtpValid) {
                                    setState(() => _isOtpValid = isValid);
                                  }
                                },
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '— — — —',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              verticalSpace(24),
                              Align(
                                alignment: Alignment.center,
                                child: TextButton(
                                  onPressed: () {
                                    // TODO: Resend OTP
                                  },
                                  child: Text(
                                    'إعادة إرسال الرمز',
                                    style: TextStyles.font13BlueSemiBold,
                                  ),
                                ),
                              ),
                              verticalSpace(24),
                              SizedBox(
                                width: double.infinity,
                                child: AppTextButton(
                                  buttonText: 'تحقق من الرمز',
                                  textStyle: TextStyles.font16WhiteSemiBold,
                                  onPressed: _isOtpValid
                                      ? () {
                                          // TODO: Verify OTP then navigate to success screen
                                          Navigator.of(context).pushNamed(
                                            Routes.otpSuccessScreen,
                                          );
                                        }
                                      : null,
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
                                    'تعديل الرقم والرجوع',
                                    style: TextStyles.font13DarkBlueRegular,
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
          )],
      ),
    );
  }
}

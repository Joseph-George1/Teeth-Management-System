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
                      'تأكيد رقم الهاتف',
                      style: TextStyles.font24BlueBold,
                    ),
                    verticalSpace(8),
                    Text(
                      'أدخل كود التفعيل المرسل إليك عبر الرسالة القصيرة.',
                      style: TextStyles.font14GrayRegular,
                      textAlign: TextAlign.right,
                    ),
                    verticalSpace(36),

                    TextFormField(
                      controller: _otpController,
                      maxLength: 4,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
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

                    verticalSpace(32),
                    SizedBox(
                      width: double.infinity,
                      child: AppTextButton(
                        buttonText: 'تأكيد',
                        textStyle: TextStyles.font16WhiteSemiBold,
                        onPressed: () {
                          // TODO: Verify OTP then navigate
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            Routes.loginScreen,
                            (route) => false,
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
                          'تعديل الرقم والرجوع',
                          style: TextStyles.font13DarkBlueRegular,
                        ),
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

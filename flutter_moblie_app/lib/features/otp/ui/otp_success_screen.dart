import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../../core/routing/routes.dart';

class OtpSuccessScreen extends StatelessWidget {
  const OtpSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top-left gradient overlay (consistent with other screens)
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
                        // Big transparent blue circle with check icon
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorsManager.mainBlue.withOpacity(0.12),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.check_rounded,
                            color: ColorsManager.mainBlue,
                            size: 64.w,
                          ),
                        ),
                        verticalSpace(16),
                        Text(
                          'تم التفعيل بنجاح',
                          style: TextStyles.font24BlueBold,
                          textAlign: TextAlign.center,
                        ),
                        verticalSpace(8),
                        Text(
                          'تهانينا! تم التحقق من الحساب\nاضغط للمتابعه',
                          style: TextStyles.font14GrayRegular,
                          textAlign: TextAlign.center,
                        ),
                        verticalSpace(24),
                        SizedBox(
                          width: double.infinity,
                          child: AppTextButton(
                            buttonText: 'تسجيل الدخول',
                            textStyle: TextStyles.font16WhiteSemiBold,
                            onPressed: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                Routes.loginScreen,
                                (route) => false,
                              );
                            },
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

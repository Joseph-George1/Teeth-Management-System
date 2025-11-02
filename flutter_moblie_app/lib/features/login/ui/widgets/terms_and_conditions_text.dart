import 'package:flutter/material.dart';

import '../../../../core/theming/styles.dart';

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'من خلال تسجيل الدخول، فإنك توافق على شروط الاستخدام الخاصة بنا',
            style: TextStyles.font13GrayRegular,
          ),
          TextSpan(
            text: ' الشروط والأحكام',
            style: TextStyles.font13DarkBlueMedium,
          ),
          TextSpan(
            text: ' و',
            style: TextStyles.font13GrayRegular.copyWith(height: 1.5),
          ),
          TextSpan(
            text: ' سياسة الخصوصية',
            style: TextStyles.font13DarkBlueMedium,
          ),
        ],
      ),
    );
  }
}
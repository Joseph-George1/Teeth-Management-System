import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_moblie_app/core/helpers/extentions.dart';


import '../../../../core/routing/routes.dart';
import '../../../../core/theming/styles.dart';

class DontHaveAccountText extends StatelessWidget {
  const DontHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'ليس لديك حساب؟',
            style: TextStyles.font13DarkBlueMedium,
          ),
          TextSpan(
            text: ' إنشاء حساب',
            style: TextStyles.font13BlueSemiBold,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                context.pushReplacementNamed(Routes.signUpScreen);
              },
          ),
        ],
      ),
    );
  }
}
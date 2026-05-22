import 'package:thoutha_mobile_app/core/helpers/extentions.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theming/styles.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class DontHaveAccountText extends StatelessWidget {
  const DontHaveAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: L10nLogin.dontHaveAnAccount.tr(),
            style: TextStyles.font13DarkBlueMedium,
          ),
          TextSpan(
            text: L10nLogin.createAnAccount1.tr(),
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

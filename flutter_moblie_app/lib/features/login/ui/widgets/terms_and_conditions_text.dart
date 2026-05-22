import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../../core/theming/styles.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class TermsAndConditionsText extends StatelessWidget {
  const TermsAndConditionsText({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text:
                L10nLogin.byLoggingInYou.tr(),
            style: TextStyles.font13GrayRegular,
          ),
          TextSpan(
            text: L10nLogin.termsAndConditions.tr(),
            style: TextStyles.font13DarkBlueMedium,
          ),
          TextSpan(
            text: L10nLogin.and.tr(),
            style: TextStyles.font13GrayRegular.copyWith(height: 1.5),
          ),
          TextSpan(
            text: L10nLogin.privacyPolicy.tr(),
            style: TextStyles.font13DarkBlueMedium,
          ),
        ],
      ),
    );
  }
}

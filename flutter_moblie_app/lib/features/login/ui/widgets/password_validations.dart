import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class PasswordValidations extends StatelessWidget {
  final bool hasLowerCase;
  final bool hasUpperCase;
  final bool hasSpecialCharacters;
  final bool hasNumber;
  final bool hasMinLength;
  const PasswordValidations({
    super.key,
    required this.hasLowerCase,
    required this.hasUpperCase,
    required this.hasSpecialCharacters,
    required this.hasNumber,
    required this.hasMinLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildValidationRow(context, L10nLogin.atLeastOneLowercase.tr(), hasLowerCase),
        verticalSpace(2),
        buildValidationRow(context, L10nLogin.atLeastOneUppercase.tr(), hasUpperCase),
        verticalSpace(2),
        buildValidationRow(context, L10nLogin.atLeastOneSpecial.tr(), hasSpecialCharacters),
        verticalSpace(2),
        buildValidationRow(context, L10nLogin.atLeastOneNumber.tr(), hasNumber),
        verticalSpace(2),
        buildValidationRow(context, L10nLogin.atLeast8Characters.tr(), hasMinLength),
      ],
    );
  }

  Widget buildValidationRow(BuildContext context, String text, bool hasValidated) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        CircleAvatar(
          radius: 2.5,
          backgroundColor: isDarkMode ? Colors.white70 : ColorsManager.gray,
        ),
        horizontalSpace(6),
        Text(
          text,
          style: TextStyles.font13DarkBlueMedium.copyWith(
            decoration: hasValidated ? TextDecoration.lineThrough : null,
            decorationColor: Colors.green,
            decorationThickness: 2,
            color: hasValidated 
                ? ColorsManager.gray 
                : (isDarkMode ? Colors.white : ColorsManager.darkBlue),
            fontWeight: hasValidated ? FontWeight.normal : FontWeight.w500,
          ),
        )
      ],
    );
  }
}

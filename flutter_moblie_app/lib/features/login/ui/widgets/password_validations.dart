import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/colors.dart';
import '../../../../core/theming/styles.dart';

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
        buildValidationRow('حرف صغير واحد على الأقل', hasLowerCase),
        verticalSpace(2),
        buildValidationRow('حرف كبير واحد على الأقل', hasUpperCase),
        verticalSpace(2),
        buildValidationRow('حرف خاص واحد على الأقل', hasSpecialCharacters),
        verticalSpace(2),
        buildValidationRow('رقم واحد على الأقل', hasNumber),
        verticalSpace(2),
        buildValidationRow('8 أحرف على الأقل', hasMinLength),
      ],
    );
  }

  Widget buildValidationRow(String text, bool hasValidated) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 2.5,
          backgroundColor: ColorsManager.gray,
        ),
        horizontalSpace(6),
        Text(
          text,
          style: TextStyles.font13DarkBlueMedium.copyWith(
            decoration: hasValidated ? TextDecoration.lineThrough : null,
            decorationColor: Colors.green,
            decorationThickness: 2,
            color: hasValidated ? ColorsManager.gray : ColorsManager.darkBlue,
            fontWeight: hasValidated ? FontWeight.normal : FontWeight.w500,
          ),
        )
      ],
    );
  }
}

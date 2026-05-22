import 'package:flutter/material.dart';

import '../theming/colors.dart';

class AppTextButton extends StatelessWidget {
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? disabledBackgroundColor;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final TextStyle textStyle;
  final VoidCallback? onPressed;
  const AppTextButton({
    super.key,
    this.borderRadius,
    this.backgroundColor,
    this.disabledBackgroundColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.buttonHeight,
    this.buttonWidth,
    required this.buttonText,
    required this.textStyle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? 16.0;
    final double hPadding = horizontalPadding ?? 12.0;
    final double vPadding = verticalPadding ?? 14.0;
    final double btnHeight = buttonHeight ?? 50.0;
    final double? btnWidth = buttonWidth;

    return TextButton(
      style: ButtonStyle(
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return disabledBackgroundColor ??
                (backgroundColor ?? ColorsManager.mainBlue)
                    .withValues(alpha: 0.5);
          }
          return backgroundColor ?? ColorsManager.mainBlue;
        }),
        padding: WidgetStateProperty.all<EdgeInsets>(
          EdgeInsets.symmetric(
            horizontal: hPadding,
            vertical: vPadding,
          ),
        ),
        minimumSize: WidgetStateProperty.all(
          Size(btnWidth?.toDouble() ?? 0, btnHeight.toDouble()),
        ),
        maximumSize: WidgetStateProperty.all(
          Size(double.infinity, btnHeight + 8),
        ),
      ),
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          buttonText,
          style: textStyle,
          maxLines: 1,
          softWrap: false,
        ),
      ),
    );
  }
}

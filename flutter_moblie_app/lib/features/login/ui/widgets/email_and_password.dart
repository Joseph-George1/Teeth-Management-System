import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/styles.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class EmailAndPassword extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? passwordError;
  final bool isObscureText;
  final VoidCallback onTogglePasswordVisibility;
  final ValueChanged<bool> onRememberMeChanged;
  final bool _rememberMe;

  const EmailAndPassword({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.passwordError,
    required this.isObscureText,
    required this.onTogglePasswordVisibility,
    required this.onRememberMeChanged,
    bool rememberMe = false,
  }) : _rememberMe = rememberMe;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            labelText: L10nDoctor.email.tr(),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        verticalSpace(16),
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            labelText: L10nLogin.password.tr(),
            errorText: passwordError,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscureText ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onTogglePasswordVisibility,
            ),
          ),
          obscureText: isObscureText,
        ),
        verticalSpace(5),
        // Forgot Password & Remember Me
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              L10nLogin.forgotYourPassword1.tr(),
              style: TextStyles.font13BlueRegular,
            ),
            Row(
              children: [
                Transform.scale(
                  scale: 0.9,
                  child: StatefulBuilder(
                    builder: (context, setState) => Checkbox(
                      value: _rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          // Can't modify final _rememberMe, need to track in parent state
                          onRememberMeChanged(value ?? false);
                        });
                      },
                      activeColor: Colors.blue,
                    ),
                  ),
                ),
                Text(
                  L10nLogin.rememberMe.tr(),
                  style: TextStyles.font13DarkBlueRegular,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

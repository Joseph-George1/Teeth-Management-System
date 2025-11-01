import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/theming/styles.dart';

class EmailAndPassword extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String? passwordError;
  final bool isObscureText;
  final VoidCallback onTogglePasswordVisibility;
  final ValueChanged<bool> onRememberMeChanged;
  bool _rememberMe = false;

   EmailAndPassword({
    super.key,
    required this.emailController,
    required this.passwordController,
    this.passwordError,
    required this.isObscureText,
    required this.onTogglePasswordVisibility,
    required this.onRememberMeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'البريد الإلكتروني',
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
              labelText: 'كلمة المرور',
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
                'هل نسيت كلمة المرور؟',
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
                            _rememberMe = value ?? false;
                          });
                          onRememberMeChanged(_rememberMe);
                        },
                        activeColor: Colors.blue,
                      ),
                    ),
                  ),
                  Text(
                    'تذكرني',
                    style: TextStyles.font13DarkBlueRegular,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
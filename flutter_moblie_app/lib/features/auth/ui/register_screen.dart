import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thoutha_mobile_app/core/helpers/app_regex.dart';
import 'package:thoutha_mobile_app/core/helpers/spacing.dart';
import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:thoutha_mobile_app/core/theming/colors.dart';
import 'package:thoutha_mobile_app/core/theming/styles.dart';
import 'package:thoutha_mobile_app/features/auth/data/auth_service.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facultyController = TextEditingController();
  final _yearController = TextEditingController();
  final _governorateController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _facultyController.dispose();
    _yearController.dispose();
    _governorateController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return L10nAuth.emailRequired.tr();
    }
    if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$').hasMatch(value)) {
      return L10nAuth.pleaseEnterAValid.tr();
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return L10nAuth.passwordRequired.tr();
    }
    if (value.length < 6) {
      return L10nAuth.passwordMustBeAt.tr();
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return L10nAuth.passwordConfirmationIsRequired.tr();
    }
    if (value != _passwordController.text) {
      return L10nAuth.passwordsDoNotMatch.tr();
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return L10nAuth.var0IsRequired.tr(namedArgs: {'var_0': fieldName.toString()});
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _authService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirm: _confirmPasswordController.text,
        first_name: _firstNameController.text.trim(),
        last_name: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        faculty: _facultyController.text.trim(),
        year: _yearController.text.trim(),
        governorate: _governorateController.text.trim(),
      );

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message'] ?? L10nAuth.theAccountHasBeen.tr(),
                textAlign: TextAlign.right,
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, Routes.loginScreen);
        }
      } else {
        setState(() {
          _errorMessage =
              response['error'] ?? L10nAuth.accountCreationFailedPlease.tr();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = L10nAuth.anErrorOccurredConnecting.tr();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final baseFontSize = width * 0.04;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(L10nAuth.createANewAccount.tr()),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  verticalSpace(40),
                  Center(
                    child: Text(
                      L10nAuth.thutha.tr(),
                      style: TextStyles.font24BlueBold.copyWith(
                        fontSize: baseFontSize * 1.5,
                      ),
                    ),
                  ),
                  verticalSpace(24),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: L10nAuth.email.tr(),
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: _validateEmail,
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: L10nAuth.password.tr(),
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    obscureText: true,
                    validator: _validatePassword,
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: L10nAuth.confirmPassword.tr(),
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    obscureText: true,
                    validator: _validateConfirmPassword,
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: InputDecoration(
                      labelText: L10nAuth.firstName.tr(),
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[\u0621-\u064A\s]'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return L10nAuth.firstNameRequired.tr();
                      }
                      if (!AppRegex.isArabicName(value.trim())) {
                        return L10nAuth.theFirstNameMust.tr();
                      }
                      return null;
                    },
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: InputDecoration(
                      labelText: L10nAuth.lastName.tr(),
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'[\u0621-\u064A\s]'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return L10nAuth.lastNameRequired.tr();
                      }
                      if (!AppRegex.isArabicName(value.trim())) {
                        return L10nAuth.theLastNameMust.tr();
                      }
                      return null;
                    },
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: L10nAuth.phoneNumber.tr(),
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        _validateRequired(value, L10nAuth.phoneNumber.tr()),
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _facultyController,
                    decoration: InputDecoration(
                      labelText: L10nAuth.college.tr(),
                      prefixIcon: Icon(Icons.school_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) => _validateRequired(value, L10nAuth.college.tr()),
                  ),
                  verticalSpace(16),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: L10nAuth.academicYear.tr(),
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: [L10nAuth.fourth.tr(), L10nAuth.fifth.tr(), L10nAuth.privilege.tr()]
                        .map((year) => DropdownMenuItem(
                              value: year,
                              child: Text(year),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        _yearController.text = value;
                      }
                    },
                    initialValue: _yearController.text.isNotEmpty
                        ? _yearController.text
                        : null,
                    validator: (value) =>
                        _validateRequired(value, L10nAuth.academicYear.tr()),
                  ),
                  verticalSpace(16),
                  TextFormField(
                    controller: _governorateController,
                    decoration: InputDecoration(
                      labelText: L10nAuth.text.tr(),
                      helperText: L10nAuth.text1.tr(),
                      prefixIcon: Icon(Icons.location_city_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) => _validateRequired(value, L10nAuth.text.tr()),
                  ),
                  if (_errorMessage != null) ...[
                    SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: baseFontSize * 0.875,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  SizedBox(height: 32),
                  SizedBox(
                    height: 52 * (width / 390),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: ColorsManager.mainBlue,
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            )
                          : Text(
                              L10nAuth.registration.tr(),
                              style: TextStyle(
                                fontSize: baseFontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                          context, Routes.loginScreen);
                    },
                    child: Text(
                      L10nAuth.alreadyHaveAnAccount.tr(),
                      style: TextStyle(
                        color: ColorsManager.mainBlue,
                        fontSize: baseFontSize * 0.875,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

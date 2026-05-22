import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../core/routing/routes.dart';
import '../../../core/theming/colors.dart';
import '../../auth/data/auth_service.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
/*import 'package:showcaseview/showcaseview.dart';
import 'package:thoutha_mobile_app/tour/tour_config.dart';
import 'package:thoutha_mobile_app/tour/tour_service.dart';*/


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.nextScreen, this.nextRouteSettings});

  final Widget? nextScreen;
  final RouteSettings? nextRouteSettings;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String? passwordError;
  String? errorMessage;
  bool rememberMe = false;
  bool isObscureText = true;
  late final GlobalKey<FormState> _formKey;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _loadSavedCredentials();
  }

  // Load saved credentials if they exist
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = prefs.getBool('rememberMe') ?? false;
      if (rememberMe) {
        emailController.text = prefs.getString('savedEmail') ?? '';
        passwordController.text = prefs.getString('savedPassword') ?? '';
      }
    });
  }

  // Save or clear credentials based on rememberMe value
  Future<void> _handleRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      rememberMe = value;
    });

    if (value) {
      // Save credentials
      await prefs.setBool('rememberMe', true);
      await prefs.setString('savedEmail', emailController.text);
      await prefs.setString('savedPassword', passwordController.text);
    } else {
      // Clear saved credentials
      await prefs.remove('rememberMe');
      await prefs.remove('savedEmail');
      await prefs.remove('savedPassword');
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (rememberMe) {
      await _handleRememberMe(true);
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      passwordError = null;
    });

    try {
      final result = await AuthService().login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      if (result['success'] == true) {
        Navigator.of(context).pushReplacementNamed(
          Routes.doctorHomeScreen,
          arguments: widget.nextRouteSettings?.arguments,
        );
      } else {
        final errorMsg =
            result['error'] ?? L10nLogin.loginFailedPleaseTry.tr();
        setState(() {
          errorMessage = errorMsg;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Login failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Full screen gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [
                  isDarkMode
                      ? ColorsManager.layerBlur1.withAlpha(50)
                      : ColorsManager.layerBlur1.withAlpha(102),
                  isDarkMode
                      ? ColorsManager.layerBlur1.withAlpha(20)
                      : ColorsManager.layerBlur1.withAlpha(25),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),

          // Bottom-right gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.7, 0.7),
                radius: 1.5,
                colors: [
                  isDarkMode
                      ? ColorsManager.layerBlur2.withAlpha(50)
                      : ColorsManager.layerBlur2.withAlpha(102),
                  isDarkMode
                      ? ColorsManager.layerBlur2.withAlpha(20)
                      : ColorsManager.layerBlur2.withAlpha(25),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.3, 0.8],
              ),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                final isTablet = screenWidth >= 600;
                final baseFontSize = screenWidth * 0.04;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? screenWidth * 0.1 : 24,
                        vertical: isTablet ? screenHeight * 0.1 : 24,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: isTablet ? 550 : double.infinity,
                            ),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: isDarkMode
                                      ? Colors.black.withAlpha(102)
                                      : Colors.black.withAlpha(25),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Form(
                                key: _formKey,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/images/splash-logo.png',
                                        width: isTablet ? 120 : 80,
                                        height: isTablet ? 120 : 80,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      L10nHomeScreen.login.tr(),
                                      style: TextStyle(
                                        fontSize: (baseFontSize * 1.5).clamp(20.0, 28.0),
                                        fontWeight: FontWeight.bold,
                                        color: ColorsManager.mainBlue,
                                        fontFamily: 'Cairo',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      L10nLogin.enterYourEmailAnd.tr(),
                                      style: TextStyle(
                                        fontSize: (baseFontSize * 0.875).clamp(14.0, 18.0),
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.grey,
                                        fontFamily: 'Cairo',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 24),

                                    if (errorMessage != null)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(bottom: 16),
                                        decoration: BoxDecoration(
                                          color: isDarkMode
                                              ? Colors.red
                                                  .withValues(alpha: 0.15)
                                              : Colors.red[50],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: isDarkMode
                                                  ? Colors.red.shade900
                                                  : Colors.red[200]!),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: isDarkMode
                                                    ? Colors.red[300]
                                                    : Colors.red,
                                                size: 20),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                errorMessage!,
                                                style: TextStyle(
                                                  color: isDarkMode
                                                      ? Colors.red[300]
                                                      : Colors.red,
                                                  fontFamily: 'Cairo',
                                                  fontSize: (baseFontSize * 0.8).clamp(13.0, 16.0),
                                                ),
                                                softWrap: true,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // Tour: Email Field
                                    TextFormField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: L10nDoctor.email.tr(),
                                        prefixIcon: Icon(Icons.email_outlined),
                                        labelStyle: TextStyle(
                                            fontSize: (baseFontSize * 0.8).clamp(14.0, 16.0)),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return L10nLogin.pleaseEnterYourEmail.tr();
                                        }
                                        if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$')
                                            .hasMatch(value)) {
                                          return L10nLogin.pleaseEnterAValid.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),

                                    // Tour: Password Field
                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: isObscureText,
                                      decoration: InputDecoration(
                                        labelText: L10nLogin.password.tr(),
                                        prefixIcon:
                                            Icon(Icons.lock_outline),
                                        labelStyle: TextStyle(
                                            fontSize: (baseFontSize * 0.8).clamp(14.0, 16.0)),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isObscureText
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isObscureText = !isObscureText;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return L10nLogin.pleaseEnterYourPassword.tr();
                                        }
                                        if (value.length < 6) {
                                          return L10nLogin.passwordMustBeAt.tr();
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 8),

                                    // Forgot Password & Remember Me
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pushNamed(
                                                  Routes.forgotPasswordScreen);
                                            },
                                            child: Text(
                                              L10nLogin.forgotYourPassword.tr(),
                                              style: TextStyle(
                                                fontSize: (baseFontSize * 0.8).clamp(13.0, 16.0),
                                                color: ColorsManager.mainBlue,
                                                decoration:
                                                    TextDecoration.underline,
                                                fontFamily: 'Cairo',
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Transform.scale(
                                              scale: isTablet ? 1.1 : 0.9,
                                              child: Checkbox(
                                                value: rememberMe,
                                                onChanged: (bool? value) {
                                                  _handleRememberMe(
                                                      value ?? false);
                                                },
                                                activeColor:
                                                    ColorsManager.mainBlue,
                                              ),
                                            ),
                                            Text(
                                              L10nLogin.rememberMe.tr(),
                                              style: TextStyle(
                                                fontSize: (baseFontSize * 0.8).clamp(13.0, 16.0),
                                                color: isDarkMode
                                                    ? Colors.white
                                                    : ColorsManager.darkBlue,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: 'Cairo',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 24),

                                    SizedBox(
                                      width: double.infinity,
                                      height: isTablet ? 60 : 52,
                                      child: ElevatedButton(
                                        onPressed: isLoading ? null : _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              ColorsManager.mainBlue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: isLoading
                                            ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white,
                                                ),
                                              )
                                            : Text(
                                                L10nHomeScreen.login.tr(),
                                                style: TextStyle(
                                                  fontSize: (baseFontSize * 0.9).clamp(16.0, 20.0),
                                                  color: Colors.white,
                                                  fontFamily: 'Cairo',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      L10nLogin.byEnteringYouAgree.tr(),
                                      style: TextStyle(
                                        fontSize: (baseFontSize * 0.75).clamp(12.0, 15.0),
                                        color: isDarkMode
                                            ? Colors.white60
                                            : Colors.grey,
                                        fontFamily: 'Cairo',
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 16),
                                    // Sign up link
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          L10nLogin.dontAlreadyHaveAn.tr(),
                                          style: TextStyle(
                                            fontSize: (baseFontSize * 0.8).clamp(13.0, 16.0),
                                            color: isDarkMode
                                                ? Colors.white
                                                : ColorsManager.darkBlue,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, Routes.signUpScreen);
                                          },
                                          child: Text(
                                            L10nLogin.createAnAccount.tr(),
                                            style: TextStyle(
                                              fontSize: (baseFontSize * 0.8).clamp(13.0, 16.0),
                                              color: ColorsManager.mainBlue,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Back button
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                Routes.categoriesScreen,
                                (route) => false,
                              );
                            },
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: isTablet ? 550 : double.infinity,
                              ),
                              height: isTablet ? 60 : 52,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    ColorsManager.layerBlur1,
                                    ColorsManager.layerBlur2,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(25),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  L10nLogin.returnToTheHome.tr(),
                                  style: TextStyle(
                                    fontSize: (baseFontSize * 0.875).clamp(14.0, 18.0),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

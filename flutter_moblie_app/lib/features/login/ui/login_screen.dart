import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/routing/routes.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/widgets/app_text_button.dart';
import '../../auth/data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

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

  @override
  Widget build(BuildContext context) {

    // Handle login form submission
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form validation fails
    }
    
    // Save credentials if remember me is checked
    if (rememberMe) {
      await _handleRememberMe(true);
    }
    
    // Save credentials if remember me is checked
    if (rememberMe) {
      await _handleRememberMe(true);
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
      passwordError = null;
    });

    try {
      // Call the login API
      final result = await AuthService().login(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      
      if (result['success'] == true) {
        if (mounted) {
          // Navigate to home screen on successful login
          Navigator.pushReplacementNamed(context, Routes.categoriesScreen);
        }
      } else {
        // Show error message if login fails
        String errorMsg = result['error'] ?? 'فشل تسجيل الدخول. الرجاء المحاولة مرة أخرى.';
        
        // More specific error messages based on status code
        if (result['statusCode'] == 401) {
          errorMsg = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
        } else if (result['statusCode'] == 404) {
          errorMsg = 'لا يوجد حساب مسجل بهذا البريد الإلكتروني. الرجاء إنشاء حساب أولاً';
        }
        
        setState(() {
          errorMessage = errorMsg;
        });
      }
      } catch (e) {
        if (mounted) {
          setState(() {
            errorMessage = 'Login failed. Please try again.';
            // You can add more specific error handling here
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
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      super.dispose();
    }

    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Full screen gradient overlay
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -0.7), // Top-left quadrant
                  radius: 1.5,
                  colors: [
                    ColorsManager.layerBlur1.withOpacity(0.4),
                    ColorsManager.layerBlur1.withOpacity(0.1),
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
                  center: Alignment(0.7, 0.7), // Bottom-right quadrant
                  radius: 1.5,
                  colors: [
                    ColorsManager.layerBlur2.withOpacity(0.4),
                    ColorsManager.layerBlur2.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.1, 0.3, 0.8],
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: EdgeInsets.all(24.0.w),
                child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.0.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            verticalSpace(10),
                            Center(
                              child: Image.asset(
                                'assets/images/splash-logo.png',
                                width: 80.w,
                                height: 80.h,
                              ),
                            ),
                            Text('تسجيل الدخول', 
                              style: TextStyles.font24BlueBold,
                              textAlign: TextAlign.center,
                            ),
                            verticalSpace(8),
                            Text(
                              'ادخل البريد الإلكتروني وكلمة المرور',
                              style: TextStyles.font14GrayRegular,
                              textAlign: TextAlign.center,
                            ),
                            verticalSpace(16),
                            
                            // Error message
                            if (errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  color: Colors.red[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red[200]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error_outline, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
errorMessage ?? 'An error occurred',
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            // Email Field
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }
                                if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$').hasMatch(value)) {
                                  return 'الرجاء إدخال بريد إلكتروني صالح';
                                }
                                return null;
                              },
                            ),
                            
                            verticalSpace(16),
                            
                            // Password Field
                            TextFormField(
                              controller: passwordController,
                              obscureText: isObscureText,
                              decoration: InputDecoration(
                                labelText: 'كلمة المرور',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isObscureText ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isObscureText = !isObscureText;
                                    });
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                if (value.length < 6) {
                                  return 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                            
                            verticalSpace(8),
                            
                            // Forgot Password & Remember Me
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(Routes.forgotPasswordScreen);
                                  },
                                  child: Text(
                                    'نسيت كلمة المرور؟',
                                    style: TextStyles.font13BlueRegular.copyWith(
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Transform.scale(
                                      scale: 0.9,
                                      child: Checkbox(
                                        value: rememberMe,
                                        onChanged: (bool? value) {
                                          _handleRememberMe(value ?? false);
                                        },
                                        activeColor: ColorsManager.mainBlue,
                                      ),
                                    ),
                                    Text(
                                      'تذكرني',
                                      style: TextStyles.font13DarkBlueMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            
                            verticalSpace(16),
                            
                            // Login Button
                            SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ColorsManager.mainBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('تسجيل الدخول', style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                                verticalSpace(10),
                                // Terms & Conditions
                                Text(
                                  'بالدخول، أنت توافق على الشروط والأحكام.',
                                  style: TextStyles.font13GrayRegular,
                                  textAlign: TextAlign.center,
                                ),
                                verticalSpace(16),
                                // Sign up link
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'هل ليس لديك حساب بالفعل؟ ',
                                      style: TextStyles.font13DarkBlueMedium,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, Routes.signUpScreen);
                                      },
                                      child: Text(
                                        'إنشاء حساب',
                                        style: TextStyles.font13BlueSemiBold.copyWith(
                                          decoration: TextDecoration.underline,
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
                ),
              ),
                          ],
                        ),
                      ),
                    );
  }
}

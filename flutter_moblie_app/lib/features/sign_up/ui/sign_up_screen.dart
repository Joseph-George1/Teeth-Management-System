import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/core/helpers/spacing.dart';
import 'package:thotha_mobile_app/core/theming/colors.dart';
import 'package:thotha_mobile_app/core/theming/styles.dart';
import 'package:thotha_mobile_app/core/widgets/app_text_button.dart';
import 'package:thotha_mobile_app/core/routing/routes.dart';
import 'package:thotha_mobile_app/features/sign_up/logic/sign_up_cubit.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController patientEmailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? _selectedUserType;

  // List of countries with code, flag, and Arabic name
  //final List<Map<String, String>> countries = [
   // {'code': '+20', 'flag': '🇪🇬', 'name': 'مصر'},
  //  {'code': '+966', 'flag': '🇸🇦', 'name': 'السعودية'},
  //  {'code': '+971', 'flag': '🇦🇪', 'name': 'الإمارات'},
  //  {'code': '+965', 'flag': '🇰🇼', 'name': 'الكويت'},
   // {'code': '+974', 'flag': '🇶🇦', 'name': 'قطر'},
   // {'code': '+973', 'flag': '🇧🇭', 'name': 'البحرين'},
   // {'code': '+968', 'flag': '🇴🇲', 'name': 'عمان'},
  //  {'code': '+962', 'flag': '🇯🇴', 'name': 'الأردن'},
   // {'code': '+961', 'flag': '🇱🇧', 'name': 'لبنان'},
   // {'code': '+964', 'flag': '🇮🇶', 'name': 'العراق'},
   // {'code': '+212', 'flag': '🇲🇦', 'name': 'المغرب'},
    //{'code': '+213', 'flag': '🇩🇿', 'name': 'الجزائر'},
   // {'code': '+216', 'flag': '🇹🇳', 'name': 'تونس'},
   // {'code': '+218', 'flag': '🇱🇾', 'name': 'ليبيا'},
   // {'code': '+249', 'flag': '🇸🇩', 'name': 'السودان'},
   // {'code': '+967', 'flag': '🇾🇪', 'name': 'اليمن'},
   // {'code': '+963', 'flag': '🇸🇾', 'name': 'سوريا'},
   //// {'code': '+90', 'flag': '🇹🇷', 'name': 'تركيا'},
   // {'code': '+92', 'flag': '🇵🇰', 'name': 'باكستان'},
   // {'code': '+91', 'flag': '🇮🇳', 'name': 'الهند'},
   // {'code': '+1', 'flag': '🇺🇸', 'name': 'الولايات المتحدة'},
   // {'code': '+44', 'flag': '🇬🇧', 'name': 'بريطانيا'},
   //{'code': '+33', 'flag': '🇫🇷', 'name': 'فرنسا'},
    //{'code': '+49', 'flag': '🇩🇪', 'name': 'ألمانيا'},
  //];

  String? selectedCountryCode = '+20';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Controllers are now initialized with their declarations
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    patientEmailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpCubit(),
      child: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Navigate to login after a short delay
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushReplacementNamed(context, Routes.loginScreen);
            });
          } else if (state is SignUpError) {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Scaffold(
          body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Full screen gradient overlay (same as login)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(-0.7, -0.7),
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
            // Bottom-right gradient overlay (same as login)
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.7, 0.7),
                  radius: 1.5,
                  colors: [
                    ColorsManager.layerBlur2.withOpacity(0.4),
                    ColorsManager.layerBlur2.withOpacity(0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.8],
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          verticalSpace(20),
                          Image.asset(
                            'assets/images/splash-logo.png',
                            width: 80.w,
                            height: 80.h,
                          ),
                          Text(' إنشاء حساب', style: TextStyles.font24BlueBold),
                          Text(
                            'أنشئ حسابك للبدء في استخدام التطبيق.',
                            style: TextStyles.font14GrayRegular,
                            textAlign: TextAlign.right,
                          ),
                          verticalSpace(10),
                          // User Type Selection - Buttons
                          Row(
                            children: [
                              // Doctor Button - Moved to the left
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedUserType = 'طبيب';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.horizontal(
                                        right: Radius.circular(6),
                                      ),
                                      border: Border.all(
                                        color: _selectedUserType == 'طبيب' 
                                            ? ColorsManager.mainBlue 
                                            : Colors.grey[300]!,
                                        width: _selectedUserType == 'طبيب' ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      'طبيب',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedUserType == 'طبيب' 
                                            ? ColorsManager.mainBlue 
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Patient Button - Moved to the right
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedUserType = 'مريض';
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: const BorderRadius.horizontal(
                                        left: Radius.circular(6),
                                      ),
                                      border: Border.all(
                                        color: _selectedUserType == 'مريض'
                                            ? ColorsManager.mainBlue 
                                            : Colors.grey[300]!,
                                        width: _selectedUserType == 'مريض' ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      'مريض',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: _selectedUserType == 'مريض'
                                            ? ColorsManager.mainBlue 
                                            : Colors.grey[600],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                       /*   verticalSpace(16),
                          // First Name Field
                          TextFormField(
                            controller: nameController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الأول',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),
                          verticalSpace(16),
                          // Last Name Field
                          TextFormField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'الاسم الأخير',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.person_outline),
                            ),
                          ),*/
                          // Show Email only for Doctors
                        /*  if (_selectedUserType == 'طبيب') ...[
                            verticalSpace(16),
                            TextFormField(
                              controller: patientEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                            ),
                          ],*/
                          verticalSpace(16),
                          // Phone Number with Country Code
                            // Phone Number Field
                            TextFormField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: 'البريد الاكتروني',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                            ),
                          verticalSpace(16),
                          // Password Field
                          TextFormField(
                            controller: passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'كلمة المرور',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                          ),
                          verticalSpace(16),
                          // Confirm Password Field
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'تأكيد كلمة المرور',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              prefixIcon: const Icon(Icons.lock_outline),
                            ),
                          ),
                          verticalSpace(24),
                          // Sign Up Button
                          BlocBuilder<SignUpCubit, SignUpState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: state is SignUpLoading
                                    ? const Center(child: CircularProgressIndicator())
                                    : AppTextButton(
                                        buttonText: 'إنشاء حساب',
                                        textStyle: TextStyles.font16WhiteSemiBold,
                                        onPressed: () {
                                          if (_selectedUserType == null) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('الرجاء تحديد نوع المستخدم'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          
                                          // For patients, use email as the primary contact
                                          // For doctors, use phone number with country code
                                          final phone = _selectedUserType == 'طبيب' 
                                              ? '${selectedCountryCode}${phoneController.text.trim()}'
                                              : emailController.text.trim();
                                              
                                          context.read<SignUpCubit>().signUp(
                                                email: emailController.text.trim(),
                                                password: passwordController.text,
                                                name: nameController.text.trim(),
                                                phone: phone,
                                                userType: _selectedUserType!,
                                              );
                                        },
                                      ),
                              );
                            },
                          ),
                          verticalSpace(10),
                          // Terms text (same spacing as login)
                          Text(
                            'بالإنشاء، أنت توافق على الشروط والأحكام.',
                            style: TextStyles.font13GrayRegular,
                            textAlign: TextAlign.center,
                          ),
                          verticalSpace(24),
                          // Already have an account? Login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'لديك حساب بالفعل؟',
                                style: TextStyles.font13DarkBlueMedium,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(Routes.loginScreen);
                                },
                                child: Text(
                                  'تسجيل الدخول',
                                  style: TextStyles.font13BlueSemiBold,
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
    )));
  }
}
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
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final String _userType = 'طالب'; // Default user type

  String? _selectedCollege;
  String? _selectedStudyYear;
  String? _selectedGovernorate;

  final List<String> _colleges = [
    'كلية طب الأسنان - القاهرة',
    'كلية طب الأسنان - عين شمس',
    'كلية طب الأسنان - الإسكندرية',
    'كلية طب الأسنان - المنصورة',
    'أخرى',
  ];

  final List<String> _studyYears = [
    'الفرقة الأولى',
    'الفرقة الثانية',
    'الفرقة الثالثة',
    'الفرقة الرابعة',
    'الفرقة الخامسة',
    'امتياز',
  ];

  final List<String> _governorates = [
    'القاهرة',
    'الجيزة',
    'الإسكندرية',
    'الدقهلية',
    'الشرقية',
    'الغربية',
    'المنوفية',
    'البحيرة',
    'القليوبية',
    'دمياط',
    'كفر الشيخ',
    'بورسعيد',
    'الإسماعيلية',
    'السويس',
    'المنيا',
    'أسيوط',
    'سوهاج',
    'قنا',
    'الأقصر',
    'أسوان',
    'البحر الأحمر',
    'مطروح',
    'شمال سيناء',
    'جنوب سيناء',
    'الفيوم',
    'بني سويف',
    'الوادي الجديد',
  ];

  String? selectedCountryCode = '+20';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Controllers are now initialized with their declarations
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
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
                Future.delayed(const Duration(seconds: 3), () {
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
                                     verticalSpace(16),
                                     // First Name Field
                                     TextFormField(
                                       controller: firstNameController,
                                       textInputAction: TextInputAction.next,
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
                                       controller: lastNameController,
                                       textInputAction: TextInputAction.next,
                                       decoration: InputDecoration(
                                         labelText: 'الاسم الأخير',
                                         border: OutlineInputBorder(
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                         prefixIcon: const Icon(Icons.person_outline),
                                       ),
                                     ),
                                     verticalSpace(16),
                                     // Email Field
                                     TextFormField(
                                       controller: emailController,
                                       keyboardType: TextInputType.emailAddress,
                                       decoration: InputDecoration(
                                         labelText: 'البريد الإلكتروني',
                                         border: OutlineInputBorder(
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                         prefixIcon: const Icon(Icons.email_outlined),
                                       ),
                                     ),
                                     verticalSpace(16),
                                     // Phone Number with Country Code
                                     // Phone Number Field
                                     TextFormField(
                                       controller: phoneController,
                                       keyboardType: TextInputType.phone,
                                       decoration: InputDecoration(
                                         labelText: 'رقم الهاتف',
                                         border: OutlineInputBorder(
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                         prefixIcon: const Icon(Icons.phone_outlined),
                                       ),
                                     ),
                                     verticalSpace(16),
                                     // College Dropdown
                                     DropdownButtonFormField<String>(
                                       value: _selectedCollege,
                                       decoration: InputDecoration(
                                         labelText: 'اختر الكلية',
                                         border: OutlineInputBorder(
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                       ),
                                       items: _colleges
                                           .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                                           .toList(),
                                       onChanged: (v) => setState(() => _selectedCollege = v),
                                     ),
                                     verticalSpace(16),
                                     // Study Year Dropdown
                                     DropdownButtonFormField<String>(
                                       value: _selectedStudyYear,
                                       decoration: InputDecoration(
                                         labelText: 'السنة الدراسية',
                                         border: OutlineInputBorder(
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                       ),
                                       items: _studyYears
                                           .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                                           .toList(),
                                       onChanged: (v) => setState(() => _selectedStudyYear = v),
                                     ),
                                     verticalSpace(16),
                                     // Governorate Dropdown
                                     DropdownButtonFormField<String>(
                                       value: _selectedGovernorate,
                                       decoration: InputDecoration(
                                         labelText: 'اختر المحافظة',
                                         border: OutlineInputBorder(
                                           borderRadius: BorderRadius.circular(8),
                                         ),
                                       ),
                                       items: _governorates
                                           .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                                           .toList(),
                                       onChanged: (v) => setState(() => _selectedGovernorate = v),
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
                                               ? const Center(
                                               child: CircularProgressIndicator())
                                               : AppTextButton(
                                             buttonText: 'إنشاء حساب',
                                             textStyle: TextStyles.font16WhiteMedium,
                                             onPressed: () {
                                               if (firstNameController.text
                                                   .trim()
                                                   .isEmpty) {
                                                 ScaffoldMessenger
                                                     .of(context)
                                                     .showSnackBar(
                                                   const SnackBar(
                                                     content: Text(
                                                         'الرجاء إدخال الاسم الأول'),
                                                     backgroundColor: Colors.red,
                                                   ),
                                                 );
                                                 return;
                                               }

                                               if (lastNameController.text
                                                   .trim()
                                                   .isEmpty) {
                                                 ScaffoldMessenger
                                                     .of(context)
                                                     .showSnackBar(
                                                   const SnackBar(
                                                     content: Text(
                                                         'الرجاء إدخال الاسم الأخير'),
                                                     backgroundColor: Colors.red,
                                                   ),
                                                 );
                                                 return;
                                               }

                                               // Validate email
                                               if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$')
                                                   .hasMatch(
                                                   emailController.text.trim())) {
                                                 ScaffoldMessenger
                                                     .of(context)
                                                     .showSnackBar(
                                                   const SnackBar(
                                                     content: Text(
                                                         'الرجاء إدخال بريد إلكتروني صالح'),
                                                     backgroundColor: Colors.red,
                                                   ),
                                                 );
                                                 return;
                                               }

                                               // Validate password length
                                               if (passwordController.text.length <
                                                   6) {
                                                 ScaffoldMessenger
                                                     .of(context)
                                                     .showSnackBar(
                                                   const SnackBar(
                                                     content: Text(
                                                         'يجب أن تكون كلمة المرور 6 أحرف على الأقل'),
                                                     backgroundColor: Colors.red,
                                                   ),
                                                 );
                                                 return;
                                               }

                                               if (passwordController.text !=
                                                   confirmPasswordController.text) {
                                                 ScaffoldMessenger
                                                     .of(context)
                                                     .showSnackBar(
                                                   const SnackBar(
                                                     content: Text(
                                                         'كلمتا المرور غير متطابقتين'),
                                                     backgroundColor: Colors.red,
                                                   ),
                                                 );
                                                 return;
                                               }

                                               final phone = emailController.text.trim();

                                               // If all validations pass, proceed with sign up
                                               context.read<SignUpCubit>().signUp(
                                                 email: emailController.text.trim(),
                                                 password: passwordController.text,

                                                 firstName: firstNameController.text.trim(),
                                                 lastName: lastNameController.text.trim(),
                                                 phone: phone,
                                                 college: _selectedCollege,
                                                 studyYear: _selectedStudyYear,
                                                 governorate: _selectedGovernorate,
                                               );
                                             },
                                           ),
                                         );
                                       },
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
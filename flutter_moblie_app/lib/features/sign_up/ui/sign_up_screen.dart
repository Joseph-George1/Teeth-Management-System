import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/core/helpers/spacing.dart';
import 'package:thotha_mobile_app/core/theming/colors.dart';
import 'package:thotha_mobile_app/core/theming/styles.dart';
import 'package:thotha_mobile_app/core/widgets/app_text_button.dart';
import 'package:thotha_mobile_app/core/routing/routes.dart';
import 'package:thotha_mobile_app/features/sign_up/logic/sign_up_cubit.dart';
import 'package:thotha_mobile_app/core/networking/api_service.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/core/networking/models/university_model.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/helpers/app_regex.dart';
import 'package:thotha_mobile_app/features/login/ui/widgets/password_validations.dart';

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
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final String _userType = 'طالب'; // Default user type

  String? _selectedCollege;
  String? _selectedStudyYear;
  String? _selectedGovernorate;
  String? _selectedCategory;

  final _formKey = GlobalKey<FormState>();
  bool hasLowerCase = false;
  bool hasUpperCase = false;
  bool hasSpecialCharacters = false;
  bool hasNumber = false;
  bool hasMinLength = false;

  // Dynamic data from API
  final ApiService _apiService = ApiService();
  List<CityModel> _cities = [];
  List<UniversityModel> _universities = [];
  List<CategoryModel> _categories = [];

  // Loading states
  bool _isLoadingCities = false;
  bool _isLoadingUniversities = false;
  bool _isLoadingCategories = false;

  // Keep study years static (unlikely to change)
  final List<String> _studyYears = [
    'الفرقة الأولى',
    'الفرقة الثانية',
    'الفرقة الثالثة',
    'الفرقة الرابعة',
    'الفرقة الخامسة',
    'امتياز',
  ];

  String? selectedCountryCode = '+20';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch reference data from APIs
    _fetchReferenceData();
  }

  Future<void> _fetchReferenceData() async {
    // Fetch all data in parallel for better performance
    await Future.wait([
      _fetchCities(),
      _fetchUniversities(),
      _fetchCategories(),
    ]);
  }

  Future<void> _fetchCities() async {
    setState(() {
      _isLoadingCities = true;
    });

    final result = await _apiService.getCities();

    setState(() {
      _isLoadingCities = false;
      if (result['success']) {
        _cities = result['data'] as List<CityModel>;
      } else {
        // Show error but don't block UI
        print('Failed to load cities: ${result['error']}');
      }
    });
  }

  Future<void> _fetchUniversities() async {
    setState(() {
      _isLoadingUniversities = true;
    });

    final result = await _apiService.getUniversities();

    setState(() {
      _isLoadingUniversities = false;
      if (result['success']) {
        _universities = result['data'] as List<UniversityModel>;
      } else {
        print('Failed to load universities: ${result['error']}');
      }
    });
  }

  Future<void> _fetchCategories() async {
    setState(() {
      _isLoadingCategories = true;
    });

    final result = await _apiService.getCategories();

    setState(() {
      _isLoadingCategories = false;
      if (result['success']) {
        _categories = result['data'] as List<CategoryModel>;
      } else {
        print('Failed to load categories: ${result['error']}');
      }
    });
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
              } else if (state is SignUpOtpSent) {
                // Navigate to OTP verification screen
                Navigator.pushNamed(
                  context,
                  Routes.signupOtpVerificationScreen,
                  arguments: {
                    'phoneNumber': state.phoneNumber,
                    'email': state.email,
                  },
                );
                // Optionally show a snackbar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.blue,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
                              child: Form(
                                key: _formKey,
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
                                    Text(' إنشاء حساب',
                                        style: TextStyles.font24BlueBold),
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.person_outline),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال الاسم الأول';
                                        }
                                        return null;
                                      },
                                    ),
                                    verticalSpace(16),
                                    // Last Name Field
                                    TextFormField(
                                      controller: lastNameController,
                                      textInputAction: TextInputAction.next,
                                      decoration: InputDecoration(
                                        labelText: 'الاسم الأخير',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.person_outline),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال الاسم الأخير';
                                        }
                                        return null;
                                      },
                                    ),
                                    verticalSpace(16),
                                    // Email Field
                                    TextFormField(
                                      controller: emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        labelText: 'البريد الإلكتروني',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.email_outlined),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !AppRegex.isEmailValid(value)) {
                                          return 'الرجاء إدخال بريد إلكتروني صالح';
                                        }
                                        return null;
                                      },
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.phone_outlined),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.isEmpty ||
                                            !AppRegex.isPhoneNumberValid(
                                                value)) {
                                          return 'الرجاء إدخال رقم هاتف صالح';
                                        }
                                        return null;
                                      },
                                    ),
                                    verticalSpace(16),
                                    // University/College Dropdown
                                    _isLoadingUniversities
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            value: _selectedCollege,
                                            decoration: InputDecoration(
                                              labelText: 'اختر الكلية',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            items: _universities
                                                .map((u) => DropdownMenuItem(
                                                    value: u.name,
                                                    child: Text(u.name)))
                                                .toList(),
                                            onChanged: (v) => setState(
                                                () => _selectedCollege = v),
                                          ),
                                    verticalSpace(16),
                                    // Study Year Dropdown
                                    DropdownButtonFormField<String>(
                                      isExpanded: true,
                                      value: _selectedStudyYear,
                                      decoration: InputDecoration(
                                        labelText: 'السنة الدراسية',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      items: _studyYears
                                          .map((y) => DropdownMenuItem(
                                              value: y, child: Text(y)))
                                          .toList(),
                                      onChanged: (v) => setState(
                                          () => _selectedStudyYear = v),
                                    ),
                                    verticalSpace(16),
                                    // City/Governorate Dropdown
                                    _isLoadingCities
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            value: _selectedGovernorate,
                                            decoration: InputDecoration(
                                              labelText: 'اختر المحافظة',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            items: _cities
                                                .map((city) => DropdownMenuItem(
                                                    value: city.name,
                                                    child: Text(city.name)))
                                                .toList(),
                                            onChanged: (v) => setState(
                                                () => _selectedGovernorate = v),
                                          ),
                                    verticalSpace(16),
                                    // Category/Specialty Dropdown
                                    _isLoadingCategories
                                        ? const Center(
                                            child: CircularProgressIndicator())
                                        : DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            value: _selectedCategory,
                                            decoration: InputDecoration(
                                              labelText: 'اختر التخصص',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            items: _categories
                                                .map((cat) => DropdownMenuItem(
                                                    value: cat.name,
                                                    child: Text(cat.name)))
                                                .toList(),
                                            onChanged: (v) => setState(
                                                () => _selectedCategory = v),
                                          ),
                                    verticalSpace(16),
                                    // Password Field
                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: true,
                                      onChanged: (password) {
                                        setState(() {
                                          hasLowerCase =
                                              AppRegex.hasLowerCase(password);
                                          hasUpperCase =
                                              AppRegex.hasUpperCase(password);
                                          hasSpecialCharacters =
                                              AppRegex.hasSpecialCharacter(
                                                  password);
                                          hasNumber =
                                              AppRegex.hasNumber(password);
                                          hasMinLength =
                                              AppRegex.hasMinLength(password);
                                        });
                                      },
                                      decoration: InputDecoration(
                                        labelText: 'كلمة المرور',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال كلمة المرور';
                                        }
                                        return null;
                                      },
                                    ),
                                    verticalSpace(16),
                                    PasswordValidations(
                                      hasLowerCase: hasLowerCase,
                                      hasUpperCase: hasUpperCase,
                                      hasSpecialCharacters:
                                          hasSpecialCharacters,
                                      hasNumber: hasNumber,
                                      hasMinLength: hasMinLength,
                                    ),
                                    verticalSpace(16),
                                    // Confirm Password Field
                                    TextFormField(
                                      controller: confirmPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'تأكيد كلمة المرور',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء تأكيد كلمة المرور';
                                        }
                                        if (value != passwordController.text) {
                                          return 'كلمتا المرور غير متطابقتين';
                                        }
                                        return null;
                                      },
                                    ),
                                    verticalSpace(24),
                                    // Sign Up Button
                                    BlocBuilder<SignUpCubit, SignUpState>(
                                      builder: (context, state) {
                                        return SizedBox(
                                          width: double.infinity,
                                          child: state is SignUpLoading
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator())
                                              : AppTextButton(
                                                  buttonText: 'إنشاء حساب',
                                                  textStyle: TextStyles
                                                      .font16WhiteMedium,
                                                  onPressed: () {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      // Check if password criteria are met
                                                      if (!hasLowerCase ||
                                                          !hasUpperCase ||
                                                          !hasSpecialCharacters ||
                                                          !hasNumber ||
                                                          !hasMinLength) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'يرجى التأكد من استكمال جميع شروط كلمة المرور'),
                                                            backgroundColor:
                                                                Colors.red,
                                                          ),
                                                        );
                                                        return;
                                                      }

                                                      final phone =
                                                          phoneController.text
                                                              .trim();

                                                      // If all validations pass, proceed with sign up
                                                      context
                                                          .read<SignUpCubit>()
                                                          .signUp(
                                                            email:
                                                                emailController
                                                                    .text
                                                                    .trim(),
                                                            password:
                                                                passwordController
                                                                    .text,

                                                            firstName:
                                                                firstNameController
                                                                    .text
                                                                    .trim(),
                                                            lastName:
                                                                lastNameController
                                                                    .text
                                                                    .trim(),
                                                            phone: phone,
                                                            college:
                                                                _selectedCollege,
                                                            studyYear:
                                                                _selectedStudyYear,
                                                            governorate:
                                                                _selectedGovernorate,
                                                            category:
                                                                _selectedCategory, // Add this
                                                          );
                                                    }
                                                  },
                                                ),
                                        );
                                      },
                                    ),

                                    verticalSpace(24),
                                    // Already have an account? Login
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'لديك حساب بالفعل؟',
                                          style:
                                              TextStyles.font13DarkBlueMedium,
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushNamed(Routes.loginScreen);
                                          },
                                          child: Text(
                                            'تسجيل الدخول',
                                            style:
                                                TextStyles.font13BlueSemiBold,
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
                    ),
                  ],
                ),
              ),
            )));
  }
}

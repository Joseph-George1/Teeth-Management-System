import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoutha_mobile_app/core/helpers/app_regex.dart';
import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/core/networking/models/category_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/city_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/university_model.dart';
import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:thoutha_mobile_app/core/theming/colors.dart';
import 'package:thoutha_mobile_app/core/widgets/app_text_button.dart';
import 'package:thoutha_mobile_app/features/booking/ui/otp_verification_dialog.dart';
import 'package:thoutha_mobile_app/features/login/ui/widgets/password_validations.dart';
import 'package:thoutha_mobile_app/features/sign_up/logic/sign_up_cubit.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

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
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final ApiService _apiService = ApiService();
  List<CityModel> _cities = [];
  List<UniversityModel> _universities = [];
  List<CategoryModel> _categories = [];

  bool _isLoadingCities = false;
  bool _isLoadingUniversities = false;
  bool _isLoadingCategories = false;

  List<DropdownMenuItem<String>> _cityDropdownItems = [];
  List<DropdownMenuItem<String>> _uniDropdownItems = [];
  List<DropdownMenuItem<String>> _catDropdownItems = [];

  final List<String> _studyYears = [
    L10nSignUp.fourthBand.tr(),
    L10nSignUp.fifthDivision.tr(),
    L10nProfile.privilege.tr(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchReferenceData();
    });
  }
  
  Future<void> _fetchReferenceData() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCities = true;
      _isLoadingUniversities = true;
      _isLoadingCategories = true;
    });

    try {
      final results = await Future.wait([
        _apiService.getCities(),
        _apiService.getUniversities(),
        _apiService.getCategories(),
      ]);

      if (!mounted) return;

      setState(() {
        if (results[0]['success']) {
          _cities = results[0]['data'] as List<CityModel>;
          _cityDropdownItems = _cities
              .map((city) {
                final name = city.name;
                if (name.trim().isEmpty) return null;
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name, style: const TextStyle(fontFamily: 'Cairo')),
                );
              })
              .whereType<DropdownMenuItem<String>>()
              .toList();
        }
        if (results[1]['success']) {
          _universities = results[1]['data'] as List<UniversityModel>;
          _uniDropdownItems = _universities
              .map((u) {
                final name = u.name;
                if (name.trim().isEmpty) return null;
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name, style: const TextStyle(fontFamily: 'Cairo')),
                );
              })
              .whereType<DropdownMenuItem<String>>()
              .toList();
        }
        if (results[2]['success']) {
          _categories = results[2]['data'] as List<CategoryModel>;
          _catDropdownItems = _categories
              .map((cat) {
                final name = cat.name;
                if (name.trim().isEmpty) return null;
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name, style: const TextStyle(fontFamily: 'Cairo')),
                );
              })
              .whereType<DropdownMenuItem<String>>()
              .toList();
        }
        _isLoadingCities = false;
        _isLoadingUniversities = false;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCities = false;
          _isLoadingUniversities = false;
          _isLoadingCategories = false;
        });
      }
      debugPrint('Error fetching reference data: $e');
    }
  }

  Future<void> _fetchCities() async {
    // This is now integrated into _fetchReferenceData to avoid redundant setState calls
  }

  Future<void> _fetchUniversities() async {
    // This is now integrated into _fetchReferenceData to avoid redundant setState calls
  }

  Future<void> _fetchCategories() async {
    // This is now integrated into _fetchReferenceData to avoid redundant setState calls
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => SignUpCubit(),
      child: BlocListener<SignUpCubit, SignUpState>(
        listener: (context, state) {
          if (state is SignUpSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Future.delayed(Duration(seconds: 3), () {
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, Routes.loginScreen);
              }
            });
          } else if (state is SignUpOtpSent) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => OtpVerificationDialog(
                contactInfo: state.phoneNumber,
                onVerified: (pin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(L10nSignUp.phoneNumberVerifiedSuccessfully.tr()),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pushReplacementNamed(context, Routes.loginScreen);
                },
              ),
            );
          } else if (state is SignUpError) {
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
                        center: Alignment(-0.8, -0.5),
                        radius: 1.2,
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
                        center: Alignment(0.8, 0.5),
                        radius: 1.2,
                        colors: [
                          isDarkMode
                              ? ColorsManager.layerBlur2.withAlpha(50)
                              : ColorsManager.layerBlur2.withAlpha(102),
                          isDarkMode
                              ? ColorsManager.layerBlur2.withAlpha(20)
                              : ColorsManager.layerBlur2.withAlpha(25),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.3, 0.8],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 24,
                              ),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(
                                    maxWidth: MediaQuery.of(context).size.width >= 600 ? 500 : double.infinity,
                                  ),
                                  padding: EdgeInsets.all(24),
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
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(height: 16),
                                          Image.asset(
                                            'assets/images/splash-logo.png',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.contain,
                                          ),
                                          Text(
                                            L10nLogin.createAnAccount1.tr(),
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : ColorsManager.mainBlue,
                                              fontFamily: 'Cairo',
                                            ),
                                          ),
                                          Text(
                                            L10nSignUp.createYourAccountTo.tr(),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isDarkMode
                                                  ? Colors.white70
                                                  : Colors.grey,
                                              fontFamily: 'Cairo',
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          SizedBox(height: 16),
                                          // First Name Field
                                          TextFormField(
                                            controller: firstNameController,
                                            textInputAction: TextInputAction.next,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[\u0621-\u064A\s]'),
                                              ),
                                            ],
                                            decoration: InputDecoration(
                                              labelText: L10nBooking.firstName.tr(),
                                              helperText: L10nSignUp.enterTheNameIn.tr(),
                                              prefixIcon:
                                                  Icon(Icons.person_outline),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return L10nBooking.pleaseEnterFirstName.tr();
                                              }
                                              if (!AppRegex.isArabicName(value.trim())) {
                                                return L10nSignUp.theFirstNameMust.tr();
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          // Last Name Field
                                          TextFormField(
                                            controller: lastNameController,
                                            textInputAction: TextInputAction.next,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                RegExp(r'[\u0621-\u064A\s]'),
                                              ),
                                            ],
                                            decoration: InputDecoration(
                                              labelText: L10nSignUp.lastName.tr(),
                                              helperText: L10nSignUp.enterTheNameIn.tr(),
                                              prefixIcon:
                                                  Icon(Icons.person_outline),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.trim().isEmpty) {
                                                return L10nSignUp.pleaseEnterLastName.tr();
                                              }
                                              if (!AppRegex.isArabicName(value.trim())) {
                                                return L10nSignUp.theLastNameMust.tr();
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          // Email Field
                                          TextFormField(
                                            controller: emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            decoration: InputDecoration(
                                              labelText: L10nDoctor.email.tr(),
                                              prefixIcon:
                                                  Icon(Icons.email_outlined),
                                              helperText: L10nSignUp.mustEndWithUniversityEduEg.tr(),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  !AppRegex.isEmailValid(value)) {
                                                return L10nLogin.pleaseEnterAValid.tr();
                                              }
                                              if (!value.endsWith('.edu.eg')) {
                                                return L10nSignUp.emailMustEndWith.tr();
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          // Phone Number Field
                                          TextFormField(
                                            controller: phoneController,
                                            keyboardType: TextInputType.phone,
                                            decoration: InputDecoration(
                                              labelText: L10nDoctor.phoneNumber.tr(),
                                              prefixIcon:
                                                  Icon(Icons.phone_outlined),
                                            ),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty ||
                                                  !AppRegex.isPhoneNumberValid(
                                                      value)) {
                                                return L10nSignUp.pleaseEnterAValid.tr();
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          // University/College Dropdown
                                          _isLoadingUniversities
                                              ? Center(
                                                  key: ValueKey('uni_loading'),
                                                  child:
                                                      CircularProgressIndicator())
                                              : DropdownButtonFormField<String>(
                                                  key: ValueKey(
                                                      'uni_dropdown'),
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                    labelText: L10nSignUp.chooseCollege.tr(),
                                                  ),
                                                  items: _uniDropdownItems,
                                                  onChanged: (v) => setState(
                                                      () => _selectedCollege = v),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return L10nSignUp.pleaseSelectACollege.tr();
                                                    }
                                                    return null;
                                                  },
                                                ),
                                          SizedBox(height: 16),
                                          // Study Year Dropdown
                                          DropdownButtonFormField<String>(
                                            isExpanded: true,
                                            decoration: InputDecoration(
                                              labelText: L10nProfile.academicYear.tr(),
                                            ),
                                            items: _studyYears
                                                .map((y) => DropdownMenuItem(
                                                    value: y, child: Text(y)))
                                                .toList(),
                                            onChanged: (v) => setState(
                                                () => _selectedStudyYear = v),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return L10nSignUp.pleaseSelectTheAcademic.tr();
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          // City/Governorate Dropdown
                                          _isLoadingCities
                                              ? Center(
                                                  key: ValueKey('city_loading'),
                                                  child:
                                                      CircularProgressIndicator())
                                              : DropdownButtonFormField<String>(
                                                  key: ValueKey(
                                                      'city_dropdown'),
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                    labelText: L10nDoctor.selectTheGovernorate.tr(),
                                                    helperText: L10nSignUp.selectTheGovernorateTo.tr(),
                                                  ),
                                                  items: _cityDropdownItems,
                                                  onChanged: (v) => setState(() =>
                                                      _selectedGovernorate = v),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return L10nSignUp.pleaseSelectAGovernorate.tr();
                                                    }
                                                    return null;
                                                  },
                                                ),
                                          SizedBox(height: 16),
                                          // Category/Specialty Dropdown
                                          _isLoadingCategories
                                              ? Center(
                                                  key: ValueKey('cat_loading'),
                                                  child:
                                                      CircularProgressIndicator())
                                              : DropdownButtonFormField<String>(
                                                  key: ValueKey(
                                                      'cat_dropdown'),
                                                  isExpanded: true,
                                                  decoration: InputDecoration(
                                                    labelText: L10nProfile.chooseYourSpecialty.tr(),
                                                  ),
                                                  items: _catDropdownItems,
                                                  onChanged: (v) => setState(
                                                      () => _selectedCategory = v),
                                                  validator: (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return L10nSignUp.pleaseChooseASpecialty.tr();
                                                    }
                                                    return null;
                                                  },
                                                ),
                                          SizedBox(height: 16),
                                          // Password Field
                                          TextFormField(
                                            controller: passwordController,
                                            obscureText: _obscurePassword,
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
                                              labelText: L10nLogin.password.tr(),
                                              prefixIcon:
                                                  Icon(Icons.lock_outline),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscurePassword =
                                                        !_obscurePassword;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return L10nLogin.pleaseEnterYourPassword.tr();
                                              }
                                              return null;
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          // Confirm Password Field
                                          TextFormField(
                                            controller: confirmPasswordController,
                                            obscureText: _obscureConfirmPassword,
                                            decoration: InputDecoration(
                                              labelText: L10nResetPassword.confirmPassword.tr(),
                                              prefixIcon:
                                                  Icon(Icons.lock_outline),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    _obscureConfirmPassword =
                                                        !_obscureConfirmPassword;
                                                  });
                                                },
                                              ),
                                            ),
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return L10nResetPassword.pleaseConfirmYourPassword.tr();
                                              }
                                              if (value !=
                                                  passwordController.text) {
                                                return L10nSignUp.passwordsDoNotMatch.tr();
                                              }
                                              return null;
                                            },
                                          ),

                                          SizedBox(height: 16),
                                          PasswordValidations(
                                            hasLowerCase: hasLowerCase,
                                            hasUpperCase: hasUpperCase,
                                            hasSpecialCharacters:
                                                hasSpecialCharacters,
                                            hasNumber: hasNumber,
                                            hasMinLength: hasMinLength,
                                          ),
                                          SizedBox(height: 24),
                                          // Sign Up Button
                                          BlocBuilder<SignUpCubit, SignUpState>(
                                            builder: (context, state) {
                                              return SizedBox(
                                                width: double.infinity,
                                                height: 52,
                                                child: state is SignUpLoading
                                                    ? Center(
                                                        child:
                                                            CircularProgressIndicator())
                                                    : AppTextButton(
                                                        buttonText: L10nLogin.createAnAccount.tr(),
                                                        textStyle: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: 'Cairo',
                                                        ),
                                                        onPressed: () {
                                                          if (_formKey.currentState!
                                                              .validate()) {
                                                            if (!hasLowerCase ||
                                                                !hasUpperCase ||
                                                                !hasSpecialCharacters ||
                                                                !hasNumber ||
                                                                !hasMinLength) {
                                                              ScaffoldMessenger.of(
                                                                      context)
                                                                  .showSnackBar(
                                                                SnackBar(
                                                                  content: Text(
                                                                      L10nSignUp.pleaseEnsureYouComplete.tr()),
                                                                  backgroundColor:
                                                                      Colors.red,
                                                                ),
                                                              );
                                                              return;
                                                            }

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
                                                                  confirmPassword:
                                                                      confirmPasswordController
                                                                          .text,
                                                                  firstName:
                                                                      firstNameController
                                                                          .text
                                                                          .trim(),
                                                                  lastName:
                                                                      lastNameController
                                                                          .text
                                                                          .trim(),
                                                                  phone:
                                                                      phoneController
                                                                          .text
                                                                          .trim(),
                                                                  college:
                                                                      _selectedCollege,
                                                                  studyYear:
                                                                      _selectedStudyYear,
                                                                  governorate:
                                                                      _selectedGovernorate,
                                                                  category:
                                                                      _selectedCategory,
                                                                );
                                                          }
                                                        },
                                                      ),
                                              );
                                            },
                                          ),
                                          SizedBox(height: 16),
                                          Wrap(
                                            alignment: WrapAlignment.center,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                L10nSignUp.alreadyHaveAnAccount.tr(),
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: isDarkMode
                                                      ? Colors.white
                                                      : ColorsManager.darkBlue,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'Cairo',
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pushNamed(
                                                      Routes.loginScreen);
                                                },
                                                child: Text(
                                                  L10nHomeScreen.login.tr(),
                                                  style: TextStyle(
                                                    fontSize: 13,
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
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

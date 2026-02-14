import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:thotha_mobile_app/core/helpers/constants.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thotha_mobile_app/core/helpers/spacing.dart';
import 'package:thotha_mobile_app/core/routing/routes.dart';
import 'package:thotha_mobile_app/core/theming/colors.dart';
import 'package:thotha_mobile_app/core/theming/styles.dart';
import 'package:thotha_mobile_app/core/widgets/app_text_button.dart';
import 'package:thotha_mobile_app/core/di/dependency_injection.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/case_request_body.dart';
import 'package:thotha_mobile_app/features/home_screen/data/repositories/case_request_repo.dart';
import 'package:thotha_mobile_app/features/home_screen/data/repositories/doctor_repository.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';

class AddCaseRequestScreen extends StatefulWidget {
  const AddCaseRequestScreen({super.key});

  @override
  State<AddCaseRequestScreen> createState() => _AddCaseRequestScreenState();
}

class _AddCaseRequestScreenState extends State<AddCaseRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  int? _selectedCityId;
  List<CityModel> _cities = [];
  List<CategoryModel> _categoriesList = [];
  bool _isLoadingData = false;

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Removed hardcoded _categories list

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoadingData = true;
    });
    try {
      final repo = getIt<DoctorRepository>();
      final citiesFuture = repo.getCities();
      final categoriesFuture = repo.getCategories();
      
      final results = await Future.wait([citiesFuture, categoriesFuture]);
      
      if (mounted) {
        setState(() {
          _cities = results[0] as List<CityModel>;
          _categoriesList = results[1] as List<CategoryModel>;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingData = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحميل البيانات')),
        );
      }
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      locale: const Locale('ar', 'EG'),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Localizations.override(
          context: context,
          locale: const Locale('ar', 'EG'),
          child: child,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  void _publishRequest() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if user is logged in
    final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
    
    if (token.isEmpty ) {
      _showLoginDialog();
    } else {
      // Proceed with publishing
      try {
        // Show loading
        if (mounted) {
           showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );
        }

        final selectedCityName = _cities
            .firstWhere((c) => c.id == _selectedCityId,
                orElse: () => CityModel(id: -1, name: ''))
            .name;

        final body = CaseRequestBody(
          specialization: _selectedCategory!,
          date: _dateController.text,
          time: _timeController.text,
          location: selectedCityName,
          description: 'No details', // Description is not in UI, defaulting
        );

        final repo = getIt<CaseRequestRepo>();
        final result = await repo.createCaseRequest(body);

        // Hide loading
        if (mounted) Navigator.pop(context);

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم نشر الطلب بنجاح!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
           if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['error'] ?? 'فشل في نشر الطلب'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) Navigator.pop(context); // Hide loading
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('حدث خطأ غير متوقع'),
                backgroundColor: Colors.red,
              ),
            );
          }
      }
    }
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: ui.TextDirection.rtl,
          child: AlertDialog(
            title: Text('تسجيل الدخول مطلوب', style: TextStyles.font18DarkBlueBold),
            content: Text(
              'يجب عليك تسجيل الدخول أولاً لتتمكن من نشر طلب حالة.',
              style: TextStyles.font14GrayRegular,
            ),
            actions: [
              TextButton(
                child: Text('إلغاء', style: TextStyles.font14GrayRegular),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('تسجيل الدخول', style: TextStyles.font14BlueSemiBold),
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  // Navigate to login screen
                  Navigator.of(context).pushNamed(Routes.loginScreen);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إضافة طلب حالة',
          style: TextStyles.font18DarkBlueBold,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorsManager.darkBlue),
      ),
      backgroundColor: ColorsManager.offWhite,
      body: SafeArea(
        child: Directionality(
          textDirection: ui.TextDirection.rtl,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'بيانات الحالة',
                    style: TextStyles.font18DarkBlueBold,
                  ),
                  verticalSpace(8),
                  Text(
                    'قم بملء البيانات التالية لنشر طلب حالة جديد',
                    style: TextStyles.font14GrayRegular,
                  ),
                  verticalSpace(32),

                  // Specialization
                  _buildLabel('التخصص'),
                  verticalSpace(8),
                  _isLoadingData
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: _buildInputDecoration(
                            hint: 'اختر التخصص',
                            prefixIcon: Icons.medical_services_outlined,
                          ),
                          items: _categoriesList
                              .map((c) => DropdownMenuItem(
                                  value: c.name, child: Text(c.name)))
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v),
                          validator: (value) =>
                              value == null ? 'يرجى اختيار التخصص' : null,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: ColorsManager.gray),
                        ),
                  verticalSpace(16),

                  // Date
                  _buildLabel('التاريخ المتاح'),
                  verticalSpace(8),
                  TextFormField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _buildInputDecoration(
                      hint: 'يوم / شهر / سنة',
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى اختيار التاريخ' : null,
                  ),
                  verticalSpace(16),

                  // Time
                  _buildLabel('الوقت المتاح'),
                  verticalSpace(8),
                  TextFormField(
                    controller: _timeController,
                    readOnly: true,
                    onTap: () => _selectTime(context),
                    decoration: _buildInputDecoration(
                      hint: '00:00',
                      prefixIcon: Icons.access_time_outlined,
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى اختيار الوقت' : null,
                  ),
                  verticalSpace(16),

                  // Location / City
                  _buildLabel('المكان / المدينة'),
                  verticalSpace(8),
                  _isLoadingData
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<int>(
                          value: _selectedCityId,
                          decoration: _buildInputDecoration(
                            hint: 'اختر المدينة',
                            prefixIcon: Icons.location_on_outlined,
                          ),
                          items: _cities
                              .map((c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(c.name),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedCityId = v),
                          validator: (value) =>
                              value == null ? 'يرجى اختيار المدينة' : null,
                          icon: const Icon(Icons.keyboard_arrow_down,
                              color: ColorsManager.gray),
                        ),
                  verticalSpace(40),

                  // Publish Button
                  AppTextButton(
                    buttonText: 'نشر الطلب',
                    textStyle: TextStyles.font16WhiteSemiBold,
                    backgroundColor: ColorsManager.mainBlue,
                    onPressed: _publishRequest,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorsManager.mainBlue, width: 1.3),
        borderRadius: BorderRadius.circular(16.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: ColorsManager.lighterGray, width: 1.3),
        borderRadius: BorderRadius.circular(16.0),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
        borderRadius: BorderRadius.circular(16.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red, width: 1.3),
        borderRadius: BorderRadius.circular(16.0),
      ),
      hintStyle: TextStyles.font14LightGrayRegular,
      hintText: hint,
      prefixIcon: Icon(
        prefixIcon,
        color: ColorsManager.mainBlue,
        size: 22.sp,
      ),
      fillColor: ColorsManager.moreLighterGray,
      filled: true,
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyles.font14DarkBlueMedium,
    );
  }
}

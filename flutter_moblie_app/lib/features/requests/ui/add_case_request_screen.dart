import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:thoutha_mobile_app/core/theming/colors.dart';
import 'package:thoutha_mobile_app/core/theming/styles.dart';
import 'package:thoutha_mobile_app/core/widgets/app_text_button.dart';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/features/requests/data/models/case_request_body.dart';
import 'package:thoutha_mobile_app/features/requests/data/models/case_request_model.dart';
import 'package:thoutha_mobile_app/features/requests/data/repos/case_request_repo.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:showcaseview/showcaseview.dart';
import 'package:thoutha_mobile_app/tour/tour_config.dart';
import 'package:thoutha_mobile_app/tour/tour_service.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class AddCaseRequestScreen extends StatefulWidget {
  final String? initialSpecialization;
  final CaseRequestModel? requestToEdit;
  const AddCaseRequestScreen({
    super.key,
    this.initialSpecialization,
    this.requestToEdit,
  });

  @override
  State<AddCaseRequestScreen> createState() => _AddCaseRequestScreenState();
}

class _AddCaseRequestScreenState extends State<AddCaseRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();

  // Doctor info loaded from SharedPreferences
  String _firstName = '';
  String _lastName = '';
  String _category = '';
  bool _isLoadingInfo = true;
  bool _isTourStarted = false;

  // Selected date & time
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // Edit mode flag
  bool get _isEditMode => widget.requestToEdit != null;

  @override
  void initState() {
    super.initState();
    _loadDoctorInfo();
    if (_isEditMode) {
      _prefillFormForEditing();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  /// If editing, pre-fill the form with the request's data
  void _prefillFormForEditing() {
    final req = widget.requestToEdit;
    if (req != null) {
      _descriptionController.text = req.description;
      try {
        final dt = DateTime.parse(req.dateTime);
        _selectedDate = DateTime(dt.year, dt.month, dt.day);
        _selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
      } catch (_) {
        // If parsing fails, keep dates as null
      }
    }
  }

  Future<void> _loadDoctorInfo() async {
    final firstName = await SharedPrefHelper.getString('first_name') ?? '';
    final lastName = await SharedPrefHelper.getString('last_name') ?? '';
    final category = await SharedPrefHelper.getString('category') ?? '';

    if (mounted) {
      setState(() {
        _firstName = firstName;
        _lastName = lastName;
        // Prioritize widget.initialSpecialization to show what they are about to post
        _category = widget.initialSpecialization ?? category;
        _isLoadingInfo = false;
      });
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String get _formattedDate => _selectedDate != null
      ? DateFormat('yyyy-MM-dd', 'en').format(_selectedDate!)
      : '';

  String get _formattedTime {
    if (_selectedTime == null) return '';
    final hour = _selectedTime!.hourOfPeriod == 0 ? 12 : _selectedTime!.hourOfPeriod;
    final minute = _selectedTime!.minute.toString().padLeft(2, '0');
    final period = _selectedTime!.period == DayPeriod.am ? L10nDoctor.am.tr() : L10nDoctor.evening.tr();
    return '$hour:$minute $period';
  }

  /// 24-hour format for API submission
  String get _formattedTime24 => _selectedTime != null
      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
      : '';

  /// Builds "2026-03-10T15:30:00" format correctly regardless of Locale
  String get _dateTimeIso {
    if (_selectedDate == null || _selectedTime == null) return '';
    final d = _selectedDate!;
    final isoDate = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return '${isoDate}T$_formattedTime24:00';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
      locale: Locale('ar', 'EG'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: ColorsManager.mainBlue,
                    onPrimary: Colors.white,
                    surface: Color(0xFF2D2D2D),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: ColorsManager.mainBlue,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: ColorsManager.mainBlue,
                    onPrimary: Colors.white,
                    surface: Color(0xFF2D2D2D),
                    onSurface: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: ColorsManager.mainBlue,
                    onPrimary: Colors.white,
                    surface: Colors.white,
                    onSurface: Colors.black,
                  ),
            timePickerTheme: TimePickerThemeData(
              helpTextStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              hourMinuteTextStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
              dayPeriodTextStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                textStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: Directionality(
              textDirection: ui.TextDirection.rtl,
              child: child!,
            ),
          ),
        );
      },
    );
    if (picked != null) {
      // If selected date is today, don't allow a time before now
      final now = DateTime.now();
      final isToday = _selectedDate != null &&
          _selectedDate!.year == now.year &&
          _selectedDate!.month == now.month &&
          _selectedDate!.day == now.day;

      if (isToday) {
        final pickedMinutes = picked.hour * 60 + picked.minute;
        final nowMinutes = now.hour * 60 + now.minute;

        if (pickedMinutes <= nowMinutes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  L10nRequests.youCannotChooseA.tr(),
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          return;
        }
      }

      setState(() => _selectedTime = picked);
    }
  }

  // ── Publish ───────────────────────────────────────────────────────────────

  Future<void> _publishRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10nRequests.pleaseSelectADate.tr(),
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
    if (token.isEmpty) {
      _showLoginDialog();
      return;
    }

    try {
      if (mounted)  {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => Center(child: CircularProgressIndicator()),
        );
      }

      // 1. Update Doctor Specialty on Server
      final firstName = await SharedPrefHelper.getString('first_name');
      final lastName = await SharedPrefHelper.getString('last_name');
      final phone = await SharedPrefHelper.getString('phone');
      final faculty = await SharedPrefHelper.getString('faculty');
      final yearString = await SharedPrefHelper.getString('year');
      final governorate = await SharedPrefHelper.getString('governorate');
      final dynamic studyYear = int.tryParse(yearString) ?? (yearString.isNotEmpty ? yearString : null);

      final updateBody = <String, dynamic>{
        if (firstName.isNotEmpty) 'firstName': firstName,
        if (lastName.isNotEmpty) 'lastName': lastName,
        if (phone.isNotEmpty) 'phoneNumber': phone,
        if (studyYear != null) 'studyYear': studyYear,
        if (faculty.isNotEmpty) 'universityName': faculty,
        if (governorate.isNotEmpty) 'cityName': governorate,
        'categoryName': _category,
      };

      final apiService = getIt<ApiService>();
      await apiService.updateDoctor(updateBody);
      await SharedPrefHelper.setData('category', _category);

      // 2. Publish Case Request
      final body = CaseRequestBody(
        description: _descriptionController.text.trim().isEmpty
            ? L10nRequests.thereAreNoAdditional.tr()
            : _descriptionController.text.trim(),
        dateTime: _dateTimeIso,
      );

      final repo = getIt<CaseRequestRepo>();
      final result = _isEditMode
          ? await repo.updateCaseRequest(widget.requestToEdit!.id ?? 0, body)
          : await repo.createCaseRequest(body);

      if (!mounted) return;
      Navigator.pop(context);

      if (result['success'] == true) {
        if (!mounted) return;
        final message =
            _isEditMode ? L10nRequests.theRequestHasBeen.tr() : L10nRequests.theRequestHasBeen1.tr();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(message, style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? L10nRequests.failedToProcessThe.tr(),
                style: TextStyle(fontFamily: 'Cairo')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(L10nBooking.anUnexpectedErrorOccurred.tr(),
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          title:
              Text(L10nRequests.loginRequired.tr(), style: TextStyles.font18DarkBlueBold),
          content: Text(
            L10nRequests.youMustLogIn.tr(),
            style: TextStyles.font14GrayRegular,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(L10nBooking.cancellation.tr(), style: TextStyles.font14GrayRegular),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushNamed(Routes.loginScreen);
              },
              child: Text(L10nHomeScreen.login.tr(), style: TextStyles.font14BlueSemiBold),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ShowCaseWidget(
      onComplete: (index, key) {
        TourService.onDismiss(key)();
      },
      builder: (context) {
        if (!_isTourStarted) {
          _isTourStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) TourService.startTourForScreen(context, 'add_case');
          });
        }
        return Scaffold(
          appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash-logo.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 8),
            Text(
              _isEditMode ? L10nRequests.modifyTheRequest.tr() : L10nRequests.addACaseRequest.tr(),
              style: TextStyles.font18DarkBlueBold.copyWith(
                fontFamily: 'Cairo',
                fontSize: 18,
                color: isDark ? Colors.white : null,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: isDark ? Color(0xFF2D2D2D) : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : ColorsManager.darkBlue,
          size: 24,
        ),
      ),
      backgroundColor:
          isDark ? Color(0xFF1E1E1E) : ColorsManager.offWhite,
      body: SafeArea(
        child: Directionality(
          textDirection: context.locale.languageCode == 'ar'
              ? ui.TextDirection.rtl
              : ui.TextDirection.ltr,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ────────────────────────────────────────
                      Text(
                        L10nRequests.caseData.tr(),
                        style: TextStyles.font18DarkBlueBold.copyWith(
                          fontFamily: 'Cairo',
                          fontSize: 18,
                          color: isDark ? Colors.white : null,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        L10nRequests.fillOutTheFollowing.tr(),
                        style: TextStyles.font14GrayRegular.copyWith(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : null,
                        ),
                      ),
                      SizedBox(height: 24),

                      // ── Doctor Info Card (auto-filled) ────────────────
                      Showcase(
                        key: TourConfig.addCaseInfoKey,
                        title: 'بياناتك الشخصية',
                        description: 'يتم ملء اسمك وتخصصك تلقائياً من ملفك الشخصي',
                        child: _buildInfoCard(isDark),
                      ),
                      SizedBox(height: 24),

                      // ── DateTime picker ───────────────────────────────
                      _buildLabel(L10nRequests.dateAndTime.tr(), isDark),
                      SizedBox(height: 8),
                      Showcase(
                        key: TourConfig.addCaseDateTimeKey,
                        title: 'تحديد الموعد',
                        description: 'اختر التاريخ والوقت المناسبين لاستقبال الحالة',
                        child: _buildDateTimePicker(isDark),
                      ),
                      SizedBox(height: 20),

                      // ── Description ───────────────────────────────────
                      _buildLabel(L10nRequests.caseDescriptionOptional.tr(), isDark),
                      SizedBox(height: 8),
                      Showcase(
                        key: TourConfig.addCaseDescriptionKey,
                        title: 'وصف الحالة',
                        description: 'أضف أي تفاصيل إضافية تساعد المريض على فهم الحالة',
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          maxLength: 500,
                          textDirection: ui.TextDirection.rtl,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 14,
                          ),
                          decoration: _buildDecoration(
                            hint: L10nRequests.addADetailedDescription.tr(),
                            icon: Icons.description_outlined,
                            isDark: isDark,
                          ),
                        ),
                      ),
                      SizedBox(height: 32),

                      // ── Publish Button ────────────────────────────────
                      Showcase(
                        key: TourConfig.addCaseSubmitKey,
                        title: 'نشر الطلب',
                        description: 'اضغط هنا ليتم نشر الحالة وتظهر للمرضى في التطبيق',
                        child: AppTextButton(
                          buttonText: _isEditMode ? L10nRequests.updateTheRequest.tr() : L10nRequests.postTheRequest.tr(),
                          textStyle: TextStyles.font16WhiteSemiBold.copyWith(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            color: isDark ? Colors.black : Colors.white,
                          ),
                          backgroundColor: ColorsManager.mainBlue,
                          onPressed: _publishRequest,
                        ),
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
    );
  }

  // ── Doctor Info Card ──────────────────────────────────────────────────────

  Widget _buildInfoCard(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: _isLoadingInfo
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: L10nRequests.theName.tr(),
                  value: '$_firstName $_lastName',
                  isDark: isDark,
                ),
                SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.medical_services_outlined,
                  label: L10nDoctor.specialization.tr(),
                  value: _category.isNotEmpty ? _category : L10nDoctor.undefined.tr(),
                  isDark: isDark,
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isDark ? Colors.grey[400] : ColorsManager.mainBlue,
          size: 20,
        ),
        SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ── DateTime Picker ───────────────────────────────────────────────────────

  Widget _buildDateTimePicker(bool isDark) {
    final hasDate = _selectedDate != null;
    final hasTime = _selectedTime != null;

    return Row(
      children: [
        // Date
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Color(0xFF2D2D2D)
                    : ColorsManager.moreLighterGray,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark ? Colors.grey.shade700 : ColorsManager.lighterGray,
                  width: 1.3,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: isDark ? Colors.grey[400] : ColorsManager.mainBlue,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasDate ? _formattedDate : L10nDoctor.theDate.tr(),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: hasDate
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        // Time
        Expanded(
          child: GestureDetector(
            onTap: _pickTime,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? Color(0xFF2D2D2D)
                    : ColorsManager.moreLighterGray,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isDark ? Colors.grey.shade700 : ColorsManager.lighterGray,
                  width: 1.3,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_outlined,
                    size: 18,
                    color: isDark ? Colors.grey[400] : ColorsManager.mainBlue,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasTime ? _formattedTime : L10nDoctor.theTime.tr(),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13,
                        color: hasTime
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyles.font14DarkBlueMedium.copyWith(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: isDark ? Colors.white : null,
      ),
    );
  }

  InputDecoration _buildDecoration({
    required String hint,
    required IconData icon,
    required bool isDark,
  }) {
    return InputDecoration(
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 14,
        color: isDark ? Colors.grey[500] : Colors.grey[400],
      ),
      prefixIcon: Icon(
        icon,
        color: isDark ? Colors.grey[400] : ColorsManager.mainBlue,
        size: 22,
      ),
      fillColor:
          isDark ? Color(0xFF2D2D2D) : ColorsManager.moreLighterGray,
      filled: true,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: isDark ? Colors.grey.shade700 : ColorsManager.lighterGray,
          width: 1.3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorsManager.mainBlue, width: 1.3),
        borderRadius: BorderRadius.circular(16),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.3),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red, width: 1.3),
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

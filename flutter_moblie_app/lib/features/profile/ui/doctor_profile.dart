import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/core/networking/models/category_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/city_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/university_model.dart';
import 'package:thoutha_mobile_app/features/doctor/ui/account_deletion_screen.dart';
import 'package:thoutha_mobile_app/features/forgot_password/ui/change_password_screen.dart';
import 'package:thoutha_mobile_app/features/profile/data/models/doctor_profile_model.dart';
import 'package:thoutha_mobile_app/features/profile/logic/profile_cubit.dart';
import 'package:thoutha_mobile_app/features/profile/logic/profile_state.dart';
import 'package:thoutha_mobile_app/features/requests/ui/my_requests_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/drawer_doctor/doctor_drawer_screen.dart';
import 'package:thoutha_mobile_app/core/helpers/phone_helper.dart';
import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';


class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<ProfileCubit>()..fetchProfile(),
      child: DoctorProfileBody(),
    );
  }
}

class DoctorProfileBody extends StatefulWidget {
  const DoctorProfileBody({super.key});

  @override
  State<DoctorProfileBody> createState() => _DoctorProfileBodyState();
}

class _DoctorProfileBodyState extends State<DoctorProfileBody> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _universityCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late final FocusNode _firstNameFocusNode;
  late final FocusNode _lastNameFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _phoneFocusNode;

  // Original values — set once when profile loads
  String _origFirstName = '';
  String _origLastName = '';
  String _origEmail = '';
  String _origUniversity = '';
  String _origYear = '';
  String _origCity = '';
  String _origPhone = '';
  String _origCategory = '';

  bool _hasChanges = false;
  bool _isSaving = false; // true while a save request is in-flight

  @override
  void initState() {
    super.initState();
    _firstNameFocusNode = FocusNode();
    _lastNameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _phoneFocusNode = FocusNode();
    _firstNameCtrl.addListener(_checkChanges);
    _lastNameCtrl.addListener(_checkChanges);
    _emailCtrl.addListener(_checkChanges);
    _universityCtrl.addListener(_checkChanges);
    _yearCtrl.addListener(_checkChanges);
    _cityCtrl.addListener(_checkChanges);
    _phoneCtrl.addListener(_checkChanges);
    _categoryCtrl.addListener(_checkChanges);
  }

  void _checkChanges() {
    final changed = _firstNameCtrl.text.trim() != _origFirstName ||
        _lastNameCtrl.text.trim() != _origLastName ||
        _emailCtrl.text.trim() != _origEmail ||
        _universityCtrl.text.trim() != _origUniversity ||
        _yearCtrl.text.trim() != _origYear ||
        _cityCtrl.text.trim() != _origCity ||
        _phoneCtrl.text.trim() != _origPhone ||
        _categoryCtrl.text.trim() != _origCategory;
    
    // Always call setState to reflect changes in the UI immediately
    setState(() => _hasChanges = changed);
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _universityCtrl.dispose();
    _yearCtrl.dispose();
    _cityCtrl.dispose();
    _phoneCtrl.dispose();
    _categoryCtrl.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _emailFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  bool _isValidPhone(String value) {
    final normalized = value.replaceAll(RegExp(r'[\s-]'), '');
    return RegExp(r'^\+?[0-9]{10,15}$').hasMatch(normalized);
  }

  String? _validateInputs() {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final university = _universityCtrl.text.trim();
    final year = _yearCtrl.text.trim();
    final city = _cityCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final category = _categoryCtrl.text.trim();

    if (firstName.isEmpty || firstName.length < 2) {
      return L10nProfile.pleaseEnterYourFirst.tr();
    }
    if (lastName.isEmpty || lastName.length < 2) {
      return L10nProfile.pleaseEnterYourLast.tr();
    }
    if (email.isEmpty || !_isValidEmail(email)) {
      return L10nProfile.pleaseEnterAValid1.tr();
    }
    if (phone.isEmpty || !_isValidPhone(phone)) {
      return L10nProfile.pleaseEnterAValid.tr();
    }
    if (university.isEmpty) {
      return L10nProfile.pleaseSelectAUniversity.tr();
    }
    if (year.isEmpty) {
      return L10nProfile.pleaseSelectTheAcademic.tr();
    }
    if (city.isEmpty) {
      return L10nProfile.pleaseSelectAGovernorate.tr();
    }
    if (category.isEmpty) {
      return L10nProfile.pleaseChooseASpecialty.tr();
    }
    return null;
  }

  Future<void> _onSave() async {
    if (_isSaving) return;

    final validationError = _validateInputs();
    if (validationError != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError,
              style: TextStyle(fontFamily: 'Cairo')),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final cubit = context.read<ProfileCubit>();

    final yearString = _yearCtrl.text.trim();
    String phone = PhoneHelper.normalizeEgyptPhone(_phoneCtrl.text);

    // Build update body - التوكن في headers يكفي للـ API
    final body = <String, dynamic>{
      'firstName': _firstNameCtrl.text.trim(),
      'lastName': _lastNameCtrl.text.trim(),
      'phoneNumber': phone,
      'email': _emailCtrl.text.trim(),
      'universityName': _universityCtrl.text.trim(),
      'studyYear': yearString, // Sending as string (رابعة، خامسة، امتياز)
      'cityName': _cityCtrl.text.trim(),
      'categoryName': _categoryCtrl.text.trim(),
    };

    if (!mounted) return;
    setState(() => _isSaving = true);
    cubit.updateProfile(body);
  }

  void _showSelectionDialog({
    required String title,
    required List<String> items,
    required TextEditingController controller,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredItems = items
                .where((item) =>
                    item.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                title: Text(title,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87)),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        onChanged: (val) =>
                            setDialogState(() => searchQuery = val),
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: L10nProfile.research.tr(),
                          hintStyle:
                              TextStyle(fontFamily: 'Cairo', fontSize: 14),
                          prefixIcon: Icon(Icons.search),
                          isDense: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 12),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: filteredItems.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey[200]),
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                filteredItems[index],
                                style: TextStyle(
                                    fontFamily: 'Cairo', 
                                    fontSize: 16,
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
                                textAlign: TextAlign.right,
                              ),
                              onTap: () {
                                controller.text = filteredItems[index];
                                Navigator.pop(context);
                                // No auto-save — user must press save button
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pushReplacementNamed(Routes.doctorHomeScreen);
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.scaffoldBackgroundColor,
        drawer: const DoctorDrawer(selectedIndex: 2),
        appBar: AppBar(
          toolbarHeight: 70,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu, size: 24),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
          ),
          titleSpacing: 0,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10nDoctor.profile.tr(),
                style: textTheme.titleLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 8),
              Image.asset(
                'assets/images/splash-logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: BlocConsumer<ProfileCubit, ProfileState<DoctorProfileModel>>(
            listener: (context, state) {
              state.whenOrNull(
                success: (p, universities, cities, categories) {
                  final firstName = p.firstName ?? '';
                  final lastName = p.lastName ?? '';
                  final email = p.email ?? '';
                  final uni = p.faculty ?? '';
                  final yr = p.year ?? '';
                  final city = p.governorate ?? '';
                  final phone = p.phone ?? '';
                  final category = p.category ?? '';
                  _firstNameCtrl.text = firstName;
                  _lastNameCtrl.text = lastName;
                  _emailCtrl.text = email;
                  _universityCtrl.text = uni;
                  _yearCtrl.text = yr;
                  _cityCtrl.text = city;
                  _phoneCtrl.text = phone;
                  _categoryCtrl.text = category;
                  _origFirstName = firstName;
                  _origLastName = lastName;
                  _origEmail = email;
                  _origUniversity = uni;
                  _origYear = yr;
                  _origCity = city;
                  _origPhone = phone;
                  _origCategory = category;
                  if (_hasChanges) setState(() => _hasChanges = false);
                  // Show success snackbar only after a save, not on first load
                  if (_isSaving) {
                    _isSaving = false;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          L10nProfile.theProfileHasBeen.tr(),
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                error: (msg, type) {
                  _isSaving = false;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text(msg, style: TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Colors.red[700],
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
              );
            },
            builder: (context, state) {
              final loadingWidget = state.mapOrNull(
                loading: (s) => s.cachedData != null
                    ? _buildContent(
                        s.cachedData!, s.universities, s.cities, s.categories)
                    : null,
                success: (s) =>
                    _buildContent(s.data, s.universities, s.cities, s.categories),
                error: (s) => Center(child: Text(s.error)),
              );
              return loadingWidget ??
                  Center(child: CircularProgressIndicator());
            },
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Save Button ───────────────────────────────────────────────
              InkWell(
                onTap: (_hasChanges && !_isSaving) ? _onSave : null,
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 250),
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: (_hasChanges && !_isSaving)
                        ? LinearGradient(
                            colors: [Color(0xFF1D61E7), Color(0xFF0B8FAC)],
                          )
                        : LinearGradient(
                            colors: [Colors.grey.shade400, Colors.grey.shade400],
                          ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Color(0xFF021433).withValues(alpha: 0.18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_hasChanges && !_isSaving)
                            ? Color(0xFF1D61E7).withValues(alpha: 0.2)
                            : Colors.transparent,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSaving
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            L10nProfile.save.tr(),
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // ── Change Password Button ────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF1D61E7), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangePasswordScreen(),
                      ),
                    );
                  },
                  icon: Icon(Icons.lock_reset_rounded,
                      color: Color(0xFF1D61E7), size: 24),
                  label: Text(
                    L10nForgotPassword.changePassword.tr(),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1D61E7),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // ── Request and Delete Buttons ─────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1D61E7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MyRequestsScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.assignment_outlined, size: 24),
                        label: Text(
                          L10nDoctor.myRequests.tr(),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AccountDeletionScreen(),
                            ),
                          );
                        },
                        icon: Icon(Icons.delete_forever_rounded,
                            color: Colors.red, size: 24),
                        label: Text(
                          L10nDoctor.deleteAccount.tr(),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize:
                                14, // Reduced slightly to fit side-by-side
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ));
  }

  Widget _buildContent(
      DoctorProfileModel profile,
      List<UniversityModel> universities,
      List<CityModel> cities,
      List<CategoryModel> categories) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            L10nProfile.yourPersonalInformation.tr(),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(0xFF4B5563),
            ),
          ),

          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ??
                  (isDark ? Colors.grey[900] : Colors.white),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildEditableInputField(
                  label: L10nProfile.email.tr(),
                  controller: _emailCtrl,
                  focusNode: _emailFocusNode,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.left,
                  hintText: 'example@mail.com',
                ),
                _divider(),
                _buildEditableInputField(
                  label: L10nBooking.firstName.tr(),
                  controller: _firstNameCtrl,
                  focusNode: _firstNameFocusNode,
                  hintText: L10nProfile.enterFirstName.tr(),
                ),
                _divider(),
                _buildEditableInputField(
                  label: L10nBooking.lastName.tr(),
                  controller: _lastNameCtrl,
                  focusNode: _lastNameFocusNode,
                  hintText: L10nProfile.enterTheLastName.tr(),
                ),
                _divider(),
                _buildEditablePhoneField(),
                _divider(),
                _buildEditableField(
                  label: L10nDoctor.theUniversity.tr(),
                  id: 'university',
                  displayValue: _universityCtrl.text.isNotEmpty
                      ? _universityCtrl.text
                      : profile.faculty,
                  onTap: () => _showSelectionDialog(
                    title: L10nProfile.chooseTheUniversity.tr(),
                    items: universities.map((u) => u.name).toList(),
                    controller: _universityCtrl,
                  ),
                ),
                _divider(),
                _buildEditableField(
                  label: L10nProfile.academicYear.tr(),
                  id: 'year',
                  displayValue:
                      _yearCtrl.text.isNotEmpty ? _yearCtrl.text : profile.year,
                  onTap: () => _showSelectionDialog(
                    title: L10nProfile.selectTheAcademicYear.tr(),
                    items: [L10nProfile.fourth.tr(), L10nProfile.fifth.tr(), L10nProfile.privilege.tr()],
                    controller: _yearCtrl,
                  ),
                ),
                _divider(),
                _buildEditableField(
                  label: L10nHomeScreen.governorate.tr(),
                  id: 'city',
                  displayValue: _cityCtrl.text.isNotEmpty
                      ? _cityCtrl.text
                      : profile.governorate,
                  onTap: () => _showSelectionDialog(
                    title: L10nDoctor.selectTheGovernorate.tr(),
                    items: cities.map((c) => c.name).toList(),
                    controller: _cityCtrl,
                  ),
                ),
                _divider(),
                _buildEditableField(
                  label: L10nDoctor.specialization.tr(),
                  id: 'category',
                  displayValue: _categoryCtrl.text.isNotEmpty
                      ? _categoryCtrl.text
                      : profile.category,
                  onTap: () => _showSelectionDialog(
                    title: L10nProfile.chooseYourSpecialty.tr(),
                    items: categories.map((c) => c.name).toList(),
                    controller: _categoryCtrl,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String id,
    String? displayValue,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onTap,
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Color(0xFF1D61E7), Color(0xFF0B8FAC)],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: isDark ? Colors.white : Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          GestureDetector(
            onTap: onTap,
            child: Text(
              (displayValue == null || displayValue.isEmpty)
                  ? L10nDoctor.undefined.tr()
                  : displayValue,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Color(0xFF1F2937),
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
    TextAlign textAlign = TextAlign.right,
    String hintText = '',
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(focusNode),
                child: ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Color(0xFF1D61E7), Color(0xFF0B8FAC)],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.edit_outlined,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  color: isDark ? Colors.white : Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          TextField(
            focusNode: focusNode,
            controller: controller,
            keyboardType: keyboardType,
            textDirection: textDirection,
            textAlign: textAlign,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                color: isDark ? Colors.white54 : Color(0xFFD1D5DB),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Color(0xFFE5E7EB),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Color(0xFF1D61E7),
                  width: 1.5,
                ),
              ),
            ),
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditablePhoneField() {
    return _buildEditableInputField(
      label: L10nDoctor.phoneNumber.tr(),
      controller: _phoneCtrl,
      focusNode: _phoneFocusNode,
      keyboardType: TextInputType.phone,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
      hintText: L10nProfile.enterPhoneNumber.tr(),
    );
  }

  Widget _divider() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      height: 1,
      color: isDark ? Colors.grey[800] : Color(0xFFF3F4F6),
      thickness: 1.2,
    );
  }
}

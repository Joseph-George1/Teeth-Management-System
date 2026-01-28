import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/drawer/doctor_drawer_screen.dart';

class DoctorProfile extends StatefulWidget {
  const DoctorProfile({Key? key}) : super(key: key);

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _loading = false;
  String? _error;

  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;
  String? _faculty;
  String? _year;
  String? _governorate;
  String? _category;
  String? _profileImage;

  final List<String> _governorates = [
    'القاهرة', 'الجيزة', 'الإسكندرية', 'الدقهلية', 'الشرقية', 'الغربية',
    'المنوفية', 'البحيرة', 'القليوبية', 'دمياط', 'كفر الشيخ', 'بورسعيد',
    'الإسماعيلية', 'السويس', 'المنيا', 'أسيوط', 'سوهاج', 'قنا', 'الأقصر',
    'أسوان', 'البحر الأحمر', 'مطروح', 'شمال سيناء', 'جنوب سيناء', 'الفيوم',
    'بني سويف', 'الوادي الجديد',
  ];

  final List<String> _categories = [
    'جراحة الوجه والفكين', 'تقويم الأسنان', 'علاج الجذور', 'طب أسنان الأطفال',
    'تركيبات الأسنان', 'علاج اللثة', 'طب الأسنان التجميلي', 'زراعة الأسنان',
  ];

  final List<String> _colleges = [
    'كلية طب الأسنان - القاهرة', 'كلية طب الأسنان - عين شمس',
    'كلية طب الأسنان - الإسكندرية', 'كلية طب الأسنان - المنصورة', 'أخرى',
  ];

  final List<String> _studyYears = [
    'الفرقة الأولى', 'الفرقة الثانية', 'الفرقة الثالثة',
    'الفرقة الرابعة', 'الفرقة الخامسة', 'امتياز',
  ];

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final cachedFirst = await SharedPrefHelper.getString('first_name');
      final cachedLast = await SharedPrefHelper.getString('last_name');
      final cachedEmail = await SharedPrefHelper.getString('email');
      final cachedPhone = await SharedPrefHelper.getString('phone');
      final cachedFaculty = await SharedPrefHelper.getString('faculty');
      final cachedYear = await SharedPrefHelper.getString('year');
      final cachedGovernorate = await SharedPrefHelper.getString('governorate');
      final cachedCategory = await SharedPrefHelper.getString('category');
      final cachedImage = await SharedPrefHelper.getString('profile_image');

      if (mounted) {
        setState(() {
          _firstName =
              (cachedFirst?.isNotEmpty ?? false) ? cachedFirst : _firstName;
          _lastName =
              (cachedLast?.isNotEmpty ?? false) ? cachedLast : _lastName;
          _email = (cachedEmail?.isNotEmpty ?? false) ? cachedEmail : _email;
          if (cachedPhone?.isNotEmpty ?? false) {
            if (!cachedPhone!.contains('@')) {
              _phone = cachedPhone;
            }
          }
          _faculty = (cachedFaculty?.isNotEmpty ?? false) ? cachedFaculty : _faculty;
          _year = (cachedYear?.isNotEmpty ?? false) ? cachedYear : _year;
          _governorate = (cachedGovernorate?.isNotEmpty ?? false) ? cachedGovernorate : _governorate;
          _category = (cachedCategory?.isNotEmpty ?? false) ? cachedCategory : _category;
          _profileImage = (cachedImage?.isNotEmpty ?? false) ? cachedImage : _profileImage;

          // Fallback if name is missing but email exists
          if ((_firstName == null || _firstName!.isEmpty) &&
              (_email != null && _email!.isNotEmpty)) {
            _firstName = _email!.split('@').first;
          }
        });
      }
      await _fetchProfile();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final dio = DioFactory.getDio();
      Response? response;
      // Try common profile endpoints
      final candidates = ['/me', '/profile', '/users/me', '/auth/me'];
      for (final path in candidates) {
        try {
          final res = await dio.get(path);
          if (res.statusCode == 200) {
            response = res;
            break;
          }
        } on DioException catch (e) {
          // Ignore 404s and try next candidate
          if (e.response?.statusCode == 404) {
            continue;
          }
          // Network/timeouts bubble up
          rethrow;
        }
      }

      // Fallback: Try POST /update_profile with empty body if GET endpoints failed
      if (response == null) {
        try {
          final res = await dio.post('/update_profile', data: {});
          if (res.statusCode == 200) {
            response = res;
          }
        } catch (_) {
          // Ignore errors from fallback attempt
        }
      }

      if (response != null && response.statusCode == 200) {
        final data = response.data;
        Map<String, dynamic>? userMap;
        if (data is Map<String, dynamic>) {
          userMap = Map<String, dynamic>.from(data);
          if (userMap['user'] is Map) {
            userMap = Map<String, dynamic>.from(userMap['user']);
          }
        }
        
        // Debug log the complete response
        print('API Response: $data');
        print('User Map: $userMap');

        // Print all keys in the response for debugging
        if (data is Map) {
          print('Top-level response keys: ${data.keys.toList()}');
          // Print all key-value pairs for top level
          data.forEach((key, value) {
            print('$key: $value (${value.runtimeType})');
          });
          
          if (data['user'] is Map) {
            final userData = data['user'] as Map;
            print('User object keys: ${userData.keys.toList()}');
            // Print all key-value pairs for user object
            userData.forEach((key, value) {
              print('user.$key: $value (${value.runtimeType})');
            });
          }
        }

        String? getVal(String a, String b) {
          if (userMap == null) return null;
          return (userMap[a] ?? userMap[b])?.toString();
        }

        final firstName = getVal('first_name', 'firstName');
        final lastName = getVal('last_name', 'lastName');
        final email = userMap?['email']?.toString();
        // Try multiple keys for phone
        // Try to get phone from multiple possible locations
        String? phone;
        
        // Debug: Print all keys that might contain phone info
        print('Searching for phone number in response...');
        
        // Try direct access first
        phone = userMap?['phone']?.toString();
        print('After checking userMap[\'phone\']: $phone');
        
        // Try common alternative keys
        final possiblePhoneKeys = ['tel', 'telephone', 'phone_number', 'mobile', 'phoneNumber', 'phone'];

        for (var key in possiblePhoneKeys) {
          if ((phone == null || phone.isEmpty) && userMap?[key] != null) {
            phone = userMap?[key]?.toString();
            print('Found phone in userMap[\'$key\']: $phone');
          }
        }
        
        // If still not found, try to get from the root of the response
        if ((phone == null || phone.isEmpty) && data is Map) {
          for (var key in possiblePhoneKeys) {
            if (data[key] != null) {
              phone = data[key]?.toString();
              print('Found phone in root[\'$key\']: $phone');
              if (phone != null && phone.isNotEmpty) break;
            }
          }
        }

        // Try to find any key that might contain phone number
        if ((phone == null || phone.isEmpty) && userMap != null) {
          final phoneKeys = userMap.keys.where((key) => 
            key.toString().toLowerCase().contains('phone') || 
            key.toString().toLowerCase().contains('tel')
          ).toList();
          
          for (final key in phoneKeys) {
            final value = userMap[key]?.toString();
            if (value != null && value.isNotEmpty && !value.contains('@')) {
              phone = value;
              break;
            }
          }
        }

        // Ensure phone is not an email
        if (phone != null && phone.contains('@')) {
          phone = null;
        }



        final faculty = userMap?['faculty']?.toString();
        final year = userMap?['year']?.toString();
        final governorate = (userMap?['governorate'] ?? userMap?['governorate_id'])?.toString();
        final profileImage = userMap?['profile_image']?.toString();

        // Debug log the extracted values
        print('Extracted phone: $phone');
        print('All userMap keys: ${userMap?.keys.toList()}');

        if (mounted) {
          setState(() {
            // Update state with fetched data, falling back to existing state if null
            if (firstName != null && firstName.isNotEmpty) _firstName = firstName;
            if (lastName != null && lastName.isNotEmpty) _lastName = lastName;
            if (email != null && email.isNotEmpty) _email = email;
            if (phone != null && phone.isNotEmpty) _phone = phone;
            if (faculty != null && faculty.isNotEmpty) _faculty = faculty;
            if (year != null && year.isNotEmpty) _year = year;
            if (governorate != null && governorate.isNotEmpty) _governorate = governorate;
            if (profileImage != null && profileImage.isNotEmpty) _profileImage = profileImage;

            // Fallback if name is missing but email exists
            if ((_firstName == null || _firstName!.isEmpty) &&
                (_email != null && _email!.isNotEmpty)) {
              _firstName = _email!.split('@').first;
            }
          });
        }

        if ((firstName?.isNotEmpty ?? false)) {
          await SharedPrefHelper.setData('first_name', firstName);
          await SharedPrefHelper.setData('last_name', lastName ?? '');
          if ((email?.isNotEmpty ?? false)) {
            await SharedPrefHelper.setData('email', email);
          }
          if (phone != null) await SharedPrefHelper.setData('phone', phone);
          if (faculty != null) await SharedPrefHelper.setData('faculty', faculty);
          if (year != null) await SharedPrefHelper.setData('year', year);
          if (governorate != null) await SharedPrefHelper.setData('governorate', governorate);
          if (profileImage != null) {
            await SharedPrefHelper.setData('profile_image', profileImage);
            DoctorDrawer.profileImageNotifier.value = profileImage;
          }
        }
      } else {
        // No known endpoint found. Do not show scary banner; keep cached data.
        return;
      }
    } on DioException catch (e) {
      // For 404 specifically, suppress the error and keep cached values
      if (e.response?.statusCode == 404) return;
      setState(() => _error = e.message ?? 'تعذر الاتصال بالخادم');
    } catch (_) {
      setState(() => _error = 'حدث خطأ غير متوقع');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final base64Image = base64Encode(bytes);

        setState(() {
          _profileImage = base64Image;
        });

        await _uploadImage(base64Image);
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة')),
      );
    }
  }

  Future<void> _uploadImage(String base64Image) async {
    try {
      final dio = DioFactory.getDio();
      final response = await dio.post(
        '/update_profile',
        data: {'profile_image': base64Image},
      );

      if (response.statusCode == 200) {
        await SharedPrefHelper.setData('profile_image', base64Image);
        DoctorDrawer.profileImageNotifier.value = base64Image;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تحديث الصورة الشخصية بنجاح')),
        );
      } else {
        throw Exception('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تحديث الصورة')),
      );
    }
  }

  Future<void> _updateProfileData(Map<String, dynamic> data) async {
    setState(() => _loading = true);
    try {
      final dio = DioFactory.getDio();
      final response = await dio.post('/update_profile', data: data);
      if (response.statusCode == 200) {
        await _fetchProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث البيانات بنجاح'), backgroundColor: Colors.green),
          );
        }
      } else {
        throw Exception('Failed to update');
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء التحديث'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showEditProfileDialog() {
    final firstNameCtrl = TextEditingController(text: _firstName);
    final lastNameCtrl = TextEditingController(text: _lastName);
    final phoneCtrl = TextEditingController(text: _phone);

    String? selectedCategory = _category;
    String? selectedYear = _year;
    String? selectedGovernorate = _governorate;
    String? selectedCollege = _faculty;

    // Ensure initial values are in the lists or null
    if (selectedCategory != null && !_categories.contains(selectedCategory)) selectedCategory = null;
    if (selectedYear != null && !_studyYears.contains(selectedYear)) selectedYear = null;
    if (selectedGovernorate != null && !_governorates.contains(selectedGovernorate)) selectedGovernorate = null;
    if (selectedCollege != null && !_colleges.contains(selectedCollege)) selectedCollege = null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: const Text('تعديل البيانات', textAlign: TextAlign.center),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: firstNameCtrl,
                        decoration: const InputDecoration(labelText: 'الاسم الأول'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: lastNameCtrl,
                        decoration: const InputDecoration(labelText: 'اسم العائلة'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCollege,
                        decoration: const InputDecoration(labelText: 'الكلية'),
                        isExpanded: true,
                        items: _colleges.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setStateDialog(() => selectedCollege = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedYear,
                        decoration: const InputDecoration(labelText: 'السنة الدراسية'),
                        isExpanded: true,
                        items: _studyYears.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setStateDialog(() => selectedYear = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGovernorate,
                        decoration: const InputDecoration(labelText: 'المحافظة'),
                        isExpanded: true,
                        items: _governorates.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setStateDialog(() => selectedGovernorate = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory, // Use the variable
                        decoration: const InputDecoration(labelText: 'التخصص'),
                        isExpanded: true,
                        items: _categories.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                        onChanged: (v) => setStateDialog(() => selectedCategory = v), // Update variable
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _updateProfileData({
                      'first_name': firstNameCtrl.text,
                      'last_name': lastNameCtrl.text,
                      'phone': phoneCtrl.text,
                      'category': selectedCategory,
                      'year': selectedYear,
                      'governorate': selectedGovernorate,
                      'faculty': selectedCollege,
                    });
                  },
                  child: const Text('حفظ'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const DoctorDrawer(),
      appBar: AppBar(
        toolbarHeight: 75.6,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, size: 24.w),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'الملف الشخصي',
              style:
                  textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'تعديل البيانات',
            onPressed: _showEditProfileDialog,
          ),
          SizedBox(width: 8.w),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: theme.brightness == Brightness.dark
                ? Colors.grey[700]
                : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: _fetchProfile,
          color: colorScheme.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _headerCard(theme, textTheme, colorScheme),
                  SizedBox(height: 12.h),
                  _infoCard(theme, textTheme, colorScheme),
                  if (_error != null) ...[
                    SizedBox(height: 12.h),
                    _errorBanner(textTheme, colorScheme, _error!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerCard(
      ThemeData theme, TextTheme textTheme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundColor: theme.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[200],
                backgroundImage: _profileImage != null
                    ? MemoryImage(base64Decode(_profileImage!))
                    : null,
                child: _profileImage == null
                    ? Icon(Icons.person_outline, color: theme.iconTheme.color)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.cardTheme.color ?? Colors.white, width: 1.5),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 12.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _loading
                    ? _shimmerLine(width: 120.w, height: 18.h, theme: theme)
                    : Text(
                        _composeName(_firstName, _lastName) ?? 'دكتور',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp,
                        ),
                        textAlign: TextAlign.right,
                      ),
                SizedBox(height: 4.h),
                _loading
                    ? _shimmerLine(width: 180.w, height: 14.h, theme: theme)
                    : Text(
                        _email ?? '-',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
      ThemeData theme, TextTheme textTheme, ColorScheme colorScheme) {
    final isDark = theme.brightness == Brightness.dark;
    final items = <_InfoItem>[
      _InfoItem(
          icon: Icons.badge_outlined, label: 'الاسم الأول', value: _firstName),
      _InfoItem(
          icon: Icons.perm_identity, label: 'اسم العائلة', value: _lastName),
      _InfoItem(
          icon: Icons.email_outlined, label: 'البريد الإلكتروني', value: _email),
      _InfoItem(
          icon: Icons.phone_outlined, label: 'رقم الهاتف', value: _phone),
      _InfoItem(
          icon: Icons.school_outlined, label: 'الكلية', value: _faculty),
      _InfoItem(
          icon: Icons.event_note_outlined,
          label: 'السنة الدراسية',
          value: _year),
      _InfoItem(
          icon: Icons.work_outline, label: 'التخصص', value: _category), // Added Category
      _InfoItem(
          icon: Icons.place_outlined, label: 'المحافظة', value: _governorate),
    ];

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _infoRow(items[i], theme, textTheme, colorScheme),
            if (i != items.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: theme.brightness == Brightness.dark
                    ? Colors.grey[700]
                    : const Color(0xFFE5E7EB),
              ),
          ]
        ],
      ),
    );
  }

  Widget _infoRow(_InfoItem item, ThemeData theme, TextTheme textTheme,
      ColorScheme colorScheme) {
    return Container( // Changed Material/Inkwell to basic Container to remove tap effect
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 6.w),
      child: Row(
        children: [
          Icon(item.icon, color: theme.iconTheme.color, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                  textAlign: TextAlign.right,
                ),
                SizedBox(height: 2.h),
                _loading
                    ? _shimmerLine(width: 160.w, height: 16.h, theme: theme)
                    : Text(
                        (item.value?.isNotEmpty ?? false) ? item.value! : '-',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                        textAlign: TextAlign.right,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(
      TextTheme textTheme, ColorScheme colorScheme, String message) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onErrorContainer),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  String? _composeName(String? f, String? l) {
    if ((f == null || f.isEmpty) && (l == null || l.isEmpty)) return null;
    if (f != null && f.isNotEmpty && l != null && l.isNotEmpty) return '$f $l';
    return f?.isNotEmpty == true ? f : l;
  }

  Widget _shimmerLine(
      {required double width,
      required double height,
      required ThemeData theme}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String? value;

  _InfoItem({required this.icon, required this.label, required this.value});
}

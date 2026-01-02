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
  const DoctorProfile({super.key});

  @override
  State<DoctorProfile> createState() => _DoctorProfileState();
}

class _DoctorProfileState extends State<DoctorProfile> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isLoading = false;
  String? _error;

  // Profile Data
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _phone;
  String? _faculty;
  String? _year;
  String? _governorate;
  String? _profileImage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// Loads data from Cache first, then API (Stale-While-Revalidate)
  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);

    // 1. Load from SharedPrefs immediately
    await _loadFromCache();

    // 2. Refresh from API in background
    await _fetchRemoteProfile();

    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadFromCache() async {
    try {
      final f = await SharedPrefHelper.getString('first_name');
      final l = await SharedPrefHelper.getString('last_name');
      final e = await SharedPrefHelper.getString('email');
      final p = await SharedPrefHelper.getString('phone');
      final fac = await SharedPrefHelper.getString('faculty');
      final y = await SharedPrefHelper.getString('year');
      final g = await SharedPrefHelper.getString('governorate');
      final img = await SharedPrefHelper.getString('profile_image');

      if (!mounted) return;

      setState(() {
        if (f.isNotEmpty) _firstName = f;
        if (l.isNotEmpty) _lastName = l;
        if (e.isNotEmpty) _email = e;
        if (p.isNotEmpty) _phone = p;
        if (fac.isNotEmpty) _faculty = fac;
        if (y.isNotEmpty) _year = y;
        if (g.isNotEmpty) _governorate = g;
        if (img.isNotEmpty) _profileImage = img;
      });
    } catch (_) {}
  }

  Future<void> _fetchRemoteProfile() async {
    try {
      final dio = DioFactory.getDio();
      // Get the email from SharedPreferences
      final email = await SharedPrefHelper.getString('email');
      
      if (email == null || email.isEmpty) {
        if (mounted) {
          setState(() => _error = 'No user email found. Please log in again.');
        }
        return;
      }

      // Get the token for authorization
      final token = await SharedPrefHelper.getSecuredString('user_token');
      if (token == null || token.isEmpty) {
        if (mounted) {
          setState(() => _error = 'Not authenticated. Please log in again.');
        }
        return;
      }

      // Since the backend doesn't have a direct profile endpoint,
      // we'll use the update_profile endpoint with an empty update to get the current profile
      final response = await dio.post(
        '/update_profile',
        data: {}, // Empty update to just get the current profile
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        print('DEBUG: Profile data: $data');
        
        if (data is Map && data['status'] == 'success' && data['user'] != null) {
          final user = data['user'];

          final f =
              user['first_name']?.toString() ?? user['firstName']?.toString();
          final l =
              user['last_name']?.toString() ?? user['lastName']?.toString();
          final e = user['email']?.toString();
          final p = user['phone']?.toString();
          final fac = user['faculty']?.toString();
          final y = user['year']?.toString();
          final g = user['governorate']?.toString();
          final img = user['profile_image']?.toString();

          if (mounted) {
            setState(() {
              if (f != null) _firstName = f;
              if (l != null) _lastName = l;
              if (e != null) _email = e;
              if (p != null) _phone = p;
              if (fac != null) _faculty = fac;
              if (y != null) _year = y;
              if (g != null) _governorate = g;
              if (img != null) _profileImage = img;
            });
          }

          // Update Cache
          if (f != null) await SharedPrefHelper.setData('first_name', f);
          if (l != null) await SharedPrefHelper.setData('last_name', l);
          if (e != null) await SharedPrefHelper.setData('email', e);
          if (p != null) await SharedPrefHelper.setData('phone', p);
          if (fac != null) await SharedPrefHelper.setData('faculty', fac);
          if (y != null) await SharedPrefHelper.setData('year', y);
          if (g != null) await SharedPrefHelper.setData('governorate', g);
          if (img != null) {
            await SharedPrefHelper.setData('profile_image', img);
            // Notify drawer to update image
            DoctorDrawer.profileImageNotifier.value = img;
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (e is DioException) {
        print('DEBUG: DioError Response: ${e.response?.data}');
        print('DEBUG: DioError Status: ${e.response?.statusCode}');
        print('DEBUG: DioError Headers: ${e.requestOptions.headers}');
      }

      // Only show error if we have NO data at all
      if ((_firstName == null || _firstName!.isEmpty) &&
          (_email == null || _email!.isEmpty)) {
        setState(() => _error = 'تعذر تحميل البيانات: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

        // Optimistic update
        await SharedPrefHelper.setData('profile_image', base64Image);
        DoctorDrawer.profileImageNotifier.value = base64Image;

        await _uploadImage(base64Image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة')),
      );
    }
  }

  Future<void> _uploadImage(String base64Image) async {
    try {
      final dio = DioFactory.getDio();
      await dio.post(
        '/update_profile',
        data: {'profile_image': base64Image},
      );
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const DoctorDrawer(),
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: RefreshIndicator(
          onRefresh: _loadProfileData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              children: [
                _buildHeaderCard(),
                SizedBox(height: 16.h),
                if (_error != null)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.orange, fontSize: 14.sp),
                    ),
                  ),
                _buildInfoCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 35.r,
                backgroundColor: Colors.grey[200],
                backgroundImage: _profileImage != null
                    ? MemoryImage(base64Decode(_profileImage!))
                    : null,
                child: _profileImage == null
                    ? Icon(Icons.person, size: 35.sp, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Color(0xFF84E5F3), // Cyan from drawer
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt,
                        size: 14.sp, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_firstName ?? ''} ${_lastName ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoItem(Icons.person_outline, 'الاسم الأول', _firstName),
          _buildDivider(),
          _buildInfoItem(Icons.person_outline, 'اسم العائلة', _lastName),
          _buildDivider(),
          _buildInfoItem(Icons.email_outlined, 'البريد الإلكتروني', _email),
          _buildDivider(),
          _buildInfoItem(Icons.phone_outlined, 'رقم الهاتف', _phone),
          _buildDivider(),
          _buildInfoItem(Icons.school_outlined, 'الكلية', _faculty),
          _buildDivider(),
          _buildInfoItem(
              Icons.calendar_today_outlined, 'السنة الدراسية', _year),
          _buildDivider(),
          _buildInfoItem(Icons.location_on_outlined, 'المحافظة', _governorate),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF84E5F3), size: 22.sp),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  (value == null || value.isEmpty) ? '-' : value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 54.w,
    );
  }
}

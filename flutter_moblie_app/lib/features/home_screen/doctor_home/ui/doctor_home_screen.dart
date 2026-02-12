import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/core/utils/notification_helper.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/drawer/doctor_drawer_screen.dart';
import 'package:thotha_mobile_app/features/notifications/ui/notifications_screen.dart';
import 'package:thotha_mobile_app/core/theming/colors.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/ui/add_case_request_screen.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [Color(0xFF84E5F3), Color(0xFF8DECB4)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 25.w,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  String? _firstName;
  String? _lastName;
  bool _isLoadingName = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    setState(() {
      _isLoadingName = true;
    });

    try {
      // Try to get stored name first (if login saved it to secure storage or prefs)
      final storedFirst = await SharedPrefHelper.getString('first_name');
      final storedLast = await SharedPrefHelper.getString('last_name');

      if (storedFirst != null && storedFirst.isNotEmpty) {
        _firstName = storedFirst;
        _lastName = storedLast;
        setState(() {
          _isLoadingName = false;
        });
        return;
      }

      // Fallback: request profile from server at /me or /profile (common patterns)
      final dio = DioFactory.getDio();

      Response response;
      try {
        response = await dio.get('/me');
      } catch (_) {
        try {
          response = await dio.get('/profile');
        } catch (_) {
          // If API calls fail, try to fallback to email
          final email = await SharedPrefHelper.getString('email');
          if (email.isNotEmpty) {
            _firstName = email.split('@').first;
            setState(() => _isLoadingName = false);
            return;
          }
          rethrow;
        }
      }

      if (response.statusCode == 200) {
        final data = response.data;
        // Support different response shapes
        _firstName = (data is Map &&
                (data['first_name'] != null || data['firstName'] != null))
            ? (data['first_name'] ?? data['firstName'])
            : (data is Map && data['firstName'] != null
                ? data['firstName']
                : null);
        _lastName = (data is Map &&
                (data['last_name'] != null || data['lastName'] != null))
            ? (data['last_name'] ?? data['lastName'])
            : (data is Map && data['lastName'] != null
                ? data['lastName']
                : null);

        // If still null, try nested 'user' object
        if ((_firstName == null || _firstName!.isEmpty) &&
            data is Map &&
            data['user'] != null) {
          final user = data['user'];
          _firstName = user['first_name'] ?? user['firstName'];
          _lastName = user['last_name'] ?? user['lastName'];
        }

        // Save to prefs for next time
        if (_firstName != null && _firstName!.isNotEmpty) {
          await SharedPrefHelper.setData('first_name', _firstName);
          if (_lastName != null)
            await SharedPrefHelper.setData('last_name', _lastName);
        }
      } else {
        // Error handling can be improved
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    } finally {
      // Final fallback if everything failed
      if (_firstName == null || _firstName!.isEmpty) {
        final email = await SharedPrefHelper.getString('email');
        if (email.isNotEmpty) {
          _firstName = email.split('@').first;
        }
      }
      if (mounted) setState(() => _isLoadingName = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final unreadCount = NotificationHelper.getUnreadCount();
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
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(
              width: 37.w,
              height: 40.h,
              child: Image.asset(
                'assets/images/splash-logo.png',
                width: 37.w,
                height: 40.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 92.w,
              height: 27.h,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'لوحة التحكم',
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, size: 24.w),
                onPressed: () {
                  // Mark notifications as read when opened
                  NotificationHelper.hasUnreadNotifications = false;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  ).then((_) {
                    // This will refresh the notification badge when returning to the screen
                    if (mounted) setState(() {});
                  });
                },
              ),
              if (unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 10,
                  child: Container(
                    width: 16.w,
                    height: 16.w,
                    decoration: BoxDecoration(
                      color: colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onError,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.1),
          child: Container(
            height: 1.1,
            color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCaseRequestScreen(),
            ),
          );
        },
        backgroundColor: ColorsManager.mainBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Container(
        color: theme.scaffoldBackgroundColor,
        child: SingleChildScrollView(
            child: Column(children: [
          // Welcome Container
          SizedBox(width: 8.w),
          Container(
            width: 390.w,
            height: 100.h,
            margin: EdgeInsets.only(top: 0.h, right: 10.w, left: 20.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Text
                Container(
                  width: double.infinity,
                  height: 36.h,
                  alignment: Alignment.centerRight,
                  child: _isLoadingName
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child:
                              const CircularProgressIndicator(strokeWidth: 3),
                        )
                      : Text(
                          _firstName != null
                              ? ' Welcome $_firstName'
                              : ' مرحباً، د.',
                          style: textTheme.titleLarge?.copyWith(
                            fontFamily: 'Cairo',
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.right,
                        ),
                ),
                SizedBox(height: 5.99.h), // Gap between texts
                // Subtitle
                Container(
                  width: double.infinity,
                  height: 20.h,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'إليك نظرة عامة على حجوزاتك وأدائك',
                    style: textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Cairo',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Grid Container with 4 cards
          Container(
            width: 390.w,
            height: 246.8.h,
            margin: EdgeInsets.only(top: 0.h, left: 20.w, right: 20.w),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 187 / 105.66,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                // First Card - Total Patients
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 77,
                              height: 30,
                              alignment: Alignment.center,
                              child: Text(
                                'الحجوزات اليوم',
                                style: textTheme.bodySmall?.copyWith(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  height: 1.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                                // maxLines: 1,
                                //overflow: TextOverflow.visible,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '28',
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'Cairo',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_outline,
                          size: 24,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                    ],
                  ),
                ),
                // Second Card - Appointments
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 77,
                              height: 30,
                              alignment: Alignment.center,
                              child: Text(
                                'الحجوزات اليوم',
                                style: textTheme.bodySmall?.copyWith(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  height: 1.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                                // maxLines: 1,
                                //overflow: TextOverflow.visible,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '28',
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'Cairo',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: theme.iconTheme.color,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Third Card - Today's Appointments
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحجوزات المكتملة',
                              style: textTheme.bodySmall?.copyWith(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                                height: 1.0,
                                fontWeight: FontWeight.w400,
                              ),
                              // maxLines: 1,
                              //  overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '20',
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'Cairo',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 52.w,
                            height: 52.h,
                            decoration: BoxDecoration(
                              color:
                                  isDark ? Colors.grey[800] : Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check_circle_outline_sharp,
                                color: theme.iconTheme.color,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Fourth Card - Available Time
                Container(
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'التقييم',
                            style: textTheme.bodySmall?.copyWith(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              color: colorScheme.onSurface.withValues(alpha: 0.6),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '4.8',
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'Cairo',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star_border,
                          color: theme.iconTheme.color,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // الحجوزات القادمة اليوم Container
          Container(
            width: 390.w,
            margin: EdgeInsets.only(
                top: 20.h, left: 20.w, right: 20.w, bottom: 20.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            decoration: BoxDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Header
                Container(
                  width: 200.w,
                  height: 27.h,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'الحجوزات القادمة اليوم',
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                      height: 1.5,
                      color: colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 0.h),
                // First Appointment Card
                Container(
                  width: 373.8,
                  height: 120,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Left Container
                      Positioned(
                        left: 11.99,
                        top: (142.0 - 102.0) / 2, // Center vertically
                        child: Container(
                          width: 232.86,
                          height: 102.0,
                          padding: const EdgeInsets.only(right: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 200,
                                height: 26.99,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'محمد اشرف',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    height: 1.5,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Small spacing between the name and specialty
                              Container(
                                width: 200,
                                height: 21.0,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'تنضيف اسنان',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.5,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              Container(
                                width: 232.86,
                                // Width as specified
                                height: 32.02,
                                // Height as specified
                                margin: const EdgeInsets.only(top: 10),
                                // Gap as specified
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Time Display - Moved to where date was
                                    // Add this text widget right after the Image.asset widget
                                    const SizedBox(height: 5),
                                    const Text(
                                      ' صباحا ',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF8DECB4),
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    Text(
                                      '1:00',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF8DECB4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Image Container
                      Positioned(
                        left: 270,
                        top: 20,
                        child: Opacity(
                          opacity: 0.8,
                          child: Container(
                            width: 79.99,
                            height: 79.99,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/kateb.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 373.8,
                  height: 120,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Left Container
                      Positioned(
                        left: 11.99,
                        top: (142.0 - 102.0) / 2, // Center vertically
                        child: Container(
                          width: 232.86,
                          height: 102.0,
                          padding: const EdgeInsets.only(right: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 200,
                                height: 26.99,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'عبدالحليم رمضان',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    height: 1.5,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Small spacing between the name and specialty
                              Container(
                                width: 200,
                                height: 21.0,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'حشو العصب ',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.5,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              Container(
                                width: 232.86,
                                // Width as specified
                                height: 32.02,
                                // Height as specified
                                margin: const EdgeInsets.only(top: 10),
                                // Gap as specified
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Time Display - Moved to where date was
                                    // Add this text widget right after the Image.asset widget
                                    const SizedBox(height: 5),
                                    const Text(
                                      ' صباحا ',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF8DECB4),
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    Text(
                                      '11:00',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF8DECB4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Image Container
                      Positioned(
                        left: 270,
                        top: 20,
                        child: Opacity(
                          opacity: 0.8,
                          child: Container(
                            width: 79.99,
                            height: 79.99,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/halim.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 373.8,
                  height: 120,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Left Container
                      Positioned(
                        left: 11.99,
                        top: (142.0 - 102.0) / 2, // Center vertically
                        child: Container(
                          width: 232.86,
                          height: 102.0,
                          padding: const EdgeInsets.only(right: 0, bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 200,
                                height: 26.99,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'زياد جمال',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    height: 1.5,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Small spacing between the name and specialty
                              Container(
                                width: 200,
                                height: 21.0,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  ' تقويم الأسنان',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.5,
                                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                                  ),
                                ),
                              ),
                              Container(
                                width: 232.86,
                                // Width as specified
                                height: 32.02,
                                // Height as specified
                                margin: const EdgeInsets.only(top: 10),
                                // Gap as specified
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Time Display - Moved to where date was
                                    // Add this text widget right after the Image.asset widget
                                    const SizedBox(height: 5),
                                    const Text(
                                      ' صباحا ',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF8DECB4),
                                      ),
                                    ),
                                    const SizedBox(height: 0),
                                    Text(
                                      '8:00',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        color: Color(0xFF8DECB4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Image Container
                      Positioned(
                        left: 270,
                        top: 20,
                        child: Opacity(
                          opacity: 0.8,
                          child: Container(
                            width: 79.99,
                            height: 79.99,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: AssetImage('assets/images/zozjpg.jpg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ])));
  }
}





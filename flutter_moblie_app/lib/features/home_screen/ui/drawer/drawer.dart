import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/booking_history/ui/booking_history_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/my_bookings/ui/my_bookings_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/browse_services/ui/browse_services_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/settings/ui/settings_screen.dart';
import 'package:thotha_mobile_app/features/login/ui/login_screen.dart';


class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'تأكيد تسجيل الخروج',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.grey,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
              ),
              TextButton(
                child: const Text(
                  'تسجيل خروج',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  // Navigate to login screen and remove all previous routes
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static const _cCyan = Color(0xFF84E5F3);
  static const _cGreen = Color(0xFF8DECB4);

  Widget _menuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? Theme.of(context).iconTheme.color),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        color:
                            textColor ?? Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: topPad + 160.h,
            padding: EdgeInsets.only(top: topPad),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(
                  height: 56.h,
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          'القائمة',
                          style: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w700,
                                fontSize: 20.sp,
                                color: colorScheme.onPrimary,
                              ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.close, color: colorScheme.onPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                  child: Container(
                    height: 64.h,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 12.w, right: 12.w),
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.person_outline, color: _cCyan),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'زياد جمال',
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16.sp,
                                          color: colorScheme.onPrimary,
                                        ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'zyadgamal@gmail.com',
                                    textAlign: TextAlign.right,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12.sp,
                                          color: colorScheme.onPrimary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _menuItem(context, title: 'الحساب الشخصي', icon: Icons.person_outline),
                _menuItem(
                  context,
                  title: 'حجوزاتي',
                  icon: Icons.event_note_outlined,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  MyBookingsScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  title: 'تاريخ الحجوزات',
                  icon: Icons.history,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  BookingHistoryScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  title: 'تصفح الخدمات',
                  icon: Icons.calendar_month_outlined,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>  BrowseServicesScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  title: 'الإعدادات',
                  icon: Icons.settings_outlined,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  SettingsScreen()),
                    );
                  },
                ),
                _menuItem(context, title: 'المساعدة والدعم', icon: Icons.help_outline),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Divider(height: 24.h),
                ),
                _menuItem(
                  context,
                  title: 'تسجيل الخروج',
                  icon: Icons.logout_outlined,
                  iconColor: colorScheme.error,
                  textColor: colorScheme.error,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    _showLogoutConfirmation(context);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Center(
              child: Text(
                'الإصدار 1.0.0',
                style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w400,
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

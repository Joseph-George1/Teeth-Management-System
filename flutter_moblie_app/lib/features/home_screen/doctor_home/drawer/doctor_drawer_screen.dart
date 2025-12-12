import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/settings/ui/settings_screen.dart';
import 'package:thotha_mobile_app/features/login/ui/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/ui/main_layout_doctor.dart';

class DoctorDrawer extends StatefulWidget {
  const DoctorDrawer({super.key});

  @override
  State<DoctorDrawer> createState() => _DoctorDrawerState();
}

class _DoctorDrawerState extends State<DoctorDrawer> {
  String? _firstName;
  String? _lastName;
  String? _email;
  bool _isLoadingName = false;

  static const _cCyan = Color(0xFF84E5F3);
  static const _cGreen = Color(0xFF8DECB4);

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

  void _showLogoutConfirmation(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'تأكيد تسجيل الخروج',
              textAlign: TextAlign.right,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            content: Text(
              'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
              textAlign: TextAlign.right,
              style: textTheme.bodyMedium,
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'إلغاء',
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  'تسجيل خروج',
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(useDoctorDrawer: true),
                    ),
                  );
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
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

  Widget _menuItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        Color iconColor = _cCyan,
        Color? textColor,
        bool isSelected = false,
        VoidCallback? onTap,
      }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isSelected 
            ? _cCyan.withOpacity(0.1) 
            : null,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                Icon(
                  icon, 
                  color: isSelected ? _cCyan : Theme.of(context).iconTheme.color
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected 
                          ? _cCyan 
                          : textColor ?? Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: _cCyan,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(4.r),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _fetchDoctorName() async {
    setState(() => _isLoadingName = true);

    try {
      final cachedFirstName = await SharedPrefHelper.getString('first_name');
      final cachedLastName = await SharedPrefHelper.getString('last_name');
      final cachedEmail = await SharedPrefHelper.getString('email');

      if (cachedFirstName != null && cachedFirstName.isNotEmpty) {
        setState(() {
          _firstName = cachedFirstName;
          _lastName = cachedLastName;
          _email = cachedEmail;
        });
        return;
      }

      final dio = DioFactory.getDio();
      Response response;
      try {
        response = await dio.get('/me');
      } catch (_) {
        response = await dio.get('/profile');
      }

      if (response.statusCode == 200) {
        final data = response.data;
        String? f, l, e;

        if (data is Map) {
          f = (data['first_name'] ?? data['firstName']) as String?;
          l = (data['last_name'] ?? data['lastName']) as String?;
          e = (data['email'] ?? (data['user']?['email'])) as String?;

          if ((f == null || f.isEmpty) && data['user'] != null) {
            final user = data['user'];
            f = user['first_name'] ?? user['firstName'];
            l = user['last_name'] ?? user['lastName'];
          }
        }

        setState(() {
          _firstName = f;
          _lastName = l;
          _email = e;
        });

        if (f != null && f.isNotEmpty) {
          await SharedPrefHelper.setData('first_name', f);
          await SharedPrefHelper.setData('last_name', l ?? '');
          if (e != null) await SharedPrefHelper.setData('email', e);
        }
      }
    } finally {
      setState(() => _isLoadingName = false);
    }
  }

  int _getCurrentIndex() {
    final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
    if (currentRoute.contains('doctor-home')) return 0;
    if (currentRoute.contains('upcoming-bookings')) return 1;
    if (currentRoute.contains('booking-records')) return 2;
    if (currentRoute.contains('profile')) return 3;
    if (currentRoute.contains('settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final double topPad = MediaQuery.of(context).padding.top;
    final int currentIndex = _getCurrentIndex();

    return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
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
                  colors: [_cCyan, _cGreen],
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
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.surface,
                            ),
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
                        color: Theme.of(context)
                            .colorScheme
                            .surface
                            .withOpacity(0.25),
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
                                color: Theme.of(context).colorScheme.surface,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: _cCyan,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    _isLoadingName
                                        ? SizedBox(
                                      width: 16.w,
                                      height: 16.w,
                                      child:
                                      const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : Text(
                                      _firstName != null
                                          ? 'د/ ${_firstName!} ${_lastName ?? ''}'
                                          : 'د/ أحمد محمود',
                                      style: textTheme.titleMedium
                                          ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                      ),
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      _email != null && _email!.isNotEmpty
                                          ? _email!
                                          : 'zyadgamal@gmail.com',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
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
                  _menuItem(
                    context,
                    title: 'الرئيسية',
                    icon: Icons.home,
                    isSelected: currentIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'doctor-home'),
                          builder: (context) => const MainLayoutDoctor(initialIndex: 0),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    title: 'الملف الشخصي',
                    icon: Icons.person_outline,
                    isSelected: currentIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'doctor-profile'),
                          builder: (context) => const MainLayoutDoctor(initialIndex: 4),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    title: 'الحجوزات القادمة',
                    icon: Icons.event_note_outlined,
                    isSelected: currentIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'upcoming-bookings'),
                          builder: (context) => const MainLayoutDoctor(initialIndex: 1),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    title: 'سجل الحجوزات',
                    icon: Icons.list_alt_rounded,
                    isSelected: currentIndex == 3,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'booking-records'),
                          builder: (context) => const MainLayoutDoctor(initialIndex: 2),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    title: 'المرضي',
                    icon: Icons.people_outline,
                    isSelected: currentIndex == 4,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'patients'),
                          builder: (context) => const MainLayoutDoctor(initialIndex: 7),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    title: 'الإعدادات',
                    icon: Icons.settings_outlined,
                    isSelected: currentIndex == 5,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'settings'),
                          builder: (context) => SettingsScreen(useDoctorDrawer: true),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    title: 'اخباري',
                    icon: Icons.messenger_rounded,
                    isSelected: currentIndex == 6,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'news'),
                          builder: (context) => const MainLayoutDoctor(initialIndex: 3),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Divider(height: 24.h),
                  ),
                  _menuItem(
                    context,
                    title: 'تسجيل الخروج',
                    icon: Icons.logout_outlined,
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
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
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

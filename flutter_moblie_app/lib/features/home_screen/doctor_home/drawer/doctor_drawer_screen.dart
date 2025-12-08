import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/settings/ui/settings_screen.dart';
/*import 'package:thotha_mobile_app/features/home_screen/doctor_home/drawer/booking_history/ui/doctor_booking_history_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/drawer/settings/ui/doctor_settings_screen.dart';*/
import 'package:thotha_mobile_app/features/login/ui/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

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
                  Navigator.of(context).pop();
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
        Color iconColor = _cCyan,
        Color textColor = Colors.black,
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
              Icon(icon, color: iconColor),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _fetchDoctorName() async {
    setState(() { _isLoadingName = true; });

    try {
      // First, try to get cached values (await because helper is async)
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

      // No cache -> fetch from server
      final dio = DioFactory.getDio();
      Response response;
      try {
        response = await dio.get('/me');
      } catch (_) {
        response = await dio.get('/profile');
      }

      if (response.statusCode == 200) {
        final data = response.data;
        String? f;
        String? l;
        String? e;
        if (data is Map) {
          f = (data['first_name'] ?? data['firstName']) as String?;
          l = (data['last_name'] ?? data['lastName']) as String?;
          e = (data['email'] ?? (data['user']?['email'])) as String?;

          // nested user object fallback
          if ((f == null || f.isEmpty) && data['user'] != null) {
            final user = data['user'];
            f = f ?? (user['first_name'] ?? user['firstName']) as String?;
            l = l ?? (user['last_name'] ?? user['lastName']) as String?;
          }
        }

        setState(() {
          _firstName = f;
          _lastName = l;
          _email = e;
        });

        // Cache values if we got them
        if (f != null && f.isNotEmpty) {
          await SharedPrefHelper.setData('first_name', f);
          await SharedPrefHelper.setData('last_name', l ?? '');
          if (e != null) await SharedPrefHelper.setData('email', e);
        }
      } else {
        setState(() {  });
      }
    } catch (e) {
      setState(() {  });
    } finally {
      setState(() { _isLoadingName = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPad = MediaQuery.of(context).padding.top;
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
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w700,
                            fontSize: 20.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
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
                      color: const Color.fromRGBO(255, 255, 255, 0.25),
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
                              color: Colors.white,
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
                                  // Name: show spinner while loading, otherwise show fetched name or fallback
                                  _isLoadingName
                                      ? SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                      : Text(
                                    _firstName != null
                                        ? 'د/ ${_firstName!} ${_lastName ?? ''}'
                                        : 'د/ أحمد محمود',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    _email != null && _email!.isNotEmpty ? _email! : 'zyadgamal@gmail.com',
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12.sp,
                                      color: Colors.white,
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
                _menuItem(context, title: 'الملف الشخصي', icon: Icons.person_outline),
                _menuItem(
                  context,
                  title: 'الحجوزات القادمة',
                  icon: Icons.event_note_outlined,
                  onTap: () {
                   /* Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyBookingsScreen(),
                      ),*/
                    //);
                  },
                ),
                _menuItem(
                  context,
                  title: 'سجل الحجوزات',
                  icon: Icons.list_alt_rounded,
                  onTap: () {
                    /*Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookingHistoryScreen(),
                      ),
                    );*/
                  },
                ),
                _menuItem(
                  context,
                  title: 'المرضي',
                  icon: Icons.people_outline,
                  onTap: () {
                   // Navigator.pop(context); // Close drawer
                   // Navigator.push(
                      //context,
                     // MaterialPageRoute(
                       // builder: (context) => BrowseServicesScreen(),
                    //  ),
                   // );
                  },
                ),
                _menuItem(
                  context,
                  title: 'الإعدادات',
                  icon: Icons.settings_outlined,
                  onTap: () {Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  SettingsScreen()),
                    );
                  },
                ),
                _menuItem(context, title: ' اخباري', icon: Icons.messenger_rounded),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Divider(height: 24.h),
                ),
                _menuItem(
                  context,
                  title: 'تسجيل الخروج',
                  icon: Icons.logout_outlined,
                  iconColor: Colors.red,
                  textColor: Colors.red,
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
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

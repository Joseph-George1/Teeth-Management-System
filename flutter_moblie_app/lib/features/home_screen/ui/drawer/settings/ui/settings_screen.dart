import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:thotha_mobile_app/core/theming/theme_provider.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // State variables for each toggle
  bool _notificationsEnabled = false;
  bool _receiveOffers = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Doctor name/email state (loaded from cache or server)
  String? _firstName;
  String? _lastName;
  String? _email;
  bool _isLoadingName = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    if (!mounted) return;
    setState(() { _isLoadingName = true; });

    try {
      // Try cache first
      final cachedFirstName = await SharedPrefHelper.getString('first_name');
      final cachedLastName = await SharedPrefHelper.getString('last_name');
      final cachedEmail = await SharedPrefHelper.getString('email');

      if (cachedFirstName != null && cachedFirstName.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _firstName = cachedFirstName;
          _lastName = cachedLastName;
          _email = cachedEmail;
          _isLoadingName = false;
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
        String? f;
        String? l;
        String? e;
        if (data is Map) {
          f = (data['first_name'] ?? data['firstName']) as String?;
          l = (data['last_name'] ?? data['lastName']) as String?;
          e = (data['email'] ?? (data['user']?['email'])) as String?;

          if ((f == null || f.isEmpty) && data['user'] != null) {
            final user = data['user'];
            f = f ?? (user['first_name'] ?? user['firstName']) as String?;
            l = l ?? (user['last_name'] ?? user['lastName']) as String?;
          }
        }

        if (!mounted) return;
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
    } catch (e) {
      // ignore errors, fall back to defaults
    } finally {
      if (!mounted) return;
      setState(() { _isLoadingName = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const Drawer(
        child: HomeDrawer(),
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false, // Disable default back button
        title: Container(
          width: double.infinity,
          height: 50,
          child: Stack(
            children: [
              // Menu icon on the left
              Positioned(
                left: 0,
                child: IconButton(
                  icon: const Icon(
                    Icons.menu,
                    color: Colors.black,
                    size: 40,
                    weight: 700, // Bold weight
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
              // Logo centered
              Positioned(
                right: 30,
                child: Image.asset(
                  'assets/images/splash-logo.png',
                  width: 46,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // User greeting container
          Container(
            width: 400,
            height:95,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.only(top: 15),
            child: Stack(
              children: [
                // Notification icon (left side)
                Positioned(
                  left: 20,
                  child: Container(
                    width: 70,
                    height: 050.99,
                    alignment: Alignment.centerLeft,
                    child: const Icon(
                      Icons.notifications_none,
                      size: 30,
                      color: Colors.black,
                    ),
                  ),
                ),

                // User name and greeting (right side)
                Positioned(
                  right: 0,
                  top: -4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Greeting
                      const Text(
                        'مرحباً، أهلاً بعودتك',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.4,
                          color: Color(0xFF858585),
                        ),
                      ),
                      // Name (dynamic)
                      _isLoadingName
                          ? SizedBox(
                              width: 16,
                              height: 20,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF858585),
                              ),
                            )
                          : Text(
                              _firstName != null
                                  ? 'د/ ${_firstName!} ${_lastName ?? ''}'
                                  : '*****',
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                fontSize: 22,
                                height: 1.5,
                                letterSpacing: 0.1,
                                color: Color(0xFF101828),
                              ),
                            ),
                      SizedBox(height: 2),
                      Text(
                        _email != null && _email!.isNotEmpty ? _email! : 'zyadgamal@gmail.com',
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Color(0xFF858585),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Container (new separate container)
          Container(
            width: 377.23,
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF021433),
                width: 0.25,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  ' ابحث عن ',
                  style: TextStyle(
                    color: Color(0xFF021433),
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 17,
                  height: 17,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.search,
                    size: 12,
                    color: Color(0x70111827), // #111827 with 70% opacity
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),

          // Main Settings Container
          Container(
            width: 414,
            padding: const EdgeInsets.only(
              top: 23.99,
              left: 20,
              right: 20,
            ),
            color: Colors.white,
            child: Column(
              children: [
                // Settings Header
                Container(
                  width: 374.01,
                  height: 42,
                  color: Colors.white,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Text(
                    'الإعدادات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      height: 1.5,
                      color: Color(0xFF0A0A0A),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(height: 23.99),

                // Main Content Container
                Container(
                  width: 374.01,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Notifications Toggle
                      Container(
                        width: double.infinity,
                        height: 49.0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -0.29),
                              child: SizedBox(
                                width: 53,
                                height: 24,
                                child: Transform.scale(
                                  scale: 1.0,
                                  child: Switch.adaptive(
                                    value: _notificationsEnabled,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _notificationsEnabled = value;
                                      });
                                      // Add any additional logic here (e.g., save to preferences)
                                    },
                                    activeColor: const Color(0xFF8DECB8),
                                    activeTrackColor: const Color(0xFF8DECB8),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: const Color(0xFFE5E7EB),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    thumbColor: MaterialStateProperty.all(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'الإشعارات',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0A0A0A),
                                height: 1.5, // 24/16 = 1.5 line height
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Receive Offers Toggle
                      Container(
                        width: double.infinity,
                        height: 49.0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Transform.translate(
                              offset: const Offset(0, -0.29),
                              child: SizedBox(
                                width: 53,
                                height: 24,
                                child: Transform.scale(
                                  scale: 1.0,
                                  child: Switch(
                                    value: _receiveOffers,
                                    onChanged: (bool value) {
                                      setState(() {
                                        _receiveOffers = value;
                                      });
                                      // Add any additional logic here (e.g., save to preferences)
                                    },
                                    activeColor: const Color(0xFF8DECB8),
                                    activeTrackColor: const Color(0xFF8DECB8),
                                    inactiveThumbColor: Colors.white,
                                    inactiveTrackColor: const Color(0xFFE5E7EB),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    thumbColor: MaterialStateProperty.all(Colors.white),
                                  ),
                                ),
                              ),
                            ),
                            const Text(
                              'تلقي العروض',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0A0A0A),
                                height: 1.5, // 24/16 = 1.5 line height
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Dark Mode Toggle
                      Container(
                        width: double.infinity,
                        height: 49.0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Consumer<ThemeProvider>(
                              builder: (context, themeProvider, _) {
                                return Transform.translate(
                                  offset: const Offset(0, -0.29),
                                  child: SizedBox(
                                    width: 53,
                                    height: 24,
                                    child: Transform.scale(
                                      scale: 1.0,
                                      child: Switch(
                                        value: themeProvider.isDarkMode,
                                        onChanged: (bool value) {
                                          themeProvider.toggleTheme(value);
                                        },
                                        activeColor: const Color(0xFF8DECB8),
                                        activeTrackColor: const Color(0xFF8DECB8),
                                        inactiveThumbColor: Colors.white,
                                        inactiveTrackColor: const Color(0xFFE5E7EB),
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        thumbColor: MaterialStateProperty.all(Colors.white),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const Text(
                              'الوضع الداكن',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF0A0A0A),
                                height: 1.5, // 24/16 = 1.5 line height
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Change Password Button
                      GestureDetector(
                        onTap: () {
                          // Add your onTap logic here
                          print('Change Password button tapped');
                        },
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 302.97,
                            height: 47.99,
                            margin: const EdgeInsets.only(top: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 0,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 96.69, vertical: 11.99),
                            child: const Text(
                              'تغير كلمة المرور',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                height: 1.5,
                                color: Color(0xFF364153),
                                letterSpacing: 0,
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
        ],
      ),
    );

  }
}

// Navigation extension to easily navigate to settings
extension SettingsNavigation on BuildContext {
  void navigateToSettings() {
    Navigator.push(
      this,
      MaterialPageRoute(builder: (context) =>  SettingsScreen()),
    );
  }
}

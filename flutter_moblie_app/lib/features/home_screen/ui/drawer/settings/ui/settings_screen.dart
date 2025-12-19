/*
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/core/theming/theme_provider.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/drawer/doctor_drawer_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';

import '../../../../../../core/theming/colors.dart';
import 'package:thotha_mobile_app/core/routing/routes.dart';

class SettingsScreen extends StatefulWidget {
  /// If true, the screen will show the Doctor drawer when opening the menu.
  final bool useDoctorDrawer;

  const SettingsScreen({super.key, this.useDoctorDrawer = false});

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
    setState(() {
      _isLoadingName = true;
    });

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
      setState(() {
        _isLoadingName = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        // Show the drawer based on where Settings was opened from
        drawer: widget.useDoctorDrawer
            ? const Drawer(child: DoctorDrawer())
            : const Drawer(child: HomeDrawer()),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          // Disable default back button
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
                      size: 30,
                      weight: 700, // Bold weight
                    ),
                    onPressed: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
                // Logo centered
                Center(
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
        body: Column(children: [
          // Main Settings Container
          Column(
            children: [
              // Settings Header
              Container(
                color: Colors.white,
                alignment: Alignment.center,
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
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  thumbColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            'الإشعارات',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                            width: 1.5,
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
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  thumbColor:
                                      MaterialStateProperty.all(Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const Text(
                            'تلقي العروض',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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
                            builder: (context, themeProvider, child) {
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
                                      inactiveTrackColor:
                                          const Color(0xFFE5E7EB),
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      thumbColor: MaterialStateProperty.all(
                                          Colors.white),
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
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0A0A0A),
                              height: 1.5, // 24/16 = 1.5 line height
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14),

                    // Change Password Button
                    // Password change functionality removed as requested
                  ],
                ),
              ),
            ],
          )
        ]));
  }
}
*/

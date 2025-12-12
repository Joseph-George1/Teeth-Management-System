import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thotha_mobile_app/core/theming/theme_provider.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:thotha_mobile_app/core/theming/colors.dart';

class HomeSettingsScreen extends StatefulWidget {
  const HomeSettingsScreen({super.key});

  @override
  State<HomeSettingsScreen> createState() => _HomeSettingsScreenState();
}

class _HomeSettingsScreenState extends State<HomeSettingsScreen> {
  // State variables for each toggle
  bool _notificationsEnabled = false;
  bool _receiveOffers = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      drawer: const HomeDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
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
                    weight: 700,
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
      body: Column(
        children: [
          // Main Settings Container
          Column(
            children: [
              // Settings Header
              Container(
                color: Colors.white,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 20, top: 20),
                child: const Text(
                  'إعدادات المستخدم',
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
                margin: const EdgeInsets.symmetric(horizontal: 20),
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
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

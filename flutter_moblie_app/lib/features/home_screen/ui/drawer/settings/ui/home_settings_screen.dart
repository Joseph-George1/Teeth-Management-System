import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thotha_mobile_app/core/theming/theme_provider.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:thotha_mobile_app/features/terms_and_conditions/ui/terms_and_conditions_screen.dart';

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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const HomeDrawer(),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.scaffoldBackgroundColor,
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
                color: Colors.transparent,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 20, top: 20),
                child: Text(
                  'إعدادات المستخدم',
                  style: textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    height: 1.5,
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
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
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
                                      activeTrackColor: const Color(0xFF8DECB8),
                                      inactiveThumbColor: Colors.white,
                                      inactiveTrackColor: theme.dividerColor,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      thumbColor: WidgetStateProperty.all(
                                          Colors.white),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Text(
                            'الوضع الداكن',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textTheme.bodyLarge?.color,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Terms and Conditions
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TermsAndConditionsScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 49.0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.arrow_back_ios,
                              size: 16,
                              color: textTheme.bodyLarge?.color,
                            ),
                            const Spacer(),
                            Text(
                              'الشروط والأحكام',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textTheme.bodyLarge?.color,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
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

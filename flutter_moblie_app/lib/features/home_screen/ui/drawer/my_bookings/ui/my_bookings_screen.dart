import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/settings/ui/settings_screen.dart';



class MyBookingsScreen extends StatelessWidget {
   MyBookingsScreen({super.key});
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const Drawer(
        child: HomeDrawer(),
      ),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
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
                  icon: Icon(
                    Icons.menu,
                    color: theme.iconTheme.color,
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
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.only(top: 15),
            child: Stack(
              children: [
                // Notification icon (left side)
                Positioned(
                  left: 20,
                  child: Container(
                    width: 70,
                    height: 39.99,
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.notifications_none,
                      size: 30,
                      color: theme.iconTheme.color,
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
                      Text(
                        'مرحباً، أهلاً بعودتك',
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.4,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                      // Name
                      Text(
                        'يوسف ايمن',
                        textDirection: TextDirection.rtl,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          height: 1.5,
                          letterSpacing: 0.1,
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
                color: isDark ? Colors.grey[700]! : const Color(0xFF021433),
                width: 0.25,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  ' ابحث عن ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Cairo',
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 17,
                  height: 17,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.search,
                    size: 12,
                    color: theme.iconTheme.color?.withOpacity(0.7), // #111827 with 70% opacity
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ),
        Container(
            width: 414,
            height: 650,
            padding: const EdgeInsets.only(top: 15, left: 20, right:15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
              // Header
              Container(
              width: 374,
              height: 42,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
              ),
              child: Text(
                'حجوزاتي القادمه',
                textAlign: TextAlign.right,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  height: 1.5,
                ),
              ),
            ),

          Container(
            width: 373.01,
            height: 175.97,
            margin: const EdgeInsets.symmetric(vertical: 11.99),
            padding: const EdgeInsets.only(
              top: 23.99,
              right: 20,
              left: 20,
            ),
            decoration: BoxDecoration(
              color: theme.cardTheme.color ?? colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            // ... rest of your existing Stack children
            child: Stack(
              children: [
                // Left Container - Adjusted for better layout
                Positioned(
                  right: 90,
                  top: -10,
                  child: SizedBox(
                    width: 333.80426025390625,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 80.99864196777344,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 26.99,
                                alignment: Alignment.centerRight,
                                child: const Text(
                                  'زياد جمال ',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    height: 1.5,
                                    color: Color(0xFF0A0A0A),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                width: double.infinity,
                                height: 21.0,
                                alignment: Alignment.centerRight,
                                child: const Text(
                                  'تدريب زراعة اسنان',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.5,
                                    color: Color(0xFF858585),
                                  ),
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                height: 21.0,
                                margin: const EdgeInsets.only(top: 5.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '11:30 صباحا',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.5,
                                            color: Color(0xFF6A7282),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.access_time,
                                          size: 16,
                                          color: Color(0xFF6A7282),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 24),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '2025-11-29',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.5,
                                            color: Color(0xFF6A7282),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.calendar_month,
                                          size: 16,
                                          color: Color(0xFF6A7282),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Image Container - Adjusted position
                Positioned(
                  right: 10,
                  top: 0,
                  child: Opacity(
                    opacity: 0.8,
                    child: Container(
                      width: 78.99,
                      height: 79.99,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/test.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                // Buttons - independent from info container
                Positioned(
                  bottom: 19,
                  child: SizedBox(
                    width: 331.80426025390625,
                    height: 36.99217987060547,
                    child: Row(
                      textDirection: TextDirection.ltr,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 162.90621948242188,
                          height: 36.99217987060547,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add edit action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEFF6FF),
                              foregroundColor: const Color(0xFF155DFC),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: const BorderSide(color: Color(0xFF155DFC)),
                              ),
                              padding: const EdgeInsets.only(

                                right: 60.64,
                                left: 66.62,
                              ),
                            ),
                            child: const Text(
                              'تعديل',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w400,
                                height: 21 / 14,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 160.90621948242188,
                          height: 36.99217987060547,
                          child: ElevatedButton(
                            onPressed: () {
                              // Add cancel action
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFEF2F2),
                              foregroundColor: const Color(0xFFE7000B),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: const BorderSide(color: Color(0xFFE7000B)),
                              ),
                              padding: const EdgeInsets.only(

                                right: 60.33,
                                left: 67.31,
                              ),
                            ),
                            child: const Text(
                              'إلغاء',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w400,
                                height: 21 / 14,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

            ])
        )
    ])

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

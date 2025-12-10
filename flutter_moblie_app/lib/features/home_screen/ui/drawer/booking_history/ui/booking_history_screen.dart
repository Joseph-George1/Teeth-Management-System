
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/settings/ui/settings_screen.dart';

class BookingHistoryScreen extends StatelessWidget {
   BookingHistoryScreen({super.key});
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
                  icon: Icon(
                    Icons.menu,
                    color: theme.iconTheme.color,
                    size: 40,
                    weight: 700,
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

          // New Container
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
                    'تاريخ الحجوزات',
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
                  width: 373.8,
                  height: 142.0,
                  margin: const EdgeInsets.only(top: 15),
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
                                  'د/كريستيانو رونالدو',
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4), // Small spacing between the name and specialty
                              Container(
                                width: 200,
                                height: 21.0,
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'تدريب تقويم الأسنان',
                                  textAlign: TextAlign.right,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.5,
                                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                  ),
                                ),
                              ),
                              Container(
                                width: 232.86,  // Width as specified
                                height: 42.02,  // Height as specified
                                margin: const EdgeInsets.only(top: 7.99),  // Gap as specified
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Status Badge (Green) - Right side in RTL
                                    Container(
                                      width: 65,
                                      height: 26.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: isDark ? Colors.green.withOpacity(0.2) : const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'مكتمل',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          height: 1.5,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),

                                    // Time Container - Center
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '1:00',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.5,
                                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                          ),
                                        ),
                                        Text(
                                          'صباحاً',
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            height: 1.5,
                                            color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Date Container - Left side in RTL
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '2025-11-25',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.5,
                                            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.calendar_month,
                                          size: 16,
                                          color: theme.iconTheme.color?.withOpacity(0.7),
                                        ),
                                      ],
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
                                image: AssetImage('assets/images/dr.cr7.jpg'),
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
                  height: 142.0,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                                child: const Text(
                                  'د/ليونيل ميسي',
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
                              const SizedBox(height: 4), // Small spacing between the name and specialty
                              Container(
                                width: 200,
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
                                width: 232.86,  // Width as specified
                                height: 42.02,  // Height as specified
                                margin: const EdgeInsets.only(top: 7.99),  // Gap as specified
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Status Badge (Green) - Right side in RTL
                                    Container(
                                      width: 65,
                                      height: 26.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDAF02),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'قيد الانتظار',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          height: 1.5,
                                          color: Color(0xFFF6F082), // Changed to red
                                        ),
                                      ),
                                    ),

                                    // Time Container - Center
                                    const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '11:50',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.5,
                                            color: Color(0xFF6A7282),
                                          ),
                                        ),
                                        Text(
                                          'صباحاً',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            height: 1.5,
                                            color: Color(0xFF6A7282),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Date Container - Left side in RTL
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
                                        const SizedBox(width: 8),
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
                                image: AssetImage('assets/images/lm10.jpg'),
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
                  height: 142.0,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                                child: const Text(
                                  'د/زيدان',
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
                              const SizedBox(height: 4), // Small spacing between the name and specialty
                              Container(
                                width: 200,
                                height: 21.0,
                                alignment: Alignment.centerRight,
                                child: const Text(
                                  'تدريب تبيض الأسنان',
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
                                width: 232.86,  // Width as specified
                                height: 42.02,  // Height as specified
                                margin: const EdgeInsets.only(top: 7.99),  // Gap as specified
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Status Badge (Green) - Right side in RTL
                                    Container(
                                      width: 65,
                                      height: 26.0,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFDA3A3),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'غير مكتمل',
                                        style: TextStyle(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                          height: 1.5,
                                          color: Color(0xFFFF0000),
                                        ),
                                      ),
                                    ),

                                    // Time Container - Center
                                    const Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '13:00',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.5,
                                            color: Color(0xFF6A7282),
                                          ),
                                        ),
                                        Text(
                                          'ظهراً',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12,
                                            height: 1.5,
                                            color: Color(0xFF6A7282),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Date Container - Left side in RTL
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          '2026-1-1',
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                            height: 1.5,
                                            color: Color(0xFF6A7282),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
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
                                image: AssetImage('assets/images/zezo.jpg'),
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
      ]),
    );
  }

  // Helper method to create info rows
  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
// ... rest of the code ...



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

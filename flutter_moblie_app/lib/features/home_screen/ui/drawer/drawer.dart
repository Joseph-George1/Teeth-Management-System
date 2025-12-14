import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/browse_services/ui/browse_services_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/settings/ui/home_settings_screen.dart' show HomeSettingsScreen;
import 'package:thotha_mobile_app/features/terms_and_conditions/ui/terms_and_conditions_screen.dart';
import 'package:thotha_mobile_app/features/help_and_support/ui/help_and_support_screen.dart';

import '../../../../core/theming/colors.dart';


class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

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
                        fontWeight: FontWeight.bold,
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
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: topPad + 180.h,
            padding: EdgeInsets.only(top: topPad),

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
                                fontWeight: FontWeight.bold,
                                fontSize: 20.sp,
                                color: colorScheme.onPrimary,
                              ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.black,size: 30,),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Image
                      Image.asset(
                        'assets/images/splash-logo.png',
                        width: 77.w,
                        height: 77.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 16.h),
                      // Title Text
                      Text(
                        'رعاية ذكية، لمسة طبية',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: ColorsManager.fontColor,
                          fontFamily: 'Cairo',
                        ),
                      ),
                    ],
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
                  title: 'الصفحة الرئيسية',
                  icon: Icons.home_outlined,
                  onTap: () {
                    // اقفل الدروار وارجع لأول صفحة (الهوم)
                    Navigator.pop(context); // Close drawer
                    Navigator.of(context).popUntil((route) => route.isFirst);
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
                      MaterialPageRoute(builder: (context) => const HomeSettingsScreen()),
                    );
                  },
                ),
                _menuItem(
                  context,
                  title: 'الشروط والأحكام',
                  icon: Icons.description_outlined,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsAndConditionsScreen(),
                      ),
                    );
                  },
                ),
                _menuItem(
                  context,
                  title: 'المساعدة والدعم',
                  icon: Icons.help_outline,
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpAndSupportScreen(),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Divider(height: 24.h),
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
                      fontWeight: FontWeight.bold,
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

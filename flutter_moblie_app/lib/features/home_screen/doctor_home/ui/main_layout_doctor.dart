import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/doctor_news_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/doctor_next_booking_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/patient_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/ui/doctor_booking_records_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/ui/doctor_profile.dart';

import 'doctor_home_screen.dart';


class MainLayoutDoctor extends StatefulWidget {
  final int initialIndex;

  const MainLayoutDoctor({super.key, this.initialIndex = 0});

  @override
  State<MainLayoutDoctor> createState() => _MainLayoutDoctorState();
}

class _MainLayoutDoctorState extends State<MainLayoutDoctor> {
  late int _currentIndex;
  late final List<Widget> _screens;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const DoctorHomeScreen(),
      DoctorNextBookingScreen(),
      DoctorBookingRecordsScreen(),
      DoctorNewsScreen(),
      const DoctorProfile(),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Container(
        color: colorScheme.surface,
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: _screens,
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withAlpha(
                  isDark ? (0.4 * 255).round() : (0.12 * 255).round()),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
        Flexible(
        child: _buildNavItem(
        icon: Icons.home_sharp,
          activeIcon: Icons.home_sharp,
          label: 'الرئيسية',
          isActive: _currentIndex == 0,
          onTap: () => _onItemTapped(0),
        ),),
            Flexible(
              child: _buildNavItem(
                icon: Icons.calendar_today,
                activeIcon: Icons.calendar_today,
                label: 'الحجوزات القادمة',
                isActive: _currentIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
            ),
            Flexible(
              child: _buildNavItem(
                icon: Icons.list_alt_rounded,
                activeIcon: Icons.list_alt_rounded,
                label: 'سجل الحجوزات',
                isActive: _currentIndex == 2,
                onTap: () => _onItemTapped(2),
              ),


            ), Flexible(
              child: _buildNavItem(
                icon: Icons.messenger_outline,
                activeIcon: Icons.messenger_outline,
                label: 'اخباري',
                isActive: _currentIndex == 4,
                onTap: () => _onItemTapped(4),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    IconData? activeIcon,
  }) {
    // All icons same size
    final double iconSize = 25.w;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            transform: Matrix4.translationValues(0, isActive ? -10.h : 0, 0),
            padding: EdgeInsets.symmetric(
                horizontal: 12.w, vertical: isActive ? 8.h : 4.h),
            decoration: BoxDecoration(
              color: isActive ? Theme
                  .of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: isActive
                  ? [
                BoxShadow(
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primary
                      .withAlpha((0.12 * 255).round()),
                  blurRadius: 8,
                  offset: const Offset(0, 6),
                )
              ]
                  : null,
            ),
            child: Icon(
              isActive && activeIcon != null ? activeIcon : icon,
              size: iconSize,
              color: isActive
                  ? Theme
                  .of(context)
                  .colorScheme
                  .primary
                  : Theme
                  .of(context)
                  .colorScheme
                  .onSurfaceVariant,
            ),
          ),
          SizedBox(height: 0.h),
          // Label: visible only when active (fade animation)
          AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: isActive ?1.0 : 1.0,
            child: Text(
              label,
              style: Theme
                  .of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(
                fontFamily: 'Cairo',
                color: isActive
                    ? Theme
                    .of(context)
                    .colorScheme
                    .primary
                    : Theme
                    .of(context)
                    .colorScheme
                    .onSurfaceVariant,
                fontSize: 11.sp,
                fontWeight: isActive ? FontWeight.w400 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }


}
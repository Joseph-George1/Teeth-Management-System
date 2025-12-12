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
      const DoctorHomeScreen(), // 0 - Home
      DoctorNextBookingScreen(), // 1 - Upcoming Bookings
      DoctorBookingRecordsScreen(), // 2 - Booking Records
       DoctorNewsScreen(), // 3 - News
      DoctorProfile(), //4 -profile
    ];
    
    // Ensure initialIndex is within bounds
    if (_currentIndex >= _screens.length) {
      _currentIndex = 0;
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;
    
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
        height: 70.h,
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(
                icon: Icons.home_sharp,
                activeIcon: Icons.home_rounded,
                label: 'الرئيسية',
                isActive: _currentIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
              _buildNavItem(
                icon: Icons.calendar_today_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: 'الحجوزات',
                isActive: _currentIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
              _buildNavItem(
                icon: Icons.list_alt_outlined,
                activeIcon: Icons.list_alt_rounded,
                label: 'السجل',
                isActive: _currentIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              _buildNavItem(
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                label: 'اخباري',
                isActive: _currentIndex == 3,
                onTap: () => _onItemTapped(3),
              ),_buildNavItem(
                icon: Icons.person,
                activeIcon: Icons.person,
                label: 'الملف',
                isActive: _currentIndex == 4,
                onTap: () => _onItemTapped(4),
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconSize = 24.w;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.onSurfaceVariant.withOpacity(0.8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: activeColor.withOpacity(0.1),
        highlightColor: activeColor.withOpacity(0.05),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: isActive ? activeColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  isActive && activeIcon != null ? activeIcon : icon,
                  size: iconSize,
                  color: isActive ? activeColor : inactiveColor,
                ),
              ),
              SizedBox(height: 4.h),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: theme.textTheme.labelSmall!.copyWith(
                  fontFamily: 'Cairo',
                  fontSize: 10.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : inactiveColor,
                  height: 1.2,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  
  }
}
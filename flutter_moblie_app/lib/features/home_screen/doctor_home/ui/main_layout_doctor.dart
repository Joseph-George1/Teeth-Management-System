import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            Flexible(
              child: _buildNavItem(
                isActive: _currentIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
            ),
            Flexible(
              child: _buildNavItem(
                isActive: _currentIndex == 2,
                onTap: () => _onItemTapped(2),
              ),
              child: _buildNavItem(
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
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
              isActive && activeIcon != null ? activeIcon : icon,
              color: isActive
            ),
              label,
                fontFamily: 'Cairo',
                color: isActive
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
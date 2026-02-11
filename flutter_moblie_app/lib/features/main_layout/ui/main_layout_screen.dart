import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/routing/routes.dart';
import '../../../features/chat/ui/chat_screen.dart';
import '../../home_screen/ui/home_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  final int initialIndex;

  const MainLayoutScreen({super.key, this.initialIndex = 0});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int _currentIndex;
  late final List<Widget> _screens;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _screens = [
      const HomeScreen(),
      const ChatScreen(),
      //const Placeholder(child: Center(child: Text('صفحة الملف الشخصي'))),
      // For profile screen (index 3)
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      // Profile button index is 2
      // Navigate to login screen and remove all previous routes
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.loginScreen,
        (route) => false,
      );
    } else {
      setState(() {
        _currentIndex = index;
        _pageController.jumpToPage(index);
      });
    }
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
              color: colorScheme.shadow.withValues(alpha: isDark ? 0.4 : 0.12),
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
                label: 'الصفحة الرئيسية',
                isActive: _currentIndex == 0,
                onTap: () => _onItemTapped(0),
              ),
            ),
            Flexible(
              child: _buildSvgNavItem(
                iconPath: 'assets/svg/ثوثه الدكتور 1.svg',
                label: 'ثوثة المساعد',
                isActive: _currentIndex == 1,
                onTap: () => _onItemTapped(1),
              ),
            ),
            Flexible(
              child: _buildNavItem(
                icon : Icons.person,
                activeIcon: Icons.person,
                label: 'الملف',
                isActive: _currentIndex == 2,
                onTap: () => _onItemTapped(2),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        splashColor: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.12),
        highlightColor: Theme.of(context)
            .colorScheme
            .onSurface
            .withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.15 : 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: const BoxDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive && activeIcon != null ? activeIcon : icon,
                color: isActive
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24.w,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontFamily: 'Cairo',
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11.sp,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSvgNavItem({
    required String iconPath,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            iconPath,
            width: 24.w,
            height: 24.w,
            // Removed colorFilter to maintain original SVG colors
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontFamily: 'Cairo',
                  color: isActive
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ],
      ),
    );
  }
}

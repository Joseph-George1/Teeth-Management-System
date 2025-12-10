import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/drawer/doctor_drawer_screen.dart';

class DoctorNewsScreen extends StatelessWidget {
  DoctorNewsScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const Drawer(
        width: 300,
        child: DoctorDrawer(),
      ),
      appBar: AppBar(
        toolbarHeight: 75.6,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: true,
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 37.w,
              height: 40.h,
              child: Image.asset(
                'assets/images/splash-logo.png',
                width: 37.w,
                height: 40.h,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 8.w),
            SizedBox(
              width: 92.w,
              height: 27.h,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'لوحة التحكم',
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_none, size: 24.w),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 10,
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onError,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.1),
          child: Container(
            height: 1.1,
            color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
          ),
        ),
      ),
      body: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Text('Main Content Here'),
    );
  }
}
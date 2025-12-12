// filepath: c:\projects\Teeth-Management-System.git\flutter_moblie_app\lib\features\home_screen\doctor_home\doctor_next_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/drawer/doctor_drawer_screen.dart';
import 'package:thotha_mobile_app/features/notifications/ui/notifications_screen.dart';

class DoctorNextBookingScreen extends StatelessWidget {
  DoctorNextBookingScreen({super.key});

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
      drawer: const DoctorDrawer(),
      appBar: AppBar(
        toolbarHeight: 75.6,
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, size: 24.w),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
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
      body: _buildMainContent(context),
    );
  }

  Widget _buildBookingCard({
    required BuildContext context,
    required String patientName,
    required String service,
    required String time,
    required String date,
    required String status,
    required Color statusColor,
    required String profileImage,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha((0.3 * 255).round())
                : Colors.grey.withAlpha((0.08 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status and Info Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Status and Info Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // Patient Info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              patientName,
                              textAlign: TextAlign.right,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontFamily: 'Cairo',
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service,
                              textAlign: TextAlign.right,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Cairo',
                                color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      time,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  children: [
                                    Text(
                                      date,
                                      style: theme.textTheme.bodySmall,
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.calendar_month,
                                      size: 16,
                                      color: colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Patient Image
                    Container(
                      width: 60,
                      height: 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(profileImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(


                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEF2F2),
                          foregroundColor: const Color(0xFFE7000B),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(
                              color: Color(0xFFE7000B),
                            ),
                          ),
                        ),
                        child: const Text(
                          'إلغاء',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ), SizedBox(width: 8.w),
                      Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEFF6FF),
                          foregroundColor: const Color(0xFF155DFC),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: const BorderSide(
                              color: Color(0xFF155DFC),
                            ),
                          ),
                        ),
                        child: const Text(
                          'تعديل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )]) );
        }

      Widget _buildMainContent(BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'حجوزاتي القادمة',
                  textAlign: TextAlign.right,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 1.5,
                  ),
                ),
              ),

              // Booking Card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color ?? colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withAlpha((0.3 * 255).round()) : Colors.grey.withAlpha((0.08 * 255).round()),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // First Booking Card
                    _buildBookingCard(
                      context: context,
                      patientName: 'زياد جمال',
                      service: 'تقويم اسنان',
                      time: '11:30 صباحا',
                      date: '2025-11-29',
                      status: 'قادم',
                      statusColor: const Color(0xFF84E5F3),
                      profileImage: 'assets/images/zozjpg.jpg',
                    ),
                    SizedBox(height: 8.h),

                    // Second Booking Card
                    _buildBookingCard(
                      context: context,
                      patientName: 'عبدالحليم رمضان',
                      service: 'حشو عصب',
                      time: '02:45 مساءً',
                      date: '2025-11-30',
                      status: 'قادم',
                      statusColor: const Color(0xFF84E5F3),
                      profileImage: 'assets/images/halim.jpg',
                    ),
                    SizedBox(height: 16.h),

                    // Third Booking Card
                    _buildBookingCard(
                      context: context,
                      patientName: 'محمد اشرف',
                      service: 'تنظيف أسنان',
                      time: '10:15 صباحا',
                      date: '2025-12-01',
                      status: 'قادم',
                      statusColor: const Color(0xFF84E5F3),
                      profileImage: 'assets/images/kateb.jpg',
                    ),
                    SizedBox(height: 16.h),

                    // Fourth Booking Card
                    _buildBookingCard(
                      context: context,
                      patientName: 'جوزيف جورح',
                      service: 'تركيب كوبري',
                      time: '04:30 مساءً',
                      date: '2025-12-02',
                      status: 'قادم',
                      statusColor: const Color(0xFF84E5F3),
                      profileImage: 'assets/images/joseoh.jpeg',
                    ),
                  ],
                ),
              ),

              // Add some bottom padding
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      }
    }

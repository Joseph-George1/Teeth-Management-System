import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          gradient: const LinearGradient(
            colors: [Color(0xFF84E5F3), Color(0xFF8DECB4)],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          width: 25.w,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ],
      showingTooltipIndicators: [0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            width: 430.w,  // Close to the specified 429.99
            height: 75.6.h,
            padding: EdgeInsets.only(
              top: 15.98.h,
              right: 20.w,
              bottom: 1.1.h,
              left: 20.w,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF), // #FFFFFF
              border: Border(
                bottom: BorderSide(
                  width: 1.1,
                  color: Color(0xFFE5E7EB), // #E5E7EB
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Menu Button
                IconButton(
                  icon: Icon(Icons.menu, size: 24.w, color: Colors.black87),
                  onPressed: () {},
                ),

                // Logo with Text
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 37.w,  // 36.99px
                      height: 40.h, // 39.99px
                      child: Image.asset(
                        'assets/images/splash-logo.png',
                        width: 37.w,
                        height: 40.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 92.w,
                      height: 27.h,
                      alignment: Alignment.center,
                      child: Text(
                        'لوحة التحكم',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600, // SemiBold
                          height: 1.5, // line-height: 27px / 18px = 1.5
                          color: const Color(0xFF101828),
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),

                // Notification Icon with Badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(Icons.notifications_none, size: 24.w, color: Colors.black87),
                      onPressed: () {},
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Welcome Container
          Container(
            width: 390.w,
            height: 70.47.h,
            margin: EdgeInsets.only(top: 0.h, right: 10.w, left: 20.w),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Welcome Text
                Container(
                  width: 220.w,
                  height: 36.h,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'مرحباً، د. أحمد محمود',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700, // Bold
                      height: 1.5, // 36px line height
                      color: const Color(0xFF101828),
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                SizedBox(height: 5.99.h), // Gap between texts
                // Subtitle
                Container(
                  width: 217.w,
                  height: 20.h,
                  alignment: Alignment.centerRight,
                  child: Text(
                    'إليك نظرة عامة على حجوزاتك وأدائك',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w400, // Regular
                      height: 1.5, // 22.5px line height
                      color: const Color(0xFF858585),
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Grid Container with 4 cards
          Container(
            width: 390.w,
            height: 246.8.h,
            margin: EdgeInsets.only(top: 0.h, left: 20.w, right: 20.w),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 187 / 105.66,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                // First Card - Total Patients
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 1),
                        blurRadius: 1,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 77,
                              height: 30,
                              alignment: Alignment.center,
                              child: Text(
                                'الحجوزات اليوم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                  height: 1.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                                // maxLines: 1,
                                //overflow: TextOverflow.visible,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '28',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE3F5FF
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.people_outline,
                          color: Color(0xFF040400),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                // Second Card - Appointments
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 1),
                        blurRadius: 1,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 77,
                              height: 30,
                              alignment: Alignment.center,
                              child: Text(
                                'الحجوزات اليوم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  color: const Color(0xFF6B7280),
                                  height: 1.0,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.center,
                               // maxLines: 1,
                               //overflow: TextOverflow.visible,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '28',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                                height: 1.1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3CD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Color(0xFF040400),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Third Card - Today's Appointments
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 1),
                        blurRadius: 1,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'الحجوزات المكتملة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: const Color(0xFF6B7280),
                                height: 1.0,
                                fontWeight: FontWeight.w400,
                              ),
                             // maxLines: 1,
                            //  overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '20',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8F5E9),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Container(
                            width: 52.w,
                            height: 52.h,
                            decoration: const BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check_circle_outline_sharp,
                                color: Colors.black,
                                size: 18.sp,
                              ),
                            ),

                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Fourth Card - Available Time
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFFE5E7EB),
                      width: 1.1,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 1),
                        blurRadius: 3,
                        spreadRadius: 0,
                      ),
                      BoxShadow(
                        color: Color(0x1A000000),
                        offset: Offset(0, 1),
                        blurRadius: 1,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'التقييم',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              color: const Color(0xFF6B7280),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 4.h),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '4.8',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF111827),
                                height: 1.2,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 52.w,
                        height: 52.h,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF3CD),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.star_border,
                          color: Color(0xFF040400),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Additional Blue Stat Card
          Container(
            width: 390.w,
            height: 305.66.h,
            margin: EdgeInsets.only(top: 12.h, left: 20.w, right: 20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1.1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 1),
                  blurRadius: 3,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 1),
                  blurRadius: 1,
                  spreadRadius: -1,
                ),
              ],
            ),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.only(right: 12.w, top: 12.h, bottom: 16.h),
                  child: Text(
                    'الحجوزات الأسبوعية',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                      height: 1.5,
                      color: const Color(0xFF101828),
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                // Replace the "// Add your content below the header here" comment with this code
                Expanded(
                  child: Container(
                    width: 347.82.w,
                    height: 220.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1.1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(12.0.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(height: 16),
                          // Chart
                          Expanded(
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 20,
                                minY: 0,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const days = ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8.0),
                                          child: Text(
                                            days[value.toInt()],
                                            style: TextStyle(
                                              color: const Color(0xFF858585),
                                              fontSize: 10.sp,
                                              fontFamily: 'Inter',
                                            ),
                                          ),
                                        );
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value == 0 || value == 5 || value == 10 || value == 15 || value == 20) {
                                          return Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color: const Color(0xFF858585),
                                              fontSize: 10.sp,
                                              fontFamily: 'Inter',
                                            ),
                                          );
                                        }
                                        return const SizedBox();
                                      },
                                      reservedSize: 30,
                                    ),
                                  ),
                                  rightTitles: const AxisTitles(),
                                  topTitles: const AxisTitles(),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 5,
                                  getDrawingHorizontalLine: (value) {
                                    // Only show dashed lines at specific y-values (0, 5, 10, 15, 20)
                                    if ([0.0, 5.0, 10.0, 15.0, 20.0].contains(value)) {
                                      return FlLine(
                                        color: const Color(0xFFF0F0F0),
                                        strokeWidth: 1.0,
                                        dashArray: [3, 3], // This creates the dashed effect
                                      );
                                    }
                                    return FlLine(
                                      color: Colors.transparent,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: [
                                  // Sample data - replace with your actual data
                                  _buildBarGroup(0, 12), // Saturday
                                  _buildBarGroup(1, 8),  // Sunday
                                  _buildBarGroup(2, 15), // Monday
                                  _buildBarGroup(3, 10), // Tuesday
                                  _buildBarGroup(4, 5),  // Wednesday
                                  _buildBarGroup(5, 18), // Thursday
                                  _buildBarGroup(6, 14), // Friday
                                ],
                              ),
                            ),
                          ),
                  ]
                      )
                    )
                  )
                )
              ]
            )
          )
        ],
      ),
    );
    // Add your content below the header here
  }
}
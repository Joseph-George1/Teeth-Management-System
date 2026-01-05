import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/features/home_screen/doctor_home/drawer/doctor_drawer_screen.dart';
import 'package:dio/dio.dart';

import '../../../../core/theming/styles.dart';
import '../../../../core/theming/colors.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String? _firstName;
  String? _lastName;
  bool _isLoadingName = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    if (mounted) {
      setState(() {
        _isLoadingName = true;
      });
    }

    try {
      final storedFirst = await SharedPrefHelper.getString('first_name') ?? '';
      final storedLast = await SharedPrefHelper.getString('last_name') ?? '';

      if (storedFirst.isNotEmpty) {
        if (mounted) {
          setState(() {
            _firstName = storedFirst;
            _lastName = storedLast;
            _isLoadingName = false;
          });
        }
        return;
      }

      final dio = DioFactory.getDio();
      Response response;
      
      try {
        response = await dio.get('/me');
      } catch (e) {
        try {
          response = await dio.get('/profile');
        } catch (e) {
          final email = await SharedPrefHelper.getString('email') ?? '';
          if (email.isNotEmpty) {
            if (mounted) {
              setState(() {
                _firstName = email.split('@').first;
                _isLoadingName = false;
              });
            }
            return;
          }
          debugPrint('Error fetching profile: $e');
          rethrow;
        }
      }

      if (response.statusCode == 200) {
        final data = response.data;
        String? firstName, lastName;
        
        if (data is Map) {
          // Try to get first name
          if (data['first_name'] != null || data['firstName'] != null) {
            firstName = (data['first_name'] ?? data['firstName'])?.toString();
          }
          
          // Try to get last name
          if (data['last_name'] != null || data['lastName'] != null) {
            lastName = (data['last_name'] ?? data['lastName'])?.toString();
          }
          
          // Check for nested user object
          if ((firstName == null || firstName.isEmpty) && data['user'] is Map) {
            final user = data['user'] as Map;
            firstName = (user['first_name'] ?? user['firstName'])?.toString();
            lastName = (user['last_name'] ?? user['lastName'])?.toString();
          }
          
          if (mounted) {
            setState(() {
              _firstName = firstName;
              _lastName = lastName;
            });
          }
        }

        if (_firstName != null && _firstName!.isNotEmpty) {
          await SharedPrefHelper.setData('first_name', _firstName!);
          if (_lastName != null && _lastName!.isNotEmpty) {
            await SharedPrefHelper.setData('last_name', _lastName!);
          }
        }
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error in _fetchDoctorName: $e');
      
      // Fallback to email if available
      if ((_firstName == null || _firstName!.isEmpty)) {
        final email = await SharedPrefHelper.getString('email') ?? '';
        if (email.isNotEmpty) {
          if (mounted) {
            setState(() {
              _firstName = email.split('@').first;
            });
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingName = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorsManager.offWhite,
      drawer: const DoctorDrawer(),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              child: Column(
                children: [
                   _buildHeader(),
                  SizedBox(height: 24.h),
                  _buildMainContent(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return DrawerHeader(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'مرحباً بك 👋',
                  style: TextStyles.font18DarkBlueBold,
                ),
                SizedBox(height: 8.h),
                Text(
                   _isLoadingName
                      ? '...'
                      : _firstName != null
                          ? 'د/ $_firstName'
                          : 'د/ زائر',
                  style: TextStyles.font12DarkBlueRegular,
                ),
              ],
            ),
             Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  _scaffoldKey.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
                color: ColorsManager.mainBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      children: [
         Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: ColorsManager.mainBlue,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إدارة عيادتك أصبحت أسهل',
                        style: TextStyles.font16WhiteSemiBold,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'تابع مواعيدك ومرضاك في مكان واحد',
                        style: TextStyles.font12WhiteRegular,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.calendar_month_rounded,
                  color: Colors.white.withOpacity(0.8),
                  size: 48.sp,
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المواعيد اليوم',
                  '12',
                  Icons.today_rounded,
                  const Color(0xFFE3F2FD),
                  ColorsManager.mainBlue,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildStatCard(
                  'المرضى الجدد',
                  '5',
                  Icons.person_add_rounded,
                  const Color(0xFFE8F5E9),
                  const Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'نظرة عامة على المواعيد',
            style: TextStyles.font18DarkBlueBold,
          ),
          SizedBox(height: 16.h),
          Container(
            height: 200.h,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                         const style = TextStyle(
                          color: Color(0xFF68737d),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        );
                        String text;
                        switch (value.toInt()) {
                          case 0:
                            text = 'السبت';
                            break;
                          case 2:
                            text = 'الاثنين';
                            break;
                          case 4:
                            text = 'الاربعاء';
                            break;
                          case 6:
                            text = 'الجمعة';
                            break;
                          default:
                            return Container();
                        }
                        return SideTitleWidget(
                          meta: meta,
                          space: 4,
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 3),
                      const FlSpot(1, 1),
                      const FlSpot(2, 4),
                      const FlSpot(3, 2),
                      const FlSpot(4, 5),
                      const FlSpot(5, 3),
                      const FlSpot(6, 4),
                    ],
                    isCurved: true,
                    color: ColorsManager.mainBlue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: ColorsManager.mainBlue.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
  
   Widget _buildStatCard(String title, String value, IconData icon,
      Color backgroundColor, Color iconColor) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyles.font12GrayRegular,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyles.font18DarkBlueBold,
          ),
        ],
      ),
    );
  }
}

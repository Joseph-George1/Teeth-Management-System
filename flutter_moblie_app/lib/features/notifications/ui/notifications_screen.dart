import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../data/models/patient_booking_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // TODO: Integrate with a Cubit to fetch actual notifications
    final List<PatientBookingModel> notifications = [];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تنبيهات الحجوزات',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(colorScheme)
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return _buildBookingCard(notifications[index], colorScheme);
              },
            ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 100.sp,
            color: colorScheme.primary.withOpacity(0.3),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد تنبيهات حالياً',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 18.sp,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ستظهر حجوزات المرضى الجديدة هنا',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
      PatientBookingModel booking, ColorScheme colorScheme) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 4,
      shadowColor: colorScheme.primary.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withOpacity(0.1),
                  child: Icon(Icons.person, color: colorScheme.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.patientName,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        booking.phone,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          color: Colors.grey[600],
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'حجز جديد',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: Colors.green,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 24.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                      Icons.calendar_today_outlined, booking.date, colorScheme),
                  _buildInfoItem(
                      Icons.access_time_outlined, booking.time, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: colorScheme.primary),
        SizedBox(width: 6.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}

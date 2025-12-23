import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Mock data for appointments
    final List<Map<String, dynamic>> appointments = [
      {
        'doctorName': 'د. أحمد محمد',
        'specialty': 'تقويم الأسنان',
        'date': DateTime.now().add(const Duration(days: 2)),
        'time': '02:30 م',
        'status': 'مؤكد',
        'statusColor': Colors.green,
      },
      {
        'doctorName': 'د. سارة عبدالله',
        'specialty': 'حشو وعلاج الجذور',
        'date': DateTime.now().add(const Duration(days: 5)),
        'time': '11:00 ص',
        'status': 'قيد الانتظار',
        'statusColor': Colors.orange,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'مواعيدي',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0B8FAC),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters (UI only for now)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('الكل', selected: true),
                  SizedBox(width: 8.w),
                  _filterChip('مؤكد'),
                  SizedBox(width: 8.w),
                  _filterChip('قيد الانتظار'),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            if (appointments.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 64.w,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد مواعيد حالية',
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.grey[600],
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                itemCount: appointments.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                appointment['doctorName'],
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: appointment['statusColor'].withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  appointment['status'],
                                  style: TextStyle(
                                    color: appointment['statusColor'],
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            appointment['specialty'],
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontFamily: 'Cairo',
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              _buildInfoChip(
                                icon: Icons.calendar_today,
                                text: DateFormat('yyyy/MM/dd', 'ar')
                                    .format(appointment['date']),
                              ),
                              SizedBox(width: 12.w),
                              _buildInfoChip(
                                icon: Icons.access_time,
                                text: appointment['time'],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, {bool selected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0B8FAC).withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: selected ? const Color(0xFF0B8FAC) : (Colors.grey[300] ?? Colors.grey),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.filter_alt_outlined, size: 16.w, color: selected ? const Color(0xFF0B8FAC) : Colors.grey[600]),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: selected ? const Color(0xFF0B8FAC) : Colors.grey[800],
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: const Color(0xFF0B8FAC)),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[800],
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
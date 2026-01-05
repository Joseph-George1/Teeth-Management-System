import 'package:thotha_mobile_app/features/appointments/data/appointments_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> _allAppointments = [];
  bool _isLoading = true;
  String _selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload when coming back to this screen
     _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final savedAppointments = await AppointmentsService().getAppointments();

    // Process saved appointments to match UI expectations
    final processedAppointments = savedAppointments.map((appt) {
      Color statusColor = Colors.grey;
      if (appt['status'] == 'مؤكد') {
        statusColor = Colors.green;
      } else if (appt['status'] == 'قيد الانتظار') {
        statusColor = Colors.orange;
      }

      return {
        ...appt,
        'statusColor': statusColor,
      };
    }).toList();

    if (mounted) {
      setState(() {
        _allAppointments = processedAppointments;
        _applyFilter();
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'الكل') {
      appointments = List.from(_allAppointments);
    } else {
      appointments = _allAppointments
          .where((element) => element['status'] == _selectedFilter)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filters (UI only for now)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('الكل'),
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
                  // Handle date display: if it's DateTime use formatter, if String use as is
                  String dateStr = '';
                  if (appointment['date'] is DateTime) {
                     dateStr = DateFormat('yyyy/MM/dd', 'ar').format(appointment['date']);
                  } else {
                     dateStr = appointment['date'].toString();
                  }

                  return GestureDetector(
                    onTap: () => _showAppointmentDetails(context, appointment),
                    child: Card(
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
                                appointment['doctorName'] ?? '',
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
                                  color: (appointment['statusColor'] as Color).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  appointment['status'] ?? '',
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
                            appointment['specialty'] ?? '',
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
                                text: dateStr,
                              ),
                              SizedBox(width: 12.w),
                              _buildInfoChip(
                                icon: Icons.access_time,
                                text: appointment['time'] ?? '',
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _filterChip(String label) {
    final selected = _selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
          _applyFilter();
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0B8FAC).withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: selected
                ? const Color(0xFF0B8FAC)
                : (Colors.grey[300] ?? Colors.grey),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_alt_outlined,
                size: 16.w,
                color: selected ? const Color(0xFF0B8FAC) : Colors.grey[600]),
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

  void _showAppointmentDetails(BuildContext context, Map<String, dynamic> appointment) {
       // date formatting logic again
       String dateStr = '';
       if (appointment['date'] is DateTime) {
          dateStr = DateFormat('yyyy/MM/dd', 'ar').format(appointment['date']);
       } else {
          dateStr = appointment['date'].toString();
       }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(17.r),
          topRight: Radius.circular(17.r),
        ),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(24.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Center(
                   child: Container(
                     width: 50.w,
                     height: 5.h,
                     decoration: BoxDecoration(
                       color: Colors.grey[300],
                       borderRadius: BorderRadius.circular(10.r),
                     ),
                   ),
                 ),
                 SizedBox(height: 20.h),
                 Text(
                   'تفاصيل الموعد',
                   style: TextStyle(
                     fontFamily: 'Cairo',
                     fontSize: 20.sp,
                     fontWeight: FontWeight.w700,
                   ),
                 ),
                 SizedBox(height: 20.h),
                 _buildDetailRow(Icons.person, 'الطبيب', appointment['doctorName'] ?? ''),
                 SizedBox(height: 16.h),
                 _buildDetailRow(Icons.medical_services, 'التخصص', appointment['specialty'] ?? ''),
                 SizedBox(height: 16.h),
                 _buildDetailRow(Icons.calendar_today, 'التاريخ', dateStr),
                 SizedBox(height: 16.h),
                 _buildDetailRow(Icons.access_time, 'الوقت', appointment['time'] ?? ''),
                 SizedBox(height: 16.h),
                 _buildDetailRow(Icons.info_outline, 'الحالة', appointment['status'] ?? '', color: appointment['statusColor']),
                 SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0B8FAC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical:10.h),
                      ),
                      child: Text(
                        'إغلاق',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 25.h), // Safe area
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: (color ?? const Color(0xFF0B8FAC)).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color ?? const Color(0xFF0B8FAC), size: 20.w),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: color ?? Colors.black87,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

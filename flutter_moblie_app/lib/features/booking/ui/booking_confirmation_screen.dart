import 'package:thotha_mobile_app/features/booking/ui/otp_verification_dialog.dart';
import 'package:thotha_mobile_app/features/appointments/data/appointments_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String doctorName;
  final String date;
  final String time;
  final String specialty;

  const BookingConfirmationScreen({
    Key? key,
    required this.doctorName,
    required this.date,
    required this.time,
    this.specialty = 'طب الأسنان',
  }) : super(key: key);

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => OtpVerificationDialog(
          contactInfo: _phoneController.text,
          onVerified: (code) {
            _completeBooking();
          },
        ),
      );
    }
  }

  void _completeBooking() {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () async {
        // Build the appointment object
        // Note: Formatting date/time or keeping as string depends on how AppointmentsScreen consumes it.
        // AppointmentsScreen mock data uses DateTime object for date.
        // We will store it as string ISO or just the string we have, and fix AppointmentsScreen to handle it.
        // For now let's store what we have.

        final appointment = {
          'doctorName': widget.doctorName,
          'specialty': widget.specialty,
          'date': widget.date,
          'time': widget.time,
          'status': 'مؤكد',
        };

        await AppointmentsService().addAppointment(appointment);

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });
        
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            titlePadding: EdgeInsets.only(top: 20.h, left: 20.w, right: 20.w),
            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            actionsPadding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
            title: Text(
              'تم الحجز بنجاح',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0B8FAC),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B8FAC).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_rounded, color: const Color(0xFF0B8FAC), size: 42.w),
                ),
                SizedBox(height: 16.h),
                Text(
                  'تم حجز موعدك بنجاح مع ${widget.doctorName}\nفي يوم ${widget.date} الساعة ${widget.time}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: const Color(0xFF1F2937),
                    height: 1.6,
                  ),
                ),
              ],
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              SizedBox(
                width: 140.w,
                height: 40.h,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to previous screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B8FAC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'حسناً',
                    style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      });
    }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              // Full screen gradient overlay (top-left)
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.7, -0.7),
                    radius: 1.5,
                    colors: [
                      const Color(0xFF84E5F3).withValues(alpha: 0.4),
                      const Color(0xFF84E5F3).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.3, 0.8],
                  ),
                ),
              ),
              // Bottom-right gradient overlay
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, 0.7),
                    radius: 1.5,
                    colors: [
                      const Color(0xFF8DECB4).withValues(alpha: 0.4),
                      const Color(0xFF8DECB4).withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                    stops: const [0.1, 0.3, 0.8],
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0.w),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24.0.w),
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color ?? colorScheme.surface,
                      borderRadius: BorderRadius.circular(16.0),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Center(
                              child: Text(
                                'تأكيد الحجز',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // Doctor Info Card
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16.r),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'معلومات الطبيب',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    _buildInfoRow('الطبيب:', widget.doctorName),
                                    SizedBox(height: 8.h),
                                    _buildInfoRow('التخصص:', widget.specialty),
                                    SizedBox(height: 8.h),
                                    _buildInfoRow('التاريخ:', widget.date),
                                    SizedBox(height: 8.h),
                                    _buildInfoRow('الوقت:', widget.time),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            // Patient Info Form title
                            Text(
                              'معلومات المريض',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            // First Name Field
                            TextFormField(
                              controller: _firstNameController,
                              decoration: InputDecoration(
                                labelText: 'الاسم الأول',
                                prefixIcon: Icon(Icons.person_outline, color: theme.iconTheme.color),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0.r),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال الاسم الأول';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Last Name Field
                            TextFormField(
                              controller: _lastNameController,
                              decoration: InputDecoration(
                                labelText: 'اسم العائلة',
                                prefixIcon: Icon(Icons.person_outline, color: theme.iconTheme.color),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0.r),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال اسم العائلة';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            // Phone Number Field
                            TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9\u0660-\u0669]')),
                              ],
                              decoration: InputDecoration(
                                labelText: 'رقم الجوال',
                                hintText: '01X XXX XXXXX',
                                prefixIcon: Icon(Icons.phone_android, color: theme.iconTheme.color),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0.r),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال رقم الجوال';
                                }
                                if (value.length < 10) {
                                  return 'يجب أن يتكون رقم الجوال من 10 أرقام على الأقل';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 24.h),
                            // Submit Button
                            SizedBox(
                              height: 48.h,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0.r),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        'تأكيد الحجز',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontSize: 16,
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

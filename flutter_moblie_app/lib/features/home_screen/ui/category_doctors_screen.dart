import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/core/di/dependency_injection.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/case_request_model.dart';
import 'package:thotha_mobile_app/features/home_screen/logic/doctor_cubit.dart';
import 'package:thotha_mobile_app/features/home_screen/logic/doctor_state.dart';
import 'package:thotha_mobile_app/features/doctor_info/ui/doctor_info_screen.dart'; // For DoctorInfoContent if needed, or re-use logic
import 'package:thotha_mobile_app/core/theming/colors.dart';
import 'dart:ui'; // For ImageFilter

class CategoryDoctorsScreen extends StatelessWidget {
  final String categoryName;
  final int? categoryId;
  final int? cityId;
  final String? cityName;

  const CategoryDoctorsScreen({
    super.key,
    required this.categoryName,
    this.categoryId,
    this.cityId,
    this.cityName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final cubit = getIt<DoctorCubit>();
        if (categoryId != null) {
          if (cityName != null && cityName!.isNotEmpty) {
            cubit.filterByCategoryAndCity(categoryId!, cityName!);
          } else {
            cubit.filterByCategory(categoryId!);
          }
        } else {
          if (cityName != null && cityName!.isNotEmpty) {
            cubit.filterByCategoryNameAndCity(categoryName, cityName!);
          } else {
            cubit.filterByCategoryName(categoryName);
          }
        }
        return cubit;
      },
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              categoryName,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w700,
              ),
            ),
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'الأطباء'),
                Tab(text: 'طلبات الحالات'),
              ],
              labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
              indicatorColor: ColorsManager.mainBlue,
              labelColor: ColorsManager.mainBlue,
              unselectedLabelColor: ColorsManager.gray,
            ),
          ),
          body: BlocBuilder<DoctorCubit, DoctorState>(
            builder: (context, state) {
              if (state is DoctorLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DoctorError) {
                return Center(child: Text(state.error));
              } else if (state is DoctorSuccess) {
                return TabBarView(
                  children: [
                    // Doctors Tab
                    _buildDoctorsList(context, state.doctors),
                    // Case Requests Tab
                    _buildCaseRequestsList(context, state.caseRequests),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorsList(BuildContext context, List<DoctorModel> doctors) {
    if (doctors.isEmpty) {
      return const Center(child: Text('لا يوجد أطباء في هذا القسم حالياً'));
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: doctors.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _buildDoctorItem(context, doctors[index]);
      },
    );
  }

  Widget _buildCaseRequestsList(BuildContext context, List<CaseRequestModel> requests) {
    if (requests.isEmpty) {
      return const Center(child: Text('لا يوجد طلبات حالات في هذا القسم حالياً'));
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: requests.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return _buildCaseRequestItem(context, requests[index]);
      },
    );
  }

  Widget _buildCaseRequestItem(BuildContext context, CaseRequestModel request) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Doctor Info
          Row(
            children: [
               Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.grey[800] : Colors.grey[200],
                ),
                child: ClipOval(
                  child: request.doctor.photo != null && request.doctor.photo!.isNotEmpty
                      ? Image.network(
                          request.doctor.photo!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.person, color: ColorsManager.gray),
                        )
                      : Icon(Icons.person, color: ColorsManager.gray),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'د. ${request.doctor.fullName} طلب حالة',
                   style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
               Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ColorsManager.mainBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  request.specialization,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'Cairo',
                    color: ColorsManager.mainBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          Divider(height: 20.h),
          
          // Request Details
          Text(
            request.description,
             style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          
          // Date, Time, Location
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14.r, color: ColorsManager.gray),
              SizedBox(width: 4.w),
              Text(
                request.date,
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Cairo'),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.access_time, size: 14.r, color: ColorsManager.gray),
              SizedBox(width: 4.w),
              Text(
                request.time,
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Cairo'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.location_on, size: 14.r, color: ColorsManager.gray),
              SizedBox(width: 4.w),
              Text(
                request.location,
                style: theme.textTheme.bodySmall?.copyWith(fontFamily: 'Cairo'),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          // Action (optional, e.g., "Contact")
           SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Handle contact or apply logic
                 _showDoctorDetails(context, request.doctor);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.mainBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              child: Text(
                'تواصل مع الطبيب',
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorItem(BuildContext context, DoctorModel doctor) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showDoctorDetails(context, doctor),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60.r,
              height: 60.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
              ),
              child: ClipOval(
                child: doctor.photo != null && doctor.photo!.isNotEmpty
                    ? Image.network(
                        doctor.photo!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Icon(Icons.person, color: Colors.grey),
                      )
                    : Icon(Icons.person, color: Colors.grey),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.fullName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    doctor.categoryName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Cairo',
                      color:
                          theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 16.r, color: Colors.grey),
                      SizedBox(width: 4.w),
                      Text(
                        doctor.cityName,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(fontFamily: 'Cairo'),
                      ),
                      Spacer(),
                      if (doctor.price != null)
                        Text(
                          '${doctor.price} جنيه',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Cairo',
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDoctorDetails(BuildContext context, DoctorModel doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            maxChildSize: 0.9,
            minChildSize: 0.3,
            builder: (context, controller) {
              return DoctorInfoContent(
                controller: controller,
                doctor: doctor,
              );
            },
          )
        ]);
      },
    );
  }
}

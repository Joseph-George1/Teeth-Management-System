import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:thotha_mobile_app/core/di/dependency_injection.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';
import 'package:thotha_mobile_app/features/home_screen/logic/doctor_cubit.dart';
import 'package:thotha_mobile_app/features/home_screen/logic/doctor_state.dart';
import 'package:thotha_mobile_app/features/doctor_info/ui/doctor_info_screen.dart';
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
        ),
        body: BlocBuilder<DoctorCubit, DoctorState>(
          builder: (context, state) {
            if (state is DoctorLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DoctorError) {
              return Center(child: Text(state.error));
            } else if (state is DoctorSuccess) {
              final doctors = state.doctors;
              if (doctors.isEmpty) {
                return const Center(
                    child: Text('لا يوجد أطباء في هذا القسم حالياً'));
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
            return const SizedBox.shrink();
          },
        ),
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

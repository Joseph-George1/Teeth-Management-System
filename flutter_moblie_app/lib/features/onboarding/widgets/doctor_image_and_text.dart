import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/theming/colors.dart';

class DoctorImageAndText extends StatefulWidget {
  final String imagePath;
  final String title;
  final String description;

  const DoctorImageAndText({
    super.key,
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  State<DoctorImageAndText> createState() => _DoctorImageAndTextState();
}

class _DoctorImageAndTextState extends State<DoctorImageAndText> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image container
              Container(
                width: 200.w,
                height: 200.h,
                margin: EdgeInsets.only(bottom: 40.h),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    width: 200.w,
                    height: 200.h,
                    // Use cacheWidth to optimize memory usage.
                    // 1500 is safe for high-res devices while being much smaller than original 4K images.
                    cacheWidth: 1500,
                    isAntiAlias: true,
                    filterQuality: FilterQuality.medium,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Title
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                margin: EdgeInsets.only(bottom: 20.h),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.mainBlue,
                  ),
                ),
              ),

              // Description
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  widget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

import '../../../../core/theming/colors.dart';

class DoctorImageAndText extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Precache the image when widget builds
    precacheImage(AssetImage(imagePath), context);
    
    return Center(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image with fade-in effect and error handling
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
                    imagePath,
                    fit: BoxFit.cover,
                    width: 200.w,
                    height: 200.h,
                    cacheWidth: 400, // Cache at 2x for high DPI
                    cacheHeight: 400,
                    filterQuality: FilterQuality.low,
                    frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                      if (wasSynchronouslyLoaded) return child;
                      return AnimatedOpacity(
                        opacity: frame == null ? 0 : 1,
                        duration: const Duration(milliseconds: 100), // Faster animation
                        curve: Curves.easeOut,
                        child: child,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error_outline, size: 50, color: Colors.grey),
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
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.fontColor,
                  ),
                ),
              ),

              // Description
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 30.w),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    color: ColorsManager.fontColor,
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

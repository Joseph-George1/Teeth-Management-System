import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';
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
  late final ValueNotifier<bool> _isLoading;
  late final ImageProvider _imageProvider;

  @override
  void initState() {
    super.initState();
    _isLoading = ValueNotifier<bool>(true);
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      _imageProvider = AssetImage(widget.imagePath);
      // Wait for the image to be loaded
      await precacheImage(_imageProvider, context);
      if (mounted) {
        _isLoading.value = false;
      }
    } catch (e) {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  @override
  void dispose() {
    _isLoading.dispose();
    super.dispose();
  }

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
              // Image container with loading state
              ValueListenableBuilder<bool>(
                valueListenable: _isLoading,
                builder: (context, isLoading, _) {
                  return Container(
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
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (isLoading)
                            const Center(child: CircularProgressIndicator())
                          else
                            Image(
                              image: _imageProvider,
                              fit: BoxFit.cover,
                              width: 200.w,
                              height: 200.h,
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
                        ],
                      ),
                    ),
                  );
                },
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

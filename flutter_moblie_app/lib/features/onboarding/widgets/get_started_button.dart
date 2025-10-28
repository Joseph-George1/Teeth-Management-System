import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theming/colors.dart';

class GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLastPage;

  const GetStartedButton({
    super.key,
    required this.onPressed,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.mainBlue,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 40.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
        minimumSize: Size(double.infinity, 50.h),
      ),
      child: Text(
        isLastPage ? 'ابدأ الآن' : 'التالي',
        style: TextStyle(
          fontSize: 16.sp,
          fontFamily: 'Cairo',
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

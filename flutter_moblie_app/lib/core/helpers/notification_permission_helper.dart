import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationPermissionHelper {
  static Future<void> showNotificationPermissionDialog(
      BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.notifications_active,
                color: Theme.of(context).primaryColor, size: 28.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'تفعيل الإشعارات',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'حافظ على متابعة عيادتك! قم بتفعيل الإشعارات لمتابعة أسماء المرضى، معلومات التواصل، ومواعيد الحجز فوراً من شاشتك الرئيسية.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ليس الآن',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'تفعيل الآن',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showPermanentlyDeniedDialog(
      BuildContext context, VoidCallback onSettingsPressed) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.orange, size: 28.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'الإشعارات معطلة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'لقد تم تعطيل الإشعارات من إعدادات الهاتف. يرجى تفعيلها من الإعدادات لمتابعة حجوزات المرضى وعيادتك.',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            height: 1.5,
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: onSettingsPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'الذهاب للإعدادات',
              style: TextStyle(
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

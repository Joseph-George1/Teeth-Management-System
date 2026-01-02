import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المساعدة والدعم',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'كيف يمكننا مساعدتك؟',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(height: 20.h),
            _buildFaqItem(
              context,
              'كيف يمكنني حجز موعد؟',
              'يمكنك حجز موعد عن طريق الذهاب إلى الصفحة الرئيسية، اختيار التخصص المطلوب، ثم اختيار الطبيب والموعد المناسب لك.',
            ),
            _buildFaqItem(
              context,
              'كيف يمكنني إلغاء الحجز؟',
              'يمكنك إلغاء الحجز من خلال صفحة "حجوزاتي"، اختيار الحجز المراد إلغاؤه، والضغط على زر "إلغاء".',
            ),
            _buildFaqItem(
              context,
              'هل يمكنني تغيير كلمة المرور؟',
              'نعم، يمكنك تغيير كلمة المرور من خلال صفحة الإعدادات واختيار "تغيير كلمة المرور".',
            ),
            SizedBox(height: 30.h),
            Text(
              'تواصل معنا',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 16.h),
            _buildContactItem(
              context,
              Icons.email_outlined,
              'البريد الإلكتروني',
              'joseph@thotha.com',
            ),
            _buildContactItem(
              context,
              Icons.phone_outlined,
              'رقم الهاتف',
              '+20 12 26191421',
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  // Implement contact action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'تحدث مع الدعم المباشر',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            child: Text(
              answer,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                color: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.color
                    ?.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(
      BuildContext context, IconData icon, String title, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }
}

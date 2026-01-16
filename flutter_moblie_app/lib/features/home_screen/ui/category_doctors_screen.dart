import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CategoryDoctorsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryDoctorsScreen({
    super.key,
    required this.categoryName,
  });

  // Mock data: different doctors for each category
  static final Map<String, List<Map<String, String>>> _doctorsByCategory = {
    'فحص شامل': [
      {
        'name': 'د/ أحمد عبد الرحمن',
        'title': 'أخصائي طب وجراحة الفم والأسنان',
        'distance': '1.2 كم',
        'rating': '4.9',
        'image': 'assets/images/دكتور.png',
      },
      {
        'name': 'د/ مي خالد',
        'title': 'استشاري طب الأسنان العام',
        'distance': '2.1 كم',
        'rating': '4.7',
        'image': 'assets/images/دكتوره.png',
      },
    ],
    'حشو أسنان': [
      {
        'name': 'د/ محمد سامي',
        'title': 'أخصائي علاج الجذور',
        'distance': '3.0 كم',
        'rating': '4.8',
        'image': 'assets/images/دكتور كبير.png',
      },
      {
        'name': 'د/ سارة عبد الله',
        'title': 'أخصائية حشو الأسنان',
        'distance': '4.5 كم',
        'rating': '4.6',
        'image': 'assets/images/دكتوره.png',
      },
    ],
    'زراعة الأسنان': [
      {
        'name': 'د/ كريم حسن',
        'title': 'استشاري زراعة الأسنان',
        'distance': '2.7 كم',
        'rating': '4.9',
        'image': 'assets/images/دكتور.png',
      },
      {
        'name': 'د/ لمياء رأفت',
        'title': 'أخصائية زراعة وتجمل أسنان',
        'distance': '5.0 كم',
        'rating': '4.8',
        'image': 'assets/images/دكتوره.png',
      },
    ],
    'خلع الأسنان': [
      {
        'name': 'د/ يوسف صابر',
        'title': 'أخصائي جراحة فموية',
        'distance': '1.8 كم',
        'rating': '4.5',
        'image': 'assets/images/دكتور كبير.png',
      },
      {
        'name': 'د/ آية محمود',
        'title': 'أخصائية خلع جراحي وبسيط',
        'distance': '3.4 كم',
        'rating': '4.4',
        'image': 'assets/images/دكتوره.png',
      },
    ],
    'تبييض الأسنان': [
      {
        'name': 'د/ شيماء علي',
        'title': 'أخصائية تجميل أسنان',
        'distance': '2.0 كم',
        'rating': '4.9',
        'image': 'assets/images/دكتوره.png',
      },
      {
        'name': 'د/ ياسر فؤاد',
        'title': 'أخصائي تبييض وليزر',
        'distance': '3.9 كم',
        'rating': '4.7',
        'image': 'assets/images/دكتور.png',
      },
    ],
    'تقويم الأسنان': [
      {
        'name': 'د/ عمر حسين',
        'title': 'استشاري تقويم أسنان',
        'distance': '1.5 كم',
        'rating': '5.0',
        'image': 'assets/images/دكتور كبير.png',
      },
      {
        'name': 'د/ ندى سمير',
        'title': 'أخصائية تقويم شفاف وتقليدي',
        'distance': '4.2 كم',
        'rating': '4.8',
        'image': 'assets/images/دكتوره.png',
      },
    ],
    'تركيبات الأسنان': [
      {
        'name': 'د/ منة إبراهيم',
        'title': 'أخصائية تركيبات ثابتة',
        'distance': '2.3 كم',
        'rating': '4.6',
        'image': 'assets/images/دكتوره.png',
      },
      {
        'name': 'د/ خالد طارق',
        'title': 'أخصائي تركيبات متحركة وزراعة',
        'distance': '5.3 كم',
        'rating': '4.7',
        'image': 'assets/images/دكتور.png',
      },
    ],
  };

  List<Map<String, String>> _resolveDoctors() {
    if (_doctorsByCategory.containsKey(categoryName)) {
      return _doctorsByCategory[categoryName]!;
    }
    // Fallback: أي فئة مش متعرفة ترجع قائمة فحص شامل
    return _doctorsByCategory['فحص شامل']!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctors = _resolveDoctors();

    return Scaffold(
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
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(10.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6.r,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar placeholder
                CircleAvatar(
                  radius: 30.r,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                  child: doctor['image'] != null
                      ? ClipOval(
                          child: doctor['image']!.toLowerCase().endsWith('.svg')
                              ? SvgPicture.asset(
                                  doctor['image']!,
                                  width: 50.r,
                                  height: 50.r,
                                  fit: BoxFit.cover,
                                )
                              : Image.asset(
                                  doctor['image']!,
                                  width: 67.r,
                                  height: 67.r,
                                 // fit: BoxFit.cover,
                                ),
                        )
                      : Icon(
                          Icons.person,
                          color: theme.colorScheme.primary,
                        ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        doctor['name'] ?? '',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        doctor['title'] ?? '',
                        textAlign: TextAlign.right,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'Cairo',
                          color: theme.textTheme.bodyMedium?.color
                              ?.withValues(alpha: 0.7),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16.r,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            doctor['rating'] ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'Cairo',
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Icon(
                            Icons.location_on,
                            size: 16.r,
                            color: theme.iconTheme.color?.withValues(alpha: 0.7),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            doctor['distance'] ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: 'Cairo',
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


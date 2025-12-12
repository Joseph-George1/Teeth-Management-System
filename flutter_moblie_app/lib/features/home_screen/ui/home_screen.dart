import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thotha_mobile_app/core/theming/app_theme.dart';
import 'package:thotha_mobile_app/core/utils/notification_helper.dart';
import 'package:thotha_mobile_app/features/doctor_info/ui/doctor_info_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:thotha_mobile_app/features/notifications/ui/notifications_screen.dart';

import 'drawer/browse_services/ui/browse_services_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showDoctorDetails(BuildContext context) {
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
              return DoctorInfoContent(controller: controller);
            },
          )
        ]);
      },
    );
  }

  Widget _buildCircularIcon(String assetPath, int index, String categoryName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // List of SVG file names in order
    final svgFiles = [
      'فحص شامل.svg',
      'حشو اسنان.svg',
      'زراعه اسنان.svg',
      'خلع اسنان.svg',
      'تبيض اسنان.svg',
      'تقويم اسنان.svg',
      'تركيبات اسنان.svg',
    ];

    // List of category names in the same order as svgFiles
    final categoryNames = [
      'فحص شامل',
      'حشو العصب',
      'زراعه الأسنان',
      ' خلع الأسنان',
      'تبيض الأسنان',
      'تقويم الأسنان',
      'تركيبات الأسنان',
    ];

    // Resolve file and label from inputs or fallbacks
    final fileName =
    index <= svgFiles.length ? svgFiles[index - 1] : 'placeholder.svg';
    final resolvedAssetPath =
    assetPath.isNotEmpty ? assetPath : 'assets/svg/$fileName';
    final resolvedCategoryName = categoryName.isNotEmpty
        ? categoryName
        : (index <= categoryNames.length ? categoryNames[index - 1] : '');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72.w,
          height: 72.h,
          margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 2.r,
                offset: const Offset(0, 0.5),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              resolvedAssetPath,
              width: 36.w,
              height: 36.h,
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                width: 36.w,
                height: 36.h,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: Icon(Icons.image, size: 18.r, color: Colors.grey),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 72.w,
          child: Text(
            resolvedCategoryName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 10.sp,
              height: 1.0,
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showDoctorDetails(context),
      child: Container(
        width: double.infinity,
        height: 120.h,
        margin: EdgeInsets.only(
            top: 14.h, left: 15.98.w, right: 15.98.w, bottom: 14.h),
        padding: EdgeInsets.only(top: 14.h, right: 15.98.w, left: 5.61.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Image Container (Right side)
            Container(
              width: 84.w,
              height: 84.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                image: DecorationImage(
                  image: AssetImage('assets/images/dr.cr7.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 6.w),
            // Middle Section with Doctor Info
            Expanded(
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Name and Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'د/ كريستيانو رونالدو',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'تدريب تقويم أسنان',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            letterSpacing: 0,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // Rating and Location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, size: 11.r, color: Colors.amber),
                            SizedBox(width: 4.w),
                            Text(
                              '4.9',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(128)',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                letterSpacing: 0,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 11.r, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                '2.5 كم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  height: 1.5,
                                  letterSpacing: 0,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Right Section (Availability)
            SizedBox(width: 6.w),
            Container(
              width: 54.w,
              height: 84.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and Area
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 11.r, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Text(
                            'المعادي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              letterSpacing: 0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Availability Badge
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.green.withOpacity(0.2)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 4.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time,
                              size: 11.r, color: Colors.green),
                          SizedBox(width: 4.w),
                          Text(
                            'متاح غداً',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w400,
                              fontSize: 11.sp,
                              height: 1.0,
                              letterSpacing: 0,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            _scaffoldKey.currentState?.openDrawer();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'مرحباً, أهلاً بعودتك',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 15.sp,
                  height: 1.0,
                  letterSpacing: -0.02,
                  color: Colors.grey,
                ),
              ),
              Text(
                'عبدالحليم رمضان',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 17.sp,
                  height: 1.2,
                  letterSpacing: -0.02,
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const HomeDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  height: 40.h,
                  margin: EdgeInsets.only(top: 10.h, left: 16.w, right: 16.w),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey[800]?.withOpacity(0.5)
                        : const Color(0xFFD9D9D9).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      // Search Icon
                      Padding(
                        padding: EdgeInsets.only(right: 12.0.w, left: 8.0.w),
                        child:
                        Icon(Icons.search, color: Colors.grey, size: 22.r),
                      ),
                      // Search Text
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: Theme.of(context).textTheme.bodyMedium,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن قسم...',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 14.h),
                          ),
                        ),
                      ),
                      // Microphone Icon
                      IconButton(
                        icon: Icon(Icons.mic, color: Colors.grey, size: 22.r),
                        onPressed: () {
                          // TODO: Add voice search functionality
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ),
                ),

                // Gradient Card
                Container(
                  width: double.infinity,
                  height: 136.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.r),
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF95F8C9), Color(0xFF54CAF7)],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Image on the left
                      Positioned(
                        left: 0,
                        top: 12.h,
                        child: Image.asset(
                          'assets/images/دكتور.png',
                          width: 160.w,
                          height: 120.h,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Text Content on the right
                      Positioned(
                        right: 20.w,
                        top: 16.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'احجز و سجل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: 160.w,
                              child: Text(
                                'مع افضل الاطباء في نطاقك',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: 80.w,
                              height: 24.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Center(
                                child: Text(
                                  'احجز الان',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Services Header
                Container(
                  width: double.infinity,
                  height: 32.h,
                  margin: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(left: 12.w),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>  BrowseServicesScreen(),
                                ),
                            );
                          },
                          child: Text(
                            'المزيد',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                              height: 1.0,
                              letterSpacing: -0.02,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                      Text(
                        'الخدمات المتوفرة',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          height: 1.2,
                          letterSpacing: -0.02,
                        ),
                      ),
                    ],
                  ),
                ),

                // Circular Categories Row
                SizedBox(
                  height: 110.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      _buildCircularIcon(
                          'assets/svg/فحص شامل.svg', 1, 'فحص شامل'),
                      _buildCircularIcon(
                          'assets/svg/حشو اسنان.svg', 2, 'حشو أسنان'),
                      _buildCircularIcon(
                          'assets/svg/زراعه اسنان.svg', 3, 'زراعة أسنان'),
                      _buildCircularIcon(
                          'assets/svg/خلع اسنان.svg', 4, 'خلع أسنان'),
                      _buildCircularIcon(
                          'assets/svg/تبيض اسنان.svg', 5, 'تبييض أسنان'),
                      _buildCircularIcon(
                          'assets/svg/تقويم اسنان.svg', 6, 'تقويم أسنان'),
                      _buildCircularIcon(
                          'assets/svg/تركيبات اسنان.svg', 7, 'تركيبات أسنان'),
                    ],
                  ),
                ),

                // City and Area Dropdowns
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 16.h, left: 22.w, right: 22.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // First container - المدن
                      Expanded(
                          child: Container(
                            height: 44.h,
                            padding: const EdgeInsets.only(
                              top: 0,
                              right: 0,
                              bottom: 1.1,
                              left: 0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isDark ? Colors.grey[700]! : const Color(0xFFD1D5DC),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 4.r,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 35.w),
                                  child: Center(
                                    child: Text(
                                      'المدن',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        height: 2.33,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 8.w,
                                  top: 0,
                                  bottom: 0,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 22.r,
                                        color: Theme.of(context).iconTheme.color,
                                      ),
                                      Container(
                                        height: 44.h,
                                        width: 1.w,
                                        margin:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                        color: isDark ? Colors.grey[700] : const Color(0xFFD1D5DC),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                      SizedBox(width: 16.w),
                      // Second container - المناطق
                      Expanded(
                          child: Container(
                            height: 47.81.h,
                            padding: const EdgeInsets.only(
                              top: 0,
                              right: 0,
                              bottom: 1.1,
                              left: 0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isDark ? Colors.grey[700]! : const Color(0xFFD1D5DC),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 4.r,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(left: 35.w),
                                  child: Center(
                                    child: Text(
                                      'المناطق',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w700,
                                        height: 2.33,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 8.w,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.arrow_drop_down,
                                        size: 22.r,
                                        color: Theme.of(context).iconTheme.color,
                                      ),
                                      Container(
                                        height: 44.h,
                                        width: 1.w,
                                        margin:
                                        EdgeInsets.symmetric(horizontal: 4.w),
                                        color: isDark ? Colors.grey[700] : const Color(0xFFD1D5DC),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ),
                SizedBox(height: 15.h),

                // Doctors Section Header
                Container(
                  height: 28.h,
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'الاطباء الاقرب لك',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17.sp,
                          height: 1.2,
                          letterSpacing: -0.02,
                        ),
                      ),
                    ],
                  ),
                ),

                // Doctor Cards
                for (var i = 0; i < 5; i++) _buildDoctorCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thotha_mobile_app/features/doctor_info/ui/doctor_info_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer.dart';

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
      'تبييض الأسنان',
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
          width: 80.w,
          height: 80.h,
          margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF111827),
              width: 0.5, // Slightly thicker border
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0x1A000000),
                blurRadius: 4.r, // Slightly more prominent shadow
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              resolvedAssetPath,
              width: 40.w, // Icon size
              height: 40.h, // Icon size
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                width: 40.w,
                height: 40.h,
                color: Colors.grey[200],
                child: Icon(Icons.image, size: 20.r, color: Colors.grey),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          width: 80.w,
          child: Text(
            resolvedCategoryName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w400,
              // Regular
              fontSize: 11.sp,
              height: 1.0,
              // line-height 24px for 11px font size
              letterSpacing: 0.1,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard() {
    return GestureDetector(
      onTap: () => _showDoctorDetails(context),
      child: Container(
        width: double.infinity,
        height: 132.h,
        margin: EdgeInsets.only(
            top: 16.h, left: 15.98.w, right: 15.98.w, bottom: 15.98.h),
        padding: EdgeInsets.only(top: 15.98.h, right: 15.98.w, left: 5.61.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
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
              width: 99.98.w,
              height: 99.98.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                color: Colors.grey[200],
                image: DecorationImage(
                  image: AssetImage('assets/images/dr.cr7.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 15.98.w),
            // Middle Section with Doctor Info
            Expanded(
              child: SizedBox(
                height: 100.h,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor Name and Title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'د/ كريستيانو رونالدو',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            // Updated to 600 (SemiBold)
                            height: 1.5,
                            // 24px line height for 16px font size
                            color: Colors.black,
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'تدريب تقويم أسنان',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            // 21px line height for 14px font size
                            letterSpacing: 0,
                            color: Colors.grey,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    // Rating and Location
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.star, size: 12.r, color: Colors.amber),
                            SizedBox(width: 4.w),
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                height: 1.5,
                                letterSpacing: 0,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '(128)',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14.sp,
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
                                size: 12.r, color: Colors.grey),
                            SizedBox(width: 4.w),
                            Expanded(
                              child: Text(
                                '2.5 كم',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 13.sp,
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
            SizedBox(width: 15.98.w),
            Container(
              width: 73.w,
              height: 100.h,
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
                          Icon(Icons.location_on, size: 12.r, color: Colors.grey),
                          SizedBox(width: 4.w),
                          Text(
                            'المعادي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              // 18px line height
                              letterSpacing: 0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Availability Badge
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
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
                            size: 11.85.r, color: Colors.green),
                        SizedBox(width: 4.w),
                        Text(
                          'متاح غداً',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w400,
                            fontSize: 12.sp,
                            height: 1.0,
                            // 18px line height
                            letterSpacing: 0,
                            color: Colors.green,
                          ),
                        ),
                      ],
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
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  height: 1.0,
                  // 100% line height
                  letterSpacing: -0.02,
                  // -2% letter spacing
                  color: Colors.grey,
                ),
              ),
              // No extra spacing needed as line height handles it
              Text(
                'عبدالحليم رمضان',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  // SemiBold
                  fontSize: 18.sp,
                  height: 1.2,
                  letterSpacing: -0.02,
                  // -2% letter spacing
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none,
                color: Colors.black, size: 28.r),
            onPressed: () {
              // TODO: Add notification functionality
            },
          ),
          SizedBox(width: 12.w),
        ],
      ),
      drawer: const HomeDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 16.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  height: 42.h,
                  margin: EdgeInsets.only(top: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    children: [
                      // Search Icon
                      Padding(
                        padding: EdgeInsets.only(right: 12.0.w, left: 8.0.w),
                        child: Icon(Icons.search, color: Colors.grey, size: 24.r),
                      ),
                      // Search Text
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن قسم...',
                            hintStyle: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16.sp,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 16.h),
                          ),
                        ),
                      ),
                      // Microphone Icon
                      IconButton(
                        icon:
                            Icon(Icons.mic, color: Colors.grey, size: 24.r),
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
                  height: 148.h,
                  margin: EdgeInsets.only(top: 20.h),
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
                        top: 13.h,
                        child: Image.asset(
                          'assets/images/دكتور.png',
                          width: 180.w,
                          height: 135.h,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // Text Content on the right
                      Positioned(
                        right: 20.w,
                        top: 20.h,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'احجز و سجل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(height: 8.h),
                            SizedBox(
                              width: 163.w,
                              child: Text(
                                'مع افضل الاطباء في نطاقك',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              width: 87.w,
                              height: 27.h,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Center(
                                child: Text(
                                  'احجز الان',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12.sp,
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
                  height: 35.h,
                  margin: EdgeInsets.only(top: 20.h, bottom: 10.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الخدمات المتوفرة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          // SemiBold
                          fontSize: 18.sp,
                          height: 1.2,
                          letterSpacing: -0.02,
                          // -2% letter spacing
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 50.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(left: 12.w),
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Add navigation to see more services
                          },
                          child: Text(
                            'المزيد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              height: 1.0,
                              // 100% line height
                              letterSpacing: -0.02,
                              // -2% letter spacing
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Circular Categories Row with Horizontal Scroll and SVG Icons
                SizedBox(
                  height: 130.h, // Increased height to accommodate labels
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      // List of SVG files from the assets/svg directory with their corresponding category names
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
                ), // Services Header
                Container(
                  width: double.infinity,
                  height: 30.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'الاطباء الاقرب لك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.bold,
                          // SemiBold
                          fontSize: 18.sp,
                          height: 1.2,
                          letterSpacing: -0.02,
                          // -2% letter spacing
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 50.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        alignment: Alignment.centerRight,
                        margin: EdgeInsets.only(left: 50.w),
                      ),
                    ],
                  ),
                ),
                // Two equal containers side by side
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 20.h, left: 22.w, right: 22.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // First container - المدن
                      Expanded(
                        child: Container(
                        // width: 150.w,
                        height: 47.81.h,
                        padding: const EdgeInsets.only(
                          top: 0,
                          right: 0,
                          bottom: 1.1,
                          left: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFD1D5DC),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Centered text with padding
                            Padding(
                              padding: EdgeInsets.only(left: 35.w),
                              // Added left padding to avoid divider
                              child: Center(
                                child: Text(
                                  'المدن',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 2.33,
                                    letterSpacing: 0.1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            // Left-aligned arrow and divider
                            Positioned(
                              left: 8.w,
                              top: 0,
                              bottom: 0,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 24.r,
                                    color: Colors.black,
                                  ),
                                  Container(
                                    height: 46.5.h,
                                    width: 1.w,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 4.w),
                                    color: const Color(0xFFD1D5DC),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )),
                      // Second container - المناطق
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Container(
                        // width: 150.w,
                        height: 47.81.h,
                        padding: const EdgeInsets.only(
                          top: 0,
                          right: 0,
                          bottom: 1.1,
                          left: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: const Color(0xFFD1D5DC),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4.r,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Centered text with padding
                            Padding(
                              padding: EdgeInsets.only(left: 35.w),
                              // Added left padding to avoid divider
                              child: Center(
                                child: Text(
                                  'المناطق',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    height: 2.33,
                                    letterSpacing: 0.1,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            // Left-aligned arrow and divider
                            Positioned(
                              left: 8.w,
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.arrow_drop_down,
                                    size: 24.r,
                                    color: Colors.black,
                                  ),
                                  Container(
                                    height: 46.5.h,
                                    width: 1.w,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 4.w),
                                    color: const Color(0xFFD1D5DC),
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
                // Doctor Card Section
                for (var i = 0; i < 5; i++) _buildDoctorCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

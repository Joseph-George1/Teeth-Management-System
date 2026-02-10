import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thotha_mobile_app/features/doctor_info/ui/doctor_info_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/category_doctors_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:thotha_mobile_app/features/notifications/ui/notifications_screen.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thotha_mobile_app/core/di/dependency_injection.dart';
import 'package:thotha_mobile_app/features/home_screen/logic/doctor_cubit.dart';

import 'package:thotha_mobile_app/features/home_screen/logic/doctor_state.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int? _selectedCityId;

  // Asset mapping for categories
  final Map<String, String> _categoryAssets = {
    'فحص شامل': 'assets/svg/فحص شامل.svg',
    'حشو أسنان': 'assets/svg/حشو اسنان.svg',
    'زراعة أسنان': 'assets/svg/زراعه اسنان.svg',
    'خلع الأسنان': 'assets/svg/خلع اسنان.svg',
    'تبييض الأسنان': 'assets/svg/تبيض اسنان.svg',
    'تقويم الأسنان': 'assets/svg/تقويم اسنان.svg',
    'تركيبات الأسنان': 'assets/svg/تركيبات اسنان.svg',
  };

  @override
  void initState() {
    super.initState();
    // Search listener will be added later if needed for Cubit filtering
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

  Widget _buildCircularIcon(String assetPath, int index, String categoryName,
      {int? categoryId}) {
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
      'حشو أسنان',
      'زراعة أسنان',
      'خلع الأسنان',
      'تبييض الأسنان',
      'تقويم الأسنان',
      'تركيبات الأسنان',
    ];

    // Resolve file and label from inputs or fallbacks
    final fileName = index < svgFiles.length ? svgFiles[index] : 'placeholder.svg';
    final resolvedAssetPath =
        assetPath.isNotEmpty ? assetPath : 'assets/svg/$fileName';
    final resolvedCategoryName = categoryName.isNotEmpty
        ? categoryName
        : (index < categoryNames.length ? categoryNames[index] : '');

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryDoctorsScreen(
              categoryName: resolvedCategoryName,
              categoryId: categoryId,
            ),
          ),
        );
      },
      child: Column(
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
      ),
    );
  }

  Widget _buildDoctorCard(DoctorModel doctor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showDoctorDetails(context, doctor),
      child: Container(
        width: double.infinity,
        height: 120.h,
        margin:
            EdgeInsets.only(top: 14.h, left: 16.w, right: 16.w, bottom: 14.h),
        padding: EdgeInsets.only(top: 14.h, right: 16.w, left: 6.w),
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
                image: const DecorationImage(
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
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
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
            SizedBox(
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

    return BlocProvider(
      create: (context) => getIt<DoctorCubit>()..loadInitialData(),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.menu,
              size: 24.w,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.notifications_none_outlined,
                size: 28.sp,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
          ],
        ),
        drawer: const HomeDrawer(),
        body: SafeArea(
          child: BlocBuilder<DoctorCubit, DoctorState>(
            builder: (context, state) {
              if (state is DoctorLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is DoctorError) {
                return Center(child: Text(state.error));
              } else if (state is DoctorSuccess) {
                final categories = state.categories;
                final cities = state.cities;
                final doctors = state.doctors;

                // Filter categories locally based on search text
                final filteredCategories = (_searchController.text.isEmpty || categories.isEmpty)
                    ? categories
                    : categories
                        .where((c) => c.name.contains(_searchController.text))
                        .toList();

                return SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        Container(
                          height: 40.h,
                          margin: EdgeInsets.only(
                              top: 10.h, left: 16.w, right: 16.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.grey[800]?.withOpacity(0.5)
                                : const Color(0xFFD9D9D9).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(right: 12.0.w, left: 8.0.w),
                                child: Icon(Icons.search,
                                    color: Colors.grey, size: 22.r),
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  onChanged: (val) {
                                    setState(
                                        () {}); // Rebuild to filter categories
                                  },
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
                              IconButton(
                                icon: Icon(Icons.mic,
                                    color: Colors.grey, size: 22.r),
                                onPressed: () {},
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
                          margin: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
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
                                        borderRadius:
                                            BorderRadius.circular(4.r),
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

                        // City Dropdown
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(
                              top: 16.h, left: 22.w, right: 22.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 48.h,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 12.w),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.grey[700]!
                                          : const Color(0xFFD1D5DC),
                                      width: 1.1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.3),
                                        blurRadius: 4.r,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: _selectedCityId,
                                      hint: Text(
                                        'اختر المدينة',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color),
                                      items: cities.map((city) {
                                        return DropdownMenuItem<int>(
                                          value: city.id,
                                          child: Text(
                                            city.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontSize: 14.sp,
                                                ),
                                            textAlign: TextAlign.right,
                                          ),
                                        );
                                      }).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedCityId = val;
                                        });
                                        if (val != null) {
                                          context
                                              .read<DoctorCubit>()
                                              .filterByCity(val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Services Header
                        Container(
                          width: double.infinity,
                          height: 32.h,
                          margin: EdgeInsets.symmetric(
                              horizontal: 13.w, vertical: 12.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'الخدمات المتوفرة',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17.sp,
                                      height: 1.2,
                                      letterSpacing: -0.02,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        // Categories Grid
                        if (filteredCategories.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12.h,
                                crossAxisSpacing: 12.w,
                                childAspectRatio: 0.8,
                              ),
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = filteredCategories[index];
                                // Use mapped asset or default
                                final asset = _categoryAssets[category.name] ??
                                    'assets/svg/فحص شامل.svg';

                                return _buildCircularIcon(
                                    asset, index, category.name,
                                    categoryId: category.id);
                              },
                            ),
                          ),

                        SizedBox(height: 15.h),

                        // Doctors Section Header
                        if (doctors.isNotEmpty)
                          Container(
                            height: 28.h,
                            margin: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'الاطباء المتاحين',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
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
                        if (doctors.isEmpty && _selectedCityId != null)
                          Padding(
                            padding: EdgeInsets.all(20.h),
                            child: Center(
                                child: Text('لا يوجد اطباء في هذه المدينة')),
                          ),

                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: doctors.length,
                          itemBuilder: (context, index) {
                            return _buildDoctorCard(doctors[index]);
                          },
                        ),

                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

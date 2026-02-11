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


  Widget _buildSquareCategory(String assetPath, int index, String categoryName,
      {int? categoryId, String? cityName}) {
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
              cityId: _selectedCityId,
              cityName: cityName,
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.grey.withOpacity(0.1),
              blurRadius: 4.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              resolvedAssetPath,
              width: 48.w,
              height: 48.h, // Increased size for square card
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                width: 48.w,
                height: 48.h,
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                child: Icon(Icons.image, size: 24.r, color: Colors.grey),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                resolvedCategoryName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600, // Bolder text
                      fontSize: 14.sp, // Larger text
                      height: 1.2,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                                crossAxisCount: 2,
                                mainAxisSpacing: 12.h,
                                crossAxisSpacing: 12.w,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: filteredCategories.length,
                              itemBuilder: (context, index) {
                                final category = filteredCategories[index];
                                // Use mapped asset or default
                                final asset = _categoryAssets[category.name] ??
                                    'assets/svg/فحص شامل.svg';

                                String? selectedCityName;
                                if (_selectedCityId != null) {
                                  try {
                                    selectedCityName = cities
                                        .firstWhere((c) => c.id == _selectedCityId)
                                        .name;
                                  } catch (_) {}
                                }

                                return _buildSquareCategory(
                                    asset, index, category.name,
                                    categoryId: category.id,
                                    cityName: selectedCityName);
                              },
                            ),
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

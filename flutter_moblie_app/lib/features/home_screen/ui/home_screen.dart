import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/routing/routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();


  void _showDoctorDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
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
        return Align(
        alignment: Alignment.topCenter,
        child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: MediaQuery.of(context).size.height * 0.9, // 90% of screen height
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        ),
        child: ListView(
        controller: controller,
        children: [
        Container(
        width: double.infinity,
        height: 89.06,
        padding: const EdgeInsets.symmetric(horizontal: 23.99),
        decoration: const BoxDecoration(
        border: Border(
        bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.1),
        ),
        ),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        const Text(
        'تفاصيل الطالب',
        style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black,
        ),
        ),
        GestureDetector(
        onTap: () => Navigator.pop(context),
        child: const Icon(Icons.close, size: 24, color: Colors.black),
        ),
        ],
        ),
        ),
        const SizedBox(height: 16),
        Center(
        child: Column(
        children: [
        // Image container
        const SizedBox(height: 16),
        Center(
        child: Column(
        children: [
        // Image container
        Container(
        width: 149.9924,
        height: 149.9924,
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
        image: AssetImage('assets/images/test.jpg'),
        fit: BoxFit.cover,
        ),
        ),
        ),
        Container(
        width: 300.91,
        height: 180.93,
        margin: const EdgeInsets.only(top: 7.9876),
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 300.91,
          height: 180.93,
          margin: const EdgeInsets.only(top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Doctor's Name
              const Text(
                'د/كريستيانو رونالدو',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                  height: 1.5,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Training/Specialty
              const Text(
                'تدريب جراحة وتجميل الأسنان',
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                  height: 1.5,
                  letterSpacing: 0,
                  color: Color(0xFF858585),
                ),
              ),

              const SizedBox(height: 16),

              // Centered Rating and Location
              SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF858585),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '2.5 كم',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            height: 1.5,
                            letterSpacing: 0,
                            color: Color(0xFF858585),
                          ),
                        ),
                        const SizedBox(width: 24), // Space between location and rating
                      ],
                    ),

                    // Rating
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 1.5,
                              letterSpacing: 0,
                              color: Colors.black,
                            ),
                            children: const [
                              TextSpan(text: '4.5 '),
                              TextSpan(
                                text: '(120)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const Spacer(),

              // Student Information Container
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 20, left: 8, right: 8, bottom: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Title
                    Container(
                      width: 86,
                      height: 30,
                      alignment: Alignment.centerRight,
                      child: const Text(
                        'عن الطالب',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF0A0A0A),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),

                    // Description
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      child: const Text(
                        'طالب بالسنة الخامسة متخصص في جراحة وتجميل الأسنان. أقوم بالتدريب العملي تحت إشراف أساتذة الكلية. لدي خبرة جيدة في الحشوات التجميلية وخلع الأسنان البسيط.',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.625,
                          color: Color(0xFF858585),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        )],
        ),
        ),
        const SizedBox(height: 24),
        ],
        ),
        //const SizedBox(height: 24),
        ) ],
        ),
        ),
        );
        },
            )
          ]
        );
              },
    );
  }
  Widget _buildCircularIcon(String assetPath, int index, String categoryName) {
    // List of SVG file names in order
    final svgFiles = [
      'فحص شامل.svg',
      'حشو اسنان.svg',
      'زراعه اسنان.svg',  // زراعه اسنان.svg (note the different ه)
      'خلع اسنان.svg',
      'تبيض اسنان.svg',   // Note: تبيض not تبييض
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
    
    // Get the correct file name or use a placeholder if index is out of range
    final fileName = index <= svgFiles.length ? svgFiles[index - 1] : 'placeholder.svg';
    final categoryName = index <= categoryNames.length ? categoryNames[index - 1] : '';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,  // Increased container size
          height: 80, // Increased container size
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF111827),
              width: 0.5, // Slightly thicker border
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4, // Slightly more prominent shadow
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/svg/$fileName',
              width: 40,  // Icon size
              height: 40, // Icon size
              fit: BoxFit.contain,
              placeholderBuilder: (BuildContext context) => Container(
                width: 40,
                height: 40,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 20, color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            categoryName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w400, // Regular
              fontSize: 11,
              height: 1.0, // line-height 24px for 11px font size
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
        width: 365,
        height: 132,
        margin: const EdgeInsets.only(top: 16, left: 15.98, right: 15.98, bottom: 15.98),
        padding: const EdgeInsets.only(top: 15.98, right: 15.98, left: 5.61),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: const Border(
            top: BorderSide(color: Color(0xFFE5E7EB), width: 1.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor Image Container (Right side)
            Container(
              width: 99.98,
              height: 99.98,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
                image: const DecorationImage(
                  image: AssetImage('assets/images/dr.cr7.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 15.98),
            // Middle Section with Doctor Info
            SizedBox(
              width: 117,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Doctor Name and Title
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د/ كريستيانو رونالدو',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w600, // Updated to 600 (SemiBold)
                          height: 1.5, // 24px line height for 16px font size
                          color: Colors.black,
                          letterSpacing: 0,
                        ),
                      ),
                      Text(
                        'تدريب تقويم أسنان',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          height: 1.5, // 21px line height for 14px font size
                          letterSpacing: 0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  // Rating and Location
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '4.9',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              letterSpacing: 0,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(128)',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                              letterSpacing: 0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '2.5 كم',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13,
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
                ],
              ),
            ),
            // Right Section (Availability)
            const SizedBox(width: 15.98),
            Container(
              width: 73,
              height: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and Area
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'المعادي',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              height: 1.5, // 18px line height
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, size: 11.85, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'متاح غداً',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            height: 1.0, // 18px line height
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'مرحباً, أهلاً بعودتك',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w400,
                fontSize: 16,
                height: 1.0, // 100% line height
                letterSpacing: -0.02, // -2% letter spacing
                color: Colors.grey,
              ),
            ),
            // No extra spacing needed as line height handles it
            const Text(
              'عبدالحليم رمضان',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.w600, // SemiBold
                fontSize: 18,
                height: 1.2,
                letterSpacing: -0.02, // -2% letter spacing
                color: Colors.black,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
            onPressed: () {
              // TODO: Add notification functionality
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                Container(
                  height: 42,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Search Icon
                      const Padding(
                        padding: EdgeInsets.only(right: 12.0, left: 8.0),
                        child: Icon(Icons.search, color: Colors.grey, size: 24),
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
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      // Microphone Icon
                      IconButton(
                        icon: const Icon(Icons.mic, color: Colors.grey, size: 24),
                        onPressed: () {
                          // TODO: Add voice search functionality
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                
                // Gradient Card
                Container(
                  width: double.infinity,
                  height: 148,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
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
                        top: 13,
                        child: Image.asset(
                          'assets/images/دكتور.png',
                          width: 180,
                          height: 135,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      // Text Content on the right
                      Positioned(
                        right: 20,
                        top: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'احجز و سجل',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 8),
                            const SizedBox(
                              width: 163,
                              child: Text(
                                'مع افضل الاطباء في نطاقك',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14, fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: 87,
                              height: 27,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Center(
                                child: Text(
                                  'احجز الان',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
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
                  width: 500,
                  height: 35,
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الخدمات المتوفرة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600, // SemiBold
                          fontSize: 18,
                          height: 1.2,
                          letterSpacing: -0.02, // -2% letter spacing
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(left: 50),
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Add navigation to see more services
                          },
                          child: const Text(
                            'المزيد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 1.0, // 100% line height
                              letterSpacing: -0.02, // -2% letter spacing
                              color: Colors.grey,
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
                  height: 130, // Increased height to accommodate labels
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // List of SVG files from the assets/svg directory with their corresponding category names
                      _buildCircularIcon('assets/svg/icon_1.svg', 1, 'فحص شامل'),
                      _buildCircularIcon('assets/svg/icon_2.svg', 2, 'حشو أسنان'),
                      _buildCircularIcon('assets/svg/icon_3.svg', 3, 'زراعة أسنان'),
                      _buildCircularIcon('assets/svg/icon_4.svg', 4, 'خلع أسنان'),
                      _buildCircularIcon('assets/svg/icon_5.svg', 5, 'تبييض أسنان'),
                      _buildCircularIcon('assets/svg/icon_6.svg', 6, 'تقويم أسنان'),
                      _buildCircularIcon('assets/svg/icon_7.svg', 7, 'تركيبات أسنان'),
                    ],
                  ),
                ), // Services Header
                Container(
                  width: 500,
                  height: 35,
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الاطباء الاقرب لك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600, // SemiBold
                          fontSize: 18,
                          height: 1.2,
                          letterSpacing: -0.02, // -2% letter spacing
                          color: Colors.black,
                        ),
                      ),
                      Container(
                        width: 50,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(left: 50),
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Add navigation to see more services
                          },
                          child: const Text(
                            'المزيد',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                              height: 1.0, // 100% line height
                              letterSpacing: -0.02, // -2% letter spacing
                              color: Colors.grey,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Two equal containers side by side
                Container(
                  width: 350,
                  margin: const EdgeInsets.only(top: 20, left: 22, right: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // First container - المدن
                      Container(
                        width: 150,
                        height: 47.81,
                        padding: const EdgeInsets.only(
                          top: 0,
                          right: 0,
                          bottom: 1.1,
                          left: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFD1D5DC),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Centered text with padding
                            const Padding(
                              padding: EdgeInsets.only(left: 35), // Added left padding to avoid divider
                              child: Center(
                                child: Text(
                                  'المدن',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18,
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
                              left: 8,
                              top: 0,
                              bottom: 0,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 24,
                                    color: Colors.black,
                                  ),
                                  Container(
                                    height: 46.5,
                                    width: 1,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    color: const Color(0xFFD1D5DC),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Second container - المناطق
                      Container(
                        width: 150,
                        height: 47.81,
                        padding: const EdgeInsets.only(
                          top: 0,
                          right: 0,
                          bottom: 1.1,
                          left: 0,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFD1D5DC),
                            width: 1.1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Centered text with padding
                            const Padding(
                              padding: EdgeInsets.only(left: 35), // Added left padding to avoid divider
                              child: Center(
                                child: Text(
                                  'المناطق',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 18,
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
                              left: 8,
                              top: 0,
                              bottom: 0,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.arrow_drop_down,
                                    size: 24,
                                    color: Colors.black,
                                  ),
                                  Container(
                                    height: 46.5,
                                    width: 1,
                                    margin: const EdgeInsets.symmetric(horizontal: 4),
                                    color: const Color(0xFFD1D5DC),
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
                // Doctor Card Section
                for (var i = 0; i < 7; i++) _buildDoctorCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/category_doctors_screen.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/drawer/drawer.dart';

final List<String> categoryNames = [
  'فحص شامل',
  'حشو العصب',
  'زراعه الأسنان',
  'خلع الأسنان',
  'تبييض الأسنان',
  'تقويم الأسنان',
  'تركيبات الأسنان',
];
final svgFiles = [
  'فحص شامل.svg',
  'حشو اسنان.svg',
  'زراعه اسنان.svg',
  'خلع اسنان.svg',
  'تبيض اسنان.svg',
  'تقويم اسنان.svg',
  'تركيبات اسنان.svg',
];
final Map<String, String> serviceDescriptions = {
  'فحص شامل': 'فحص شامل للأسنان واللثة ',
  'حشو العصب': 'علاج جذور الأسنان',
  'زراعه الأسنان': 'حلول للأسنان المفقودة',
  'خلع الأسنان': 'خلع بسيط وجراحي للأسنان',
  'تبييض الأسنان': 'تنظيف وإزالة الجير',
  'تقويم الأسنان': 'تقويم شفاف وتقليدي',
  'تركيبات الأسنان': 'تركيبات ثابتة ومتحركة',
};

class BrowseServicesScreen extends StatefulWidget {
  BrowseServicesScreen({super.key});

  @override
  State<BrowseServicesScreen> createState() => _BrowseServicesScreenState();
}

class _BrowseServicesScreenState extends State<BrowseServicesScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Helper method to load SVG with error handling
  Future<String> _loadSvg(String path) async {
    try {
      // This will throw an exception if the file doesn't exist
      await DefaultAssetBundle.of(_scaffoldKey.currentContext!).loadString(path);
      return path;
    } catch (e) {
      print('Failed to load SVG at path: $path');
      print('Error details: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      drawer: const Drawer(
        child: HomeDrawer(),
      ),
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Disable default back button
        title: Container(
          width: double.infinity,
          height: 50,
          child: Stack(
            children: [
              // Menu icon on the left
              Positioned(
                left: 0,
                child: IconButton(
                  icon: Icon(
                    Icons.menu,
                    color: theme.iconTheme.color,
                    size: 40,
                    weight: 700, // Bold weight
                  ),
                  onPressed: () {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                ),
              ),
              // Logo centered
              Positioned(
                right: 30,
                child: Image.asset(
                  'assets/images/splash-logo.png',
                  width: 46,
                  height: 50,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // User greeting container
          Container(
            width: 400,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.only(top: 15),
            child: Stack(
              children: [
                // Notification icon (left side)
                Positioned(
                  left: 20,
                  child: Container(
                    width: 70,
                    height: 39.99,
                    alignment: Alignment.centerLeft,
                    // Notification icon removed
                    child: Container(),
                  ),
                ),
                // User name and greeting (right side)
                Positioned(
                  right: 0,
                  top: -4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Greeting
                      const Text(
                        'مرحباً، أهلاً بعودتك',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          height: 1.5,
                          letterSpacing: 0.4,
                          color: Color(0xFF858585),
                        ),
                      ),
                      // Name
                      const Text(
                        'تصفح ما لدينا',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          height: 1.5,
                          letterSpacing: 0.1,
                          color: Color(0xFF101828),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Services Title Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(right: 35, top: 20, bottom: 10),
            child: Text(
              'جميع الخدمات المتوفرة',
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                fontSize: 24,
                height: 1.5,
              ),
              textAlign: TextAlign.right,
            ),
          ),

          // Scrollable categories list
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: 374.w,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                    width: 1.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categoryNames.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryDoctorsScreen(
                              categoryName: categoryNames[index],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 374,
                        height: 121,
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color ?? colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            width: 1.1,
                            color: isDark ? Colors.grey[700]! : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              // SVG icon container
                              Container(
                                width: 88.99,
                                height: 88.99,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF84E5F3), Color(0xFF8DECB4)],
                                    stops: [0.0, 1.0],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: FutureBuilder<String>(
                                  future: _loadSvg('assets/svg/${svgFiles[index]}'),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Icon(
                                        Icons.medical_services,
                                        color: Colors.blue[400],
                                        size: 40,  // Increased from 40
                                      );
                                    } else {
                                      return SvgPicture.asset(
                                        'assets/svg/${svgFiles[index]}',  // Use the filename from svgFiles list
                                        width: 56.99,
                                        height: 56.99,
                                        fit: BoxFit.contain,
                                      );
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Main content area
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Category name container
                                    Container(
                                      width: 120,
                                      height: 27,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        categoryNames[index],
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                          height: 1.5, // 27px line height / 18px font size
                                          letterSpacing: 0,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Service description
                                    Container(
                                      width: 200, // Increased from 128
                                      height: 21,
                                      padding: const EdgeInsets.only(right: 8, left: 8),
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        serviceDescriptions[categoryNames[index]] ?? '',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          height: 1.5, // 21px line height / 14px font size
                                          letterSpacing: 0,
                                          color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                        ),
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // Available students container
                                    Container(
                                      height: 21,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(width: 8),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'طالب متاح ',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 12,
                                                  color: theme
                                                      .colorScheme.primary,
                                                ),
                                              ),
                                              Text(
                                                '${index + 5} ',
                                                style: theme.textTheme.bodySmall
                                                    ?.copyWith(
                                                  fontFamily: 'Cairo',
                                                  fontSize: 12,
                                                  color: theme
                                                      .colorScheme.primary,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                Icons.person_outline,
                                                color:
                                                    theme.colorScheme.primary,
                                                size: 16,
                                              ),
                                            ],
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
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

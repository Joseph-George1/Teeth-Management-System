import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/routing/routes.dart';
import '../../core/theming/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/1-onboarding.jpg',
      'title': 'اعثر على أفضل الأطباء',
      'description':
          'في ثوثة جمعنا أفضل طلاب وأطباء الأسنان عشان نقدم لك رعاية حقيقية بأسعار طلابية.',
    },
    {
      'image': 'assets/images/2-inboarding.jpg',
      'title': 'احجز موعدك بسهولة',
      'description': 'اختار الموعد المناسب لك واحجز مع طبيبك المفضل في ثواني.',
    },
    {
      'image': 'assets/images/3-onboarding.jpg',
      'title': 'متابعة دقيقة لصحة أسنانك',
      'description': 'احصل على سجل كامل لعلاجاتك ومواعيدك القادمة.',
    },
  ];

  void _goToHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Routes.categoriesScreen,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _BackgroundGradient(),
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _DoctorImageAndText(
                imagePath: _pages[index]['image']!,
                title: _pages[index]['title']!,
                description: _pages[index]['description']!,
              );
            },
          ),
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: _GetStartedButton(
                    isLastPage: _currentPage == _pages.length - 1,
                    onPressed: () async {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _goToHome();
                      }
                    },
                  ),
                ),
                if (_currentPage < _pages.length - 1)
                  TextButton(
                    onPressed: _goToHome,
                    child: Text(
                      'ندخل في الموضوع علي طول',
                      style: TextStyle(
                        color: ColorsManager.darkBlue,
                        fontSize: 16.sp,
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== Background ===================== */

class _BackgroundGradient extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.7, -0.7),
              radius: 1.5,
              colors: [
                ColorsManager.layerBlur1.withOpacity(0.5),
                ColorsManager.layerBlur1.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.7, 0.7),
              radius: 1.5,
              colors: [
                ColorsManager.layerBlur2.withOpacity(0.4),
                ColorsManager.layerBlur2.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ===================== Doctor Image & Text ===================== */

class _DoctorImageAndText extends StatelessWidget {
  final String imagePath;
  final String title;
  final String description;

  const _DoctorImageAndText({
    required this.imagePath,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            Container(
              width: 200.w,
              height: 200.h,
              margin: EdgeInsets.only(bottom: 40.h),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.mainBlue,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===================== Button ===================== */

class _GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLastPage;

  const _GetStartedButton({
    required this.onPressed,
    required this.isLastPage,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsManager.mainBlue,
        minimumSize: Size(double.infinity, 50.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
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

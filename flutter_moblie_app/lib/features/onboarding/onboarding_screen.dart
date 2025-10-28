import 'package:flutter/material.dart';
import 'package:flutter_moblie_app/features/login/ui/login_screen.dart';
import 'package:flutter_moblie_app/features/onboarding/widgets/doctor_image_and_text.dart';
import 'package:flutter_moblie_app/features/onboarding/widgets/get_started_button.dart';
import 'package:flutter_moblie_app/features/onboarding/widgets/page_indicator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
  final int _numPages = 3;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < _numPages; i++) {
      list.add(i == _currentPage ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? ColorsManager.mainBlue : Colors.grey[400],
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  void _onSkipPressed() {
    // Navigate to login screen and remove all previous routes from the stack
    Navigator.pushNamedAndRemoveUntil(
      context, 
      Routes.loginScreen,
      (route) => false, // This removes all previous routes
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full screen gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.7), // Top-left quadrant
                radius: 1.5,
                colors: [
                  ColorsManager.layerBlur1.withOpacity(0.4),
                  ColorsManager.layerBlur1.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),
          // Bottom-right gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.7, 0.7), // Bottom-right quadrant
                radius: 1.5,
                colors: [
                  ColorsManager.layerBlur2.withOpacity(0.4),
                  ColorsManager.layerBlur2.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),

          // PageView for onboarding screens
          PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: [
              DoctorImageAndText(
                imagePath: 'assets/images/1-onboarding.jpg',
                title: 'اعثر على أفضل الأطباء',
                description:
                    'في ثوثة جمعنا أفضل طلاب وأطباء الأسنان عشان نقدم لك رعاية حقيقية بأسعار طلابية. ابتسامتك في أيد أمينة، مع نخبة من أمهر الأطباء الشباب.',
              ),
              DoctorImageAndText(
                imagePath: 'assets/images/2-inboarding.jpg',
                title: 'احجز موعدك بسهولة',
                description:
                    'اختار الموعد المناسب لك واحجز مع طبيبك المفضل في ثواني. خدمة حجز المواعيد لدينا سهلة وسريعة وآمنة.',
              ),
              DoctorImageAndText(
                imagePath: 'assets/images/3-onboarding.jpg',
                title: 'متابعة دقيقة لصحة أسنانك',
                description:
                    'احصل على سجل كامل لعلاجاتك ومواعيدك القادمة. نحن نهتم بابتسامتك من أول زيارة.',
              ),
            ],
          ),

          // Page Indicator - Always show on all pages
          Positioned(
            bottom: 100.h,
            left: 0,
            right: 0,
            child: PageIndicator(
              currentPage: _currentPage,
              pageCount: _numPages,
            ),
          ),
          SizedBox(height: 50.h),

          // Action Buttons Container
          Positioned(
            bottom: 40.h,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Next/Get Started Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30.w),
                  child: GetStartedButton(
                    isLastPage: _currentPage == _numPages - 1,
                    onPressed: () async {
                      if (_currentPage < _numPages - 1) {
                        // Go to next page
                        await _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      } else {
                        // On last page, navigate to login
                        if (mounted) {
                          _onSkipPressed();
                        }
                      }
                    },
                  ),
                ),

                // Skip Button - Only show if not on last page
                if (_currentPage < _numPages - 1)
                  TextButton(
                    onPressed: _onSkipPressed,
                    child: Text(
                      'تخطي',
                      style: TextStyle(
                        color: ColorsManager.mainBlue,
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

  Widget _buildOnboardingPage({
    required String image,
    required String title,
    required String description,
    bool isLastPage = false,
  }) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 80.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Container(
              width: 200.w,
              height: 200.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  image,
                  width: 200.w,
                  height: 200.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            // Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.fontColor,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Description
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.w),
              child: Text(
                description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  color: ColorsManager.fontColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

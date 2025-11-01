import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/routing/routes.dart';
import '../../core/theming/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _precacheOnboardingImages(BuildContext context) async {
    final images = const [
      'assets/images/1-onboarding.jpg',
      'assets/images/2-inboarding.jpg',
      'assets/images/3-onboarding.jpg',
    ];

    // Precache at displayed size (≈200x200 logical pixels) to speed up decode.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetW = (200 * dpr).round();
    final targetH = (200 * dpr).round();

    final futures = images.map((path) {
      final provider = ResizeImage(AssetImage(path), width: targetW, height: targetH);
      return precacheImage(provider, context);
    }).toList();

    // Wait for all onboarding images so they appear instantly.
    await Future.wait(futures);
  }

  @override
  void initState() {
    super.initState();
    // Precache onboarding images so they show instantly when navigating.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _precacheOnboardingImages(context);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
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
                center: const Alignment(-0.7, -0.7), // Top-left quadrant
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
                center: const Alignment(0.7, 0.7), // Bottom-right quadrant
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

          //Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/images/splash-logo.png',
                  width: 150.w,
                  height: 150.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 40.h),
                Text(
                  'رعاية ذكية, لمسة طلابية',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.fontColor,
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

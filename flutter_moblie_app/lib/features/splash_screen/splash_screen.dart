import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meta/meta.dart';

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

    // Precache at a reasonable size (400x400 for high DPI)
    const targetSize = 400; // This will be in logical pixels
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final targetW = (targetSize * dpr).round();
    final targetH = (targetSize * dpr).round();

    // Use a try-catch to prevent the app from crashing if an image fails to load
    try {
      // First, load a low-res version for immediate display
      await Future.wait(images.map((path) {
        return precacheImage(
          ResizeImage(
            AssetImage(path),
            width: 100, // Start with a smaller size for faster initial load
            height: 100,
            allowUpscaling: true,
          ),
          context,
        );
      }));

      // Then load the full resolution in the background
      unawaited(Future.wait(images.map((path) {
        return precacheImage(
          ResizeImage(
            AssetImage(path),
            width: targetW,
            height: targetH,
            allowUpscaling: false,
          ),
          context,
          onError: (exception, stackTrace) {
            debugPrint('Failed to load image: $path\n$exception');
          },
        );
      })));

    } catch (e) {
      debugPrint('Error preloading images: $e');
      // Even if there's an error, we still want to continue to the app
    }
  }

  @override
  void initState() {
    super.initState();
    
    // Start precaching images and navigate when done
    _precacheOnboardingImages(context).then((_) {
      if (mounted) {
        // Navigate immediately after precaching is done
        Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
      }
    }).catchError((error) {
      // If there's an error, still navigate but log the error
      debugPrint('Error precaching images: $error');
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
      }
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

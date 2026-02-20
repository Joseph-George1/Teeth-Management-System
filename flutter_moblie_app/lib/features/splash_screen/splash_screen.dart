import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/routing/routes.dart';
import '../../core/theming/colors.dart';
import '../../core/helpers/notification_permission_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Precache all onboarding images in parallel
    _precacheOnboardingImages();
  }

  Future<void> _precacheOnboardingImages() async {
    final images = [
      'assets/images/1-onboarding.jpg',
      'assets/images/2-inboarding.jpg',
      'assets/images/3-onboarding.jpg',
    ];

    try {
      await Future.wait(
        images.map((image) => precacheImage(
              // Must match the cacheWidth used in DoctorImageAndText
              ResizeImage(AssetImage(image), width: 1500),
              context,
            )),
      );
    } catch (e) {
      // debugPrint('Failed to precache images: $e');
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showLocationDialog(
          title: 'خدمات الموقع مطلوبة',
          content: 'يرجى تفعيل خدمات الموقع للمتابعة.',
          onPressed: () async {
            Navigator.of(context).pop();
            await Geolocator.openLocationSettings();
            _checkLocationPermission(); // Retry loop
          },
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          _showLocationDialog(
            title: 'إذن الموقع مطلوب',
            content:
                'يحتاج التطبيق إلى إذن الموقع ليعمل بشكل صحيح. يرجى منح الإذن.',
            onPressed: () {
              Navigator.of(context).pop();
              _checkLocationPermission(); // Retry loop
            },
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showLocationDialog(
          title: 'إذن الموقع مطلوب',
          content:
              'تم رفض إذن الموقع بشكل دائم. يرجى تفعيله من إعدادات التطبيق للمتابعة.',
          onPressed: () async {
            Navigator.of(context).pop();
            await Geolocator.openAppSettings();
            _checkLocationPermission(); // Retry loop
          },
        );
      }
      return;
    }

    // Location permission granted, now check notifications
    if (mounted) {
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    // 1. If already authorized, move on to onboarding
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
      }
      return;
    }

    // 2. If denied (disabled from settings), show the "Settings" dialog
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (mounted) {
        await NotificationPermissionHelper.showPermanentlyDeniedDialog(
          context,
          () async {
            Navigator.pop(context);
            await Geolocator.openAppSettings();
          },
        );
        // After returning from settings, the user should have enabled them.
        _checkNotificationPermission();
      }
      return;
    }

    // 3. If not determined (first time), show our pitch dialog
    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      if (mounted) {
        await NotificationPermissionHelper.showNotificationPermissionDialog(
            context);
        // After pitch, trigger the system request
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        // Re-check whatever the user chose in the system dialog
        _checkNotificationPermission();
      }
      return;
    }

    // Default: Final navigation if for some reason we reach here (e.g. provisional)
    if (mounted) {
      Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
    }
  }

  void _showLocationDialog({
    required String title,
    required String content,
    required VoidCallback onPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          content,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: Text(
              'موافق',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: ColorsManager.mainBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Full screen gradient overlay (matching onboarding)
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
                stops: const [0.1, 0.5, 0.8],
              ),
            ),
          ),
          // Bottom-right gradient overlay (matching onboarding)
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
                stops: const [0.1, 0.5, 0.8],
              ),
            ),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image
                Image.asset(
                  'assets/images/splash-logo.png',
                  width: 200.w,
                  height: 200.h,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 32.h),
                // Title Text
                Text(
                  'رعاية ذكية، لمسة طبية',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.fontColor,
                    fontFamily: 'Cairo',
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

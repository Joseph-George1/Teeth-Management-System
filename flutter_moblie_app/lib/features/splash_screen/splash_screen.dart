import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/routing/routes.dart';
import '../../core/theming/colors.dart';
import '../../core/helpers/shared_pref_helper.dart';
import '../../core/helpers/constants.dart';
import '../../core/helpers/notification_permission_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheOnboardingImages();
  }

  Future<void> _precacheOnboardingImages() async {
    final images = [
      'assets/images/onboarding1.jpg',
      'assets/images/onboarding2.jpg',
      'assets/images/onboarding3.jpg',
    ];

    try {
      await Future.wait(
        images.map((image) => precacheImage(
              ResizeImage(AssetImage(image), width: 1500),
              context,
            )),
      );
    } catch (e) {
      // ignore
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        _showLocationDialog(
          title: L10nSplashScreen.locationServicesAreRequired.tr(),
          content: L10nSplashScreen.pleaseActivateLocationServices.tr(),
          onPressed: () async {
            Navigator.of(context).pop();
            await Geolocator.openLocationSettings();
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
            title: L10nSplashScreen.locationPermissionRequired.tr(),
            content:
                L10nSplashScreen.theAppNeedsLocation.tr(),
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.requestPermission();
              _checkLocationPermission();
            },
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        _showLocationDialog(
          title: L10nSplashScreen.locationPermissionRequired.tr(),
          content:
              L10nSplashScreen.locationPermissionHasBeen.tr(),
          onPressed: () async {
            Navigator.of(context).pop();
            await Geolocator.openAppSettings();
          },
        );
      }
      return;
    }

    if (mounted) {
      _checkNotificationPermission();
    }
  }

  Future<void> _checkNotificationPermission() async {
    NotificationSettings settings =
        await FirebaseMessaging.instance.getNotificationSettings();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      if (mounted) {
        _navigateToNext(context);
      }
      return;
    }

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      if (mounted) {
        await NotificationPermissionHelper.showPermanentlyDeniedDialog(
          context,
          () async {
            Navigator.pop(context);
            await Geolocator.openAppSettings();
          },
        );
      }
      return;
    }

    if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
      if (mounted) {
        final result =
            await NotificationPermissionHelper.showNotificationPermissionDialog(
                context);
        if (!mounted) return;
        if (result == true) {
          await FirebaseMessaging.instance.requestPermission(
            alert: true,
            badge: true,
            sound: true,
          );
          if (!mounted) return;
          _navigateToNext(context);
        } else {
          _navigateToNext(context);
        }
      }
      return;
    }

    if (mounted) {
      _navigateToNext(context);
    }
  }

  /// Logic to decide where to go after Splash
  Future<void> _navigateToNext(BuildContext context) async {
    final hasSeenOnboarding =
        await SharedPrefHelper.getBool('has_seen_onboarding') ?? false;
    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);

    if (!context.mounted) return;

    if (!hasSeenOnboarding) {
      // إذا لم يرى الاونبوردينج ابداً
      Navigator.pushReplacementNamed(context, Routes.onBoardingScreen);
    } else {
      // إذا رآها من قبل، نرى هل هو مسجل دخول أم لا
      if (token != null && token.isNotEmpty) {
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(
          context,
          Routes.loginScreen,
        );
      } else {
        // إذا لم يكن مسجل دخول، نذهب لصفحة الأقسام (الهوم العامة)
        if (!context.mounted) return;
        Navigator.pushReplacementNamed(context, Routes.categoriesScreen);
      }
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
            fontSize: 18,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          content,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: Text(
              L10nSplashScreen.ok.tr(),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: ColorsManager.mainBlue,
                fontSize: 16,
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
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [
                  ColorsManager.layerBlur1.withValues(alpha: 0.4),
                  ColorsManager.layerBlur1.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.5, 0.8],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.7, 0.7),
                radius: 1.5,
                colors: [
                  ColorsManager.layerBlur2.withValues(alpha: 0.4),
                  ColorsManager.layerBlur2.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.1, 0.5, 0.8],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/splash-logo.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 32),
                Text(
                  L10nHomeScreen.smartCareMedicalTouch.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
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

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/features/notifications/data/repos/notification_repo.dart';
import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/core/theming/theme_provider.dart';
import 'package:thoutha_mobile_app/features/doctor/ui/doctor_booking_records_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/ui/doctor_confirmed_appointments_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/ui/doctor_next_booking_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/ui/info_pages/doctor_help_and_support_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/ui/info_pages/doctor_privacy_policy_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/ui/info_pages/doctor_terms_and_conditions_screen.dart';
import 'package:thoutha_mobile_app/features/profile/ui/doctor_profile.dart';
import 'package:thoutha_mobile_app/features/requests/ui/my_requests_screen.dart';
import 'package:thoutha_mobile_app/features/doctor/ui/secondary_home_screen.dart'
    show SecondaryHomeScreen;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';
import 'package:thoutha_mobile_app/features/login/ui/login_screen.dart';

import '../ui/doctor_home_screen.dart';
import '../../profile/data/models/doctor_profile_model.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:showcaseview/showcaseview.dart';
import 'package:thoutha_mobile_app/tour/tour_config.dart';
import 'package:thoutha_mobile_app/tour/tour_service.dart';
import 'package:thoutha_mobile_app/tour/tour_widgets.dart';

class DoctorDrawer extends StatefulWidget {
  final int? selectedIndex;
  const DoctorDrawer({super.key, this.selectedIndex});

  static final ValueNotifier<String?> profileImageNotifier =
      ValueNotifier(null);

  @override
  State<DoctorDrawer> createState() => _DoctorDrawerState();
}

class _DoctorDrawerState extends State<DoctorDrawer> {
  String? _firstName;
  String? _lastName;
  String? _email;
  String? _profileImage;
  int? _doctorId;
  String _appVersion = '1.0.0';
  bool _isTourStarted = false;

  static const _cCyan = Color(0xFF84E5F3);
  static const _cGreen = Color(0xFF8DECB4);

  late ApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService = getIt<ApiService>();
    _fetchDoctorInfo();
    _fetchAppVersion();
    DoctorDrawer.profileImageNotifier.addListener(_updateProfileImage);
  }

  @override
  void dispose() {
    DoctorDrawer.profileImageNotifier.removeListener(_updateProfileImage);
    super.dispose();
  }

  void _updateProfileImage() {
    if (DoctorDrawer.profileImageNotifier.value != null) {
      setState(() {
        _profileImage = DoctorDrawer.profileImageNotifier.value;
      });
    }
  }

  Future<void> _fetchAppVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final int buildNum = int.tryParse(packageInfo.buildNumber) ?? 0;
      if (mounted) {
        setState(() {
          if (buildNum >= 35) {
            final int patch = buildNum - 35;
            _appVersion = '1.0.$patch';
          } else {
            _appVersion = packageInfo.version;
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching app version: $e');
    }
  }

  void _showLogoutConfirmation(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return AlertDialog(
          title: Text(
            L10nDoctor.confirmLogout.tr(),
            textAlign: TextAlign.start,
            style:
                textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          content: Text(
            L10nDoctor.areYouSureYou.tr(),
            textAlign: TextAlign.start,
            style: textTheme.bodyMedium,
          ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  L10nBooking.cancellation.tr(),
                  style: textTheme.bodyLarge?.copyWith(
                    color: isDark ? Colors.grey[400] : Colors.grey[700],
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              TextButton(
                child: Text(
                  L10nDoctor.logOut.tr(),
                  style: textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                  ),
                ),
                onPressed: () async {
                  // Pop the confirmation dialog
                  Navigator.of(context).pop();

                  // Show a loading dialog during de-registration and cleanup
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );

                  try {
                    // 1. Fetch current FCM token from shared preferences
                    final fcmToken = await SharedPrefHelper.getString(SharedPrefKeys.fcmToken);
                    if (fcmToken.isNotEmpty) {
                      // 2. Call deregisterDeviceToken with a timeout to prevent locking out on bad connection
                      final notificationRepo = getIt<INotificationRepo>();
                      await notificationRepo
                          .deregisterDeviceToken(fcmToken: fcmToken)
                          .timeout(
                        const Duration(seconds: 3),
                        onTimeout: () {
                          debugPrint('⚠️ FCM de-registration timed out');
                          return false;
                        },
                      );
                    }
                  } catch (e) {
                    debugPrint('⚠️ Error during FCM de-registration: $e');
                  }

                  // 3. Clear all cached session data, keeping onboarding indicator intact
                  await SharedPrefHelper.clearAllData();
                  await SharedPrefHelper.clearAllSecuredData();
                  await SharedPrefHelper.setData('has_seen_onboarding', true);

                  if (context.mounted) {
                    // Pop the loading dialog
                    Navigator.of(context).pop();
                    
                    // Redirect to LoginScreen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    }

  Widget _menuItem(
    BuildContext context, {
    required String title,
    required IconData icon,
    Color? iconColor,
    Color? textColor,
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? _cCyan.withAlpha(26) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? _cCyan
                      : (iconColor ?? Theme.of(context).iconTheme.color),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.start,
                    style: textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Cairo',
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isSelected
                          ? _cCyan
                          : textColor ??
                              Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _cCyan,
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(4),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),  
    );  
  }

  Widget _toggleMenuItem(
    BuildContext context, {
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
    Color? iconColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
            children: [
              Icon(
                icon,
                color: iconColor ?? Theme.of(context).iconTheme.color,
                size: 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.start,
                  style: textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Cairo',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeTrackColor: Color(0xFF10B981),
                inactiveThumbColor: isDark ? Colors.black : Colors.white,
                inactiveTrackColor: Theme.of(context).dividerColor,
              ),
            ],
          ),
        ),
    );
  }

  Future<void> _fetchDoctorInfo() async {
    try {
      final cachedFirstName = await SharedPrefHelper.getString('first_name');
      final cachedLastName = await SharedPrefHelper.getString('last_name');
      final cachedEmail = await SharedPrefHelper.getString('email');
      final cachedImage = await SharedPrefHelper.getString('profile_image');
      
      // doctor_id is stored as int, so use getInt
      final cachedId = await SharedPrefHelper.getInt('doctor_id');
      // getInt returns 0 if not found, convert to null
      final doctorId = cachedId > 0 ? cachedId : null;

      debugPrint('Drawer - Cached data: firstName=$cachedFirstName, lastName=$cachedLastName, email=$cachedEmail, doctorId=$doctorId');

      // Always load cached data if available
      if (cachedFirstName != null && cachedFirstName.isNotEmpty) {
        setState(() {
          _firstName = cachedFirstName;
          _lastName = cachedLastName;
          _email = cachedEmail;
          _profileImage =
              (cachedImage?.isNotEmpty ?? false) ? cachedImage : _profileImage;
          _doctorId = doctorId;
        });
        debugPrint('Drawer - Loaded cached data into state');
      } else {
        debugPrint('Drawer - No cached data found');
      }

      // Fetch from API to update info and get doctor ID if missing/changed
      final result = await _apiService.getDoctorById();
      debugPrint('Drawer - API result: $result');
      
      if (result['success'] == true && result['data'] != null) {
        final doctorData = result['data'] as DoctorProfileModel;
        debugPrint('Drawer - Doctor data from API: firstName=${doctorData.firstName}, lastName=${doctorData.lastName}, email=${doctorData.email}');
        
        // Only update with non-null values from API to preserve cached data
        if (doctorData.firstName != null ||
            doctorData.lastName != null ||
            doctorData.email != null) {
          setState(() {
            _firstName = doctorData.firstName ?? _firstName;
            _lastName = doctorData.lastName ?? _lastName;
            _email = doctorData.email ?? _email;
            _doctorId = doctorData.id ?? _doctorId;
          });
          debugPrint('Drawer - Updated state with API data');
        }

        if (doctorData.firstName != null) {
          await SharedPrefHelper.setData('first_name', doctorData.firstName!);
        }
        if (doctorData.lastName != null) {
          await SharedPrefHelper.setData('last_name', doctorData.lastName!);
        }
        if (doctorData.email != null) {
          await SharedPrefHelper.setData('email', doctorData.email!);
        }
        if (doctorData.id != null) {
          await SharedPrefHelper.setData('doctor_id', doctorData.id);
        }
      } else {
        debugPrint('Drawer - API call failed or returned no data');
      }
    } catch (e) {
      debugPrint('Exception fetching doctor info: $e');
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  int _getCurrentIndex() {
    if (widget.selectedIndex != null) {
      return widget.selectedIndex!;
    }
    final currentRoute =
        ModalRoute.of(context)?.settings.name?.toLowerCase() ?? '';
    if (currentRoute.contains('doctor-home')) return 0;
    if (currentRoute.contains('add-case')) return 1;
    if (currentRoute.contains('doctor-profile') ||
        currentRoute.contains('profile')) {
      return 2;
    }
    if (currentRoute.contains('upcoming-bookings') ||
        currentRoute.contains('doctor-next-booking')) {
      return 3;
    }
    if (currentRoute.contains('booking-records') ||
        currentRoute.contains('records') ||
        currentRoute.contains('appointment-history')) {
      return 4;
    }
    if (currentRoute.contains('confirmed-appointments') ||
        currentRoute.contains('doctor-confirmed-appointments')) {
      return 5;
    }
    if (currentRoute.contains('doctor-requests')) return 6;
    if (currentRoute.contains('doctor-terms-and-conditions') ||
        currentRoute.contains('terms-and-conditions')) {
      return 7;
    }
    if (currentRoute.contains('doctor-privacy-policy') ||
        currentRoute.contains('privacy-policy')) {
      return 8;
    }
    if (currentRoute.contains('doctor-help-and-support') ||
        currentRoute.contains('help-and-support')) {
      return 9;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textTheme = Theme.of(context).textTheme;
    final double topPad = MediaQuery.of(context).padding.top;
    final int currentIndex = _getCurrentIndex();

    return ShowCaseWidget(
      onComplete: (index, key) {
        TourService.onDismiss(key)();
      },
      builder: (context) {
        if (!_isTourStarted) {
          _isTourStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) TourService.startTourForScreen(context, 'doctor_drawer');
          });
        }
        return Drawer(
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: topPad + 160,
              padding: EdgeInsets.only(top: topPad),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: isDark
                      ? [_cCyan.withAlpha(200), _cGreen.withAlpha(200)]
                      : [_cCyan, _cGreen],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 48),
                        Expanded(
                          child: Text(
                            L10nDoctor.list.tr(),
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.surface.withAlpha(64),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (_firstName != null &&
                                            _firstName!.isNotEmpty)
                                        ? L10nDoctor.helloDrFirstname.tr(namedArgs: {
                                            '_firstName':
                                                '${_firstName!} ${_lastName ?? ""}'
                                          })
                                        : L10nDoctor.doctor.tr(),
                                    style: textTheme.titleMedium?.copyWith(
                                      fontFamily: 'Cairo',
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    _email != null && _email!.isNotEmpty
                                        ? _email!
                                        : '********',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontFamily: 'Cairo',
                                      color: Theme.of(context).colorScheme.surface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Management Group
                  Showcase.withWidget(
                    height: 150,
                    width: 280,
                    key: TourConfig.doctorDrawerManagementKey,
                    container: CustomTourTooltip(
                      title: L10nTour.doctorManagement.tr(),
                      description: L10nTour.doctorManagementDesc.tr(),
                      onNext: () => ShowCaseWidget.of(context).next(),
                      onSkipTap: () {
                        if (context.mounted) ShowCaseWidget.of(context).dismiss();
                      },
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuItem(
                          context,
                          title: L10nDoctor.home.tr(),
                          icon: Icons.home,
                          isSelected: currentIndex == 0,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                settings: RouteSettings(name: 'doctor-home'),
                                builder: (context) => DoctorHomeScreen(),
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          context,
                          title: L10nDoctor.addANewCase.tr(),
                          icon: Icons.add_circle_outline,
                          isSelected: currentIndex == 1,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                settings: RouteSettings(name: 'add-case'),
                                builder: (context) => SecondaryHomeScreen(
                                  drawer: const DoctorDrawer(selectedIndex: 1),
                                  showAddCaseCategory: true,
                                ),
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          context,
                          title: L10nDoctor.profile.tr(),
                          icon: Icons.person_outline,
                          isSelected: currentIndex == 2,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                settings: RouteSettings(name: 'doctor-profile'),
                                builder: (context) => DoctorProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Bookings Group
                  Showcase.withWidget(
                    height: 150,
                    width: 280,
                    key: TourConfig.doctorDrawerBookingsKey,
                    container: CustomTourTooltip(
                      title: L10nTour.doctorBookings.tr(),
                      description: L10nTour.doctorBookingsDesc.tr(),
                      onNext: () => ShowCaseWidget.of(context).next(),
                      onSkipTap: () {
                        if (context.mounted) ShowCaseWidget.of(context).dismiss();
                      },
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _menuItem(
                          context,
                          title: L10nDoctor.upcomingReservations.tr(),
                          icon: Icons.event_note_outlined,
                          isSelected: currentIndex == 3,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                settings: RouteSettings(name: 'upcoming-bookings'),
                                builder: (context) => DoctorNextBookingScreen(),
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          context,
                          title: L10nDoctor.bookingHistory.tr(),
                          icon: Icons.history,
                          isSelected: currentIndex == 4,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                settings: RouteSettings(name: 'booking-records'),
                                builder: (context) => DoctorBookingRecordsScreen(),
                              ),
                            );
                          },
                        ),
                        _menuItem(
                          context,
                          title: L10nDoctor.confirmedReservations.tr(),
                          icon: Icons.check_circle_outline,
                          isSelected: currentIndex == 5,
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                settings: RouteSettings(name: 'confirmed-appointments'),
                                builder: (context) => DoctorConfirmedAppointmentsScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Showcase.withWidget(
                    height: 150,
                    width: 280,
                    key: TourConfig.doctorDrawerRequestsKey,
                    container: CustomTourTooltip(
                      title: 'طلباتي',
                      description: 'أدِر طلبات الحالات التي نشرتها',
                      onNext: () => ShowCaseWidget.of(context).next(),
                      onSkipTap: () {
                        if (context.mounted) ShowCaseWidget.of(context).dismiss();
                      },
                      isLast: true,
                    ),
                    child: _menuItem(
                    context,
                    title: L10nDoctor.myRequests.tr(),
                    icon: Icons.assignment_outlined,
                    isSelected: currentIndex == 6,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          settings:
                              RouteSettings(name: 'doctor-requests'),
                          builder: (context) => MyRequestsScreen(),
                        ),
                      );
                    },
                  ),
                  ),
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, _) {
                      return _toggleMenuItem(
                        context,
                        title: L10nDoctor.darkMode.tr(),
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(value),
                        icon: Icons.dark_mode_outlined,
                      );
                    },
                  ),
                  _toggleMenuItem(
                    context,
                    title: L10nDoctor.changeLanguage.tr(),
                    value: context.locale.languageCode == 'en',
                    onChanged: (v) {
                      if (v) {
                        context.setLocale(const Locale('en'));
                      } else {
                        context.setLocale(const Locale('ar'));
                      }
                    },
                    icon: Icons.language,
                  ),
                  _menuItem(
                    context,
                    title: L10nDoctor.termsAndConditions.tr(),
                    icon: Icons.description_outlined,
                    isSelected: currentIndex == 7,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'doctor-terms-and-conditions'),
                          builder: (context) =>
                              const DoctorTermsAndConditionsScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    title: L10nDoctor.privacyPolicy.tr(),
                    icon: Icons.shield_outlined,
                    isSelected: currentIndex == 8,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'doctor-privacy-policy'),
                          builder: (context) => const DoctorPrivacyPolicyScreen(),
                        ),
                      );
                    },
                  ),
                  _menuItem(
                    context,
                    title: L10nDoctor.helpAndSupport.tr(),
                    icon: Icons.help_outline,
                    isSelected: currentIndex == 9,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          settings: const RouteSettings(name: 'doctor-help-and-support'),
                          builder: (context) => const DoctorHelpAndSupportScreen(),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(height: 24),
                  ),
                  _menuItem(
                    context,
                    title: L10nDoctor.logOut1.tr(),
                    icon: Icons.logout_outlined,
                    textColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showLogoutConfirmation(context);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  L10nDoctor.version.tr(namedArgs: {'version': _appVersion}),
                  style: textTheme.bodySmall?.copyWith(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      );
    },
   );
  }
}

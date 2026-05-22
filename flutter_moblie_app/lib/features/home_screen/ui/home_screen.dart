import 'package:flutter/material.dart';
import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thoutha_mobile_app/features/home_screen/ui/category_doctors_screen.dart';
import 'package:thoutha_mobile_app/features/home_screen/ui/drawer/drawer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/features/doctor/logic/doctor_cubit.dart';
import 'package:thoutha_mobile_app/features/doctor/logic/doctor_state.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/core/networking/models/city_model.dart';
import 'package:thoutha_mobile_app/core/helpers/responsive_utils.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:showcaseview/showcaseview.dart';
import 'package:thoutha_mobile_app/tour/tour_config.dart';
import 'package:thoutha_mobile_app/tour/tour_service.dart';
import 'package:thoutha_mobile_app/tour/tour_widgets.dart';
import 'package:thoutha_mobile_app/tour/multi_tour_widget.dart';
 import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen(
      {super.key,
      this.drawer,
      this.showAddCaseCategory = false});
  final Widget? drawer;
  final bool showAddCaseCategory;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Instance-specific keys to prevent GlobalKey duplication during transitions
  late GlobalKey _homeMenuKey;
  late GlobalKey _homeCityDropdownKey;
  late GlobalKey _homeChatBannerKey;
  late GlobalKey _homeCategoriesGridKey;
  late GlobalKey _homePromoBannerKey;
  late GlobalKey _homeNotificationKey;

  int? _selectedCityId;
  // All candidate strings returned by Nominatim (state, county, city, etc.)
  List<String> _gpsNameCandidates = [];
  bool _gpsFinished =
      false; // true once GPS attempt completes (success or fail)
  bool _autoSelectApplied = false;
  bool _isLoggedIn = false;
  bool _isDetecting = false;
  String? _gpsFailureMessage; // non-null → show failure banner
  List<CityModel> _loadedCities = [];
  bool _isTourStarted = false;

  late final DoctorCubit _doctorCubit;

  // Asset mapping for categories (keys are Arabic names from server)
  final Map<String, String> _categoryAssets = {
    'املغم': 'assets/svg/املغم.svg',
    'حشو املجم': 'assets/svg/املغم.svg',
    'حشو عصب': 'assets/svg/حشو اسنان.svg',
    'تجميلي': 'assets/svg/تجميلي.svg',
    'زراعه اسنان': 'assets/svg/زراعه اسنان.svg',
    'زراعة الأسنان': 'assets/svg/زراعه اسنان.svg',
    'خلع اسنان': 'assets/svg/خلع اسنان.svg',
    'الجراحة وخلع': 'assets/svg/خلع اسنان.svg',
    'تبيض اسنان': 'assets/svg/تبيض اسنان.svg',
    'تنظيف وتبييض الأسنان': 'assets/svg/تبيض اسنان.svg',
    'تقويم اسنان': 'assets/svg/تقويم اسنان.svg',
    'تقويم الأسنان': 'assets/svg/تقويم اسنان.svg',
    'تركيبات اسنان': 'assets/svg/تركيبات اسنان.svg',
    'تيجان وجسور': 'assets/images/تيجان وجسور.webp',
    'طب أسنان الأطفال': 'assets/svg/اطفال2.svg',
    'تركيبات متحركة': 'assets/svg/تركيبات اسنان.svg',
    'فحص شامل': 'assets/svg/فحص شامل.svg',
  };

  final Map<String, String> _categoryTranslations = {
    'فحص شامل': 'chat.Comprehensive Examination',
    'حشو اسنان': 'doctor.Dental Filling',
    'تجميلي': 'chat.Cosmetic Filler',
    'املغم': 'chat.Amalgam Filling',
    'حشو املجم': 'chat.Amalgam Filling',
    'حشو عصب': 'chat.Nerve Filling',
    'زراعه اسنان': 'chat.Dental Implants',
    'زراعة الأسنان': 'chat.Dental Implants',
    'خلع اسنان': 'chat.Tooth Extraction',
    'الجراحة وخلع': 'chat.Surgery And Extraction',
    'تبيض اسنان': 'chat.Teeth Whitening',
    'تنظيف وتبييض الأسنان': 'chat.Teeth Cleaning And Whitening',
    'تقويم اسنان': 'chat.orthodontics',
    'تقويم الأسنان': 'chat.orthodontics',
    'تيجان وجسور': 'chat.Crowns And Bridges',
    'تركيبات اسنان': 'chat.Dental Prosthetics',
    'تركيبات متحركة': 'chat.Moving Installations',
    'طب أسنان الأطفال': 'chat.Pediatric Dentistry',
  };

  String _getAssetForCategory(String categoryName) {
    String name = categoryName.trim();
    if (_categoryAssets.containsKey(name)) {
      return _categoryAssets[name]!;
    }

    // Normalization to handle variations in Arabic characters
    String normalized = name
        .replaceAll('ة', 'ه')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي');

    if (normalized.contains('فحص') || normalized.toLowerCase().contains('examination') || normalized.toLowerCase().contains('checkup')) return 'assets/svg/فحص شامل.svg';
    if (normalized.contains('املغم') || normalized.contains('املجم') || normalized.toLowerCase().contains('amalgam')) return 'assets/svg/املغم.svg';
    if (normalized.contains('عصب') || normalized.toLowerCase().contains('nerve') || normalized.toLowerCase().contains('root canal')) return 'assets/svg/حشو اسنان.svg';
    if (normalized.contains('تجميلي') || normalized.contains('تحميلي') || normalized.toLowerCase().contains('cosmetic') || normalized.toLowerCase().contains('composite')) return 'assets/svg/تجميلي.svg';
    if (normalized.contains('زراعه') || normalized.contains('زراعة') || normalized.toLowerCase().contains('implant')) return 'assets/svg/زراعه اسنان.svg';
    if (normalized.contains('خلع') || normalized.contains('جراحه') || normalized.contains('جراحة') || normalized.toLowerCase().contains('extraction') || normalized.toLowerCase().contains('surgery')) return 'assets/svg/خلع اسنان.svg';
    if (normalized.contains('تبيض') || normalized.contains('تنظيف') || normalized.toLowerCase().contains('whitening') || normalized.toLowerCase().contains('cleaning')) return 'assets/svg/تبيض اسنان.svg';
    if (normalized.contains('تقويم') || normalized.toLowerCase().contains('orthodontic') || normalized.toLowerCase().contains('brace')) return 'assets/svg/تقويم اسنان.svg';
    if (normalized.contains('تركيبات') || normalized.toLowerCase().contains('prosthetic') || normalized.toLowerCase().contains('installation')) return 'assets/svg/تركيبات اسنان.svg';
    if (normalized.contains('تيجان') || normalized.contains('جسور') || normalized.toLowerCase().contains('crown') || normalized.toLowerCase().contains('bridge')) return 'assets/images/تيجان وجسور.webp';
    if (normalized.contains('اطفال') || normalized.contains('أطفال') || normalized.toLowerCase().contains('pediatric') || normalized.toLowerCase().contains('child')) return 'assets/svg/اطفال2.svg';

    return 'assets/svg/فحص شامل.svg';
  }

  String localizedCategoryName(String category) {
    final name = category.trim();
    if (_categoryTranslations.containsKey(name)) {
      return _categoryTranslations[name]!.tr();
    }
    
    // Check for variations if exact match fails
    String normalized = name
        .replaceAll('ة', 'ه')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي');

    if (normalized.contains('فحص') || normalized.toLowerCase().contains('examination') || normalized.toLowerCase().contains('checkup')) return L10nChat.comprehensiveExamination.tr();
    if (normalized.contains('املغم') || normalized.contains('املجم') || normalized.toLowerCase().contains('amalgam')) return L10nChat.amalgamFilling.tr();
    if (normalized.contains('عصب') || normalized.toLowerCase().contains('nerve') || normalized.toLowerCase().contains('root canal')) return L10nChat.nerveFilling.tr();
    if (normalized.contains('تجميلي') || normalized.contains('تحميلي') || normalized.toLowerCase().contains('cosmetic') || normalized.toLowerCase().contains('composite')) return L10nChat.cosmeticFiller.tr();
    if (normalized.contains('زراعه') || normalized.contains('زراعة') || normalized.toLowerCase().contains('implant')) return L10nChat.dentalImplants.tr();
    if (normalized.contains('خلع') || normalized.contains('جراحه') || normalized.toLowerCase().contains('extraction') || normalized.toLowerCase().contains('surgery')) return L10nChat.surgeryAndExtraction.tr();
    if (normalized.contains('تبيض') || normalized.contains('تنظيف') || normalized.toLowerCase().contains('whitening') || normalized.toLowerCase().contains('cleaning')) return L10nChat.teethCleaningAndWhitening.tr();
    if (normalized.contains('تقويم') || normalized.toLowerCase().contains('orthodontic') || normalized.toLowerCase().contains('brace')) return L10nChat.orthodontics.tr();
    if (normalized.contains('تيجان') || normalized.contains('جسور') || normalized.toLowerCase().contains('crown') || normalized.toLowerCase().contains('bridge')) return L10nChat.crownsAndBridges.tr();
    if (normalized.contains('تركيبات') || normalized.toLowerCase().contains('prosthetic') || normalized.toLowerCase().contains('installation')) return L10nChat.dentalProsthetics.tr();
    if (normalized.contains('اطفال') || normalized.toLowerCase().contains('pediatric') || normalized.toLowerCase().contains('child')) return L10nChat.pediatricDentistry.tr();

    return category;
  }

  Future<void> _handleCategoryTap({
    required String categoryName,
    required int? categoryId,
    required String? cityName,
  }) async {
    // Navigation restricted to CategoryDoctorsScreen
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDoctorsScreen(
          categoryName: categoryName,
          categorySvg: _getAssetForCategory(categoryName),
          categoryId: categoryId,
          cityId: _selectedCityId,
          cityName: cityName,
        ),
      ),
    );
  }

   Widget _buildSquareCategory(String assetPath, int index, String categoryName,
       {int? categoryId, String? cityName}) {
     final isDark = Theme.of(context).brightness == Brightness.dark;
     final screenW = MediaQuery.of(context).size.width;
     final double fontSize = (screenW * 0.033).clamp(11.0, 15.0);

     final defaultAssetPaths = [
       'assets/svg/املغم.svg',
       'assets/svg/حشو اسنان.svg',
       'assets/svg/تجميلي.svg',
       'assets/svg/زراعه اسنان.svg',
       'assets/svg/خلع اسنان.svg',
       'assets/svg/تبيض اسنان.svg',
       'assets/svg/تقويم اسنان.svg',
       'assets/svg/تركيبات اسنان.svg',
       'assets/images/تيجان وجسور.webp',
       'assets/svg/اطفال2.svg',
       'assets/svg/تركيبات اسنان.svg',
     ];

    final defaultCategoryNames = [
      'املغم',
      'حشو عصب',
      'تجميلي',
      'زراعة الأسنان',
      'الجراحة وخلع',
      'تنظيف وتبييض الأسنان',
      'تقويم الأسنان',
      'تركيبات اسنان',
      'تيجان وجسور',
      'طب أسنان الأطفال',
      'تركيبات متحركة',
    ];

    final resolvedAssetPath = assetPath.isNotEmpty 
        ? assetPath 
        : (index < defaultAssetPaths.length ? defaultAssetPaths[index] : 'assets/svg/فحص شامل.svg');
    
    final rawCategoryName = categoryName.isNotEmpty
        ? categoryName
        : (index < defaultCategoryNames.length ? defaultCategoryNames[index] : '');

    return GestureDetector(
      onTap: () {
        _handleCategoryTap(
          categoryName: rawCategoryName,
          categoryId: categoryId,
          cityName: cityName,
        );
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: resolvedAssetPath.contains('تقويم اسنان') ? 16.0 : 12.0,
                  vertical: resolvedAssetPath.contains('تقويم اسنان') ? 11.0 : 0.0,
                ),
                child: resolvedAssetPath.endsWith('.svg')
                    ? SvgPicture.asset(
                        resolvedAssetPath,
                        fit: BoxFit.contain,
                        placeholderBuilder: (BuildContext context) => Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: const Icon(Icons.image, size: 32, color: Colors.grey),
                        ),
                      )
                    : Image.asset(
                        resolvedAssetPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: isDark ? Colors.grey[800] : Colors.grey[200],
                          child: const Icon(Icons.image, size: 32, color: Colors.grey),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                localizedCategoryName(rawCategoryName),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                      height: 1.2,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
   }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Unique keys for THIS instance
    _homeMenuKey = GlobalKey(debugLabel: 'home_menu_${DateTime.now().microsecondsSinceEpoch}');
    _homeCityDropdownKey = GlobalKey(debugLabel: 'home_city_${DateTime.now().microsecondsSinceEpoch}');
    _homeChatBannerKey = GlobalKey(debugLabel: 'home_chat_${DateTime.now().microsecondsSinceEpoch}');
    _homeCategoriesGridKey = GlobalKey(debugLabel: 'home_grid_${DateTime.now().microsecondsSinceEpoch}');
    _homePromoBannerKey = GlobalKey(debugLabel: 'home_promo_${DateTime.now().microsecondsSinceEpoch}');
    _homeNotificationKey = GlobalKey(debugLabel: 'home_notification_${DateTime.now().microsecondsSinceEpoch}');

    _doctorCubit = getIt<DoctorCubit>()..loadInitialData();
    WidgetsBinding.instance.addObserver(this);
    _checkLoginStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-detect city when app comes back to foreground
      _resetAndDetectCity();
    }
  }

  void _resetAndDetectCity() {
    if (!mounted) return;
    setState(() {
      _autoSelectApplied = false;
      _gpsFinished = false;
      _gpsNameCandidates = [];
      _gpsFailureMessage = null;
      _selectedCityId = null;
    });
    _autoDetectCity();
  }

  Future<void> _checkLoginStatus() async {
    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
    if (mounted) {
      setState(() {
        _isLoggedIn = token.isNotEmpty && token != 'null';
        // Reset auto-detect flags every time so GPS detection runs fresh
        _autoSelectApplied = false;
        _gpsFinished = false;
        _gpsNameCandidates = [];
        _gpsFailureMessage = null;
        _selectedCityId = null;
      });
      // Auto-detect city for all users (logged in or not)
      _autoDetectCity();
    }
  }

  // ── GPS helpers ──────────────────────────────────────────────────────────

  /// Strips common Arabic administrative prefixes Nominatim adds.
  String _stripPrefix(String s) => s
      .replaceAll(RegExp(r'^محافظة\s*'), '')
      .replaceAll(RegExp(r'^مديرية\s*'), '')
      .replaceAll(RegExp(r'^مدينة\s*'), '')
      .replaceAll(RegExp(r'^قسم\s*'), '')
      .replaceAll(RegExp(r'\s*محافظة$'), '')
      .trim();

  /// Returns true if [a] and [b] refer to the same governorate.
  bool _namesMatch(String a, String b) {
    final na = _stripPrefix(a.trim());
    final nb = _stripPrefix(b.trim());
    if (na.isEmpty || nb.isEmpty) return false;
    if (na == nb) return true;
    if (na.length >= 4 && nb.contains(na)) return true;
    if (nb.length >= 4 && na.contains(nb)) return true;
    return false;
  }

  /// Tries to match any GPS candidate against the loaded cities list.
  void _tryAutoSelectCity() {
    if (_autoSelectApplied || _selectedCityId != null) return;
    if (!_gpsFinished || _loadedCities.isEmpty) return;

    _autoSelectApplied = true;

    CityModel? match;
    outer:
    for (final raw in _gpsNameCandidates) {
      for (final c in _loadedCities) {
        if (_namesMatch(raw, c.name)) {
          match = c;
          break outer;
        }
      }
    }

    if (match != null) {
      setState(() {
        _selectedCityId = match!.id;
        _gpsFailureMessage = null;
      });
      // Optionally trigger search automatically
      _doctorCubit.filterByCity(match.id);
    } else {
      setState(() {
        _gpsFailureMessage =
            L10nDoctor.theApplicationWasUnable.tr();
      });
    }
  }

  Future<void> _autoDetectCity() async {
    if (mounted) setState(() => _isDetecting = true);
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          setState(() {
            _gpsFinished = true;
            _gpsFailureMessage =
                L10nDoctor.locationPermissionHasBeen.tr();
          });
        }
        return;
      }
      if (perm == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _gpsFinished = true;
            _gpsFailureMessage = L10nDoctor.theLocationCannotBe.tr();
          });
        }
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          setState(() {
            _gpsFinished = true;
            _gpsFailureMessage =
                L10nDoctor.theLocationServiceIs.tr();
          });
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final dio = Dio();
      final resAr = await dio.get(
        'https://nominatim.openstreetmap.org/reverse',
        queryParameters: {
          'lat': pos.latitude,
          'lon': pos.longitude,
          'format': 'json',
          'accept-language': 'ar',
        },
        options: Options(
          headers: {'User-Agent': 'ThothaApp/1.0'},
          receiveTimeout: Duration(seconds: 10),
        ),
      );

      final candidates = <String>[];
      const addressKeys = [
        'state',
        'county',
        'city',
        'town',
        'village',
        'state_district',
        'region',
        'municipality'
      ];

      if (resAr.statusCode == 200 && resAr.data is Map) {
        final address = resAr.data['address'] as Map?;
        if (address != null) {
          for (final key in addressKeys) {
            final v = address[key];
            if (v is String && v.isNotEmpty) candidates.add(v);
          }
        }
      }

      if (mounted) {
        setState(() => _gpsNameCandidates = candidates);
      }
    } catch (_) {
      // Silently fail, _tryAutoSelectCity will handle the empty candidates
    } finally {
      if (mounted) {
        setState(() {
          _gpsFinished = true;
          _isDetecting = false;
        });
        _tryAutoSelectCity();
      }
    }
  }

  /// Returns only the steps belonging to [screenName], with instance keys.
  List<TourStep> _getStepsForHome() {
    return [
      TourStep(id: 'home_menu', key: _homeMenuKey, title: 'القائمة الرئيسية', description: 'اضغط هنا لفتح القائمة الجانبية والوصول للإعدادات', screen: 'home'),
      TourStep(id: 'home_promo_banner', key: _homePromoBannerKey, title: 'بانر الحجز', description: 'تعرّف على خدمات الحجز مع أفضل أطباء الأسنان', screen: 'home'),
      TourStep(id: 'home_city_dropdown', key: _homeCityDropdownKey, title: 'اختيار المحافظة', description: 'اختر محافظتك لعرض الأطباء القريبين منك', screen: 'home'),
      TourStep(id: 'home_chat_banner', key: _homeChatBannerKey, title: 'مساعد ثوثة الذكي', description: 'لا تعرف ماذا تحتاج؟ اضغط هنا للتحدث مع المساعد الذكي', screen: 'home'),
      TourStep(id: 'home_categories_grid', key: _homeCategoriesGridKey, title: 'الخدمات المتاحة', description: 'اختر التخصص المطلوب لعرض الأطباء وحجز موعد', screen: 'home'),
      TourStep(id: 'home_notification', key: _homeNotificationKey, title: L10nNotifications.notifications.tr(), description: L10nNotifications.clickOnTheIcon.tr(), screen: 'home'),
    ];
  }

  Future<void> _startTour(BuildContext context) async {
    final steps = _getStepsForHome();
    final unseenGroups = <List<TourStep>>[];
    
    // Logic to show only unseen steps
    for (final step in steps) {
        final seen = await TourService.hasBeenSeen(step.id);
        if (!seen) {
          unseenGroups.add([step]);
        }
    }
    
    if (unseenGroups.isEmpty) return;
    
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!context.mounted) return;
      if (mounted) {
        final tour = MultiTourWidget.of(context);
        if (tour != null) {
          tour.startTour(unseenGroups);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider.value(
      value: _doctorCubit,
      child: MultiTourWidget(
        child: ShowCaseWidget(
        onComplete: (index, key) {
          final steps = _getStepsForHome();
          try {
            for (final s in steps) {
              if (s.key == key) {
                TourService.markSeen(s.id);
                break;
              }
            }
          } catch (_) {}
        },
        builder: (context) {
          if (!_isTourStarted) {
            _isTourStarted = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _startTour(context);
            });
          }
          return Scaffold(
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: Showcase.withWidget(
            height: 150,
            width: 280,
            key: _homeMenuKey,
            container: CustomTourTooltip(
              title: 'القائمة الرئيسية',
              description: 'اضغط هنا لفتح القائمة الجانبية والوصول للإعدادات',
              onNext: () => ShowCaseWidget.of(context).next(),
              onSkipTap: () {
                if (context.mounted) ShowCaseWidget.of(context).dismiss();
              },
            ),
            child: IconButton(
              icon: Icon(
                Icons.menu,
                size: 24,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          actions: [
            // Blue notification bell for patients
            Showcase.withWidget(
              height: 150,
              width: 280,
              key: _homeNotificationKey,
              container: CustomTourTooltip(
                title: L10nNotifications.notifications.tr(),
                description: L10nNotifications.clickOnTheIcon.tr(),
                onNext: () {
                  TourService.markSeen('home_notification');
                  ShowCaseWidget.of(context).next();
                },
                onSkipTap: () {
                  if (context.mounted) ShowCaseWidget.of(context).dismiss();
                },
                isLast: true,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.notifications_active,
                  size: 28,
                  color: Colors.blue,
                ),
                onPressed: () {
                  TourService.markSeen('home_notification');
                  Navigator.pushNamed(
                    context,
                    Routes.patientNotificationsScreen,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
          ],
        ),
        drawer: widget.drawer ?? const HomeDrawer(),
        body: SafeArea(
          child: BlocConsumer<DoctorCubit, DoctorState>(
            listener: (context, state) {
              if (!_isLoggedIn &&
                  state is DoctorSuccess &&
                  state.cities.isNotEmpty) {
                _loadedCities = state.cities;
                _tryAutoSelectCity();
              }
            },
            builder: (context, state) {
              if (state is DoctorLoading) {
                return Center(child: CircularProgressIndicator());
              } else if (state is DoctorError) {
                return Center(
                    child: Text(state.error,
                        style: TextStyle(fontFamily: 'Cairo')));
              } else if (state is DoctorSuccess) {
                final categories = state.categories;
                final cities = state.cities;

                final visibleCategories = categories;

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [


                      // Tour: Promotional Card
                      Showcase.withWidget(
                height: 150,
                width: 280,
                        key: _homePromoBannerKey,
                        container: CustomTourTooltip(
                          title: 'بانر الحجز',
                          description: 'تعرّف على خدمات الحجز مع أفضل أطباء الأسنان',
                          onNext: () => ShowCaseWidget.of(context).next(),
                          onSkipTap: () {
                            if (context.mounted) ShowCaseWidget.of(context).dismiss();
                          },
                        ),
                        child: Builder(builder: (context) {
                          final cardW = MediaQuery.of(context).size.width;
                          final cardH = (cardW * 0.36).clamp(120.0, 180.0);
                          return Container(
                            width: double.infinity,
                            height: cardH,
                            margin: EdgeInsets.symmetric(
                                horizontal: cardW * 0.05,
                                vertical: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [Color(0xFF95F8C9), Color(0xFF54CAF7)],
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Flexible(
                                  flex: 4,
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Image.asset(
                                      'assets/images/دكتور.png',
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Flexible(
                                  flex: 6,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, right: 16, bottom: 16, left: 8),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          L10nHomeScreen.bookAndRegister.tr(),
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color: Colors.white,
                                            fontSize: (cardW * 0.04).clamp(13.0, 18.0),
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          L10nHomeScreen.withTheBestDoctors.tr(),
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            color: Colors.white,
                                            fontSize: (cardW * 0.033).clamp(11.0, 15.0),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.start,
                                        ),
                                        SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            L10nHomeScreen.bookNow1.tr(),
                                            style: TextStyle(
                                              fontFamily: 'Cairo',
                                              color: Colors.black,
                                              fontSize: (cardW * 0.028).clamp(10.0, 13.0),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      // Tour: City Dropdown
                      Showcase.withWidget(
                height: 150,
                width: 280,
                        key: _homeCityDropdownKey,
                        container: CustomTourTooltip(
                          title: 'اختيار المحافظة',
                          description: 'اختر محافظتك لعرض الأطباء القريبين منك',
                          onNext: () => ShowCaseWidget.of(context).next(),
                          onSkipTap: () {
                            if (context.mounted) ShowCaseWidget.of(context).dismiss();
                          },
                        ),
                        child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.screenWidth(context) * 0.06,
                            vertical: 16),
                        child: Container(
                          height: 52,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey[700]!
                                  : Color(0xFFD1D5DC),
                              width: 1.1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _selectedCityId,
                              hint: Row(
                                children: [
                                  Icon(
                                    _isDetecting
                                        ? Icons.location_searching
                                        : Icons.my_location,
                                    size: 16,
                                    color: _isDetecting
                                        ? Theme.of(context).colorScheme.primary
                                        : (isDark ? Colors.white70 : Colors.grey[500]),
                                  ),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      _isDetecting
                                          ? L10nDoctor.locatingYourLocation.tr()
                                          : L10nDoctor.selectCity.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontFamily: 'Cairo',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              isExpanded: true,
                              icon: _isDetecting
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    )
                                  : Icon(Icons.arrow_drop_down,
                                      color: Theme.of(context).iconTheme.color),
                              items: cities.map((city) {
                                return DropdownMenuItem<int>(
                                  value: city.id,
                                  child: Text(
                                    city.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontFamily: 'Cairo',
                                          fontSize: 14,
                                        ),
                                    textAlign: TextAlign.start,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedCityId = val;
                                  _gpsFailureMessage = null;
                                });
                                if (val != null) {
                                  _doctorCubit.filterByCity(val);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      ),

                      // GPS failure banner
                      if (!_isLoggedIn && _gpsFailureMessage != null)
                        Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.screenWidth(context) * 0.06),
                          padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.orange.withValues(alpha: 0.15)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: isDark
                                    ? Colors.orange.shade700
                                    : Colors.orange.shade300,
                                width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.location_off,
                                  color: isDark
                                      ? Colors.orange[300]
                                      : Colors.orange,
                                  size: 18),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _gpsFailureMessage!,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : Colors.orange.shade800,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Tour: Chatbot Banner
                      Showcase.withWidget(
                height: 150,
                width: 280,
                        key: _homeChatBannerKey,
                        container: CustomTourTooltip(
                          title: 'مساعد ثوثة الذكي',
                          description: 'لا تعرف ماذا تحتاج؟ اضغط هنا للتحدث مع المساعد الذكي',
                          onNext: () => ShowCaseWidget.of(context).next(),
                          onSkipTap: () {
                            if (context.mounted) ShowCaseWidget.of(context).dismiss();
                          },
                        ),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, Routes.chatScreen);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: ResponsiveUtils.screenWidth(context) * 0.05,
                                vertical: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Color(0xFF54CAF7), width: 1.5),
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/svg/ثوثه الدكتور 1.svg',
                                  ),
                                ),
                                SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    L10nHomeScreen.ifYouDontKnow.tr(),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Services Header
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12),
                        child: Text(
                          L10nHomeScreen.availableServices.tr(),
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontFamily: 'Cairo',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                    height: 1.2,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Tour: Categories Grid
                      if (visibleCategories.isNotEmpty)
                        Showcase.withWidget(
                height: 150,
                width: 280,
                          key: _homeCategoriesGridKey,
                          container: CustomTourTooltip(
                            title: 'الخدمات المتاحة',
                            description: 'اختر التخصص المطلوب لعرض الأطباء وحجز موعد',
                            onNext: () => ShowCaseWidget.of(context).next(),
                            onSkipTap: () {
                              if (context.mounted) ShowCaseWidget.of(context).dismiss();
                            },
                            isLast: true,
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: ResponsiveUtils.screenWidth(context) * 0.05),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final crossAxisCount = ResponsiveUtils.screenWidth(context) > 600 ? 4 : 2;
                                return GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 1.0,
                                  ),
                                  itemCount: visibleCategories.length,
                                  itemBuilder: (context, index) {
                                    final category = visibleCategories[index];
                                    final asset =
                                        _getAssetForCategory(category.name);

                                    String? selectedCityName;
                                    if (_selectedCityId != null) {
                                      try {
                                        selectedCityName = cities
                                            .firstWhere(
                                                (c) => c.id == _selectedCityId)
                                            .name;
                                      } catch (_) {}
                                    }

                                    return _buildSquareCategory(
                                        asset, index, category.name,
                                        categoryId: category.id,
                                        cityName: selectedCityName);
                                  },
                                );
                              },
                            ),
                          ),
                        ),

                      SizedBox(height: 20),
                    ],
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    },
        ),
      ),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'core/di/dependency_injection.dart';
import 'core/services/firebase_background_handler.dart';
import 'core/routing/app_router.dart';
import 'core/services/firebase_messaging_service.dart';
import 'features/notifications/data/repos/notification_repo.dart';
import 'core/helpers/shared_pref_helper.dart';
import 'core/helpers/constants.dart';
import 'doc_app.dart';
import 'firebase_options.dart';

import 'package:easy_localization/easy_localization.dart' hide TextDirection;

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Register background handler for data-only FCM payloads
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Setup Dependency Injection
  await setupGetIt();

  // Initialize Firebase Messaging Service
  final firebaseMessagingService = getIt<FirebaseMessagingService>();
  final notificationRepo = getIt<INotificationRepo>();
  await firebaseMessagingService.initialize(notificationRepo);

  // Initialize Arabic locale data for date formatting
  await initializeDateFormatting('ar');

  // Allow all orientations so layouts can adapt on tablets and landscape.
  await SystemChrome.setPreferredOrientations(DeviceOrientation.values);

  // Clear chat history at app startup (so it only persists during the current session)
  await SharedPrefHelper.removeData(SharedPrefKeys.chatHistory);
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      useFallbackTranslations: true,
      useFallbackTranslationsForEmptyResources: true,
      child: DocApp(
        appRouter: AppRouter(),
      ),
    ),
  );
}

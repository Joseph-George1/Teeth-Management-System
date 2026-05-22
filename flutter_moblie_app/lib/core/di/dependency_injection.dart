import 'package:get_it/get_it.dart';
import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/core/services/firebase_messaging_service.dart';
import 'package:thoutha_mobile_app/features/doctor/data/repos/doctor_repository.dart';
import 'package:thoutha_mobile_app/features/requests/data/repos/case_request_repo.dart';
import 'package:thoutha_mobile_app/features/doctor/logic/doctor_cubit.dart';
import 'package:thoutha_mobile_app/features/notifications/data/repos/notification_repo.dart';
import 'package:thoutha_mobile_app/features/notifications/logic/notifications_cubit.dart';
import 'package:thoutha_mobile_app/features/profile/data/repos/profile_repository.dart';
import 'package:thoutha_mobile_app/features/profile/logic/profile_cubit.dart';
import 'package:thoutha_mobile_app/features/requests/data/logic/my_requests_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());
  getIt.registerLazySingleton<FirebaseMessagingService>(
    () => FirebaseMessagingService(),
  );

  // Repositories
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepository(getIt()),
  );
  getIt.registerLazySingleton<CaseRequestRepo>(
    () => CaseRequestRepo(getIt()),
  );
  getIt.registerLazySingleton<INotificationRepo>(
    () => NotificationRepo(getIt<ApiService>()),
  );
  // Also register the implementation type to avoid resolution issues
  getIt.registerLazySingleton<NotificationRepo>(
    () => NotificationRepo(getIt<ApiService>()),
  );
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(),
  );

  // Cubits
  getIt.registerFactory<DoctorCubit>(
    () => DoctorCubit(getIt()),
  );
  getIt.registerFactory<ProfileCubit>(
    () => ProfileCubit(getIt()),
  );
  getIt.registerFactory<MyRequestsCubit>(
    () => MyRequestsCubit(getIt()),
  );
  getIt.registerFactory<NotificationsCubit>(
    () => NotificationsCubit(getIt()),
  );
}

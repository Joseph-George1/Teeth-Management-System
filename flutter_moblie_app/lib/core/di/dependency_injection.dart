import 'package:get_it/get_it.dart';
import 'package:thotha_mobile_app/core/networking/api_service.dart';
import 'package:thotha_mobile_app/features/home_screen/data/repositories/doctor_repository.dart';
import 'package:thotha_mobile_app/features/home_screen/logic/doctor_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupGetIt() async {
  // Services
  getIt.registerLazySingleton<ApiService>(() => ApiService());

  // Repositories
  getIt.registerLazySingleton<DoctorRepository>(
    () => DoctorRepository(getIt()),
  );

  // Cubits
  getIt.registerFactory<DoctorCubit>(
    () => DoctorCubit(getIt()),
  );
}

import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';

abstract class DoctorState {}

class DoctorInitial extends DoctorState {}

class DoctorLoading extends DoctorState {}

class DoctorSuccess extends DoctorState {
  final List<DoctorModel> doctors;
  final List<CategoryModel> categories;
  final List<CityModel> cities;

  DoctorSuccess({
    required this.doctors,
    required this.categories,
    required this.cities,
  });
}

class DoctorError extends DoctorState {
  final String error;
  DoctorError(this.error);
}

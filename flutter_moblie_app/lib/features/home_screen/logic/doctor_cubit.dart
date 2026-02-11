import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/repositories/doctor_repository.dart';
import 'package:thotha_mobile_app/features/home_screen/logic/doctor_state.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository _repository;

  List<CategoryModel> _categories = [];
  List<CityModel> _cities = [];

  DoctorCubit(this._repository) : super(DoctorInitial());

  // Load initial reference data (categories & cities)
  Future<void> loadInitialData() async {
    emit(DoctorLoading());

    try {
      // Parallel execution for faster loading
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getCities(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _cities = results[1] as List<CityModel>;

      // Initially show empty doctors list, but with loaded filters
      emit(DoctorSuccess(
        doctors: [],
        categories: _categories,
        cities: _cities,
      ));
    } catch (e) {
      print('=== DoctorCubit Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
      emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> filterByCity(int cityId) async {
    emit(DoctorLoading());
    try {
      final doctors = await _repository.getDoctorsByCity(cityId);
      emit(DoctorSuccess(
        doctors: doctors,
        categories: _categories,
        cities: _cities,
      ));
    } catch (e) {
      print('=== DoctorCubit Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
      emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> filterByCategory(int categoryId) async {
    emit(DoctorLoading());
    try {
      final doctors = await _repository.getDoctorsByCategory(categoryId);
      emit(DoctorSuccess(
        doctors: doctors,
        categories: _categories,
        cities: _cities,
      ));
    } catch (e) {
      print('=== DoctorCubit Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
      emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> filterByCategoryName(String categoryName) async {
    emit(DoctorLoading());
    try {
      if (_categories.isEmpty) {
        _categories = await _repository.getCategories();
      }
      final category = _categories.firstWhere(
        (c) => c.name.trim() == categoryName.trim(),
        orElse: () => CategoryModel(id: -1, name: ''),
      );

      if (category.id != -1) {
        // We found the category, so we delegate to the ID-based filter
        // Note: filterByCategory emits Loading again, which is fine.
        await filterByCategory(category.id);
      } else {
        emit(DoctorError('عفواً، هذا التخصص غير متوفر حالياً'));
      }
    } catch (e) {
      print('=== DoctorCubit Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
      emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> filterByCategoryAndCity(int categoryId, String cityName) async {
    emit(DoctorLoading());
    try {
      final allDoctors = await _repository.getDoctorsByCategory(categoryId);
      final filteredDoctors = allDoctors
          .where((doctor) => doctor.cityName.trim() == cityName.trim())
          .toList();

      emit(DoctorSuccess(
        doctors: filteredDoctors,
        categories: _categories,
        cities: _cities,
      ));
    } catch (e) {
      print('=== DoctorCubit Error ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');
      print('Stack trace: ${StackTrace.current}');
      emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> filterByCategoryNameAndCity(String categoryName, String cityName) async {
    emit(DoctorLoading());
    try {
      if (_categories.isEmpty) {
        _categories = await _repository.getCategories();
      }
      final category = _categories.firstWhere(
        (c) => c.name.trim() == categoryName.trim(),
        orElse: () => CategoryModel(id: -1, name: ''),
      );

      if (category.id != -1) {
        await filterByCategoryAndCity(category.id, cityName);
      } else {
        emit(DoctorError('عفواً، هذا التخصص غير متوفر حالياً'));
      }
    } catch (e) {
       print('=== DoctorCubit Error ===');
       print('Error type: ${e.runtimeType}');
       print('Error message: ${e.toString()}');
       print('Stack trace: ${StackTrace.current}');
       emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }

}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/case_request_model.dart';
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
      final results = await Future.wait([
        _repository.getDoctorsByCategory(categoryId),
        _repository.getCaseRequestsByCategory(categoryId),
      ]);
      
      final doctors = results[0] as List<DoctorModel>;
      final caseRequests = results[1] as List<CaseRequestModel>;
      
      emit(DoctorSuccess(
        doctors: doctors,
        caseRequests: caseRequests,
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
      final results = await Future.wait([
        _repository.getDoctorsByCategory(categoryId),
        _repository.getCaseRequestsByCategory(categoryId),
      ]);

      final allDoctors = results[0] as List<DoctorModel>;
      final allRequests = results[1] as List<CaseRequestModel>; // We might want to filter requests by city too, but model has location string not cityId

      final filteredDoctors = allDoctors
          .where((doctor) => doctor.cityName.trim() == cityName.trim())
          .toList();

      // Filter requests by city name (client-side since API doesn't support it yet)
      final filteredRequests = allRequests
          .where((request) => request.location.contains(cityName.trim()) || request.doctor.cityName == cityName.trim())
          .toList();

      emit(DoctorSuccess(
        doctors: filteredDoctors,
        caseRequests: filteredRequests,
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

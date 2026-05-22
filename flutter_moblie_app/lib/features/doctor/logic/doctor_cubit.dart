import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/networking/models/category_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/city_model.dart';
import 'package:thoutha_mobile_app/features/doctor/data/repos/doctor_repository.dart';
import 'package:thoutha_mobile_app/features/doctor/logic/doctor_state.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class DoctorCubit extends Cubit<DoctorState> {
  final DoctorRepository _repository;

  List<CategoryModel> _categories = [];
  List<CityModel> _cities = [];

  DoctorCubit(this._repository) : super(DoctorInitial());

  // Load initial reference data (categories & cities)
  Future<void> loadInitialData({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      if (_categories.isNotEmpty && _cities.isNotEmpty) {
        emit(DoctorSuccess(
          doctors: state is DoctorSuccess ? (state as DoctorSuccess).doctors : [],
          categories: _categories,
          cities: _cities,
        ));
        return;
      }

      // Try to load from SharedPreferences first
      try {
        final cachedCatsStr = await SharedPrefHelper.getString('cached_categories');
        final cachedCitiesStr = await SharedPrefHelper.getString('cached_cities');
        if (cachedCatsStr.isNotEmpty && cachedCitiesStr.isNotEmpty) {
          final List catsJson = json.decode(cachedCatsStr) as List;
          final List citiesJson = json.decode(cachedCitiesStr) as List;
          _categories = catsJson.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
          _cities = citiesJson.map((e) => CityModel.fromJson(e as Map<String, dynamic>)).toList();

          emit(DoctorSuccess(
            doctors: state is DoctorSuccess ? (state as DoctorSuccess).doctors : [],
            categories: _categories,
            cities: _cities,
          ));
          // Trigger background fetch to silently update the cache
          _fetchInitialDataSilently();
          return;
        }
      } catch (e) {
        debugPrint('Error loading cached categories/cities: $e');
      }
    }

    emit(DoctorLoading());
    try {
      await _fetchInitialData();
    } catch (e) {
      debugPrint('=== DoctorCubit Error ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');
      emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> _fetchInitialData() async {
    final results = await Future.wait([
      _repository.getCategories(),
      _repository.getCities(),
    ]);

    _categories = results[0] as List<CategoryModel>;
    _cities = results[1] as List<CityModel>;

    emit(DoctorSuccess(
      doctors: state is DoctorSuccess ? (state as DoctorSuccess).doctors : [],
      categories: _categories,
      cities: _cities,
    ));

    // Save to cache
    await SharedPrefHelper.setData('cached_categories', json.encode(_categories.map((e) => e.toJson()).toList()));
    await SharedPrefHelper.setData('cached_cities', json.encode(_cities.map((e) => e.toJson()).toList()));
  }

  Future<void> _fetchInitialDataSilently() async {
    try {
      final results = await Future.wait([
        _repository.getCategories(),
        _repository.getCities(),
      ]);

      _categories = results[0] as List<CategoryModel>;
      _cities = results[1] as List<CityModel>;

      emit(DoctorSuccess(
        doctors: state is DoctorSuccess ? (state as DoctorSuccess).doctors : [],
        categories: _categories,
        cities: _cities,
      ));

      await SharedPrefHelper.setData('cached_categories', json.encode(_categories.map((e) => e.toJson()).toList()));
      await SharedPrefHelper.setData('cached_cities', json.encode(_cities.map((e) => e.toJson()).toList()));
    } catch (e) {
      debugPrint('Error silently fetching categories/cities: $e');
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
      debugPrint('=== DoctorCubit Error ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');
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
      debugPrint('=== DoctorCubit Error ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');
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
        emit(DoctorError(L10nDoctor.sorryThisSpecialtyIs.tr()));
      }
    } catch (e) {
      debugPrint('=== DoctorCubit Error ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');
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
      debugPrint('=== DoctorCubit Error ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');
      emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }

  Future<void> filterByCategoryNameAndCity(
      String categoryName, String cityName) async {
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
        emit(DoctorError(L10nDoctor.sorryThisSpecialtyIs.tr()));
      }
    } catch (e) {
      debugPrint('=== DoctorCubit Error ===');
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error message: ${e.toString()}');
      debugPrint('Stack trace: ${StackTrace.current}');
      emit(DoctorError('حدث خطأ: ${e.toString()}'));
    }
  }
}

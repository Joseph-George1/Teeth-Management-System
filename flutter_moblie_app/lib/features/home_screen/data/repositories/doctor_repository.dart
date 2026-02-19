import 'package:thotha_mobile_app/core/networking/api_service.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/case_request_model.dart';

class DoctorRepository {
  final ApiService _apiService;

  DoctorRepository(this._apiService);

  Future<List<DoctorModel>> getDoctorsByCity(int cityId) async {
    final result = await _apiService.getDoctorsByCity(cityId);
    if (result['success'] == true) {
      return result['data'] as List<DoctorModel>;
    }
    throw Exception(result['error'] ?? 'فشل في تحميل الأطباء');
  }

  Future<List<DoctorModel>> getDoctorsByCategory(int categoryId) async {
    final result = await _apiService.getDoctorsByCategory(categoryId);
    if (result['success'] == true) {
      return result['data'] as List<DoctorModel>;
    }
    throw Exception(result['error'] ?? 'فشل في تحميل الأطباء');
  }

  Future<List<CaseRequestModel>> getCaseRequestsByCategory(int categoryId) async {
    final result = await _apiService.getCaseRequestsByCategory(categoryId);
    if (result['success'] == true) {
      return result['data'] as List<CaseRequestModel>;
    }
    throw Exception(result['error'] ?? 'فشل في تحميل الطلبات');
  }

  Future<List<CategoryModel>> getCategories() async {
    final result = await _apiService.getCategories();
    if (result['success'] == true) {
      return result['data'] as List<CategoryModel>;
    }
    throw Exception(result['error'] ?? 'فشل في تحميل التخصصات');
  }

  Future<List<CityModel>> getCities() async {
    final result = await _apiService.getCities();
    if (result['success'] == true) {
      return result['data'] as List<CityModel>;
    }
    throw Exception(result['error'] ?? 'فشل في تحميل المدن');
  }
}

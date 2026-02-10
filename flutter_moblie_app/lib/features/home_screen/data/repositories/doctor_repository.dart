import 'package:thotha_mobile_app/core/networking/api_service.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';

class DoctorRepository {
  final ApiService _apiService;

  DoctorRepository(this._apiService);

  Future<List<DoctorModel>> getDoctorsByCity(int cityId) async {
    final result = await _apiService.getDoctorsByCity(cityId);
    if (result['success'] == true) {
      return result['data'] as List<DoctorModel>;
    } else {
      throw Exception(result['error'] ?? 'Failed to load doctors');
    }
  }

  Future<List<DoctorModel>> getDoctorsByCategory(int categoryId) async {
    final result = await _apiService.getDoctorsByCategory(categoryId);
    if (result['success'] == true) {
      return result['data'] as List<DoctorModel>;
    } else {
      throw Exception(result['error'] ?? 'Failed to load doctors');
    }
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final result = await _apiService.getCategories();
      if (result['success'] == true) {
        return result['data'] as List<CategoryModel>;
      } else {
        throw Exception(result['error'] ?? 'Failed to load categories');
      }
    } catch (e) {
      print('API Error, using mock data: $e');
      // Return mock data if API fails
      return [
        CategoryModel(id: 1, name: 'فحص شامل'),
        CategoryModel(id: 2, name: 'حشو أسنان'),
        CategoryModel(id: 3, name: 'زراعة أسنان'),
        CategoryModel(id: 4, name: 'خلع الأسنان'),
        CategoryModel(id: 5, name: 'تبييض الأسنان'),
        CategoryModel(id: 6, name: 'تقويم الأسنان'),
        CategoryModel(id: 7, name: 'تركيبات الأسنان'),
      ];
    }
  }

  Future<List<CityModel>> getCities() async {
    try {
      final result = await _apiService.getCities();
      if (result['success'] == true) {
        return result['data'] as List<CityModel>;
      } else {
        throw Exception(result['error'] ?? 'Failed to load cities');
      }
    } catch (e) {
      print('API Error, using mock data: $e');
      // Return mock data if API fails
      return [
        CityModel(id: 1, name: 'القاهرة'),
        CityModel(id: 2, name: 'الإسكندرية'),
        CityModel(id: 3, name: 'الجيزة'),
        CityModel(id: 4, name: 'الأقصر'),
        CityModel(id: 5, name: 'أسوان'),
      ];
    }
  }
}

import 'package:thotha_mobile_app/core/networking/api_service.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/case_request_model.dart';

class DoctorRepository {
  final ApiService _apiService;

  DoctorRepository(this._apiService);

  Future<List<DoctorModel>> getDoctorsByCity(int cityId) async {
    try {
      final result = await _apiService.getDoctorsByCity(cityId);
      if (result['success'] == true) {
        return result['data'] as List<DoctorModel>;
      } else {
        throw Exception(result['error'] ?? 'Failed to load doctors');
      }
    } catch (e) {
      print('API Error in getDoctorsByCity, using mock data: $e');
      // Return mock data filtered by cityId (for now just return all mock data)
      return _getMockDoctors().where((d) {
        // In a real app we'd filter by ID, but for mock data we'll just return a subset or all
        // depending on how strict we want to be. Let's return all for better UX in demo.
        return true; 
      }).toList();
    }
  }

  Future<List<DoctorModel>> getDoctorsByCategory(int categoryId) async {
    try {
      final result = await _apiService.getDoctorsByCategory(categoryId);
      if (result['success'] == true) {
        return result['data'] as List<DoctorModel>;
      } else {
        throw Exception(result['error'] ?? 'Failed to load doctors');
      }
    } catch (e) {
      print('API Error in getDoctorsByCategory, using mock data: $e');

      // Mock category mapping
      final mockCategories = {
        1: 'فحص شامل',
        2: 'حشو أسنان',
        3: 'زراعة أسنان',
        4: 'خلع الأسنان',
        5: 'تبييض الأسنان',
        6: 'تقويم الأسنان',
        7: 'تركيبات الأسنان',
      };

      final categoryName = mockCategories[categoryId];

      // Return mock data filtered by category
      return _getMockDoctors().where((d) {
        if (categoryName == null) return true; // Return all if unknown category
        // Loose matching for mock data
        return d.categoryName.contains(categoryName) || categoryName.contains(d.categoryName);
      }).toList();
    }
  }

  Future<List<CaseRequestModel>> getCaseRequestsByCategory(int categoryId) async {
    try {
      final result = await _apiService.getCaseRequestsByCategory(categoryId);
      if (result['success'] == true) {
        return result['data'] as List<CaseRequestModel>;
      } else {
        throw Exception(result['error'] ?? 'Failed to load case requests');
      }
    } catch (e) {
      print('API Error in getCaseRequestsByCategory, using mock data: $e');
      
      // Return mock requests
      return [
        CaseRequestModel(
          id: 101,
          description: 'مطلوب حالة زراعة ضرس عاجلة',
          date: '2024-05-20',
          time: '14:00',
          location: 'العيادة - المعادي',
          specialization: 'زراعة أسنان',
          doctor: _getMockDoctors()[1], // Dr. Sara
        ),
         CaseRequestModel(
          id: 102,
          description: 'حالة تقويم بسيطة للتدريب',
          date: '2024-05-22',
          time: '10:00',
          location: 'العيادة - الدقي',
          specialization: 'تقويم الأسنان',
          doctor: _getMockDoctors()[0], // Dr. Ahmed
        ),
      ];
    }
  }

  // Helper method to generate mock doctors
  List<DoctorModel> _getMockDoctors() {
    return [
      DoctorModel(
        id: 1,
        firstName: 'أحمد',
        lastName: 'محمد',
        studyYear: '2010',
        phoneNumber: '01012345678',
        universityName: 'جامعة القاهرة',
        cityName: 'القاهرة',
        categoryName: 'تقويم الأسنان',
        photo: 'https://img.freepik.com/free-photo/smiling-doctor-with-nurses_1098-1549.jpg', // Placeholder
        email: 'ahmed@example.com',
        description: 'أخصائي تقويم أسنان بخبرة 10 سنوات',
        price: 200.0,
      ),
      DoctorModel(
        id: 2,
        firstName: 'سارة',
        lastName: 'علي',
        studyYear: '2015',
        phoneNumber: '01123456789',
        universityName: 'جامعة عين شمس',
        cityName: 'الجيزة',
        categoryName: 'زراعة الأسنان',
        photo: 'https://img.freepik.com/free-photo/pleased-young-female-doctor-wearing-medical-robe-stethoscope-around-neck-standing-with-closed-posture_409827-254.jpg', // Placeholder
        email: 'sara@example.com',
        description: 'استشاري زراعة أسنان',
        price: 350.0,
      ),
      DoctorModel(
        id: 3,
        firstName: 'محمد',
        lastName: 'محمود',
        studyYear: '2018',
        phoneNumber: '01234567890',
        universityName: 'جامعة الإسكندرية',
        cityName: 'الإسكندرية',
        categoryName: 'حشو أسنان',
        photo: 'https://img.freepik.com/free-photo/portrait-smiling-male-doctor_171337-1532.jpg', // Placeholder
        email: 'mohamed@example.com',
        description: 'طبيب أسنان عام',
        price: 150.0,
      ),
       DoctorModel(
        id: 4,
        firstName: 'كريستيانو',
        lastName: 'رونالدو',
        studyYear: '2020',
        phoneNumber: '010000007',
        universityName: 'جامعة لشبونة',
        cityName: 'المعادي',
        categoryName: 'تجميل الأسنان',
        photo: 'https://i.pinimg.com/736x/8f/a0/51/8fa051251f5ac2d0b756027089fbffde.jpg',
        email: 'cr7@goat.com',
        description: 'أفضل طبيب تجميل أسنان في العالم',
        price: 700.0,
      ),
    ];
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
        final cities = result['data'] as List<CityModel>;
        if (cities.isEmpty) {
          throw Exception('Empty cities list');
        }
        return cities;
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

import 'package:thotha_mobile_app/core/networking/api_service.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/case_request_model.dart';

class DoctorRepository {
  final ApiService _apiService;

  DoctorRepository(this._apiService);

  Future<List<DoctorModel>> getDoctorsByCity(int cityId) async {
    // Return mock data filtered by cityId
    // In a real app we'd filter by ID, but for mock data we'll just return all for better UX in demo.
    return _getMockDoctors(); 
  }

  Future<List<DoctorModel>> getDoctorsByCategory(int categoryId) async {
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

  Future<List<CaseRequestModel>> getCaseRequestsByCategory(int categoryId) async {
    try {
      final result = await _apiService.getCaseRequestsByCategory(categoryId);
      if (result['success'] == true) {
        return result['data'] as List<CaseRequestModel>;
      } else {
        throw Exception(result['error'] ?? 'Failed to load case requests');
      }
    } catch (e) {
      // Keep mock for Case Requests as API is not confirmed yet
      print('API Error in getCaseRequestsByCategory, using mock data: $e');
      return [
        CaseRequestModel(
          id: 101,
          description: 'مطلوب حالة زراعة ضرس عاجلة',
          date: '2024-05-20',
          time: '14:00',
          location: 'العيادة - المعادي',
          specialization: 'زراعة أسنان',
          doctor: DoctorModel(
            id: 1, 
            firstName: 'سارة', 
            lastName: 'علي', 
            studyYear: '2015', 
            phoneNumber: '0100000000', 
            universityName: 'Cairo', 
            cityName: 'Cairo', 
            categoryName: 'Implant'
          ), 
        ),
         CaseRequestModel(
          id: 102,
          description: 'حالة تقويم بسيطة للتدريب',
          date: '2024-05-22',
          time: '10:00',
          location: 'العيادة - الدقي',
          specialization: 'تقويم الأسنان',
          doctor: DoctorModel(
            id: 1, 
            firstName: 'سارة', 
            lastName: 'علي', 
            studyYear: '2015', 
            phoneNumber: '0100000000', 
            universityName: 'Cairo', 
            cityName: 'Cairo', 
            categoryName: 'Implant'
          ), 
        ),
      ];
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
      throw Exception('Failed to load categories: $e');
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
      throw Exception('Failed to load cities: $e');
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
}

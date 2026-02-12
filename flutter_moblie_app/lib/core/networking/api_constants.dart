class ApiConstants {
  static const String baseUrl = 'http://13.53.131.167:5000';

  // Doctor endpoints (public) - Try different variations
  static const String getDoctorsByCity = '/api/doctor/getDoctorsByCity';
  static const String getDoctorsByCategory = '/api/doctor/getDoctorsByCategory';
  static const String getCaseRequestsByCategory = '/api/case/getByCategory'; // Assumed endpoint
  static const String createCaseRequest = '/api/case/create'; // Assumed endpoint


  // Reference data endpoints (public) - Try simpler endpoints first
  static const String getCategories = '/categories';  // Simpler version
  static const String getCities = '/cities';          // Simpler version
  
  // Alternative endpoints if above don't work
  static const String getCategoriesAlt = '/api/categories';
  static const String getCitiesAlt = '/api/cities';
  
  // Auth endpoints
  static const String sendOtp = '/api/auth/send-otp';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String resetPassword = '/api/auth/reset-password';

  // Fallback endpoints
  static const String getCategoriesFallback = '/api/category/getCategories';
  static const String getCitiesFallback = '/api/cities/getAllCities';
}

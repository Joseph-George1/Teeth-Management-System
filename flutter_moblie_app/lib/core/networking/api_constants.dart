class ApiConstants {
  static const String baseUrl = 'https://thoutha.page';
  static const String loginDoctor = '/api/auth/login/doctor';
  static const String signupDoctor = '/api/auth/signup';
  static const String getAllCities = '/api/cities/getAllCities';
  static const String getAllUniversities = '/api/university/getAllUniversities';

  // Doctor endpoints (public) - Try different variations
  static const String getDoctorsByCities = '/api/doctor/getDoctorsByCities';
  static const String getDoctorsByCategories = '/api/doctor/getDoctorsByCategories';
  static const String getCaseRequestsByCategories = '/api/case/getByCategories'; // Assumed endpoint
  static const String createCaseRequest = '/api/case/create'; // Assumed endpoint


  // Reference data endpoints (public) - Try simpler endpoints first
  static const String getCategories = '/api/doctor/getCategories';
  static const String getCities = '/cities';          // Simpler version
  
  // Alternative endpoints if above don't work
  static const String getCategoriesAlt = '/api/categories';
  static const String getCitiesAlt = '/api/cities';
  
  // Fallback endpoints
  static const String getCategoriesFallback = '/api/category/getCategories';
  static const String getCitiesFallback = '/api/cities/getAllCities';
}

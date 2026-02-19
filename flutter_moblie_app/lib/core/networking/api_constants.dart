class ApiConstants {
  static const String baseUrl = 'http://16.16.218.59:8080';
  static const String otpBaseUrl = 'https://thoutha.page';

  // Authentication endpoints
  static const String doctorLogin = '/api/auth/login/doctor';
  static const String signup = '/api/auth/signup';

  // Doctor endpoints (public) - Try different variations
  static const String getDoctorsByCities = '/api/doctor/getDoctorsByCity';
  static const String getDoctorsByCategories = '/api/doctor/getDoctorsByCategory';
  static const String getCaseRequestsByCategories = '/api/case/getByCategory'; // Assumed endpoint
  static const String createCaseRequest = '/api/case/create'; // Assumed endpoint

  // Reference data endpoints
  static const String getUniversities = '/api/university/getAllUniversities';
  static const String getCategories = '/api/category/getCategories';
  static const String getCities = '/api/cities/getAllCities';  // Updated to new endpoint
  
  // Alternative/fallback endpoints
  static const String getCategoriesAlt = '/api/categories';
  static const String getCategoriesFallback = '/api/category/getCategories';
  static const String getCitiesAlt = '/cities';
  static const String getCitiesFallback = '/api/cities';

  // OTP endpoints
  static const String sendOtp = '/api/otp/send';
  static const String verifyOtp = '/api/otp/verify';
}

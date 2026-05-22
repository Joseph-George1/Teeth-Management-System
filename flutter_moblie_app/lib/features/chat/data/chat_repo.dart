import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/core/networking/api_constants.dart';

class ChatRepo {
  final ApiService _apiService;

  ChatRepo(this._apiService);

  Future<Map<String, dynamic>> startSession({String language = 'ar'}) async {
    try {
      // Chat endpoints are on the same base URL as the app
      final response = await _apiService.post(
        ApiConstants.startSession,
        data: {'language': language},
      );
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required String answerId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.submitAnswer,
        data: {
          'session_id': sessionId,
          'question_id': questionId,
          'answer_id': answerId,
        },
      );
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    String? sessionId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.chat,
        data: {
          'message': message,
          if (sessionId != null) 'session_id': sessionId,
        },
      );
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await _apiService.get(ApiConstants.getCategories);
      return response;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}

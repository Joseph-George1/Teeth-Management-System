import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/features/requests/data/models/case_request_body.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class CaseRequestRepo {
  final ApiService _apiService;

  CaseRequestRepo(this._apiService);

  Future<Map<String, dynamic>> createCaseRequest(CaseRequestBody body) async {
    try {
      final response = await _apiService.createCaseRequest(body.toJson());
      return response;
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> updateCaseRequest(
      int requestId, CaseRequestBody body) async {
    try {
      // Validate data before sending
      if (body.description.trim().isEmpty || body.dateTime.trim().isEmpty) {
        return {
          'success': false,
          'error': L10nRequests.allRequiredFieldsMust.tr(),
        };
      }

      final response = await _apiService.editRequest(
        requestId,
        body.description.trim(),
        body.dateTime.trim(),
      );
      return response;
    } catch (e) {
      return {
        'success': false,
        'error': 'خطأ: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getRequestById(int id) async {
    try {
      return await _apiService.getRequestById(id);
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> deleteRequest(int id, {int? doctorId}) async {
    try {
      return await _apiService.deleteRequest(id, doctorId: doctorId);
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getRequestsByDoctorId() async {
    try {
      return await _apiService.getRequestsByDoctorId();
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<Map<String, dynamic>> getRequestsByCategoryId(int categoryId) async {
    try {
      return await _apiService.getCaseRequestsByCategory(categoryId);
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

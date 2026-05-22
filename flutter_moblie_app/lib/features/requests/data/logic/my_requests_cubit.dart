import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoutha_mobile_app/features/requests/data/repos/case_request_repo.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../../../../core/helpers/shared_pref_helper.dart' show SharedPrefHelper;
import '../../../../core/helpers/constants.dart' show SharedPrefKeys;
import '../logic/my_requests_state.dart';
import '../models/case_request_model.dart' show CaseRequestModel;
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

/// Manages fetching and deleting the authenticated doctor's requests.
///
/// Call [loadRequests] on creation (cubit..loadRequests() inside BlocProvider).
/// Call [deleteRequest] when the user confirms deletion.
class MyRequestsCubit extends Cubit<MyRequestsState> {
  final CaseRequestRepo _repo;

  MyRequestsCubit(this._repo) : super(MyRequestsInitial());

  // ── Public API ────────────────────────────────────────────────────────────

  /// Fetches all requests for the currently logged-in doctor.
  Future<void> loadRequests({bool forceRefresh = false}) async {
    // If we already have data and not forcing refresh, we can skip the full loading state
    final hasData = state is MyRequestsSuccess || state is MyRequestsDeleteSuccess;

    if (!hasData || forceRefresh) {
      List<CaseRequestModel> cachedList = [];
      try {
        final cachedStr = await SharedPrefHelper.getString('cached_my_requests');
        if (cachedStr.isNotEmpty) {
          final List decoded = json.decode(cachedStr) as List;
          cachedList = decoded.map((e) => CaseRequestModel.fromJson(e as Map<String, dynamic>)).toList();
          if (cachedList.isNotEmpty) {
            emit(MyRequestsSuccess(cachedList));
          }
        }
      } catch (_) {}

      if (cachedList.isEmpty) {
        emit(MyRequestsLoading());
      }
    }

    // ── 1. Token guard ────────────────────────────────────────────────────
    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
    if (token == null || token.isEmpty) {
      emit(MyRequestsError(
        L10nRequests.pleaseLogInFirst.tr(),
        isAuthError: true,
      ));
      return;
    }

    // ── 3. GET /api/request/getRequestsByDoctorId ──────────
    final result = await _repo.getRequestsByDoctorId();

    if (result['success'] == true) {
      final requests = List<CaseRequestModel>.from(result['data'] as List);
      emit(requests.isEmpty ? MyRequestsEmpty() : MyRequestsSuccess(requests));
      // Save to cache
      try {
        final encoded = json.encode(requests.map((e) => e.toJson()).toList());
        await SharedPrefHelper.setData('cached_my_requests', encoded);
      } catch (_) {}
    } else {
      final code = result['statusCode'] as int?;
      if (code == 404) {
        // 404 = no requests found: treat as empty, not an error
        emit(MyRequestsEmpty());
        await SharedPrefHelper.removeData('cached_my_requests');
      } else if (code != null && code >= 500) {
        if (state is! MyRequestsSuccess) {
          emit(MyRequestsError(
            L10nRequests.serverErrorPleaseTry.tr(),
            isServerError: true,
          ));
        }
      } else {
        if (state is! MyRequestsSuccess) {
          emit(MyRequestsError(
            result['error']?.toString() ?? L10nDoctor.failedToLoadRequests.tr(),
          ));
        }
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Returns the request list from whichever state currently holds one.
  List<CaseRequestModel> get _visibleRequests {
    final s = state;
    if (s is MyRequestsSuccess) return s.requests;
    if (s is MyRequestsDeleteSuccess) return s.requests;
    if (s is MyRequestsDeleteError) return s.requests;
    return [];
  }

  /// Deletes [request] and emits the updated list.
  Future<void> deleteRequest(CaseRequestModel request) async {
    // 1. استنساخ القائمة الحالية قبل الحذف
    final currentList = List<CaseRequestModel>.from(_visibleRequests);

    try {
      // 2. الحصول على ID الطبيب
      int doctorId = await SharedPrefHelper.getInt('doctor_id');
      if (doctorId == 0) {
        final s = await SharedPrefHelper.getString('doctor_id');
        doctorId = int.tryParse(s) ?? 0;
      }

      // 3. استدعاء الـ API
      final result = await _repo.deleteRequest(request.id ?? 0,
          doctorId: doctorId == 0 ? null : doctorId);

      if (result['success'] == true) {
        // 4. نجاح الحذف: تحديث القائمة محلياً فوراً
        currentList.removeWhere((r) => r.id == request.id);

        if (currentList.isEmpty) {
          // حتى لو فرغت القائمة، نرسل نجاح الحذف أولاً ليغلق الـ UI الحوار
          emit(MyRequestsDeleteSuccess(const []));
          emit(MyRequestsEmpty());
          await SharedPrefHelper.removeData('cached_my_requests');
        } else {
          emit(MyRequestsDeleteSuccess(currentList));
          // تحديث الكاش
          final encoded = json.encode(currentList.map((e) => e.toJson()).toList());
          await SharedPrefHelper.setData('cached_my_requests', encoded);
        }
      } else {
        // 5. فشل السيرفر في الحذف
        emit(MyRequestsDeleteError(
          result['error']?.toString() ?? L10nHomeScreen.failedToDeleteRequest.tr(),
          currentList,
        ));
      }
    } catch (e) {
      // 6. معالجة أي خطأ غير متوقع (مثل انقطاع الإنترنت)
      emit(MyRequestsDeleteError(
        L10nRequests.somethingWentWrong.tr(),
        currentList,
      ));
    }
  }
}

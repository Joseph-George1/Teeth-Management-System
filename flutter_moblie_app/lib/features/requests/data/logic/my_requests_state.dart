import '../models/case_request_model.dart';

abstract class MyRequestsState {}

/// Before any fetch has started.
class MyRequestsInitial extends MyRequestsState {}

/// Fetching the request list from the server.
class MyRequestsLoading extends MyRequestsState {}

/// Server returned 200 with a non-empty list.
class MyRequestsSuccess extends MyRequestsState {
  final List<CaseRequestModel> requests;
  MyRequestsSuccess(this.requests);
}

/// 404 response or the server returned an empty list.
class MyRequestsEmpty extends MyRequestsState {}

/// Any error state (auth, network, server).
class MyRequestsError extends MyRequestsState {
  final String message;
  final bool isServerError;
  final bool isAuthError;

  MyRequestsError(
    this.message, {
    this.isServerError = false,
    this.isAuthError = false,
  });
}

/// A delete completed successfully — carries the updated list.
class MyRequestsDeleteSuccess extends MyRequestsState {
  final List<CaseRequestModel> requests;
  MyRequestsDeleteSuccess(this.requests);
}

/// A delete failed — carries the unchanged list + error message.
class MyRequestsDeleteError extends MyRequestsState {
  final String message;
  final List<CaseRequestModel> requests;
  MyRequestsDeleteError(this.message, this.requests);
}

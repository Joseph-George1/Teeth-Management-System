import 'package:freezed_annotation/freezed_annotation.dart';

part 'add_edit_case_request_state.freezed.dart';

@freezed
class AddEditCaseRequestState with _$AddEditCaseRequestState {
  factory AddEditCaseRequestState.initial() = _Initial;
  factory AddEditCaseRequestState.loading() = Loading;
  factory AddEditCaseRequestState.success() = Success;
  factory AddEditCaseRequestState.error({required String message}) =
      Error;
}

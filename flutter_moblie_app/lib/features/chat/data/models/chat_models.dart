import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_models.freezed.dart';
part 'chat_models.g.dart';

@freezed
abstract class ChatResponse with _$ChatResponse {
  const factory ChatResponse({
    @JsonKey(name: 'session_id') String? sessionId,
    @JsonKey(name: 'next_step') String? nextStep,
    @JsonKey(name: 'chatbot_mode') bool? chatbotMode,
    ChatQuestion? question,
    List<ChatAnswer>? answers,
    @JsonKey(name: 'question_id') String? questionId,
    @JsonKey(name: 'question_text') String? questionText,
    Map<String, dynamic>? result,
    String? reply,
  }) = _ChatResponse;

  factory ChatResponse.fromJson(Map<String, dynamic> json) =>
      _$ChatResponseFromJson(json);
}

@freezed
abstract class ChatQuestion with _$ChatQuestion {
  const factory ChatQuestion({
    String? id,
    String? text,
    List<ChatAnswer>? answers,
  }) = _ChatQuestion;

  factory ChatQuestion.fromJson(Map<String, dynamic> json) =>
      _$ChatQuestionFromJson(json);
}

@freezed
abstract class ChatAnswer with _$ChatAnswer {
  const factory ChatAnswer({
    String? id,
    String? text,
  }) = _ChatAnswer;

  factory ChatAnswer.fromJson(Map<String, dynamic> json) =>
      _$ChatAnswerFromJson(json);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatResponse _$ChatResponseFromJson(Map<String, dynamic> json) =>
    _ChatResponse(
      sessionId: json['session_id'] as String?,
      nextStep: json['next_step'] as String?,
      chatbotMode: json['chatbot_mode'] as bool?,
      question: json['question'] == null
          ? null
          : ChatQuestion.fromJson(json['question'] as Map<String, dynamic>),
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => ChatAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      questionId: json['question_id'] as String?,
      questionText: json['question_text'] as String?,
      result: json['result'] as Map<String, dynamic>?,
      reply: json['reply'] as String?,
    );

Map<String, dynamic> _$ChatResponseToJson(_ChatResponse instance) =>
    <String, dynamic>{
      'session_id': instance.sessionId,
      'next_step': instance.nextStep,
      'chatbot_mode': instance.chatbotMode,
      'question': instance.question,
      'answers': instance.answers,
      'question_id': instance.questionId,
      'question_text': instance.questionText,
      'result': instance.result,
      'reply': instance.reply,
    };

_ChatQuestion _$ChatQuestionFromJson(Map<String, dynamic> json) =>
    _ChatQuestion(
      id: json['id'] as String?,
      text: json['text'] as String?,
      answers: (json['answers'] as List<dynamic>?)
          ?.map((e) => ChatAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ChatQuestionToJson(_ChatQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'answers': instance.answers,
    };

_ChatAnswer _$ChatAnswerFromJson(Map<String, dynamic> json) => _ChatAnswer(
      id: json['id'] as String?,
      text: json['text'] as String?,
    );

Map<String, dynamic> _$ChatAnswerToJson(_ChatAnswer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
    };

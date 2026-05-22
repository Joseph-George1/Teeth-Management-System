import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/models/chat_models.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState {
  factory ChatState.initial() = _Initial;
  factory ChatState.loading() = ChatLoading;
  factory ChatState.success({
    required List<FlowItem> flowItems,
    required List<ChatItem> chatHistory,
    @Default([]) List<Map<String, dynamic>> categories,
    String? sessionId,
    String? activeQuestionId,
    @Default(false) bool chatMode,
    @Default(false) bool isActionLoading,
  }) = ChatSuccess;
  factory ChatState.error(String message) = ChatError;
}

enum FlowType { question, answer, result }

@freezed
abstract class FlowItem with _$FlowItem {
  factory FlowItem({
    required FlowType type,
    required String text,
    ChatQuestion? question,
    String? category,
  }) = _FlowItem;
}

enum ChatRole { user, bot }

@freezed
abstract class ChatItem with _$ChatItem {
  factory ChatItem({
    required ChatRole role,
    required String text,
  }) = _ChatItem;
}

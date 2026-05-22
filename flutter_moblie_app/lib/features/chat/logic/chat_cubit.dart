import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/chat_repo.dart';
import '../data/models/chat_models.dart';
import 'chat_state.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;

  ChatCubit(this._chatRepo) : super(ChatState.initial());

  Future<void> startSession() async {
    emit(ChatState.loading());

    // Load categories first for matching later
    final categories = await _loadCategories();

    final result = await _chatRepo.startSession();

    if (result['success'] == true) {
      final data = result['data'];
      final response = ChatResponse.fromJson(data);

      final flowItems = <FlowItem>[];
      final chatHistory = <ChatItem>[];

      _processResponse(response, flowItems, chatHistory, response.sessionId,
          true, categories);
    } else {
      emit(ChatState.error(result['error'] ?? L10nChat.failedToStartA.tr()));
    }
  }

  Future<List<Map<String, dynamic>>> _loadCategories() async {
    try {
      // ApiConstants.getCategories is /api/category/getCategories
      final response = await _chatRepo.getCategories();
      if (response['success'] == true && response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data'] as List);
      }
    } catch (_) {}
    return [];
  }

  void _processResponse(
    ChatResponse response,
    List<FlowItem> flowItems,
    List<ChatItem> chatHistory,
    String? sessionId,
    bool emitNew,
    List<Map<String, dynamic>> categories,
  ) {
    bool chatMode = false;
    String? activeQuestionId;

    final nextStep = response.nextStep;
    if (response.chatbotMode == true ||
        ['chat', 'chatbot', 'ai'].contains(nextStep?.toLowerCase())) {
      chatMode = true;
    }

    if (response.result != null) {
      final category =
          (response.result!['category'] ?? response.result!['category_en'])
              ?.toString();
      if (category != null && category.trim().isNotEmpty) {
        flowItems.add(FlowItem(
          type: FlowType.result,
          text: '✅ تم تحديد الفئة: $category',
          category: category,
        ));
      }
    }

    final q = response.question;
    if (q != null && q.id != null && q.text != null) {
      flowItems
          .add(FlowItem(type: FlowType.question, text: q.text!, question: q));
      activeQuestionId = q.id;
    } else if (response.questionId != null && response.questionText != null) {
      // Support for flat question response
      final flatQ = ChatQuestion(
        id: response.questionId,
        text: response.questionText,
        answers: response.answers,
      );
      flowItems.add(FlowItem(
          type: FlowType.question, text: flatQ.text!, question: flatQ));
      activeQuestionId = flatQ.id;
    }

    if (emitNew) {
      emit(ChatState.success(
        flowItems: flowItems,
        chatHistory: chatHistory,
        categories: categories,
        sessionId: sessionId,
        activeQuestionId: activeQuestionId,
        chatMode: chatMode,
      ));
    }
  }

  /// ابحث عن category_id باستخدام اسم الفئة
  int? getCategoryIdByName(
      String rawCategory, List<Map<String, dynamic>> categories) {
    try {
      final mapped = _mapToAppCategory(rawCategory);
      final normalizedInput = _normalize(mapped);
      for (var cat in categories) {
        final name = cat['name']?.toString() ?? '';
        final nameAr = cat['name_ar']?.toString() ?? '';

        if (_normalize(name) == normalizedInput ||
            _normalize(nameAr) == normalizedInput) {
          return cat['id'] as int?;
        }
      }
    } catch (_) {}
    return null;
  }

  String _normalize(String s) {
    return s
        .replaceAll(L10nChat.a.tr(), L10nChat.a1.tr())
        .replaceAll(L10nChat.e.tr(), L10nChat.a1.tr())
        .replaceAll(L10nChat.oh.tr(), L10nChat.a1.tr())
        .replaceAll(L10nChat.oh1.tr(), L10nChat.e1.tr())
        .replaceAll(L10nChat.yes.tr(), L10nChat.y.tr())
        .replaceAll(RegExp(r'[^\u0621-\u064A0-9a-zA-Z]'), '')
        .toLowerCase();
  }

  String _mapToAppCategory(String raw) {
    final map = <String, String>{
      L10nChat.teethWhitening.tr(): L10nChat.teethCleaningAndWhitening.tr(),
      'Teeth Whitening': L10nChat.teethCleaningAndWhitening.tr(),
      L10nChat.dentalImplants.tr(): L10nChat.dentalImplants.tr(),
      'Dental Implants': L10nChat.dentalImplants.tr(),
      L10nChat.dentalFillings.tr(): L10nChat.cosmeticFiller.tr(),
      'Dental Fillings': L10nChat.cosmeticFiller.tr(),
      L10nChat.toothExtraction.tr(): L10nChat.surgeryAndExtraction.tr(),
      'Tooth Extraction': L10nChat.surgeryAndExtraction.tr(),
      L10nChat.dentalCrownsprostheses.tr(): L10nChat.crownsAndBridges.tr(),
      'Dental Crowns / Prosthodontics': L10nChat.crownsAndBridges.tr(),
      L10nChat.orthodontics.tr(): L10nChat.orthodontics.tr(),
      'Braces': L10nChat.orthodontics.tr(),
      L10nChat.aComprehensiveDentalExamination.tr(): L10nChat.comprehensiveExamination.tr(),
      'Comprehensive Dental Examination': L10nChat.comprehensiveExamination.tr(),
      L10nChat.cleaningAndWhitening.tr(): L10nChat.teethCleaningAndWhitening.tr(),
      L10nChat.children.tr(): L10nChat.pediatricDentistry.tr(),
      'Pediatric': L10nChat.pediatricDentistry.tr(),
      L10nChat.crownsAndBridges.tr(): L10nChat.crownsAndBridges.tr(),
      'Crowns and Bridges': L10nChat.crownsAndBridges.tr(),
    };
    return map[raw] ?? map[raw.trim()] ?? raw;
  }

  Future<void> submitAnswer(ChatQuestion q, ChatAnswer a) async {
    final currentState = state;
    if (currentState is! ChatSuccess || currentState.sessionId == null) return;

    final flowItems = List<FlowItem>.from(currentState.flowItems);
    flowItems.add(FlowItem(type: FlowType.answer, text: a.text ?? ''));

    emit(currentState.copyWith(
      flowItems: flowItems,
      activeQuestionId: null,
      isActionLoading: true,
    ));

    final result = await _chatRepo.submitAnswer(
      sessionId: currentState.sessionId!,
      questionId: q.id!,
      answerId: a.id!,
    );

    if (result['success'] == true) {
      final response = ChatResponse.fromJson(result['data']);
      _processResponse(
        response,
        flowItems,
        currentState.chatHistory,
        currentState.sessionId,
        true,
        currentState.categories,
      );
    } else {
      // Handle error but stay in success state to show chat
      emit(currentState.copyWith(isActionLoading: false));
    }
  }

  Future<void> sendChatMessage(String message) async {
    final currentState = state;
    if (currentState is! ChatSuccess) return;

    final chatHistory = List<ChatItem>.from(currentState.chatHistory);
    chatHistory.add(ChatItem(role: ChatRole.user, text: message));
    chatHistory.add(ChatItem(role: ChatRole.bot, text: L10nChat.heThinks.tr()));

    emit(
        currentState.copyWith(chatHistory: chatHistory, isActionLoading: true));

    final result = await _chatRepo.sendChatMessage(
      message: message,
      sessionId: currentState.sessionId,
    );

    chatHistory
        .removeWhere((m) => m.role == ChatRole.bot && m.text == L10nChat.heThinks.tr());

    if (result['success'] == true) {
      final response = ChatResponse.fromJson(result['data']);
      final reply = response.reply ?? L10nChat.sorryIDidntUnderstand.tr();
      chatHistory.add(ChatItem(role: ChatRole.bot, text: reply));

      emit(currentState.copyWith(
        chatHistory: chatHistory,
        sessionId: response.sessionId ?? currentState.sessionId,
        isActionLoading: false,
      ));
    } else {
      chatHistory.add(ChatItem(
          role: ChatRole.bot, text: L10nChat.sorryAConnectionError.tr()));
      emit(currentState.copyWith(
          chatHistory: chatHistory, isActionLoading: false));
    }
  }

  Future<void> restartSession() async {
    emit(ChatState.loading());
    startSession();
  }
}

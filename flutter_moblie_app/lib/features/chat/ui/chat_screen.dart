import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:thotha_mobile_app/features/home_screen/ui/category_doctors_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Same API used by the frontend chatbot
  static const String _apiBase = 'https://thoutha.page/api';
  static const Map<String, String> _apiHeaders = {'Content-Type': 'application/json'};

  // UI colors to match frontend CSS (ChatBot.css)
  static const Color _color2 = Color(0xFF53CAF9); // header + user bubble
  static const Color _color3 = Color(0x2853CAF9); // bot bubble (53caf928)
  static const Color _outline = Color(0xFFCCCCE5);
  static const String _thinkingText = 'يفكر.....';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiBase,
      headers: _apiHeaders,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _isLoading = false;
  bool _chatMode = false;
  String? _sessionId;
  String? _activeQuestionId;

  final List<_FlowItem> _flowItems = <_FlowItem>[];
  final List<_ChatItem> _chatHistory = <_ChatItem>[];

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      if (mounted) setState(() {});
    });
    _inputFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _startSessionOnce();
  }

  Future<void> _startSessionOnce() async {
    if (_isLoading || _sessionId != null || _flowItems.isNotEmpty) return;
    setState(() => _isLoading = true);
    try {
      final res = await _dio.post('/session/start', data: {'language': 'ar'});
      final data = res.data;
      if (data is Map && data['session_id'] != null) {
        _sessionId = data['session_id'].toString();
      }
      _processResponse(data);
    } catch (_) {
      // If session flow fails, fall back to chat mode
      setState(() => _chatMode = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool _processResponse(dynamic data) {
    final nextStep = (data is Map) ? (data['next_step'] ?? data['next'] ?? data['mode'] ?? data['state']) : null;

    if (data is Map && data['chatbot_mode'] == true) {
      setState(() => _chatMode = true);
      return true;
    }
    if (nextStep is String && <String>['chat', 'chatbot', 'ai'].contains(nextStep.toLowerCase())) {
      setState(() => _chatMode = true);
      return true;
    }

    if (data is Map) {
      final result = data['result'];
      String? category;
      if (result is Map) {
        category = (result['category'] ?? result['category_en'])?.toString();
      }
      if (category != null && category.trim().isNotEmpty) {
        setState(() {
          _flowItems.add(_FlowItem.result(text: '✅ تم تحديد الفئة: $category', category: category));
        });
        return true;
      }
    }

    final q = _normalizeQuestion(data);
    if (q != null) {
      setState(() {
        _flowItems.add(_FlowItem.question(q));
        _activeQuestionId = q.id;
      });
      return true;
    }

    setState(() => _chatMode = true);
    return false;
  }

  _FlowQuestion? _normalizeQuestion(dynamic data) {
    if (data is! Map) return null;
    final q = (data['question'] is Map) ? (data['question'] as Map) : null;
    final id = (data['question_id'] ?? data['questionId'] ?? q?['id'] ?? q?['question_id'] ?? q?['questionId'])?.toString();
    final text =
        (data['question_text'] ?? (data['question'] is String ? data['question'] : null) ?? q?['text'] ?? q?['question_text'])?.toString();
    if (id == null || id.isEmpty || text == null || text.isEmpty) return null;

    final rawAnswers = (data['answers'] ?? data['options'] ?? q?['answers'] ?? q?['options']);
    final List<_FlowAnswer> answers = [];
    if (rawAnswers is List) {
      for (final a in rawAnswers) {
        if (a is Map) {
          final aid = (a['id'] ?? a['answer_id'] ?? a['value'])?.toString();
          final at = (a['text'] ?? a['label'] ?? a['answer_text'] ?? a['title'])?.toString();
          if (aid != null && aid.isNotEmpty && at != null && at.isNotEmpty) {
            answers.add(_FlowAnswer(id: aid, text: at));
          }
        }
      }
    }
    return _FlowQuestion(id: id, text: text, answers: answers);
  }

  Future<void> _submitAnswer(_FlowQuestion q, _FlowAnswer a) async {
    if (_sessionId == null || _sessionId!.isEmpty) return;

    setState(() {
      _isLoading = true;
      _activeQuestionId = null;
      _flowItems.add(_FlowItem.answer(text: a.text));
    });
    _scrollToBottom();

    final isOther = RegExp(r'(اخر|أخر|other)', caseSensitive: false).hasMatch(a.text);
    if (isOther) {
      setState(() {
        _flowItems.add(_FlowItem.result(text: 'من فضلك اكتب رسالتك بالتفصيل عشان أقدر أساعدك بشكل أفضل:'));
        _chatMode = true;
        _isLoading = false;
      });
      _scrollToBottom();
      return;
    }

    try {
      final res = await _dio.post('/session/answer', data: {'session_id': _sessionId, 'question_id': q.id, 'answer_id': a.id});
      final data = res.data;
      if (!_processResponse(data)) {
        setState(() {
          _flowItems.add(_FlowItem.result(
            text: 'عذراً، أحتاج المزيد من المعلومات. من فضلك اكتب رسالة بالتفصيل عشان أقدر أفهم احتياجك بشكل أفضل:',
          ));
          _chatMode = true;
        });
      }
    } catch (_) {
      setState(() => _chatMode = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  Future<void> _sendChatMessage() async {
    final msg = _inputController.text.trim();
    if (msg.isEmpty) return;

    _inputController.clear();
    _inputFocusNode.requestFocus();

    setState(() {
      _chatHistory.add(_ChatItem.user(msg));
      _chatHistory.add(_ChatItem.bot(_thinkingText));
    });
    _scrollToBottom();

    const errorMsg = 'عذراً، حدث خطأ في الاتصال. حاول مرة أخرى.';
    try {
      final res = await _dio.post('/chat', data: {'message': msg, 'session_id': _sessionId});
      final data = res.data;
      if (data is Map && data['session_id'] != null) {
        _sessionId = data['session_id'].toString();
      }
      final reply = (data is Map && data['reply'] != null) ? data['reply'].toString() : errorMsg;
      setState(() {
        _chatHistory.removeWhere((m) => m.role == _ChatRole.bot && m.text == _thinkingText);
        _chatHistory.add(_ChatItem.bot(reply));
      });
    } catch (_) {
      setState(() {
        _chatHistory.removeWhere((m) => m.role == _ChatRole.bot && m.text == _thinkingText);
        _chatHistory.add(_ChatItem.bot(errorMsg));
      });
    } finally {
      _scrollToBottom();
    }
  }

  String _mapToAppCategory(String raw) {
    const map = <String, String>{
      'تبييض الأسنان': 'تبييض الأسنان',
      'Teeth Whitening': 'تبييض الأسنان',
      'زراعة الأسنان': 'زراعة أسنان',
      'Dental Implants': 'زراعة أسنان',
      'حشوات الأسنان': 'حشو أسنان',
      'Dental Fillings': 'حشو أسنان',
      'خلع الأسنان': 'خلع الأسنان',
      'Tooth Extraction': 'خلع الأسنان',
      'تيجان الأسنان / التركيبات': 'تركيبات الأسنان',
      'Dental Crowns / Prosthodontics': 'تركيبات الأسنان',
      'تقويم الأسنان': 'تقويم الأسنان',
      'Braces': 'تقويم الأسنان',
      'فحص شامل للأسنان': 'فحص شامل',
      'Comprehensive Dental Examination': 'فحص شامل',
    };
    return map[raw] ?? map[raw.trim()] ?? raw;
  }

  void _openCategory(String rawCategory) {
    final mapped = _mapToAppCategory(rawCategory);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDoctorsScreen(categoryName: mapped),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _header(theme),
          Expanded(child: _chatBody(theme)),
          if (_chatMode)
            SafeArea(
              top: false,
              child: _footer(theme),
            ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Container(
      padding: EdgeInsets.only(
        left: 22.w,
        right: 22.w,
        bottom: 15.h,
        top: MediaQuery.of(context).padding.top + 15.h,
      ),
      decoration: const BoxDecoration(
        color: _color2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset('assets/svg/ثوثه الدكتور 1.svg', width: 32.r, height: 32.r),
          SizedBox(width: 8.w),
          Text(
            'ثوثة الطبيب الذكي',
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBody(ThemeData theme) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _botMessage('👋🏻 اهلا بك\nازاى اقدر اساعدك؟'),
          if (_isLoading && _flowItems.isEmpty) ...[
            SizedBox(height: 16.h),
            _botMessage('...جاري تجهيز الأسئلة'),
          ],
          for (final item in _flowItems) ...[
            SizedBox(height: 16.h),
            if (item.type == _FlowType.question) ...[
              _botMessage(item.question!.text),
              if (!_chatMode && _activeQuestionId == item.question!.id && item.question!.answers.isNotEmpty) ...[
                SizedBox(height: 14.h),
                _quickReplies(item.question!),
              ],
            ] else if (item.type == _FlowType.result) ...[
              _botMessage(item.text),
              if (item.category != null) ...[
                SizedBox(height: 14.h),
                _resultButton(item.category!),
              ],
            ] else ...[
              _userMessage(item.text),
            ],
          ],
          for (final m in _chatHistory) ...[
            SizedBox(height: 16.h),
            if (m.role == _ChatRole.user) _userMessage(m.text) else _botMessage(m.text),
          ],
        ],
      ),
    );
  }

  Widget _footer(ThemeData theme) {
    final hasText = _inputController.text.trim().isNotEmpty;
    final isFocused = _inputFocusNode.hasFocus;

    return Container(
      padding: EdgeInsets.fromLTRB(22.w, 15.h, 22.w, 20.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32.r),
            border: Border.all(color: isFocused ? _color2 : _outline, width: isFocused ? 2 : 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendChatMessage(),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك..............................',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 17.w, vertical: 12.h),
                  ),
                ),
              ),
              if (hasText)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: InkWell(
                    onTap: _isLoading ? null : _sendChatMessage,
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 35.r,
                      width: 35.r,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: _color2),
                      child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
       );
  }

  Widget _botAvatar({required double size}) {
    return Container(
      height: size,
      width: size,
      padding: EdgeInsets.all(size * 0.18),
      decoration: const BoxDecoration(color: _color2, shape: BoxShape.circle),
      child: SvgPicture.asset('assets/svg/ثوثه الدكتور 1.svg'),
    );
  }

  Widget _botMessage(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: _color3,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(13.r),
                topRight: Radius.circular(13.r),
                bottomRight: Radius.circular(13.r),
                bottomLeft: Radius.circular(3.r),
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14.sp,
                height: 1.5,
                color: const Color(0xFF083B52),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        _botAvatar(size: 32.r),
      ],
    );
  }

  Widget _userMessage(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: _color2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(13.r),
            topRight: Radius.circular(13.r),
            bottomRight: Radius.circular(3.r),
            bottomLeft: Radius.circular(13.r),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            height: 1.5,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _quickReplies(_FlowQuestion q) {
    final answers = q.answers;
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 420;
        final columns = isNarrow ? 1 : 2;
        final buttonWidth = (constraints.maxWidth - (12.w * (columns - 1))) / columns;

        return Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          alignment: WrapAlignment.end,
          children: answers.map((a) {
            final isOther = RegExp(r'(اخر|أخر|other)', caseSensitive: false).hasMatch(a.text);
            final full = isOther || columns == 1;
            return SizedBox(
              width: full ? constraints.maxWidth : buttonWidth,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _submitAnswer(q, a),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _color3,
                  foregroundColor: const Color(0xFF083B52),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(
                  a.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Cairo', fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  Widget _resultButton(String category) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: _color2.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _openCategory(category),
          style: ElevatedButton.styleFrom(
            backgroundColor: _color2,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'عرض أطباء $category',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(width: 10.w),
              Icon(Icons.arrow_back_rounded, size: 20.r),
            ],
          ),
        ),
      ),
    );
  }
}

enum _FlowType { question, answer, result }

class _FlowItem {
  final _FlowType type;
  final String text;
  final _FlowQuestion? question;
  final String? category;

  _FlowItem._({required this.type, required this.text, this.question, this.category});

  factory _FlowItem.question(_FlowQuestion q) => _FlowItem._(type: _FlowType.question, text: q.text, question: q);
  factory _FlowItem.answer({required String text}) => _FlowItem._(type: _FlowType.answer, text: text);
  factory _FlowItem.result({required String text, String? category}) =>
      _FlowItem._(type: _FlowType.result, text: text, category: category);
}

class _FlowQuestion {
  final String id;
  final String text;
  final List<_FlowAnswer> answers;
  _FlowQuestion({required this.id, required this.text, required this.answers});
}

class _FlowAnswer {
  final String id;
  final String text;
  _FlowAnswer({required this.id, required this.text});
}

enum _ChatRole { user, bot }

class _ChatItem {
  final _ChatRole role;
  final String text;
  _ChatItem._(this.role, this.text);

  factory _ChatItem.user(String text) => _ChatItem._(_ChatRole.user, text);
  factory _ChatItem.bot(String text) => _ChatItem._(_ChatRole.bot, text);
}

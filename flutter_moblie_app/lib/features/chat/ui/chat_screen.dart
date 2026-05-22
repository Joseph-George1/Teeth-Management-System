import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thoutha_mobile_app/core/networking/api_constants.dart';
import 'package:thoutha_mobile_app/features/home_screen/ui/category_doctors_screen.dart';
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/core/routing/routes.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static final String _apiBase = '${ApiConstants.baseUrl}/api';
  static const Map<String, String> _apiHeaders = {
    'Content-Type': 'application/json'
  };

  static const Color _color2 = Color(0xFF53CAF9);
  static const Color _color3 = Color(0x2853CAF9);
  static Color _outline = Color(0xFFCCCCE5);
  static String _thinkingText = L10nChat.heThinks.tr();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiBase,
      headers: _apiHeaders,
      connectTimeout: Duration(seconds: 30),
      receiveTimeout: Duration(seconds: 30),
    ),
  );

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  bool _isLoading = false;
  bool _chatMode = false;
  String? _sessionId;
  String? _activeQuestionId;
  bool _isEnglish = false;
  List<Map<String, dynamic>> _categories = []; // قائمة الكاتيجوريات من API

  final List<_FlowItem> _flowItems = <_FlowItem>[];
  final List<_ChatItem> _chatHistory = <_ChatItem>[];

  static const String _chatStorageKey = SharedPrefKeys.chatHistory;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(() {
      if (mounted) setState(() {});
    });
    _inputFocusNode.addListener(() {
      if (mounted) setState(() {});
    });
    _loadCategories(); // جلب الكاتيجوريات عند البداية
    _loadChatState().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // دائماً نأخذ اللغة من إعداد التطبيق الحالي
        final locale = Localizations.localeOf(context).languageCode;
        final appIsEnglish = (locale == 'en');
        
        // لو اللغة اتغيرت، نمسح الـ session القديمة ونبدأ من جديد
        if (_isEnglish != appIsEnglish) {
          _isEnglish = appIsEnglish;
          _sessionId = null;
          _flowItems.clear();
          _chatHistory.clear();
          _chatMode = false;
          _activeQuestionId = null;
          _saveChatState();
        }
        
        _startSessionOnce();
      });
    });
  }

  /// حفظ حالة الشات في الذاكرة المحلية
  Future<void> _saveChatState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final state = {
        'sessionId': _sessionId,
        'chatMode': _chatMode,
        'isEnglish': _isEnglish,
        'activeQuestionId': _activeQuestionId,
        'flowItems': _flowItems.map((e) => e.toJson()).toList(),
        'chatHistory': _chatHistory.map((e) => e.toJson()).toList(),
      };
      await prefs.setString(_chatStorageKey, jsonEncode(state));
    } catch (e) {
      debugPrint('ChatBot: Error saving chat state: $e');
    }
  }

  /// استعادة حالة الشات من الذاكرة المحلية
  Future<void> _loadChatState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_chatStorageKey);
      if (raw == null || raw.isEmpty) return;

      final state = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        _sessionId = state['sessionId'] as String?;
        _chatMode = state['chatMode'] as bool? ?? false;
        _isEnglish = state['isEnglish'] as bool? ?? false;
        _activeQuestionId = state['activeQuestionId'] as String?;

        final flowList = state['flowItems'] as List<dynamic>?;
        if (flowList != null) {
          _flowItems.clear();
          for (final item in flowList) {
            final parsed = _FlowItem.fromJson(item as Map<String, dynamic>);
            if (parsed != null) _flowItems.add(parsed);
          }
        }

        final chatList = state['chatHistory'] as List<dynamic>?;
        if (chatList != null) {
          _chatHistory.clear();
          for (final item in chatList) {
            _chatHistory.add(_ChatItem.fromJson(item as Map<String, dynamic>));
          }
        }
      });
      _scrollToBottom();
    } catch (e) {
      debugPrint('ChatBot: Error loading chat state: $e');
    }
  }

  Future<void> _startSessionOnce() async {
    if (_isLoading || _sessionId != null || _flowItems.isNotEmpty) return;
    final locale = Localizations.localeOf(context).languageCode;
    _isEnglish = (locale == 'en');
    try {
      final res = await _dio.post('/session/start', data: {'language': _isEnglish ? 'en' : 'ar'});
      final data = res.data;
      if (data is Map && data['session_id'] != null) {
        _sessionId = data['session_id'].toString();
      }
      _processResponse(data);
    } catch (_) {
      setState(() => _chatMode = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
      _saveChatState();
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
        duration: Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  bool _processResponse(dynamic data) {
    final nextStep = (data is Map)
        ? (data['next_step'] ?? data['next'] ?? data['mode'] ?? data['state'])
        : null;

    if (data is Map && data['chatbot_mode'] == true) {
      setState(() => _chatMode = true);
      return true;
    }
    if (nextStep is String &&
        <String>['chat', 'chatbot', 'ai'].contains(nextStep.toLowerCase())) {
      setState(() => _chatMode = true);
      return true;
    }

    if (data is Map) {
      final result = data['result'];
      String? category;
      if (result is Map) {
        category = (_isEnglish 
            ? (result['category_en'] ?? result['category'])
            : (result['category'] ?? result['category_en']))?.toString();
      }
      if (category != null && category.trim().isNotEmpty) {
        setState(() {
          _flowItems.add(_FlowItem.result(
              text: _isEnglish ? '✅ Category selected: $category' : '✅ تم تحديد الفئة: $category', 
              category: category));
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
    final id = (data['question_id'] ??
            data['questionId'] ??
            q?['id'] ??
            q?['question_id'] ??
            q?['questionId'])
        ?.toString();
    final text = (data['question_text'] ??
            (data['question'] is String ? data['question'] : null) ??
            q?['text'] ??
            q?['question_text'])
        ?.toString();
    if (id == null || id.isEmpty || text == null || text.isEmpty) return null;

    final rawAnswers =
        (data['answers'] ?? data['options'] ?? q?['answers'] ?? q?['options']);
    final List<_FlowAnswer> answers = [];
    if (rawAnswers is List) {
      for (final a in rawAnswers) {
        if (a is Map) {
          final aid = (a['id'] ?? a['answer_id'] ?? a['value'])?.toString();
          final at = (a['text'] ?? a['label'] ?? a['answer_text'] ?? a['title'])
              ?.toString();
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

    if (a.text.toLowerCase().contains('english')) {
      _isEnglish = true;
    } else if (a.text.contains(L10nChat.arab.tr()) || a.text.contains(L10nChat.arabic.tr())) {
      _isEnglish = false;
    }

    setState(() {
      _isLoading = true;
      _activeQuestionId = null;
      _flowItems.add(_FlowItem.answer(text: a.text));
    });
    _scrollToBottom();

    final isOther =
        RegExp(r'(اخر|أخر|other)', caseSensitive: false).hasMatch(a.text);
    if (isOther) {
      setState(() {
        _flowItems.add(_FlowItem.result(
            text: _isEnglish 
                ? 'Please write your message in detail so I can help you better:' 
                : L10nChat.pleaseWriteYourMessage.tr()));
        _chatMode = true;
        _isLoading = false;
      });
      _scrollToBottom();
      _saveChatState();
      return;
    }

    try {
      final res = await _dio.post('/session/answer', data: {
        'session_id': _sessionId,
        'question_id': q.id,
        'answer_id': a.id
      });
      final data = res.data;
      if (!_processResponse(data)) {
        setState(() {
          _flowItems.add(_FlowItem.result(
            text: _isEnglish
                ? 'Sorry, I need more information. Please write a detailed message so I can better understand your needs:'
                : L10nChat.sorryINeedMore.tr(),
          ));
          _chatMode = true;
        });
      }
    } catch (_) {
      setState(() => _chatMode = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
      _saveChatState();
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

    final errorMsg = _isEnglish 
        ? 'Sorry, a connection error occurred. Please try again.'
        : L10nChat.sorryAConnectionError1.tr();
    try {
      final res = await _dio
          .post('/chat', data: {'message': msg, 'session_id': _sessionId});
      final data = res.data;
      if (data is Map && data['session_id'] != null) {
        _sessionId = data['session_id'].toString();
      }
      final reply = (data is Map && data['reply'] != null)
          ? data['reply'].toString()
          : errorMsg;

      // Detect category from structured response OR by searching for known category names in text
      String? detectedCategory;
      if (data is Map) {
        final result = data['result'];
        if (result is Map) {
          detectedCategory = (_isEnglish
              ? (result['category_en'] ?? result['category'])
              : (result['category'] ?? result['category_en']))?.toString();
        }
        detectedCategory ??= data['category']?.toString();
      }

      // If not found in structured data, search in the text for any known category names
      if (detectedCategory == null || detectedCategory.trim().isEmpty) {
        for (final cat in _categories) {
          final nameAr = cat['name_ar']?.toString() ?? '';
          final nameEn = cat['name']?.toString() ?? '';
          
          if (nameAr.isNotEmpty && reply.contains(nameAr)) {
            detectedCategory = nameAr;
            break;
          }
          if (nameEn.isNotEmpty && reply.toLowerCase().contains(nameEn.toLowerCase())) {
            detectedCategory = nameEn;
            break;
          }
        }
      }

      // Convert to Arabic canonical for consistency
      if (detectedCategory != null && detectedCategory.trim().isNotEmpty) {
        detectedCategory = _getArabicCanonical(detectedCategory);
      }

      setState(() {
        _chatHistory.removeWhere(
            (m) => m.role == _ChatRole.bot && m.text == _thinkingText);
        _chatHistory.add(_ChatItem.bot(reply, category: detectedCategory));
      });
    } catch (_) {
      setState(() {
        _chatHistory.removeWhere(
            (m) => m.role == _ChatRole.bot && m.text == _thinkingText);
        _chatHistory.add(_ChatItem.bot(errorMsg));
      });
    } finally {
      _scrollToBottom();
      _saveChatState();
    }
  }

  /// جلب الكاتيجوريات من API
  Future<void> _loadCategories() async {
    try {
      final res = await _dio.get('/category/getCategories');
      final data = res.data;
      debugPrint('ChatBot: Categories API raw data: $data');

      final List? raw = data is List
          ? data
          : (data is Map
              ? (data['categories'] ?? data['data']) as List?
              : null);

      if (raw != null) {
        final parsed = <Map<String, dynamic>>[];
        for (final c in raw) {
          if (c is Map) parsed.add(Map<String, dynamic>.from(c));
        }
        if (mounted) setState(() => _categories = parsed);
      }
    } catch (e) {}
  }

  int? _getCategoryIdByName(String categoryName) {
    try {
      final input = categoryName.trim().toLowerCase();
      for (var cat in _categories) {
        final nameEn = (cat['name']?.toString() ?? '').toLowerCase();
        final nameAr = (cat['name_ar']?.toString() ?? '').toLowerCase();

        if (nameEn == input || nameAr == input || 
            _simpleNormalize(nameEn) == _simpleNormalize(input) ||
            _simpleNormalize(nameAr) == _simpleNormalize(input)) {
          return cat['id'] as int?;
        }
      }
    } catch (_) {}
    return null;
  }

  String _simpleNormalize(String s) {
    return s
        .replaceAll(RegExp(r'[^\u0621-\u064A0-9a-zA-Z]'), '')
        .replaceAll('ة', 'ه')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي')
        .toLowerCase();
  }

  String _getArabicCanonical(String raw) {
    final clean = raw.trim().toLowerCase();
    
    // Map common variations to the official Arabic name used in the app/API
    final Map<String, String> variations = {
      'cosmetic filling': 'حشو تجميلي',
      'composite filling': 'حشو تجميلي',
      'cosmetic': 'حشو تجميلي',
      'teeth whitening': 'تنظيف وتبييض الأسنان',
      'teeth cleaning': 'تنظيف وتبييض الأسنان',
      'cleaning and whitening': 'تنظيف وتبييض الأسنان',
      'whitening': 'تنظيف وتبييض الأسنان',
      'dental implants': 'زراعة الأسنان',
      'implants': 'زراعة الأسنان',
      'surgery and extraction': 'الجراحة والخلع',
      'surgery': 'الجراحة والخلع',
      'extraction': 'الجراحة والخلع',
      'tooth extraction': 'الجراحة والخلع',
      'braces': 'تقويم الأسنان',
      'orthodontics': 'تقويم الأسنان',
      'crowns and bridges': 'تيجان وجسور',
      'fixed prosthetics': 'تيجان وجسور',
      'amalgam filling': 'حشو املغم',
      'amalgam': 'حشو املغم',
      'root canal': 'حشو عصب',
      'nerve filling': 'حشو عصب',
      'pediatric dentistry': 'طب أسنان الأطفال',
      'kids dentistry': 'طب أسنان الأطفال',
      'comprehensive dental examination': 'فحص شامل',
      'comprehensive examination': 'فحص شامل',
      'dental prosthetics': 'تركيبات اسنان',
      'removable prosthetics': 'تركيبات متحركة',
    };
    
    return variations[clean] ?? raw;
  }

  String _getEnglishName(String arabicName) {
     final Map<String, String> arToEn = {
        'حشو تجميلي': 'Cosmetic Filling',
        'تنظيف وتبييض الأسنان': 'Teeth Whitening',
        'زراعة الأسنان': 'Dental Implants',
        'الجراحة والخلع': 'Surgery and Extraction',
        'تقويم الأسنان': 'Orthodontics',
        'تيجان وجسور': 'Crowns and Bridges',
        'حشو املغم': 'Amalgam Filling',
        'حشو عصب': 'Nerve Filling',
        'طب أسنان الأطفال': 'Pediatric Dentistry',
        'فحص شامل': 'Comprehensive Examination',
        'تركيبات اسنان': 'Dental Prosthetics',
        'تركيبات متحركة': 'Removable Prosthetics',
     };
     return arToEn[arabicName] ?? arabicName;
  }

  String _getAssetForCategory(String categoryName) {
    String name = categoryName.trim();
    
    // Exact mapping if possible
    final Map<String, String> categoryAssets = {
      L10nChat.amalgamFilling.tr(): 'assets/svg/املغم.svg',
      L10nChat.nerveFilling.tr(): 'assets/svg/حشو اسنان.svg',
      L10nChat.cosmeticFiller.tr(): 'assets/svg/تجميلي.svg',
      L10nChat.dentalImplants.tr(): 'assets/svg/زراعه اسنان.svg',
      L10nChat.surgeryAndExtraction.tr(): 'assets/svg/خلع اسنان.svg',
      L10nChat.cleaningAndWhiteningTeeth.tr(): 'assets/svg/تبيض اسنان.svg',
      L10nChat.teethWhitening.tr(): 'assets/svg/تبيض اسنان.svg',
      L10nChat.orthodontics.tr(): 'assets/svg/تقويم اسنان.svg',
      L10nChat.dentalProsthetics.tr(): 'assets/svg/تركيبات اسنان.svg',
      L10nChat.crownsAndBridges1.tr(): 'assets/images/تيجان وجسور.webp',
      L10nChat.pediatricDentistry.tr(): 'assets/svg/اطفال2.svg',
      L10nChat.movingInstallations.tr(): 'assets/svg/تركيبات اسنان.svg',
    };

    if (categoryAssets.containsKey(name)) {
      return categoryAssets[name]!;
    }

    // Normalization and partial matching
    String normalized = name
        .replaceAll('ة', 'ه')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll('آ', 'ا')
        .replaceAll('ى', 'ي');

    if (normalized.contains('فحص') || normalized.toLowerCase().contains('examination') || normalized.toLowerCase().contains('checkup')) return 'assets/svg/فحص شامل.svg';
    if (normalized.contains('املغم') || normalized.contains('املجم') || normalized.toLowerCase().contains('amalgam')) return 'assets/svg/املغم.svg';
    if (normalized.contains('عصب') || normalized.toLowerCase().contains('nerve') || normalized.toLowerCase().contains('root canal')) return 'assets/svg/حشو اسنان.svg';
    if (normalized.contains('تجميلي') || normalized.contains('تحميلي') || normalized.toLowerCase().contains('cosmetic') || normalized.toLowerCase().contains('composite')) return 'assets/svg/تجميلي.svg';
    if (normalized.contains('زراعه') || normalized.contains('زراعة') || normalized.toLowerCase().contains('implant')) return 'assets/svg/زراعه اسنان.svg';
    if (normalized.contains('خلع') || normalized.contains('جراحه') || normalized.contains('جراحة') || normalized.toLowerCase().contains('extraction') || normalized.toLowerCase().contains('surgery')) return 'assets/svg/خلع اسنان.svg';
    if (normalized.contains('تبيض') || normalized.contains('تنظيف') || normalized.toLowerCase().contains('whitening') || normalized.toLowerCase().contains('cleaning')) return 'assets/svg/تبيض اسنان.svg';
    if (normalized.contains('تقويم') || normalized.toLowerCase().contains('orthodontic') || normalized.toLowerCase().contains('brace')) return 'assets/svg/تقويم اسنان.svg';
    if (normalized.contains('تركيبات') || normalized.toLowerCase().contains('prosthetic') || normalized.toLowerCase().contains('installation')) return 'assets/svg/تركيبات اسنان.svg';
    if (normalized.contains('تيجان') || normalized.contains('جسور') || normalized.toLowerCase().contains('crown') || normalized.toLowerCase().contains('bridge')) return 'assets/images/تيجان وجسور.webp';
    if (normalized.contains('اطفال') || normalized.contains('أطفال') || normalized.toLowerCase().contains('pediatric') || normalized.toLowerCase().contains('child')) return 'assets/svg/اطفال2.svg';

    return 'assets/svg/فحص شامل.svg';
  }

  void _openCategory(String rawCategory) {
    final arabicCanonical = _getArabicCanonical(rawCategory);
    final uiName = _isEnglish ? _getEnglishName(arabicCanonical) : arabicCanonical;
    
    debugPrint('ChatBot: rawCategory=$rawCategory');
    debugPrint('ChatBot: arabicCanonical=$arabicCanonical');
    
    // Search for the ID using the Arabic canonical name (more reliable)
    final categoryId = _getCategoryIdByName(arabicCanonical);
    debugPrint('ChatBot: categoryId=$categoryId');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDoctorsScreen(
          categoryName: uiName,
          categorySvg: _getAssetForCategory(arabicCanonical),
          categoryId: categoryId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          _header(theme),
          Expanded(
            child: _chatBody(
              theme,
              bottomPadding: _chatMode ? 0 : 0,
            ),
          ),
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
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        left: 22,
        right: 22,
        bottom: 15,
        top: topPad + 15,
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? theme.cardColor : _color2,
        border: theme.brightness == Brightness.dark
            ? Border(bottom: BorderSide(color: theme.dividerColor))
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/svg/ثوثه الدكتور 1.svg',
                  width: 32, height: 32),
              SizedBox(width: 8),
              Text(
                _isEnglish ? 'Thoutha Smart Doctor' : L10nChat.thouthaTheSmartDoctor.tr(),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
          Positioned(
            right: 0,
            child: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    Routes.categoriesScreen,
                    (route) => false,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatBody(
    ThemeData theme, {
    required double bottomPadding,
  }) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
          16, 25, 16, 25 + (bottomPadding > 0 ? bottomPadding : 0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _botMessage(_isEnglish ? '👋🏻 Welcome How can I help you?' : L10nChat.welcomeHowCanIHelp.tr()),
          if (_isLoading && _flowItems.isEmpty) ...[
            SizedBox(height: 16),
            _botMessage(_isEnglish ? '...Preparing questions' : L10nChat.preparingQuestions.tr()),
          ],
          for (final item in _flowItems) ...[
            SizedBox(height: 16),
            if (item.type == _FlowType.question) ...[
              _botMessage(item.question!.text),
              if (!_chatMode &&
                  _activeQuestionId == item.question!.id &&
                  item.question!.answers.isNotEmpty) ...[
                SizedBox(height: 14),
                _quickReplies(item.question!),
              ],
            ] else if (item.type == _FlowType.result) ...[
              _botMessage(item.text),
              if (item.category != null) ...[
                SizedBox(height: 14),
                _resultButton(item.category!),
              ],
            ] else ...[
              _userMessage(item.text),
            ],
          ],
          for (final m in _chatHistory) ...[
            SizedBox(height: 16),
            if (m.role == _ChatRole.user)
              _userMessage(m.text)
            else
              _botMessage(m.text),
            if (m.role == _ChatRole.bot &&
                m.category != null &&
                m.category!.trim().isNotEmpty) ...[
              SizedBox(height: 14),
              _resultButton(m.category!),
            ],
          ],
        ],
      ),
    );
  }

  Widget _footer(ThemeData theme) {
    final hasText = _inputController.text.trim().isNotEmpty;
    final isFocused = _inputFocusNode.hasFocus;
    final borderRadius = BorderRadius.circular(30);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      color: theme.scaffoldBackgroundColor,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.brightness == Brightness.dark
              ? theme.cardColor
              : Colors.white,
          borderRadius: borderRadius,
          border: Border.all(
            color: isFocused
                ? _color2
                : (theme.brightness == Brightness.dark
                    ? Colors.grey[700]!
                    : _outline.withOpacity(0.3)),
            width: isFocused ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendChatMessage(),
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: theme.colorScheme.onSurface,
                        fontSize: 15),
                    decoration: InputDecoration(
                      hintText: _isEnglish ? 'Type your message...' : L10nChat.writeYourMessage.tr(),
                      hintTextDirection: TextDirection.rtl,
                      hintStyle: TextStyle(
                          fontFamily: 'Cairo',
                          color: theme.brightness == Brightness.dark
                              ? Colors.grey[500]
                              : Color(0xFF9E9E9E),
                          fontSize: 14),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      fillColor: Colors.transparent,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
                AnimatedScale(
                  scale: hasText ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 250),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: hasText ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 200),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: InkWell(
                        onTap: _isLoading ? null : _sendChatMessage,
                        borderRadius: BorderRadius.circular(999),
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: _color2),
                          child: Icon(Icons.arrow_upward,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ),
                ),
                if (!hasText) SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _botAvatar({required double size}) {
    return Container(
      height: size,
      width: size,
      padding: EdgeInsets.all(size * 0.18),
      decoration: BoxDecoration(color: _color2, shape: BoxShape.circle),
      child: SvgPicture.asset('assets/svg/ثوثه الدكتور 1.svg'),
    );
  }

  Widget _botMessage(String text) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.surfaceContainerHighest.withOpacity(0.5)
                  : _color3,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(13),
                topRight: Radius.circular(13),
                bottomRight: Radius.circular(13),
                bottomLeft: Radius.circular(3),
              ),
            ),
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 8),
        _botAvatar(size: 32),
      ],
    );
  }

  Widget _userMessage(String text) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _color2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(13),
            topRight: Radius.circular(13),
            bottomRight: Radius.circular(3),
            bottomLeft: Radius.circular(13),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
            height: 1.5,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _quickReplies(_FlowQuestion q) {
    final theme = Theme.of(context);
    final answers = q.answers;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final a in answers) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _submitAnswer(q, a),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.brightness == Brightness.dark
                    ? Color(0xFF1E1E2D)
                    : Colors.white,
                foregroundColor: theme.brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                side: BorderSide(
                  color: _color2,
                  width: 1.5,
                ),
                elevation: theme.brightness == Brightness.dark ? 2 : 1,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                a.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 12),
        ],
      ],
    );
  }

  Future<void> _restartSession() async {
    setState(() {
      _isLoading = true;
      
      // Move current chat history into flow items to preserve chronological order
      for (final item in _chatHistory) {
        if (item.role == _ChatRole.user) {
          _flowItems.add(_FlowItem.answer(text: item.text));
        } else {
          _flowItems.add(_FlowItem.result(text: item.text, category: item.category));
        }
      }
      _chatHistory.clear();

      _sessionId = null;
      _activeQuestionId = null;
      _chatMode = false;
      
      // Add a separator instead of clearing
      _flowItems.add(_FlowItem.result(
          text: _isEnglish ? '— New Conversation —' : L10nChat.newConversation.tr()));
    });

    try {
      final res = await _dio.post('/session/start', data: {'language': 'ar'});
      final data = res.data;
      if (data is Map && data['session_id'] != null) {
        _sessionId = data['session_id'].toString();
      }
      _processResponse(data);
    } catch (_) {
      setState(() => _chatMode = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
      _saveChatState();
    }
  }

  Widget _resultButton(String category) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      children: [
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: _color2.withOpacity(0.3),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => _openCategory(category),
              style: ElevatedButton.styleFrom(
                backgroundColor: _color2,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.75),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Text(
                        _isEnglish ? 'View $category cases' : 'عرض حالات $category',
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_back_rounded, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 10),
        Center(
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _restartSession,
            icon: Icon(Icons.refresh_rounded, size: 18, color: _color2),
              label: Text(
                _isEnglish ? 'Restart conversation' : L10nChat.restartTheConversationFrom.tr(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _color2,
                ),
              ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: _color2, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }
}

enum _FlowType { question, answer, result }

class _FlowItem {
  final _FlowType type;
  final String text;
  final _FlowQuestion? question;
  final String? category;

  _FlowItem._(
      {required this.type, required this.text, this.question, this.category});

  factory _FlowItem.question(_FlowQuestion q) =>
      _FlowItem._(type: _FlowType.question, text: q.text, question: q);
  factory _FlowItem.answer({required String text}) =>
      _FlowItem._(type: _FlowType.answer, text: text);
  factory _FlowItem.result({required String text, String? category}) =>
      _FlowItem._(type: _FlowType.result, text: text, category: category);

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'text': text,
        'category': category,
        'question': question?.toJson(),
      };

  static _FlowItem? fromJson(Map<String, dynamic> json) {
    final typeName = json['type'] as String?;
    if (typeName == null) return null;
    final type = _FlowType.values.firstWhere(
      (e) => e.name == typeName,
      orElse: () => _FlowType.result,
    );
    final questionJson = json['question'] as Map<String, dynamic>?;
    return _FlowItem._(
      type: type,
      text: json['text'] as String? ?? '',
      category: json['category'] as String?,
      question: questionJson != null ? _FlowQuestion.fromJson(questionJson) : null,
    );
  }
}

class _FlowQuestion {
  final String id;
  final String text;
  final List<_FlowAnswer> answers;
  _FlowQuestion({required this.id, required this.text, required this.answers});

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'answers': answers.map((a) => a.toJson()).toList(),
      };

  factory _FlowQuestion.fromJson(Map<String, dynamic> json) => _FlowQuestion(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
        answers: (json['answers'] as List<dynamic>?)
                ?.map((a) => _FlowAnswer.fromJson(a as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

class _FlowAnswer {
  final String id;
  final String text;
  _FlowAnswer({required this.id, required this.text});

  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  factory _FlowAnswer.fromJson(Map<String, dynamic> json) => _FlowAnswer(
        id: json['id'] as String? ?? '',
        text: json['text'] as String? ?? '',
      );
}

enum _ChatRole { user, bot }

class _ChatItem {
  final _ChatRole role;
  final String text;
  final String? category;
  _ChatItem._(this.role, this.text, {this.category});

  factory _ChatItem.user(String text) => _ChatItem._(_ChatRole.user, text);
  factory _ChatItem.bot(String text, {String? category}) =>
      _ChatItem._(_ChatRole.bot, text, category: category);

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'text': text,
        if (category != null) 'category': category,
      };

  factory _ChatItem.fromJson(Map<String, dynamic> json) {
    final role =
        (json['role'] as String?) == 'user' ? _ChatRole.user : _ChatRole.bot;
    return _ChatItem._(
      role,
      json['text'] as String? ?? '',
      category: json['category'] as String?,
    );
  }
}

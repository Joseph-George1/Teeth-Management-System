import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/styles.dart';
import '../../../core/networking/dio_factory.dart';
import '../../../core/helpers/shared_pref_helper.dart';
import '../../../core/helpers/constants.dart';
import '../../main_layout/ui/main_layout_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _ensureConversationId();
    // Precache chatbot avatar to ensure circular image renders instantly
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage('assets/images/chatbot.jpg'), context);
    });
  }

  Future<void> _ensureConversationId() async {
    // Try to load an existing conversation id from secure storage
    final existing = await SharedPrefHelper.getSecuredString(SharedPrefKeys.conversationId);
    String id = (existing is String) ? existing : '';
    if (id.isEmpty) {
      // Generate a simple unique id without extra dependencies
      final rnd = Random().nextInt(999999).toString().padLeft(6, '0');
      id = 'sess-${DateTime.now().millisecondsSinceEpoch}-$rnd';
      await SharedPrefHelper.setSecuredString(SharedPrefKeys.conversationId, id);
    }
    if (mounted) {
      setState(() {
        _conversationId = id;
      });
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;
    // Ensure we have a conversation id before sending
    if (_conversationId == null || _conversationId!.isEmpty) {
      await _ensureConversationId();
    }
    setState(() {
      _isSending = true;
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _msgController.clear();

    try {
      final Dio dio = DioFactory.getDio();
      // Build limited conversation history (exclude the just-typed message to avoid duplication)
      final prior = _messages.length > 1 ? _messages.sublist(0, _messages.length - 1) : const <_ChatMessage>[];
      // Take last 10 turns max to keep payload small
      final take = prior.length > 10 ? prior.sublist(prior.length - 10) : prior;
      final history = take
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.text,
              })
          .toList(growable: false);
      final response = await dio.post(
        'https://thoutha.page/api/chat',
        data: {
          'message': text,
          'history': history,
          'conversation_id': _conversationId,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      String botText;
      final data = response.data;
      if (data is Map && data['reply'] != null) {
        botText = data['reply'].toString();
      } else if (data is Map && data['response'] != null) {
        botText = data['response'].toString();
      } else {
        botText = data.toString();
      }

      setState(() {
        _messages.add(_ChatMessage(text: botText, isUser: false));
      });
    } catch (e) {
      String errText = 'حدث خطأ أثناء الإرسال. حاول مرة أخرى.';
      if (e is DioException) {
        final code = e.response?.statusCode;
        final data = e.response?.data;
        final msg = e.message;
        errText = 'فشل الإرسال (${code ?? 'شبكة'}): ${data ?? msg ?? 'تحقق من الاتصال'}';
      }
      setState(() {
        _messages.add(_ChatMessage(text: errText, isUser: false));
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            // Navigate to main layout with home_screen tab (index 0) selected
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainLayoutScreen(initialIndex: 0),
              ),
            );
          },
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Top-left gradient overlay (monochrome)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.7, -0.7),
                radius: 1.5,
                colors: [
                  Colors.black.withOpacity(0.08),
                  Colors.black.withOpacity(0.03),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),
          // Bottom-right gradient overlay (monochrome)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 1.5,
                colors: [
                  Colors.black.withOpacity(0.06),
                  Colors.black.withOpacity(0.02),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 0.8],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  children: [
                    // Header
                    Text(
                      'الطبيب المساعد ثوثه',
                      style: TextStyles.font24BlackBold,
                    ),
                    verticalSpace(8),
                    // Chatbot header image (centered circle)
                    Center(
                      child: CircleAvatar(
                        radius: 34,
                        backgroundImage:
                            const AssetImage('assets/images/chatbot.jpg'),
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                    verticalSpace(8),

                    // Messages list
                    Expanded(
                      child: ListView.separated(
                        reverse: true,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        itemBuilder: (context, index) {
                          final msg = _messages[_messages.length - 1 - index];
                          if (msg.isUser) {
                            // User bubble (left)
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 0.8.sw),
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  msg.text,
                                  style: TextStyles.font15DarkBlueMedium,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            );
                          } else {
                            // Bot bubble (right) with small avatar at the start
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black12, width: 1),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    'assets/images/chatbo t.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                ConstrainedBox(
                                  constraints: BoxConstraints(maxWidth: 0.75.sw),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      msg.text,
                                      style: TextStyles.font15DarkBlueMedium,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                        },
                        separatorBuilder: (_, __) => verticalSpace(8),
                        itemCount: _messages.length,
                      ),
                    ),

                    // Input bar
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _sendMessage(),
                            decoration: InputDecoration(
                              hintText: 'اكتب رسالتك...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            ),
                          ),
                        ),
                        horizontalSpace(8),
                        IconButton(
                          onPressed: _isSending ? null : _sendMessage,
                          icon: const Icon(Icons.send),
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

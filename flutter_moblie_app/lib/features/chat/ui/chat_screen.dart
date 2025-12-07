import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

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
        leadingWidth: 8,
       // backgroundColor: Colors.blue,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainLayoutScreen(initialIndex: 0),
              ),
            );
          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ const SizedBox(width: 8),
            Text(
              'الطبيب المساعد ثوثة',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,

            ), const SizedBox(width: 8),
            SvgPicture.asset(
              'assets/svg/ثوثه الدكتور 1.svg',
              width: 40,
              height: 40,
            ),

          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
      ),
      body: Container(
        color: Colors.white,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            children: [
              // Chat messages
            Expanded(
              child: ListView.separated(
                reverse: true,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final msg = _messages[_messages.length - 1 - index];
                  if (msg.isUser) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 0.75 * MediaQuery.of(context).size.width),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              msg.text,
                              style: GoogleFonts.cairo(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                height: 1.6, // 160% line height
                                letterSpacing: 0.15,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(

                          width: 40,
                          height: 40,
                          child: SvgPicture.asset(
                            'assets/svg/ثوثه الدكتور 1.svg',

                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 0.75 * MediaQuery.of(context).size.width),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.lightBlueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: _messages.length,
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
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
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                    color: Colors.black,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      ));
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

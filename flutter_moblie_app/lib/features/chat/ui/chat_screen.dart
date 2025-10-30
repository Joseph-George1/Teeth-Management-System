import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';

import '../../../core/helpers/spacing.dart';
import '../../../core/theming/colors.dart';
import '../../../core/theming/styles.dart';
import '../../../core/networking/dio_factory.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() {
      _isSending = true;
      _messages.add(_ChatMessage(text: text, isUser: true));
    });
    _msgController.clear();

    try {
      final Dio dio = DioFactory.getDio();
      final response = await dio.post(
        'http://16.16.218.118:5000/chat',
        data: {
          'message': text,
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
      setState(() {
        _messages.add(_ChatMessage(text: 'حدث خطأ أثناء الإرسال. حاول مرة أخرى.', isUser: false));
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

                    // Messages list
                    Expanded(
                      child: ListView.separated(
                        reverse: true,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        itemBuilder: (context, index) {
                          final msg = _messages[_messages.length - 1 - index];
                          return Align(
                            alignment: msg.isUser
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            child: Container(
                              constraints: BoxConstraints(maxWidth: 0.8.sw),
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              decoration: BoxDecoration(
                                color: msg.isUser
                                    ? Colors.black.withOpacity(0.05)
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyles.font15DarkBlueMedium,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          );
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

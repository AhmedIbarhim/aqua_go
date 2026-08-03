import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:aqua_go/generated/locale_keys.g.dart';
import '../../../../core/components/generic_app_bar.dart';
import '../../../../core/extentions/context_extentions.dart';
import '../../data/models/support_chat_message.dart';
import '../widgets/support_chat_bubble.dart';
import '../widgets/support_chat_date_divider.dart';
import '../widgets/support_chat_input_field.dart';

class SupportChatView extends StatefulWidget {
  const SupportChatView({super.key});

  @override
  State<SupportChatView> createState() => _SupportChatViewState();
}

class _SupportChatViewState extends State<SupportChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<SupportChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadInitialMockMessages();
  }

  void _loadInitialMockMessages() {
    _messages.addAll([
      SupportChatMessage.message(
        id: '1',
        text: 'شكرا لك لاستخدامك خدماتنا',
        time: '14:00 م',
        isMe: false,
      ),
      SupportChatMessage.dateDivider(
        id: 'divider_1',
        dateText: 'الجمعة 8 مايو 2026',
      ),
      SupportChatMessage.message(
        id: '2',
        text: 'هل يمكنني التحدث مع خدمة العملاء؟',
        time: '16:00 م',
        isMe: true,
        status: 'مقروء',
      ),
      SupportChatMessage.message(
        id: '3',
        text: 'لدي مشكلة في خطوات الحجز',
        time: '16:00 م',
        isMe: true,
        status: 'مقروء',
      ),
      SupportChatMessage.message(
        id: '4',
        text: 'نحن في خدمتك, مانوع المشكلة التي تواجهها؟',
        time: '14:00 م',
        isMe: false,
      ),
      SupportChatMessage.message(
        id: '5',
        text:
            'اذا كان استفسارك عن خطوات الحجز ف عليك اتباع الخطوات التالية:\n- اختيار نوع الخدمة\n- اختيار نوع السيارة\n- اختيار الوقت و التاريخ المناسب\n- اضافة خدمات اخري\n- اختيار طريقة دفع و الاستمرار',
        time: '14:00 م',
        isMe: false,
      ),
      SupportChatMessage.dateDivider(
        id: 'divider_2',
        dateText: 'السبت 9 مايو 2026',
      ),
      SupportChatMessage.message(
        id: '6',
        text: 'لدي استفسار عن الغاء الحجز؟',
        time: '16:00 م',
        isMe: true,
        status: 'غير مقروء',
      ),
    ]);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final newMsg = SupportChatMessage.message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      time: _getCurrentTimeArabic(),
      isMe: true,
      status: 'غير مقروء',
    );

    setState(() {
      _messages.add(newMsg);
      _messageController.clear();
    });

    _scrollToBottom();
  }

  String _getCurrentTimeArabic() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'م' : 'ص';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double sw(double width) => context.sw(width);

    return Scaffold(
      backgroundColor: context.colors.screenBG,
      appBar: GenericAppBar(
        title: LocaleKeys.support_contact_us.tr(context: context),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.symmetric(
                horizontal: sw(16),
                vertical: sw(8),
              ),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final item = _messages[index];
                if (item.isDateDivider) {
                  return SupportChatDateDivider(date: item.dateText ?? '');
                } else {
                  return SupportChatBubble(
                    text: item.text,
                    time: item.time,
                    isMe: item.isMe,
                    status: item.status,
                  );
                }
              },
            ),
          ),
          SupportChatInputField(
            controller: _messageController,
            onSend: _sendMessage,
            onAttach: () {
              // Attachment logic (can be implemented in future)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('سيتم إضافة ميزة إرفاق الملفات قريباً'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

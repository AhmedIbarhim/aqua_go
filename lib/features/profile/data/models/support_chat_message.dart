class SupportChatMessage {
  final String id;
  final String text;
  final String time;
  final bool isMe;
  final String? status;
  final bool isDateDivider;
  final String? dateText;

  const SupportChatMessage({
    required this.id,
    this.text = '',
    this.time = '',
    required this.isMe,
    this.status,
    this.isDateDivider = false,
    this.dateText,
  });

  factory SupportChatMessage.message({
    required String id,
    required String text,
    required String time,
    required bool isMe,
    String? status,
  }) {
    return SupportChatMessage(
      id: id,
      text: text,
      time: time,
      isMe: isMe,
      status: status,
      isDateDivider: false,
    );
  }

  factory SupportChatMessage.dateDivider({
    required String id,
    required String dateText,
  }) {
    return SupportChatMessage(
      id: id,
      isMe: false,
      isDateDivider: true,
      dateText: dateText,
    );
  }
}

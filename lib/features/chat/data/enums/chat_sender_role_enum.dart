enum ChatSenderRole {
  customer,
  worker,
  supportAgent,
  system;

  static ChatSenderRole fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'WORKER':
        return ChatSenderRole.worker;
      case 'SUPPORT_AGENT':
        return ChatSenderRole.supportAgent;
      case 'SYSTEM':
        return ChatSenderRole.system;
      case 'CUSTOMER':
      default:
        return ChatSenderRole.customer;
    }
  }

  String get originalValue {
    switch (this) {
      case ChatSenderRole.customer:
        return 'CUSTOMER';
      case ChatSenderRole.worker:
        return 'WORKER';
      case ChatSenderRole.supportAgent:
        return 'SUPPORT_AGENT';
      case ChatSenderRole.system:
        return 'SYSTEM';
    }
  }

  bool get isMe => this == ChatSenderRole.customer;
  bool get isSystem => this == ChatSenderRole.system;
}

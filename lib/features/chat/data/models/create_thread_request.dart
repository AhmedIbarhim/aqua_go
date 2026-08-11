import '../enums/chat_category_enum.dart';
import '../enums/chat_thread_kind_enum.dart';

class CreateThreadRequest {
  final ChatThreadKind kind;
  final ChatCategory category;
  final String subject;
  final String? bookingId;

  const CreateThreadRequest({
    this.kind = ChatThreadKind.customerSupport,
    required this.category,
    required this.subject,
    this.bookingId,
  });

  Map<String, dynamic> toJson() {
    return {
      'kind': kind.originalValue,
      'category': category.originalValue,
      'subject': subject,
      if (bookingId != null && bookingId!.isNotEmpty) 'bookingId': bookingId,
    };
  }
}

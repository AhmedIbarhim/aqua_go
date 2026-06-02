import 'booking_response_model.dart';

class BookingsListResponseModel {
  final List<BookingResponseModel> items;
  final String? nextCursor;
  final int? totalMatching;

  BookingsListResponseModel({
    required this.items,
    this.nextCursor,
    this.totalMatching,
  });

  factory BookingsListResponseModel.fromJson(Map<String, dynamic> json) {
    return BookingsListResponseModel(
      items:
          (json['items'] as List?)
              ?.map(
                (item) =>
                    BookingResponseModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      nextCursor: json['nextCursor'] as String?,
      totalMatching: json['totalMatching'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'nextCursor': nextCursor,
      'totalMatching': totalMatching,
    };
  }
}

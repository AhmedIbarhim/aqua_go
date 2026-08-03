import 'gift_model.dart';

class GiftsListResponseModel {
  final List<GiftModel> items;
  final String? nextCursor;
  final int? totalMatching;

  GiftsListResponseModel({
    required this.items,
    this.nextCursor,
    this.totalMatching,
  });

  factory GiftsListResponseModel.fromJson(Map<String, dynamic> json) {
    return GiftsListResponseModel(
      items: (json['items'] as List?)
          ?.map((item) => GiftModel.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      nextCursor: json['nextCursor'] as String?,
      totalMatching: json['totalMatching'] as int?,
    );
  }
}

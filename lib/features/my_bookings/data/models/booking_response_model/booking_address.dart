class BookingAddress {
  String? addressId;
  String? label;
  num? lat;
  num? lng;
  String? details;
  String? arrivalNotes;
  String? zoneId;
  bool? isSaved;

  BookingAddress({
    this.addressId,
    this.label,
    this.lat,
    this.lng,
    this.details,
    this.arrivalNotes,
    this.zoneId,
    this.isSaved,
  });

  BookingAddress.fromJson(Map<String, dynamic> json) {
    addressId = json['addressId'];
    label = json['label'];
    lat = json['lat'] != null ? num.tryParse(json['lat'].toString()) : null;
    lng = json['lng'] != null ? num.tryParse(json['lng'].toString()) : null;
    details = json['details'];
    arrivalNotes = json['arrivalNotes'];
    zoneId = json['zoneId'];
    isSaved = json['isSaved'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['addressId'] = addressId;
    data['label'] = label;
    data['lat'] = lat;
    data['lng'] = lng;
    data['details'] = details;
    data['arrivalNotes'] = arrivalNotes;
    data['zoneId'] = zoneId;
    data['isSaved'] = isSaved;
    return data;
  }
}

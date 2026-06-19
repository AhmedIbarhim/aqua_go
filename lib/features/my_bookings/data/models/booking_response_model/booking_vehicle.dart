class BookingVehicle {
  int? vehicleSeq;
  String? vehicleMake;
  String? vehicleModel;
  String? vehicleColor;
  int? vehicleYear;
  String? plate;
  String? makeLogoUrl;
  bool? colorEditable;

  BookingVehicle({
    this.vehicleSeq,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleYear,
    this.plate,
    this.makeLogoUrl,
    this.colorEditable,
  });

  BookingVehicle.fromJson(Map<String, dynamic> json) {
    vehicleSeq = json['vehicleSeq'];
    vehicleMake = json['vehicleMake'];
    vehicleModel = json['vehicleModel'];
    vehicleColor = json['vehicleColor'];
    vehicleYear = json['vehicleYear'] != null
        ? int.tryParse(json['vehicleYear'].toString())
        : null;
    plate = json['plate'];
    makeLogoUrl = json['makeLogoUrl'];
    colorEditable = json['colorEditable'] as bool?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicleSeq'] = vehicleSeq;
    data['vehicleMake'] = vehicleMake;
    data['vehicleModel'] = vehicleModel;
    data['vehicleColor'] = vehicleColor;
    data['vehicleYear'] = vehicleYear;
    data['plate'] = plate;
    data['makeLogoUrl'] = makeLogoUrl;
    data['colorEditable'] = colorEditable;
    return data;
  }
}

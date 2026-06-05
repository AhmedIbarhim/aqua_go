class BookingVehicle {
  int? vehicleSeq;
  String? vehicleMake;
  String? vehicleModel;
  String? vehicleColor;
  int? vehicleYear;
  String? plateMasked;
  String? makeLogoUrl;

  BookingVehicle({
    this.vehicleSeq,
    this.vehicleMake,
    this.vehicleModel,
    this.vehicleColor,
    this.vehicleYear,
    this.plateMasked,
    this.makeLogoUrl,
  });

  BookingVehicle.fromJson(Map<String, dynamic> json) {
    vehicleSeq = json['vehicleSeq'];
    vehicleMake = json['vehicleMake'] ?? json['vehicle_make'];
    vehicleModel = json['vehicleModel'] ?? json['vehicle_model'];
    vehicleColor = json['vehicleColor'] ?? json['vehicle_color'];
    vehicleYear = json['vehicleYear'] != null
        ? int.tryParse(json['vehicleYear'].toString())
        : (json['vehicle_year'] != null
            ? int.tryParse(json['vehicle_year'].toString())
            : null);
    plateMasked = json['plateMasked'] ??
        json['plate_masked'] ??
        json['plateText'] ??
        json['plate_text'];
    makeLogoUrl = json['makeLogoUrl'] ??
        json['vehicleMakeLogoUrl'] ??
        json['vehicle_make_logo_url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicleSeq'] = vehicleSeq;
    data['vehicleMake'] = vehicleMake;
    data['vehicleModel'] = vehicleModel;
    data['vehicleColor'] = vehicleColor;
    data['vehicleYear'] = vehicleYear;
    data['plateMasked'] = plateMasked;
    data['makeLogoUrl'] = makeLogoUrl;
    return data;
  }
}

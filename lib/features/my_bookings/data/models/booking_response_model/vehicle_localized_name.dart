class VehicleLocalizedName {
  String? ar;
  String? en;

  VehicleLocalizedName({this.ar, this.en});

  VehicleLocalizedName.fromJson(Map<String, dynamic> json) {
    ar = json['ar'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ar'] = ar;
    data['en'] = en;
    return data;
  }
}

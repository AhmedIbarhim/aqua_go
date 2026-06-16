class ServiceName {
  String? en;
  String? ar;

  ServiceName({this.en, this.ar});

  ServiceName.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar_SA'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['en'] = en;
    json['ar_SA'] = ar;
    return json;
  }
}

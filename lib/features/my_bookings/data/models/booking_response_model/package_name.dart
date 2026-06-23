class PackageName {
  String? en;
  String? ar;

  PackageName({this.en, this.ar});

  PackageName.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    ar = json['ar'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['en'] = en;
    json['ar'] = ar;
    return json;
  }
}

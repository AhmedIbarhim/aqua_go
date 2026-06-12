class PackageName {
  String? en;
  String? ar;

  PackageName({this.en, this.ar});

  PackageName.fromJson(Map<String, dynamic> json) {
    en = json['en'] ?? json['nameEn'] ?? json['name'];
    ar = json['ar_SA'] ?? json['ar'] ?? json['nameAr'] ?? json['name_ar'] ?? json['name_sa'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = <String, dynamic>{};
    json['en'] = en;
    json['ar_SA'] = ar;
    return json;
  }
}

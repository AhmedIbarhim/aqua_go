class Photos {
  String? stage;
  String? angle;
  String? url;

  Photos({this.stage, this.angle, this.url});

  Photos.fromJson(Map<String, dynamic> json) {
    stage = json['stage'];
    angle = json['angle'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stage'] = stage;
    data['angle'] = angle;
    data['url'] = url;
    return data;
  }
}

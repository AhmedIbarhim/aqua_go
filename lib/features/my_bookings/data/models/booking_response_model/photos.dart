class Photos {
  int? vehicleSeq;
  String? stage;
  String? angle;
  String? url;

  Photos({this.vehicleSeq, this.stage, this.angle, this.url});

  Photos.fromJson(Map<String, dynamic> json) {
    vehicleSeq = json['vehicleSeq'];
    stage = json['stage'];
    angle = json['angle'];
    url = json['url'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['vehicleSeq'] = vehicleSeq;
    data['stage'] = stage;
    data['angle'] = angle;
    data['url'] = url;
    return data;
  }
}

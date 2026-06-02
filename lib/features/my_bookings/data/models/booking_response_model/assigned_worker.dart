class AssignedWorker {
  String? workerId;
  String? displayName;
  int? ratingAggregate;

  AssignedWorker({this.workerId, this.displayName, this.ratingAggregate});

  AssignedWorker.fromJson(Map<String, dynamic> json) {
    workerId = json['workerId'];
    displayName = json['displayName'];
    ratingAggregate = json['ratingAggregate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['workerId'] = workerId;
    data['displayName'] = displayName;
    data['ratingAggregate'] = ratingAggregate;
    return data;
  }
}

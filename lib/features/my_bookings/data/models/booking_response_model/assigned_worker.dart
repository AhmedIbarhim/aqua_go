class AssignedWorker {
  String? workerId;
  String? displayName;
  num? ratingAggregate;
  String? avatarUrl;

  AssignedWorker({
    this.workerId,
    this.displayName,
    this.ratingAggregate,
    this.avatarUrl,
  });

  AssignedWorker.fromJson(Map<String, dynamic> json) {
    workerId = json['workerId'];
    displayName = json['displayName'];
    ratingAggregate = json['ratingAggregate'];
    avatarUrl = json['avatarUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['workerId'] = workerId;
    data['displayName'] = displayName;
    data['ratingAggregate'] = ratingAggregate;
    data['avatarUrl'] = avatarUrl;
    return data;
  }
}

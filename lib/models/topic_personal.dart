class TopicPersonal {
  String? userId;
  List<String>? topicIds;

  TopicPersonal({this.userId, this.topicIds});

  TopicPersonal.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    topicIds = List<String>.from(json['topicIds'].map((x) => x as String));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data['userId'] = userId;
    _data['topicIds'] = topicIds;

    return _data;
  }
}
class LearningProgress {
  String? userId;
  String? topicId;
  Map<String, String>? wordStatus; // Word ID to learning status mapping

  LearningProgress({
    this.userId,
    this.topicId,
    this.wordStatus,
  });

  factory LearningProgress.fromJson(Map<String, dynamic> json) {
    return LearningProgress(
      userId: json['userId'],
      topicId: json['topicId'],
      wordStatus: json['wordStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};

    _data['userId'] = userId;
    _data['topicId'] = topicId;
    _data['wordStatus'] = wordStatus;

    return _data;
  }
}
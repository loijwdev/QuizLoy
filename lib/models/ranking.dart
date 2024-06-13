class Ranking {
  String? userId;
  String? topicId;
  int? timeTaken;
  int? correctAnswers;
  int? studyCount;

  Ranking({
    this.userId,
    this.topicId,
    this.timeTaken = null,
    this.correctAnswers = null,
    this.studyCount,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      userId: json['userId'],
      topicId: json['topicId'],
      timeTaken: json['timeTaken'],
      correctAnswers: json['correctAnswers'],
      studyCount: json['studyCount'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};

    _data['userId'] = userId;
    _data['topicId'] = topicId;
    _data['timeTaken'] = timeTaken;
    _data['correctAnswers'] = correctAnswers;
    _data['studyCount'] = studyCount;

    return _data;
  }
}

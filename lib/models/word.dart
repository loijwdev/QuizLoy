class Word {
  String? wordId;
  String? english;
  String? vietnamese;
  String? status;
  bool starred = false;
  String? topicId;

  Word(
      {this.wordId,
      this.english,
      this.vietnamese,
      this.status = "not learned",
      this.starred = false,
      this.topicId});

  Word.fromJson(Map<String, dynamic> json) {
    wordId = json["wordId"];
    english = json["english"];
    vietnamese = json["vietnamese"];
    status = json["status"];
    starred = json["starred"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["english"] = english;
    _data["vietnamese"] = vietnamese;
    _data["status"] = status;
    _data["starred"] = starred;
    return _data;
  }

  Map<String, dynamic> toSqliteMap() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["wordId"] = wordId;
    _data["topicId"] = topicId;
    _data["english"] = english;
    _data["vietnamese"] = vietnamese;
    _data["status"] = status;
    _data["starred"] = starred ? 1 : 0;
    return _data;
  }

  @override
  String toString() {
    return 'Word{english: $english, vietnamese: $vietnamese}';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quiz_loy/models/word.dart';

class VocabularyTopic {
  String? topicId;
  String? userId; // Creator's UID
  String? title;
  String? description;
  bool isPublic = false; // Whether the topic is public or private
  DateTime? createdAt; // Timestamp of topic creation
  List<Word>? words; // Collection of words in the topic
  int? participantCount;

  VocabularyTopic({
    this.topicId,
    this.userId,
    this.title,
    this.description,
    this.isPublic = false,
    this.createdAt,
    this.participantCount = 0,
  });

  VocabularyTopic.fromJson(Map<String, dynamic> json) {
    topicId = json["topicId"];
    userId = json["userId"];
    title = json["title"];
    description = json["description"];
    isPublic = json["isPublic"];
    final timestamp = json["createdAt"] as Timestamp?;
    createdAt = timestamp?.toDate(); // Convert Timestamp to DateTime
    participantCount = json["participantCount"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};

    _data["userId"] = userId;
    _data["title"] = title;
    _data["description"] = description;
    _data["isPublic"] = isPublic;
    _data["createdAt"] = createdAt != null
        ? Timestamp.fromDate(createdAt!)
        : null; // Convert DateTime to Timestamp
    _data["participantCount"] = participantCount;
    return _data;
  }

  Map<String, dynamic> toSqliteMap() {
    final Map<String, dynamic> _data = <String, dynamic>{};
    _data["topicId"] = topicId;
    _data["userId"] = userId;
    _data["title"] = title;
    _data["description"] = description;
    _data["isPublic"] = isPublic ? 1 : 0; // Convert bool to int
    _data["createdAt"] = createdAt != null
        ? createdAt!.toIso8601String() // Convert DateTime to String
        : null;
    _data["participantCount"] = participantCount;
    return _data;
  }

  // Method to create VocabularyTopic from a Map from SQLite
  VocabularyTopic.fromSqliteMap(Map<String, dynamic> map) {
    topicId = map["topicId"];
    userId = map["userId"];
    title = map["title"];
    description = map["description"];
    isPublic = map["isPublic"] == 0; // Convert int to bool
    createdAt = map["createdAt"] != null
        ? DateTime.parse(map["createdAt"]) // Convert String to DateTime
        : null;
    participantCount = map["participantCount"];
  }
}

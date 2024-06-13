import 'package:cloud_firestore/cloud_firestore.dart';

class Folder {
  String? userId;
  String? folderId;
  String? title;
  String? description;
  DateTime? createdAt;
  List<String>? topicIds;

  Folder({
    this.userId,
    this.folderId,
    this.title,
    this.description,
    this.createdAt,
    this.topicIds,
  });

  Folder.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    folderId = json['folderId'];
    title = json['title'];
    description = json['description'];
    topicIds = List<String>.from(json['topicIds'].map((x) => x as String));
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> _data = <String, dynamic>{};

    _data['userId'] = userId;
    _data['title'] = title;
    _data['description'] = description;
    _data["createdAt"] =
        createdAt != null ? Timestamp.fromDate(createdAt!) : null;
    _data['topicIds'] = topicIds;

    return _data;
  }
}

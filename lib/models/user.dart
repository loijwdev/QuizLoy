class User {
  String? id;
  String? email;
  String? username;
  String? photoUrl;
  bool? isLocked;

  User({
    this.id,
    this.email,
    this.username,
    this.photoUrl,
    this.isLocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'photoUrl': photoUrl,
      'isLocked': isLocked,
    };
  }

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    username = json['username'];
    photoUrl = json['photoUrl'];
    isLocked = json['isLocked'];
  }
}

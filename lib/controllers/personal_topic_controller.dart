import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class PersonalTopicController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  @override
  void onInit() {
    super.onInit();
  }

  Future<List<String>> getTopicIds(String userId) async {
    var personalTopics = await _firestore
        .collection("personalTopics")
        .where('userId', isEqualTo: userId)
        .get();

    List<String> topicIds = [];
    for (var topic in personalTopics.docs) {
      topicIds.addAll(List<String>.from(topic.data()['topicIds']));
    }
    return topicIds;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/models/user.dart' as u;
import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:quiz_loy/models/word.dart';

class HomePageController extends GetxController {
  var listTopic = RxList<VocabularyTopic>();
  final _firestore = FirebaseFirestore.instance;
  var listWords = RxList<Word>();
  User? user = FirebaseAuth.instance.currentUser;

  @override
  void onInit() {
    super.onInit();
  }

  Future<RxList<VocabularyTopic>> getListTopic(String userId) async {
    listTopic.clear();
    var topics = await _firestore
        .collection("vocabularyTopics")
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    for (var topic in topics.docs) {
      listTopic.add(VocabularyTopic.fromJson(topic.data()));
    }
    return listTopic;
  }

  Future<RxList<Word>> getListWords(String topicId) async {
    listWords.clear();
    var wordsCollection = await _firestore
        .collection('vocabularyTopics')
        .doc(topicId)
        .collection('words')
        .get();
    for (var word in wordsCollection.docs) {
      listWords.add(Word.fromJson(word.data()));
    }
    return listWords;
  }

  Future<int> getWordsLength(String topicId) async {
    listWords.clear();
    var wordsCollection = await _firestore
        .collection('vocabularyTopics')
        .doc(topicId)
        .collection('words')
        .get();
    return wordsCollection.docs.length;
  }

  Future<u.User> getUserById(String userId) async {
    var user = await _firestore.collection('users').doc(userId).get();
    return u.User.fromJson(user.data()!);
  }
}

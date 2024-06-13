import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class WordController extends GetxController {
  RxBool isStared = false.obs;
  final _firestore = FirebaseFirestore.instance;

  void starWord(String topicId, String wordId) async {
    DocumentReference wordRef = _firestore
        .collection('vocabularyTopics')
        .doc(topicId)
        .collection('words')
        .doc(wordId);

    DocumentSnapshot wordSnapshot = await wordRef.get();
    bool currentStarredStatus =
        ((wordSnapshot.data() as Map<String, dynamic>?) ?? {})['starred'] ??
            false;

    await wordRef.update({'starred': !currentStarredStatus});
    isStared.value = !currentStarredStatus;
  }

  void changeStatusWord(String topicId, String wordId, String status) async {
    DocumentReference wordRef = _firestore
        .collection('vocabularyTopics')
        .doc(topicId)
        .collection('words')
        .doc(wordId);
    await wordRef.update({'status': status});
  }

  Future<int> getKnownWordsCount(String topicId, List<String> wordIds) async {
    int knownWordsCount = 0;
    print("wordIds: $wordIds");
    for (String wordId in wordIds) {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('vocabularyTopics')
          .doc(topicId)
          .collection('words')
          .doc(wordId)
          .get();

      if (documentSnapshot.exists && documentSnapshot['status'] == 'known') {
        knownWordsCount++;
      }
    }
    return knownWordsCount;
  }
}

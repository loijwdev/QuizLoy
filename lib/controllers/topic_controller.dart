import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/personal_topic_controller.dart';
import 'package:quiz_loy/local_db/database_helper.dart';
import 'package:quiz_loy/models/topic_personal.dart';
import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:quiz_loy/pages/detail_topic.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/toast/toast.dart';
import 'package:quiz_loy/models/user.dart' as u;

class CreateTopicController extends GetxController {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  RxList<TextEditingController> english = <TextEditingController>[].obs;
  RxList<TextEditingController> vietnamese = <TextEditingController>[].obs;

  RxInt containerCount = RxInt(2);
  var listWords = RxList<Word>();
  String? topicId;
  var dropdownValue = 'Mọi người'.obs;
  var canView = true.obs;
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  var db = DatabaseHelper();

  @override
  void onInit() {
    super.onInit();
    for (int i = 0; i < containerCount.value; i++) {
      english.add(TextEditingController());
      vietnamese.add(TextEditingController());
    }
  }

  void changeDropdownValue(String newValue) {
    dropdownValue.value = newValue;
    canView.value = dropdownValue.value == 'Mọi người' ? true : false;
  }

  void addContainer() {
    containerCount.value++;
    english.add(TextEditingController());
    vietnamese.add(TextEditingController());
  }

  void removeContainer(int index) async {
    containerCount.value--;
    english.removeAt(index);
    vietnamese.removeAt(index);
  }

  void addTopicToDb() async {
    final User? user = auth.currentUser;
    List<Word> wordsList = [];

    if (title.text.isEmpty) {
      showToast(message: "Vui lòng nhập chủ đề");
    } else {
      for (int i = 0; i < english.length; i++) {
        Word word = Word(
          english: english[i].text,
          vietnamese: vietnamese[i].text,
        );
        if (english[i].text.isNotEmpty && vietnamese[i].text.isNotEmpty) {
          wordsList.add(word);
        }
      }

      // Print the wordsList
      print('Words List: $wordsList');
      print(wordsList.length);
      if (wordsList.length < 2) {
        showToast(
            message:
                "Bạn phải thêm vào ít nhất hai thuật ngữ mới lưu được học phần");
      } else {
        var vocabTopic = VocabularyTopic(
          userId: user!.uid,
          title: title.text,
          description: description.text,
          isPublic: canView.value,
          createdAt: DateTime.now(),
        );

        await addTopic(vocabTopic, wordsList);

        await db.insertTopic(vocabTopic, wordsList);

        listWords = await getWords(topicId!);

        var personalTopic = TopicPersonal(
          userId: user.uid,
          topicIds: [topicId!],
        );
        await addPersonalTopic(personalTopic);
        Get.to(
          DetailTopic(),
          arguments: [listWords, title.text, description.text, topicId],
        );
      }
    }
  }

  Future<void> addPersonalTopic(TopicPersonal topic) async {
    try {
      final docRef = _firestore.collection('personalTopics').doc(topic.userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // If the document exists, update the 'topicIds' field
        await docRef.update({
          'topicIds': FieldValue.arrayUnion(topic.topicIds!.toList()),
        });
      } else {
        // If the document does not exist, create it
        await docRef.set(topic.toJson());
      }
    } catch (e) {
      print('Error adding personal topic: $e');
    }
  }

  void addTopicFromCsv(List<String> pairs) async {
    final User? user = auth.currentUser;
    List<Word> wordsList = [];
    if (title.text.isEmpty) {
      showToast(message: "Vui lòng nhập chủ đề");
    } else {
      for (String pair in pairs) {
        if (pair.trim().isNotEmpty) {
          List<String> words = pair.split(',');
          if (words[0].trim().isNotEmpty && words[1].trim().isNotEmpty) {
            Word word = Word(
              english: words[0].trim(),
              vietnamese: words[1].trim(),
            );
            wordsList.add(word);
          }
        }
      }

      var vocabTopic = VocabularyTopic(
        userId: user!.uid,
        title: title.text,
        description: description.text,
        isPublic: canView.value,
        createdAt: DateTime.now(),
      );

      await addTopic(vocabTopic, wordsList);
      listWords = await getWords(topicId!);
      await db.insertTopic(vocabTopic, wordsList);
      var personalTopic = TopicPersonal(
        userId: user.uid,
        topicIds: [topicId!],
      );
      await addPersonalTopic(personalTopic);

      Get.to(
        DetailTopic(),
        arguments: [listWords, title.text, description.text, topicId],
      );
    }
  }

  void updateTopic(String topicId) async {
    listWords = await getWords(topicId);
    List<Word> wordsList = [];
    if (title.text.isEmpty) {
      showToast(message: "Vui lòng nhập chủ đề");
    } else if (description.text.isEmpty) {
      showToast(message: "Vui lòng nhập mô tả");
    } else {
      print('listWords: $listWords');
      for (int i = 0; i < english.length; i++) {
        Word word;
        if (i < listWords.length) {
          word = Word(
            english: english[i].text,
            vietnamese: vietnamese[i].text,
            wordId: listWords[i].wordId,
          );
        } else {
          word = Word(
            english: english[i].text,
            vietnamese: vietnamese[i].text,
          );
        }
        if (english[i].text.isNotEmpty && vietnamese[i].text.isNotEmpty) {
          wordsList.add(word);
        }
      }
      if (wordsList.length < 2) {
        showToast(
            message:
                "Bạn phải thêm vào ít nhất hai thuật ngữ mới lưu được học phần");
        Get.back();
      } else {
        await editTopic(topicId, wordsList, title.text, description.text);
        listWords = await getWords(topicId);
        Get.to(
          DetailTopic(),
          arguments: [listWords, title.text, description.text, topicId],
        );
      }
    }
  }

  void removeTopic(String topicId) async {
    await deleteTopic(topicId);
    Get.offAll(HomePage());
    showToast(message: "Đã xóa chủ đề thành công");
  }

  Future<void> addTopic(VocabularyTopic topic, List<Word> words) async {
    try {
      DocumentReference topicRef =
          await _firestore.collection('vocabularyTopics').add(topic.toJson());
      topicId = topicRef.id;
      topic.topicId = topicId;
      await topicRef.update({'topicId': topicRef.id});

      for (Word word in words) {
        DocumentReference wordRef =
            await topicRef.collection('words').add(word.toJson());
        word.wordId = wordRef.id;
        await wordRef.update({'wordId': wordRef.id});
      }
    } catch (e) {
      print('Error adding topic: $e');
    }
  }

  Future<void> deleteTopic(String topicId) async {
    try {
      // Get reference to the topic
      var topicRef = _firestore.collection('vocabularyTopics').doc(topicId);

      // Get all the words in the subcollection and delete them
      var wordsSnapshot = await topicRef.collection('words').get();
      for (var wordDoc in wordsSnapshot.docs) {
        await wordDoc.reference.delete();
      }

      // Delete the topic itself
      await topicRef.delete();

      var personalListsSnapshot =
          await _firestore.collection('personalTopics').get();
      for (var personalListDoc in personalListsSnapshot.docs) {
        var personalList = TopicPersonal.fromJson(personalListDoc.data());

        // If the personalList contains the topicId, remove it
        if (personalList.topicIds!.contains(topicId)) {
          personalList.topicIds!.remove(topicId);

          // Update the personalList in the database
          await personalListDoc.reference.update(personalList.toJson());
        }
      }
    } catch (e) {
      print('Error deleting topic: $e');
    }
  }

  Future<void> editTopic(String topicId, List<Word> words, String title,
      String description) async {
    try {
      for (var word in words) {
        if (word.wordId == null) {
          DocumentReference wordRef = await _firestore
              .collection('vocabularyTopics')
              .doc(topicId)
              .collection('words')
              .add(word.toJson());
          await wordRef.update({'wordId': wordRef.id});
        } else {
          await _firestore
              .collection('vocabularyTopics')
              .doc(topicId)
              .collection('words')
              .doc(word.wordId)
              .update(word.toJson());
        }
      }
      await _firestore
          .collection('vocabularyTopics')
          .doc(topicId)
          .update({'title': title, 'description': description});
    } catch (e) {
      print('Error updating topic: $e');
    }
  }

  Future<void> deleteWord(String topicId, String wordId) async {
    try {
      await _firestore
          .collection('vocabularyTopics')
          .doc(topicId)
          .collection('words')
          .doc(wordId)
          .delete();
    } catch (e) {
      print('Error deleting word: $e');
    }
  }

  Future<RxList<Word>> getWords(String topicId) async {
    var wordsList = RxList<Word>();
    var words =
        await _firestore.collection("vocabularyTopics/${topicId}/words").get();
    for (var word in words.docs) {
      wordsList.add(Word.fromJson(word.data()));
    }
    return wordsList;
  }

  Future<VocabularyTopic?> getTopicById(String topicId) async {
    try {
      var topicDoc =
          await _firestore.collection('vocabularyTopics').doc(topicId).get();
      if (topicDoc.exists) {
        return VocabularyTopic.fromJson(topicDoc.data()!);
      } else {
        print('No topic found with id: $topicId');
        return null;
      }
    } catch (e) {
      print('Error getting topic: $e');
      return null;
    }
  }

  Future<List<VocabularyTopic>> getTopicsByIds(List<String> ids) async {
    List<VocabularyTopic> topics = [];
    for (var id in ids) {
      var topic = await getTopicById(id);
      if (topic != null) {
        topics.add(topic);
      }
    }
    return topics;
  }

  Future<RxList<VocabularyTopic>> getAllTopic(
      String userId, List<String> topicIdsOld) async {
    try {
      PersonalTopicController personalTopicController =
          PersonalTopicController();
      List<String> topicIds = await personalTopicController.getTopicIds(userId);
      Set<String> mergedTopicIds = {...topicIds};
      mergedTopicIds.removeAll(topicIdsOld);
      print("MergedTopicIds: $mergedTopicIds");
      Query query = _firestore
          .collection('vocabularyTopics')
          .where(FieldPath.documentId, whereIn: mergedTopicIds);

      // if (topicIds.isNotEmpty) {
      //   query = query.where(FieldPath.documentId, whereNotIn: topicIdsOld);
      // }

      var topicDoc = await query.get();
      print(topicDoc.docs);
      if (topicDoc.docs.isNotEmpty) {
        return RxList<VocabularyTopic>(topicDoc.docs
            .map((doc) =>
                VocabularyTopic.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
      } else {
        print('No topics found for user id: $userId');
        return RxList<VocabularyTopic>();
      }
    } catch (e) {
      print('Error getting topics: $e');
      return RxList<VocabularyTopic>();
    }
  }

  Future<RxList<VocabularyTopic>> getAllPublicTopicsSorted() async {
    try {
      PersonalTopicController personalTopicController =
          PersonalTopicController();
      List<String> topicIds =
          await personalTopicController.getTopicIds(auth.currentUser!.uid);
      print("topicIdsỏted: $topicIds");
      Query query = _firestore
          .collection('vocabularyTopics')
          .where('isPublic', isEqualTo: true)
          .orderBy('createdAt', descending: true);

      var topicDoc = await query.get();
      if (topicDoc.docs.isNotEmpty) {
        var topics = topicDoc.docs
            .map((doc) =>
                VocabularyTopic.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
        // Filter out topics with IDs in topicIds
        topics.removeWhere((topic) => topicIds.contains(topic.topicId));
        return RxList<VocabularyTopic>(topics);
      } else {
        print('No public topics found');
        return RxList<VocabularyTopic>();
      }
    } catch (e) {
      print('Error getting public topics: $e');
      return RxList<VocabularyTopic>();
    }
  }

  Future<u.User> getUserByTopicId(String topicId) async {
    try {
      var userId;
      var topicDoc =
          await _firestore.collection('vocabularyTopics').doc(topicId).get();
      if (topicDoc.exists) {
        userId = topicDoc.data()!['userId'];
        var userDoc = await _firestore.collection('users').doc(userId).get();
        return u.User.fromJson(userDoc.data()!);
      } else {
        throw Exception('No topic found with id: $topicId');
      }
    } catch (e) {
      throw Exception('Error getting user by topic id: $e');
    }
  }

  void updateTopicViewCount(String topicId) async {
    try {
      var topicDoc =
          await _firestore.collection('vocabularyTopics').doc(topicId).get();
      if (topicDoc.exists) {
        var viewCount = topicDoc.data()!['participantCount'] + 1;
        await topicDoc.reference.update({'participantCount': viewCount});
      } else {
        throw Exception('No topic found with id: $topicId');
      }
    } catch (e) {
      throw Exception('Error updating topic view count: $e');
    }
  }
}

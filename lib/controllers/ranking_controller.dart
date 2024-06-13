import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/personal_topic_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/vocab_topic.dart';

class RankingController extends GetxController {
  final _firestore = FirebaseFirestore.instance;
  PersonalTopicController personalTopicController =
      Get.put(PersonalTopicController());
  HomePageController homePageController = Get.put(HomePageController());
  CreateTopicController createTopicController =
      Get.put(CreateTopicController());
  @override
  void onInit() {
    super.onInit();
  }

  void addOrUpdateRanking(
      String userId, String topicId, int correctAnswer, int timeTaken) async {
    DocumentReference docRef =
        _firestore.collection('ranking').doc("$userId-$topicId");
    DocumentSnapshot doc = await docRef.get();

    if (doc.exists) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      int currentCorrectAnswers = data['correctAnswers'] ?? 0;
      // If the document exists, update the fields
      if (currentCorrectAnswers < correctAnswer) {
        await docRef.update({
          'correctAnswers': correctAnswer,
          'timeTaken': timeTaken == 0 ? null : timeTaken,
        });
      }
      if (currentCorrectAnswers == correctAnswer &&
          (data['timeTaken'] ?? 0) > timeTaken) {
        await docRef.update({
          'timeTaken': timeTaken == 0 ? null : timeTaken,
        });
      }
      await docRef.update({
        'studyCount': FieldValue.increment(1),
      });
    } else {
      // If the document does not exist, create a new one
      await docRef.set({
        'userId': userId,
        'topicId': topicId,
        'correctAnswers': correctAnswer == 0 ? null : correctAnswer,
        'timeTaken': timeTaken == 0 ? null : timeTaken,
        'studyCount': 1,
      });
    }
  }

  Future<List<Map<String, dynamic>>> getTopUsersMostStudy(
      String topicId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('ranking')
        .where('topicId', isEqualTo: topicId)
        .where('studyCount', isGreaterThanOrEqualTo: 3)
        .orderBy('studyCount', descending: true)
        .limit(3)
        .get();

    List<Map<String, dynamic>> users = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String userId = data['userId'] as String;
      int studyCount = data['studyCount'] as int;
      var userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        User user = User.fromJson(userDoc.data() as Map<String, dynamic>);
        VocabularyTopic? topic =
            await createTopicController.getTopicById(topicId);
        users.add({
          'user': user,
          'studyCount': studyCount,
          'topic': topic?.title,
        });
      }
    }
    return users;
  }

  Future<List<Map<String, dynamic>>> getTopUsersBestStudy(
      String topicId, int lengthList) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('ranking')
        .where('topicId', isEqualTo: topicId)
        .where('correctAnswers', isGreaterThanOrEqualTo: lengthList)
        .orderBy('correctAnswers', descending: true)
        .orderBy('timeTaken', descending: false)
        .limit(3)
        .get();
    List<Map<String, dynamic>> users = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String userId = data['userId'] as String;
      int timeTaken = data['timeTaken'] as int;
      var userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        User user = User.fromJson(userDoc.data() as Map<String, dynamic>);
        VocabularyTopic? topic =
            await createTopicController.getTopicById(topicId);
        users.add({
          'user': user,
          'timeTaken': timeTaken,
          'topic': topic?.title,
        });
      }
    }
    return users;
  }

  Future<List<Map<String, dynamic>>> getUserInTopBestStudy(
      String userId) async {
    print('Checking user with ID tham so: $userId');
    List<String> topicIds = await personalTopicController.getTopicIds(userId);
    print(topicIds);
    List<Map<String, dynamic>> result = [];
    for (String topicId in topicIds) {
      int lengthList = await homePageController.getWordsLength(topicId);
      List<Map<String, dynamic>> topUsers =
          await getTopUsersBestStudy(topicId, lengthList);
      int index = topUsers.indexWhere((user) => user['user'].id == userId);
      if (index != -1) {
        // Thêm 1 vào index vì index bắt đầu từ 0
        print('User is at position: ${index + 1}');
        result.add({
          ...topUsers[index],
          'position': index + 1,
        });
      }
    }
    return result;
  }

  Future<List<Map<String, dynamic>>> getUserInTopMostStudy(
      String userId) async {
    List<String> topicIds = await personalTopicController.getTopicIds(userId);
    List<Map<String, dynamic>> result = [];
    for (String topicId in topicIds) {
      List<Map<String, dynamic>> topUsers = await getTopUsersMostStudy(topicId);
      int index = topUsers.indexWhere((user) => user['user'].id == userId);
      if (index != -1) {
        // Thêm 1 vào index vì index bắt đầu từ 0
        result.add({
          ...topUsers[index],
          'position': index + 1,
        });
      }
    }
    return result;
  }
}

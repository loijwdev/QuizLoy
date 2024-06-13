import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class LearningProgressController extends GetxController {
  final _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
  }

  void addLearningProgressToDb(
      String userId, String topicId, Map<String, dynamic> wordStatus) async {
    try {
      String docId = '$userId-$topicId';
      DocumentReference docRef =
          _firestore.collection('learning_progress').doc(docId);

      // Lấy tài liệu hiện có từ Firestore
      DocumentSnapshot doc = await docRef.get();

      if (doc.exists) {
        // Nếu tài liệu tồn tại, lấy dữ liệu hiện tại của wordStatus từ Firestore
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        Map<String, dynamic> existingWordStatus =
            Map<String, dynamic>.from(data?['wordStatus'] ?? {});

        // Cập nhật hoặc thêm mới các trạng thái từ vào existingWordStatus
        existingWordStatus.addAll(wordStatus);

        // Cập nhật lại wordStatus trong Firestore
        await docRef.update({
          'wordStatus': existingWordStatus,
        });
      } else {
        // Nếu tài liệu không tồn tại, tạo mới tài liệu và thêm wordStatus vào
        await docRef.set({
          'userId': userId,
          'topicId': topicId,
          'wordStatus': wordStatus,
        });
      }
    } catch (e) {
      // Xử lý các lỗi nếu có
      print('Error updating learning progress: $e');
    }
  }

  Future<int> getKnownWordsCount(String userId, String topicId) async {
    try {
      String docId = '$userId-$topicId';
      DocumentReference docRef =
          _firestore.collection('learning_progress').doc(docId);

      // Lấy tài liệu hiện có từ Firestore
      DocumentSnapshot doc = await docRef.get();

      if (doc.exists) {
        // Nếu tài liệu tồn tại, lấy dữ liệu hiện tại của wordStatus từ Firestore
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        Map<String, dynamic> wordStatus =
            Map<String, dynamic>.from(data?['wordStatus'] ?? {});

        // Đếm số lượng từ "known"
        int knownWordsCount = 0;
        wordStatus.forEach((word, status) {
          if (status == 'known') {
            knownWordsCount++;
          }
        });
        return knownWordsCount;
      } else {
        // Nếu tài liệu không tồn tại, trả về 0
        return 0;
      }
    } catch (e) {
      // Xử lý các lỗi nếu có
      print('Error getting known words count: $e');
      return 0;
    }
  }
}

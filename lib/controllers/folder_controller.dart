import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/models/folder.dart';
import 'package:quiz_loy/models/user.dart' as u;
import 'package:quiz_loy/pages/detail_folder.dart';
import 'package:quiz_loy/pages/detail_topic.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/toast/toast.dart';

class FolderController extends GetxController {
  TextEditingController title = TextEditingController();
  TextEditingController description = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  RxList<Folder> listFolders = RxList<Folder>();
  RxInt lengthOfTopics = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  void addFolderToDb() async {
    final User? user = auth.currentUser;
    if (title.text.isEmpty) {
      Get.back();
    } else {
      DocumentReference folderRef = await _firestore.collection('folders').add({
        'userId': user!.uid,
        'title': title.text,
        'description': description.text,
        'createdAt': Timestamp.now(),
        'topicIds': [],
      });
      await folderRef.update({'folderId': folderRef.id});
      Get.to(DetailFolder(),
          arguments: [folderRef.id, title.text, description.text]);
    }
  }

  void deleteFolder(String folderId) async {
    await _firestore.collection('folders').doc(folderId).delete();
    Get.offAll(HomePage());
    showToast(message: "Đã xóa thư mục");
  }

  void updateFolder(String folderId) async {
    await _firestore.collection('folders').doc(folderId).update({
      'title': title.text,
      'description': description.text,
    });
    Get.off(DetailFolder(),
        arguments: [folderId, title.text, description.text]);
  }

  void addTopicIdToFolders(List<String> folderIds, String topicId) async {
    for (String folderId in folderIds) {
      DocumentReference folderRef =
          _firestore.collection('folders').doc(folderId);
      await folderRef.update({
        'topicIds': FieldValue.arrayUnion([topicId]),
      });
    }
    Get.back();
  }

  void addTopicIdsToFolders(List<String> topicIds, String folderId) async {
    for (String topicId in topicIds) {
      DocumentReference folderRef =
          _firestore.collection('folders').doc(folderId);
      await folderRef.update({
        'topicIds': FieldValue.arrayUnion([topicId]),
      });
    }
    // Get.off(DetailFolder(), arguments: [folderId, title.text, description.text]);
  }

  void removeTopicIdFromFolder(String folderId, String topicId) async {
    DocumentReference folderRef =
        _firestore.collection('folders').doc(folderId);
    await folderRef.update({
      'topicIds': FieldValue.arrayRemove([topicId]),
    });
    showToast(message: "Đã xóa học phần khỏi thư mục");
  }

  Future<List<String>> getTopicIdsFromFolder(String folderId) async {
    var folder = await _firestore.collection('folders').doc(folderId).get();
    if (folder.data() != null && folder.data()!['topicIds'] != null) {
      return List<String>.from(folder.data()!['topicIds']);
    } else {
      // Handle the case where the document or the 'topicIds' field does not exist
      print('Document or topicIds field does not exist');
      return [];
    }
  }

  Future<RxList<Folder>> getListFolders(String userId) async {
    listFolders.clear(); // Clear the existing list before populating

    var folders = await _firestore
        .collection("folders")
        .where('userId', isEqualTo: userId)
        .get();

    // Populate the listFolders with Folder objects
    listFolders
        .addAll(folders.docs.map((folder) => Folder.fromJson(folder.data())));

    return listFolders;
  }

  Future<int> getLengthOfTopics(String folderId) async {
    print('folderId: $folderId');
    var folder = await _firestore.collection('folders').doc(folderId).get();
    if (folder.data() != null && folder.data()!['topicIds'] != null) {
      lengthOfTopics.value = folder.data()!['topicIds'].length;
      return lengthOfTopics.value;
    } else {
      // Handle the case where the document or the 'topicIds' field does not exist
      print('Document or topicIds field does not exist');
      return 0;
    }
  }
}

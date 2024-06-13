import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/folder_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/pages/create_folder.dart';

class AddTopicToFolder extends StatefulWidget {
  const AddTopicToFolder({super.key});

  @override
  State<AddTopicToFolder> createState() => _AddTopicToFolderState();
}

class _AddTopicToFolderState extends State<AddTopicToFolder> {
  late FolderController folderController;
  late List<bool> selectedTiles;
  late Future listFoldersFuture;
  String? topicId;

  @override
  void initState() {
    folderController = Get.put(FolderController());
    selectedTiles =
        List<bool>.filled(folderController.listFolders.length, false);
    listFoldersFuture =
        folderController.getListFolders(folderController.auth.currentUser!.uid);
    super.initState();
    var data = Get.arguments;
    topicId = data[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Thêm vào thư mục'),
          centerTitle: true,
          actions: [
            TextButton(
                onPressed: () {
                  List<String> selectedFolderIds = [];
                  for (int i = 0; i < selectedTiles.length; i++) {
                    if (selectedTiles[i]) {
                      selectedFolderIds.add(
                          folderController.listFolders[i].folderId.toString());
                    }
                  }
                  folderController.addTopicIdToFolders(
                      selectedFolderIds, topicId!);
                },
                child: Text("Xong",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black)))
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Container(
                    margin: const EdgeInsets.all(5),
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextButton(
                      child: const Text('Tạo thư mục mới'),
                      onPressed: () {
                        Get.to(CreateFolder());
                      },
                    ))),
            FutureBuilder(
                future: listFoldersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error'),
                    );
                  } else {
                    return Obx(() {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: folderController.listFolders.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: InkWell(
                                  onTap: () {
                                    print(selectedTiles[index]);
                                    setState(() {
                                      selectedTiles[index] =
                                          !selectedTiles[index];
                                    });
                                  },
                                  child: Container(
                                    decoration: selectedTiles[index]
                                        ? BoxDecoration(
                                            border: Border.all(
                                              color: Colors
                                                  .blue, // Set border color
                                              width: 2.0, // Set border width
                                            ),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    10.0)), // Set rounded corner radius
                                          )
                                        : null,
                                    child: ListTile(
                                      leading: const Icon(Icons.folder),
                                      title: Text(folderController
                                          .listFolders[index].title
                                          .toString()),
                                    ),
                                  ),
                                ),
                              );
                            }),
                      );
                    });
                  }
                }),
          ],
        ));
  }
}

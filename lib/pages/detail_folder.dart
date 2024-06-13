import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/folder_controller.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/models/folder.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:quiz_loy/pages/create_folder.dart';
import 'package:quiz_loy/pages/detail_topic.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/list_topic.dart';

class DetailFolder extends StatefulWidget {
  const DetailFolder({super.key});

  @override
  State<DetailFolder> createState() => _DetailFolderState();
}

class _DetailFolderState extends State<DetailFolder> {
  String? folderId;
  String? title;
  String? description;
  int? length;
  late FolderController folderController;
  late HomePageController homePageController;
  late Future<List<String>> listTopicIdsFuture;
  late CreateTopicController createTopicController;
  List<String> topicIds = [];
  @override
  void initState() {
    super.initState();
    folderController = Get.put(FolderController());
    homePageController = Get.put(HomePageController());
    createTopicController = Get.put(CreateTopicController());
    var data = Get.arguments;
    print(data);
    folderId = data[0];
    title = data[1];
    description = data[2];
    if (data.length > 3 && data[3] != null) {
      listTopicIdsFuture = Future.value(data[3]);
    } else {
      listTopicIdsFuture = folderController.getTopicIdsFromFolder(folderId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(HomePage());
          },
        ),
        actions: [
          PopupMenuButton(
              onSelected: (value) async {
                if (value == '1') {
                  Get.to(CreateFolder(),
                      arguments: [folderId, title, description]);
                } else if (value == '2') {
                  List<String> listTopicIds =
                      await folderController.getTopicIdsFromFolder(folderId!);
                  Get.to(ListTopic(),
                      arguments: [folderId, title, description, listTopicIds]);
                } else {
                  folderController.deleteFolder(folderId!);
                }
              },
              itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: '1',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Sửa thư mục")
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.folder),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Thêm học phần"),
                        ],
                      ),
                      value: '2',
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.delete),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Xóa thư mục"),
                        ],
                      ),
                      value: '3',
                    ),
                  ])
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title!,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            Row(
              children: [
                FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    folderController.getLengthOfTopics(folderId.toString()),
                    homePageController
                        .getUserById(folderController.auth.currentUser!.uid),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      if (snapshot.hasError) {
                        print(snapshot.error);
                        return Text('Error');
                      } else {
                        User user = snapshot.data![1];
                        return Row(
                          children: [
                            Text(
                              "${folderController.lengthOfTopics.value} học phần",
                              style: TextStyle(fontSize: 16),
                            ),
                            Container(
                              height: 30,
                              child: VerticalDivider(),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              user.username.toString(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                  future: Future.wait([
                    listTopicIdsFuture,
                    homePageController
                        .getUserById(folderController.auth.currentUser!.uid),
                  ]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      print(snapshot.error);
                      return const Center(child: Text('Error'));
                    } else {
                      List<String> topicIds = snapshot.data![0];
                      User user = snapshot.data![1];
                      if (topicIds.isEmpty) {
                        return Center(
                          child: ButtonTheme(
                            minWidth: 200.0, // change this value as needed
                            child: ElevatedButton(
                              onPressed: () {
                                Get.to(ListTopic(), arguments: [
                                  folderId,
                                  title,
                                  description,
                                  topicIds
                                ]);
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Colors.blue, // background color
                                onPrimary: Colors.white, // text color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      10), // rounded corners
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12), // padding
                              ),
                              child: Text(
                                'Thêm học phần',
                                style: TextStyle(
                                    fontSize: 16), // text size and style
                              ),
                            ),
                          ),
                        );
                      } else {
                        return ListView.builder(
                            itemCount: topicIds.length,
                            itemBuilder: (context, index) {
                              return FutureBuilder<VocabularyTopic?>(
                                  future: createTopicController
                                      .getTopicById(topicIds[index]),
                                  builder: (context, topicSnapshot) {
                                    if (topicSnapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    } else if (topicSnapshot.hasError) {
                                      return const Center(child: Text('Error'));
                                    } else {
                                      VocabularyTopic? topic =
                                          topicSnapshot.data;
                                      return Dismissible(
                                        key: UniqueKey(),
                                        direction: DismissDirection.endToStart,
                                        onDismissed: (direction) {
                                          folderController
                                              .removeTopicIdFromFolder(
                                                  folderId.toString(),
                                                  topic.topicId.toString());
                                          folderController
                                              .lengthOfTopics.value--;
                                        },
                                        background: Container(
                                          alignment: Alignment.centerRight,
                                          padding: EdgeInsets.only(right: 20.0),
                                          color: Colors.red,
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ),
                                        child: InkWell(
                                          onTap: () async {
                                            await homePageController
                                                .getListWords(
                                                    topic.topicId!.toString());
                                            Get.to(DetailTopic(), arguments: [
                                              homePageController.listWords,
                                              topic.title,
                                              topic.description,
                                              topic.topicId
                                            ]);
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            child: Card(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      topic!.title.toString(),
                                                      style: TextStyle(
                                                          fontSize: 18),
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    FutureBuilder<int>(
                                                      future: homePageController
                                                          .getWordsLength(topic
                                                              .topicId
                                                              .toString()),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator());
                                                        } else if (snapshot
                                                            .hasError) {
                                                          return Text('Error');
                                                        } else {
                                                          return Text(
                                                            "${snapshot.data} thuật ngữ",
                                                            style: TextStyle(
                                                                fontSize: 18),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                    const SizedBox(
                                                      height: 7,
                                                    ),
                                                    Text(
                                                      user.username.toString(),
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  });
                            });
                      }
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

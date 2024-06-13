import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/folder_controller.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/personal_topic_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/models/folder.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:quiz_loy/pages/create_folder.dart';
import 'package:quiz_loy/pages/create_topic.dart';
import 'package:quiz_loy/pages/detail_folder.dart';

class ListTopic extends StatefulWidget {
  const ListTopic({super.key});

  @override
  State<ListTopic> createState() => _ListTopicState();
}

class _ListTopicState extends State<ListTopic> {
  late CreateTopicController createTopicController;
  late FolderController folderController;
  late HomePageController homePageController;
  String? folderId;
  String? title;
  String? description;
  late List<bool> selectedTopic;
  late Future<List<dynamic>> futureData;
  late List<String> selectedTopicIds;
  late List<String> unselectedTopicIds;

  @override
  void initState() {
    super.initState();
    selectedTopicIds = [];
    unselectedTopicIds = [];
    folderController = Get.put(FolderController());
    createTopicController = Get.put(CreateTopicController());
    homePageController = Get.put(HomePageController());
    PersonalTopicController personalTopicController =
        Get.put(PersonalTopicController());
    var data = Get.arguments;
    print(data);
    folderId = data[0];
    title = data[1];
    description = data[2];
    print("data[3]: ${data[3]}");
    futureData = Future.wait([
      createTopicController
          .getAllTopic(createTopicController.auth.currentUser!.uid!, data[3])
          .then((listTopic) {
        selectedTopic = List<bool>.filled(listTopic.length, false);
        return Future.wait(listTopic.map((topic) async {
          var wordsLength =
              await homePageController.getWordsLength(topic.topicId.toString());
          var user = await homePageController.getUserById(topic.userId!);
          return {'topic': topic, 'wordsLength': wordsLength, 'user': user};
        })).then((list) => {
              'listTopic': list.map((item) => item['topic']).toList(),
              'wordsLengths': list.map((item) => item['wordsLength']).toList(),
              'users': list.map((item) => item['user']).toList(),
            });
      }),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm học phần'),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () {
                print("selectedTopicIdsXXXXXXXX: $selectedTopicIds");
                if (selectedTopicIds.isEmpty) {
                  Get.back();
                  print("1");
                } else {
                  print("2");
                  folderController.addTopicIdsToFolders(
                      selectedTopicIds, folderId!);
                  print("unselectedTopicIds: $unselectedTopicIds");
                  selectedTopicIds.addAll(unselectedTopicIds);

                  Get.off(DetailFolder(), arguments: [
                    folderId,
                    title,
                    description,
                    selectedTopicIds
                  ]);
                }
              },
              child: const Text("Xong",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black)))
        ],
      ),
      body: Column(
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
                    child: const Text('Tạo học phần mới'),
                    onPressed: () {
                      Get.to(CreateTopic());
                    },
                  ))),
          FutureBuilder<List<dynamic>>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                print(snapshot.error);
                return const Center(
                  child: Text('Error'),
                );
              } else {
                var listTopicData = snapshot.data![0];
                print(listTopicData);
                RxList listTopic =
                    RxList<dynamic>.from(listTopicData['listTopic']);
                List<int> wordsLengths = List<int>.from(
                    listTopicData['wordsLengths'].map((item) => item as int));
                List<User> users = List<User>.from(
                    listTopicData['users'].map((item) => item as User));

                return Expanded(
                  child: ListView.builder(
                      itemCount: listTopic.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 15),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                print(selectedTopic[index]);
                                selectedTopic[index] = !selectedTopic[index];
                                if (selectedTopic[index]) {
                                  selectedTopicIds
                                      .add(listTopic[index].topicId.toString());
                                } else {
                                  selectedTopicIds.remove(
                                      listTopic[index].topicId.toString());
                                }
                                print("selectedTopicIds: $selectedTopicIds");
                              });
                            },
                            child: Container(
                              decoration: selectedTopic[index]
                                  ? BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue, // Set border color
                                        width: 2.0, // Set border width
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              10.0)), // Set rounded corner radius
                                    )
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(listTopic[index].title.toString(),
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${wordsLengths[index]} thuật ngữ",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(users[index].username.toString(),
                                        style: const TextStyle(
                                          fontSize: 15,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

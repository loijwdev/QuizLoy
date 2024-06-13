import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/network_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:intl/intl.dart';
import 'package:quiz_loy/pages/detail_topic.dart';
import 'package:quiz_loy/pages/widget/bottom_navigation_bar.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  CreateTopicController topicController = Get.put(CreateTopicController());
  HomePageController homePageController = Get.put(HomePageController());
  NetworkController networkController = Get.put(NetworkController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cộng đồng'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: Future.wait([
          topicController.getAllPublicTopicsSorted(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            RxList<VocabularyTopic> topics = snapshot.data![0];
            return FutureBuilder(
              future: Future.wait(topics.map((topic) => Future.wait([
                    homePageController.getWordsLength(topic.topicId!),
                    homePageController.getUserById(topic.userId.toString()),
                  ]))),
              builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  return topics.length == 0
                      ? Center(
                          child: Text('Chưa có chủ đề nào'),
                        )
                      : Obx(() {
                          if (!networkController.isConnected.value) {
                            return Center(
                              child: Text(
                                'Không có kết nối mạng',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          } else {
                            return ListView.builder(
                              itemCount: topics.length,
                              itemBuilder: (context, index) {
                                final topic = topics[index];
                                final time = DateFormat('dd/MM/yyyy')
                                    .format(topic.createdAt!);
                                final wordsLength =
                                    snapshot.data![index][0] as int;
                                final user = snapshot.data![index][1] as User;
                                return Card(
                                  child: InkWell(
                                    onTap: () async {
                                      await homePageController.getListWords(
                                          topic.topicId.toString());
                                      Get.to(DetailTopic(), arguments: [
                                        homePageController.listWords,
                                        topic.title,
                                        topic.description,
                                        topic.topicId,
                                        "Community",
                                        homePageController.user!.uid,
                                      ]);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(18.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Text(topic.title.toString()),
                                          const SizedBox(height: 10),
                                          Text(
                                            "$wordsLength thuật ngữ",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                          const SizedBox(height: 6),
                                          topic.description!.isEmpty
                                              ? SizedBox.shrink()
                                              : Text(
                                                  topic.description.toString()),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                user.username.toString(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text('Ngày tạo: $time'),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                              'Số người tham gia: ${topic.participantCount}')
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        });
                }
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}

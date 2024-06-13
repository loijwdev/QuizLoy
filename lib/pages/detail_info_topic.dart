import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/ranking_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/models/ranking.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:intl/intl.dart';
import 'package:quiz_loy/models/word.dart';

class DetailInfoTopic extends StatefulWidget {
  const DetailInfoTopic({super.key});

  @override
  State<DetailInfoTopic> createState() => _DetailInfoTopicState();
}

class _DetailInfoTopicState extends State<DetailInfoTopic> {
  CreateTopicController topicController = Get.put(CreateTopicController());
  String? topicId;
  RankingController rankingController = Get.put(RankingController());
  RxList<Word> listWords = RxList<Word>.empty();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var data = Get.arguments;
    topicId = data[0];
    listWords = data[1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin học phần'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: FutureBuilder(
                future: Future.wait([
                  topicController.getTopicById(topicId!),
                  topicController.getUserByTopicId(topicId!),
                  rankingController.getTopUsersMostStudy(topicId!),
                  rankingController.getTopUsersBestStudy(
                      topicId!, listWords.length)
                ]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error'));
                  } else {
                    VocabularyTopic topic =
                        snapshot.data![0] as VocabularyTopic;
                    User user = snapshot.data![1] as User;
                    List<Map<String, dynamic>> userMostStudy =
                        snapshot.data![2] as List<Map<String, dynamic>>;
                    List<Map<String, dynamic>> userBestStudy =
                        snapshot.data![3] as List<Map<String, dynamic>>;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tạo bởi",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: ListTile(
                            title: Text(user.username!),
                            subtitle: Text(
                                "Ngày tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(topic.createdAt!)}"),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Ai có thể xem",
                          style: TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        topic.isPublic!
                            ? Card(
                                child: ListTile(
                                  title: Text("Mọi người"),
                                ),
                              )
                            : Card(
                                child: ListTile(
                                  title: Text("Chỉ mình tôi"),
                                ),
                              ),
                        const SizedBox(height: 20),
                        topic.isPublic!
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Số lượng người tham gia: ${topic.participantCount}",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                      "Người dùng nghiên cứu chủ đề nhiều lần nhất",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  Column(
                                    children: userMostStudy
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      Map<String, dynamic> value = entry.value;
                                      User e = value['user'] as User;
                                      int studyCount =
                                          value['studyCount'] as int;
                                      return Card(
                                        child: ListTile(
                                          leading: Text(
                                            (index + 1).toString(),
                                            style: TextStyle(fontSize: 17),
                                          ),
                                          title: Text(e.username!),
                                          trailing: Text(
                                            "$studyCount lần",
                                            style: TextStyle(fontSize: 17),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 20),
                                  Text("Người dùng hoàn thành chủ đề tốt nhất",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color:
                                              Color.fromARGB(255, 207, 159, 26),
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 10),
                                  Column(
                                    children: userBestStudy
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      Map<String, dynamic> value = entry.value;
                                      User e = value['user'] as User;
                                      int timeTaken = value['timeTaken'] as int;
                                      return Card(
                                        child: ListTile(
                                          leading: Text((index + 1).toString(),
                                              style: TextStyle(fontSize: 17)),
                                          title: Text(e.username!),
                                          trailing: Text("$timeTaken giây",
                                              style: TextStyle(fontSize: 17)),
                                        ),
                                      );
                                    }).toList(),
                                  )
                                ],
                              )
                            : Container(),
                      ],
                    );
                  }
                })),
      ),
    );
  }
}

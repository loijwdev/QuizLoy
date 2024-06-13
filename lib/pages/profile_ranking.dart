import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/personal_topic_controller.dart';
import 'package:quiz_loy/controllers/ranking_controller.dart';

class ProfileRanking extends StatefulWidget {
  const ProfileRanking({super.key});

  @override
  State<ProfileRanking> createState() => _ProfileRankingState();
}

class _ProfileRankingState extends State<ProfileRanking> {
  RankingController rankingController = Get.put(RankingController());
  PersonalTopicController personalTopicController =
      Get.put(PersonalTopicController());
  HomePageController homePageController = Get.put(HomePageController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thành tích cá nhân"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(15.0),
          child: FutureBuilder(
              future: Future.wait([
                rankingController
                    .getUserInTopBestStudy(homePageController.user!.uid),
                rankingController
                    .getUserInTopMostStudy(homePageController.user!.uid)
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print(snapshot.error);
                  return Center(child: Text('Error'));
                } else {
                  print("snapshot.data: ${snapshot.data}");
                  List<Map<String, dynamic>?> userBestStudy =
                      snapshot.data![0] as List<Map<String, dynamic>?>;
                  List<Map<String, dynamic>?> userMostStudy =
                      snapshot.data![1] as List<Map<String, dynamic>?>;
                  print("userBestStudy: $userBestStudy");
                  print("userMostStudy: $userMostStudy");

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Nghiên cứu học phần tốt nhất",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color.fromARGB(255, 207, 159, 26)),
                      ),
                      SizedBox(height: 10),
                      userBestStudy.isEmpty
                          ? Center(
                              child: Text(
                                  "Bạn chưa nằm trong top ở học phần nào cả",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  )))
                          : Column(
                              children: userBestStudy.map((user) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      child: ListTile(
                                        title: Text(user!['topic'] ?? "",
                                            style: TextStyle(
                                                fontSize: 19,
                                                color: Color.fromARGB(
                                                    255, 11, 65, 241),
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            "Thời gian: ${user['timeTaken'].toString()} s"),
                                        trailing: Text(
                                            "Top ${user['position']}",
                                            style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 207, 159, 26),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                      SizedBox(height: 30),
                      Text("Nghiên cứu học phần nhiều nhất",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red)),
                      SizedBox(height: 10),
                      userMostStudy.isEmpty
                          ? Center(
                              child: Text(
                                  "Bạn chưa nằm trong top ở học phần nào cả",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  )))
                          : Column(
                              children: userMostStudy.map((e) {
                                return Column(
                                  children: [
                                    Card(
                                      child: ListTile(
                                        title: Text(e!['topic'] ?? "",
                                            style: TextStyle(
                                                fontSize: 19,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold)),
                                        subtitle: Text(
                                            "Số lần: ${e['studyCount'].toString()}"),
                                        trailing: Text("Top ${e['position']}",
                                            style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                      ),
                                    )
                                  ],
                                );
                              }).toList(),
                            )
                    ],
                  );
                }
              }),
        ),
      ),
    );
  }
}

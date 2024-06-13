import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/ranking_controller.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:quiz_loy/pages/detail_topic.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/quiz_screen/quiz.dart';

class ResultQuizPage extends StatefulWidget {
  const ResultQuizPage({super.key});

  @override
  State<ResultQuizPage> createState() => _ResultQuizPageState();
}

class _ResultQuizPageState extends State<ResultQuizPage> {
  RankingController rankingController = Get.put(RankingController());
  HomePageController homePageController = Get.put(HomePageController());
  FlutterTts flutterTts = FlutterTts();
  List<Word> correctAnswer = [];
  List<Word> wrongAnswer = [];
  RxList<Word> listWords = RxList();
  String? topic;
  String? desc;
  String? topicId;
  int? time;
  var data;
  @override
  void initState() {
    super.initState();
    data = Get.arguments;
    correctAnswer = data[0];
    wrongAnswer = data[1];
    listWords = data[2];
    topic = data[3];
    desc = data[4];
    topicId = data[5];
    time = data[6];
    if (time != -1) {
      rankingController.addOrUpdateRanking(
          homePageController.user!.uid, topicId!, correctAnswer.length, time!);
    }

    print("data: $data");
    print("lenth0: ${correctAnswer.length}");
    print("length1: ${wrongAnswer.length}");
  }

  @override
  Widget build(BuildContext context) {
    void speak(String text) async {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1);
      await flutterTts.speak(text);
    }

    double appBarHeight = AppBar().preferredSize.height;
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: new AppBar(
            title: new Text(
              "Kết quả",
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Get.offAll(HomePage());
              },
            )),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text("Bạn đã hoàn thành chủ đề $topic",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                LinearPercentIndicator(
                  width: MediaQuery.of(context).size.width - 50,
                  animation: true,
                  lineHeight: 20.0,
                  animationDuration: 2500,
                  percent: correctAnswer.length / listWords.length,
                  center: Text(
                      '${((correctAnswer.length / listWords.length) * 100).round()}%'),
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Colors.green,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Đúng: ${correctAnswer.length}/${listWords.length}",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Sai: ${wrongAnswer.length}/${listWords.length}",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                ),
                time != -1
                    ? Container(
                        padding: EdgeInsets.all(8),
                        child: Text(
                          "Thời gian: ${time.toString()} giây",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
                const SizedBox(height: 10),
                Container(
                  height: screenHeight - appBarHeight - statusBarHeight,
                  child: ListView.builder(
                      itemCount: listWords.length,
                      physics: NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        var word = listWords[index];
                        bool isCorrect = correctAnswer.contains(word);
                        return Card(
                          child: ListTile(
                            title: Text(word.english.toString()),
                            subtitle: Text(word.vietnamese.toString()),
                            trailing: Wrap(
                              spacing: 12, // space between two icons
                              children: [
                                IconButton(
                                  icon: Icon(Icons.volume_up),
                                  onPressed: () {
                                    speak(word.english.toString());
                                  },
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                  ),
                                ), //  // icon-1
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: EdgeInsets.symmetric(vertical: 5),
            ),
            onPressed: () {
              Get.off(QuizPage(), arguments: [
                listWords,
                topic,
                desc,
                topicId,
              ]);
            },
            child: Text("Học lại",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/ranking_controller.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:quiz_loy/pages/detail_topic.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/typing_screen.dart';

class ResultTyping extends StatefulWidget {
  const ResultTyping({super.key});

  @override
  State<ResultTyping> createState() => _ResultTypingState();
}

class _ResultTypingState extends State<ResultTyping> {
  RankingController rankingController = Get.put(RankingController());
  HomePageController homePageController = Get.put(HomePageController());
  FlutterTts flutterTts = FlutterTts();
  RxList<Word> listWords = RxList();
  List<Word> correctWords = [];
  List<Word> wrongWords = [];
  String? topic;
  String? desc;
  String? topicId;
  int? time;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    var data = Get.arguments;
    correctWords = data[0];
    wrongWords = data[1];
    listWords = data[2];
    topic = data[3];
    desc = data[4];
    topicId = data[5];
    time = data[6];
    if (time != -1) {
      rankingController.addOrUpdateRanking(
          homePageController.user!.uid, topicId!, correctWords.length, time!);
    }
    print(data);
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
      appBar: AppBar(
          title: Text("Kết quả"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.offAll(HomePage());
            },
          )),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text("Bạn đã hoàn thành chủ đề $topic",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            LinearPercentIndicator(
              width: MediaQuery.of(context).size.width - 50,
              animation: true,
              lineHeight: 20.0,
              animationDuration: 2500,
              percent: correctWords.length / listWords.length,
              center: Text(
                  '${((correctWords.length / listWords.length) * 100).round()}%'),
              linearStrokeCap: LinearStrokeCap.roundAll,
              progressColor: Colors.green,
            ),
            const SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              child: Text(
                "Đúng: ${correctWords.length}/${listWords.length}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
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
              padding: EdgeInsets.all(8),
              child: Text(
                "Sai: ${wrongWords.length}/${listWords.length}",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: screenHeight - appBarHeight - statusBarHeight,
              child: ListView.builder(
                  itemCount: listWords.length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    var word = listWords[index];
                    bool isCorrect = correctWords.contains(word);
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
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Icon(
                                isCorrect ? Icons.check : Icons.close,
                                color: isCorrect ? Colors.green : Colors.red,
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 5),
          ),
          onPressed: () {
            Get.off(TypingPage(), arguments: [
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
      ),
    );
  }
}

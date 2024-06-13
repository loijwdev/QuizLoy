import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:quiz_loy/pages/flash_card.dart';
import 'package:quiz_loy/pages/home_page.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  List<Word> known = [];
  List<Word> learning = [];
  RxList<Word> listWords = RxList();
  String? topic;
  String? desc;
  String? topicId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var data = Get.arguments;
    known = data[0];
    learning = data[1];
    listWords = data[2];
    topicId = data[3];
    topic = data[4];
    desc = data[5];
    print("known: $known");
    print("learning: $learning");
  }

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularPercentIndicator(
                radius: 70.0,
                lineWidth: 13.0,
                animation: true,
                percent: known.length >= learning.length
                    ? known.length / (known.length + learning.length)
                    : learning.length / (known.length + learning.length),
                center: known.length >= learning.length
                    ? Text(
                        "${(known.length / (known.length + learning.length) * 100).toStringAsFixed(0)}%",
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      )
                    : Text(
                        "${(learning.length / (known.length + learning.length) * 100).toStringAsFixed(0)}%",
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20.0),
                      ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: known.length >= learning.length
                    ? Colors.green
                    : Colors.orange,
              ),
              Column(
                children: [
                  Text(
                    "Đã biết",
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Đang học",
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    known.length.toString(),
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.green,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    learning.length.toString(),
                    style: TextStyle(
                        fontSize: 19,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Container(
              width: double
                  .infinity, // This will make the button stretch across the screen
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  Get.off(FlashCard(),
                      arguments: [listWords, topicId, topic, desc]);
                },
                child: Text(
                  "Làm lại",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

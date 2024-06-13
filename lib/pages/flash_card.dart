import 'package:card_swiper/card_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/learning_progress_controller.dart';
import 'package:quiz_loy/controllers/ranking_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/controllers/word_controller.dart';
import 'package:quiz_loy/models/learning_progress.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:quiz_loy/pages/create_topic.dart';
import 'package:quiz_loy/pages/result_screen/result_flash_card.dart';

class FlashCard extends StatefulWidget {
  const FlashCard({super.key});

  @override
  State<FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<FlashCard> {
  int length = 80;
  var temp = 0.obs;
  var autoplay = false.obs;
  RxList<Word> listWords = RxList();
  String? topicId;
  String? topic;
  String? desc;
  FlutterTts flutterTts = FlutterTts();
  int currentCardIndex = 0;
  SwiperController swiperController = SwiperController();
  WordController wordController = Get.put(WordController());
  LearningProgressController learningProgressController =
      Get.put(LearningProgressController());
  HomePageController homePageController = Get.put(HomePageController());
  CreateTopicController topicController = Get.put(CreateTopicController());
  RankingController rankingController = Get.put(RankingController());
  RxString dropdownValue = 'Tiếng Anh'.obs;
  User user = User();
  speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setVolume(1.0);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    var data = Get.arguments;
    print(data);
    listWords = data[0];
    topicId = data[1];
    topic = data[2];
    desc = data[3];
    super.initState();
    getUserOfTopic(topicId!);
  }

  void getUserOfTopic(String topicId) async {
    user = await topicController.getUserByTopicId(topicId);
  }

  @override
  Widget build(BuildContext context) {
    List<Word> known = [];
    List<Word> learning = [];

    double height = MediaQuery.of(context).size.height;
    List<GlobalKey<FlipCardState>> cardKeys =
        List<GlobalKey<FlipCardState>>.generate(
      listWords.length,
      (index) => GlobalKey<FlipCardState>(),
    );
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Obx(() => Text("${temp.value + 1}/${listWords.length}",
              style: TextStyle(fontWeight: FontWeight.bold))),
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          return AlertDialog(
                            title: Text("Thiết lập thẻ ghi nhớ"),
                            content: Container(
                              child: Obx(() => Container(
                                    height: 120,
                                    child: Column(
                                      children: [
                                        DropdownButton<String>(
                                          value: dropdownValue.value,
                                          items: <String>[
                                            'Tiếng Anh',
                                            'Tiếng Việt'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              dropdownValue.value = newValue!;
                                            });
                                            Navigator.pop(context);
                                          },
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        ElevatedButton(
                                            onPressed: () {
                                              listWords.shuffle();
                                            },
                                            child: Text("Trộn ngẫu nhiên"))
                                      ],
                                    ),
                                  )),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                icon: Icon(Icons.settings))
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                  height: 4.5 / 6 * height,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: Obx(() => Swiper(
                        controller: swiperController,
                        itemBuilder: (BuildContext context, int index) {
                          return Obx(() => FlipCard(
                                key: cardKeys[index],
                                fill: Fill.fillBack,
                                direction: FlipDirection.VERTICAL, // default
                                side: CardSide.FRONT,
                                front: Container(
                                  color: Colors.black26,
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          dropdownValue.value == "Tiếng Anh"
                                              ? listWords[index].english!
                                              : listWords[index].vietnamese!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 29,
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        child:
                                            dropdownValue.value == "Tiếng Anh"
                                                ? IconButton(
                                                    icon: Icon(Icons.volume_up),
                                                    onPressed: () {
                                                      speak(listWords[index]
                                                          .english!);
                                                      // Xử lý sự kiện khi nhấn nút loa
                                                    },
                                                  )
                                                : SizedBox.shrink(),
                                      ),
                                    ],
                                  ),
                                ),
                                back: Container(
                                    color: Colors.black26,
                                    child: Stack(
                                      children: [
                                        Center(
                                          child: Text(
                                            dropdownValue.value == 'Tiếng Anh'
                                                ? listWords[index].vietnamese!
                                                : listWords[index].english!,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 29),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: dropdownValue.value ==
                                                  "Tiếng Anh"
                                              ? SizedBox.shrink()
                                              : IconButton(
                                                  icon: Icon(Icons.volume_up),
                                                  onPressed: () {
                                                    speak(listWords[index]
                                                        .english!);
                                                  },
                                                ),
                                        ),
                                      ],
                                    )),
                              ));
                        },
                        autoplay: autoplay.value,
                        itemCount: listWords.length,
                        onIndexChanged: (value) async {
                          temp.value = value;
                          print("temp: ${temp.value}");
                          if (autoplay.value) {
                            // temp.value = value;
                            speak(listWords[temp.value].english!);
                            await Future.delayed(Duration(seconds: 1));
                            cardKeys[temp.value].currentState?.toggleCard();

                            learning.add(listWords[temp.value]);

                            String userId = homePageController.user!.uid;
                            if (userId != user.id!) {
                              learningProgressController
                                  .addLearningProgressToDb(
                                      homePageController.user!.uid, topicId!, {
                                "${listWords[0].wordId!}": "learning",
                                "${listWords[temp.value].wordId!}": "learning"
                              });
                              print("khác");
                            } else {
                              wordController.changeStatusWord(topicId!,
                                  listWords[temp.value].wordId!, "learning");
                            }
                            // Kiểm tra nếu là chỉ mục cuối cùng của danh sách
                            if (temp.value == listWords.length - 1) {
                              learning.add(listWords[0]);
                              if (userId == user.id!) {
                                wordController.changeStatusWord(
                                    topicId!, listWords[0].wordId!, "learning");
                              } else {
                                rankingController.addOrUpdateRanking(
                                    userId, topicId!, 0, 0);
                              }
                              await Future.delayed(Duration(seconds: 1));
                              cardKeys[temp.value].currentState?.toggleCard();
                              Get.to(ResultPage(), arguments: [
                                known,
                                learning,
                                listWords,
                                topicId,
                                topic,
                                desc
                              ]);
                              swiperController.stopAutoplay();
                              autoplay.value = false;
                            }
                          } else {
                            print("tempstop: ${temp.value}");
                            // swiperController.stopAutoplay();
                            swiperController.move(temp.value);
                          }
                        },
                      ))),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      String userId = homePageController.user!.uid;
                      if (temp.value == listWords.length - 1) {
                        learning.add(listWords[temp.value]);

                        Get.to(ResultPage(), arguments: [
                          known,
                          learning,
                          listWords,
                          topicId,
                          topic,
                          desc
                        ]);
                        if (userId != user.id) {
                          rankingController.addOrUpdateRanking(
                              userId, topicId!, 0, 0);
                        }
                      } else {
                        swiperController.next();

                        learning.add(listWords[temp.value]);
                      }

                      if (user.id != userId) {
                        learningProgressController.addLearningProgressToDb(
                            homePageController.user!.uid,
                            topicId!,
                            {"${listWords[temp.value].wordId!}": "learning"});
                      } else {
                        wordController.changeStatusWord(topicId!,
                            listWords[temp.value].wordId!, "learning");
                      }
                    },
                    child: Text("Đang học"),
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(5)),
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      String userId = homePageController.user!.uid;
                      if (temp.value == listWords.length - 1) {
                        known.add(listWords[temp.value]);

                        Get.to(ResultPage(), arguments: [
                          known,
                          learning,
                          listWords,
                          topicId,
                          topic,
                          desc
                        ]);
                        if (userId != user.id) {
                          rankingController.addOrUpdateRanking(
                              userId, topicId!, 0, 0);
                        }
                      } else {
                        swiperController.next();

                        known.add(listWords[temp.value]);
                      }
                      if (user.id != userId) {
                        learningProgressController.addLearningProgressToDb(
                            homePageController.user!.uid,
                            topicId!,
                            {"${listWords[temp.value].wordId!}": "known"});
                      } else {
                        wordController.changeStatusWord(
                            topicId!, listWords[temp.value].wordId!, "known");
                      }
                    },
                    child: Text("Đã biết"),
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.all(5)),
                      textStyle: MaterialStateProperty.all<TextStyle>(
                        TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                  onPressed: () {
                    autoplay.value = !autoplay.value;
                  },
                  style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.black),
                    textStyle: MaterialStateProperty.all<TextStyle>(
                      TextStyle(fontSize: 16),
                    ),
                  ),
                  child: Obx(() => autoplay.value
                      ? Text("Dừng", style: TextStyle(fontSize: 16))
                      : Text("Chế độ tự động", style: TextStyle(fontSize: 16))))
            ],
          ),
        ));
  }
}

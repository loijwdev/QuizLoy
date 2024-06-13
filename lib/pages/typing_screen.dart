import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/learning_progress_controller.dart';
import 'package:quiz_loy/controllers/ranking_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/controllers/word_controller.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:quiz_loy/pages/result_screen/result_typing.dart';

class TypingPage extends StatefulWidget {
  @override
  _TypingPageState createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  WordController wordController = Get.put(WordController());
  RankingController rankingController = Get.put(RankingController());
  CreateTopicController topicController = Get.put(CreateTopicController());
  HomePageController homePageController = Get.put(HomePageController());
  LearningProgressController learningProgressController =
      Get.put(LearningProgressController());
  RxList<Word> listWords = RxList();
  String? topic;
  String? desc;
  String? topicId;
  var currentQuestionIndex = 0.obs;
  TextEditingController textEditingController = TextEditingController();
  List<Word> correctWords = [];
  List<Word> wrongWords = [];
  RxString dropdownValue = "Nhập Tiếng Anh".obs;
  var checkSpeak = false.obs;
  var checkShowAnser = false.obs;
  FlutterTts flutterTts = FlutterTts();
  String? currentUserId;
  Stopwatch stopwatch = Stopwatch();
  int? timeTaken;
  User userOfTopic = User();

  void speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  @override
  void initState() {
    super.initState();
    var data = Get.arguments;
    listWords = data[0];
    topic = data[1];
    desc = data[2];
    topicId = data[3];
    print(data);
    currentUserId = homePageController.user!.uid;
    stopwatch.start();
  }

  Stream<int> stopwatchStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield stopwatch.elapsed.inSeconds;
    }
  }

  void getUserOfTopic(String topicId) async {
    userOfTopic = await topicController.getUserByTopicId(topicId);
    print('User: ${userOfTopic.id}');
  }

  List<String> shuffleLetters(String word) {
    List<String> letters = word.split('');
    letters.shuffle();
    return letters;
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex.value < listWords.length - 1) {
      currentQuestionIndex.value++;
    } else {
      stopwatch.stop();
      if (userOfTopic.id != currentUserId) {
        timeTaken = stopwatch.elapsed.inSeconds;
      } else {
        timeTaken = -1;
      }
      Get.to(ResultTyping(), arguments: [
        correctWords,
        wrongWords,
        listWords,
        topic,
        desc,
        topicId,
        timeTaken
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Typing"),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Obx(() => AlertDialog(
                          title: Text("Tùy chọn đánh chữ"),
                          content: Container(
                            height: 205,
                            child: Column(
                              children: [
                                DropdownButton<String>(
                                  value: dropdownValue.value,
                                  items: <String>[
                                    'Nhập Tiếng Anh',
                                    'Nhập Tiếng Việt'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    dropdownValue.value = newValue!;
                                  },
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Tự đông phát âm",
                                        style: TextStyle(fontSize: 15)),
                                    Checkbox(
                                        value: checkSpeak.value,
                                        onChanged: (value) {
                                          checkSpeak.value = value!;
                                          print(checkSpeak.value);
                                        })
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Hiển thị đáp án ngay sau khi trả lời sai",
                                      style: TextStyle(fontSize: 15),
                                    ),
                                    Checkbox(
                                        value: checkShowAnser.value,
                                        onChanged: (value) {
                                          checkShowAnser.value = value!;
                                          print(checkShowAnser.value);
                                        }),
                                  ],
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      listWords.shuffle();
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Xáo trộn'))
                              ],
                            ),
                          )));
                    });
              },
              icon: Icon(Icons.settings)),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressBar(
                  maxSteps: listWords.length,
                  progressType: LinearProgressBar.progressTypeLinear,
                  currentStep: currentQuestionIndex.value + 1,
                  progressColor: Colors.grey,
                  backgroundColor: Colors.black12,
                ),
                dropdownValue.value == "Nhập Tiếng Anh"
                    ? Text(
                        listWords[currentQuestionIndex.value].english!,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        listWords[currentQuestionIndex.value].vietnamese!,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                SizedBox(height: 40),
                TextField(
                  controller: textEditingController,
                  decoration: InputDecoration(
                    hintText: "Nhập",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: dropdownValue.value == "Nhập Tiếng Anh"
                          ? shuffleLetters(listWords[currentQuestionIndex.value]
                                  .vietnamese!
                                  .replaceAll(RegExp(r'\s+'), ''))
                              .map((letter) {
                              return LetterButton(
                                letter: letter,
                              );
                            }).toList()
                          : shuffleLetters(listWords[currentQuestionIndex.value]
                                  .english!
                                  .replaceAll(RegExp(r'\s+'), ''))
                              .map((letter) {
                              return LetterButton(
                                letter: letter,
                              );
                            }).toList()),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (dropdownValue.value == "Nhập Tiếng Anh") {
                      if (textEditingController.text.toLowerCase() ==
                          listWords[currentQuestionIndex.value]
                              .vietnamese!
                              .toLowerCase()) {
                        if (checkSpeak.value) {
                          speak(listWords[currentQuestionIndex.value].english!);
                        }
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Đúng!"),
                            );
                          },
                        );
                        if (currentUserId != userOfTopic.id) {
                          learningProgressController.addLearningProgressToDb(
                              currentUserId!, topicId!, {
                            "${listWords[currentQuestionIndex.value].wordId}":
                                "known"
                          });
                        } else {
                          wordController.changeStatusWord(
                              topicId!,
                              listWords[currentQuestionIndex.value].wordId!,
                              "known");
                        }
                        correctWords.add(listWords[currentQuestionIndex.value]);
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                          moveToNextQuestion();
                          textEditingController.clear();
                        });
                      } else {
                        if (checkSpeak.value) {
                          speak(listWords[currentQuestionIndex.value].english!);
                        }
                        if (checkShowAnser.value) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Sai!"),
                                content: Text(
                                    "Đáp án đúng là: ${listWords[currentQuestionIndex.value].vietnamese}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Sai!"),
                              );
                            },
                          );
                        }
                        if (currentUserId != userOfTopic.id) {
                          learningProgressController.addLearningProgressToDb(
                              currentUserId!, topicId!, {
                            "${listWords[currentQuestionIndex.value].wordId}":
                                "learning"
                          });
                        } else {
                          wordController.changeStatusWord(
                              topicId!,
                              listWords[currentQuestionIndex.value].wordId!,
                              "learning");
                        }
                        wrongWords.add(listWords[currentQuestionIndex.value]);
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                          moveToNextQuestion();
                          textEditingController.clear();
                        });
                      }
                    } else {
                      if (textEditingController.text.toLowerCase() ==
                          listWords[currentQuestionIndex.value]
                              .english!
                              .toLowerCase()) {
                        if (checkSpeak.value) {
                          speak(listWords[currentQuestionIndex.value].english!);
                        }
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Đúng!"),
                              // actions: [
                              //   TextButton(
                              //     onPressed: () {
                              //       Navigator.of(context).pop();
                              //     },
                              //     child: Text("OK"),
                              //   ),
                              // ],
                            );
                          },
                        );
                        if (currentUserId != userOfTopic.id) {
                          learningProgressController.addLearningProgressToDb(
                              currentUserId!, topicId!, {
                            "${listWords[currentQuestionIndex.value].wordId}":
                                "known"
                          });
                        } else {
                          wordController.changeStatusWord(
                              topicId!,
                              listWords[currentQuestionIndex.value].wordId!,
                              "known");
                        }
                        correctWords.add(listWords[currentQuestionIndex.value]);
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                          moveToNextQuestion();
                          textEditingController.clear();
                        });
                      } else {
                        if (checkSpeak.value) {
                          speak(listWords[currentQuestionIndex.value].english!);
                        }
                        if (checkShowAnser.value) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Sai!"),
                                content: Text(
                                    "Đáp án đúng là: ${listWords[currentQuestionIndex.value].english}",
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold)),
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Sai!"),
                              );
                            },
                          );
                        }
                        if (currentUserId != userOfTopic.id) {
                          learningProgressController.addLearningProgressToDb(
                              currentUserId!, topicId!, {
                            "${listWords[currentQuestionIndex.value].wordId}":
                                "learning"
                          });
                        } else {
                          wordController.changeStatusWord(
                              topicId!,
                              listWords[currentQuestionIndex.value].wordId!,
                              "learning");
                        }
                        wrongWords.add(listWords[currentQuestionIndex.value]);
                        Future.delayed(Duration(seconds: 1), () {
                          Navigator.of(context).pop();
                          moveToNextQuestion();
                          textEditingController.clear();
                        });
                      }
                    }
                  },
                  child: Text("Kiểm tra"),
                ),
                const SizedBox(
                  height: 35,
                ),
                StreamBuilder<int>(
                  stream: stopwatchStream(),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return SizedBox.shrink();
                    }
                    return userOfTopic.id != currentUserId
                        ? Center(
                            child: Text("Thời gian: ${snapshot.data} s",
                                style: TextStyle(fontSize: 20)),
                          )
                        : SizedBox.shrink();
                  },
                )
              ],
            ),
          )),
    );
  }
}

class LetterButton extends StatelessWidget {
  final String letter;

  LetterButton({required this.letter});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      child: Text(letter,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }
}

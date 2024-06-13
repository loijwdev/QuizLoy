import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:linear_progress_bar/linear_progress_bar.dart';
import 'package:quick_quiz_view/quick_quiz_view.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/learning_progress_controller.dart';
import 'package:quiz_loy/controllers/ranking_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/controllers/word_controller.dart';
import 'package:quiz_loy/models/learning_progress.dart';
import 'package:quiz_loy/models/ranking.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:quiz_loy/pages/quiz_screen/quiz_view.dart';
import 'dart:math';

import 'package:quiz_loy/pages/result_screen/result_quiz.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
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
  User userOfTopic = User();
  var currentQuestionIndex = 0.obs;
  late List<String> vietnameseWords;
  late List<String> englishWords;
  List<Word> correctAnswers = [];
  List<Word> incorrectAnswers = [];
  int correctAnswerIndex = 0;
  RxString dropdownValue = 'Q: Tiếng Anh - A: Tiếng Việt'.obs;
  var checkSpeak = false.obs;
  var checkShowAnser = false.obs;
  FlutterTts flutterTts = FlutterTts();
  String? currentUserId;
  Stopwatch stopwatch = Stopwatch();
  int? timeTaken;
  @override
  void initState() {
    super.initState();
    var data = Get.arguments;
    listWords = data[0];
    topic = data[1];
    desc = data[2];
    topicId = data[3];
    getUserOfTopic(topicId!);
    print('List words: $listWords');
    currentUserId = homePageController.user!.uid;
    stopwatch.start();
  }

  Stream<int> stopwatchStream() async* {
    while (true) {
      await Future.delayed(Duration(seconds: 1));
      yield stopwatch.elapsed.inSeconds;
    }
  }

  void speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);
  }

  void getUserOfTopic(String topicId) async {
    userOfTopic = await topicController.getUserByTopicId(topicId);
    print('User: ${userOfTopic.id}');
  }

  bool isCorrectAnswerEngtoVie(int selectedOptionIndex) {
    int correctAnswerIndex = vietnameseWords
        .indexOf(listWords[currentQuestionIndex.value].vietnamese!);
    return selectedOptionIndex - 1 == correctAnswerIndex;
  }

  bool isCorrectAnswerVietoEng(int selectedOptionIndex) {
    int correctAnswerIndex =
        englishWords.indexOf(listWords[currentQuestionIndex.value].english!);
    return selectedOptionIndex - 1 == correctAnswerIndex;
  }

  void moveToNextQuestionEngtoVie() {
    if (currentQuestionIndex.value < listWords.length - 1) {
      currentQuestionIndex.value++;

      vietnameseWords.shuffle();
      print("Vietnamese words move: ${vietnameseWords.sublist(0, 4)}");
      if (!vietnameseWords
          .sublist(0, 4)
          .contains(listWords[currentQuestionIndex.value].vietnamese!)) {
        vietnameseWords[randomIndex()] =
            listWords[currentQuestionIndex.value].vietnamese!;
        print("Vietnamese words move 2: $vietnameseWords");
      }
    } else {
      stopwatch.stop();
      if (userOfTopic.id != currentUserId) {
        timeTaken = stopwatch.elapsed.inSeconds;
      } else {
        timeTaken = -1;
      }
      Get.to(ResultQuizPage(), arguments: [
        correctAnswers,
        incorrectAnswers,
        listWords,
        topic,
        desc,
        topicId,
        timeTaken
      ]);
    }
  }

  void moveToNextQuestionVietoEng() {
    if (currentQuestionIndex.value < listWords.length - 1) {
      currentQuestionIndex.value++;

      englishWords.shuffle();
      print("English words move: ${englishWords.sublist(0, 4)}");
      if (!englishWords
          .sublist(0, 4)
          .contains(listWords[currentQuestionIndex.value].english!)) {
        englishWords[randomIndex()] =
            listWords[currentQuestionIndex.value].english!;
        print("English words move 2: $englishWords");
      }
    } else {
      if (userOfTopic.id != currentUserId) {
        timeTaken = stopwatch.elapsed.inSeconds;
      } else {
        timeTaken = -1;
      }
      Get.to(ResultQuizPage(), arguments: [
        correctAnswers,
        incorrectAnswers,
        listWords,
        topic,
        desc,
        topicId,
        timeTaken
      ]);
    }
  }

  int randomIndex() {
    var rng = new Random();
    int index = rng.nextInt(4); // generates a random number between 0 and 3
    print('Random index: $index');
    return index;
  }

  void updateOptions() {
    if (dropdownValue.value == 'Q: Tiếng Anh - A: Tiếng Việt') {
      vietnameseWords[randomIndex()] =
          listWords[currentQuestionIndex.value].vietnamese!;
    } else {
      englishWords[randomIndex()] =
          listWords[currentQuestionIndex.value].english!;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> randomVietnameseWords = [
      'sáng tạo',
      'phụng sự',
      'cố gắng',
      'trách nhiêm'
    ];

    vietnameseWords = listWords.map((word) => word.vietnamese!).toList();
    vietnameseWords.shuffle();

    while (vietnameseWords.length < 4) {
      vietnameseWords.add(randomVietnameseWords[vietnameseWords.length % 4]);
    }
    print('Vietnamese words: $vietnameseWords');
    if (!vietnameseWords
        .sublist(0, 4)
        .contains(listWords[currentQuestionIndex.value].vietnamese!)) {
      vietnameseWords[randomIndex()] =
          listWords[currentQuestionIndex.value].vietnamese!;
    }

    List<String> randomEnglishWords = [
      'creative',
      'service',
      'effort',
      'responsibility'
    ];

    englishWords = listWords.map((word) => word.english!).toList();
    englishWords.shuffle();
    while (englishWords.length < 4) {
      englishWords.add(randomEnglishWords[englishWords.length % 4]);
    }
    print('English words: $englishWords');
    if (!englishWords
        .sublist(0, 4)
        .contains(listWords[currentQuestionIndex.value].english!)) {
      englishWords[randomIndex()] =
          listWords[currentQuestionIndex.value].english!;
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Obx(() => AlertDialog(
                            title: Text('Tùy chọn hiển thị'),
                            content: Container(
                              height: 205,
                              child: Column(
                                children: [
                                  DropdownButton<String>(
                                    value: dropdownValue.value,
                                    items: <String>[
                                      'Q: Tiếng Anh - A: Tiếng Việt',
                                      'Q: Tiếng Việt - A: Tiếng Anh',
                                    ].map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      dropdownValue.value = newValue!;
                                      updateOptions();
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
                                      child: Text('Xáo trộn')),
                                ],
                              ),
                            )));
                      });
                },
                icon: Icon(Icons.settings))
          ],
        ),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),

            // Trong phương thức build
            child: Obx(
              () => Column(
                children: [
                  LinearProgressBar(
                    maxSteps: listWords.length,
                    progressType: LinearProgressBar.progressTypeLinear,
                    currentStep: currentQuestionIndex.value + 1,
                    progressColor: Colors.grey,
                    backgroundColor: Colors.black12,
                  ),
                  QuickQuizViewz(
                    title: dropdownValue.value == 'Q: Tiếng Anh - A: Tiếng Việt'
                        ? listWords[currentQuestionIndex.value].english!
                        : listWords[currentQuestionIndex.value].vietnamese!,
                    option1:
                        dropdownValue.value == 'Q: Tiếng Anh - A: Tiếng Việt'
                            ? vietnameseWords[0]
                            : englishWords[0],
                    option2:
                        dropdownValue.value == 'Q: Tiếng Anh - A: Tiếng Việt'
                            ? vietnameseWords[1]
                            : englishWords[1],
                    option3:
                        dropdownValue.value == 'Q: Tiếng Anh - A: Tiếng Việt'
                            ? vietnameseWords[2]
                            : englishWords[2],
                    option4:
                        dropdownValue.value == 'Q: Tiếng Anh - A: Tiếng Việt'
                            ? vietnameseWords[3]
                            : englishWords[3],
                    onOptionSelected: (value) {
                      print('Selected option: $value');
                      if (dropdownValue.value ==
                          'Q: Tiếng Anh - A: Tiếng Việt') {
                        if (isCorrectAnswerEngtoVie(value)) {
                          correctAnswers
                              .add(listWords[currentQuestionIndex.value]);

                          if (checkSpeak.value) {
                            speak(
                                listWords[currentQuestionIndex.value].english!);
                          }

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Correct Answer'),
                                content: Text(
                                    'Congratulations! You selected the correct answer.'),
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

                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.of(context).pop(); // Close the dialog
                            moveToNextQuestionEngtoVie();
                          });
                        } else {
                          if (checkSpeak.value) {
                            speak(
                                listWords[currentQuestionIndex.value].english!);
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

                          incorrectAnswers
                              .add(listWords[currentQuestionIndex.value]);
                          if (checkShowAnser.value) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Wrong Answer'),
                                  content: dropdownValue.value ==
                                          'Q: Tiếng Anh - A: Tiếng Việt'
                                      ? Text(
                                          'Sorry! You selected the wrong answer. The correct answer is: ${listWords[currentQuestionIndex.value].vietnamese}')
                                      : Text(
                                          'Sorry! You selected the wrong answer. The correct answer is: ${listWords[currentQuestionIndex.value].english}'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Tiếp tục'),
                                      onPressed: () {
                                        Navigator.of(context).pop();

                                        moveToNextQuestionEngtoVie();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            Future.delayed(Duration(seconds: 4), () {
                              Navigator.of(context).pop(); // Close the dialog
                              moveToNextQuestionEngtoVie();
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Wrong Answer'),
                                );
                              },
                            );
                            Future.delayed(Duration(seconds: 1), () {
                              Navigator.of(context).pop(); // Close the dialog
                              moveToNextQuestionEngtoVie();
                            });
                          }
                        }
                      } else {
                        if (isCorrectAnswerVietoEng(value)) {
                          if (checkSpeak.value) {
                            speak(
                                listWords[currentQuestionIndex.value].english!);
                          }
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

                          correctAnswers
                              .add(listWords[currentQuestionIndex.value]);
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Correct Answer'),
                                content: Text(
                                    'Congratulations! You selected the correct answer.'),
                              );
                            },
                          );
                          Future.delayed(Duration(seconds: 1), () {
                            Navigator.of(context).pop(); // Close the dialog
                            moveToNextQuestionVietoEng();
                          });
                        } else {
                          if (checkSpeak.value) {
                            speak(
                                listWords[currentQuestionIndex.value].english!);
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

                          incorrectAnswers
                              .add(listWords[currentQuestionIndex.value]);

                          if (checkShowAnser.value) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Wrong Answer'),
                                  content: dropdownValue.value ==
                                          'Q: Tiếng Anh - A: Tiếng Việt'
                                      ? Text(
                                          'Sorry! You selected the wrong answer. The correct answer is: ${listWords[currentQuestionIndex.value].vietnamese}')
                                      : Text(
                                          'Sorry! You selected the wrong answer. The correct answer is: ${listWords[currentQuestionIndex.value].english}'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text('Tiếp tục'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        moveToNextQuestionVietoEng();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                            Future.delayed(Duration(seconds: 4), () {
                              Navigator.of(context).pop(); // Close the dialog
                              moveToNextQuestionVietoEng();
                            });
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Wrong Answer'),
                                );
                              },
                            );
                            Future.delayed(Duration(seconds: 1), () {
                              Navigator.of(context).pop(); // Close the dialog
                              moveToNextQuestionVietoEng();
                            });
                          }
                        }
                      }
                    },
                    onNextPressed: () {},
                    onPreviousPressed: () {},
                  ),
                  StreamBuilder<int>(
                    stream: stopwatchStream(),
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return SizedBox.shrink();
                      }
                      return userOfTopic.id != currentUserId
                          ? Text("Thời gian: ${snapshot.data} s",
                              style: TextStyle(fontSize: 20))
                          : SizedBox.shrink();
                    },
                  )
                ],
              ),
            )));
  }
}

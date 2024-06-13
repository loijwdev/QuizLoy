import 'package:csv/csv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flip_card/flip_card.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/learning_progress_controller.dart';
import 'package:quiz_loy/controllers/network_controller.dart';
import 'package:quiz_loy/controllers/personal_topic_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/controllers/word_controller.dart';
import 'package:quiz_loy/models/topic_personal.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:quiz_loy/pages/add_topic_to_folder.dart';
import 'package:quiz_loy/pages/create_topic.dart';
import 'package:quiz_loy/pages/detail_info_topic.dart';
import 'package:quiz_loy/pages/flash_card.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/quiz_screen/quiz.dart';
import 'package:quiz_loy/pages/toast/toast.dart';
import 'package:quiz_loy/pages/typing_screen.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class DetailTopic extends StatefulWidget {
  const DetailTopic({super.key});

  @override
  State<DetailTopic> createState() => _DetailTopicState();
}

class _DetailTopicState extends State<DetailTopic> {
  FlutterTts flutterTts = FlutterTts();
  RxList<Word> listWords = RxList<Word>.empty();
  CreateTopicController createTopicController =
      Get.put(CreateTopicController());
  WordController wordController = Get.put(WordController());
  HomePageController homePageController = Get.put(HomePageController());
  LearningProgressController learningProgressController =
      Get.put(LearningProgressController());
  NetworkController networkController = Get.put(NetworkController());
  String? topic;
  String? desc;
  String? topicId;
  String? sourceScreen;
  String? userId;
  String? uuIDCurrent;
  int knownWordsCount = 0;
  int knownWordsCountOtherPeople = 0;
  bool _showBanner = true;
  User user = User();
  List<String> wordIds = [];

  void getUUId() async {
    uuIDCurrent = await createTopicController.auth.currentUser!.uid;
    print("uuIDCurrent: $uuIDCurrent");
  }

  void getUserByTopicId() async {
    user = await createTopicController.getUserByTopicId(topicId!);
  }

  @override
  void initState() {
    super.initState();
    // Access Get.arguments and assign it to listWords in initState
    var data = Get.arguments;
    listWords = data[0] as RxList<Word>;
    for (var word in listWords) {
      wordIds.add(word.wordId.toString());
    }
    print("List words: $listWords");
    topic = data[1];
    desc = data[2];
    topicId = data[3];
    if (data.length >= 6) {
      sourceScreen = data[4];
      userId = data[5];
      if (sourceScreen != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar("Bạn có muốn thêm học phần ", "Thêm học phần",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Color.fromARGB(255, 151, 125, 125)!,
              mainButton: TextButton(
                onPressed: () {
                  var personalTopic = TopicPersonal(
                    userId: userId,
                    topicIds: [topicId!],
                  );
                  createTopicController.addPersonalTopic(personalTopic);
                  createTopicController.updateTopicViewCount(topicId!);
                  Get.back();
                },
                child: Text("Thêm", style: TextStyle(color: Colors.white)),
              ),
              duration: Duration(seconds: 35));
        });
      }
    }

    getUUId();
    getUserByTopicId();
    print(data);
  }

  @override
  Widget build(BuildContext context) {
    speak(String text) async {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setVolume(1.0);
      await flutterTts.speak(text);
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.offAll(HomePage());
          },
        ),
        actions: [
          PopupMenuButton(
              onSelected: (value) {
                if (value == '1') {
                  Get.to(CreateTopic(),
                      arguments: [listWords, topic, desc, topicId]);
                } else if (value == '2') {
                  Get.to(AddTopicToFolder(), arguments: [topicId]);
                } else if (value == '3') {
                  createTopicController.removeTopic(topicId.toString());
                } else if (value == '4') {
                  Get.to(DetailInfoTopic(), arguments: [topicId, listWords]);
                }
              },
              itemBuilder: (context) => [
                    if (user.id == uuIDCurrent)
                      const PopupMenuItem(
                        value: '1',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Sửa học phần")
                          ],
                        ),
                      ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.folder),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Thêm vào thư mục"),
                        ],
                      ),
                      value: '2',
                    ),
                    if (user.id == uuIDCurrent)
                      const PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Xóa học phần")
                          ],
                        ),
                        value: '3',
                      ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(Icons.details),
                          SizedBox(
                            width: 5,
                          ),
                          Text("Thông tin chi tiết"),
                        ],
                      ),
                      value: '4',
                    ),
                  ])
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _showBanner && networkController.isConnected.value
                  ? FutureBuilder(
                      future: Future.wait([
                        Future.value(
                            createTopicController.auth.currentUser!.uid),
                        createTopicController.getUserByTopicId(topicId!),
                        wordController.getKnownWordsCount(
                            topicId.toString(), wordIds),
                        learningProgressController.getKnownWordsCount(
                            createTopicController.auth.currentUser!.uid,
                            topicId!)
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          uuIDCurrent = snapshot.data![0] as String;
                          user = snapshot.data![1] as User;
                          knownWordsCount = snapshot.data![2] as int;
                          knownWordsCountOtherPeople = snapshot.data![3] as int;
                          print("Snapshot.data: ${snapshot.data}");
                          if (user.id == uuIDCurrent &&
                              knownWordsCount < listWords.length - 1)
                            return SizedBox.shrink();
                          if (user.id != uuIDCurrent &&
                              knownWordsCountOtherPeople < listWords.length - 1)
                            return SizedBox.shrink();
                          return MaterialBanner(
                            content: (() {
                              print("user.id: ${user.id}");
                              print("uuIDCurrent: $uuIDCurrent");
                              if (user.id == uuIDCurrent &&
                                  knownWordsCount >= listWords.length - 1) {
                                return Text(
                                  "Bạn đã thạo ${knownWordsCount}/${listWords.length} từ vựng trong học phần này",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              } else if (user.id != uuIDCurrent &&
                                  knownWordsCountOtherPeople >=
                                      listWords.length - 1) {
                                return Text(
                                  "Bạn đã thạo ${knownWordsCountOtherPeople}/${listWords.length} từ vựng trong học phần của ${user.username}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            }()),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            backgroundColor: Colors.blue[100],
                            actions: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _showBanner = false;
                                  });
                                },
                                child: Text(
                                  "Đóng",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                  ),
                                ),
                              )
                            ],
                          );
                        }
                      })
                  : SizedBox.shrink(),
              const SizedBox(
                height: 5,
              ),
              MySwiper(
                listWords: listWords,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                topic.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      child: FutureBuilder<User>(
                    future: createTopicController.getUserByTopicId(topicId!),
                    builder:
                        (BuildContext context, AsyncSnapshot<User> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        user = snapshot.data!;
                        return Row(
                          children: [
                            user.photoUrl == null ||
                                    !networkController.isConnected.value
                                ? CircleAvatar(
                                    backgroundImage:
                                        AssetImage("assets/images/img.jpg"),
                                  )
                                : CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user.photoUrl.toString()),
                                  ),
                            SizedBox(
                              width: 18,
                            ),
                            Text(user.username.toString()),
                          ],
                        );
                      }
                    },
                  )),
                  Container(
                    height: 24, // Chiều cao của đường dọc
                    width: 2, // Chiều rộng của đường dọc
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Expanded(child: Text("${listWords.length} thuật ngữ"))
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text(desc.toString()),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.black26,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: ListTile(
                  leading: Icon(Icons.import_contacts),
                  title: Text("Thẻ ghi nhớ"),
                  onTap: () {
                    bool hasStarredWord =
                        listWords.any((word) => word.starred == true);
                    if (hasStarredWord) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Lựa chọn thẻ ghi nhớ'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: ListTile(
                                    title: Text('Học hết'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Get.to(FlashCard(), arguments: [
                                        listWords,
                                        topicId,
                                        topic,
                                        desc
                                      ]);
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: ListTile(
                                    title: Text('Học các từ đã đánh dấu'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      RxList<Word> starredWords =
                                          RxList<Word>.from(listWords
                                              .where((word) =>
                                                  word.starred == true)
                                              .toList());
                                      Get.to(FlashCard(), arguments: [
                                        starredWords,
                                        topicId,
                                        topic,
                                        desc
                                      ]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Hủy'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Get.to(FlashCard(),
                          arguments: [listWords, topicId, topic, desc]);
                    }
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.black26,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: ListTile(
                  onTap: () {
                    bool hasStarredWord =
                        listWords.any((word) => word.starred == true);
                    if (hasStarredWord) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Lựa chọn trắc nghiệm'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: ListTile(
                                    title: Text('Học hết'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Get.to(QuizPage(), arguments: [
                                        listWords,
                                        topic,
                                        desc,
                                        topicId,
                                      ]);
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: ListTile(
                                    title: Text('Học các từ đã đánh dấu'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      RxList<Word> starredWords =
                                          RxList<Word>.from(listWords
                                              .where((word) =>
                                                  word.starred == true)
                                              .toList());
                                      Get.to(QuizPage(), arguments: [
                                        starredWords,
                                        topic,
                                        desc,
                                        topicId,
                                      ]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Hủy'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Get.to(QuizPage(), arguments: [
                        listWords,
                        topic,
                        desc,
                        topicId,
                      ]);
                    }
                  },
                  leading: Icon(Icons.quiz),
                  title: Text("Trắc nghiệm"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  color: Colors.black26,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: ListTile(
                  onTap: () {
                    bool hasStarredWord =
                        listWords.any((word) => word.starred == true);
                    if (hasStarredWord) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Lựa chọn đánh chữ'),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: ListTile(
                                    title: Text('Học hết'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      Get.to(TypingPage(), arguments: [
                                        listWords,
                                        topic,
                                        desc,
                                        topicId,
                                      ]);
                                    },
                                  ),
                                ),
                                const SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8.0)),
                                  ),
                                  child: ListTile(
                                    title: Text('Học các từ đã đánh dấu'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      RxList<Word> starredWords =
                                          RxList<Word>.from(listWords
                                              .where((word) =>
                                                  word.starred == true)
                                              .toList());
                                      Get.to(TypingPage(), arguments: [
                                        starredWords,
                                        topic,
                                        desc,
                                        topicId,
                                      ]);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Hủy'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      Get.to(TypingPage(), arguments: [
                        listWords,
                        topic,
                        desc,
                        topicId,
                      ]);
                    }
                  },
                  leading: Icon(Icons.keyboard),
                  title: Text("Đánh chữ"),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Thuật ngữ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  TextButton(
                      onPressed: exportToCsv,
                      child: Text("Xuất ra file .csv",
                          style: TextStyle(color: Colors.black, fontSize: 17)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey[300]))),
                ],
              ),
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: listWords.length,
                  itemBuilder: (context, index) {
                    var word = listWords[index];
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
                            ), // icon-1
                            IconButton(
                              icon: Icon(Icons.star,
                                  color: word.starred == true
                                      ? Colors.yellow
                                      : Colors.grey),
                              onPressed: () {
                                setState(() {
                                  wordController.starWord(
                                      topicId!, word.wordId!);
                                  word.starred = !word.starred!;
                                });
                              },
                            ), // icon-2   )
                          ],
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  void exportToCsv() {
    List<String> header = ['English', 'Vietnamese'];
    List<List<String>> listOfLists = [];
    listWords.forEach((word) {
      listOfLists.add([word.english.toString(), word.vietnamese.toString()]);
    });
    exportCSV.myCSV(header, listOfLists, fileName: topicId);
  }
}

class MySwiper extends StatefulWidget {
  final RxList<Word> listWords;
  const MySwiper({
    super.key,
    required this.listWords,
  });

  @override
  State<MySwiper> createState() => _MySwiperState();
}

class _MySwiperState extends State<MySwiper> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 270,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          var word = widget.listWords[index];
          return FlipCard(
            fill: Fill.fillBack,
            direction: FlipDirection.VERTICAL, // default
            side: CardSide.FRONT,
            front: Container(
              color: Color.fromARGB(255, 56, 52, 52),
              child: Center(
                child: Text(
                  word.english.toString(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.white),
                ),
              ),
            ),
            back: Container(
                color: Color.fromARGB(255, 56, 52, 52),
                child: Center(
                  child: Text(
                    word.vietnamese.toString(),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: Colors.white),
                  ),
                )),
          );
        },
        itemCount: widget.listWords.length,
        pagination: (widget.listWords.length >= 10)
            ? SwiperPagination(
                margin: EdgeInsets.zero,
                builder: SwiperCustomPagination(builder: (context, config) {
                  return Container(
                    child: Stack(children: [
                      Positioned(
                        bottom: 7,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Text(
                            ' ${config.activeIndex + 1}/${config.itemCount}',
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ]),
                  );
                }),
              )
            : SwiperPagination(
                builder: DotSwiperPaginationBuilder(
                  color: Colors.grey,
                  activeColor: Colors.blue,
                  space: 8,
                  size: 10,
                  activeSize: 12,
                ),
              ),
        control: SwiperControl(),
      ),
    );
  }
}

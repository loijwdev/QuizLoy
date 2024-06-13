import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/folder_controller.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/network_controller.dart';
import 'package:quiz_loy/controllers/personal_topic_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/local_db/database_helper.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:quiz_loy/pages/create_topic.dart';
import 'package:quiz_loy/pages/detail_folder.dart';
import 'package:quiz_loy/pages/detail_topic.dart';
import 'package:quiz_loy/pages/library_page.dart';
import 'package:quiz_loy/pages/widget/app_bar.dart';
import 'package:quiz_loy/pages/widget/bottom_navigation_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomePageController homePageController;
  late FolderController folderController;
  late PersonalTopicController personalTopicController;
  late NetworkController networkController;

  @override
  void initState() {
    super.initState();
    homePageController = Get.put(HomePageController());
    folderController = Get.put(FolderController());
    personalTopicController = Get.put(PersonalTopicController());
    networkController = Get.put(NetworkController());
  }

  var db = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        personalTopicController.getTopicIds(homePageController.user!.uid),
        folderController.getListFolders(homePageController.user!.uid)
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else {
          if (snapshot.hasError) {
            return Text('Error');
          } else {
            return Scaffold(
              appBar: HomeAppBar(),
              body: SafeArea(
                child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 13),
                    child:
                        // if (!networkController.isConnected.value) {
                        //   return Center(
                        //     child: Text(
                        //       'Không có kết nối mạng',
                        //       style: TextStyle(
                        //         color: Colors.red,
                        //         fontSize: 18,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   );
                        // }
                        SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Các học phần",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(LibraryPage(indexTab: 0));
                                },
                                child: Text(
                                  "Xem tất cả",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            height: 180,
                            child: ListTopics(
                              listTopics: snapshot.data![0],
                            ),
                          ),
                          SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Thư mục",
                                style: TextStyle(
                                    fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                              TextButton(
                                onPressed: () {
                                  Get.to(LibraryPage(indexTab: 1));
                                },
                                child: Text(
                                  "Xem tất cả",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            height: 140,
                            width: double.infinity,
                            child: ListFolder(
                              listFolders: folderController.listFolders,
                            ),
                          ),
                        ],
                      ),
                    )),
              ),
              bottomNavigationBar: BottomNavigation(),
            );
          }
        }
      },
    );
  }
}

class ListTopics extends StatefulWidget {
  List<String> listTopics;

  ListTopics({super.key, required this.listTopics});

  @override
  State<ListTopics> createState() => _ListTopicsState();
}

class _ListTopicsState extends State<ListTopics> {
  late PageController _pageController;
  late HomePageController homePageController;
  late PersonalTopicController personalTopicController;
  late CreateTopicController createTopicController;
  var db = DatabaseHelper();
  NetworkController networkController = Get.find<NetworkController>();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    homePageController = Get.find<HomePageController>();
    personalTopicController = Get.find<PersonalTopicController>();
    createTopicController = Get.put(CreateTopicController());
    print(widget.listTopics.length);
  }

  @override
  Widget build(BuildContext context) {
    return widget.listTopics.isNotEmpty
        ? PageView.builder(
            controller: _pageController,
            itemCount: widget.listTopics.length,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            itemBuilder: (BuildContext context, int index) {
              return Obx(() {
                return FutureBuilder<VocabularyTopic?>(
                    future: networkController.isConnected.value
                        ? createTopicController
                            .getTopicById(widget.listTopics[index])
                        : db.getTopicById(widget.listTopics[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else {
                        VocabularyTopic? topic = snapshot.data;
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 0),
                          child: Card(
                            child: InkWell(
                              onTap: () async {
                                await homePageController
                                    .getListWords(topic.topicId.toString());
                                Get.to(DetailTopic(), arguments: [
                                  homePageController.listWords,
                                  topic.title,
                                  topic.description,
                                  topic.topicId
                                ]);
                              },
                              splashColor: Colors.blue.withAlpha(30),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      topic!.title.toString(),
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    FutureBuilder<int>(
                                      future: homePageController.getWordsLength(
                                          topic.topicId.toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else {
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Error'); // Error handling
                                          } else {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                border: Border.all(
                                                    color: Colors.black),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(5.0)),
                                              ),
                                              child: Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 7),
                                                child: Text(
                                                  "${snapshot.data} thuật ngữ",
                                                  style:
                                                      TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                    FutureBuilder<User>(
                                      future: homePageController
                                          .getUserById(topic.userId.toString()),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return CircularProgressIndicator();
                                        } else {
                                          if (snapshot.hasError) {
                                            return Text('Error');
                                          } else {
                                            String userName = snapshot
                                                .data!.username
                                                .toString();
                                            return Text(
                                              userName,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            );
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    });
              });
              // return Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 0),
              //   child: Card(
              //     child: InkWell(
              //       onTap: () async {
              //         // await homePageController
              //         //     .getListWords(topic.topicId.toString());
              //         // Get.to(DetailTopic(), arguments: [
              //         //   homePageController.listWords,
              //         //   topic.title,
              //         //   topic.description,
              //         //   topic.topicId
              //         // ]);
              //       },
              //       splashColor: Colors.blue.withAlpha(30),
              //       child: Padding(
              //         padding: const EdgeInsets.all(12.0),
              //         child: Column(
              //           crossAxisAlignment: CrossAxisAlignment.start,
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Text(
              //               topic.title.toString(),
              //               style: TextStyle(
              //                   fontSize: 18, fontWeight: FontWeight.bold),
              //             ),
              //             FutureBuilder<int>(
              //               future: homePageController
              //                   .getWordsLength(topic.topicId.toString()),
              //               builder: (context, snapshot) {
              //                 if (snapshot.connectionState ==
              //                     ConnectionState.waiting) {
              //                   return CircularProgressIndicator();
              //                 } else {
              //                   if (snapshot.hasError) {
              //                     return Text('Error'); // Error handling
              //                   } else {
              //                     return Container(
              //                       decoration: BoxDecoration(
              //                         color: Colors.grey,
              //                         border: Border.all(color: Colors.black),
              //                         borderRadius: BorderRadius.all(
              //                             Radius.circular(5.0)),
              //                       ),
              //                       child: Container(
              //                         margin:
              //                             EdgeInsets.symmetric(horizontal: 7),
              //                         child: Text(
              //                           "${snapshot.data} thuật ngữ",
              //                           style: TextStyle(fontSize: 18),
              //                         ),
              //                       ),
              //                     );
              //                   }
              //                 }
              //               },
              //             ),
              //             FutureBuilder<User>(
              //               future: homePageController
              //                   .getUserById(topic.userId.toString()),
              //               builder: (context, snapshot) {
              //                 if (snapshot.connectionState ==
              //                     ConnectionState.waiting) {
              //                   return CircularProgressIndicator();
              //                 } else {
              //                   if (snapshot.hasError) {
              //                     return Text('Error');
              //                   } else {
              //                     String userName =
              //                         snapshot.data!.username.toString();
              //                     return Text(
              //                       userName,
              //                       style: TextStyle(
              //                         fontSize: 16,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                     );
              //                   }
              //                 }
              //               },
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // );
            },
          )
        : Center(
            child: Text(
              'Tạo học phần',
              style: TextStyle(fontSize: 24),
            ),
          );
  }
}

class ListFolder extends StatefulWidget {
  final RxList listFolders;
  const ListFolder({super.key, required this.listFolders});

  @override
  State<ListFolder> createState() => _ListFolderState();
}

class _ListFolderState extends State<ListFolder> {
  late PageController _pageController;
  late FolderController folderController;
  late HomePageController homePageController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    folderController = Get.find();
    homePageController = Get.find();
  }

  @override
  Widget build(BuildContext context) {
    return widget.listFolders.isEmpty
        ? Center(
            child: Text(
              'Tạo thư mục',
              style: TextStyle(fontSize: 24),
            ),
          )
        : PageView.builder(
            controller: _pageController,
            itemCount: widget.listFolders.length,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        0), // Thay đổi giá trị 16.0 thành khoảng cách mong muốn
                child: Card(
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {
                      Get.to(DetailFolder(), arguments: [
                        widget.listFolders[index].folderId,
                        widget.listFolders[index].title,
                        widget.listFolders[index].description
                      ]);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.listFolders[index].title.toString(),
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              FutureBuilder<int>(
                                future: folderController.getLengthOfTopics(
                                    widget.listFolders[index].folderId
                                        .toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    if (snapshot.hasError) {
                                      print(snapshot.error);
                                      return Text('Error');
                                    } else {
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          border:
                                              Border.all(color: Colors.black),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0)),
                                        ),
                                        child: Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 7),
                                          child: Text(
                                            "${snapshot.data} học phần",
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                              Spacer(),
                              FutureBuilder<User>(
                                future: homePageController.getUserById(widget
                                    .listFolders[index].userId
                                    .toString()),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else {
                                    if (snapshot.hasError) {
                                      return Text('Error');
                                    } else {
                                      String userName =
                                          snapshot.data!.username.toString();
                                      return Text(
                                        userName,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
    ;
  }
}

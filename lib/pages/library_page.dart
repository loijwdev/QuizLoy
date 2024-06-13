import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/folder_controller.dart';
import 'package:quiz_loy/controllers/home_page_controller.dart';
import 'package:quiz_loy/controllers/personal_topic_controller.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/models/folder.dart';
import 'package:quiz_loy/models/user.dart';
import 'package:quiz_loy/models/vocab_topic.dart';
import 'package:quiz_loy/pages/create_folder.dart';
import 'package:quiz_loy/pages/create_topic.dart';
import 'package:quiz_loy/pages/detail_folder.dart';
import 'package:quiz_loy/pages/detail_topic.dart';
import 'package:quiz_loy/pages/widget/bottom_navigation_bar.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

class LibraryPage extends StatefulWidget {
  final int indexTab;
  const LibraryPage({super.key, required this.indexTab});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  late HomePageController homePageController;
  late FolderController folderController;
  late CreateTopicController topicController;
  late PersonalTopicController personalTopicController;

  @override
  void initState() {
    super.initState();
    homePageController = Get.put(HomePageController());
    folderController = Get.put(FolderController());
    topicController = Get.put(CreateTopicController());
    personalTopicController = Get.put(PersonalTopicController());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future:
            personalTopicController.getTopicIds(homePageController.user!.uid),
        builder: (context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show loading spinner while waiting for data
          } else if (snapshot.hasError) {
            return Text(
                'Error: ${snapshot.error}'); // Show error message if there's an error
          } else {
            final topicIds = snapshot.data;
            return FutureBuilder<List<VocabularyTopic>>(
              future: topicController.getTopicsByIds(topicIds!),
              builder: (BuildContext context,
                  AsyncSnapshot<List<VocabularyTopic>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator()); // Show loading spinner while waiting for data
                } else if (snapshot.hasError) {
                  return Text(
                      'Error: ${snapshot.error}'); // Show error message if there's an error
                } else {
                  final listTopic = snapshot.data;
                  final topicsByTime =
                      groupBy(listTopic as Iterable<VocabularyTopic>,
                          (VocabularyTopic topic) {
                    final date = topic.createdAt;
                    return DateFormat('MM/yyyy').format(date!);
                  });
                  return DefaultTabController(
                    initialIndex: widget.indexTab,
                    length: 2,
                    child: Scaffold(
                        appBar: AppBar(
                          title: const Text('Thư viện'),
                          centerTitle: true,
                          bottom: const TabBar(
                            tabs: <Widget>[
                              Tab(
                                text: "Học phần",
                              ),
                              Tab(
                                text: 'Thư mục',
                              ),
                            ],
                          ),
                          actions: [
                            PopupMenuButton(
                                onSelected: (value) {
                                  if (value == '1') {
                                    Get.to(CreateTopic());
                                  } else {
                                    Get.to(CreateFolder());
                                  }
                                },
                                itemBuilder: (context) => const [
                                      PopupMenuItem(
                                        value: '1',
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text("Thêm học phần")
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text("Thêm thư mục"),
                                          ],
                                        ),
                                        value: '2',
                                      ),
                                    ])
                          ],
                        ),
                        body: TabBarView(
                          children: [
                            listTopic!.isEmpty
                                ? const Center(
                                    child: Text("Bạn chưa có học phần nào"))
                                : ListView.builder(
                                    itemCount: topicsByTime.keys.length,
                                    itemBuilder: (context, index) {
                                      final time =
                                          topicsByTime.keys.elementAt(index);
                                      final topics = topicsByTime[time]!;
                                      return ExpansionTile(
                                        title: Text(time),
                                        children: topics.map((topic) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Card(
                                              child: InkWell(
                                                onTap: () async {
                                                  await homePageController
                                                      .getListWords(topic
                                                          .topicId!
                                                          .toString());
                                                  Get.to(DetailTopic(),
                                                      arguments: [
                                                        homePageController
                                                            .listWords,
                                                        topic.title!,
                                                        topic.description!,
                                                        topic.topicId
                                                      ]);
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      19.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children: [
                                                      Text(topic.title!),
                                                      const SizedBox(
                                                          height: 10),
                                                      FutureBuilder<int>(
                                                        future: homePageController
                                                            .getWordsLength(
                                                                topic.topicId!),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return CircularProgressIndicator();
                                                          } else {
                                                            if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error'); // Error handling
                                                            } else {
                                                              return Text(
                                                                "${snapshot.data} thuật ngữ",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      ),
                                                      const SizedBox(
                                                          height: 10),
                                                      FutureBuilder<User>(
                                                        future: homePageController
                                                            .getUserById(topic
                                                                .userId
                                                                .toString()),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return CircularProgressIndicator();
                                                          } else {
                                                            if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error');
                                                            } else {
                                                              String userName =
                                                                  snapshot.data!
                                                                      .username
                                                                      .toString();
                                                              return Text(
                                                                userName,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                        }).toList(),
                                      );
                                    }),
                            FutureBuilder(
                              future: folderController.getListFolders(
                                  folderController.auth.currentUser!.uid),
                              builder: (context,
                                  AsyncSnapshot<RxList<Folder>> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                } else if (snapshot.hasError) {
                                  return const Center(child: Text("Error"));
                                } else {
                                  return ListView.builder(
                                    itemCount: snapshot.data!.length,
                                    itemBuilder: (context, index) {
                                      final folder = snapshot.data![index];
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Card(
                                          child: InkWell(
                                            onTap: () async {
                                              Get.to(DetailFolder(),
                                                  arguments: [
                                                    folder.folderId,
                                                    folder.title,
                                                    folder.description,
                                                  ]);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(19.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.stretch,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.folder),
                                                      SizedBox(width: 20),
                                                      Text(folder.title!),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),
                                                  Row(
                                                    children: [
                                                      FutureBuilder<int>(
                                                        future: folderController
                                                            .getLengthOfTopics(
                                                                folder.folderId
                                                                    .toString()),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return CircularProgressIndicator();
                                                          } else {
                                                            if (snapshot
                                                                .hasError) {
                                                              print(snapshot
                                                                  .error);
                                                              return Text(
                                                                  'Error');
                                                            } else {
                                                              return Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .grey,
                                                                  border: Border.all(
                                                                      color: Colors
                                                                          .black),
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              5.0)),
                                                                ),
                                                                child:
                                                                    Container(
                                                                  margin: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              7),
                                                                  child: Text(
                                                                    "${snapshot.data} học phần",
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            18),
                                                                  ),
                                                                ),
                                                              );
                                                            }
                                                          }
                                                        },
                                                      ),
                                                      const SizedBox(
                                                        width: 50,
                                                      ),
                                                      FutureBuilder<User>(
                                                        future: homePageController
                                                            .getUserById(folder
                                                                .userId
                                                                .toString()),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Center(
                                                                child:
                                                                    CircularProgressIndicator());
                                                          } else {
                                                            if (snapshot
                                                                .hasError) {
                                                              return Text(
                                                                  'Error');
                                                            } else {
                                                              String userName =
                                                                  snapshot.data!
                                                                      .username
                                                                      .toString();
                                                              return Text(
                                                                userName,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
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
                                }
                              },
                            )
                          ],
                        ),
                        bottomNavigationBar: BottomNavigation()),
                  );
                }
              },
            );
          }
        });
  }
}

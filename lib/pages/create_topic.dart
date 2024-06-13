import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/topic_controller.dart';
import 'package:quiz_loy/models/word.dart';
import 'package:quiz_loy/pages/toast/toast.dart';
import 'package:quiz_loy/pages/widget/bottom_navigation_bar.dart';
import 'package:path/path.dart' as path; // For file path manipulation
import 'package:csv/csv.dart'; // For parsing CSV files

class CreateTopic extends StatefulWidget {
  const CreateTopic({super.key});

  @override
  State<CreateTopic> createState() => _CreateTopicState();
}

class _CreateTopicState extends State<CreateTopic> {
  CreateTopicController createTopicController =
      Get.put(CreateTopicController());
  RxList<Word> listWords = RxList<Word>.empty();
  String? topic;
  String? desc;
  String? topicId;
  List<int> removedIndices = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (Get.arguments != null) {
        var data = Get.arguments;
        print(data);
        listWords = data[0];
        topic = data[1];
        desc = data[2];
        topicId = data[3];
        createTopicController.title.text = topic!;
        createTopicController.description.text = desc!;
        createTopicController.containerCount.value = listWords.length;
        print("lwl: ${listWords.length}");
        for (int i = 0; i < listWords.length; i++) {
          if (createTopicController.english.length <= i) {
            createTopicController.english.add(TextEditingController());
          }
          if (createTopicController.vietnamese.length <= i) {
            createTopicController.vietnamese.add(TextEditingController());
          }
          createTopicController.english[i].text = listWords[i].english!;
          createTopicController.vietnamese[i].text = listWords[i].vietnamese!;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Tạo học phần",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // leading: IconButton(
          //   icon: Icon(Icons.settings),
          //   onPressed: () {},
          // ),
          actions: [
            TextButton(
                onPressed: () {
                  if (Get.arguments != null) {
                    createTopicController.updateTopic(topicId!);
                    print("removedIndices: $removedIndices");
                    if (removedIndices.isNotEmpty) {
                      for (int index in removedIndices) {
                        print(index);
                        print(listWords.length);
                        if (index < listWords.length) {
                          print("index: $index");
                          print(listWords[index]);
                          print(listWords[index].wordId!);
                          createTopicController.deleteWord(
                              topicId!, listWords[index].wordId!);
                        }
                      }
                    }
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Obx(() => AlertDialog(
                              title: Text('Ai có thể xem'),
                              content: DropdownButton<String>(
                                value:
                                    createTopicController.dropdownValue.value,
                                icon: const Icon(Icons.arrow_downward),
                                iconSize: 24,
                                elevation: 16,
                                style:
                                    const TextStyle(color: Colors.deepPurple),
                                underline: Container(
                                  height: 2,
                                  color: Colors.deepPurpleAccent,
                                ),
                                onChanged: (String? newValue) {
                                  createTopicController
                                      .changeDropdownValue(newValue!);
                                },
                                items: <String>[
                                  'Mọi người',
                                  'Chỉ tôi'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Đóng'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    createTopicController.addTopicToDb();
                                  },
                                ),
                              ],
                            ));
                      },
                    );
                  }
                },
                child: Text("Xong",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black)))
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: createTopicController.title,
                      decoration: InputDecoration(
                        hintText: "Chủ đề, chương, đơn vị",
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 3),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text("Tiêu đề"),
                    TextFormField(
                      controller: createTopicController.description,
                      decoration: InputDecoration(
                        hintText: "Học phần của bạn có chủ đề gì",
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 3),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Text("Mô tả"),
                  ],
                ),
              ),
              SizedBox(
                height: 12,
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Hướng dẫn'),
                        content: Text(
                          'Hãy chọn file có đuôi là .csv và chứa các từ vựng theo định dạng: "English, Vietnamese" mỗi từ sẽ cách nhau 1 dấu , trên 1 dòng. Ví dụ: "Hello , Xin chào"',
                          style: TextStyle(fontSize: 18),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Chọn file'),
                            onPressed: () {
                              _importFile(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text(
                  "Thêm các từ vựng từ file .csv",
                  style: TextStyle(color: Colors.black),
                ),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  padding:
                      MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(16)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Obx(
                () => Column(
                  children: List.generate(
                    createTopicController.containerCount.value,
                    (index) => Column(
                      children: [
                        Container(
                          color: Colors.grey.shade300,
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Dismissible(
                                key: UniqueKey(),
                                direction: DismissDirection.endToStart,
                                onDismissed: (direction) {
                                  if (listWords.length > 2) {
                                    setState(() {
                                      //listWords.removeAt(index);
                                      createTopicController
                                          .removeContainer(index);
                                      removedIndices.add(index);
                                    });
                                  } else {
                                    showToast(
                                        message:
                                            "Bạn phải thêm vào ít nhất hai thuật ngữ mới lưu được học phần");
                                    // how to resfresh the page
                                    Get.back();
                                  }
                                },
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: EdgeInsets.only(right: 20.0),
                                  color: Colors.red,
                                  child:
                                      Icon(Icons.delete, color: Colors.white),
                                ),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller:
                                          createTopicController.english[index],
                                      decoration: InputDecoration(
                                        labelText: "Thuật ngữ",
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue, width: 3),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    TextFormField(
                                      controller: createTopicController
                                          .vietnamese[index],
                                      decoration: InputDecoration(
                                        labelText: "Định nghĩa",
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.blue, width: 3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 12), // Adjust the height as needed
                      ],
                    ),
                  ).toList(),
                ),
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                height: 60,
                width: double.infinity,
                // color: Colors.black12,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(0.8, 1),
                    colors: <Color>[
                      Color(0xff1f005c),
                      Color(0xff5b0060),
                      Color(0xff870160),
                      Color(0xffac255e),
                      Color(0xffca485c),
                      Color(0xffe16b5c),
                      Color(0xfff39060),
                      Color(0xffffb56b),
                    ], // Gradient from https://learnui.design/tools/gradient-generator.html
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    print('tap');
                    createTopicController.addContainer();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Column(
                      children: <Widget>[
                        Icon(
                          Icons.add_circle,
                          color: Colors.white,
                          size: 28,
                        ),
                        Text('Thêm'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: Container(
        //   height: 60,
        //   // color: Colors.black12,
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topLeft,
        //       end: Alignment(0.8, 1),
        //       colors: <Color>[
        //         Color(0xff1f005c),
        //         Color(0xff5b0060),
        //         Color(0xff870160),
        //         Color(0xffac255e),
        //         Color(0xffca485c),
        //         Color(0xffe16b5c),
        //         Color(0xfff39060),
        //         Color(0xffffb56b),
        //       ], // Gradient from https://learnui.design/tools/gradient-generator.html
        //     ),
        //   ),
        //   child: InkWell(
        //     onTap: () {
        //       print('tap');
        //       createTopicController.addContainer();
        //     },
        //     child: Padding(
        //       padding: EdgeInsets.only(top: 8.0),
        //       child: Column(
        //         children: <Widget>[
        //           Icon(
        //             Icons.add_circle,
        //             color: Colors.white,
        //             size: 28,
        //           ),
        //           Text('Thêm'),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  Future<void> _importFile(BuildContext context) async {
    try {
      final filePicker = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (filePicker != null && filePicker.files.isNotEmpty) {
        final filePath = filePicker.files.single.path!;

        // Read the contents of the file
        final fileContent = await File(filePath).readAsString();

        final csvConverter = CsvToListConverter();
        final csvList = csvConverter.convert(fileContent);

        // Skip the first row (header)
        final dataRows = csvList.skip(1);

        // Convert each row to a pair of English - Vietnamese
        List<List<String>> pairs = dataRows.map((row) {
          return [row[0].toString(), row[1].toString()];
        }).toList();

        // Show the preview dialog with the pairs
        _showPreviewDialog(context, pairs);
      }
    } catch (e) {
      print('Error importing file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing file. Please try again.'),
        ),
      );
    }
    
  }

  void _showPreviewDialog(BuildContext context, List<List<String>> pairs) {
    List<TextEditingController> englishControllers = [];
    List<TextEditingController> vietnameseControllers = [];

    // Initialize controllers for each pair
    for (List<String> pair in pairs) {
      String englishWord = pair[0].trim();
      String vietnameseMeaning = pair.length > 1 ? pair[1].trim() : 'N/A';
      englishControllers.add(TextEditingController(text: englishWord));
      vietnameseControllers.add(TextEditingController(text: vietnameseMeaning));
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xem trước'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(pairs.length, (index) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: englishControllers[index],
                      decoration: InputDecoration(
                        labelText: "English - $index",
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 3),
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: vietnameseControllers[index],
                      decoration: InputDecoration(
                        labelText: "Vietnamese - $index",
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue, width: 3),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                );
              }),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                CreateTopicController createTopicController =
                    Get.find<CreateTopicController>();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Obx(() => AlertDialog(
                          title: Text('Ai có thể xem'),
                          content: DropdownButton<String>(
                            value: createTopicController.dropdownValue.value,
                            icon: const Icon(Icons.arrow_downward),
                            iconSize: 24,
                            elevation: 16,
                            style: const TextStyle(color: Colors.deepPurple),
                            underline: Container(
                              height: 2,
                              color: Colors.deepPurpleAccent,
                            ),
                            onChanged: (String? newValue) {
                              createTopicController
                                  .changeDropdownValue(newValue!);
                            },
                            items: <String>['Mọi người', 'Chỉ tôi']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Đóng'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text('OK'),
                              onPressed: () {
                                List<String> updatedPairs = [];
                                for (int i = 0; i < pairs.length; i++) {
                                  String englishWord =
                                      englishControllers[i].text.trim();
                                  String vietnameseMeaning =
                                      vietnameseControllers[i].text.trim();
                                  updatedPairs
                                      .add('$englishWord, $vietnameseMeaning');
                                }

                                createTopicController
                                    .addTopicFromCsv(updatedPairs);
                                createTopicController.update();
                              },
                            ),
                          ],
                        ));
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}

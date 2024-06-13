import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/folder_controller.dart';
import 'package:quiz_loy/models/folder.dart';

class CreateFolder extends StatefulWidget {
  const CreateFolder({super.key});

  @override
  State<CreateFolder> createState() => _CreateFolderState();
}

class _CreateFolderState extends State<CreateFolder> {
  FolderController folderController = Get.put(FolderController());
  String? title;
  String? description;
  String? folderId;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Get.arguments != null) {
      var data = Get.arguments;
      print(data);
      folderId = data[0];
      title = data[1];
      description = data[2];
      folderController.title.text = title!;
      folderController.description.text = description!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Thư mục mới",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
              onPressed: () {
                if (Get.arguments != null) {
                  folderController.updateFolder(folderId!);
                } else {
                  folderController.addFolderToDb();
                }
              },
              child: Text("Lưu",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black)))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextFormField(
            controller: folderController.title,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 3),
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text("Tiêu đề thư mục"),
          TextFormField(
            controller: folderController.description,
            decoration: InputDecoration(
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.blue, width: 3),
              ),
            ),
          ),
          SizedBox(
            height: 4,
          ),
          Text("Mô tả (tùy chọn)"),
        ]),
      ),
    );
  }
}

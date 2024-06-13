import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/pages/community.dart';
import 'package:quiz_loy/pages/create_folder.dart';
import 'package:quiz_loy/pages/create_topic.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/library_page.dart';
import 'package:quiz_loy/pages/setting_screen.dart';
import 'package:quiz_loy/pages/toast/toast.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQueryData = MediaQuery.of(context);
    double screenWidth = mediaQueryData.size.width;
    double screenHeight = mediaQueryData.size.height;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      onTap: (value) => {
        print(value),
        if (value == 0)
          {Get.offAll(HomePage())}
        else if (value == 1)
          {Get.to(Community())}
        else if (value == 2)
          {}
        else if (value == 3)
          Future.delayed(Duration.zero, () async {
            {
              Get.to(LibraryPage(
                indexTab: 0,
              ));
            }
          })
        else
          {Get.to(SettingScreen())}
      },
      selectedItemColor: Colors.purple,
      unselectedItemColor: Colors.black,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Trang chủ"),
        BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories), label: "Cộng đồng"),
        BottomNavigationBarItem(
            icon: PopupMenuButton(
                onSelected: (value) => {
                      if (value == '1')
                        {Get.to(const CreateTopic())}
                      else
                        {Get.to(const CreateFolder())},
                    },
                offset: Offset(screenWidth * 0.2, screenHeight * -0.14),
                icon: Icon(Icons.add),
                itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: '1',
                        child: Row(
                          children: [
                            Icon(Icons.topic),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Học phần")
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: '2',
                        child: Row(
                          children: [
                            Icon(Icons.folder),
                            SizedBox(
                              width: 5,
                            ),
                            Text("Thư mục")
                          ],
                        ),
                      )
                    ]),
            label: ""),
        BottomNavigationBarItem(
            icon: Icon(Icons.folder_open), label: "Thư viện"),
        BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts), label: "Hồ sơ")
      ],
    );
  }
}

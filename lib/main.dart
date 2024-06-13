import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/dependency_injection.dart';
import 'package:quiz_loy/pages/quiz_screen/quiz.dart';

import 'package:quiz_loy/pages/result_screen/result_flash_card.dart';

import 'package:device_preview/device_preview.dart';
import 'package:quiz_loy/pages/result_screen/result_quiz.dart';
import 'package:quiz_loy/pages/splash_screen/splash_screen.dart';
import 'package:quiz_loy/pages/typing_screen.dart';
import 'package:quiz_loy/pages/user_auth_page/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyAHKAbR_keSyrpj1QYJGZniorv2Kybk5bY",
          appId: "1:633623089633:android:68493624b531e9fb6602a0",
          messagingSenderId: "633623089633",
          projectId: "quizloy-95173",
          storageBucket: "quizloy-95173.appspot.com",

      ));

  // runApp(
  //   DevicePreview(
  //     enabled: true,
  //     tools: [
  //       ...DevicePreview.defaultTools,
  //     ],
  //     builder: (context) => const MyApp(),
  //   ),
  // );
  runApp(const MyApp());
  DependencyInjection.init();

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QuizLoy',
        // useInheritedMediaQuery: true,
        // locale: DevicePreview.locale(context),
        // builder: DevicePreview.appBuilder,
        home: SplashScreen());
    // home: TypingPage());
  }
}

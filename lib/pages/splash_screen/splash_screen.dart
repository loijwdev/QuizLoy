import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/user_auth_page/login_page.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Hiển thị hình ảnh splash trước, sau đó thực hiện kiểm tra trạng thái đăng nhập
    Future.delayed(Duration(seconds: 2), _checkLoginStatus);
  }

  void _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (email != null && password != null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        print("Login successful");
        Get.offAll(() => HomePage()); // Điều hướng đến HomePage
      } catch (e) {
        prefs.remove('email');
        prefs.remove('password');
        Get.offAll(() => LoginPage()); // Điều hướng đến LoginPage
      }
    } else {
      Get.offAll(() => LoginPage()); // Điều hướng đến LoginPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset("assets/logo/logo.png"),
      ),
    );
  }
}

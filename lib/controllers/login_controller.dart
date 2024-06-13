import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/toast/toast.dart';

import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  FirebaseAuth _auth = FirebaseAuth.instance;
  RxBool isSigning = false.obs;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController resetPassController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserEmailPassword();
  }

  void onLogin() async {
    isSigning.value = true;
    String email = emailController.text;
    String password = passwordController.text;

    try {
      UserCredential userCredential = await signInWithEmailAndPassword(email, password);
      isSigning.value = false;

      if (userCredential.user != null) {
        showToast(message: "User is successfully signed in");
        await _saveUserEmailPassword(email, password);
        Get.off(HomePage());
      } else {
        isSigning.value = false;
        showToast(message: "Incorrect email or password");
      }
    } catch (e) {
      print(e);
      isSigning.value = false;
      showToast(message: "Some error occurred");
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-email' || e.code == 'invalid-credential') {
        showToast(message: 'Invalid email or password.');
      } else {
        print(e.code);
        showToast(message: 'An error occurred: ${e.code}');
      }
      rethrow;
    }
  }

  Future<void> _saveUserEmailPassword(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<void> _loadUserEmailPassword() async {
    final prefs = await SharedPreferences.getInstance();
    emailController.text = prefs.getString('email') ?? '';
    passwordController.text = prefs.getString('password') ?? '';
  }

  void submit(BuildContext context) async {
    String resetPass = resetPassController.text;
    showToast(message: 'Please Check Your Email');
    await _auth.sendPasswordResetEmail(email: resetPass);
    resetPassController.clear();
    Navigator.pop(context);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}

// Create a custom dialog
Future openDialog(BuildContext context, LoginController loginController) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      String? errorMessage;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Email Recovery'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter your Email',
                    errorText: errorMessage,
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  controller: loginController.resetPassController,
                ),

              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  String resetPass = loginController.resetPassController.text;
                  if (resetPass.isEmpty) {
                    setState(() {
                      errorMessage = 'Please enter your email';
                    });
                  } else if (!loginController._isValidEmail(resetPass)) {
                    setState(() {
                      errorMessage = 'Invalid email address';
                    });
                  } else {
                    loginController.submit(context);
                    setState(() {
                      errorMessage = null;
                    });
                  }
                },
                child: Text(
                    'SUBMIT',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

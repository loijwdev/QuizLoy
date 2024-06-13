import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/toast/toast.dart';
import 'package:quiz_loy/models/user.dart' as u;

class SignUpController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  //bool isSigningUp = false;
  RxBool isSigningUp = false.obs;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isValidEmail(String email) {
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

  void onSignUp() async {
    isSigningUp.value = true;
    String email = emailController.text;
    String password = passwordController.text;
    String rePassword = rePasswordController.text;
    String username = usernameController.text;
    if (rePassword == password) {
      if (isValidEmail(email)) {
        try {
          UserCredential userCredential = await createAccount(email, password);
          isSigningUp.value = false;
          if (userCredential.user != null) {
            final userData = u.User(
              id: userCredential.user!.uid,
              email: email,
              photoUrl: null,
              username: username,
            );
            await createUser(userData);
            Get.to(const HomePage());
            showToast(message: "User is successfully created");
          }
        } catch (ex) {
          print(ex);
        }
      } else {
        showToast(message: "Invalid email format");
      }
    } else {
      showToast(message: "Error in password!");
    }
  }

  Future<UserCredential> createAccount(String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return userCredential;
    } on FirebaseAuthException catch (ex) {
      if (ex.code == "weak-password") {
        showToast(
          message: "Weak Password",
        );
      } else if (ex.code == "email-already-in-use") {
        showToast(
          message: "Email Already exists",
        );
      }
      throw ex;
    } catch (ex) {
      print(ex);
      throw ex;
    }
  }

  Future<void> createUser(u.User user) async {
    try {
      final docUser =
          FirebaseFirestore.instance.collection('users').doc(user.id);
      final json = user.toJson();
      await docUser.set(json);
    } catch (e) {
      print("Error writing to Firestore: $e");
      // Handle the error appropriately, e.g., show an error message to the user
    }
  }
}

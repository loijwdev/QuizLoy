import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/sign_up_controller.dart';

import 'package:quiz_loy/pages/toast/toast.dart';
import 'package:quiz_loy/pages/home_page.dart';

import 'package:quiz_loy/pages/user_auth_page/login_page.dart';

import 'package:quiz_loy/pages/widget/form_container_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  SignUpController signUpController = Get.put(SignUpController());
  //bool isSigningUp = false;

  @override
  void dispose() {
    signUpController.emailController.dispose();
    signUpController.passwordController.dispose();
    signUpController.rePasswordController.dispose();
    signUpController.usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/logo/logo.png',
                        width: 135,
                      )
                    ],
                  ),
                ),
                Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                FormContainerWidget(
                  controller: signUpController.emailController,
                  hintText: "Email",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 20,
                ),
                FormContainerWidget(
                  controller: signUpController.usernameController,
                  hintText: "Username",
                  isPasswordField: false,
                ),
                SizedBox(
                  height: 20,
                ),
                FormContainerWidget(
                  controller: signUpController.passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                ),
                SizedBox(
                  height: 20,
                ),
                FormContainerWidget(
                  controller: signUpController.rePasswordController,
                  hintText: "Re-enter the password",
                  isPasswordField: true,
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        signUpController.onSignUp();
                      },
                      child: Obx(
                        () => signUpController.isSigningUp.value
                            ? CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                "Sign Up",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        // disabledBackgroundColor: Color.fromRGBO(95, 169, 239, 1),
                        // disabledForegroundColor: Colors.white,
                        backgroundColor: Color.fromRGBO(95, 169, 239, 1),
                      )),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          height: 0.05,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 33.0),
                        child: Text(
                          "OR",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 0, 0, 0.4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color.fromRGBO(0, 0, 0, 0.2),
                          height: 0.05,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      style: TextStyle(fontSize: 17),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(LoginPage());
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> createUser(u.User user) async {
  //   try {
  //     final docUser =
  //         FirebaseFirestore.instance.collection('users').doc(user.id);
  //     final json = user.toJson();
  //     await docUser.set(json);
  //   } catch (e) {
  //     print("Error writing to Firestore: $e");
  //     // Handle the error appropriately, e.g., show an error message to the user
  //   }
  // }

  // void _signUp() async {
  //   setState(() {
  //     isSigningUp = true;
  //   });

  //   String email = signUpController.emailController.text;
  //   String password = signUpController.passwordController.text;
  //   String rePassword = signUpController.rePasswordController.text;
  //   String username = signUpController.usernameController.text;

  //   if (rePassword == password) {
  //     User? user = await _auth.signUpWithEmailAndPassword(email, password);
  //     setState(() {
  //       isSigningUp = false;
  //     });
  //     if (user != null) {
  //       final userData = u.User(
  //           id: user.uid, email: email, photoUrl: null, username: username);
  //       createUser(userData);
  //       Navigator.push(
  //           context, MaterialPageRoute(builder: (context) => HomePage()));
  //       showToast(message: "User is successfully created");
  //     } else {
  //       showToast(message: "Some error happened");
  //     }
  //   } else {
  //     setState(() {
  //       isSigningUp = false;
  //     });
  //     showToast(message: "Passwords do not match");
  //   }
  // }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quiz_loy/controllers/login_controller.dart';
import 'package:quiz_loy/pages/home_page.dart';
import 'package:quiz_loy/pages/toast/toast.dart';
import 'package:quiz_loy/pages/user_auth_page/sign_up_page.dart';
import 'package:quiz_loy/pages/widget/form_container_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  LoginController loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
    loginController.emailController.clear();
    loginController.passwordController.clear();
    loginController.resetPassController.clear();
    _attemptAutoLogin();
  }

  void _attemptAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (email != null && password != null) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        // Navigate to home page if login is successful
        Get.offAll(() => HomePage());
      } catch (e) {
        // Clear the stored credentials if login fails
        prefs.remove('email');
        prefs.remove('password');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 90),
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
                "Login",
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20,
              ),
              FormContainerWidget(
                controller: loginController.emailController,
                hintText: "Email",
                isPasswordField: false,
              ),
              SizedBox(
                height: 20,
              ),
              FormContainerWidget(
                controller: loginController.passwordController,
                hintText: "Password",
                isPasswordField: true,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    openDialog(context, loginController);
                  },
                  child: Text(
                    "Forgot password",
                    textAlign: TextAlign.right,
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: loginController.onLogin,
                  child: Obx(
                        () => loginController.isSigning.value
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      "Login",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    backgroundColor: Color.fromRGBO(95, 169, 239, 1),
                  ),
                ),
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
                    "Don't have an account?",
                    style: TextStyle(fontSize: 17),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(SignUpPage());
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 17),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

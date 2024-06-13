import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_rules/database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'dart:io';

import 'package:quiz_loy/pages/toast/toast.dart';
import 'package:quiz_loy/pages/user_auth_page/login_page.dart';

import 'package:get/get.dart';
import 'package:quiz_loy/pages/profile_ranking.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  User? currentUser;
  Map<String, dynamic>? userData;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get current user (auth)
  Future<void> _getCurrentUser() async {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          currentUser = user;
        });
        _fetchUserData(user.uid);
      }
    });
  }

  // Firestore
  Future<void> _fetchUserData(String userId) async {
    final db = FirebaseFirestore.instance;
    final docRef = db.collection("users").doc(userId);
    docRef.snapshots().listen(
      (event) {
        setState(() {
          userData = event.data();
        });
      },
      onError: (error) => print("Listen failed: $error"),
    );
  }

  // Image picker
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      _showConfirmationDialog(pickedImage.path);
    } else {
      print("No image picked");
    }
  }

  // Show image picker dialog
  Future<void> _showImagePickerDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chọn ảnh'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: Text('Chụp ảnh từ camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImageToStorage(File imageFile) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;

      // Ensure the file is saved as a PNG
      Reference storageRef = storage.ref().child(
          '${currentUser?.uid}_${DateTime.now().millisecondsSinceEpoch}.png');
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (error) {
      print("Error uploading image to Firebase Storage: $error");
      return '';
    }
  }

  // Update user profile picture
  Future<void> _updateUserProfilePicture(String imageUrl) async {
    try {
      final db = FirebaseFirestore.instance;
      final userRef = db.collection("users").doc(currentUser!.uid);
      await userRef.update({'photoUrl': imageUrl});
    } catch (error) {
      print("Error updating user profile picture in Firestore: $error");
    }
  }

  // Show confirmation dialog
  Future<void> _showConfirmationDialog(String imagePath) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xác nhận'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(File(imagePath)),
              Text('Bạn có muốn sử dụng ảnh này làm ảnh đại diện không?'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Hủy bỏ'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog xác nhận
                _showImagePickerDialog(); // Quay lại để người dùng chọn lại ảnh
              },
            ),
            TextButton(
              child: Text('Đồng ý'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog xác nhận
                setState(() {
                  isLoading = true; // Start loading
                });
                _uploadImageToStorage(File(imagePath)).then((downloadUrl) {
                  _updateUserProfilePicture(downloadUrl).then((_) {
                    setState(() {
                      isLoading = false; // Stop loading
                      showToast(message: "Update image successfully");
                    });
                  });
                });
              },
            ),
          ],
        );
      },
    );
  }

  //Show Name dialog
  Future<void> _showNameDialog(String name) async {
    TextEditingController nameController = TextEditingController(text: name);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String? errorMessage;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('User Name'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter new name',
                      errorText: errorMessage,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    controller: nameController,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    String changeName = nameController.text;
                    if (changeName.isEmpty) {
                      setState(() {
                        errorMessage = 'Please enter your name';
                      });
                    } else {
                      try {
                        await _updateName(changeName);
                        Navigator.of(context).pop();
                        showToast(message: "Name updated successfully");
                      } catch (error) {
                        setState(() {
                          errorMessage = error.toString();
                        });
                      } finally {}
                    }
                  },
                  child: Text(
                    'Update',
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

  Future<void> _updateName(String name) async {
    try {
      final db = FirebaseFirestore.instance;
      final userRef = db.collection("users").doc(currentUser!.uid);
      await userRef.update({'username': name});
    } catch (error) {
      throw Exception("Error updating username in Firestore: $error");
    }
  }

  Future<void> _showPassword() async {
    TextEditingController oldPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    bool isOldPasswordObscured = true;
    bool isNewPasswordObscured = true;
    bool isConfirmPasswordObscured = true;

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        String? oldPasswordError;
        String? newPasswordError;
        String? confirmPasswordError;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Change password'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter old password',
                      errorText: oldPasswordError,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(isOldPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isOldPasswordObscured = !isOldPasswordObscured;
                          });
                        },
                      ),
                    ),
                    obscureText: isOldPasswordObscured,
                    controller: oldPasswordController,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter new password',
                      errorText: newPasswordError,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(isNewPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isNewPasswordObscured = !isNewPasswordObscured;
                          });
                        },
                      ),
                    ),
                    obscureText: isNewPasswordObscured,
                    controller: newPasswordController,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      errorText: confirmPasswordError,
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(isConfirmPasswordObscured
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordObscured =
                                !isConfirmPasswordObscured;
                          });
                        },
                      ),
                    ),
                    obscureText: isConfirmPasswordObscured,
                    controller: confirmPasswordController,
                  ),
                ],
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        _forgetPass();
                        // Navigator.of(context).pop();
                      },
                      child: Text(
                        'Forget password',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        String oldPassword = oldPasswordController.text;
                        String newPassword = newPasswordController.text;
                        String confirmPassword = confirmPasswordController.text;

                        setState(() {
                          oldPasswordError = oldPassword.isEmpty
                              ? 'Old password cannot be empty'
                              : null;
                          newPasswordError = newPassword.isEmpty
                              ? 'New password cannot be empty'
                              : newPassword.length < 8
                                  ? 'Password must be at least 8 characters'
                                  : null;
                          confirmPasswordError = confirmPassword.isEmpty
                              ? 'Confirm password cannot be empty'
                              : confirmPassword != newPassword
                                  ? 'New passwords do not match'
                                  : null;
                        });

                        if (oldPasswordError == null &&
                            newPasswordError == null &&
                            confirmPasswordError == null) {
                          User? user = FirebaseAuth.instance.currentUser;

                          if (user != null) {
                            try {
                              // Reauthenticate user
                              AuthCredential credential =
                                  EmailAuthProvider.credential(
                                email: user.email!,
                                password: oldPassword,
                              );
                              await user
                                  .reauthenticateWithCredential(credential);

                              // Update password
                              await user.updatePassword(newPassword);
                              setState(() {
                                oldPasswordError = null;
                                newPasswordError = null;
                                confirmPasswordError = null;
                              });
                              Navigator.of(context).pop();
                              showToast(
                                  message: 'Update password successfully');
                            } catch (e) {
                              setState(() {
                                oldPasswordError =
                                    'Failed to change password: ${e.toString()}';
                                showToast(
                                    message:
                                        'Failed to change password: ${e.toString()}');
                              });
                            }
                          } else {
                            setState(() {
                              oldPasswordError = 'Please fill in all fields';
                            });
                          }
                        }
                      },
                      child: Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  //Forget Password
  Future<void> _forgetPass() async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: userData!['email']);
    showToast(message: 'Please check your email');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SafeArea(
          child: Stack(
            children: [
              ListView(
                children: [
                  // User card
                  if (userData != null)
                    BigUserCard(
                      backgroundColor: Colors.blue,
                      userName: userData!['username'] ?? "Unknown User",
                      userMoreInfo: Text(userData!['email'] ?? "No email"),
                      userProfilePic: userData!['photoUrl'] != null
                          ? NetworkImage(userData!['photoUrl'])
                          : AssetImage("assets/images/img.jpg")
                              as ImageProvider,
                      cardActionWidget: SettingsItem(
                        icons: Icons.edit,
                        iconStyle: IconStyle(
                          withBackground: true,
                          borderRadius: 50,
                          backgroundColor: Colors.yellow[600],
                        ),
                        title: "Thay đổi ảnh đại diện",
                        subtitle: "Tap to change your avatar",
                        onTap: () {
                          _showImagePickerDialog();
                        },
                      ),
                    )
                  else
                    Center(
                        child:
                            CircularProgressIndicator()), // Show a loading indicator while fetching data
                  SettingsGroup(
                    settingsGroupTitle: "Account",
                    items: [
                      SettingsItem(
                        icons: Icons.email,
                        title: "Email",
                        subtitle: userData?['email'] ?? "No email",
                      ),
                      SettingsItem(
                        onTap: () {
                          _showNameDialog(userData?['username']);
                        },
                        icons: Icons.person,
                        title: "Tên người dùng",
                        subtitle: userData?['username'] ?? "No username",
                      ),
                      SettingsItem(
                        onTap: () {
                          _showPassword();
                        },
                        icons: Icons.password,
                        title: "Đổi mật khẩu",
                      ),
                      SettingsItem(
                        onTap: () {
                          Get.to(ProfileRanking());
                        },
                        icons: Icons.star_half,
                        title: "Thành tích",
                      ),
                      SettingsItem(
                        onTap: () async {
                          // Clear the saved email and password from SharedPreferences
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('email');
                          await prefs.remove('password');

                          // Sign out the user from Firebase Auth
                          await FirebaseAuth.instance.signOut();

                          // Navigate to the LoginPage
                          Get.offAll(() => LoginPage());
                        },
                        icons: Icons.exit_to_app_rounded,
                        title: "Sign Out",
                      ),

                      SettingsItem(
                        onTap: () {},
                        icons: Icons.info_rounded,
                        iconStyle: IconStyle(
                          backgroundColor: Colors.purple,
                        ),
                        title: 'Về chúng tôi',
                        subtitle: "QuizLoy App",
                      ),
                    ],
                  ),
                ],
              ),
              if (isLoading)
                Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

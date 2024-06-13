import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetworkController extends GetxController {
  final Connectivity connectivity = Connectivity();
  var isConnected = false.obs;

  @override
  void onInit() {
    super.onInit();
    connectivity.onConnectivityChanged.listen(updateConnectionStatus);
    checkInitialConnection();
  }

  void updateConnectionStatus(ConnectivityResult connectivityResult) {
    isConnected.value = connectivityResult != ConnectivityResult.none;
    if (!isConnected.value) {
      Get.rawSnackbar(
        messageText: const Text(
          'Vui lòng kết nối mạng',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: Colors.red[400]!,
        icon: Padding(
          padding: const EdgeInsets.only(right: 10, left: 10),
          child: const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 35,
          ),
        ),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
        snackPosition: SnackPosition.TOP,
      );
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }

  Future<void> checkInitialConnection() async {
    var connectivityResult = await connectivity.checkConnectivity();
    updateConnectionStatus(connectivityResult);
  }
}

import 'package:get/get.dart';
import 'package:quiz_loy/controllers/network_controller.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}

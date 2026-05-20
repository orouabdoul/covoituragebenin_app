import 'package:get/get.dart';

import '../controller/messager_controller.dart';

class MessagerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MessagerController>()) {
      Get.lazyPut<MessagerController>(() => MessagerController());
    }
  }
}
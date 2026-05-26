import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class DriverHomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DriverHomeController>()) {
      Get.lazyPut<DriverHomeController>(() => DriverHomeController());
    }
  }
}

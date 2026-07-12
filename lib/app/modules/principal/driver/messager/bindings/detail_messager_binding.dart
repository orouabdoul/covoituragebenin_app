import 'package:get/get.dart';

import '../controllers/detail_messager_controller.dart';

class DetailMessagerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DriverDetailMessagerController>()) {
      Get.lazyPut<DriverDetailMessagerController>(() => DriverDetailMessagerController());
    }
  }
}
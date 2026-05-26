import 'package:get/get.dart';

import '../controllers/add_trajet_controller.dart';

class AddTrajetBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddTrajetController>()) {
      Get.lazyPut<AddTrajetController>(() => AddTrajetController());
    }
  }
}

import 'package:get/get.dart';

import '../controller/profil_driver_controller.dart';

class ProfilDriverBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DriverProfileController>()) {
      Get.lazyPut<DriverProfileController>(() => DriverProfileController());
    }
  }
}

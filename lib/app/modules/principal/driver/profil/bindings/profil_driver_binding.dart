import 'package:get/get.dart';

import '../controllers/profil_driver_controller.dart';

class ProfilDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileController>(() => DriverProfileController(), fenix: true);
  }
}

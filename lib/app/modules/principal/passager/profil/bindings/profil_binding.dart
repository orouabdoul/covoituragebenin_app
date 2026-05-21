import 'package:get/get.dart';

import '../controllers/profil_controller.dart';

class ProfilBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ProfilController>()) {
      Get.lazyPut<ProfilController>(() => ProfilController());
    }
  }
}
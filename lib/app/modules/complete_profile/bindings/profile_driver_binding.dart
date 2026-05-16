import 'package:get/get.dart';

import '../controllers/profile_driver_controller.dart';

class ProfileDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileDriverController>(() => ProfileDriverController());
  }
}
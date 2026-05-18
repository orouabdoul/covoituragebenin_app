import 'package:get/get.dart';

import '../controllers/profile_passager_controller.dart';

class ProfilePassagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfilePassagerController>(() => ProfilePassagerController());
  }
}
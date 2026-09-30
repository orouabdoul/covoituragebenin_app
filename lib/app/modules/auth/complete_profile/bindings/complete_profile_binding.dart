import 'package:get/get.dart';

import '../controllers/complete_profile_controller.dart';

class CompleteProfileBinding extends Bindings {
  @override
  void dependencies() {
    final isDriver = Get.currentRoute.contains('driver');
    Get.lazyPut<CompleteProfileController>(
      () => CompleteProfileController(isDriver: isDriver),
    );
  }
}

import 'package:get/get.dart';

import '../controllers/complete_profile_controller.dart';

class CompleteProfileBinding extends Bindings {
  CompleteProfileBinding({required this.isDriver});

  final bool isDriver;

  @override
  void dependencies() {
    Get.delete<CompleteProfileController>(force: true);
    Get.lazyPut<CompleteProfileController>(
      () => CompleteProfileController(isDriver: isDriver),
      fenix: true,
    );
  }
}

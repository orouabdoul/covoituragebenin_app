import 'package:get/get.dart';

import '../controllers/input_phone_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InputPhoneController>(() => InputPhoneController());
  }
}
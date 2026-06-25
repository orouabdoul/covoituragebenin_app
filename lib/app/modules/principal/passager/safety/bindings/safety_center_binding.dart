import 'package:get/get.dart';
import '../controllers/safety_center_controller.dart';

class SafetyCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SafetyCenterController>(() => SafetyCenterController());
  }
}

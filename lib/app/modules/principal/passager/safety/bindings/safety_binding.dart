import 'package:get/get.dart';
import '../controllers/safety_controller.dart';

class SafetyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SafetyController>(() => SafetyController());
  }
}

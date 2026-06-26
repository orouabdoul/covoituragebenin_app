import 'package:get/get.dart';
import '../controllers/driver_safety_controller.dart';

class DriverSafetyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverSafetyController>(() => DriverSafetyController());
  }
}

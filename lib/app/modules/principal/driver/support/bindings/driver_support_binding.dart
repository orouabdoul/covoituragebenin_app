import 'package:get/get.dart';
import '../controllers/driver_support_controller.dart';

class DriverSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverSupportController>(() => DriverSupportController());
  }
}

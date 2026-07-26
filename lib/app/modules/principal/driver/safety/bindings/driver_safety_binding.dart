import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/safety/safety_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/safety/safety_service_impl.dart';
import '../controllers/driver_safety_controller.dart';

class DriverSafetyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SafetyService>(() => SafetyServiceImpl());
    Get.lazyPut<DriverSafetyController>(() => DriverSafetyController());
  }
}

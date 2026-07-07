import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/safety/passenger_safety_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/safety/passenger_safety_service_impl.dart';
import '../controllers/safety_center_controller.dart';

class SafetyCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerSafetyService>(
        () => PassengerSafetyServiceImpl(), fenix: true);
    Get.lazyPut<SafetyCenterController>(
        () => SafetyCenterController(), fenix: true);
  }
}

import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/profile/driver_profile_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/profile/driver_profile_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/safety/safety_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/safety/safety_service_impl.dart';
import '../controllers/profil_driver_controller.dart';

class ProfilDriverBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverProfileService>(() => DriverProfileServiceImpl(), fenix: true);
    Get.lazyPut<SafetyService>(() => SafetyServiceImpl(), fenix: true);
    Get.lazyPut<DriverProfileController>(() => DriverProfileController(), fenix: true);
  }
}

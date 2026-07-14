import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/profile/passenger_profile_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/profile/passenger_profile_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/safety/passenger_safety_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/safety/passenger_safety_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/stats/passenger_stats_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/stats/passenger_stats_service_impl.dart';
import '../controllers/profil_controller.dart';

class ProfilBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerProfileService>(
      () => PassengerProfileServiceImpl(),
      fenix: true,
    );
    Get.lazyPut<PassengerStatsService>(
      () => PassengerStatsServiceImpl(),
      fenix: true,
    );
    Get.lazyPut<PassengerSafetyService>(
      () => PassengerSafetyServiceImpl(),
      fenix: true,
    );
    Get.lazyPut<ProfilController>(
      () => ProfilController(Get.find<PassengerProfileService>()),
      fenix: true,
    );
  }
}

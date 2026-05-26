import 'package:get/get.dart';

import '../controllers/reservations_controller.dart';

class ReservationsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReservationsController>()) {
      Get.lazyPut<ReservationsController>(() => ReservationsController());
    }
  }
}

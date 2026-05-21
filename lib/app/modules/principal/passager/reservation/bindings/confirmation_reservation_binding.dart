import 'package:get/get.dart';

import '../controllers/confirmation_reservation_controller.dart';

class ConfirmationReservationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConfirmationReservationController>()) {
      Get.lazyPut<ConfirmationReservationController>(() => ConfirmationReservationController());
    }
  }
}

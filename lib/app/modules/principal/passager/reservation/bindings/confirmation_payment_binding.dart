import 'package:get/get.dart';

import '../controllers/confirmation_reservation_controller.dart';

class ConfirmationPaymentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ConfirmationReservationController>()) {
      Get.lazyPut<ConfirmationReservationController>(() => ConfirmationReservationController());
    }
  }
}
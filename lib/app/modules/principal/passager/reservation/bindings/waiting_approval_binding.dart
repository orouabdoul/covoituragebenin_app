import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service_impl.dart';
import '../controllers/waiting_approval_controller.dart';

class WaitingApprovalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerReservationService>(
        () => PassengerReservationServiceImpl(), fenix: true);
    Get.lazyPut<WaitingApprovalController>(
        () => WaitingApprovalController(), fenix: true);
  }
}

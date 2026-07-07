import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service_impl.dart';
import '../controllers/payment_success_controller.dart';

class PaymentSuccessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerReservationService>(
        () => PassengerReservationServiceImpl(), fenix: true);
    Get.lazyPut<PaymentSuccessController>(
        () => PaymentSuccessController(), fenix: true);
  }
}

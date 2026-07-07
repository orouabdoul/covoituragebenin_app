import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service_impl.dart';
import '../controllers/detail_reservation_controller.dart';

class DetailReservationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerReservationService>(
        () => PassengerReservationServiceImpl(), fenix: true);
    Get.lazyPut<DetailReservationController>(
        () => DetailReservationController(), fenix: true);
  }
}

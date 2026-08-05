import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service_impl.dart';
import '../controllers/live_tracking_controller.dart';

class LiveTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerReservationService>(
        () => PassengerReservationServiceImpl(), fenix: true);
    if (!Get.isRegistered<PassengerMessagingService>()) {
      Get.lazyPut<PassengerMessagingService>(
          () => PassengerMessagingServiceImpl(), fenix: true);
    }
    Get.lazyPut<LiveTrackingController>(
        () => LiveTrackingController(), fenix: true);
  }
}

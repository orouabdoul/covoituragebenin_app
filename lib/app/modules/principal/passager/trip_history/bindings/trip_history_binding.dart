import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/trips/passenger_trips_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/trips/passenger_trips_service_impl.dart';
import '../controllers/trip_history_controller.dart';

class TripHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerTripsService>(
        () => PassengerTripsServiceImpl(), fenix: true);
    Get.lazyPut<TripHistoryController>(
        () => TripHistoryController(), fenix: true);
  }
}

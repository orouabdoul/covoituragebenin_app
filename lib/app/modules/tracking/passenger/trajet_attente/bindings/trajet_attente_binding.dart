import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service.dart';
import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service_impl.dart';
import '../controllers/trajet_attente_controller.dart';

class TrajetAttenteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackingService>(() => TrackingServiceImpl(), fenix: true);
    Get.lazyPut<TrajetAttenteController>(() => TrajetAttenteController(), fenix: true);
  }
}

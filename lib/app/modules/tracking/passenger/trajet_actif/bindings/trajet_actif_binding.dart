import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service.dart';
import 'package:covoiturage_benin_app/app/core/services/tracking/tracking_service_impl.dart';
import '../controllers/trajet_actif_controller.dart';

class TrajetActifBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrackingService>(() => TrackingServiceImpl(), fenix: true);
    Get.lazyPut<TrajetActifController>(() => TrajetActifController(), fenix: true);
  }
}

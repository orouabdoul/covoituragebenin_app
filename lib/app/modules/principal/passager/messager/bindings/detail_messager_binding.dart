import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service_impl.dart';
import '../controllers/detail_messager_controller.dart';

class DetailMessagerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PassengerMessagingService>()) {
      Get.lazyPut<PassengerMessagingService>(
        () => PassengerMessagingServiceImpl(),
        fenix: true,
      );
    }
    Get.lazyPut<DetailMessagerController>(() => DetailMessagerController(), fenix: true);
  }
}

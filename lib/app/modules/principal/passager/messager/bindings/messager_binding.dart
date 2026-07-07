import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/messaging/passenger_messaging_service_impl.dart';
import '../controllers/messager_controller.dart';

class MessagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerMessagingService>(
      () => PassengerMessagingServiceImpl(),
      fenix: true,
    );
    Get.lazyPut<MessagerController>(() => MessagerController(), fenix: true);
  }
}

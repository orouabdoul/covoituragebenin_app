import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/messaging/messaging_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/messaging/messaging_service_impl.dart';
import '../controllers/detail_messager_controller.dart';

class DetailMessagerBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MessagingService>()) {
      Get.lazyPut<MessagingService>(() => MessagingServiceImpl(), fenix: true);
    }
    if (!Get.isRegistered<DriverDetailMessagerController>()) {
      Get.lazyPut<DriverDetailMessagerController>(() => DriverDetailMessagerController());
    }
  }
}
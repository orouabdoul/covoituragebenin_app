import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/home/home_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/home/home_service_impl.dart';
import '../controllers/home_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerHomeService>(
      () => PassengerHomeServiceImpl(),
      fenix: true,
    );
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<PassengerHomeService>()),
      fenix: true,
    );
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
      fenix: true,
    );
  }
}

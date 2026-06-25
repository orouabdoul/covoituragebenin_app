import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<HomeController>()) {
      Get.lazyPut<HomeController>(() => HomeController());
    }
    Get.lazyPut<NotificationsController>(() => NotificationsController(), fenix: true);
  }
}

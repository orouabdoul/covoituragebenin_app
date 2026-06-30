import 'package:get/get.dart';

import '../controller/home_controller.dart';
import '../../notifications/controllers/notifications_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);
    Get.lazyPut<NotificationsController>(() => NotificationsController(), fenix: true);
  }
}

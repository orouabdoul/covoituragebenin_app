import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/notifications/passenger_notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/notifications/passenger_notifications_service_impl.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerNotificationsService>(
      () => PassengerNotificationsServiceImpl(),
      fenix: true,
    );
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(),
      fenix: true,
    );
  }
}

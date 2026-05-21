import 'package:get/get.dart';
import '../controllers/detail_reservation_controller.dart';

class DetailReservationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DetailReservationController>()) {
      Get.lazyPut<DetailReservationController>(() => DetailReservationController());
    }
  }
}

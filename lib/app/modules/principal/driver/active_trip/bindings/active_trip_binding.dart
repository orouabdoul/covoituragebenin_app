import 'package:get/get.dart';
import '../controllers/active_trip_controller.dart';

class ActiveTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ActiveTripController>(() => ActiveTripController());
  }
}

import 'package:get/get.dart';
import '../controllers/end_trip_controller.dart';

class EndTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EndTripController>(() => EndTripController());
  }
}

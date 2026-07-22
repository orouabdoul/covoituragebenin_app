import 'package:get/get.dart';
import '../controllers/running_trip_controller.dart';

class RunningTripBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RunningTripController>(() => RunningTripController());
  }
}

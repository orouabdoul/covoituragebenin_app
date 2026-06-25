import 'package:get/get.dart';
import '../controllers/driver_arrival_controller.dart';

class DriverArrivalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DriverArrivalController>(() => DriverArrivalController());
  }
}

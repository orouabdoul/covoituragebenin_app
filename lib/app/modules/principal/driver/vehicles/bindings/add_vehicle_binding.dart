import 'package:get/get.dart';

import '../controllers/add_vehicle_controller.dart';

class AddVehicleBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AddVehicleController>()) {
      Get.lazyPut<AddVehicleController>(() => AddVehicleController());
    }
  }
}

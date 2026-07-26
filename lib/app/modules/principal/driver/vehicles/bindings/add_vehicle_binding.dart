import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/vehicles/vehicles_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/vehicles/vehicles_service_impl.dart';
import '../controllers/add_vehicle_controller.dart';

class AddVehicleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VehiclesService>(() => VehiclesServiceImpl());
    Get.lazyPut<AddVehicleController>(() => AddVehicleController());
  }
}

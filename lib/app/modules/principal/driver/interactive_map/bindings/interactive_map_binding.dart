import 'package:get/get.dart';
import '../controllers/interactive_map_controller.dart';

class InteractiveMapBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InteractiveMapController>(() => InteractiveMapController());
  }
}

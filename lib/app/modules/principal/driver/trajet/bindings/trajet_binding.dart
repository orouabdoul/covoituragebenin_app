import 'package:get/get.dart';

import '../controller/trajet_controller.dart';

class TrajetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrajetController>(() => TrajetController());
  }
}
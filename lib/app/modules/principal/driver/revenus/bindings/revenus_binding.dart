import 'package:get/get.dart';

import '../controllers/revenus_controller.dart';

class RevenusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RevenusController>(() => RevenusController());
  }
}

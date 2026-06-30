import 'package:get/get.dart';

import '../controllers/messager_controller.dart';

class MessagerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessagerController>(() => MessagerController(), fenix: true);
  }
}
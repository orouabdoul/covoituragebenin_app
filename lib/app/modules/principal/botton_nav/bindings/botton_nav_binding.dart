import 'package:get/get.dart';

import '../controllers/botton_nav_controller.dart';
import '../controllers/botton_nav_role.dart';

class BottonNavBinding extends Bindings {
  BottonNavBinding({required this.role});

  final BottonNavRole role;

  @override
  void dependencies() {
    Get.lazyPut<BottonNavController>(() => BottonNavController(role: role));
  }
}

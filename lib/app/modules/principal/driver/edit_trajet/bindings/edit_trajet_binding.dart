import 'package:get/get.dart';

import '../controllers/edit_trajet_controller.dart';

class EditTrajetBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditTrajetController>(() => EditTrajetController());
  }
}

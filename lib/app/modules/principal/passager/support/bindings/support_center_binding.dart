import 'package:get/get.dart';
import '../controllers/support_center_controller.dart';

class SupportCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportCenterController>(() => SupportCenterController());
  }
}

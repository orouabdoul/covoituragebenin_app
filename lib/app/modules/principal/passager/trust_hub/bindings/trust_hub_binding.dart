import 'package:get/get.dart';
import '../controllers/trust_hub_controller.dart';

class TrustHubBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrustHubController>(() => TrustHubController());
  }
}

import 'package:get/get.dart';
import '../controllers/refund_request_controller.dart';

class RefundRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RefundRequestController>(() => RefundRequestController());
  }
}

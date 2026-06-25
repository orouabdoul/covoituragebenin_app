import 'package:get/get.dart';
import '../controllers/refund_history_controller.dart';

class RefundHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RefundHistoryController>(() => RefundHistoryController());
  }
}

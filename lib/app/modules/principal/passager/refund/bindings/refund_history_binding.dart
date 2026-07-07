import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/refund/passenger_refund_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/refund/passenger_refund_service_impl.dart';
import '../controllers/refund_history_controller.dart';

class RefundHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerRefundService>(
        () => PassengerRefundServiceImpl(), fenix: true);
    Get.lazyPut<RefundHistoryController>(
        () => RefundHistoryController(), fenix: true);
  }
}

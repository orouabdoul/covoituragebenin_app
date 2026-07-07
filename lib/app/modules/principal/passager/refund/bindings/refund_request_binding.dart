import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/refund/passenger_refund_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/refund/passenger_refund_service_impl.dart';
import '../controllers/refund_request_controller.dart';

class RefundRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerRefundService>(
        () => PassengerRefundServiceImpl(), fenix: true);
    Get.lazyPut<RefundRequestController>(
        () => RefundRequestController(), fenix: true);
  }
}

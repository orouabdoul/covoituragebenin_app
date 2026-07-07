import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/support/passenger_support_service.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/support/passenger_support_service_impl.dart';
import '../controllers/support_center_controller.dart';

class SupportCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerSupportService>(
        () => PassengerSupportServiceImpl(), fenix: true);
    Get.lazyPut<SupportCenterController>(() => SupportCenterController(),
        fenix: true);
  }
}

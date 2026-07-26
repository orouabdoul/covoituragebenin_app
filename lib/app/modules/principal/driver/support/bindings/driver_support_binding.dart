import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/support/support_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/support/support_service_impl.dart';
import '../controllers/driver_support_controller.dart';

class DriverSupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportService>(() => SupportServiceImpl());
    Get.lazyPut<DriverSupportController>(() => DriverSupportController());
  }
}

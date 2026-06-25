import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class TrustHubController extends GetxController {
  void goToSafety() => Get.toNamed(AppRoutes.passengerSafetyCenter);
  void goToSupport() => Get.toNamed(AppRoutes.passengerSupportCenter);
  void goToRefund() => Get.toNamed(AppRoutes.passengerRefundRequest);
}

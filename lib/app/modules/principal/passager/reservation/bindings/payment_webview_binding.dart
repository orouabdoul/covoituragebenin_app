import 'package:get/get.dart';

import '../controllers/payment_webview_controller.dart';

class PaymentWebviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentWebviewController>(
        () => PaymentWebviewController(), fenix: true);
  }
}

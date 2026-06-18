import 'package:get/get.dart';

class LoadingController extends GetxController {
  static LoadingController instance = Get.find();
  final RxBool isLoading = false.obs;
  final RxString message = ''.obs;

  void showLoading({String message = ''}) {
    isLoading.value = true;
    this.message.value = message;
  }

  void hideLoading() {
    isLoading.value = false;
    message.value = '';
  }
}
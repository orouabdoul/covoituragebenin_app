import 'dart:async';

import 'package:get/get.dart';

class OtpCodeController extends GetxController {
  static const int _initialResendSeconds = 55;

  final RxString phoneNumber = ''.obs;
  final RxString enteredCode = ''.obs;
  final RxInt resendSeconds = _initialResendSeconds.obs;

  Timer? _timer;

  bool get canVerify => enteredCode.value.length == 6;

  bool get canResend => resendSeconds.value == 0;

  @override
  void onInit() {
    super.onInit();
    final Object? argument = Get.arguments;
    if (argument is String && argument.trim().isNotEmpty) {
      phoneNumber.value = argument.trim();
    }
    _startResendTimer();
  }

  void onCodeChanged(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    enteredCode.value = digits.length > 6 ? digits.substring(0, 6) : digits;
    update();
  }

  void verifyCode() {
    if (!canVerify) {
      Get.snackbar('MINIZON', 'Saisissez le code complet.');
      return;
    }

    Get.snackbar('MINIZON', 'Code vérifié avec succès.');
  }

  void resendCode() {
    if (!canResend) {
      return;
    }

    resendSeconds.value = _initialResendSeconds;
    _startResendTimer();
    update();
    Get.snackbar('MINIZON', 'Nouveau code envoyé.');
  }

  void _startResendTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendSeconds.value == 0) {
        timer.cancel();
        update();
        return;
      }
      resendSeconds.value = resendSeconds.value - 1;
      update();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
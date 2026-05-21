import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class InputPhoneController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedCountry = 'Bénin (+229)'.obs;
  final RxBool canContinueRx = false.obs;

  bool get canContinue => phoneController.text.trim().isNotEmpty;

  void onPhoneChanged(String value) {
    canContinueRx.value = value.trim().isNotEmpty;
  }

  void continueWithPhone() {
    if (!canContinue) {
      Get.snackbar('MINIZON', 'Entrez votre numéro de téléphone.');
      return;
    }
    Get.toNamed(AppRoutes.otpCode, arguments: phoneController.text.trim());
  }

  void continueWithEmail() {
    Get.snackbar('MINIZON', 'Connexion par email bientôt disponible.');
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}

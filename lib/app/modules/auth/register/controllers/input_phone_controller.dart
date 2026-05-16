import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class InputPhoneController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedCountry = 'Bénin (+229)'.obs;

  bool get canContinue => phoneController.text.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    phoneController.addListener(update);
  }

  void continueWithPhone() {
    if (!canContinue) {
      Get.snackbar('MINIZON', 'Entrez votre numéro de téléphone.');
      return;
    }
    Get.toNamed(
       '/otp-code',
      arguments: phoneController.text.trim(),
    );
  }

  void continueWithEmail() {
    Get.snackbar('MINIZON', 'Connexion par email bientôt disponible.');
  }

  @override
  void onClose() {
    phoneController
      ..removeListener(update)
      ..dispose();
    super.onClose();
  }
}
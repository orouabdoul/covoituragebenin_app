import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/auth_mode.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/auth/roles/controllers/roles_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class InputPhoneController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedCountry = 'Bénin (+229)'.obs;
  final RxBool canContinueRx = false.obs;
  final RxBool isLoading = false.obs;

  RoleType? _role;
  AuthMode _mode = AuthMode.register;

  bool get canContinue => phoneController.text.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map) {
      _role = arg['role'] as RoleType?;
      _mode = arg['mode'] as AuthMode? ?? AuthMode.register;
    }
  }

  void onPhoneChanged(String value) {
    canContinueRx.value = value.trim().isNotEmpty;
  }

  Future<void> continueWithPhone() async {
    if (!canContinue) {
      UIHelper().showSnackBar('MINIZON', 'Entrez votre numéro de téléphone.', 2);
      return;
    }

    final rawPhone = phoneController.text.trim();
    final phone = rawPhone.startsWith('+') ? rawPhone : '+229$rawPhone';

    isLoading.value = true;
    final result = await Get.find<AuthService>().sendOtp(phone: phone);
    isLoading.value = false;

    if (result.isSuccess) {
      Get.toNamed(
        AppRoutes.otpCode,
        arguments: {
          'phone': phone,
          'role': _role,
          'mode': _mode,
          'testOtp': result.data,
        },
      );
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  void continueWithEmail() {
    UIHelper().showSnackBar('MINIZON', 'Connexion par email bientôt disponible.', 1);
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }
}

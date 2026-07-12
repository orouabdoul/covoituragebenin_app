import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/auth_mode.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
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

  bool get canContinue {
    final v = phoneController.text.trim();
    return v.length == 10 && v.startsWith('01');
  }

  @override
  void onInit() {
    super.onInit();
    phoneController.text = '01';
    phoneController.selection = TextSelection.collapsed(offset: 2);
    final arg = Get.arguments;
    if (arg is Map) {
      _role = arg['role'] as RoleType?;
      _mode = arg['mode'] as AuthMode? ?? AuthMode.register;
    }
  }

  void onPhoneChanged(String value) {
    canContinueRx.value = value.trim().length == 10 && value.trim().startsWith('01');
  }

  Future<void> continueWithPhone() async {
    final rawPhone = phoneController.text.trim();
    if (rawPhone.length != 10 || !rawPhone.startsWith('01')) {
      UIHelper().showSnackBar('MINIZON', 'Le numéro doit commencer par 01 et contenir 10 chiffres.', 2);
      return;
    }

    final phone = '+229$rawPhone';

    isLoading.value = true;
    final result = await Get.find<AuthService>().sendOtp(phone: phone);
    isLoading.value = false;

    if (result.isSuccess) {
      final data = result.data!;
      if (data.alreadyActive) {
        UIHelper().showSnackBar(
          'MINIZON',
          'Un code a déjà été envoyé. Vérifiez vos SMS.',
          1,
        );
      }
      Get.toNamed(
        AppRoutes.otpCode,
        arguments: {
          'phone': phone,
          'role': _role,
          'mode': _mode,
          'testOtp': data.otpCode,
          'resendIn': data.resendIn,
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

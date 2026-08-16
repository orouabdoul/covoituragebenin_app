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

  // Préfixes ARCEP officiels Bénin (format 10 chiffres depuis nov. 2024)
  // MTN: 42,46,50-54,56,57,59,61,62,66,67,69,90,91,96,97
  // Moov: 45,55,58,60,63-65,68,94,95,98,99
  // Celtiis: 20-24,28,29,40,41,43,44,47-49,92,93
  static final _beninPhoneRegex = RegExp(r'^01(2[0-4289]|[4-6]\d|9\d)\d{6}$');

  bool get canContinue {
    final v = phoneController.text.trim();
    return _beninPhoneRegex.hasMatch(v);
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
      final existingPhone = arg['phone'] as String? ?? '';
      if (existingPhone.length >= 4) {
        phoneController.text = existingPhone;
        phoneController.selection =
            TextSelection.collapsed(offset: existingPhone.length);
        canContinueRx.value = _beninPhoneRegex.hasMatch(existingPhone);
      }
    }
  }

  void onPhoneChanged(String value) {
    canContinueRx.value = _beninPhoneRegex.hasMatch(value.trim());
  }

  Future<void> continueWithPhone() async {
    final rawPhone = phoneController.text.trim();
    if (!_beninPhoneRegex.hasMatch(rawPhone)) {
      UIHelper().showSnackBar('MINIZON', 'Numéro invalide. Vérifiez le format (ex: 0197XXXXXX).', 2);
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

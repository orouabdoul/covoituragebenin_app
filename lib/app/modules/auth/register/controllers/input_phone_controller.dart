import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/auth_mode.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/auth/roles/controllers/roles_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class _Country {
  final String flag;
  final String name;
  final String dialCode;
  const _Country(this.flag, this.name, this.dialCode);
}

class InputPhoneController extends GetxController {
  final TextEditingController phoneController = TextEditingController();
  final RxString selectedCountryName = 'Bénin'.obs;
  final RxString selectedCountryFlag = '🇧🇯'.obs;
  final RxString selectedCountryDisplay = 'Bénin (+229)'.obs;
  final RxBool canContinueRx = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasStartedTyping = false.obs;
  final RxBool condStartsWith01 = false.obs;
  final RxBool condLength = false.obs;
  final RxBool condPrefix = false.obs;

  static final _prefixRegex = RegExp(r'^01(2[0-4289]|[4-6]\d|9\d)');

  static const _countries = [
    _Country('🇧🇯', 'Bénin', '+229'),
    _Country('🇳🇬', 'Nigeria', '+234'),
    _Country('🇹🇬', 'Togo', '+228'),
    _Country('🇬🇭', 'Ghana', '+233'),
    _Country('🇨🇮', 'Côte d\'Ivoire', '+225'),
    _Country('🇸🇳', 'Sénégal', '+221'),
    _Country('🇲🇱', 'Mali', '+223'),
    _Country('🇧🇫', 'Burkina Faso', '+226'),
    _Country('🇳🇪', 'Niger', '+227'),
    _Country('🇨🇲', 'Cameroun', '+237'),
    _Country('🇫🇷', 'France', '+33'),
  ];

  void selectCountry() {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Sélectionner un pays', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _countries.length,
                itemBuilder: (_, i) {
                  final c = _countries[i];
                  return ListTile(
                    leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                    title: Text(c.name),
                    trailing: Text(c.dialCode, style: const TextStyle(color: Colors.grey)),
                    onTap: () {
                      selectedCountryName.value = c.name;
                      selectedCountryFlag.value = c.flag;
                      selectedCountryDisplay.value = '${c.name} (${c.dialCode})';
                      Get.back();
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

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
    final v = value.trim();
    hasStartedTyping.value = v.length > 2;
    condStartsWith01.value = v.startsWith('01');
    condLength.value = v.length == 10;
    condPrefix.value = _prefixRegex.hasMatch(v);
    canContinueRx.value = _beninPhoneRegex.hasMatch(v);
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

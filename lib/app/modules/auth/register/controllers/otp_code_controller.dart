import 'dart:async';

import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/auth_mode.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/auth/roles/controllers/roles_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class OtpCodeController extends GetxController {
  static const int _initialResendSeconds = 210; // 3min 30s

  final RxString phoneNumber = ''.obs;
  final RxString enteredCode = ''.obs;
  final RxInt resendSeconds = _initialResendSeconds.obs;
  final RxBool isLoading = false.obs;
  final RxString testOtpCode = ''.obs;

  Timer? _timer;
  RoleType? _role;
  AuthMode _mode = AuthMode.register;

  bool get canVerify => enteredCode.value.length == 6;
  bool get canResend => resendSeconds.value == 0;

  String get formattedResendTime {
    final m = resendSeconds.value ~/ 60;
    final s = resendSeconds.value % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is Map) {
      final phone = arg['phone'] as String?;
      if (phone != null && phone.isNotEmpty) phoneNumber.value = phone;
      _role = arg['role'] as RoleType?;
      _mode = arg['mode'] as AuthMode? ?? AuthMode.register;
      final otp = arg['testOtp'] as String?;
      if (otp != null && otp.isNotEmpty) testOtpCode.value = otp;
      final resendIn = arg['resendIn'] as int?;
      if (resendIn != null && resendIn > 0) resendSeconds.value = resendIn;
    } else if (arg is String && arg.trim().isNotEmpty) {
      phoneNumber.value = arg.trim();
    }
    _startResendTimer();
  }

  void onCodeChanged(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    enteredCode.value = digits.length > 6 ? digits.substring(0, 6) : digits;
    update();
    if (canVerify) verifyCode();
  }

  Future<void> verifyCode() async {
    if (isLoading.value) return;
    if (!canVerify) {
      UIHelper().showSnackBar('MINIZON', 'Saisissez le code complet.', 2);
      return;
    }

    isLoading.value = true;
    update();
    final result = await Get.find<AuthService>().verifyOtp(
      phone: phoneNumber.value,
      otpCode: enteredCode.value,
    );
    isLoading.value = false;
    update();

    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      return;
    }

    final auth = result.data!;
    final uc = UserController.instance;

    // Déterminer le rôle : préférer le choix local (plus fiable que le serveur
    // qui assigne "passenger" par défaut lors de la création de compte).
    final chosenRole = _role == RoleType.driver ? 'driver' : 'passenger';
    final effectiveRole = (_mode == AuthMode.register && _role != null)
        ? chosenRole
        : auth.user.role;

    await uc.setUserAndToken(
      auth.user,
      auth.token,
      isProfileComplete: auth.profileComplete,
    );
    uc.setRole(effectiveRole);

    // Envoyer le rôle au serveur lors d'une inscription (correction du défaut "passenger")
    if (_mode == AuthMode.register && _role != null) {
      // Appel non-bloquant : la navigation ne dépend pas du résultat
      Get.find<AuthService>()
          .setUserRole(effectiveRole)
          .then((r) {
        if (!r.isSuccess) {
          // Échec ignoré silencieusement — le rôle local est déjà correct
        }
      });
    }

    _navigateAfterAuth(auth.profileComplete, effectiveRole);
  }

  void _navigateAfterAuth(bool profileComplete, String role) {
    final bool isDriver = role == 'driver' || role == 'conducteur';

    if (profileComplete) {
      Get.offAllNamed(
        isDriver ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger,
      );
      return;
    }

    // Profil incomplet → aller directement à l'écran de complétion
    // sans repasser par /roles (le rôle est déjà connu).
    if (_role != null) {
      Get.offAllNamed(
        isDriver
            ? AppRoutes.completeProfileDriver
            : AppRoutes.completeProfilePassenger,
      );
      return;
    }

    // Fallback : cas de reconnexion où le rôle est inconnu localement
    Get.offAllNamed(AppRoutes.roles, arguments: {'skipAuth': true});
  }

  Future<void> resendCode() async {
    if (!canResend || isLoading.value) return;

    isLoading.value = true;
    update();
    final result = await Get.find<AuthService>().sendOtp(phone: phoneNumber.value);
    isLoading.value = false;
    update();

    if (result.isSuccess) {
      final data = result.data!;
      resendSeconds.value = data.resendIn ?? _initialResendSeconds;
      _startResendTimer();
      if (data.otpCode != null && data.otpCode!.isNotEmpty) {
        testOtpCode.value = data.otpCode!;
      }
      update();
      if (data.alreadyActive) {
        UIHelper().showSnackBar(
          'MINIZON',
          'Un code est déjà actif. Renvoi disponible dans ${data.resendIn}s.',
          1,
        );
      } else {
        UIHelper().showSnackBar('MINIZON', 'Nouveau code envoyé.', 0);
      }
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
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

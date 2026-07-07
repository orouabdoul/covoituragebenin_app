import 'dart:async';

import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/auth_mode.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
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
      // Server-side cooldown from 429: initialise resend timer accordingly
      final cooldown = arg['cooldown'] as int?;
      if (cooldown != null && cooldown > 0) {
        resendSeconds.value = cooldown;
      }
    } else if (arg is String && arg.trim().isNotEmpty) {
      phoneNumber.value = arg.trim();
    }
    _startResendTimer();
  }

  void onCodeChanged(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    enteredCode.value = digits.length > 6 ? digits.substring(0, 6) : digits;
    update();
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
    await uc.setUserAndToken(
      auth.user,
      auth.token,
      isProfileComplete: auth.profileComplete,
    );
    uc.setRole(auth.user.role);

    _navigateAfterAuth(auth.profileComplete, auth.user.role);
  }

  void _navigateAfterAuth(bool profileComplete, String serverRole) {
    final bool isDriver = serverRole == 'driver' ||
        serverRole == 'conducteur' ||
        _role == RoleType.driver;

    if (_mode == AuthMode.login && !profileComplete) {
      UIHelper().showSnackBar(
        'MINIZON',
        'Bienvenue ! Finalisez votre inscription pour accéder à l\'application.',
        1,
      );
      Get.offAllNamed(AppRoutes.roles, arguments: {'skipAuth': true});
      return;
    }

    if (!profileComplete) {
      Get.offAllNamed(
        isDriver
            ? AppRoutes.completeProfileDriver
            : AppRoutes.completeProfilePassenger,
      );
    } else {
      Get.offAllNamed(
        isDriver ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger,
      );
    }
  }

  Future<void> resendCode() async {
    if (!canResend) return;
    if (isLoading.value) return;

    isLoading.value = true;
    update();
    final result = await Get.find<AuthService>().sendOtp(phone: phoneNumber.value);
    isLoading.value = false;
    update();

    if (!result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      return;
    }

    final data = result.data!;
    if (data.hasCooldown) {
      // 429 — an OTP is still active, update timer with remaining server cooldown
      resendSeconds.value = data.cooldown!;
      _startResendTimer();
      UIHelper().showSnackBar(
        'MINIZON',
        'Un code est déjà actif. Renvoi disponible dans ${data.cooldown}s.',
        1,
      );
    } else {
      // 200 — new OTP sent
      resendSeconds.value = _initialResendSeconds;
      _startResendTimer();
      if (data.otpCode != null && data.otpCode!.isNotEmpty) {
        testOtpCode.value = data.otpCode!;
      }
      update();
      UIHelper().showSnackBar('MINIZON', 'Nouveau code envoyé.', 0);
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

import '../../search/controllers/search_controller.dart';

enum MobileMoneyService { mtn, moov, celtiis }

class ConfirmationReservationController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxInt selectedPaymentIndex = 0.obs;
  final RxInt reservedSeats = 2.obs;
  final Rx<MobileMoneyService> selectedMobileService = MobileMoneyService.mtn.obs;
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();
  final TextEditingController paymentContactController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCodeController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  // Payment flow state
  final RxBool isOtpSent = false.obs;
  final RxInt otpResendCountdown = 0.obs;
  final RxBool isProcessingPayment = false.obs;

  Timer? _otpCountdownTimer;

  final List<ReservationPaymentMethod> paymentMethods = const [
    ReservationPaymentMethod(
      title: AppStrings.reservationMobileMoneyPaymentTitle,
      description: AppStrings.reservationMobileMoneyPaymentDescription,
      icon: Icons.phone_android_rounded,
      backgroundColor: Color(0xFFDBEAFE),
    ),
    ReservationPaymentMethod(
      title: AppStrings.reservationCardPaymentTitle,
      description: AppStrings.reservationCardPaymentDescription,
      icon: Icons.credit_card_rounded,
      backgroundColor: Color(0xFFDCFCE7),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    // Args captured synchronously; .value= deferred to post-frame to avoid
    // setState-during-build crash when controller is lazily created by GetX.
    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final dynamic selectedRide = savedArgs['ride'];
        if (selectedRide is SearchRide) ride.value = selectedRide;

        final dynamic seats = savedArgs['seats'];
        if (seats is int) reservedSeats.value = seats;

        final dynamic idx = savedArgs['paymentIndex'];
        if (idx is int) selectedPaymentIndex.value = idx;
      }
    });
  }

  void selectPayment(int index) {
    if (selectedPaymentIndex.value != index) {
      paymentContactController.clear();
      cardExpiryController.clear();
      cardCodeController.clear();
    }

    selectedPaymentIndex.value = index;
  }

  void selectMobileService(MobileMoneyService service) {
    selectedMobileService.value = service;
  }

  // index 0 = Mobile Money, index 1 = Card
  bool get isCardPayment => selectedPaymentIndex.value == 1;

  String get paymentInputLabel => isCardPayment
      ? AppStrings.reservationCardNumberLabel
      : AppStrings.reservationPhoneNumberLabel;

  String get paymentInputPrefix => isCardPayment ? 'CB' : '+229';

  TextInputType get paymentInputKeyboardType =>
      isCardPayment ? TextInputType.number : TextInputType.phone;

  String get cardExpiryLabel => AppStrings.reservationCardExpiryLabel;

  String get cardExpiryHint => AppStrings.reservationCardExpiryHint;

  String get cardCodeLabel => AppStrings.reservationCardCodeLabel;

  String get cardCodeHint => AppStrings.reservationCardCodeHint;

  void incrementSeats() {
    reservedSeats.value += 1;
  }

  void decrementSeats() {
    if (reservedSeats.value <= 1) {
      return;
    }

    reservedSeats.value -= 1;
  }

  void confirmReservation() {
    final arguments = {'ride': ride.value, 'seats': reservedSeats.value, 'paymentIndex': selectedPaymentIndex.value};
    Get.toNamed(AppRoutes.passengerWaitingApproval, arguments: arguments);
  }

  void sendOTP() {
    isOtpSent.value = true;
    otpResendCountdown.value = 60;
    _otpCountdownTimer?.cancel();
    _otpCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (otpResendCountdown.value > 0) {
        otpResendCountdown.value--;
      } else {
        _otpCountdownTimer?.cancel();
      }
    });
  }

  void resetOtpFlow() {
    isOtpSent.value = false;
    otpResendCountdown.value = 0;
    otpController.clear();
    _otpCountdownTimer?.cancel();
  }

  int get totalAmount {
    final price = ride.value?.price ?? '1 500 FCFA';
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    final unit = int.tryParse(digits) ?? 1500;
    final base = unit * reservedSeats.value;
    return base + (base * 0.1).round();
  }

  void confirmPayment() {
    isProcessingPayment.value = true;
    Future.delayed(const Duration(milliseconds: 1800), () {
      isProcessingPayment.value = false;
      final ref = '#TXN-${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';
      Get.toNamed(
        AppRoutes.passengerPaymentSuccess,
        arguments: {'ride': ride.value, 'ref': ref, 'amount': totalAmount, 'seats': reservedSeats.value},
      );
    });
  }

  @override
  void onClose() {
    pickupController.dispose();
    dropoffController.dispose();
    paymentContactController.dispose();
    cardExpiryController.dispose();
    cardCodeController.dispose();
    otpController.dispose();
    _otpCountdownTimer?.cancel();
    super.onClose();
  }
}

class ReservationPaymentMethod {
  const ReservationPaymentMethod({
    required this.title,
    required this.description,
    required this.icon,
    this.backgroundColor = const Color(0xFFF5F5F5),
  });

  final String title;
  final String description;
  final Object icon;
  final Object? backgroundColor;

  Color get resolvedBackgroundColor {
    final Object? value = backgroundColor;
    if (value is Color) {
      return value;
    }

    return const Color(0xFFF5F5F5);
  }

  IconData get iconData {
    if (icon is IconData) {
      return icon as IconData;
    }

    final String legacyIcon = icon.toString();

    switch (legacyIcon) {
      case 'M':
        return Icons.phone_android_rounded;
      case '◫':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

import '../../search/controllers/search_controller.dart';

enum MobileMoneyService { mtn, moov, celtiis }

class ConfirmationReservationController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxInt selectedPaymentIndex = 0.obs;
  final RxInt reservedSeats = 1.obs;
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
  final RxBool isLoadingContext = false.obs;

  // Commission / max seats from API
  final RxInt commissionRate = 10.obs;
  final RxInt maxPerBooking = 4.obs;
  int _pricePerSeat = 0;
  String _bookingMode = 'approval';

  // Booking UUID obtained after createBooking API call
  String _bookingUuid = '';

  Timer? _otpCountdownTimer;

  final RxList<ReservationPaymentMethod> paymentMethods = <ReservationPaymentMethod>[
    const ReservationPaymentMethod(
      title: AppStrings.reservationMobileMoneyPaymentTitle,
      description: AppStrings.reservationMobileMoneyPaymentDescription,
      icon: Icons.phone_android_rounded,
      backgroundColor: Color(0xFFDBEAFE),
    ),
    const ReservationPaymentMethod(
      title: AppStrings.reservationCardPaymentTitle,
      description: AppStrings.reservationCardPaymentDescription,
      icon: Icons.credit_card_rounded,
      backgroundColor: Color(0xFFDCFCE7),
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final dynamic selectedRide = savedArgs['ride'];
        if (selectedRide is SearchRide) {
          ride.value = selectedRide;
          if (selectedRide.uuid.isNotEmpty) _fetchContext(selectedRide.uuid);
          // Clamp seats to what's actually available
          final available = selectedRide.seatsAvailable;
          if (available > 0 && reservedSeats.value > available) {
            reservedSeats.value = available;
          }
        }
        final dynamic seats = savedArgs['seats'];
        if (seats is int) {
          final available = ride.value?.seatsAvailable ?? 0;
          reservedSeats.value = (available > 0 && seats > available) ? available : seats;
        }
        final dynamic idx = savedArgs['paymentIndex'];
        if (idx is int) selectedPaymentIndex.value = idx;
        final dynamic bUuid = savedArgs['bookingUuid'];
        if (bUuid is String) _bookingUuid = bUuid;
      }
    });
  }

  Future<void> _fetchContext(String tripUuid) async {
    isLoadingContext.value = true;
    final result = await _service.fetchConfirmationContext(tripUuid);
    isLoadingContext.value = false;
    if (!result.isSuccess) return;
    final ctx = result.data!;
    commissionRate.value = ctx.commissionRate;
    maxPerBooking.value = ctx.trip.maxPerBooking;
    _pricePerSeat = ctx.trip.pricePerSeat;
    _bookingMode = ctx.trip.bookingMode;
    // Pre-fill phone
    if (ctx.userPhone.isNotEmpty) {
      paymentContactController.text = ctx.userPhone;
    }
    // Update payment methods from API if available
    if (ctx.paymentMethods.isNotEmpty) {
      paymentMethods.assignAll(ctx.paymentMethods.map((m) => ReservationPaymentMethod(
        title: m.title,
        description: m.description,
        icon: _resolveIcon(m.iconName),
        backgroundColor: Color(m.color),
      )));
    }
  }

  IconData _resolveIcon(String name) {
    switch (name) {
      case 'phone_android': return Icons.phone_android_rounded;
      case 'credit_card': return Icons.credit_card_rounded;
      default: return Icons.payment_rounded;
    }
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

  int get maxSeats {
    final available = ride.value?.seatsAvailable ?? 0;
    final cap = maxPerBooking.value;
    if (available > 0) return available < cap ? available : cap;
    return cap;
  }

  void incrementSeats() {
    final max = maxSeats;
    if (max > 0 && reservedSeats.value >= max) return;
    reservedSeats.value += 1;
  }

  void decrementSeats() {
    if (reservedSeats.value <= 1) return;
    reservedSeats.value -= 1;
  }

  void confirmReservation() async {
    final tripUuid = ride.value?.uuid ?? '';
    if (tripUuid.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Trajet introuvable.', 2);
      return;
    }

    isProcessingPayment.value = true;
    final result = await _service.createBooking(tripUuid, seats: reservedSeats.value);
    isProcessingPayment.value = false;

    if (!result.isSuccess) {
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
      return;
    }

    _bookingUuid = result.data!;
    logger.d('confirmReservation bookingUuid=$_bookingUuid mode=$_bookingMode');

    if (_bookingUuid.isEmpty) {
      logger.w('createBooking succeeded but UUID is empty — check API response');
      UIHelper().showSnackBar(
        'Réservation créée',
        'Votre réservation est enregistrée. Consultez Mes Réservations.',
        0,
      );
      Get.back();
      return;
    }

    if (_bookingMode == 'instant') {
      Get.toNamed(
        AppRoutes.passengerReservationPayment,
        arguments: {
          'ride': ride.value,
          'seats': reservedSeats.value,
          'bookingUuid': _bookingUuid,
          'paymentIndex': selectedPaymentIndex.value,
        },
      );
    } else {
      Get.toNamed(
        AppRoutes.passengerWaitingApproval,
        arguments: {
          'ride': ride.value,
          'seats': reservedSeats.value,
          'bookingUuid': _bookingUuid,
          'paymentIndex': selectedPaymentIndex.value,
        },
      );
    }
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
    if (_pricePerSeat > 0) {
      final base = _pricePerSeat * reservedSeats.value;
      return base + (base * commissionRate.value / 100).round();
    }
    final price = ride.value?.price ?? '1 500 FCFA';
    final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
    final unit = int.tryParse(digits) ?? 1500;
    final base = unit * reservedSeats.value;
    return base + (base * 0.1).round();
  }

  Future<void> confirmPayment() async {
    if (_bookingUuid.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Réservation introuvable. Veuillez recommencer.', 3);
      return;
    }

    final phone = paymentContactController.text.trim();
    if (phone.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Veuillez entrer votre numéro de téléphone.', 2);
      return;
    }

    isProcessingPayment.value = true;
    final provider = selectedMobileService.value.name;
    logger.d('confirmPayment bookingUuid=$_bookingUuid phone=$phone provider=$provider');
    final result = await _service.initiatePayment(
      _bookingUuid,
      phone: phone,
      provider: provider,
    );
    isProcessingPayment.value = false;

    if (!result.isSuccess) {
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.displayMessage, 2);
      }
      return;
    }

    Get.toNamed(
      AppRoutes.passengerPaymentSuccess,
      arguments: {
        'ride': ride.value,
        'bookingUuid': _bookingUuid,
        'seats': reservedSeats.value,
      },
    );
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
    if (value is Color) return value;
    return const Color(0xFFF5F5F5);
  }

  IconData get iconData {
    if (icon is IconData) return icon as IconData;
    return Icons.payment_rounded;
  }
}

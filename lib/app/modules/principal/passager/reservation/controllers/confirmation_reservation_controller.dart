import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/reservation/views/confirmation_payment_view.dart';

import '../../search/controllers/search_controller.dart';

class ConfirmationReservationController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxInt selectedPaymentIndex = 0.obs;
  final RxInt reservedSeats = 2.obs;
  final TextEditingController paymentContactController = TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCodeController = TextEditingController();

  final List<ReservationPaymentMethod> paymentMethods = const [
    ReservationPaymentMethod(
      title: AppStrings.reservationCashPaymentTitle,
      description: AppStrings.reservationCashPaymentDescription,
      icon: Icons.payments_outlined,
      backgroundColor: Color(0xFFFEF9C3),
    ),
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

    final dynamic arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      final dynamic selectedRide = arguments['ride'];
      if (selectedRide is SearchRide) {
        ride.value = selectedRide;
      }
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

  bool get isCardPayment => selectedPaymentIndex.value == 2;

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
    final arguments = {'ride': ride.value};

    try {
      Get.toNamed(
        AppRoutes.passengerReservationPayment,
        arguments: arguments,
      );
    } catch (_) {
      // Fallback for hot-reload stale route tables.
      Get.to(
        () => const ConfirmationPaymentView(),
        arguments: arguments,
      );
    }
  }

  void confirmPayment() {
    Get.snackbar(AppStrings.appName, 'Paiement confirmé avec succès.');
    Get.back();
  }

  @override
  void onClose() {
    paymentContactController.dispose();
    cardExpiryController.dispose();
    cardCodeController.dispose();
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
      case '¤':
        return Icons.payments_outlined;
      case 'M':
        return Icons.phone_android_rounded;
      case '◫':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }
}

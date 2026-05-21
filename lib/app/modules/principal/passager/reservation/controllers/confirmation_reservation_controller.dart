import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';

import '../../search/controllers/search_controller.dart';

class ConfirmationReservationController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxInt selectedPaymentIndex = 0.obs;
  final RxInt reservedSeats = 2.obs;

  final List<ReservationPaymentMethod> paymentMethods = const [
    ReservationPaymentMethod(
      title: AppStrings.reservationCashPaymentTitle,
      description: AppStrings.reservationCashPaymentDescription,
      icon: '¤',
    ),
    ReservationPaymentMethod(
      title: AppStrings.reservationMobileMoneyPaymentTitle,
      description: AppStrings.reservationMobileMoneyPaymentDescription,
      icon: 'M',
    ),
    ReservationPaymentMethod(
      title: AppStrings.reservationCardPaymentTitle,
      description: AppStrings.reservationCardPaymentDescription,
      icon: '◫',
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
    selectedPaymentIndex.value = index;
  }

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
    Get.snackbar(AppStrings.appName, 'Réservation confirmée avec succès.');
    Get.back();
  }
}

class ReservationPaymentMethod {
  const ReservationPaymentMethod({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final String icon;
}

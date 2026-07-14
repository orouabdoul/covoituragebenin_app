import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/controllers/messager_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/reservation/controllers/reservation_controller.dart';
import '../../search/controllers/search_controller.dart';

class PaymentSuccessController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final transactionRef = ''.obs;
  final totalAmount = 0.obs;
  final reservedSeats = 1.obs;

  // Enriched data from API
  final driverPhone = ''.obs;
  final conversationUuid = ''.obs;
  final formattedAmount = ''.obs;

  String _bookingUuid = '';

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final r = savedArgs['ride'];
        if (r is SearchRide) ride.value = r;
        final ref = savedArgs['ref'];
        if (ref is String) transactionRef.value = ref;
        final amount = savedArgs['amount'];
        if (amount is int) totalAmount.value = amount;
        final seats = savedArgs['seats'];
        if (seats is int) reservedSeats.value = seats;
        final uuid = savedArgs['bookingUuid'];
        if (uuid is String && uuid.isNotEmpty) {
          _bookingUuid = uuid;
          _fetchSuccess();
        }
      }
      if (transactionRef.value.isEmpty) {
        transactionRef.value =
            '#TXN-${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';
      }
    });
  }

  Future<void> _fetchSuccess() async {
    final result = await _service.fetchPaymentSuccess(_bookingUuid);
    if (!result.isSuccess) return;
    final data = result.data!;
    transactionRef.value = data.transactionRef;
    totalAmount.value = data.amountPaid;
    formattedAmount.value = data.formattedAmount;
    driverPhone.value = data.driverPhone;
    conversationUuid.value = data.conversationUuid;
    reservedSeats.value = data.reservedSeats;
    ride.value = SearchRide(
      driverName: data.ride.driverName,
      rating: data.ride.rating,
      reviewCount: '${data.ride.reviewCount}',
      price: data.ride.uuid,
      priceValue: data.amountPaid,
      origin: data.ride.origin,
      destination: data.ride.destination,
      departureTime: data.ride.departureTime,
      departureNote: '',
      arrivalTime: '',
      arrivalNote: '',
      duration: '',
      vehicle: data.ride.vehicle,
      seatsAvailable: data.reservedSeats,
      minutesUntilDeparture: 0,
      isVerified: false,
    );
  }

  String get displayFormattedAmount {
    if (formattedAmount.value.isNotEmpty) return formattedAmount.value;
    final formatted = totalAmount.value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ' ',
    );
    return '$formatted FCFA';
  }

  void callDriver() {
    final phone = driverPhone.value.isNotEmpty ? driverPhone.value : '+229 97 12 34 56';
    final driverName = ride.value?.driverName ?? 'votre conducteur';
    Get.snackbar(
      'Appeler $driverName',
      'Numéro : $phone',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.phone_rounded, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  void messageDriver() {
    final driverName = ride.value?.driverName ?? 'Votre conducteur';
    final origin = ride.value?.origin ?? '';
    final destination = ride.value?.destination ?? '';
    MessagerController.openDriverChat(
      driverName: driverName,
      tripRoute: origin.isNotEmpty ? '$origin → $destination' : '',
      conversationUuid: conversationUuid.value,
    );
  }

  void goToReservations() {
    // Forcer le rechargement de la liste avant de switcher l'onglet
    try {
      Get.find<ReservationController>().refresh();
    } catch (_) {}
    BottonNavController.goToTab(2);
  }

  void goHome() => BottonNavController.goToTab(0);
}

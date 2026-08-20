import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/app_sync.dart';
import 'package:covoiturage_benin_app/app/core/utils/phone_utils.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/controllers/messager_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
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
  final bookingRef = ''.obs;
  final pickupCity = ''.obs;
  final pickupAddress = ''.obs;
  final dropoffCity = ''.obs;
  final dropoffAddress = ''.obs;
  final Rxn<PriceBreakdown> priceBreakdown = Rxn<PriceBreakdown>();
  final Rxn<double> passengerDistanceKm = Rxn<double>();

  String _bookingUuid = '';
  Timer? _autoRedirectTimer;

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
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
    _autoRedirectTimer = Timer(const Duration(seconds: 4), goHome);
  }

  Future<void> _fetchSuccess() async {
    final result = await _service.fetchPaymentSuccess(_bookingUuid);
    if (!result.isSuccess) return;
    final data = result.data!;
    if (data.transactionRef.isNotEmpty) transactionRef.value = data.transactionRef;
    if (data.amountPaid > 0) totalAmount.value = data.amountPaid;
    if (data.formattedAmount.isNotEmpty) formattedAmount.value = data.formattedAmount;
    if (data.driverPhone.isNotEmpty) driverPhone.value = data.driverPhone;
    if (data.conversationUuid.isNotEmpty) conversationUuid.value = data.conversationUuid;
    if (data.reservedSeats > 0) reservedSeats.value = data.reservedSeats;
    if (data.bookingRef.isNotEmpty) bookingRef.value = data.bookingRef;
    if (data.pickupCity.isNotEmpty) pickupCity.value = data.pickupCity;
    if (data.pickupAddress.isNotEmpty) pickupAddress.value = data.pickupAddress;
    if (data.dropoffCity.isNotEmpty) dropoffCity.value = data.dropoffCity;
    if (data.dropoffAddress.isNotEmpty) dropoffAddress.value = data.dropoffAddress;
    priceBreakdown.value = data.priceBreakdown;
    passengerDistanceKm.value = data.passengerDistanceKm;
    // Rafraîchit la liste des réservations dès que le paiement est confirmé,
    // sans attendre que l'utilisateur tape "Mes réservations"
    AppSync.i.refreshPassenger();
    ride.value = SearchRide(
      uuid: data.ride.uuid,
      driverName: data.ride.driverName,
      driverInitials: data.ride.driverInitials,
      rating: data.ride.rating,
      reviewCount: '${data.ride.reviewCount}',
      vehicle: data.ride.vehicle,
      vehiclePlate: data.ride.vehiclePlate,
      price: data.formattedAmount.isNotEmpty
          ? data.formattedAmount
          : '${data.amountPaid} FCFA',
      priceValue: data.amountPaid,
      origin: data.ride.origin,
      destination: data.ride.destination,
      departureTime: data.ride.departureTime,
      departureNote: '',
      arrivalTime: '',
      arrivalNote: '',
      duration: '',
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

  void callDriver() => PhoneUtils.call(driverPhone.value);

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
    _autoRedirectTimer?.cancel();
    AppSync.i.refreshPassenger();
    Get.until((route) => route.settings.name == AppRoutes.dashboardPassenger || route.isFirst);
    BottonNavController.goToTab(2);
  }

  void goHome() {
    _autoRedirectTimer?.cancel();
    AppSync.i.refreshPassenger();
    Get.until((route) => route.settings.name == AppRoutes.dashboardPassenger || route.isFirst);
    BottonNavController.goToTab(0);
  }

  @override
  void onClose() {
    _autoRedirectTimer?.cancel();
    super.onClose();
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/benin_locations_data.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/reservations_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

import '../../search/controllers/search_controller.dart';

enum MobileMoneyService { mtn, moov, celtiis }

class ConfirmationReservationController extends GetxController {
  PassengerReservationService get _service =>
      Get.find<PassengerReservationService>();

  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final RxInt selectedPaymentIndex = 0.obs;
  final RxInt reservedSeats = 1.obs;
  final Rx<MobileMoneyService> selectedMobileService =
      MobileMoneyService.mtn.obs;

  // ── Pickup — ville ─────────────────────────────────────────────────────────
  final TextEditingController pickupCityController = TextEditingController();
  final RxnString pickupSelectedCity = RxnString();
  final RxList<String> pickupCityItems = <String>[].obs;

  // ── Pickup — quartier ──────────────────────────────────────────────────────
  final TextEditingController pickupNeighborhoodController =
      TextEditingController();
  final RxnString pickupSelectedNeighborhood = RxnString();

  // ── Pickup — adresse libre (repère) ───────────────────────────────────────
  final TextEditingController pickupController = TextEditingController();

  // ── Dropoff — ville ────────────────────────────────────────────────────────
  final TextEditingController dropoffCityController = TextEditingController();
  final RxnString dropoffSelectedCity = RxnString();
  final RxList<String> dropoffCityItems = <String>[].obs;

  // ── Dropoff — quartier ─────────────────────────────────────────────────────
  final TextEditingController dropoffNeighborhoodController =
      TextEditingController();
  final RxnString dropoffSelectedNeighborhood = RxnString();

  // ── Dropoff — adresse libre ────────────────────────────────────────────────
  final TextEditingController dropoffController = TextEditingController();

  // ── GPS coordinates ────────────────────────────────────────────────────────
  final Rx<double?> pickupLat = Rx<double?>(null);
  final Rx<double?> pickupLng = Rx<double?>(null);
  final Rx<double?> dropoffLat = Rx<double?>(null);
  final Rx<double?> dropoffLng = Rx<double?>(null);
  final RxBool isLocatingPickup = false.obs;
  final RxBool isLocatingDropoff = false.obs;

  // ── Quartiers disponibles (réactif à la ville sélectionnée) ───────────────
  List<String> get pickupNeighborhoodItems =>
      BeninLocations.getDistricts(pickupSelectedCity.value);

  List<String> get dropoffNeighborhoodItems =>
      BeninLocations.getDistricts(dropoffSelectedCity.value);

  // ── Payment fields ─────────────────────────────────────────────────────────
  final TextEditingController paymentContactController =
      TextEditingController();
  final TextEditingController cardExpiryController = TextEditingController();
  final TextEditingController cardCodeController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  final RxBool isOtpSent = false.obs;
  final RxInt otpResendCountdown = 0.obs;
  final RxBool isProcessingPayment = false.obs;
  final RxBool isLoadingContext = false.obs;

  final RxInt commissionRate = 10.obs;
  final RxInt maxPerBooking = 4.obs;
  int _pricePerSeat = 0;
  String _bookingMode = 'approval';
  String _bookingUuid = '';

  Timer? _otpCountdownTimer;

  final RxList<ReservationPaymentMethod> paymentMethods =
      <ReservationPaymentMethod>[
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
    // Initialise avec toutes les villes (sans priorité tant que le trajet n'est pas connu)
    final allCities = BeninLocations.cities;
    pickupCityItems.assignAll(allCities);
    dropoffCityItems.assignAll(allCities);

    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final dynamic selectedRide = savedArgs['ride'];
        if (selectedRide is SearchRide) {
          ride.value = selectedRide;
          _buildCityLists(selectedRide);
          if (selectedRide.uuid.isNotEmpty) _fetchContext(selectedRide.uuid);
          final available = selectedRide.seatsAvailable;
          if (available > 0 && reservedSeats.value > available) {
            reservedSeats.value = available;
          }
        }
        final dynamic seats = savedArgs['seats'];
        if (seats is int) {
          final available = ride.value?.seatsAvailable ?? 0;
          reservedSeats.value =
              (available > 0 && seats > available) ? available : seats;
        }
        final dynamic idx = savedArgs['paymentIndex'];
        if (idx is int) selectedPaymentIndex.value = idx;
        final dynamic bUuid = savedArgs['bookingUuid'];
        if (bUuid is String) _bookingUuid = bUuid;
      }
    });
  }

  // ── Listes de villes ordonnées selon le trajet ────────────────────────────

  void _buildCityLists(SearchRide r) {
    // Villes définies dans le trajet du conducteur
    final tripCities = <String>[
      r.origin,
      if (r.waypointCity != null && r.waypointCity!.isNotEmpty) r.waypointCity!,
      r.destination,
    ].where((c) => BeninLocations.citiesWithDistricts.containsKey(c)).toList();

    // Pickup : villes du trajet sauf la destination (généralement)
    final pickupPriority = tripCities
        .where((c) => c != r.destination)
        .toList();
    if (pickupPriority.isEmpty) pickupPriority.addAll(tripCities);

    pickupCityItems.assignAll(
        BeninLocations.orderedCities(pickupPriority));

    // Dropoff : toutes les villes du trajet, destination en premier
    final dropoffPriority = [
      if (tripCities.contains(r.destination)) r.destination,
      ...tripCities.where((c) => c != r.destination),
    ];
    if (dropoffPriority.isEmpty) dropoffPriority.addAll(tripCities);

    dropoffCityItems.assignAll(
        BeninLocations.orderedCities(dropoffPriority));
  }

  // ── Sélection ville prise en charge ───────────────────────────────────────

  void onPickupCitySelected(String city) {
    pickupSelectedCity.value = city;
    pickupCityController.text = city;
    // Réinitialise le quartier quand la ville change
    pickupSelectedNeighborhood.value = null;
    pickupNeighborhoodController.text = '';
    // Coordonnées GPS de la ville
    final coords = BeninLocations.getCityCoords(city);
    pickupLat.value = coords?.lat;
    pickupLng.value = coords?.lng;
  }

  void onPickupCityTyped() {
    pickupSelectedCity.value = null;
    pickupSelectedNeighborhood.value = null;
    pickupNeighborhoodController.text = '';
    pickupLat.value = null;
    pickupLng.value = null;
  }

  void onPickupNeighborhoodSelected(String district) {
    pickupSelectedNeighborhood.value = district;
    pickupNeighborhoodController.text = district;
  }

  void onPickupNeighborhoodTyped() => pickupSelectedNeighborhood.value = null;

  // ── Sélection ville dépose ─────────────────────────────────────────────────

  void onDropoffCitySelected(String city) {
    dropoffSelectedCity.value = city;
    dropoffCityController.text = city;
    dropoffSelectedNeighborhood.value = null;
    dropoffNeighborhoodController.text = '';
    final coords = BeninLocations.getCityCoords(city);
    dropoffLat.value = coords?.lat;
    dropoffLng.value = coords?.lng;
  }

  void onDropoffCityTyped() {
    dropoffSelectedCity.value = null;
    dropoffSelectedNeighborhood.value = null;
    dropoffNeighborhoodController.text = '';
    dropoffLat.value = null;
    dropoffLng.value = null;
  }

  void onDropoffNeighborhoodSelected(String district) {
    dropoffSelectedNeighborhood.value = district;
    dropoffNeighborhoodController.text = district;
  }

  void onDropoffNeighborhoodTyped() => dropoffSelectedNeighborhood.value = null;

  // ── GPS ───────────────────────────────────────────────────────────────────

  Future<void> locatePickup() async {
    isLocatingPickup.value = true;
    try {
      final pos = await _getPosition();
      if (pos != null) {
        pickupLat.value = pos.latitude;
        pickupLng.value = pos.longitude;
        UIHelper().showSnackBar('MINIZON', 'Position prise en charge obtenue.', 0);
      }
    } finally {
      isLocatingPickup.value = false;
    }
  }

  Future<void> locateDropoff() async {
    isLocatingDropoff.value = true;
    try {
      final pos = await _getPosition();
      if (pos != null) {
        dropoffLat.value = pos.latitude;
        dropoffLng.value = pos.longitude;
        UIHelper().showSnackBar('MINIZON', 'Position de dépose obtenue.', 0);
      }
    } finally {
      isLocatingDropoff.value = false;
    }
  }

  Future<Position?> _getPosition() async {
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      UIHelper().showSnackBar('MINIZON', 'Permission de localisation refusée.', 2);
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      logger.e('GPS: $e');
      UIHelper().showSnackBar('MINIZON', 'Impossible d\'obtenir la position GPS.', 2);
      return null;
    }
  }

  // ── Contexte trajet ───────────────────────────────────────────────────────

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
    if (ctx.userPhone.isNotEmpty) {
      paymentContactController.text = ctx.userPhone;
    }
    if (ctx.paymentMethods.isNotEmpty) {
      paymentMethods.assignAll(ctx.paymentMethods.map((m) =>
          ReservationPaymentMethod(
            title: m.title,
            description: m.description,
            icon: _resolveIcon(m.iconName),
            backgroundColor: Color(m.color),
          )));
    }
  }

  IconData _resolveIcon(String name) {
    switch (name) {
      case 'phone_android':
        return Icons.phone_android_rounded;
      case 'credit_card':
        return Icons.credit_card_rounded;
      default:
        return Icons.payment_rounded;
    }
  }

  // ── Places ────────────────────────────────────────────────────────────────

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
  String get paymentInputLabel =>
      isCardPayment ? AppStrings.reservationCardNumberLabel : AppStrings.reservationPhoneNumberLabel;
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

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateForm() {
    final pCity = pickupCityController.text.trim();
    final pNbh = pickupNeighborhoodController.text.trim();
    final dCity = dropoffCityController.text.trim();
    final dNbh = dropoffNeighborhoodController.text.trim();

    if (pCity.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Choisissez la ville de prise en charge.', 2);
      return false;
    }
    if (pNbh.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Choisissez le quartier de prise en charge.', 2);
      return false;
    }
    if (pickupLat.value == null) {
      UIHelper().showSnackBar(
          'MINIZON',
          'Coordonnées GPS non disponibles pour "$pCity". Utilisez le bouton GPS.',
          3);
      return false;
    }
    if (dCity.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Choisissez la ville de dépose.', 2);
      return false;
    }
    if (dNbh.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Choisissez le quartier de dépose.', 2);
      return false;
    }
    if (dropoffLat.value == null) {
      UIHelper().showSnackBar(
          'MINIZON',
          'Coordonnées GPS non disponibles pour "$dCity". Utilisez le bouton GPS.',
          3);
      return false;
    }
    return true;
  }

  // ── Réservation ───────────────────────────────────────────────────────────

  Future<void> confirmReservation() async {
    if (!_validateForm()) return;

    final tripUuid = ride.value?.uuid ?? '';
    if (tripUuid.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Trajet introuvable.', 2);
      return;
    }

    isProcessingPayment.value = true;
    final result = await _service.createBooking(
      tripUuid,
      seats: reservedSeats.value,
      pickupCity: pickupCityController.text.trim(),
      pickupNeighborhood: pickupNeighborhoodController.text.trim(),
      pickupAddress: pickupController.text.trim(),
      pickupLat: pickupLat.value!,
      pickupLng: pickupLng.value!,
      dropoffCity: dropoffCityController.text.trim(),
      dropoffNeighborhood: dropoffNeighborhoodController.text.trim(),
      dropoffAddress: dropoffController.text.trim(),
      dropoffLat: dropoffLat.value!,
      dropoffLng: dropoffLng.value!,
    );
    isProcessingPayment.value = false;

    if (!result.isSuccess) {
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.displayMessage, 2);
      }
      return;
    }

    final booking = result.data!;
    _bookingUuid = booking.bookingUuid;
    _bookingMode = booking.bookingMode;

    logger.d('createBooking OK uuid=$_bookingUuid mode=$_bookingMode '
        'price=${booking.calculatedPrice} dist=${booking.passengerDistanceKm}km');

    _showPriceSheet(booking);
  }

  void _showPriceSheet(CreateBookingResult booking) {
    Get.bottomSheet(
      _PriceConfirmSheet(
        booking: booking,
        seats: reservedSeats.value,
        onConfirm: _proceedToNextStep,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _proceedToNextStep() {
    Get.back();
    if (_bookingUuid.isEmpty) return;

    if (_bookingMode == 'instant') {
      Get.toNamed(AppRoutes.passengerReservationPayment, arguments: {
        'ride': ride.value,
        'seats': reservedSeats.value,
        'bookingUuid': _bookingUuid,
        'paymentIndex': selectedPaymentIndex.value,
      });
    } else {
      Get.toNamed(AppRoutes.passengerWaitingApproval, arguments: {
        'ride': ride.value,
        'seats': reservedSeats.value,
        'bookingUuid': _bookingUuid,
        'paymentIndex': selectedPaymentIndex.value,
      });
    }
  }

  // ── Paiement ──────────────────────────────────────────────────────────────

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
    Get.toNamed(AppRoutes.passengerPaymentSuccess, arguments: {
      'ride': ride.value,
      'bookingUuid': _bookingUuid,
      'seats': reservedSeats.value,
    });
  }

  @override
  void onClose() {
    pickupCityController.dispose();
    pickupNeighborhoodController.dispose();
    pickupController.dispose();
    dropoffCityController.dispose();
    dropoffNeighborhoodController.dispose();
    dropoffController.dispose();
    paymentContactController.dispose();
    cardExpiryController.dispose();
    cardCodeController.dispose();
    otpController.dispose();
    _otpCountdownTimer?.cancel();
    super.onClose();
  }
}

// ── Sheet de confirmation du prix calculé ──────────────────────────────────

class _PriceConfirmSheet extends StatelessWidget {
  const _PriceConfirmSheet({
    required this.booking,
    required this.seats,
    required this.onConfirm,
  });

  final CreateBookingResult booking;
  final int seats;
  final VoidCallback onConfirm;

  String _fmt(int v) => v
      .toString()
      .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7EF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.route_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Prix estimé pour votre trajet',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          Text(
            'Calculé selon votre distance exacte',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F7EF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Text(
                  '${_fmt(booking.calculatedPrice)} FCFA',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  seats > 1 ? 'pour $seats places' : 'pour 1 place',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.social_distance_rounded,
            label: 'Votre trajet',
            value: booking.formattedPassengerDistance,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.route_rounded,
            label: 'Trajet total du conducteur',
            value: booking.formattedTripDistance,
          ),
          if (booking.priceTotal > 0 &&
              booking.priceTotal != booking.calculatedPrice) ...[
            const SizedBox(height: 8),
            _DetailRow(
              icon: Icons.receipt_long_rounded,
              label: 'Prix total du trajet (référence)',
              value: '${_fmt(booking.priceTotal)} FCFA',
              valueColor: Colors.grey[500],
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Continuer vers le paiement',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: Get.back,
            child: Text(
              'Annuler',
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ),
        Text(
          value,
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor ?? const Color(0xFF111827)),
        ),
      ],
    );
  }
}

// ── Payment method model ───────────────────────────────────────────────────

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

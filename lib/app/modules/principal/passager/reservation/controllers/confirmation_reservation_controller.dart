import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/reservations/passenger_reservation_service.dart';
import 'package:covoiturage_benin_app/app/core/services/routing/routing_service.dart';
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
  Position? _gpsPosition;
  final RxBool isAutoLocating = false.obs;

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
  final RxInt maxPerBooking = 0.obs;
  final RxInt availableSeatsFromCtx = 0.obs;
  final RxInt _pricePerSeat = 0.obs; // mis à jour par l'API → Obx se reconstruit
  int _argsTotalAmount = 0;          // passé en args navigation — non-réactif
  int _confirmedPrice = 0;           // prix confirmé par le sheet createBooking
  String _bookingMode = 'approval';

  // ── Distance / prorata ────────────────────────────────────────────────────
  final RoutingService _routing = RoutingService();
  final RxDouble passengerDistanceKm = 0.0.obs; // pickup→dropoff du passager
  final RxDouble _tripDistanceKm = 0.0.obs;     // trajet complet conducteur

  int get estimatedPricePerSeat => _pricePerSeat.value;

  /// Prix par place au prorata de la distance passager / distance trajet.
  /// Retourne le prix plein si les distances ne sont pas encore disponibles.
  int get estimatedProratedPricePerSeat {
    final perSeat = _pricePerSeat.value;
    if (perSeat == 0) return 0;
    final pDist = passengerDistanceKm.value;
    final tDist = _tripDistanceKm.value;
    if (pDist <= 0 || tDist <= 0) return perSeat;
    final ratio = (pDist / tDist).clamp(0.0, 1.0);
    return (ratio * perSeat).round().clamp(1, perSeat);
  }

  /// Vrai si on a calculé un prix proratisé (pickup/dropoff connus).
  bool get isPriceProrated =>
      passengerDistanceKm.value > 0 &&
      _tripDistanceKm.value > 0 &&
      _pricePerSeat.value > 0;

  String _bookingUuid = '';
  bool _priceConfirmed = false;

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

    _autoLocate(); // Détection GPS automatique dès l'ouverture de la page

    final dynamic savedArgs = Get.arguments;
    if (savedArgs is Map<String, dynamic>) {
      final dynamic selectedRide = savedArgs['ride'];
      if (selectedRide is SearchRide) {
        ride.value = selectedRide;
        _buildCityLists(selectedRide);
        _tripDistanceKm.value = selectedRide.distanceKm; // Haversine déjà calculé
        unawaited(_fetchTripDistanceOsrm(selectedRide)); // affine via OSRM
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
      // Montant passé par navigation → stocké sans mise à jour réactive
      // (évite un setState-during-build quand le contrôleur est initialisé lazily)
      final dynamic passedTotal = savedArgs['totalAmount'];
      if (passedTotal is int && passedTotal > 0) {
        _argsTotalAmount = passedTotal;
      }
    }
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
    pickupSelectedNeighborhood.value = null;
    pickupNeighborhoodController.text = '';
    // GPS réel (position actuelle) > coords base de données (centre-ville)
    if (_gpsPosition == null) {
      final coords = BeninLocations.getCityCoords(city);
      pickupLat.value = coords?.lat;
      pickupLng.value = coords?.lng;
    }
    unawaited(_updatePassengerDistance());
  }

  void onPickupCityTyped() {
    pickupSelectedCity.value = null;
    pickupSelectedNeighborhood.value = null;
    pickupNeighborhoodController.text = '';
    if (_gpsPosition == null) {
      pickupLat.value = null;
      pickupLng.value = null;
    }
    passengerDistanceKm.value = 0.0;
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
    unawaited(_updatePassengerDistance());
  }

  void onDropoffCityTyped() {
    dropoffSelectedCity.value = null;
    dropoffSelectedNeighborhood.value = null;
    dropoffNeighborhoodController.text = '';
    dropoffLat.value = null;
    dropoffLng.value = null;
    passengerDistanceKm.value = 0.0;
  }

  void onDropoffNeighborhoodSelected(String district) {
    dropoffSelectedNeighborhood.value = district;
    dropoffNeighborhoodController.text = district;
  }

  void onDropoffNeighborhoodTyped() => dropoffSelectedNeighborhood.value = null;

  // ── GPS auto-détection ────────────────────────────────────────────────────

  // Vérifie que les coordonnées sont dans les limites du Bénin
  bool _isInBenin(double lat, double lng) =>
      lat >= 6.0 && lat <= 12.5 && lng >= 0.8 && lng <= 3.8;

  Future<void> _autoLocate() async {
    isAutoLocating.value = true;
    try {
      final pos = await _getPosition();
      if (pos != null && _isInBenin(pos.latitude, pos.longitude)) {
        _gpsPosition = pos;
        pickupLat.value = pos.latitude;
        pickupLng.value = pos.longitude;
        logger.d('GPS Bénin: (${pos.latitude}, ${pos.longitude})');
      } else if (pos != null) {
        // Position hors Bénin (émulateur) → ignorée, les coords de ville seront utilisées
        logger.w('GPS hors Bénin ignoré: (${pos.latitude}, ${pos.longitude})');
      }
    } finally {
      isAutoLocating.value = false;
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
      // Essayer la dernière position connue d'abord (instantané)
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;

      // Sinon demander une position fraîche (medium = GPS + réseau, fonctionne sur émulateur)
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
        ),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          UIHelper().showSnackBar(
            'MINIZON',
            'GPS trop lent. Vérifiez que la localisation est activée.',
            3,
          );
          throw TimeoutException('GPS timeout');
        },
      );
    } on TimeoutException {
      return null;
    } catch (e) {
      logger.e('GPS: $e');
      UIHelper().showSnackBar('MINIZON', 'Impossible d\'obtenir la position GPS.', 2);
      return null;
    }
  }

  // ── Distance trajet complet (OSRM) ───────────────────────────────────────

  Future<void> _fetchTripDistanceOsrm(SearchRide r) async {
    final dep = BeninLocations.getCityCoords(r.origin);
    final dest = BeninLocations.getCityCoords(r.destination);
    if (dep == null || dest == null) return;
    final route = await _routing.computeRoute(
      departureLat: dep.lat,
      departureLng: dep.lng,
      arrivalLat: dest.lat,
      arrivalLng: dest.lng,
    );
    if (route != null) {
      _tripDistanceKm.value = route.distanceKm;
      logger.d('Trip distance OSRM: ${route.distanceKm.toStringAsFixed(1)}km');
    }
  }

  // ── Distance passager (pickup→dropoff via OSRM) ───────────────────────────

  Future<void> _updatePassengerDistance() async {
    final pLat = pickupLat.value;
    final pLng = pickupLng.value;
    final dLat = dropoffLat.value;
    final dLng = dropoffLng.value;
    if (pLat == null || pLng == null || dLat == null || dLng == null) {
      passengerDistanceKm.value = 0.0;
      return;
    }
    final route = await _routing.computeRoute(
      departureLat: pLat,
      departureLng: pLng,
      arrivalLat: dLat,
      arrivalLng: dLng,
    );
    if (route != null) {
      passengerDistanceKm.value = route.distanceKm;
      logger.d('Passenger distance OSRM: ${route.distanceKm.toStringAsFixed(1)}km');
    } else {
      passengerDistanceKm.value = _haversineKm(pLat, pLng, dLat, dLng);
      logger.d('Passenger distance Haversine: ${passengerDistanceKm.value.toStringAsFixed(1)}km');
    }
  }

  double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371.0;
    final rad1 = lat1 * (pi / 180);
    final rad2 = lat2 * (pi / 180);
    final dLat = (lat2 - lat1) * (pi / 180);
    final dLng = (lng2 - lng1) * (pi / 180);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(rad1) * cos(rad2) * sin(dLng / 2) * sin(dLng / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
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
    _pricePerSeat.value = ctx.trip.pricePerSeat;
    _bookingMode = ctx.trip.bookingMode;
    // Distance trajet depuis le backend (si OSRM n'a pas encore répondu)
    final ctxDist = double.tryParse(ctx.trip.distanceKm) ?? 0.0;
    if (ctxDist > 0 && _tripDistanceKm.value <= 0) {
      _tripDistanceKm.value = ctxDist;
      logger.d('Trip distance from context: ${ctxDist.toStringAsFixed(1)}km');
    }
    // Source authoritative pour les places disponibles
    if (ctx.trip.availableSeats > 0) {
      availableSeatsFromCtx.value = ctx.trip.availableSeats;
    }
    // Clamp la sélection courante au nouveau max
    final newMax = maxSeats;
    if (newMax > 0 && reservedSeats.value > newMax) {
      reservedSeats.value = newMax;
    }
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

  // Nombre de places réellement disponibles (contexte API prioritaire sur recherche)
  int get effectiveAvailable =>
      availableSeatsFromCtx.value > 0
          ? availableSeatsFromCtx.value
          : (ride.value?.seatsAvailable ?? 0);

  // Max sélectionnable = min(places dispo, cap conducteur) ; 0 dans l'un = ignoré
  int get maxSeats {
    final available = effectiveAvailable;
    final cap = maxPerBooking.value; // 0 = pas de cap côté conducteur
    if (available > 0 && cap > 0) return available < cap ? available : cap;
    if (available > 0) return available;
    if (cap > 0) return cap;
    return 0; // indéterminé (contexte pas encore chargé)
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
      if (isAutoLocating.value) {
        UIHelper().showSnackBar(
            'MINIZON', 'Localisation GPS en cours. Attendez un instant.', 3);
      } else {
        UIHelper().showSnackBar(
            'MINIZON',
            'Position GPS introuvable. Vérifiez que la localisation est activée.',
            3);
      }
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
          'Ville de dépose "$dCity" non reconnue. Choisissez une ville de la liste.',
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

    logger.d('confirmReservation: '
        'pickup=(${pickupLat.value},${pickupLng.value}) '
        'dropoff=(${dropoffLat.value},${dropoffLng.value}) '
        'seats=${reservedSeats.value}');

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
    _priceConfirmed = false;

    // Calcul du prix confirmé avec fallback si le backend retourne 0
    if (booking.calculatedPrice > 0) {
      // Prix calculé par le backend (distance réelle du passager)
      _confirmedPrice = booking.calculatedPrice * reservedSeats.value;
    } else if (booking.passengerDistanceKm > 0 &&
        booking.tripDistanceKm > 0 &&
        _pricePerSeat.value > 0) {
      // Distances retournées par le backend → calcul local du prorata
      final ratio = (booking.passengerDistanceKm / booking.tripDistanceKm)
          .clamp(0.0, 1.0);
      final perSeat = (ratio * _pricePerSeat.value).round();
      _confirmedPrice =
          (perSeat > 0 ? perSeat : _pricePerSeat.value) * reservedSeats.value;
    } else if (passengerDistanceKm.value > 0 &&
        _tripDistanceKm.value > 0 &&
        _pricePerSeat.value > 0) {
      // Distances OSRM pré-calculées (pickup/dropoff sélectionnés avant réservation)
      final ratio =
          (passengerDistanceKm.value / _tripDistanceKm.value).clamp(0.0, 1.0);
      final perSeat = (ratio * _pricePerSeat.value).round();
      _confirmedPrice =
          (perSeat > 0 ? perSeat : _pricePerSeat.value) * reservedSeats.value;
    } else if (_pricePerSeat.value > 0) {
      // Dernier recours : prix plein × places
      _confirmedPrice = _pricePerSeat.value * reservedSeats.value;
    }

    logger.d('_showPriceSheet: calculatedPrice=${booking.calculatedPrice} '
        'passengerDist=${booking.passengerDistanceKm}km '
        'tripDist=${booking.tripDistanceKm}km '
        'pricePerSeat=${_pricePerSeat.value} '
        'confirmedPrice=$_confirmedPrice');

    Get.bottomSheet(
      _PriceConfirmSheet(
        booking: booking,
        seats: reservedSeats.value,
        confirmedTotal: _confirmedPrice,
        onConfirm: _proceedToNextStep,
        onCancel: _cancelAndDismiss,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    ).then((_) {
      // Déclenché sur fermeture par swipe (ni Annuler ni Continuer pressés)
      if (!_priceConfirmed && _bookingUuid.isNotEmpty) _cancelAndDismiss();
    });
  }

  Future<void> _cancelAndDismiss() async {
    Get.back();
    if (_bookingUuid.isEmpty) return;
    final uuid = _bookingUuid;
    _bookingUuid = ''; // reset immédiat pour permettre un nouvel essai
    await _service.cancelBooking(uuid);
  }

  void _proceedToNextStep() {
    _priceConfirmed = true; // empêche l'annulation automatique via .then()
    Get.back();
    if (_bookingUuid.isEmpty) return;

    if (_bookingMode == 'instant') {
      Get.toNamed(AppRoutes.passengerReservationPayment, arguments: {
        'ride': ride.value,
        'seats': reservedSeats.value,
        'bookingUuid': _bookingUuid,
        'paymentIndex': selectedPaymentIndex.value,
        'totalAmount': totalAmount,
      });
    } else {
      Get.toNamed(AppRoutes.passengerWaitingApproval, arguments: {
        'ride': ride.value,
        'seats': reservedSeats.value,
        'bookingUuid': _bookingUuid,
        'paymentIndex': selectedPaymentIndex.value,
        'totalAmount': totalAmount,
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
    // Priorité 0 : prix confirmé par le sheet (calculatedPrice du backend)
    if (_confirmedPrice > 0) return _confirmedPrice;
    // Priorité 1 : prix proratisé (ou plein si pas de distances) depuis l'API
    final perSeat = estimatedProratedPricePerSeat;
    if (perSeat > 0) {
      final base = perSeat * reservedSeats.value;
      return base + (base * commissionRate.value / 100).round();
    }
    // Priorité 2 : montant transmis par les arguments de navigation (non-réactif)
    if (_argsTotalAmount > 0) return _argsTotalAmount;
    // Priorité 3 : fallback depuis la chaîne de prix du trajet
    final price = ride.value?.price ?? '';
    if (price.isNotEmpty) {
      final digits = price.replaceAll(RegExp(r'[^0-9]'), '');
      final unit = int.tryParse(digits) ?? 0;
      if (unit > 0) {
        final base = unit * reservedSeats.value;
        return base + (base * commissionRate.value / 100).round();
      }
    }
    return 0;
  }

  Future<void> confirmPayment() async {
    if (_bookingUuid.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Réservation introuvable. Veuillez recommencer.', 3);
      return;
    }
    final rawPhone = paymentContactController.text.trim().replaceAll(RegExp(r'\s'), '');
    if (rawPhone.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Veuillez entrer votre numéro de téléphone.', 2);
      return;
    }
    // Envoyer les chiffres locaux tels que saisis (ex : 0159000892)
    // Le backend gère le préfixe pays pour FedaPay
    final phone = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');

    isProcessingPayment.value = true;
    final provider = selectedMobileService.value.name;
    final amount = totalAmount;
    final result = await _service.initiatePayment(
      _bookingUuid,
      phone: phone,
      provider: provider,
      amount: amount,
    );
    isProcessingPayment.value = false;
    if (!result.isSuccess) {
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.displayMessage, 3);
      }
      return;
    }

    // Ouvrir la WebView FedaPay intégrée pour validation MoMo
    Get.toNamed(AppRoutes.passengerPaymentWebview, arguments: {
      'paymentUrl': result.data!.paymentUrl,
      'paymentUuid': result.data!.paymentUuid,
      'ride': ride.value,
      'bookingUuid': _bookingUuid,
      'seats': reservedSeats.value,
      'amount': totalAmount,
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
    required this.confirmedTotal,
    required this.onConfirm,
    required this.onCancel,
  });

  final CreateBookingResult booking;
  final int seats;
  final int confirmedTotal;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

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
            'Prix de votre trajet',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF111827)),
          ),
          const SizedBox(height: 4),
          Text(
            booking.passengerDistanceKm > 0
                ? 'Calculé sur ${booking.formattedPassengerDistance} de trajet'
                : 'Basé sur le tarif du conducteur',
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
                  confirmedTotal > 0 ? '${_fmt(confirmedTotal)} FCFA' : '-- FCFA',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  seats > 1 && confirmedTotal > 0
                      ? '${_fmt((confirmedTotal / seats).round())} FCFA × $seats places'
                      : 'pour 1 place',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (booking.passengerDistanceKm > 0) ...[
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
            const SizedBox(height: 8),
          ],
          if (booking.priceTotal > 0 &&
              confirmedTotal > 0 &&
              booking.priceTotal != (confirmedTotal / seats).round()) ...[
            _DetailRow(
              icon: Icons.receipt_long_rounded,
              label: 'Prix plein du trajet (référence)',
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
            onPressed: onCancel,
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

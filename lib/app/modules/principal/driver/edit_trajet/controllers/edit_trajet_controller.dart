import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/app_sync.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/services/routing/geocoding_service.dart';
import 'package:covoiturage_benin_app/app/core/services/routing/routing_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/benin_location_helpers.dart';
import 'package:covoiturage_benin_app/app/data/benin_locations_data.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/vehicle_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/driver/trajet/controllers/add_trajet_controller.dart'
    show TripPreferenceData, BookingModeOption, CancellationPolicyOption;

class EditTrajetController extends GetxController {
  TripsService get _tripsService => Get.find<TripsService>();
  final RoutingService _routing = RoutingService();
  final GeocodingService _geocoding = GeocodingService();

  late final String _tripUuid;

  // ── Vehicles ──────────────────────────────────────────────────────────────
  final RxList<VehicleData> availableVehicles = <VehicleData>[].obs;
  final Rx<VehicleData?> selectedVehicle = Rx<VehicleData?>(null);
  final RxBool isLoadingVehicles = false.obs;

  // ── Seats, price ──────────────────────────────────────────────────────────
  final RxInt availableSeats = 3.obs;
  final RxDouble pricePerSeat = 5000.0.obs;
  final RxSet<String> selectedOptions = <String>{}.obs;
  final RxBool isSaving = false.obs;
  final RxBool isLoadingData = false.obs;

  int priceDefault = 5000;

  // ── Commission from API ───────────────────────────────────────────────────
  int commissionRatePercent = 10;
  int driverSharePercent = 90;

  // ── Booking mode & cancellation policy ────────────────────────────────────
  final RxString selectedBookingMode = 'instant'.obs;
  final RxString selectedCancellationPolicy = 'flexible'.obs;
  final RxList<BookingModeOption> bookingModes = <BookingModeOption>[
    const BookingModeOption(
      mode: 'instant',
      title: 'Réservation instantanée',
      description: 'Les passagers sont acceptés automatiquement dès la réservation.',
      icon: 'bolt',
    ),
    const BookingModeOption(
      mode: 'approval',
      title: 'Sur approbation',
      description: 'Chaque demande de réservation vous est soumise pour validation.',
      icon: 'how_to_reg',
    ),
  ].obs;
  final RxList<CancellationPolicyOption> cancellationPolicies =
      <CancellationPolicyOption>[
    const CancellationPolicyOption(
      policy: 'flexible',
      title: 'Flexible',
      description: 'Remboursement complet jusqu\'à 1h avant le départ.',
    ),
    const CancellationPolicyOption(
      policy: 'moderate',
      title: 'Modérée',
      description: '50 % remboursé si annulé au moins 24h avant le départ.',
    ),
    const CancellationPolicyOption(
      policy: 'strict',
      title: 'Stricte',
      description: 'Aucun remboursement après confirmation de la réservation.',
    ),
  ].obs;

  // ── Text controllers ──────────────────────────────────────────────────────
  final TextEditingController departureCityController = TextEditingController();
  final TextEditingController departureArrondissementController =
      TextEditingController();
  final TextEditingController departureDistrictController =
      TextEditingController();
  final TextEditingController departurePointController =
      TextEditingController();
  final TextEditingController destinationCityController =
      TextEditingController();
  final TextEditingController destinationArrondissementController =
      TextEditingController();
  final TextEditingController destinationDistrictController =
      TextEditingController();
  final TextEditingController destinationPointController =
      TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController priceController =
      TextEditingController(text: '5000');

  int get totalAmount => availableSeats.value * pricePerSeat.value.toInt();
  int get maxPassengers {
    final seats = selectedVehicle.value?.availableSeats ?? 5;
    return (seats - 1).clamp(1, 99);
  }

  String get capacityLabel {
    final v = selectedVehicle.value;
    if (v == null) return 'Sélectionnez un véhicule';
    return '${v.brand} ${v.model} — $maxPassengers place${maxPassengers > 1 ? 's' : ''} passager max';
  }

  // ── Villes, arrondissements & quartiers ───────────────────────────────────
  final RxList<String> _apiCities = <String>[].obs;
  final Map<String, List<String>> _apiArrondissements = {};

  final RxnString selectedDepartureCity = RxnString();
  final RxnString selectedDepartureArrondissement = RxnString();
  final RxnString selectedDepartureDistrict = RxnString();
  final RxnString selectedDestinationCity = RxnString();
  final RxnString selectedDestinationArrondissement = RxnString();
  final RxnString selectedDestinationDistrict = RxnString();

  // ── Trip estimate ─────────────────────────────────────────────────────────
  final RxBool isLoadingEstimate = false.obs;
  final RxnString estimatedDistanceKm = RxnString();
  final RxnString estimatedDurationLabel = RxnString();
  int? estimatedDurationMinutes;
  final TextEditingController durationController = TextEditingController();
  bool _durationModifiedByUser = false;
  bool _updatingDurationProgrammatically = false;


  // ── GPS ───────────────────────────────────────────────────────────────────
  double? _deviceLat;
  double? _deviceLng;

  static Map<String, List<String>> get beninCitiesWithDistricts =>
      BeninLocationHelpers.citiesWithArrondissements;

  List<String> get beninCities {
    final api = _apiCities.toList();
    return api.isNotEmpty ? api : BeninLocationHelpers.cities;
  }

  List<String> getArrondissements(String? city) {
    if (city == null) return [];
    final apiResult =
        _apiArrondissements[city.toLowerCase()] ?? _apiArrondissements[city];
    if (apiResult != null) return apiResult;
    return BeninLocations.getArrondissements(city);
  }

  List<String> getQuartiers(String? city, String? arrondissement) =>
      BeninLocations.getQuartiers(city, arrondissement);

  bool cityHasArrondissements(String? city) =>
      BeninLocations.hasArrondissements(city);

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _tripUuid = (args?['uuid'] as String?) ?? '';
    selectedOptions.addAll(const {'no_smoking', 'music'});
    priceController.addListener(_onPriceChanged);
    durationController.addListener(_onDurationChanged);
    _fetchDeviceGps();
    _loadAll();
  }

  void _onDurationChanged() {
    if (_updatingDurationProgrammatically) return;
    _durationModifiedByUser = true;
    final val = int.tryParse(durationController.text.trim());
    if (val != null && val > 0) estimatedDurationMinutes = val;
  }

  Future<void> _fetchDeviceGps() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      _deviceLat = pos.latitude;
      _deviceLng = pos.longitude;
      logger.d('GPS device: $_deviceLat, $_deviceLng');
    } catch (e) {
      logger.w('_fetchDeviceGps: $e');
    }
  }

  Future<void> _loadAll() async {
    isLoadingVehicles.value = true;
    isLoadingData.value = true;

    // Charger le formulaire (véhicules, villes, etc.)
    final formResult = await _tripsService.fetchTripForm();
    isLoadingVehicles.value = false;
    if (!formResult.isSuccess) {
      UIHelper().showSnackBar(AppStrings.appName, formResult.displayMessage, 2);
      isLoadingData.value = false;
      return;
    }
    _applyFormData(formResult.data!);

    // Charger les données du trajet existant
    if (_tripUuid.isNotEmpty) {
      final tripResult = await _tripsService.fetchTripRaw(_tripUuid);
      if (!tripResult.isSuccess) {
        isLoadingData.value = false;
        UIHelper()
            .showSnackBar(AppStrings.appName, tripResult.displayMessage, 2);
        return;
      }
      _prefillFromJson(tripResult.data!);
      isLoadingData.value = false;
    } else {
      isLoadingData.value = false;
      logger.w('EditTrajetController: no uuid provided');
    }
  }

  void _applyFormData(Map<String, dynamic> body) {
    final rawVehicles = body['vehicles'] as List<dynamic>? ?? [];
    availableVehicles.assignAll(
      rawVehicles
          .map((v) => VehicleData.fromJson(v as Map<String, dynamic>))
          .toList(),
    );

    final rawCities = body['cities'] as List<dynamic>? ?? [];
    _apiCities.assignAll(rawCities.whereType<String>().toList());

    final rawArr = body['arrondissements'] as Map<String, dynamic>?;
    if (rawArr != null) {
      _apiArrondissements.clear();
      rawArr.forEach((city, list) {
        if (list is List) {
          _apiArrondissements[city.toLowerCase()] =
              list.whereType<String>().toList();
        }
      });
    }

    final rawModes = body['booking_modes'] as List<dynamic>? ?? [];
    if (rawModes.isNotEmpty) {
      bookingModes.assignAll(rawModes.map((m) {
        final mm = m as Map<String, dynamic>;
        return BookingModeOption(
          mode: mm['mode'] as String? ?? '',
          title: mm['title'] as String? ?? '',
          description: mm['description'] as String? ?? '',
          icon: mm['icon'] as String? ?? '',
        );
      }).toList());
    }

    final rawPolicies = body['cancellation_policies'] as List<dynamic>? ?? [];
    if (rawPolicies.isNotEmpty) {
      cancellationPolicies.assignAll(rawPolicies.map((p) {
        final pp = p as Map<String, dynamic>;
        return CancellationPolicyOption(
          policy: pp['policy'] as String? ?? '',
          title: pp['title'] as String? ?? '',
          description: pp['description'] as String? ?? '',
        );
      }).toList());
    }

    final commission = body['commission'] as Map<String, dynamic>?;
    if (commission != null) {
      commissionRatePercent =
          (commission['rate_percent'] as num?)?.toInt() ?? 10;
      driverSharePercent =
          (commission['driver_share'] as num?)?.toInt() ?? 90;
    }
  }

  void _prefillFromJson(Map<String, dynamic> j) {
    // L'API retourne une structure imbriquée. On extrait les sous-objets d'abord,
    // puis on lit chaque champ en cherchant dans le bon niveau (avec fallback plat).
    final route = (j['route'] as Map<String, dynamic>?) ?? {};
    final vehicleMap = (j['vehicle'] as Map<String, dynamic>?) ?? {};
    final passengersMap = (j['passengers'] as Map<String, dynamic>?) ?? {};
    final financesMap = (j['finances'] as Map<String, dynamic>?) ?? {};

    // DEBUG — à supprimer après diagnostic
    logger.d('=== PREFILL DEBUG ===');
    logger.d('ROOT keys: ${j.keys.toList()}');
    logger.d('ROUTE keys: ${route.keys.toList()}');
    logger.d('VEHICLE keys: ${vehicleMap.keys.toList()}');
    logger.d('PASSENGERS keys: ${passengersMap.keys.toList()}');
    logger.d('FINANCES keys: ${financesMap.keys.toList()}');
    logger.d('departure_city root: ${j['departure_city']}');
    logger.d('arrival_city root: ${j['arrival_city']}');
    logger.d('route.origin: ${route['origin']}');
    logger.d('route.destination: ${route['destination']}');
    logger.d('route.departure_arrondissement: ${route['departure_arrondissement']}');
    logger.d('route.departure_neighborhood: ${route['departure_neighborhood']}');
    logger.d('===================');

    // Commune départ : l'API retourne route.origin = "Ville, Arrondissement, Quartier"
    final depCity = (j['departure_city'] as String?)?.trim() ??
        (route['departure_city'] as String?)?.trim() ??
        _parseCity(route['origin'] as String?);
    departureCityController.text = depCity;
    if (depCity.isNotEmpty) selectedDepartureCity.value = depCity;

    // Arrondissement : route.origin_arrondissement ou route.departure_arrondissement
    final depArr = (route['departure_arrondissement'] as String?)?.trim() ??
        (route['origin_arrondissement'] as String?)?.trim() ??
        (j['departure_arrondissement'] as String?)?.trim() ??
        '';
    departureArrondissementController.text = depArr;
    if (depArr.isNotEmpty) selectedDepartureArrondissement.value = depArr;

    // Quartier : extrait de route.origin si pas de clé dédiée
    final depDistrict = (route['departure_neighborhood'] as String?)?.trim() ??
        (j['departure_neighborhood'] as String?)?.trim() ??
        (j['departure_district'] as String?)?.trim() ??
        _parseNeighborhood(route['origin'] as String?);
    departureDistrictController.text = depDistrict;
    if (depDistrict.isNotEmpty) selectedDepartureDistrict.value = depDistrict;

    departurePointController.text =
        (route['origin_point'] as String?)?.trim() ??
            (j['departure_point'] as String?)?.trim() ??
            '';


    // Commune arrivée : route.destination = "Ville, Arrondissement, Quartier"
    final destCity = (j['arrival_city'] as String?)?.trim() ??
        (j['destination_city'] as String?)?.trim() ??
        (route['arrival_city'] as String?)?.trim() ??
        _parseCity(route['destination'] as String?);
    destinationCityController.text = destCity;
    if (destCity.isNotEmpty) selectedDestinationCity.value = destCity;

    // Arrondissement : route.destination_arrondissement ou route.arrival_arrondissement
    final destArr = (route['arrival_arrondissement'] as String?)?.trim() ??
        (route['destination_arrondissement'] as String?)?.trim() ??
        (j['arrival_arrondissement'] as String?)?.trim() ??
        '';
    destinationArrondissementController.text = destArr;
    if (destArr.isNotEmpty) selectedDestinationArrondissement.value = destArr;

    // Quartier : extrait de route.destination si pas de clé dédiée
    final destDistrict = (route['arrival_neighborhood'] as String?)?.trim() ??
        (j['arrival_neighborhood'] as String?)?.trim() ??
        (j['destination_district'] as String?)?.trim() ??
        _parseNeighborhood(route['destination'] as String?);
    destinationDistrictController.text = destDistrict;
    if (destDistrict.isNotEmpty) selectedDestinationDistrict.value = destDistrict;

    destinationPointController.text =
        (route['destination_point'] as String?)?.trim() ??
            (j['arrival_point'] as String?)?.trim() ??
            (j['destination_point'] as String?)?.trim() ??
            '';


    // Date/heure : dans route.departure_date + route.departure_time
    final rawDepTime = (route['departure_time'] as String?) ??
        (j['departure_time'] as String?) ??
        '';
    final rawDepDate = (route['departure_date'] as String?) ??
        (j['departure_date'] as String?) ??
        '';
    // Fallback : departure_at ISO (ex: "2025-08-15T08:00:00")
    final rawDepAt = (route['departure_at'] as String?) ??
        (j['departure_at'] as String?) ??
        '';

    if (rawDepDate.isNotEmpty) {
      dateController.text =
          rawDepDate.contains('-') ? _fromIsoDate(rawDepDate) : rawDepDate;
      timeController.text =
          rawDepTime.length >= 5 ? rawDepTime.substring(0, 5) : rawDepTime;
    } else if (rawDepAt.contains('T')) {
      final dt = DateTime.tryParse(rawDepAt)?.toLocal();
      if (dt != null) {
        dateController.text =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        timeController.text =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } else if (rawDepTime.contains('T')) {
      final dt = DateTime.tryParse(rawDepTime)?.toLocal();
      if (dt != null) {
        dateController.text =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        timeController.text =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    }

    // Sièges : passengers.total_seats ou passengers.total
    availableSeats.value =
        (passengersMap['total_seats'] as num?)?.toInt() ??
        (passengersMap['total'] as num?)?.toInt() ??
        ((j['total_seats'] ?? j['available_seats']) as num?)?.toInt() ??
        4;

    // Prix : finances.price_per_seat
    final price = (financesMap['price_per_seat'] as num?)?.toDouble() ??
        (j['price_per_seat'] as num?)?.toDouble() ??
        priceDefault.toDouble();
    pricePerSeat.value = price;
    priceController.text = price.toInt().toString();

    descriptionController.text = (j['description'] as String?) ?? '';

    final bm = j['booking_mode'] as String?;
    if (bm != null && bm.isNotEmpty) selectedBookingMode.value = bm;
    final cp = j['cancellation_policy'] as String?;
    if (cp != null && cp.isNotEmpty) selectedCancellationPolicy.value = cp;

    // Véhicule : route.vehicle_id (nouveau), sinon vehicle.id ou racine
    final vehicleId = (route['vehicle_id'] as num?)?.toInt() ??
        (vehicleMap['id'] as num?)?.toInt() ??
        (j['vehicle_id'] as num?)?.toInt();
    if (vehicleId != null && vehicleId != 0) {
      final match =
          availableVehicles.firstWhereOrNull((v) => v.id == vehicleId);
      if (match != null) selectedVehicle.value = match;
    } else {
      final vehicleUuid = (vehicleMap['uuid'] as String?) ??
          (j['vehicle_uuid'] as String?);
      if (vehicleUuid != null && vehicleUuid.isNotEmpty) {
        final match =
            availableVehicles.firstWhereOrNull((v) => v.uuid == vehicleUuid);
        if (match != null) selectedVehicle.value = match;
      }
    }

    final rawPrefs = j['preferences'];
    if (rawPrefs is List) {
      selectedOptions.clear();
      selectedOptions.addAll(rawPrefs.whereType<String>());
    }
  }

  static String _fromIsoDate(String yyyymmdd) {
    final parts = yyyymmdd.split('-');
    if (parts.length != 3) return yyyymmdd;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  static String _parseCity(String? fullAddr) {
    if (fullAddr == null || fullAddr.isEmpty) return '';
    return fullAddr.split(', ').first.trim();
  }

  static String _parseNeighborhood(String? fullAddr) {
    if (fullAddr == null || fullAddr.isEmpty) return '';
    final parts = fullAddr.split(', ');
    return parts.length >= 3 ? parts.last.trim() : '';
  }

  void _onPriceChanged() {
    final raw = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final val = double.tryParse(raw);
    if (val != null && val != pricePerSeat.value) {
      pricePerSeat.value = val;
    }
  }

  // ── Location handlers ─────────────────────────────────────────────────────

  void onDepartureCityChanged(String? city) {
    selectedDepartureCity.value = city;
    selectedDepartureArrondissement.value = null;
    selectedDepartureDistrict.value = null;
    departureCityController.text = city ?? '';
    departureArrondissementController.text = '';
    departureDistrictController.text = '';
    _durationModifiedByUser = false;
    _triggerEstimate();
  }

  void onDestinationCityChanged(String? city) {
    selectedDestinationCity.value = city;
    selectedDestinationArrondissement.value = null;
    selectedDestinationDistrict.value = null;
    destinationCityController.text = city ?? '';
    destinationArrondissementController.text = '';
    destinationDistrictController.text = '';
    _durationModifiedByUser = false;
    _triggerEstimate();
  }

  void onDepartureArrondissementChanged(String? arr) {
    selectedDepartureArrondissement.value = arr;
    selectedDepartureDistrict.value = null;
    departureArrondissementController.text = arr ?? '';
    departureDistrictController.text = '';
    _triggerEstimate();
  }

  void onDestinationArrondissementChanged(String? arr) {
    selectedDestinationArrondissement.value = arr;
    selectedDestinationDistrict.value = null;
    destinationArrondissementController.text = arr ?? '';
    destinationDistrictController.text = '';
    _triggerEstimate();
  }

  void onDepartureArrondissementTyped() {
    selectedDepartureArrondissement.value = null;
    selectedDepartureDistrict.value = null;
    departureDistrictController.text = '';
  }

  void onDestinationArrondissementTyped() {
    selectedDestinationArrondissement.value = null;
    selectedDestinationDistrict.value = null;
    destinationDistrictController.text = '';
  }

  void onDepartureDistrictChanged(String? district) {
    selectedDepartureDistrict.value = district;
    departureDistrictController.text = district ?? '';
    _triggerEstimate();
  }

  void onDestinationDistrictChanged(String? district) {
    selectedDestinationDistrict.value = district;
    destinationDistrictController.text = district ?? '';
    _triggerEstimate();
  }

  void onDepartureCityTyped() {
    selectedDepartureCity.value = null;
    selectedDepartureArrondissement.value = null;
    selectedDepartureDistrict.value = null;
    departureArrondissementController.text = '';
    departureDistrictController.text = '';
    _clearEstimate();
  }

  void onDestinationCityTyped() {
    selectedDestinationCity.value = null;
    selectedDestinationArrondissement.value = null;
    selectedDestinationDistrict.value = null;
    destinationArrondissementController.text = '';
    destinationDistrictController.text = '';
    _clearEstimate();
  }

  void _clearEstimate() {
    estimatedDistanceKm.value = null;
    estimatedDurationLabel.value = null;
    estimatedDurationMinutes = null;
    _durationModifiedByUser = false;
    _updatingDurationProgrammatically = true;
    durationController.text = '';
    _updatingDurationProgrammatically = false;
  }

  void onDepartureDistrictTyped() => selectedDepartureDistrict.value = null;
  void onDestinationDistrictTyped() => selectedDestinationDistrict.value = null;

  // ── Estimate ──────────────────────────────────────────────────────────────

  Future<void> _triggerEstimate() async {
    final dep = selectedDepartureCity.value;
    final dest = selectedDestinationCity.value;
    if (dep == null || dest == null) {
      estimatedDistanceKm.value = null;
      estimatedDurationLabel.value = null;
      estimatedDurationMinutes = null;
      return;
    }
    isLoadingEstimate.value = true;
    estimatedDistanceKm.value = null;
    estimatedDurationLabel.value = null;

    final depCoordsStatic = BeninLocationHelpers.getCityCoords(dep);
    final destCoordsStatic = BeninLocationHelpers.getCityCoords(dest);

    final depArr = selectedDepartureArrondissement.value;
    final depDist = selectedDepartureDistrict.value;
    final depQuery =
        [depDist, depArr, dep].where((e) => e != null && e.isNotEmpty).join(', ');
    final depPrecise = await _geocoding.geocodeAddress('$depQuery, Benin');

    final destArr = selectedDestinationArrondissement.value;
    final destDist = selectedDestinationDistrict.value;
    final destQuery =
        [destDist, destArr, dest].where((e) => e != null && e.isNotEmpty).join(', ');
    final destPrecise = await _geocoding.geocodeAddress('$destQuery, Benin');

    final depLat = depPrecise?.lat ?? depCoordsStatic?.lat;
    final depLng = depPrecise?.lng ?? depCoordsStatic?.lng;
    final destLat = destPrecise?.lat ?? destCoordsStatic?.lat;
    final destLng = destPrecise?.lng ?? destCoordsStatic?.lng;


    if (depLat != null && depLng != null && destLat != null && destLng != null) {
      final route = await _routing.computeRoute(
        departureLat: depLat,
        departureLng: depLng,
        arrivalLat: destLat,
        arrivalLng: destLng,
      );
      if (route != null) {
        isLoadingEstimate.value = false;
        final km = route.distanceKm;
        estimatedDistanceKm.value =
            km % 1 == 0 ? km.toInt().toString() : km.toStringAsFixed(1);
        estimatedDurationLabel.value = route.durationLabel;
        estimatedDurationMinutes = route.durationMinutes;
        if (!_durationModifiedByUser) {
          _updatingDurationProgrammatically = true;
          durationController.text = estimatedDurationMinutes.toString();
          _updatingDurationProgrammatically = false;
        }
        return;
      }
    }

    final payload = <String, dynamic>{
      'departure_city': dep,
      'arrival_city': dest,
    };
    if (depArr != null) payload['departure_arrondissement'] = depArr;
    if (depDist != null) payload['departure_neighborhood'] = depDist;
    if (destArr != null) payload['arrival_arrondissement'] = destArr;
    if (destDist != null) payload['arrival_neighborhood'] = destDist;
    if (depLat != null && depLng != null) {
      payload['departure_latitude'] = depLat;
      payload['departure_longitude'] = depLng;
    }
    if (destLat != null && destLng != null) {
      payload['arrival_latitude'] = destLat;
      payload['arrival_longitude'] = destLng;
    }

    final result = await _tripsService.estimateTrip(payload);
    isLoadingEstimate.value = false;
    if (result.isSuccess && result.data != null) {
      final body = result.data!;
      final km = (body['distance_km'] as num?)?.toDouble();
      estimatedDistanceKm.value = km != null
          ? (km % 1 == 0 ? km.toInt().toString() : km.toStringAsFixed(1))
          : null;
      estimatedDurationLabel.value =
          body['estimated_duration_label'] as String?;
      estimatedDurationMinutes =
          (body['estimated_duration_minutes'] as num?)?.toInt();
      if (!_durationModifiedByUser && estimatedDurationMinutes != null) {
        _updatingDurationProgrammatically = true;
        durationController.text = estimatedDurationMinutes.toString();
        _updatingDurationProgrammatically = false;
      }
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void selectVehicle(VehicleData vehicle) {
    selectedVehicle.value = vehicle;
    _applySeatsLimit();
  }

  void _applySeatsLimit() {
    final max = maxPassengers;
    if (availableSeats.value > max) {
      availableSeats.value = max;
      UIHelper().showSnackBar(
          AppStrings.appName,
          'Places passagers limitées à $max (1 siège réservé au conducteur).',
          1);
    } else if (availableSeats.value < 1) {
      availableSeats.value = 1;
    }
  }

  void incrementSeats() {
    if (availableSeats.value < maxPassengers) {
      availableSeats.value = availableSeats.value + 1;
    } else {
      UIHelper().showSnackBar(AppStrings.appName, capacityLabel, 1);
    }
  }

  void decrementSeats() {
    if (availableSeats.value > 1) {
      availableSeats.value = availableSeats.value - 1;
    }
  }

  void updatePrice(double value) {
    pricePerSeat.value = value;
    priceController.text = value.toInt().toString();
  }

  void toggleOption(String option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
    } else {
      selectedOptions.add(option);
    }
  }

  List<String> _buildPreferencesList() => selectedOptions.toList();

  // ── Preferences list ──────────────────────────────────────────────────────
  final List<TripPreferenceData> preferences = const [
    TripPreferenceData(
        option: 'no_smoking',
        title: 'Non-fumeur',
        subtitle: 'Cigarettes interdites dans le véhicule',
        icon: Icons.smoke_free_rounded),
    TripPreferenceData(
        option: 'music',
        title: 'Musique',
        subtitle: 'Musique autorisée en trajet',
        icon: Icons.music_note_rounded),
    TripPreferenceData(
        option: 'ac',
        title: 'Climatisé',
        subtitle: 'Climatisation disponible',
        icon: Icons.ac_unit_rounded),
    TripPreferenceData(
        option: 'chat',
        title: 'Discussion',
        subtitle: 'Ambiance conviviale et bavarde',
        icon: Icons.chat_bubble_outline_rounded),
    TripPreferenceData(
        option: 'no_luggage',
        title: 'Bagages limités',
        subtitle: 'Bagages légers uniquement',
        icon: Icons.luggage_rounded),
    TripPreferenceData(
        option: 'female_only',
        title: 'Femmes seulement',
        subtitle: 'Réservé aux passagères',
        icon: Icons.female_rounded),
    TripPreferenceData(
        option: 'pets',
        title: 'Animaux acceptés',
        subtitle: 'Les animaux de compagnie sont bienvenus',
        icon: Icons.pets_rounded),
    TripPreferenceData(
        option: 'quiet',
        title: 'Silence',
        subtitle: 'Trajet calme, pas de téléphone',
        icon: Icons.volume_off_rounded),
  ];

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveTrip() async {
    if (isSaving.value) return;

    if (selectedDepartureCity.value == null) {
      UIHelper().showSnackBar(
          AppStrings.appName, 'Veuillez sélectionner la commune de départ.', 2);
      return;
    }
    if (selectedDepartureArrondissement.value == null) {
      UIHelper().showSnackBar(AppStrings.appName,
          'Veuillez sélectionner l\'arrondissement de départ.', 2);
      return;
    }
    if (selectedDepartureDistrict.value == null &&
        departureDistrictController.text.trim().isEmpty) {
      UIHelper().showSnackBar(AppStrings.appName,
          'Veuillez sélectionner le quartier de départ.', 2);
      return;
    }
    if (selectedDestinationCity.value == null) {
      UIHelper().showSnackBar(AppStrings.appName,
          'Veuillez sélectionner la commune de destination.', 2);
      return;
    }
    if (selectedDestinationArrondissement.value == null) {
      UIHelper().showSnackBar(AppStrings.appName,
          'Veuillez sélectionner l\'arrondissement de destination.', 2);
      return;
    }
    if (selectedDestinationDistrict.value == null &&
        destinationDistrictController.text.trim().isEmpty) {
      UIHelper().showSnackBar(AppStrings.appName,
          'Veuillez sélectionner le quartier de destination.', 2);
      return;
    }
    if (dateController.text.isEmpty) {
      UIHelper().showSnackBar(
          AppStrings.appName, 'Veuillez sélectionner une date de départ.', 2);
      return;
    }
    if (timeController.text.isEmpty) {
      UIHelper().showSnackBar(
          AppStrings.appName, 'Veuillez sélectionner une heure de départ.', 2);
      return;
    }
    if (selectedVehicle.value == null) {
      UIHelper().showSnackBar(
          AppStrings.appName, 'Veuillez sélectionner un véhicule.', 2);
      return;
    }
    final price = pricePerSeat.value.toInt();
    if (price <= 0) {
      UIHelper().showSnackBar(
          AppStrings.appName, 'Veuillez saisir un prix valide.', 2);
      return;
    }

    isSaving.value = true;

    final dep = selectedDepartureCity.value!;
    final dest = selectedDestinationCity.value!;
    final depNeighborhood = departureDistrictController.text.trim();
    final destNeighborhood = destinationDistrictController.text.trim();

    final payload = <String, dynamic>{
      'vehicle_id': selectedVehicle.value!.id,
      'departure_city': dep,
      if (selectedDepartureArrondissement.value?.isNotEmpty == true)
        'departure_arrondissement': selectedDepartureArrondissement.value,
      if (depNeighborhood.isNotEmpty) 'departure_neighborhood': depNeighborhood,
      if (departurePointController.text.trim().isNotEmpty)
        'departure_point': departurePointController.text.trim(),
      'arrival_city': dest,
      if (selectedDestinationArrondissement.value?.isNotEmpty == true)
        'arrival_arrondissement': selectedDestinationArrondissement.value,
      if (destNeighborhood.isNotEmpty) 'arrival_neighborhood': destNeighborhood,
      if (destinationPointController.text.trim().isNotEmpty)
        'arrival_point': destinationPointController.text.trim(),
      'departure_date': dateController.text,
      'departure_time': timeController.text,
      'total_seats': availableSeats.value,
      'price_per_seat': price,
      'booking_mode': selectedBookingMode.value,
      'cancellation_policy': selectedCancellationPolicy.value,
      'is_recurring': false,
      if (descriptionController.text.trim().isNotEmpty)
        'description': descriptionController.text.trim(),
      'preferences': _buildPreferencesList(),
      if (_durationModifiedByUser && estimatedDurationMinutes != null)
        'estimated_duration_minutes': estimatedDurationMinutes,
    };

    final ApiResult<void> result =
        await _tripsService.updateTrip(_tripUuid, payload);
    isSaving.value = false;

    if (result.isSuccess) {
      AppSync.i.refreshDriver();
      UIHelper().showSnackBar(
          AppStrings.appName, 'Trajet mis à jour avec succès !', 0);
      // Revenir au dashboard (bottom nav) puis basculer sur l'onglet Trajets
      Get.until((route) => route.settings.name == AppRoutes.dashboardDriver);
      Get.find<BottonNavController>().onTabSelected(1);
    } else {
      UIHelper().showSnackBar(AppStrings.appName, result.displayMessage, 2);
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  @override
  void onClose() {
    priceController.removeListener(_onPriceChanged);
    durationController.removeListener(_onDurationChanged);
    departureCityController.dispose();
    departureArrondissementController.dispose();
    departureDistrictController.dispose();
    departurePointController.dispose();
    destinationCityController.dispose();
    destinationArrondissementController.dispose();
    destinationDistrictController.dispose();
    destinationPointController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    priceController.dispose();
    durationController.dispose();
    super.onClose();
  }
}

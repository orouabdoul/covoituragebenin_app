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
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

class AddTrajetController extends GetxController {
  TripsService get _tripsService => Get.find<TripsService>();
  final RoutingService _routing = RoutingService();
  final GeocodingService _geocoding = GeocodingService();

  String? _editUuid;
  bool get isEditMode => _editUuid != null;

  // ── Vehicles ──────────────────────────────────────────────────────────────
  final RxList<VehicleData> availableVehicles = <VehicleData>[].obs;
  final Rx<VehicleData?> selectedVehicle = Rx<VehicleData?>(null);
  final RxBool isLoadingVehicles = false.obs;
  bool hasApprovedVehicle = true;

  // ── Seats, price ──────────────────────────────────────────────────────────
  final RxInt availableSeats = 3.obs;
  final RxDouble pricePerSeat = 5000.0.obs;
  final RxSet<String> selectedOptions = <String>{}.obs;
  final RxBool isPublishing = false.obs;
  final RxBool isLoadingEdit = false.obs;

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
  final RxList<CancellationPolicyOption> cancellationPolicies = <CancellationPolicyOption>[
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
  final TextEditingController departureArrondissementController = TextEditingController();
  final TextEditingController departureDistrictController = TextEditingController();
  final TextEditingController departurePointController = TextEditingController();
  final TextEditingController destinationCityController = TextEditingController();
  final TextEditingController destinationArrondissementController = TextEditingController();
  final TextEditingController destinationDistrictController = TextEditingController();
  final TextEditingController destinationPointController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController priceController = TextEditingController(text: '5000');

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
  // Arrondissements retournés par l'API (ville → liste arrondissements)
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

  // Coordonnées précises calculées lors du géocodage (quartier/arrondissement/ville)
  // ignore: unused_field
  double? _depPreciseLat;
  // ignore: unused_field
  double? _depPreciseLng;
  // ignore: unused_field
  double? _destPreciseLat;

  // ── GPS ───────────────────────────────────────────────────────────────────
  double? _deviceLat;
  double? _deviceLng;
  // ignore: unused_field
  double? _destPreciseLng;

  static Map<String, List<String>> get beninCitiesWithDistricts =>
      BeninLocationHelpers.citiesWithArrondissements;

  List<String> get beninCities {
    final api = _apiCities.toList();
    return api.isNotEmpty ? api : BeninLocationHelpers.cities;
  }

  bool get formTouched =>
      selectedDepartureCity.value != null ||
      selectedDestinationCity.value != null ||
      departureCityController.text.isNotEmpty ||
      destinationCityController.text.isNotEmpty;

  List<String> getArrondissements(String? city) {
    if (city == null) return [];
    // API keys are lowercase (e.g., "cotonou"), display names are title-case
    final apiResult = _apiArrondissements[city.toLowerCase()] ?? _apiArrondissements[city];
    if (apiResult != null) return apiResult;
    return BeninLocations.getArrondissements(city);
  }

  List<String> getQuartiers(String? city, String? arrondissement) =>
      BeninLocations.getQuartiers(city, arrondissement);

  bool cityHasArrondissements(String? city) =>
      BeninLocations.hasArrondissements(city);

  void onDepartureCityChanged(String? city) {
    selectedDepartureCity.value = city;
    selectedDepartureArrondissement.value = null;
    selectedDepartureDistrict.value = null;
    departureCityController.text = city ?? '';
    departureArrondissementController.text = '';
    departureDistrictController.text = '';
    _depPreciseLat = null;
    _depPreciseLng = null;
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
    _destPreciseLat = null;
    _durationModifiedByUser = false;
    _triggerEstimate();
  }

  void onDepartureArrondissementChanged(String? arr) {
    selectedDepartureArrondissement.value = arr;
    selectedDepartureDistrict.value = null;
    departureArrondissementController.text = arr ?? '';
    departureDistrictController.text = '';
    _depPreciseLat = null;
    _depPreciseLng = null;
    _triggerEstimate();
  }

  void onDestinationArrondissementChanged(String? arr) {
    selectedDestinationArrondissement.value = arr;
    selectedDestinationDistrict.value = null;
    destinationArrondissementController.text = arr ?? '';
    destinationDistrictController.text = '';
    _destPreciseLat = null;
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

    // Géocodage précis : Quartier → Arrondissement → Commune
    final depArr = selectedDepartureArrondissement.value;
    final depDist = selectedDepartureDistrict.value;
    final depQuery = [depDist, depArr, dep].where((e) => e != null && e.isNotEmpty).join(', ');
    final depPrecise = await _geocoding.geocodeAddress('$depQuery, Benin');

    final destArr = selectedDestinationArrondissement.value;
    final destDist = selectedDestinationDistrict.value;
    final destQuery = [destDist, destArr, dest].where((e) => e != null && e.isNotEmpty).join(', ');
    final destPrecise = await _geocoding.geocodeAddress('$destQuery, Benin');

    final depLat = depPrecise?.lat ?? depCoordsStatic?.lat;
    final depLng = depPrecise?.lng ?? depCoordsStatic?.lng;
    final destLat = destPrecise?.lat ?? destCoordsStatic?.lat;
    final destLng = destPrecise?.lng ?? destCoordsStatic?.lng;

    // Stocker les coordonnées précises pour les utiliser dans publishTrip()
    _depPreciseLat = depLat;
    _depPreciseLng = depLng;
    _destPreciseLat = destLat;

    // Routage routier réel via OSRM (OpenStreetMap)
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
      logger.w('OSRM unavailable for $dep→$dest, falling back to backend');
    }

    // Fallback : estimation backend
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
      estimatedDurationLabel.value = body['estimated_duration_label'] as String?;
      estimatedDurationMinutes = (body['estimated_duration_minutes'] as num?)?.toInt();
      if (!_durationModifiedByUser && estimatedDurationMinutes != null) {
        _updatingDurationProgrammatically = true;
        durationController.text = estimatedDurationMinutes.toString();
        _updatingDurationProgrammatically = false;
      }
    }
  }

  void onDepartureDistrictChanged(String? district) {
    selectedDepartureDistrict.value = district;
    departureDistrictController.text = district ?? '';
    _depPreciseLat = null;
    _depPreciseLng = null;
    _triggerEstimate();
  }

  void onDestinationDistrictChanged(String? district) {
    selectedDestinationDistrict.value = district;
    destinationDistrictController.text = district ?? '';
    _destPreciseLat = null;
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
    _depPreciseLat = null;
    _depPreciseLng = null;
    _destPreciseLat = null;
    _durationModifiedByUser = false;
    _updatingDurationProgrammatically = true;
    durationController.text = '';
    _updatingDurationProgrammatically = false;
  }

  void onDepartureDistrictTyped() => selectedDepartureDistrict.value = null;
  void onDestinationDistrictTyped() => selectedDestinationDistrict.value = null;

  // ── Preferences ───────────────────────────────────────────────────────────
  final List<TripPreferenceData> preferences = const [
    TripPreferenceData(option: 'no_smoking', title: 'Non-fumeur', subtitle: 'Cigarettes interdites dans le véhicule', icon: Icons.smoke_free_rounded),
    TripPreferenceData(option: 'music', title: 'Musique', subtitle: 'Musique autorisée en trajet', icon: Icons.music_note_rounded),
    TripPreferenceData(option: 'ac', title: 'Climatisé', subtitle: 'Climatisation disponible', icon: Icons.ac_unit_rounded),
    TripPreferenceData(option: 'chat', title: 'Discussion', subtitle: 'Ambiance conviviale et bavarde', icon: Icons.chat_bubble_outline_rounded),
    TripPreferenceData(option: 'no_luggage', title: 'Bagages limités', subtitle: 'Bagages légers uniquement', icon: Icons.luggage_rounded),
    TripPreferenceData(option: 'female_only', title: 'Femmes seulement', subtitle: 'Réservé aux passagères', icon: Icons.female_rounded),
    TripPreferenceData(option: 'pets', title: 'Animaux acceptés', subtitle: 'Les animaux de compagnie sont bienvenus', icon: Icons.pets_rounded),
    TripPreferenceData(option: 'quiet', title: 'Silence', subtitle: 'Trajet calme, pas de téléphone', icon: Icons.volume_off_rounded),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _editUuid = args?['uuid'] as String?;
    selectedOptions.addAll(const {'no_smoking', 'music'});
    priceController.addListener(_onPriceChanged);
    durationController.addListener(_onDurationChanged);
    _fetchDeviceGps();
    if (isEditMode) {
      _loadFormAndEdit();
    } else {
      _loadTripForm();
    }
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      _deviceLat = pos.latitude;
      _deviceLng = pos.longitude;
      logger.d('GPS device: $_deviceLat, $_deviceLng');
    } catch (e) {
      logger.w('_fetchDeviceGps: $e');
    }
  }

  Future<void> _loadTripForm() async {
    isLoadingVehicles.value = true;
    final result = await _tripsService.fetchTripForm();
    isLoadingVehicles.value = false;
    if (!result.isSuccess) {
      UIHelper().showSnackBar(AppStrings.appName, result.displayMessage, 2);
      return;
    }
    _applyFormData(result.data!);
  }

  void _applyFormData(Map<String, dynamic> body) {
    hasApprovedVehicle = (body['has_approved_vehicle'] as bool?) ?? true;

    // Véhicules approuvés
    final rawVehicles = body['vehicles'] as List<dynamic>? ?? [];
    availableVehicles.assignAll(
      rawVehicles
          .map((v) => VehicleData.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
    if (availableVehicles.length == 1) {
      selectedVehicle.value = availableVehicles.first;
    }

    // Villes depuis l'API
    final rawCities = body['cities'] as List<dynamic>? ?? [];
    _apiCities.assignAll(rawCities.whereType<String>().toList());

    // Arrondissements depuis l'API (map ville → liste) — clés normalisées en lowercase
    final rawArr = body['arrondissements'] as Map<String, dynamic>?;
    if (rawArr != null) {
      _apiArrondissements.clear();
      rawArr.forEach((city, list) {
        if (list is List) {
          _apiArrondissements[city.toLowerCase()] = list.whereType<String>().toList();
        }
      });
    }

    // Modes de réservation
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

    // Politiques d'annulation
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

    // Commission
    final commission = body['commission'] as Map<String, dynamic>?;
    if (commission != null) {
      commissionRatePercent = (commission['rate_percent'] as num?)?.toInt() ?? 10;
      driverSharePercent = (commission['driver_share'] as num?)?.toInt() ?? 90;
    }
  }

  Future<void> _loadFormAndEdit() async {
    await _loadTripForm();
    await _loadForEdit();
  }

  Future<void> _loadForEdit() async {
    isLoadingEdit.value = true;
    final result = await _tripsService.fetchTripRaw(_editUuid!);
    isLoadingEdit.value = false;
    if (!result.isSuccess) {
      UIHelper().showSnackBar(AppStrings.appName, result.displayMessage, 2);
      return;
    }
    _prefillFromJson(result.data!);
  }

  void _prefillFromJson(Map<String, dynamic> j) {
    final depCity = j['departure_city'] as String? ?? '';
    departureCityController.text = depCity;
    if (depCity.isNotEmpty) selectedDepartureCity.value = depCity;

    final depArr = (j['departure_arrondissement'] as String?) ?? '';
    departureArrondissementController.text = depArr;
    if (depArr.isNotEmpty) selectedDepartureArrondissement.value = depArr;

    final depDistrict = ((j['departure_neighborhood'] ?? j['departure_district']) as String?) ?? '';
    departureDistrictController.text = depDistrict;
    if (depDistrict.isNotEmpty) selectedDepartureDistrict.value = depDistrict;

    departurePointController.text = j['departure_point'] as String? ?? '';

    // Restaurer les coords précises si disponibles dans les données du trajet
    _depPreciseLat = (j['departure_latitude'] as num?)?.toDouble();
    _depPreciseLng = (j['departure_longitude'] as num?)?.toDouble();

    final destCity = ((j['arrival_city'] ?? j['destination_city']) as String?) ?? '';
    destinationCityController.text = destCity;
    if (destCity.isNotEmpty) selectedDestinationCity.value = destCity;

    final destArr = (j['arrival_arrondissement'] as String?) ?? '';
    destinationArrondissementController.text = destArr;
    if (destArr.isNotEmpty) selectedDestinationArrondissement.value = destArr;

    final destDistrict = ((j['arrival_neighborhood'] ?? j['destination_district']) as String?) ?? '';
    destinationDistrictController.text = destDistrict;
    if (destDistrict.isNotEmpty) selectedDestinationDistrict.value = destDistrict;

    destinationPointController.text =
        ((j['arrival_point'] ?? j['destination_point']) as String?) ?? '';

    _destPreciseLat = (j['arrival_latitude'] as num?)?.toDouble();

    // Date/heure
    final rawDepTime = j['departure_time'] as String? ?? '';
    final rawDepDate = j['departure_date'] as String? ?? '';
    if (rawDepDate.isEmpty && rawDepTime.contains('T')) {
      final dt = DateTime.tryParse(rawDepTime)?.toLocal();
      if (dt != null) {
        dateController.text =
            '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
        timeController.text =
            '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      }
    } else {
      dateController.text = rawDepDate.contains('-') ? _fromIsoDate(rawDepDate) : rawDepDate;
      timeController.text = rawDepTime.length >= 5 ? rawDepTime.substring(0, 5) : rawDepTime;
    }

    availableSeats.value =
        ((j['total_seats'] ?? j['available_seats']) as num?)?.toInt() ?? 4;
    final price = (j['price_per_seat'] as num?)?.toDouble() ?? priceDefault.toDouble();
    pricePerSeat.value = price;
    priceController.text = price.toInt().toString();

    descriptionController.text = j['description'] as String? ?? '';

    final bm = j['booking_mode'] as String?;
    if (bm != null && bm.isNotEmpty) selectedBookingMode.value = bm;
    final cp = j['cancellation_policy'] as String?;
    if (cp != null && cp.isNotEmpty) selectedCancellationPolicy.value = cp;

    final vehicleId = (j['vehicle_id'] as num?)?.toInt();
    if (vehicleId != null) {
      final match = availableVehicles.firstWhereOrNull((v) => v.id == vehicleId);
      if (match != null) selectedVehicle.value = match;
    } else {
      final vehicleUuid = j['vehicle_uuid'] as String?;
      if (vehicleUuid != null && vehicleUuid.isNotEmpty) {
        final match = availableVehicles.firstWhereOrNull((v) => v.uuid == vehicleUuid);
        if (match != null) selectedVehicle.value = match;
      }
    }

    final rawPrefs = j['preferences'];
    if (rawPrefs is List) {
      selectedOptions.clear();
      selectedOptions.addAll(rawPrefs.whereType<String>());
    }
  }

  // Display format DD/MM/YYYY ↔ API format YYYY-MM-DD
  static String _fromIsoDate(String yyyymmdd) {
    final parts = yyyymmdd.split('-');
    if (parts.length != 3) return yyyymmdd;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }

  static String _toIsoDate(String ddmmyyyy) {
    final parts = ddmmyyyy.split('/');
    if (parts.length != 3) return ddmmyyyy;
    return '${parts[2]}-${parts[1]}-${parts[0]}';
  }

  void _onPriceChanged() {
    final raw = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final val = double.tryParse(raw);
    if (val != null && val != pricePerSeat.value) {
      pricePerSeat.value = val;
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
          'MINIZON', 'Places passagers limitées à $max (1 siège réservé au conducteur).', 1);
    } else if (availableSeats.value < 1) {
      availableSeats.value = 1;
    }
  }

  void incrementSeats() {
    if (availableSeats.value < maxPassengers) {
      availableSeats.value = availableSeats.value + 1;
    } else {
      UIHelper().showSnackBar('MINIZON', capacityLabel, 1);
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

  Future<void> publishTrip() async {
    if (isPublishing.value) return;

    if (!hasApprovedVehicle && !isEditMode) {
      UIHelper().showSnackBar(AppStrings.appName,
          'Vous n\'avez pas de véhicule approuvé. Ajoutez-en un dans votre profil.', 2);
      return;
    }
    if (selectedDepartureCity.value == null) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner la commune de départ.', 2);
      return;
    }
    if (selectedDepartureArrondissement.value == null) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner l\'arrondissement de départ.', 2);
      return;
    }
    if (selectedDepartureDistrict.value == null && departureDistrictController.text.trim().isEmpty) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner le quartier de départ.', 2);
      return;
    }
    if (selectedDestinationCity.value == null) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner la commune de destination.', 2);
      return;
    }
    if (selectedDestinationArrondissement.value == null) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner l\'arrondissement de destination.', 2);
      return;
    }
    if (selectedDestinationDistrict.value == null && destinationDistrictController.text.trim().isEmpty) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner le quartier de destination.', 2);
      return;
    }
    if (dateController.text.isEmpty) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner une date de départ.', 2);
      return;
    }
    if (timeController.text.isEmpty) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner une heure de départ.', 2);
      return;
    }
    if (selectedVehicle.value == null) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner un véhicule.', 2);
      return;
    }
    final price = pricePerSeat.value.toInt();
    if (price <= 0) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez saisir un prix valide.', 2);
      return;
    }

    isPublishing.value = true;

    final dep = selectedDepartureCity.value!;
    final dest = selectedDestinationCity.value!;

    final depNeighborhood = departureDistrictController.text.trim();
    final destNeighborhood = destinationDistrictController.text.trim();

    final payload = <String, dynamic>{
      'vehicle_id': selectedVehicle.value!.id,
      'departure_city': dep,
      if (selectedDepartureArrondissement.value?.isNotEmpty == true)
        'departure_arrondissement': selectedDepartureArrondissement.value,
      if (depNeighborhood.isNotEmpty)
        'departure_neighborhood': depNeighborhood,
      if (departurePointController.text.trim().isNotEmpty)
        'departure_point': departurePointController.text.trim(),
      'arrival_city': dest,
      if (selectedDestinationArrondissement.value?.isNotEmpty == true)
        'arrival_arrondissement': selectedDestinationArrondissement.value,
      if (destNeighborhood.isNotEmpty)
        'arrival_neighborhood': destNeighborhood,
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

    final ApiResult<void> result;
    if (isEditMode) {
      result = await _tripsService.updateTrip(_editUuid!, payload);
    } else {
      result = await _tripsService.publishTrip(payload);
    }

    isPublishing.value = false;

    if (result.isSuccess) {
      AppSync.i.refreshDriver();
      UIHelper().showSnackBar(
        AppStrings.appName,
        isEditMode ? 'Trajet mis à jour avec succès !' : 'Trajet publié avec succès !',
        0,
      );
      if (isEditMode) {
        Get.back();
      } else {
        BottonNavController.goToTab(1);
      }
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

// ── Data classes ─────────────────────────────────────────────────────────────

class TripPreferenceData {
  const TripPreferenceData({
    required this.option,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
  final String option;
  final String title;
  final String subtitle;
  final IconData icon;
}

class BookingModeOption {
  const BookingModeOption({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
  });
  final String mode;
  final String title;
  final String description;
  final String icon;
}

class CancellationPolicyOption {
  const CancellationPolicyOption({
    required this.policy,
    required this.title,
    required this.description,
  });
  final String policy;
  final String title;
  final String description;
}

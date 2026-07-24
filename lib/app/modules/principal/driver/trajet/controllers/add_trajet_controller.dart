import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/benin_locations_data.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/vehicle_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

class AddTrajetController extends GetxController {
  TripsService get _tripsService => Get.find<TripsService>();

  String? _editUuid;
  bool get isEditMode => _editUuid != null;

  // ── Vehicles ──────────────────────────────────────────────────────────────
  final RxList<VehicleData> availableVehicles = <VehicleData>[].obs;
  final Rx<VehicleData?> selectedVehicle = Rx<VehicleData?>(null);
  final RxBool isLoadingVehicles = false.obs;
  bool hasApprovedVehicle = true;

  // ── Seats, price ──────────────────────────────────────────────────────────
  final RxInt availableSeats = 4.obs;
  final RxDouble pricePerSeat = 5000.0.obs;
  final RxSet<String> selectedOptions = <String>{}.obs;
  final RxBool isPublishing = false.obs;
  final RxBool isLoadingEdit = false.obs;

  // ── Price suggestion from API ─────────────────────────────────────────────
  int priceDefault = 5000;
  int priceMin = 500;
  int priceMax = 50000;

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
  final TextEditingController departureDistrictController = TextEditingController();
  final TextEditingController departurePointController = TextEditingController();
  final TextEditingController destinationCityController = TextEditingController();
  final TextEditingController destinationDistrictController = TextEditingController();
  final TextEditingController destinationPointController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController priceController = TextEditingController(text: '5000');

  int get totalAmount => availableSeats.value * pricePerSeat.value.toInt();
  int get maxPassengers => selectedVehicle.value?.availableSeats ?? 4;
  String get capacityLabel {
    final v = selectedVehicle.value;
    if (v == null) return 'Sélectionnez un véhicule';
    return '${v.brand} ${v.model} — ${v.availableSeats} places max';
  }

  // ── Villes & quartiers ────────────────────────────────────────────────────
  final RxList<String> _apiCities = <String>[].obs;
  final RxnString selectedDepartureCity = RxnString();
  final RxnString selectedDepartureDistrict = RxnString();
  final RxnString selectedDestinationCity = RxnString();
  final RxnString selectedDestinationDistrict = RxnString();

  static Map<String, List<String>> get beninCitiesWithDistricts =>
      BeninLocations.citiesWithDistricts;

  List<String> get beninCities {
    final api = _apiCities.toList();
    return api.isNotEmpty ? api : BeninLocations.cities;
  }

  List<String> getDistricts(String? city) => BeninLocations.getDistricts(city);

  void onDepartureCityChanged(String? city) {
    selectedDepartureCity.value = city;
    selectedDepartureDistrict.value = null;
    departureCityController.text = city ?? '';
    departureDistrictController.text = '';
  }

  void onDestinationCityChanged(String? city) {
    selectedDestinationCity.value = city;
    selectedDestinationDistrict.value = null;
    destinationCityController.text = city ?? '';
    destinationDistrictController.text = '';
  }

  void onDepartureDistrictChanged(String? district) {
    selectedDepartureDistrict.value = district;
    departureDistrictController.text = district ?? '';
  }

  void onDestinationDistrictChanged(String? district) {
    selectedDestinationDistrict.value = district;
    destinationDistrictController.text = district ?? '';
  }

  void onDepartureCityTyped() {
    selectedDepartureCity.value = null;
    selectedDepartureDistrict.value = null;
    departureDistrictController.text = '';
  }

  void onDestinationCityTyped() {
    selectedDestinationCity.value = null;
    selectedDestinationDistrict.value = null;
    destinationDistrictController.text = '';
  }

  void onDepartureDistrictTyped() => selectedDepartureDistrict.value = null;
  void onDestinationDistrictTyped() => selectedDestinationDistrict.value = null;

  // ── Preferences (static — driven by API trip-form icons) ──────────────────
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
    if (isEditMode) {
      _loadFormAndEdit();
    } else {
      _loadTripForm();
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

    // Vehicles (approved only)
    final rawVehicles = body['vehicles'] as List<dynamic>? ?? [];
    availableVehicles.assignAll(
      rawVehicles
          .map((v) => VehicleData.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
    if (availableVehicles.length == 1) {
      selectedVehicle.value = availableVehicles.first;
    }

    // Cities from API
    final rawCities = body['cities'] as List<dynamic>? ?? [];
    _apiCities.assignAll(rawCities.whereType<String>().toList());

    // Booking modes from API
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

    // Cancellation policies from API
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

    // Price suggestion from API
    final priceSuggestion = body['price_suggestion'] as Map<String, dynamic>?;
    if (priceSuggestion != null) {
      priceDefault = (priceSuggestion['default'] as num?)?.toInt() ?? 5000;
      priceMin = (priceSuggestion['min'] as num?)?.toInt() ?? 500;
      priceMax = (priceSuggestion['max'] as num?)?.toInt() ?? 50000;
      if (!isEditMode) {
        pricePerSeat.value = priceDefault.toDouble();
        priceController.text = priceDefault.toString();
      }
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
    if (depCity.isNotEmpty) {
      selectedDepartureCity.value = depCity;
    }

    final depDistrict = ((j['departure_neighborhood'] ?? j['departure_district']) as String?) ?? '';
    departureDistrictController.text = depDistrict;
    if (depDistrict.isNotEmpty) selectedDepartureDistrict.value = depDistrict;

    departurePointController.text = j['departure_point'] as String? ?? '';

    final destCity = ((j['arrival_city'] ?? j['destination_city']) as String?) ?? '';
    destinationCityController.text = destCity;
    if (destCity.isNotEmpty) {
      selectedDestinationCity.value = destCity;
    }

    final destDistrict = ((j['arrival_neighborhood'] ?? j['destination_district']) as String?) ?? '';
    destinationDistrictController.text = destDistrict;
    if (destDistrict.isNotEmpty) selectedDestinationDistrict.value = destDistrict;

    destinationPointController.text =
        ((j['arrival_point'] ?? j['destination_point']) as String?) ?? '';

    // Handles both ISO datetime ("2026-07-24T07:00:00Z") and separate date/time fields
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

    // Booking mode & cancellation policy from trip data
    final bm = j['booking_mode'] as String?;
    if (bm != null && bm.isNotEmpty) selectedBookingMode.value = bm;
    final cp = j['cancellation_policy'] as String?;
    if (cp != null && cp.isNotEmpty) selectedCancellationPolicy.value = cp;

    // Match vehicle: try by integer id first, then by uuid
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

    // Preferences: list of API option strings
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
      UIHelper().showSnackBar('MINIZON', 'Places limitées à $max (capacité du véhicule).', 1);
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
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner la ville de départ.', 2);
      return;
    }
    if (selectedDepartureDistrict.value == null) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner le quartier de départ.', 2);
      return;
    }
    if (selectedDestinationCity.value == null) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez sélectionner la ville de destination.', 2);
      return;
    }
    if (selectedDestinationDistrict.value == null) {
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
    if (price < priceMin) {
      UIHelper().showSnackBar(AppStrings.appName, 'Le prix minimum est de $priceMin FCFA.', 2);
      return;
    }
    if (price > priceMax) {
      UIHelper().showSnackBar(AppStrings.appName, 'Le prix maximum est de $priceMax FCFA.', 2);
      return;
    }

    isPublishing.value = true;

    final payload = {
      'vehicle_id': selectedVehicle.value!.id,
      'departure_city': selectedDepartureCity.value!,
      'departure_neighborhood': departureDistrictController.text.trim(),
      'departure_point': departurePointController.text.trim(),
      'arrival_city': selectedDestinationCity.value!,
      'arrival_neighborhood': destinationDistrictController.text.trim(),
      'arrival_point': destinationPointController.text.trim(),
      'departure_date': dateController.text,
      'departure_time': timeController.text,
      'total_seats': availableSeats.value,
      'price_per_seat': price,
      'booking_mode': selectedBookingMode.value,
      'max_per_booking': 2,
      'cancellation_policy': selectedCancellationPolicy.value,
      'is_recurring': false,
      'description': descriptionController.text.trim(),
      'preferences': _buildPreferencesList(),
      'is_published': true,
    };

    final ApiResult<void> result;
    if (isEditMode) {
      result = await _tripsService.updateTrip(_editUuid!, payload);
    } else {
      result = await _tripsService.publishTrip(payload);
    }

    isPublishing.value = false;

    if (result.isSuccess) {
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
    departureCityController.dispose();
    departureDistrictController.dispose();
    departurePointController.dispose();
    destinationCityController.dispose();
    destinationDistrictController.dispose();
    destinationPointController.dispose();
    descriptionController.dispose();
    dateController.dispose();
    timeController.dispose();
    priceController.dispose();
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

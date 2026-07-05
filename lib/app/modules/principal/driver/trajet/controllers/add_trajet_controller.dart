import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/vehicles/vehicles_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/api_result.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/vehicle_model.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

enum TripLuggageOption { smallBag, stops, smoking, music, airConditioning }

class AddTrajetController extends GetxController {
  TripsService get _tripsService => Get.find<TripsService>();
  VehiclesService get _vehiclesService => Get.find<VehiclesService>();

  String? _editUuid;
  bool get isEditMode => _editUuid != null;

  // ── Vehicles ──────────────────────────────────────────────────────────────
  final RxList<VehicleData> availableVehicles = <VehicleData>[].obs;
  final Rx<VehicleData?> selectedVehicle = Rx<VehicleData?>(null);
  final RxBool isLoadingVehicles = false.obs;

  // ── Seats, price, options ─────────────────────────────────────────────────
  final RxInt availableSeats = 4.obs;
  final RxDouble pricePerSeat = 5000.0.obs;
  final RxSet<TripLuggageOption> selectedOptions = <TripLuggageOption>{}.obs;
  final RxBool isPublishing = false.obs;
  final RxBool isLoadingEdit = false.obs;

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

  final List<String> departureSuggestions = const ['Cotonou', 'Porto-Novo', 'Parakou'];
  final List<String> destinationSuggestions = const ['Parakou', 'Abomey', 'Bohicon'];

  final List<TripFieldGroup> fieldGroups = const [
    TripFieldGroup(title: 'Départ', subtitle: "D'où partez-vous ?", icon: Icons.trip_origin_rounded),
    TripFieldGroup(title: 'Destination', subtitle: 'Où allez-vous ?', icon: Icons.flag_rounded),
    TripFieldGroup(title: 'Date et Heure', subtitle: 'Quand partez-vous ?', icon: Icons.schedule_rounded),
    TripFieldGroup(title: 'Votre véhicule', subtitle: 'Sélectionnez votre véhicule', icon: Icons.directions_car_rounded),
    TripFieldGroup(title: 'Places disponibles', subtitle: 'Combien de passagers ?', icon: Icons.airline_seat_recline_normal_rounded),
    TripFieldGroup(title: 'Prix par place', subtitle: 'Fixez votre tarif', icon: Icons.payments_rounded),
    TripFieldGroup(title: 'Description', subtitle: 'Optionnel', icon: Icons.notes_rounded),
    TripFieldGroup(title: 'Préférences', subtitle: 'Configurez votre trajet', icon: Icons.tune_rounded),
  ];

  final List<TripPreferenceData> preferences = const [
    TripPreferenceData(option: TripLuggageOption.smallBag, title: 'Bagages autorisés', subtitle: 'Petits sacs acceptés', icon: Icons.work_outline_rounded),
    TripPreferenceData(option: TripLuggageOption.stops, title: 'Arrêts possibles', subtitle: 'Flexibilité trajet', icon: Icons.alt_route_rounded),
    TripPreferenceData(option: TripLuggageOption.smoking, title: 'Non-fumeur', subtitle: 'Trajet sans tabac', icon: Icons.smoke_free_rounded),
    TripPreferenceData(option: TripLuggageOption.music, title: 'Musique', subtitle: 'Ambiance musicale', icon: Icons.music_note_rounded),
    TripPreferenceData(option: TripLuggageOption.airConditioning, title: 'Climatisation', subtitle: 'Confort climatique', icon: Icons.ac_unit_rounded),
  ];

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    _editUuid = args?['uuid'] as String?;
    selectedOptions.addAll(const {
      TripLuggageOption.smallBag,
      TripLuggageOption.smoking,
      TripLuggageOption.music,
    });
    priceController.addListener(_onPriceChanged);
    if (isEditMode) {
      _loadVehiclesAndEdit();
    } else {
      _loadVehicles();
    }
  }

  Future<void> _loadVehicles() async {
    isLoadingVehicles.value = true;
    final result = await _vehiclesService.listVehicles();
    isLoadingVehicles.value = false;
    if (result.isSuccess && result.data != null) {
      availableVehicles.assignAll(result.data!);
      if (availableVehicles.length == 1) {
        selectedVehicle.value = availableVehicles.first;
      }
    }
  }

  Future<void> _loadVehiclesAndEdit() async {
    await _loadVehicles();
    await _loadForEdit();
  }

  Future<void> _loadForEdit() async {
    isLoadingEdit.value = true;
    final result = await _tripsService.fetchTripRaw(_editUuid!);
    isLoadingEdit.value = false;
    if (!result.isSuccess) {
      UIHelper().showSnackBar(AppStrings.appName, result.error!.message, 2);
      return;
    }
    _prefillFromJson(result.data!);
  }

  void _prefillFromJson(Map<String, dynamic> j) {
    departureCityController.text = j['departure_city'] as String? ?? '';
    departureDistrictController.text =
        ((j['departure_neighborhood'] ?? j['departure_district']) as String?) ?? '';
    departurePointController.text = j['departure_point'] as String? ?? '';
    destinationCityController.text =
        ((j['arrival_city'] ?? j['destination_city']) as String?) ?? '';
    destinationDistrictController.text =
        ((j['arrival_neighborhood'] ?? j['destination_district']) as String?) ?? '';
    destinationPointController.text =
        ((j['arrival_point'] ?? j['destination_point']) as String?) ?? '';
    // Accept both DD/MM/YYYY and YYYY-MM-DD
    final rawDate = j['departure_date'] as String? ?? '';
    dateController.text = rawDate.contains('-') ? _fromIsoDate(rawDate) : rawDate;
    timeController.text = j['departure_time'] as String? ?? '';
    availableSeats.value =
        ((j['total_seats'] ?? j['available_seats']) as num?)?.toInt() ?? 4;
    final price = (j['price_per_seat'] as num?)?.toDouble() ?? 5000;
    pricePerSeat.value = price;
    priceController.text = price.toInt().toString();
    descriptionController.text = j['description'] as String? ?? '';
    // Match vehicle by uuid if returned by API
    final vehicleUuid = j['vehicle_uuid'] as String?;
    if (vehicleUuid != null && vehicleUuid.isNotEmpty) {
      final match = availableVehicles.firstWhereOrNull((v) => v.uuid == vehicleUuid);
      if (match != null) selectedVehicle.value = match;
    }
    // Preferences: list of strings (new) or map of booleans (old)
    final rawPrefs = j['preferences'];
    if (rawPrefs is List) {
      selectedOptions.clear();
      for (final p in rawPrefs) {
        switch (p as String?) {
          case 'allows_bags': selectedOptions.add(TripLuggageOption.smallBag); break;
          case 'allows_stops': selectedOptions.add(TripLuggageOption.stops); break;
          case 'no_smoking': selectedOptions.add(TripLuggageOption.smoking); break;
          case 'music': selectedOptions.add(TripLuggageOption.music); break;
          case 'air_conditioning': selectedOptions.add(TripLuggageOption.airConditioning); break;
        }
      }
    } else if (rawPrefs is Map) {
      selectedOptions.clear();
      if (rawPrefs['allows_bags'] == true) selectedOptions.add(TripLuggageOption.smallBag);
      if (rawPrefs['allows_stops'] == true) selectedOptions.add(TripLuggageOption.stops);
      if (rawPrefs['no_smoking'] == true) selectedOptions.add(TripLuggageOption.smoking);
      if (rawPrefs['music'] == true) selectedOptions.add(TripLuggageOption.music);
      if (rawPrefs['air_conditioning'] == true) selectedOptions.add(TripLuggageOption.airConditioning);
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

  void toggleOption(TripLuggageOption option) {
    if (selectedOptions.contains(option)) {
      selectedOptions.remove(option);
    } else {
      selectedOptions.add(option);
    }
  }

  // Seules valeurs acceptées par le backend : no_smoking, music
  List<String> _buildPreferencesList() => [
    if (selectedOptions.contains(TripLuggageOption.smoking)) 'no_smoking',
    if (selectedOptions.contains(TripLuggageOption.music)) 'music',
  ];

  Future<void> publishTrip() async {
    if (isPublishing.value) return;

    final depCity = departureCityController.text.trim();
    final destCity = destinationCityController.text.trim();
    if (depCity.isEmpty) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez entrer la ville de départ.', 2);
      return;
    }
    if (destCity.isEmpty) {
      UIHelper().showSnackBar(AppStrings.appName, 'Veuillez entrer la ville de destination.', 2);
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

    isPublishing.value = true;

    final payload = {
      'vehicle_id': selectedVehicle.value!.id,
      'departure_city': depCity,
      'departure_neighborhood': departureDistrictController.text.trim(),
      'departure_point': departurePointController.text.trim(),
      'arrival_city': destCity,
      'arrival_neighborhood': destinationDistrictController.text.trim(),
      'arrival_point': destinationPointController.text.trim(),
      'departure_date': dateController.text, // déjà en DD/MM/YYYY depuis le picker
      'departure_time': timeController.text,
      'total_seats': availableSeats.value,
      'price_per_seat': pricePerSeat.value.toInt(),
      'booking_mode': 'instant',
      'max_per_booking': 2,
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
      UIHelper().showSnackBar(AppStrings.appName, result.error!.message, 2);
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

class TripFieldGroup {
  const TripFieldGroup({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;
}

class TripPreferenceData {
  const TripPreferenceData({required this.option, required this.title, required this.subtitle, required this.icon});
  final TripLuggageOption option;
  final String title;
  final String subtitle;
  final IconData icon;
}

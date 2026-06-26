import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum TripVehicleType { car, moto }

enum TripLuggageOption { smallBag, stops, smoking, music, airConditioning }

// ── Règlementation Bénin ─────────────────────────────────────────────────────
// Code de la Route CEDEAO + arrêtés MTPT (Ministère des Transports)
// Motos    : conducteur + 1 passager maximum (zémidjan inclus)
// Citadine : ≤ 5 places totales  → max 3 passagers proposables
// Berline  : 5 places            → max 4 passagers
// SUV/4x4  : ≤ 7 places          → max 5 passagers (si 7 places → 6)
// Van      : ≤ 9 places          → max 8 passagers
class VehicleCapacity {
  const VehicleCapacity({
    required this.category,
    required this.maxPassengers,
    required this.label,
  });
  final String category;
  final int maxPassengers;
  final String label;
}

class AddTrajetController extends GetxController {
  final Rx<TripVehicleType> selectedVehicleType = TripVehicleType.car.obs;
  final RxnString selectedBrand = RxnString();
  final RxnString selectedModel = RxnString();
  final RxInt availableSeats = 4.obs;
  final RxDouble pricePerSeat = 5000.0.obs;
  final RxSet<TripLuggageOption> selectedOptions = <TripLuggageOption>{}.obs;

  // Location controllers
  final TextEditingController departureCityController = TextEditingController();
  final TextEditingController departureDistrictController = TextEditingController();
  final TextEditingController departurePointController = TextEditingController();
  final TextEditingController destinationCityController = TextEditingController();
  final TextEditingController destinationDistrictController = TextEditingController();
  final TextEditingController destinationPointController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  // Date/time controllers
  final TextEditingController dateController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  // Price controller — synced to pricePerSeat
  final TextEditingController priceController = TextEditingController(text: '5000');

  int get totalAmount => availableSeats.value * pricePerSeat.value.toInt();

  // ── Données marques / modèles voitures ────────────────────────────────────

  static const Map<String, List<String>> _carBrandModels = {
    'Toyota':     ['Corolla', 'Camry', 'Yaris', 'Avensis', 'RAV4', 'Fortuner', 'Prado', 'Land Cruiser', 'Hilux'],
    'Honda':      ['Fit', 'Jazz', 'Civic', 'Accord', 'HR-V', 'CR-V'],
    'Hyundai':    ['i10', 'i20', 'Accent', 'Elantra', 'i30', 'Tucson', 'Santa Fe'],
    'KIA':        ['Picanto', 'Rio', 'Ceed', 'Sportage', 'Sorento'],
    'Peugeot':    ['206', '207', '208', '306', '307', '308', '406', '407', '508', '3008', '5008'],
    'Renault':    ['Clio', 'Sandero', 'Logan', 'Symbol', 'Mégane', 'Laguna', 'Duster'],
    'Volkswagen': ['Polo', 'Golf', 'Jetta', 'Passat', 'Tiguan', 'Touareg'],
    'Nissan':     ['Micra', 'Note', 'Almera', 'Tiida', 'Qashqai', 'X-Trail', 'Pathfinder'],
    'Ford':       ['Fiesta', 'Focus', 'Mondeo', 'EcoSport', 'Ranger', 'Explorer'],
    'Suzuki':     ['Alto', 'Swift', 'Baleno', 'Vitara', 'Jimny'],
    'BMW':        ['Série 1', 'Série 3', 'Série 5', 'X1', 'X3', 'X5'],
    'Mercedes':   ['Classe A', 'Classe C', 'Classe E', 'GLC', 'GLE', 'Vito'],
  };

  static const Map<String, List<String>> _motoBrandModels = {
    'Honda':  ['Wave 110', 'CG 150', 'Shine 125', 'CB 125', 'CB 150', 'XR 150', 'CB 300'],
    'Yamaha': ['Saluto 125', 'YBR 125', 'FZ 150', 'Fazer 150', 'R15', 'MT-07'],
    'Suzuki': ['Hayate', 'EN 125', 'GN 125', 'GS 150', 'Bandit 150'],
    'TVS':    ['Sport 100', 'Metro 100', 'Star City 125', 'Apache 160'],
    'Bajaj':  ['Platina', 'Discover 125', 'Pulsar 125', 'Pulsar 150'],
    'Kymco':  ['Like 125', 'Agility 125', 'Elegance 150', 'Super 8'],
    'Lifan':  ['LF 110', 'LF 125', 'LF 150', 'KP 150'],
    'Loncin': ['LX 110', 'LX 150', 'GP 250'],
  };

  // ── Limites légales Bénin par modèle ─────────────────────────────────────
  // Nombre de PASSAGERS (places offertes, hors conducteur)

  static const Map<String, int> _modelMaxPassengers = {
    // -- Motos : 1 passager max (Art. 142 Code Route CEDEAO) --
    'Wave 110': 1, 'CG 150': 1, 'Shine 125': 1, 'CB 125': 1, 'CB 150': 1,
    'XR 150': 1, 'CB 300': 1,
    'Saluto 125': 1, 'YBR 125': 1, 'FZ 150': 1, 'Fazer 150': 1, 'R15': 1, 'MT-07': 1,
    'Hayate': 1, 'EN 125': 1, 'GN 125': 1, 'GS 150': 1, 'Bandit 150': 1,
    'Sport 100': 1, 'Metro 100': 1, 'Star City 125': 1, 'Apache 160': 1,
    'Platina': 1, 'Discover 125': 1, 'Pulsar 125': 1, 'Pulsar 150': 1,
    'Like 125': 1, 'Agility 125': 1, 'Elegance 150': 1, 'Super 8': 1,
    'LF 110': 1, 'LF 125': 1, 'LF 150': 1, 'KP 150': 1,
    'LX 110': 1, 'LX 150': 1, 'GP 250': 1,

    // -- Citadines 4 places (conducteur + 3 max) --
    'Yaris': 3, 'i10': 3, 'Picanto': 3, 'Alto': 3, 'Jazz': 3, 'Fit': 3,
    'Jimny': 3,

    // -- Berlines / Compactes 5 places (conducteur + 4 max) --
    'Corolla': 4, 'Avensis': 4, 'Camry': 4, 'Hilux': 4,
    'Civic': 4, 'Accord': 4, 'HR-V': 4, 'CR-V': 4,
    'Accent': 4, 'Elantra': 4, 'i20': 4, 'i30': 4, 'Tucson': 4,
    'Rio': 4, 'Ceed': 4, 'Sportage': 4,
    '206': 4, '207': 4, '208': 4, '306': 4, '307': 4,
    '308': 4, '406': 4, '407': 4, '508': 4, '3008': 4,
    'Clio': 4, 'Sandero': 4, 'Logan': 4, 'Symbol': 4, 'Mégane': 4, 'Laguna': 4,
    'Duster': 4,
    'Polo': 4, 'Golf': 4, 'Jetta': 4, 'Passat': 4, 'Tiguan': 4,
    'Micra': 4, 'Note': 4, 'Almera': 4, 'Tiida': 4, 'Qashqai': 4, 'X-Trail': 4,
    'Fiesta': 4, 'Focus': 4, 'Mondeo': 4, 'EcoSport': 4, 'Ranger': 4,
    'Swift': 4, 'Baleno': 4, 'Vitara': 4,
    'Série 1': 4, 'Série 3': 4, 'Série 5': 4, 'X1': 4, 'X3': 4,
    'Classe A': 4, 'Classe C': 4, 'Classe E': 4, 'GLC': 4,

    // -- SUV 7 places (conducteur + 6 max) --
    'RAV4': 5, 'Fortuner': 6, 'Prado': 6, 'Land Cruiser': 6,
    'Santa Fe': 6, 'Sorento': 6,
    'Pathfinder': 6, 'Explorer': 6,
    'Touareg': 5, 'X5': 5, 'GLE': 5, '5008': 6,

    // -- Van / Minibus (conducteur + 8 max) --
    'Vito': 8,
  };

  // ── Infos règlementation affichée ─────────────────────────────────────────

  int get maxPassengers {
    if (selectedVehicleType.value == TripVehicleType.moto) return 1;
    final model = selectedModel.value;
    if (model == null) return 4;
    return _modelMaxPassengers[model] ?? 4;
  }

  String get capacityLabel {
    final m = maxPassengers;
    if (m == 1) return 'Moto — 1 passager max (Code Route Art. 142)';
    if (m == 3) return 'Citadine — 3 passagers max (4 places)';
    if (m == 4) return 'Berline/Compacte — 4 passagers max (5 places)';
    if (m == 5) return 'SUV 5 places — 4 passagers max';
    if (m == 6) return 'Grand SUV 7 places — 6 passagers max';
    if (m == 8) return 'Van/Minibus — 8 passagers max';
    return '$m passagers max selon la réglementation';
  }

  // ── Données statiques ─────────────────────────────────────────────────────

  List<String> get brandsForType {
    return selectedVehicleType.value == TripVehicleType.moto
        ? _motoBrandModels.keys.toList()
        : _carBrandModels.keys.toList();
  }

  List<String> get modelsForBrand {
    final brand = selectedBrand.value;
    if (brand == null) return [];
    final map = selectedVehicleType.value == TripVehicleType.moto
        ? _motoBrandModels
        : _carBrandModels;
    return map[brand] ?? [];
  }

  final List<String> departureSuggestions = const ['Cotonou', 'Porto-Novo', 'Parakou'];
  final List<String> destinationSuggestions = const ['Parakou', 'Abomey', 'Bohicon'];

  final List<TripFieldGroup> fieldGroups = const [
    TripFieldGroup(title: 'Départ', subtitle: "D'où partez-vous ?", icon: Icons.trip_origin_rounded),
    TripFieldGroup(title: 'Destination', subtitle: 'Où allez-vous ?', icon: Icons.flag_rounded),
    TripFieldGroup(title: 'Date et Heure', subtitle: 'Quand partez-vous ?', icon: Icons.schedule_rounded),
    TripFieldGroup(title: 'Votre véhicule', subtitle: 'Sélectionnez ou ajoutez', icon: Icons.directions_car_rounded),
    TripFieldGroup(title: 'Places disponibles', subtitle: 'Combien de passagers ?', icon: Icons.airline_seat_recline_normal_rounded),
    TripFieldGroup(title: 'Prix par place', subtitle: 'Fixez votre tarif', icon: Icons.payments_rounded),
    TripFieldGroup(title: 'Description', subtitle: 'Optionnel', icon: Icons.notes_rounded),
    TripFieldGroup(title: 'Préférences', subtitle: 'Configurez votre trajet', icon: Icons.tune_rounded),
  ];

  final List<TripVehicleCardData> vehicleCards = const [
    TripVehicleCardData(type: TripVehicleType.car, title: 'Voiture', icon: Icons.directions_car_rounded, selected: true),
    TripVehicleCardData(type: TripVehicleType.moto, title: 'Moto', icon: Icons.two_wheeler_rounded, selected: false),
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
    selectedOptions.addAll(const {
      TripLuggageOption.smallBag,
      TripLuggageOption.smoking,
      TripLuggageOption.music,
    });
    priceController.addListener(_onPriceChanged);
  }

  void _onPriceChanged() {
    final raw = priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final val = double.tryParse(raw);
    if (val != null && val != pricePerSeat.value) {
      pricePerSeat.value = val;
    }
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void selectVehicleType(TripVehicleType type) {
    if (selectedVehicleType.value == type) return;
    selectedVehicleType.value = type;
    selectedBrand.value = null;
    selectedModel.value = null;
    _applySeatsLimit();
  }

  void selectBrand(String brand) {
    selectedBrand.value = brand;
    selectedModel.value = null;
    // Ne pas encore limiter — attendre le modèle
  }

  void selectModel(String model) {
    selectedModel.value = model;
    _applySeatsLimit();
  }

  void _applySeatsLimit() {
    final max = maxPassengers;
    if (availableSeats.value > max) {
      availableSeats.value = max;
      UIHelper().showSnackBar(
        'MINIZON',
        'Places limitées à $max selon la réglementation béninoise.',
        1,
      );
    } else if (availableSeats.value < 1) {
      availableSeats.value = 1;
    }
  }

  void incrementSeats() {
    if (availableSeats.value < maxPassengers) {
      availableSeats.value = availableSeats.value + 1;
    } else {
      UIHelper().showSnackBar(
        'MINIZON',
        capacityLabel,
        1,
      );
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

  void publishTrip() {
    UIHelper().showSnackBar(AppStrings.appName, 'Trajet prêt à être publié.', 0);
    Get.offNamed(AppRoutes.driverTrips);
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

class TripVehicleCardData {
  const TripVehicleCardData({required this.type, required this.title, required this.icon, required this.selected});
  final TripVehicleType type;
  final String title;
  final IconData icon;
  final bool selected;
}

class TripPreferenceData {
  const TripPreferenceData({required this.option, required this.title, required this.subtitle, required this.icon});
  final TripLuggageOption option;
  final String title;
  final String subtitle;
  final IconData icon;
}

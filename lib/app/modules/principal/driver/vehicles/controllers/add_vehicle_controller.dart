import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/providers/vehicles_provider.dart';

enum VehicleType { car, motorcycle }

class VehicleColorOption {
  final String label;
  final Color color;
  const VehicleColorOption({required this.label, required this.color});
}

class AddVehicleController extends GetxController {
  final _provider = VehiclesProvider();

  final licensePlateController = TextEditingController();
  final yearController         = TextEditingController();

  final selectedVehicleType = Rxn<VehicleType>(VehicleType.car);
  final selectedBrand       = RxnString();
  final selectedModel       = RxnString();
  final selectedColor       = RxnString();
  final selectedFuel        = RxnString();
  final seatsCount          = RxInt(4);
  final isSubmitting        = false.obs;

  // ── Vehicle photos ──────────────────────────────────────────────────────────

  final _vehiclePhotos = <String, XFile>{};
  final photoCount     = 0.obs;

  bool hasVehiclePhoto(String slot) => _vehiclePhotos.containsKey(slot);

  Future<void> pickVehiclePhoto(String slot, ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (file == null) return;
    _vehiclePhotos[slot] = file;
    photoCount.value = _vehiclePhotos.length;
  }

  // ── Brand / model data ──────────────────────────────────────────────────────

  static const Map<String, List<String>> carBrandModels = {
    'Toyota':     ['Corolla', 'Camry', 'RAV4', 'Hilux', 'Land Cruiser', 'Yaris', 'Avensis', 'Fortuner', 'Prado'],
    'Peugeot':    ['206', '207', '208', '306', '307', '308', '406', '407', '508', '3008', '5008'],
    'Renault':    ['Clio', 'Mégane', 'Laguna', 'Duster', 'Logan', 'Symbol', 'Sandero'],
    'Honda':      ['Civic', 'Accord', 'CR-V', 'HR-V', 'Jazz', 'Fit'],
    'Hyundai':    ['Accent', 'Elantra', 'Tucson', 'Santa Fe', 'i10', 'i20', 'i30'],
    'Nissan':     ['Almera', 'Tiida', 'X-Trail', 'Qashqai', 'Note', 'Micra', 'Pathfinder'],
    'Ford':       ['Fiesta', 'Focus', 'Mondeo', 'Ranger', 'EcoSport', 'Explorer'],
    'Volkswagen': ['Golf', 'Polo', 'Passat', 'Tiguan', 'Jetta', 'Touareg'],
    'Mercedes':   ['Classe A', 'Classe C', 'Classe E', 'GLC', 'GLE', 'Vito'],
    'BMW':        ['Série 1', 'Série 3', 'Série 5', 'X1', 'X3', 'X5'],
    'KIA':        ['Picanto', 'Rio', 'Sportage', 'Sorento', 'Ceed'],
    'Suzuki':     ['Swift', 'Vitara', 'Jimny', 'Alto', 'Baleno'],
  };

  static const Map<String, List<String>> motoBrandModels = {
    'Honda':  ['CB 125', 'CB 150', 'XR 150', 'Wave 110', 'CB 300', 'CG 150', 'Shine 125'],
    'Yamaha': ['YBR 125', 'FZ 150', 'Fazer 150', 'MT-07', 'R15', 'Saluto 125'],
    'Suzuki': ['GS 150', 'EN 125', 'GN 125', 'Bandit 150', 'Hayate'],
    'TVS':    ['Apache 160', 'Star City 125', 'Sport 100', 'Metro 100'],
    'Bajaj':  ['Pulsar 125', 'Pulsar 150', 'Discover 125', 'Platina'],
    'Kymco':  ['Agility 125', 'Elegance 150', 'Like 125', 'Super 8'],
    'Lifan':  ['LF 110', 'LF 125', 'LF 150', 'KP 150'],
    'Loncin': ['LX 110', 'LX 150', 'GP 250'],
  };

  List<String> get brandsForType {
    return selectedVehicleType.value == VehicleType.motorcycle
        ? motoBrandModels.keys.toList()
        : carBrandModels.keys.toList();
  }

  List<String> get modelsForBrand {
    final brand = selectedBrand.value;
    if (brand == null) return [];
    final map = selectedVehicleType.value == VehicleType.motorcycle
        ? motoBrandModels
        : carBrandModels;
    return map[brand] ?? [];
  }

  // ── Options ─────────────────────────────────────────────────────────────────

  static const List<String> fuelOptions = [
    'Essence',
    'Diesel',
    'Hybride',
    'Électrique',
    'GPL',
  ];

  static const List<VehicleColorOption> colorOptions = [
    VehicleColorOption(label: 'Blanc',  color: Color(0xFFFFFFFF)),
    VehicleColorOption(label: 'Noir',   color: Color(0xFF1F2937)),
    VehicleColorOption(label: 'Gris',   color: Color(0xFF9CA3AF)),
    VehicleColorOption(label: 'Argent', color: Color(0xFFD1D5DB)),
    VehicleColorOption(label: 'Rouge',  color: Color(0xFFEF4444)),
    VehicleColorOption(label: 'Bleu',   color: Color(0xFF3B82F6)),
    VehicleColorOption(label: 'Vert',   color: Color(0xFF10B981)),
    VehicleColorOption(label: 'Jaune',  color: Color(0xFFF59E0B)),
    VehicleColorOption(label: 'Orange', color: Color(0xFFF97316)),
    VehicleColorOption(label: 'Marron', color: Color(0xFF92400E)),
  ];

  // ── Selections ───────────────────────────────────────────────────────────────

  void selectVehicleType(VehicleType type) {
    if (selectedVehicleType.value == type) return;
    selectedVehicleType.value = type;
    selectedBrand.value = null;
    selectedModel.value = null;
    if (type == VehicleType.motorcycle && seatsCount.value > 2) {
      seatsCount.value = 2;
    } else if (type == VehicleType.car && seatsCount.value < 2) {
      seatsCount.value = 4;
    }
  }

  void selectBrand(String brand) {
    selectedBrand.value = brand;
    selectedModel.value = null;
  }

  void selectModel(String model)  => selectedModel.value = model;
  void selectColor(String color)  => selectedColor.value = color;
  void selectFuel(String fuel)    => selectedFuel.value  = fuel;

  void incrementSeats() {
    final max = selectedVehicleType.value == VehicleType.motorcycle ? 2 : 9;
    if (seatsCount.value < max) seatsCount.value++;
  }

  void decrementSeats() {
    final min = selectedVehicleType.value == VehicleType.motorcycle ? 1 : 2;
    if (seatsCount.value > min) seatsCount.value--;
  }

  // ── Navigation ───────────────────────────────────────────────────────────────

  void onBack() => Get.back();

  void onSaveAsDraft() {
    UIHelper().showSnackBar(AppStrings.appName, AppStrings.driverVehicleSaveDraft, 0);
  }

  void onAddDocument(String documentType) {
    UIHelper().showSnackBar(AppStrings.appName, 'Ajouter document: $documentType', 1);
  }

  // ── Register ─────────────────────────────────────────────────────────────────

  Future<void> onRegisterVehicle() async {
    if (isSubmitting.value) return;

    // Client-side validation
    final brand = selectedBrand.value;
    final model = selectedModel.value;
    final color = selectedColor.value;
    final plate = licensePlateController.text.trim();
    final yearText = yearController.text.trim();

    if (brand == null || brand.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Veuillez sélectionner une marque.', 2);
      return;
    }
    if (model == null || model.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Veuillez sélectionner un modèle.', 2);
      return;
    }
    if (color == null || color.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Veuillez sélectionner une couleur.', 2);
      return;
    }
    if (plate.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Veuillez saisir la plaque d\'immatriculation.', 2);
      return;
    }
    final year = int.tryParse(yearText);
    if (year == null || year < 1990 || year > DateTime.now().year + 1) {
      UIHelper().showSnackBar('MINIZON', 'Année de fabrication invalide.', 2);
      return;
    }

    isSubmitting.value = true;
    final result = await _provider.createVehicle({
      'brand':           brand,
      'model':           model,
      'color':           color,
      'year':            year,
      'license_plate':   plate,
      'available_seats': seatsCount.value,
      if (selectedFuel.value != null) 'fuel_type': selectedFuel.value,
    });
    isSubmitting.value = false;

    if (result.isSuccess) {
      UIHelper().showSnackBar(
        'MINIZON',
        'Véhicule enregistré. Vérification sous 1-2 jours ouvrés.',
        0,
      );
      Get.back();
    } else {
      final msg = result.error == AppError.validationError
          ? (_provider.lastValidationMessage ?? result.error!.message)
          : result.error!.message;
      UIHelper().showSnackBar('MINIZON', msg, 2);
    }
  }

  @override
  void onClose() {
    licensePlateController.dispose();
    yearController.dispose();
    super.onClose();
  }
}

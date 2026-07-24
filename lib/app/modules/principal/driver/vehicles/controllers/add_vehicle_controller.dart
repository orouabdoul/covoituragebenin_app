import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';

import 'package:covoiturage_benin_app/app/core/services/driver/vehicles/vehicles_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/vehicle_model.dart';

enum VehicleType { car, motorcycle }

class VehicleColorOption {
  final String label;
  final Color color;
  const VehicleColorOption({required this.label, required this.color});
}

// Maps a doc key to the file picked by the user
class DocSlot {
  final String label;
  final String apiKey;
  final bool required;
  DocSlot({required this.label, required this.apiKey, required this.required});
}

class AddVehicleController extends GetxController {
  VehiclesService get _service => Get.find<VehiclesService>();

  final licensePlateController = TextEditingController();
  final yearController         = TextEditingController();

  final selectedVehicleType = Rxn<VehicleType>(VehicleType.car);
  final selectedBrand       = RxnString();
  final selectedModel       = RxnString();
  final selectedColor       = RxnString();
  final seatsCount          = RxInt(4);
  final isSubmitting        = false.obs;
  final isEditMode          = false.obs;

  // ── File state ────────────────────────────────────────────────────────────
  XFile? _vehiclePhoto;
  final Map<String, XFile> _docFiles = {};
  final filesVersion = 0.obs; // rebuild trigger

  static final List<DocSlot> docSlots = [
    DocSlot(label: 'Carte grise',        apiKey: 'registration_doc',      required: true),
    DocSlot(label: 'Assurance',           apiKey: 'insurance_doc',          required: true),
    DocSlot(label: 'TVM',                 apiKey: 'tvm_doc',                required: false),
    DocSlot(label: 'Visite technique',    apiKey: 'technical_control_doc',  required: false),
  ];

  bool get hasVehiclePhoto => _vehiclePhoto != null;
  bool hasDoc(String apiKey) => _docFiles.containsKey(apiKey);

  String? _editingUuid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final vehicle = args?['vehicle'];
    if (vehicle is VehicleData) _prefillForEdit(vehicle);
  }

  void _prefillForEdit(VehicleData v) {
    _editingUuid = v.uuid;
    isEditMode.value = true;

    // Use slug to determine type
    final type = v.vehicleTypeSlug == 'moto'
        ? VehicleType.motorcycle
        : VehicleType.car;
    selectedVehicleType.value = type;

    selectedBrand.value = v.brand.isNotEmpty ? v.brand : null;
    if (v.brand.isNotEmpty && modelsForBrand.contains(v.model)) {
      selectedModel.value = v.model;
    }

    if (colorOptions.any((c) => c.label == v.color)) {
      selectedColor.value = v.color;
    }

    final minSeats = type == VehicleType.motorcycle ? 1 : 2;
    final maxSeats = type == VehicleType.motorcycle ? 2 : 9;
    seatsCount.value = v.availableSeats.clamp(minSeats, maxSeats);

    licensePlateController.text = v.licensePlate;
    if (v.year > 0) yearController.text = '${v.year}';
  }

  // ── File picking ──────────────────────────────────────────────────────────

  Future<void> pickVehiclePhoto(ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (file == null) return;
    _vehiclePhoto = file;
    filesVersion.value++;
  }

  Future<void> pickDoc(String apiKey, ImageSource source) async {
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    _docFiles[apiKey] = file;
    filesVersion.value++;
  }

  Future<void> pickDocFromFiles(String apiKey) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );
    if (result == null || result.files.isEmpty) return;
    final pFile = result.files.first;
    if (pFile.path == null) return;
    _docFiles[apiKey] = XFile(pFile.path!, name: pFile.name);
    filesVersion.value++;
  }

  // ── Brand / model data ────────────────────────────────────────────────────

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

  // ── Options ───────────────────────────────────────────────────────────────

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

  // ── Selections ────────────────────────────────────────────────────────────

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

  void incrementSeats() {
    final max = selectedVehicleType.value == VehicleType.motorcycle ? 2 : 9;
    if (seatsCount.value < max) seatsCount.value++;
  }

  void decrementSeats() {
    final min = selectedVehicleType.value == VehicleType.motorcycle ? 1 : 2;
    if (seatsCount.value > min) seatsCount.value--;
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void onBack() => Get.back();

  // ── Register / Update ─────────────────────────────────────────────────────

  Future<void> onRegisterVehicle() async {
    if (isSubmitting.value) return;

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

    // Required files for creation only
    if (!isEditMode.value) {
      if (_vehiclePhoto == null) {
        UIHelper().showSnackBar('MINIZON', 'Ajoutez une photo du véhicule.', 2);
        return;
      }
      if (!hasDoc('registration_doc')) {
        UIHelper().showSnackBar('MINIZON', 'Ajoutez la carte grise.', 2);
        return;
      }
      if (!hasDoc('insurance_doc')) {
        UIHelper().showSnackBar('MINIZON', 'Ajoutez l\'attestation d\'assurance.', 2);
        return;
      }
    }

    // vehicle_type slug: "voiture" for car, "moto" for motorcycle
    final vehicleTypeSlug = selectedVehicleType.value == VehicleType.motorcycle
        ? 'moto'
        : 'voiture';

    // Build FormData
    final fields = <String, dynamic>{
      'vehicle_type':    vehicleTypeSlug,
      'brand':           brand,
      'model':           model,
      'color':           color,
      'year':            year,
      'license_plate':   plate,
      'available_seats': seatsCount.value,
    };

    final formMap = <String, dynamic>{
      for (final e in fields.entries) e.key: e.value.toString(),
    };

    if (_vehiclePhoto != null) {
      formMap['vehicle_photo'] = await MultipartFile.fromFile(
        _vehiclePhoto!.path,
        filename: _vehiclePhoto!.name,
      );
    }

    for (final slot in docSlots) {
      final file = _docFiles[slot.apiKey];
      if (file != null) {
        formMap[slot.apiKey] = await MultipartFile.fromFile(
          file.path,
          filename: file.name,
        );
      }
    }

    final formData = FormData.fromMap(formMap);

    isSubmitting.value = true;
    bool success;
    AppError? apiError;

    if (isEditMode.value && _editingUuid != null) {
      final r = await _service.updateVehicle(_editingUuid!, formData);
      success = r.isSuccess;
      apiError = r.error;
    } else {
      final r = await _service.createVehicle(formData);
      success = r.isSuccess;
      apiError = r.error;
    }
    isSubmitting.value = false;

    if (success) {
      UIHelper().showSnackBar(
        'MINIZON',
        isEditMode.value
            ? 'Véhicule mis à jour avec succès.'
            : 'Véhicule enregistré. Vérification sous 1-2 jours ouvrés.',
        0,
      );
      Get.back();
    } else {
      final msg = apiError == AppError.validationError
          ? (_service.lastValidationMessage ?? apiError!.message)
          : apiError!.message;
      UIHelper().showSnackBar('MINIZON', msg, 2);
    }
  }

  // ── Delete ────────────────────────────────────────────────────────────────

  void onDeleteVehicle() {
    if (!isEditMode.value || _editingUuid == null) return;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce véhicule ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: _confirmDelete,
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete() async {
    Get.back();
    final result = await _service.deleteVehicle(_editingUuid!);
    if (result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', 'Véhicule supprimé.', 0);
      Get.back();
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
  }

  @override
  void onClose() {
    licensePlateController.dispose();
    yearController.dispose();
    super.onClose();
  }
}

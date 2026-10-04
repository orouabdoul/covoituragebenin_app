import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/face_verification_service.dart';
import 'package:covoiturage_benin_app/app/core/services/push_notification/push_notification_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/auth/user_model.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/id_card_camera_screen.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

// ─── Shared data classes ──────────────────────────────────────────────────────

class EmergencyContactEntry {
  String name;
  String phone;
  String relationship;

  EmergencyContactEntry({
    required this.name,
    required this.phone,
    required this.relationship,
  });

  Map<String, String> toMap() =>
      {'name': name, 'phone': phone, 'relationship': relationship};
}

enum DriverType { car, moto }

// ─── Unified controller ───────────────────────────────────────────────────────

class CompleteProfileController extends GetxController {
  CompleteProfileController({required this.isDriver});

  final bool isDriver;

  // ── Text controllers ──────────────────────────────────────────────────────
  final lastNameController  = TextEditingController();
  final firstNameController = TextEditingController();
  final phoneController     = TextEditingController();
  // Passenger-only
  final emailController   = TextEditingController();
  final addressController = TextEditingController();
  // Driver-only
  final licenseNumberController = TextEditingController();
  final vehicleColorController  = TextEditingController();
  final vehicleSeatsController  = TextEditingController();
  final plateController         = TextEditingController();

  // ── Location ──────────────────────────────────────────────────────────────
  final RxnString selectedCity         = RxnString();
  final RxnString selectedNeighborhood = RxnString();
  final RxnString selectedQuartier     = RxnString(); // driver only (3rd level)

  void selectCity(String v) {
    selectedCity.value = v;
    selectedNeighborhood.value = null;
    selectedQuartier.value = null;
    update();
  }

  void selectNeighborhood(String v) {
    selectedNeighborhood.value = v;
    selectedQuartier.value = null;
    update();
  }

  void selectQuartier(String v) {
    selectedQuartier.value = v;
    update();
  }

  void goToRoles() {
    Get.toNamed(AppRoutes.roles, arguments: {
      'skipAuth': true,
      'registerToken': _registerToken,
      'phone': _authPhone,
    });
  }

  // ── Emergency contacts (max 5) ────────────────────────────────────────────
  final RxList<EmergencyContactEntry> emergencyContacts =
      <EmergencyContactEntry>[].obs;

  void addEmergencyContact(String name, String phone, String relationship) {
    if (emergencyContacts.length >= 5) return;
    emergencyContacts.add(
        EmergencyContactEntry(name: name, phone: phone, relationship: relationship));
    update();
  }

  void removeEmergencyContact(int index) {
    if (index >= 0 && index < emergencyContacts.length) {
      emergencyContacts.removeAt(index);
      update();
    }
  }

  // ── General state ──────────────────────────────────────────────────────────
  final RxInt progress           = 0.obs;
  final Rxn<String> selectedGender = Rxn<String>();
  final RxBool isSubmitting      = false.obs;

  // ── Driver vehicle ─────────────────────────────────────────────────────────
  final Rx<DriverType> selectedDriverType = DriverType.car.obs;
  final RxnString selectedBrand = RxnString();
  final RxnString selectedModel = RxnString();
  final vehiclePhotoName          = ''.obs;
  final registrationDocumentName  = ''.obs;
  final licenseDocumentName       = ''.obs;
  final insuranceDocName          = ''.obs;
  XFile? _vehiclePhotoFile;
  XFile? _registrationDocFile;
  XFile? _licenseDocFile;
  XFile? _insuranceDocFile;

  // ── Selfies ────────────────────────────────────────────────────────────────
  final Rx<XFile?> selfieFront = Rx<XFile?>(null);
  final Rx<XFile?> selfieLeft  = Rx<XFile?>(null);
  final Rx<XFile?> selfieRight = Rx<XFile?>(null);

  // ── ID card ────────────────────────────────────────────────────────────────
  final idCardFrontName = ''.obs;
  final idCardBackName  = ''.obs;
  XFile?  _idCardFrontFile;
  XFile?  _idCardBackFile;
  XFile?  _idCardFaceZoneFile;
  Rect?   idCardFaceBox;
  Size?   idCardImageSize;
  bool    isDetectingCardFace  = false;
  String? idCardDetectionError;

  XFile? get idCardFrontFile => _idCardFrontFile;
  XFile? get idCardBackFile  => _idCardBackFile;

  // ── Face verification ──────────────────────────────────────────────────────
  final verificationStatus  = Rx<VerificationStatus>(VerificationStatus.idle);
  final verificationMessage = ''.obs;
  final verificationScore   = 0.0.obs;

  bool get canVerify => selfieFront.value != null && _idCardFrontFile != null;

  // ── Validation errors (all declared; driver-only ones stay empty for passenger)
  final firstNameError    = ''.obs;
  final lastNameError     = ''.obs;
  final phoneError        = ''.obs;
  final genderError       = ''.obs;
  final cityError         = ''.obs;
  final neighborhoodError = ''.obs;
  final selfieError       = ''.obs;
  final idCardError       = ''.obs;
  final brandError        = ''.obs;
  final modelError        = ''.obs;
  final colorError        = ''.obs;
  final seatsError        = ''.obs;
  final plateError        = ''.obs;
  final vehiclePhotoError  = ''.obs;
  final registrationError  = ''.obs;
  final licenseDocError    = ''.obs;
  final insuranceError     = ''.obs;

  // ── Size limits ────────────────────────────────────────────────────────────
  static const int _maxSelfieBytes = 2 * 1024 * 1024;
  static const int _maxImageBytes  = 5 * 1024 * 1024;
  static const int _maxDocBytes    = 5 * 1024 * 1024;

  // ── Auth ───────────────────────────────────────────────────────────────────
  String? _registerToken;
  String  _authPhone = '';

  // ── Brand / model data ─────────────────────────────────────────────────────
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

  List<String> get brandsForType =>
      selectedDriverType.value == DriverType.moto
          ? motoBrandModels.keys.toList()
          : carBrandModels.keys.toList();

  List<String> get modelsForBrand {
    final brand = selectedBrand.value;
    if (brand == null) return [];
    final map = selectedDriverType.value == DriverType.moto
        ? motoBrandModels
        : carBrandModels;
    return map[brand] ?? [];
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    progress.value = isDriver ? 75 : 60;
    final args = Get.arguments;
    if (args is Map) {
      _registerToken = args['registerToken'] as String?;
      _authPhone     = args['phone'] as String? ?? '';
    }
    if (_registerToken != null && _authPhone.isNotEmpty) {
      final local = _authPhone.startsWith('+229')
          ? _authPhone.substring(4)
          : _authPhone;
      phoneController.text = local;
    } else if (_registerToken == null) {
      final stored = UserController.instance.user.value?.phone ?? '';
      final local  = stored.startsWith('+229') ? stored.substring(4) : stored;
      phoneController.text = local.isNotEmpty ? local : '01';
    } else {
      phoneController.text = '01';
    }
    FaceVerificationService.initialize();
  }

  // ── Selectors ─────────────────────────────────────────────────────────────

  void selectGender(String gender) {
    selectedGender.value = gender;
    update();
  }

  void selectDriverType(DriverType type) {
    if (selectedDriverType.value == type) return;
    selectedDriverType.value = type;
    selectedBrand.value = null;
    selectedModel.value = null;
    vehicleSeatsController.text = type == DriverType.moto ? '1' : '';
    update();
  }

  void selectBrand(String brand) {
    selectedBrand.value = brand;
    selectedModel.value = null;
    update();
  }

  void selectModel(String model) {
    selectedModel.value = model;
    update();
  }

  // ── Selfies ────────────────────────────────────────────────────────────────

  void onSelfiesChanged(XFile? front, XFile? left, XFile? right) {
    _storeValidatedSelfies(front, left, right);
  }

  Future<void> _storeValidatedSelfies(
      XFile? front, XFile? left, XFile? right) async {
    bool rejected = false;
    Future<XFile?> check(XFile? f) async {
      if (f == null) return null;
      if (await File(f.path).length() > _maxSelfieBytes) {
        rejected = true;
        return null;
      }
      return f;
    }

    selfieFront.value = await check(front);
    selfieLeft.value  = await check(left);
    selfieRight.value = await check(right);
    selfieError.value = rejected ? 'La photo ne doit pas dépasser 2 Mo.' : '';
    _resetVerification();
    update();
    _tryAutoVerify();
  }

  // ── ID card ────────────────────────────────────────────────────────────────

  Future<void> pickIdCard({
    required bool isFront,
    required ImageSource source,
  }) async {
    XFile? file;
    if (source == ImageSource.camera) {
      final result = await Get.to<IdCardCaptureResult>(
          () => IdCardCameraScreen(isBack: !isFront));
      if (result == null) return;
      file = result.fullCard;
      if (isFront) _idCardFaceZoneFile = result.faceZone;
    } else {
      file = await ImagePicker().pickImage(source: source, imageQuality: 85);
      if (isFront) _idCardFaceZoneFile = null;
    }
    if (file == null) return;

    final size = await File(file.path).length();
    if (size > _maxImageBytes) {
      idCardError.value = 'La photo ne doit pas dépasser 5 Mo.';
      update();
      return;
    }
    idCardError.value = '';

    if (isFront) {
      _idCardFrontFile      = file;
      idCardFrontName.value = file.name;
      idCardFaceBox         = null;
      idCardDetectionError  = null;
      _resetVerification();
      isDetectingCardFace = true;
      update();
      FaceVerificationService.detectFaceOnCard(file).then((result) {
        idCardFaceBox        = result.boundingBox;
        idCardImageSize      = result.imageSize;
        idCardDetectionError = result.error;
        isDetectingCardFace  = false;
        update();
        if (result.found) _tryAutoVerify();
      });
    } else {
      _idCardBackFile      = file;
      idCardBackName.value = file.name;
      update();
    }
  }

  // ── Face verification ──────────────────────────────────────────────────────

  Future<void> runVerification() async {
    if (!canVerify) return;
    verificationStatus.value = VerificationStatus.loading;
    update();
    try {
      final result = await FaceVerificationService.verify(
        selfieFront:    selfieFront.value!,
        idCardFront:    _idCardFrontFile!,
        idCardFaceZone: _idCardFaceZoneFile,
      );
      verificationStatus.value =
          result.passed ? VerificationStatus.success : VerificationStatus.failure;
      verificationMessage.value = result.message;
      verificationScore.value   = result.similarityScore;
    } catch (e) {
      verificationStatus.value  = VerificationStatus.error;
      verificationMessage.value = 'Erreur lors de la vérification: $e';
    }
    update();
  }

  void _resetVerification() {
    if (verificationStatus.value != VerificationStatus.idle) {
      verificationStatus.value  = VerificationStatus.idle;
      verificationMessage.value = '';
      verificationScore.value   = 0.0;
    }
  }

  void _tryAutoVerify() {
    if (!canVerify) return;
    if (verificationStatus.value == VerificationStatus.loading) return;
    runVerification();
  }

  // ── Driver documents ───────────────────────────────────────────────────────

  Future<void> addVehiclePhoto({required ImageSource source}) async {
    final XFile? file =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    final size = await File(file.path).length();
    if (size > _maxImageBytes) {
      vehiclePhotoError.value =
          'La photo ne doit pas dépasser 5 Mo (${(size / 1048576).toStringAsFixed(1)} Mo)';
      update();
      return;
    }
    _vehiclePhotoFile        = file;
    vehiclePhotoName.value   = file.name;
    vehiclePhotoError.value  = '';
    update();
  }

  Future<void> addRequiredDocument({required bool isLicense}) async {
    final XFile? file = await openFile(acceptedTypeGroups: [
      XTypeGroup(
        label: 'Documents',
        mimeTypes: [
          'application/pdf', 'image/jpeg', 'image/png',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        ],
        extensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      ),
    ]);
    if (file == null) return;
    final size = await File(file.path).length();
    if (size > _maxDocBytes) {
      final msg =
          'Le document ne doit pas dépasser 5 Mo (${(size / 1048576).toStringAsFixed(1)} Mo)';
      if (isLicense) { licenseDocError.value = msg; } else { registrationError.value = msg; }
      update();
      return;
    }
    if (isLicense) {
      _licenseDocFile             = file;
      licenseDocumentName.value   = file.name;
      licenseDocError.value       = '';
    } else {
      _registrationDocFile            = file;
      registrationDocumentName.value  = file.name;
      registrationError.value         = '';
    }
    update();
  }

  Future<void> addInsuranceDoc() async {
    final XFile? file = await openFile(acceptedTypeGroups: [
      XTypeGroup(
        label: 'Documents',
        mimeTypes: ['application/pdf', 'image/jpeg', 'image/png'],
        extensions: ['pdf', 'jpg', 'jpeg', 'png'],
      ),
    ]);
    if (file == null) return;
    final size = await File(file.path).length();
    if (size > _maxDocBytes) {
      insuranceError.value =
          'Le document ne doit pas dépasser 5 Mo (${(size / 1048576).toStringAsFixed(1)} Mo)';
      update();
      return;
    }
    _insuranceDocFile       = file;
    insuranceDocName.value  = file.name;
    insuranceError.value    = '';
    update();
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  void _clearErrors() {
    firstNameError.value = lastNameError.value = phoneError.value =
        genderError.value = cityError.value = neighborhoodError.value =
            selfieError.value = idCardError.value = brandError.value =
                modelError.value = colorError.value = seatsError.value =
                    plateError.value = vehiclePhotoError.value =
                        registrationError.value = licenseDocError.value =
                            insuranceError.value = '';
    update();
  }

  bool _validate() {
    bool ok = true;

    if (firstNameController.text.trim().isEmpty) {
      firstNameError.value = 'Le prénom est requis'; ok = false;
    }
    if (lastNameController.text.trim().isEmpty) {
      lastNameError.value = 'Le nom est requis'; ok = false;
    }
    final phone = phoneController.text.trim();
    if (phone.isEmpty || phone == '01') {
      phoneError.value = 'Le numéro de téléphone est requis'; ok = false;
    }
    if (selectedGender.value == null) {
      genderError.value = 'Le genre est requis'; ok = false;
    }
    if (selectedCity.value == null || selectedCity.value!.isEmpty) {
      cityError.value = 'La commune est requise'; ok = false;
    }
    if (selectedNeighborhood.value == null ||
        selectedNeighborhood.value!.isEmpty) {
      neighborhoodError.value = "L'arrondissement est requis"; ok = false;
    }
    if (selfieFront.value == null ||
        selfieLeft.value == null ||
        selfieRight.value == null) {
      selfieError.value = 'Les 3 selfies (face, gauche, droite) sont requis';
      ok = false;
    }
    if (_idCardFrontFile == null) {
      idCardError.value = "La pièce d'identité (recto) est requise"; ok = false;
    }

    if (isDriver) {
      if (selectedBrand.value == null || selectedBrand.value!.isEmpty) {
        brandError.value = 'La marque du véhicule est requise'; ok = false;
      }
      if (selectedModel.value == null || selectedModel.value!.isEmpty) {
        modelError.value = 'Le modèle du véhicule est requis'; ok = false;
      }
      if (vehicleColorController.text.trim().isEmpty) {
        colorError.value = 'La couleur est requise'; ok = false;
      }
      if (selectedDriverType.value == DriverType.car) {
        final seats = vehicleSeatsController.text.trim();
        if (seats.isEmpty) {
          seatsError.value = 'Le nombre de places est requis'; ok = false;
        } else {
          final n = int.tryParse(seats);
          if (n == null || n < 1) {
            seatsError.value = 'Nombre de places invalide'; ok = false;
          }
        }
      }
      if (plateController.text.trim().isEmpty) {
        plateError.value = "La plaque d'immatriculation est requise"; ok = false;
      }
      if (_vehiclePhotoFile == null) {
        vehiclePhotoError.value = 'La photo du véhicule est requise'; ok = false;
      }
      if (_registrationDocFile == null) {
        registrationError.value = "Le document d'immatriculation est requis";
        ok = false;
      }
      if (selectedDriverType.value != DriverType.moto &&
          _licenseDocFile == null) {
        licenseDocError.value = 'Le permis de conduire est requis'; ok = false;
      }
      if (_insuranceDocFile == null) {
        insuranceError.value = "L'assurance est requise"; ok = false;
      }
    }

    update();
    return ok;
  }

  void _parseBackendErrors(dynamic data) {
    if (data == null) return;
    dynamic rawErrors = data['errors'];
    if (rawErrors == null && data['body'] is Map) {
      rawErrors = data['body']['errors'];
    }
    if (rawErrors is! Map) return;

    String first(dynamic v) {
      if (v is List && v.isNotEmpty) return v.first.toString();
      if (v is String) return v;
      return '';
    }

    if (rawErrors['first_name'] != null)   firstNameError.value    = first(rawErrors['first_name']);
    if (rawErrors['last_name'] != null)    lastNameError.value     = first(rawErrors['last_name']);
    if (rawErrors['phone'] != null)        phoneError.value        = first(rawErrors['phone']);
    if (rawErrors['gender'] != null)       genderError.value       = first(rawErrors['gender']);
    if (rawErrors['city'] != null)         cityError.value         = first(rawErrors['city']);
    if (rawErrors['neighborhood'] != null) neighborhoodError.value = first(rawErrors['neighborhood']);
    final selfieKey = rawErrors['selfie_front'] ?? rawErrors['selfie_left'] ?? rawErrors['selfie_right'];
    if (selfieKey != null) selfieError.value = first(selfieKey);
    if (rawErrors['id_card_front'] != null) idCardError.value = first(rawErrors['id_card_front']);

    if (isDriver) {
      if (rawErrors['brand'] != null)                  brandError.value        = first(rawErrors['brand']);
      if (rawErrors['model'] != null)                  modelError.value        = first(rawErrors['model']);
      if (rawErrors['color'] != null)                  colorError.value        = first(rawErrors['color']);
      if (rawErrors['available_seats'] != null)        seatsError.value        = first(rawErrors['available_seats']);
      if (rawErrors['license_plate'] != null)          plateError.value        = first(rawErrors['license_plate']);
      if (rawErrors['vehicle_photo'] != null)          vehiclePhotoError.value  = first(rawErrors['vehicle_photo']);
      if (rawErrors['registration_doc'] != null)       registrationError.value  = first(rawErrors['registration_doc']);
      if (rawErrors['driving_license_photo'] != null)  licenseDocError.value    = first(rawErrors['driving_license_photo']);
      if (rawErrors['insurance_doc'] != null)          insuranceError.value     = first(rawErrors['insurance_doc']);
    }
    update();
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> submit() async {
    _clearErrors();
    if (!_validate()) {
      UIHelper().showSnackBar(
          'MINIZON', 'Veuillez corriger les champs indiqués.', 2);
      return;
    }

    final isNew = _registerToken != null;
    if (!isNew) {
      final uuid = UserController.instance.user.value?.uuid;
      if (uuid == null || uuid.isEmpty) {
        UIHelper()
            .showSnackBar('MINIZON', 'Session expirée. Reconnectez-vous.', 2);
        return;
      }
    }

    isSubmitting.value = true;
    update();

    try {
      final dio = AppDio.create();

      String? genderCode;
      if (selectedGender.value != null) {
        genderCode = (selectedGender.value! == 'Homme' ||
                selectedGender.value! == 'M')
            ? 'M'
            : 'F';
      }

      final fields = <String, dynamic>{
        'role_name':   isDriver ? 'driver' : 'passenger',
        'first_name':  firstNameController.text.trim(),
        'last_name':   lastNameController.text.trim(),
      };

      if (isNew) {
        fields['register_token'] = _registerToken!;
      } else {
        final uuid = UserController.instance.user.value?.uuid;
        if (uuid != null) fields['user_uuid'] = uuid;
      }

      final phone = phoneController.text.trim();
      if (phone.isNotEmpty && phone != '01') fields['phone'] = phone;
      if (selectedCity.value != null)         fields['city']         = selectedCity.value!;
      if (selectedNeighborhood.value != null) fields['neighborhood'] = selectedNeighborhood.value!;
      if (genderCode != null)                 fields['gender']       = genderCode;

      // Quartier (3e niveau) — commun aux deux rôles
      if (selectedQuartier.value != null) {
        fields['address_details'] = selectedQuartier.value!;
      }

      if (isDriver) {
        final isMoto = selectedDriverType.value == DriverType.moto;
        if (!isMoto && licenseNumberController.text.trim().isNotEmpty) {
          fields['driving_license_number'] = licenseNumberController.text.trim();
        }
        if (selectedBrand.value != null) { fields['brand'] = selectedBrand.value!; }
        if (selectedModel.value != null) { fields['model'] = selectedModel.value!; }
        if (vehicleColorController.text.trim().isNotEmpty) {
          fields['color'] = vehicleColorController.text.trim();
        }
        if (vehicleSeatsController.text.trim().isNotEmpty) {
          fields['available_seats'] = vehicleSeatsController.text.trim();
        }
        if (plateController.text.trim().isNotEmpty) {
          fields['license_plate'] = plateController.text.trim();
        }
        fields['vehicle_type'] = isMoto ? 'moto' : 'voiture';
      } else {
        if (emailController.text.trim().isNotEmpty) {
          fields['email'] = emailController.text.trim();
        }
      }

      final formMap = <String, dynamic>{...fields};

      // Selfies
      if (selfieFront.value != null) {
        formMap['selfie_front'] = await MultipartFile.fromFile(
            selfieFront.value!.path, filename: 'selfie_front.jpg');
      }
      if (selfieLeft.value != null) {
        formMap['selfie_left'] = await MultipartFile.fromFile(
            selfieLeft.value!.path, filename: 'selfie_left.jpg');
      }
      if (selfieRight.value != null) {
        formMap['selfie_right'] = await MultipartFile.fromFile(
            selfieRight.value!.path, filename: 'selfie_right.jpg');
      }

      // ID card
      if (_idCardFrontFile != null) {
        formMap['id_card_front'] = await MultipartFile.fromFile(
            _idCardFrontFile!.path, filename: 'id_card_front.jpg');
      }
      if (_idCardBackFile != null) {
        formMap['id_card_back'] = await MultipartFile.fromFile(
            _idCardBackFile!.path, filename: 'id_card_back.jpg');
      }

      // Driver-only files
      if (isDriver) {
        final isMoto = selectedDriverType.value == DriverType.moto;
        if (_vehiclePhotoFile != null) {
          formMap['vehicle_photo'] = await MultipartFile.fromFile(
              _vehiclePhotoFile!.path, filename: 'vehicle_photo.jpg',
              contentType: DioMediaType('image', 'jpeg'));
        }
        if (_registrationDocFile != null) {
          final ext =
              _registrationDocFile!.path.split('.').last.toLowerCase();
          formMap['registration_doc'] = await MultipartFile.fromFile(
              _registrationDocFile!.path,
              filename: 'registration.$ext',
              contentType: ext == 'pdf'
                  ? DioMediaType('application', 'pdf')
                  : DioMediaType('image', ext == 'png' ? 'png' : 'jpeg'));
        }
        if (!isMoto && _licenseDocFile != null) {
          final ext = _licenseDocFile!.path.split('.').last.toLowerCase();
          formMap['driving_license_photo'] = await MultipartFile.fromFile(
              _licenseDocFile!.path,
              filename: 'license.$ext',
              contentType: ext == 'pdf'
                  ? DioMediaType('application', 'pdf')
                  : DioMediaType('image', ext == 'png' ? 'png' : 'jpeg'));
        }
        if (_insuranceDocFile != null) {
          final ext = _insuranceDocFile!.path.split('.').last.toLowerCase();
          formMap['insurance_doc'] = await MultipartFile.fromFile(
              _insuranceDocFile!.path,
              filename: 'insurance.$ext',
              contentType: ext == 'pdf'
                  ? DioMediaType('application', 'pdf')
                  : DioMediaType('image', ext == 'png' ? 'png' : 'jpeg'));
        }
      }

      logger.d(
          'submit → POST ${AppApi.register} (driver=$isDriver, new=$isNew)');

      final formData = FormData.fromMap(formMap);
      for (int i = 0; i < emergencyContacts.length; i++) {
        formData.fields
          ..add(MapEntry('emergency_contacts[$i][name]', emergencyContacts[i].name))
          ..add(MapEntry('emergency_contacts[$i][phone]', emergencyContacts[i].phone))
          ..add(MapEntry('emergency_contacts[$i][relationship]', emergencyContacts[i].relationship));
      }

      final headers = <String, dynamic>{};
      if (!isNew) {
        final token = await UserController.instance.getSessionToken();
        if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
      }

      final response = await dio.post(
        AppApi.register,
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          sendTimeout:    const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 60),
          headers: headers,
        ),
      );

      logger.d('submit réponse [${response.statusCode}]');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body     = response.data?['body'] as Map<String, dynamic>?;
        final newToken = body?['token'] as String?;
        final uc       = UserController.instance;

        if (newToken != null && newToken.isNotEmpty) {
          final userJson = body?['user'] as Map<String, dynamic>?;
          if (userJson != null) {
            await uc.setUserAndToken(UserModel.fromJson(userJson), newToken,
                isProfileComplete: true);
          } else {
            uc.token.value = newToken;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', newToken);
          }
          PushNotificationService.instance.registerFcmToken();
        }

        uc.setRole(isDriver ? 'driver' : 'passenger');
        await uc.setProfileComplete(true);
        Get.offAllNamed(
            isDriver ? AppRoutes.dashboardDriver : AppRoutes.dashboardPassenger);
      } else if (response.statusCode == 401) {
        UIHelper().showSnackBar(
            'MINIZON', 'Session expirée. Veuillez recommencer la vérification OTP.', 3);
        await Future.delayed(const Duration(seconds: 2));
        Get.offAllNamed(AppRoutes.register);
      } else if (response.statusCode == 409) {
        UIHelper().showSnackBar(
            'MINIZON', 'Un compte existe déjà pour ce numéro.', 2);
      } else if (response.statusCode == 422) {
        _parseBackendErrors(response.data);
        UIHelper().showSnackBar(
            'MINIZON', 'Veuillez corriger les champs signalés en rouge.', 3);
      } else {
        _parseBackendErrors(response.data);
        final msg = response.data?['message'] as String? ??
            response.data?['error'] as String? ??
            'Erreur (${response.statusCode}).';
        logger.w('submit → échec: $msg');
        UIHelper().showSnackBar('MINIZON', msg, 2);
      }
    } catch (e, st) {
      logger.e('submit → exception', error: e, stackTrace: st);
      UIHelper()
          .showSnackBar('MINIZON', 'Erreur réseau. Vérifiez votre connexion.', 2);
    } finally {
      isSubmitting.value = false;
      update();
    }
  }

  @override
  void onClose() {
    lastNameController.dispose();
    firstNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    licenseNumberController.dispose();
    vehicleColorController.dispose();
    vehicleSeatsController.dispose();
    plateController.dispose();
    super.onClose();
  }
}

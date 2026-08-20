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
import 'profile_passager_controller.dart' show EmergencyContactEntry;

enum DriverType { car, moto }

class ProfileDriverController extends GetxController {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();

  // Ville et quartier sélectionnés via listes déroulantes
  final RxnString selectedCity = RxnString();
  final RxnString selectedNeighborhood = RxnString();

  void selectCity(String city) {
    selectedCity.value = city;
    selectedNeighborhood.value = null;
    update();
  }

  void selectNeighborhood(String neighborhood) {
    selectedNeighborhood.value = neighborhood;
    update();
  }
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController vehicleSeatsController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

  // ── Emergency contacts (max 5) ─────────────────────────────────────────────
  final RxList<EmergencyContactEntry> emergencyContacts =
      <EmergencyContactEntry>[].obs;

  void addEmergencyContact(String name, String phone, String relationship) {
    if (emergencyContacts.length >= 5) return;
    emergencyContacts.add(EmergencyContactEntry(
        name: name, phone: phone, relationship: relationship));
    update();
  }

  void removeEmergencyContact(int index) {
    if (index >= 0 && index < emergencyContacts.length) {
      emergencyContacts.removeAt(index);
      update();
    }
  }

  final Rx<DriverType> selectedDriverType = DriverType.car.obs;
  final RxInt progress = 75.obs;
  final Rxn<String> selectedGender = Rxn<String>();

  final RxnString selectedBrand = RxnString();
  final RxnString selectedModel = RxnString();

  final RxString vehiclePhotoName = ''.obs;
  final RxString registrationDocumentName = ''.obs;
  final RxString licenseDocumentName = ''.obs;
  final RxString insuranceDocName = ''.obs;

  // Fichiers réels (pas juste les noms)
  XFile? _vehiclePhotoFile;
  XFile? _registrationDocFile;
  XFile? _licenseDocFile;
  XFile? _insuranceDocFile;
  XFile? _idCardBackFile;

  final RxBool isSubmitting = false.obs;

  // ── Erreurs de validation inline ───────────────────────────────────────────
  final RxString firstNameError  = ''.obs;
  final RxString lastNameError   = ''.obs;
  final RxString phoneError      = ''.obs;
  final RxString brandError      = ''.obs;
  final RxString modelError      = ''.obs;
  final RxString colorError      = ''.obs;
  final RxString plateError      = ''.obs;
  final RxString selfieError     = ''.obs;
  final RxString idCardError     = ''.obs;
  final RxString vehiclePhotoError  = ''.obs;
  final RxString registrationError  = ''.obs;
  final RxString licenseDocError    = ''.obs;
  final RxString insuranceError     = ''.obs;

  // Taille max autorisée : 5 Mo images, 10 Mo documents
  static const int _maxImageBytes = 5 * 1024 * 1024;
  static const int _maxDocBytes   = 10 * 1024 * 1024;

  // register_token (nouveau compte) ou null (utilisateur existant avec auth token)
  String? _registerToken;
  String _authPhone = '';

  final Rx<XFile?> selfieFront = Rx<XFile?>(null);
  final Rx<XFile?> selfieLeft = Rx<XFile?>(null);
  final Rx<XFile?> selfieRight = Rx<XFile?>(null);

  final RxString idCardFrontName = ''.obs;
  final RxString idCardBackName = ''.obs;
  XFile? _idCardFrontFile;
  XFile? _idCardFaceZoneFile; // recadrage de la zone visage (côté gauche CNI)

  // ID card face detection state (for UI overlay)
  Rect? idCardFaceBox;
  Size? idCardImageSize;
  bool isDetectingCardFace = false;
  String? idCardDetectionError;

  XFile? get idCardFrontFile => _idCardFrontFile;
  XFile? get idCardBackFile => _idCardBackFile;

  // Face verification
  final verificationStatus = Rx<VerificationStatus>(VerificationStatus.idle);
  final verificationMessage = ''.obs;
  final verificationScore = 0.0.obs;

  bool get canVerify =>
      selfieFront.value != null && _idCardFrontFile != null;

  // ── Brand / model data ──────────────────────────────────────────────────────

  static const Map<String, List<String>> carBrandModels = {
    'Toyota': ['Corolla', 'Camry', 'RAV4', 'Hilux', 'Land Cruiser', 'Yaris', 'Avensis', 'Fortuner', 'Prado'],
    'Peugeot': ['206', '207', '208', '306', '307', '308', '406', '407', '508', '3008', '5008'],
    'Renault': ['Clio', 'Mégane', 'Laguna', 'Duster', 'Logan', 'Symbol', 'Sandero'],
    'Honda': ['Civic', 'Accord', 'CR-V', 'HR-V', 'Jazz', 'Fit'],
    'Hyundai': ['Accent', 'Elantra', 'Tucson', 'Santa Fe', 'i10', 'i20', 'i30'],
    'Nissan': ['Almera', 'Tiida', 'X-Trail', 'Qashqai', 'Note', 'Micra', 'Pathfinder'],
    'Ford': ['Fiesta', 'Focus', 'Mondeo', 'Ranger', 'EcoSport', 'Explorer'],
    'Volkswagen': ['Golf', 'Polo', 'Passat', 'Tiguan', 'Jetta', 'Touareg'],
    'Mercedes': ['Classe A', 'Classe C', 'Classe E', 'GLC', 'GLE', 'Vito'],
    'BMW': ['Série 1', 'Série 3', 'Série 5', 'X1', 'X3', 'X5'],
    'KIA': ['Picanto', 'Rio', 'Sportage', 'Sorento', 'Ceed'],
    'Suzuki': ['Swift', 'Vitara', 'Jimny', 'Alto', 'Baleno'],
  };

  static const Map<String, List<String>> motoBrandModels = {
    'Honda': ['CB 125', 'CB 150', 'XR 150', 'Wave 110', 'CB 300', 'CG 150', 'Shine 125'],
    'Yamaha': ['YBR 125', 'FZ 150', 'Fazer 150', 'MT-07', 'R15', 'Saluto 125'],
    'Suzuki': ['GS 150', 'EN 125', 'GN 125', 'Bandit 150', 'Hayate'],
    'TVS': ['Apache 160', 'Star City 125', 'Sport 100', 'Metro 100'],
    'Bajaj': ['Pulsar 125', 'Pulsar 150', 'Discover 125', 'Platina'],
    'Kymco': ['Agility 125', 'Elegance 150', 'Like 125', 'Super 8'],
    'Lifan': ['LF 110', 'LF 125', 'LF 150', 'KP 150'],
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

  // ── Actions ─────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      _registerToken = args['registerToken'] as String?;
      _authPhone = args['phone'] as String? ?? '';
    }

    // Pré-remplir le numéro de téléphone
    if (_registerToken != null && _authPhone.isNotEmpty) {
      final local = _authPhone.startsWith('+229')
          ? _authPhone.substring(4)
          : _authPhone;
      phoneController.text = local;
    } else if (_registerToken == null) {
      final storedPhone = UserController.instance.user.value?.phone ?? '';
      final local = storedPhone.startsWith('+229')
          ? storedPhone.substring(4)
          : storedPhone;
      phoneController.text = local.isNotEmpty ? local : '01';
    } else {
      phoneController.text = '01';
    }
    FaceVerificationService.initialize();
  }

  Future<void> runVerification() async {
    if (!canVerify) return;
    verificationStatus.value = VerificationStatus.loading;
    update();
    try {
      final result = await FaceVerificationService.verify(
        selfieFront: selfieFront.value!,
        idCardFront: _idCardFrontFile!,
        idCardFaceZone: _idCardFaceZoneFile,
      );
      verificationStatus.value =
          result.passed ? VerificationStatus.success : VerificationStatus.failure;
      verificationMessage.value = result.message;
      verificationScore.value = result.similarityScore;
    } catch (e) {
      verificationStatus.value = VerificationStatus.error;
      verificationMessage.value = 'Erreur lors de la vérification: $e';
    }
    update();
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
    update();
  }

  void selectDriverType(DriverType type) {
    if (selectedDriverType.value == type) return;
    selectedDriverType.value = type;
    selectedBrand.value = null;
    selectedModel.value = null;
    if (type == DriverType.moto) {
      vehicleSeatsController.text = '1';
    } else {
      vehicleSeatsController.clear();
    }
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

  void onSelfiesChanged(XFile? front, XFile? left, XFile? right) {
    selfieFront.value = front;
    selfieLeft.value = left;
    selfieRight.value = right;
    _resetVerification();
    update();
    _tryAutoVerify();
  }

  Future<void> pickIdCard({required bool isFront, required ImageSource source}) async {
    XFile? file;

    // Caméra → écran guidé avec cadre carte (zone visage uniquement pour le recto)
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

    if (isFront) {
      _idCardFrontFile = file;
      idCardFrontName.value = file.name;
      idCardFaceBox = null;
      idCardDetectionError = null;
      _resetVerification();

      isDetectingCardFace = true;
      update();

      FaceVerificationService.detectFaceOnCard(file).then((result) {
        idCardFaceBox = result.boundingBox;
        idCardImageSize = result.imageSize;
        idCardDetectionError = result.error;
        isDetectingCardFace = false;
        update();
        if (result.found) _tryAutoVerify();
      });
    } else {
      _idCardBackFile = file;
      idCardBackName.value = file.name;
      update();
    }
  }

  void _resetVerification() {
    if (verificationStatus.value != VerificationStatus.idle) {
      verificationStatus.value = VerificationStatus.idle;
      verificationMessage.value = '';
      verificationScore.value = 0.0;
    }
  }

  void _tryAutoVerify() {
    if (!canVerify) return;
    if (verificationStatus.value == VerificationStatus.loading) return;
    runVerification();
  }

  void _clearErrors() {
    firstNameError.value = '';
    lastNameError.value = '';
    phoneError.value = '';
    brandError.value = '';
    modelError.value = '';
    colorError.value = '';
    plateError.value = '';
    selfieError.value = '';
    idCardError.value = '';
    vehiclePhotoError.value = '';
    registrationError.value = '';
    licenseDocError.value = '';
    insuranceError.value = '';
    update();
  }

  void _parseBackendErrors(dynamic data) {
    if (data == null) return;
    final errors = data['errors'];
    if (errors is! Map) return;

    String _first(dynamic v) {
      if (v is List && v.isNotEmpty) return v.first.toString();
      if (v is String) return v;
      return '';
    }

    if (errors['first_name'] != null) firstNameError.value = _first(errors['first_name']);
    if (errors['last_name'] != null) lastNameError.value = _first(errors['last_name']);
    if (errors['phone'] != null) phoneError.value = _first(errors['phone']);
    if (errors['brand'] != null) brandError.value = _first(errors['brand']);
    if (errors['model'] != null) modelError.value = _first(errors['model']);
    if (errors['color'] != null) colorError.value = _first(errors['color']);
    if (errors['license_plate'] != null) plateError.value = _first(errors['license_plate']);
    if (errors['selfie_front'] != null) selfieError.value = _first(errors['selfie_front']);
    if (errors['id_card_front'] != null) idCardError.value = _first(errors['id_card_front']);
    if (errors['vehicle_photo'] != null) vehiclePhotoError.value = _first(errors['vehicle_photo']);
    if (errors['registration_doc'] != null) registrationError.value = _first(errors['registration_doc']);
    if (errors['driving_license_photo'] != null) licenseDocError.value = _first(errors['driving_license_photo']);
    if (errors['insurance_doc'] != null) insuranceError.value = _first(errors['insurance_doc']);
    update();
  }

  Future<void> continueProfile() async {
    _clearErrors();

    final isNewRegistration = _registerToken != null;
    if (!isNewRegistration) {
      final userUuid = UserController.instance.user.value?.uuid;
      if (userUuid == null || userUuid.isEmpty) {
        UIHelper().showSnackBar('MINIZON', 'Session expirée. Reconnectez-vous.', 2);
        return;
      }
    }

    isSubmitting.value = true;
    update();

    try {
      final dio = AppDio.create();

      String? genderCode;
      if (selectedGender.value != null) {
        genderCode = (selectedGender.value! == 'Homme' || selectedGender.value! == 'M') ? 'M' : 'F';
      }

      final isMoto = selectedDriverType.value == DriverType.moto;
      final vehicleType = isMoto ? 'moto' : 'voiture';

      final Map<String, dynamic> fields = {
        'role_name': 'driver',
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
      };

      if (isNewRegistration) {
        fields['register_token'] = _registerToken!;
      } else {
        final userUuid = UserController.instance.user.value?.uuid;
        if (userUuid != null) fields['user_uuid'] = userUuid;
      }

      final phone = phoneController.text.trim();
      if (phone.isNotEmpty && phone != '01') fields['phone'] = phone;
      if (selectedCity.value != null) fields['city'] = selectedCity.value!;
      if (selectedNeighborhood.value != null) fields['neighborhood'] = selectedNeighborhood.value!;
      if (addressController.text.trim().isNotEmpty) fields['address_details'] = addressController.text.trim();
      if (genderCode != null) fields['gender'] = genderCode;
      if (!isMoto && licenseNumberController.text.trim().isNotEmpty) {
        fields['driving_license_number'] = licenseNumberController.text.trim();
      }
      if (selectedBrand.value != null) fields['brand'] = selectedBrand.value!;
      if (selectedModel.value != null) fields['model'] = selectedModel.value!;
      if (vehicleColorController.text.trim().isNotEmpty) fields['color'] = vehicleColorController.text.trim();
      if (vehicleSeatsController.text.trim().isNotEmpty) {
        fields['available_seats'] = vehicleSeatsController.text.trim();
      }
      if (plateController.text.trim().isNotEmpty) fields['license_plate'] = plateController.text.trim();
      fields['vehicle_type'] = vehicleType;

      final formMap = <String, dynamic>{...fields};
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
      if (_idCardFrontFile != null) {
        formMap['id_card_front'] = await MultipartFile.fromFile(
            _idCardFrontFile!.path, filename: 'id_card_front.jpg');
      }
      if (_idCardBackFile != null) {
        formMap['id_card_back'] = await MultipartFile.fromFile(
            _idCardBackFile!.path, filename: 'id_card_back.jpg');
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
      if (_vehiclePhotoFile != null) {
        formMap['vehicle_photo'] = await MultipartFile.fromFile(
            _vehiclePhotoFile!.path, filename: 'vehicle_photo.jpg',
            contentType: DioMediaType('image', 'jpeg'));
      }
      if (_registrationDocFile != null) {
        final ext = _registrationDocFile!.path.split('.').last.toLowerCase();
        formMap['registration_doc'] = await MultipartFile.fromFile(
            _registrationDocFile!.path,
            filename: 'registration.$ext',
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

      logger.d('continueProfile → POST ${AppApi.register} (new=$isNewRegistration)');
      logger.d('continueProfile champs: $fields');

      final formData = FormData.fromMap(formMap);
      for (int i = 0; i < emergencyContacts.length; i++) {
        formData.fields.add(MapEntry('emergency_contacts[$i][name]', emergencyContacts[i].name));
        formData.fields.add(MapEntry('emergency_contacts[$i][phone]', emergencyContacts[i].phone));
        formData.fields.add(MapEntry('emergency_contacts[$i][relationship]', emergencyContacts[i].relationship));
      }

      final headers = <String, dynamic>{};
      if (!isNewRegistration) {
        final token = await UserController.instance.getSessionToken();
        if (token.isNotEmpty) headers['Authorization'] = 'Bearer $token';
      }

      final response = await dio.post(
        AppApi.register,
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 60),
          headers: headers,
        ),
      );

      logger.d('continueProfile réponse [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('continueProfile → succès, navigation dashboard conducteur');
        final body = response.data?['body'] as Map<String, dynamic>?;
        final newToken = body?['token'] as String?;
        final uc = UserController.instance;

        if (newToken != null && newToken.isNotEmpty) {
          final userJson = body?['user'] as Map<String, dynamic>?;
          if (userJson != null) {
            await uc.setUserAndToken(
              UserModel.fromJson(userJson),
              newToken,
              isProfileComplete: true,
            );
          } else {
            uc.token.value = newToken;
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('token', newToken);
          }
          PushNotificationService.instance.registerFcmToken();
        }

        uc.setRole('driver');
        await uc.setProfileComplete(true);
        Get.offAllNamed(AppRoutes.dashboardDriver);
      } else if (response.statusCode == 401) {
        UIHelper().showSnackBar(
          'MINIZON',
          'Token d\'inscription expiré. Veuillez recommencer.',
          2,
        );
      } else if (response.statusCode == 409) {
        UIHelper().showSnackBar(
          'MINIZON',
          'Un compte existe déjà pour ce numéro.',
          2,
        );
      } else if (response.statusCode == 422) {
        _parseBackendErrors(response.data);
        UIHelper().showSnackBar(
          'MINIZON',
          'Veuillez corriger les champs signalés en rouge.',
          3,
        );
      } else {
        _parseBackendErrors(response.data);
        final msg = response.data?['message'] as String? ??
            response.data?['error'] as String? ??
            'Erreur lors de la soumission (${response.statusCode}).';
        logger.w('continueProfile → échec: $msg');
        UIHelper().showSnackBar('MINIZON', msg, 2);
      }
    } catch (e, st) {
      logger.e('continueProfile → exception', error: e, stackTrace: st);
      UIHelper().showSnackBar(
          'MINIZON', 'Erreur réseau. Vérifiez votre connexion.', 2);
    } finally {
      isSubmitting.value = false;
      update();
    }
  }

  Future<void> addVehiclePhoto({required ImageSource source}) async {
    final XFile? file =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    final size = await File(file.path).length();
    if (size > _maxImageBytes) {
      vehiclePhotoError.value = 'Image trop lourde — max 5 Mo (actuel : ${(size / 1048576).toStringAsFixed(1)} Mo)';
      update();
      return;
    }
    _vehiclePhotoFile = file;
    vehiclePhotoName.value = file.name;
    vehiclePhotoError.value = '';
    update();
  }

  Future<void> addRequiredDocument({required bool isLicense}) async {
    final XFile? file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Documents',
          mimeTypes: [
            'application/pdf',
            'image/jpeg',
            'image/png',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          ],
          extensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        ),
      ],
    );
    if (file == null) return;
    final size = await File(file.path).length();
    if (size > _maxDocBytes) {
      final msg = 'Fichier trop lourd — max 10 Mo (actuel : ${(size / 1048576).toStringAsFixed(1)} Mo)';
      if (isLicense) licenseDocError.value = msg;
      else registrationError.value = msg;
      update();
      return;
    }
    if (isLicense) {
      _licenseDocFile = file;
      licenseDocumentName.value = file.name;
      licenseDocError.value = '';
    } else {
      _registrationDocFile = file;
      registrationDocumentName.value = file.name;
      registrationError.value = '';
    }
    update();
  }

  Future<void> addInsuranceDoc() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Documents',
          mimeTypes: ['application/pdf', 'image/jpeg', 'image/png'],
          extensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
      ],
    );
    if (file == null) return;
    final size = await File(file.path).length();
    if (size > _maxDocBytes) {
      insuranceError.value = 'Fichier trop lourd — max 10 Mo (actuel : ${(size / 1048576).toStringAsFixed(1)} Mo)';
      update();
      return;
    }
    _insuranceDocFile = file;
    insuranceDocName.value = file.name;
    insuranceError.value = '';
    update();
  }

  @override
  void onClose() {
    lastNameController.dispose();
    firstNameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    licenseNumberController.dispose();
    vehicleColorController.dispose();
    vehicleSeatsController.dispose();
    plateController.dispose();
    super.onClose();
  }
}

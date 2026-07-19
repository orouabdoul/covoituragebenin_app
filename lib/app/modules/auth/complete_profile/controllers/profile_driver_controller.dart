import 'package:dio/dio.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_api.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/face_verification_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_dio.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/id_card_camera_screen.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'profile_passager_controller.dart' show EmergencyContactEntry;

enum DriverType { car, moto }

class ProfileDriverController extends GetxController {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController licenseNumberController = TextEditingController();
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
    phoneController.text = '01';
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

    // Recto + caméra → écran guidé avec cadre carte + recadrage zone visage
    if (isFront && source == ImageSource.camera) {
      final result = await Get.to<IdCardCaptureResult>(
          () => const IdCardCameraScreen());
      if (result == null) return;
      file = result.fullCard;
      _idCardFaceZoneFile = result.faceZone;
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

  Future<void> continueProfile() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Prénom et nom sont requis.', 2);
      return;
    }

    final userUuid = UserController.instance.user.value?.uuid;
    if (userUuid == null || userUuid.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Session expirée. Reconnectez-vous.', 2);
      return;
    }

    isSubmitting.value = true;
    update();

    try {
      final token = await UserController.instance.getSessionToken();
      final dio = AppDio.create();

      // Gender: "Homme" → "M", "Femme" → "F"
      String? genderCode;
      if (selectedGender.value != null) {
        genderCode = (selectedGender.value! == 'Homme' || selectedGender.value! == 'M') ? 'M' : 'F';
      }

      final vehicleType = selectedDriverType.value == DriverType.moto ? 'moto' : 'voiture';

      final Map<String, dynamic> fields = {
        'user_uuid': userUuid,
        'role_name': 'driver',
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
      };
      final phone = phoneController.text.trim();
      if (phone.isNotEmpty && phone != '01') fields['phone'] = phone;
      if (cityController.text.trim().isNotEmpty) fields['city'] = cityController.text.trim();
      if (neighborhoodController.text.trim().isNotEmpty) fields['neighborhood'] = neighborhoodController.text.trim();
      if (addressController.text.trim().isNotEmpty) fields['address_details'] = addressController.text.trim();
      if (genderCode != null) fields['gender'] = genderCode;
      if (licenseNumberController.text.trim().isNotEmpty) {
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
      // emergency_contacts ajoutés en bracket-notation après FormData.fromMap

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
      if (_licenseDocFile != null) {
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

      logger.d('continueProfile → POST ${AppApi.register}');
      logger.d('continueProfile champs texte: $fields');
      logger.d('continueProfile fichiers: {'
          'selfie_front: ${selfieFront.value?.path}, '
          'selfie_left: ${selfieLeft.value?.path}, '
          'selfie_right: ${selfieRight.value?.path}, '
          'id_card_front: ${_idCardFrontFile?.path}, '
          'id_card_back: ${_idCardBackFile?.path}, '
          'license_photo: ${_licenseDocFile?.path}, '
          'vehicle_photo: ${_vehiclePhotoFile?.path}, '
          'registration_doc: ${_registrationDocFile?.path}, '
          'insurance_doc: ${_insuranceDocFile?.path}'
          '}');
      logger.d('continueProfile token présent: ${token.isNotEmpty}');

      final formData = FormData.fromMap(formMap);
      for (int i = 0; i < emergencyContacts.length; i++) {
        formData.fields.add(MapEntry('emergency_contacts[$i][name]', emergencyContacts[i].name));
        formData.fields.add(MapEntry('emergency_contacts[$i][phone]', emergencyContacts[i].phone));
        formData.fields.add(MapEntry('emergency_contacts[$i][relationship]', emergencyContacts[i].relationship));
      }

      final response = await dio.post(
        AppApi.register,
        data: formData,
        options: Options(
          validateStatus: (_) => true,
          sendTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      logger.d('continueProfile réponse [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('continueProfile → succès, navigation dashboard conducteur');
        // Mettre à jour le token retourné par register
        final body = response.data?['body'] as Map?;
        final newToken = body?['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          UserController.instance.token.value = newToken;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newToken);
        }
        UserController.instance.setRole('driver');
        await UserController.instance.setProfileComplete(true);
        Get.offAllNamed(AppRoutes.dashboardDriver);
      } else {
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
    _vehiclePhotoFile = file;
    vehiclePhotoName.value = file.name;
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
    if (isLicense) {
      _licenseDocFile = file;
      licenseDocumentName.value = file.name;
    } else {
      _registrationDocFile = file;
      registrationDocumentName.value = file.name;
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
    _insuranceDocFile = file;
    insuranceDocName.value = file.name;
    update();
  }

  @override
  void onClose() {
    lastNameController.dispose();
    firstNameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    neighborhoodController.dispose();
    addressController.dispose();
    licenseNumberController.dispose();
    vehicleColorController.dispose();
    vehicleSeatsController.dispose();
    plateController.dispose();
    super.onClose();
  }
}

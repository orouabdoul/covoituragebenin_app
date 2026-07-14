import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/face_verification_service.dart';
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

  final Rx<XFile?> selfieFront = Rx<XFile?>(null);
  final Rx<XFile?> selfieLeft = Rx<XFile?>(null);
  final Rx<XFile?> selfieRight = Rx<XFile?>(null);

  final RxString idCardFrontName = ''.obs;
  final RxString idCardBackName = ''.obs;
  XFile? _idCardFrontFile;

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
    final file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null) return;
    if (isFront) {
      _idCardFrontFile = file;
      idCardFrontName.value = file.name;
      idCardFaceBox = null;
      idCardDetectionError = null;
      _resetVerification();

      // Detect face on card for UI overlay (non-blocking)
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
    await UserController.instance.setProfileComplete(true);
    Get.offAllNamed(AppRoutes.dashboardDriver);
  }

  Future<void> addVehiclePhoto({required ImageSource source}) async {
    final XFile? file = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (file == null) return;
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
      licenseDocumentName.value = file.name;
    } else {
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

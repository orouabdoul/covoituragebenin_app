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

class ProfilePassagerController extends GetxController {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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

  final RxInt progress = 60.obs;
  final RxString avatarImageName = ''.obs;
  final Rxn<String> selectedGender = Rxn<String>();

  final Rx<XFile?> selfieFront = Rx<XFile?>(null);
  final Rx<XFile?> selfieLeft = Rx<XFile?>(null);
  final Rx<XFile?> selfieRight = Rx<XFile?>(null);

  final RxString idCardFrontName = ''.obs;
  final RxString idCardBackName = ''.obs;
  XFile? _idCardFrontFile;
  XFile? _idCardBackFile;
  XFile? _avatarFile;
  XFile? _idCardFaceZoneFile; // recadrage de la zone visage (côté gauche CNI)

  final RxBool isSubmitting = false.obs;

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
      if (isFront) _idCardFaceZoneFile = null; // galerie : pas de zone pré-découpée
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

  Future<void> createProfile() async {
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

      final Map<String, dynamic> fields = {
        'user_uuid': userUuid,
        'role_name': 'passenger',
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
      };
      if (emailController.text.trim().isNotEmpty) {
        fields['email'] = emailController.text.trim();
      }
      final phone = phoneController.text.trim();
      if (phone.isNotEmpty && phone != '01') fields['phone'] = phone;
      if (cityController.text.trim().isNotEmpty) fields['city'] = cityController.text.trim();
      if (neighborhoodController.text.trim().isNotEmpty) fields['neighborhood'] = neighborhoodController.text.trim();
      if (addressController.text.trim().isNotEmpty) fields['address_details'] = addressController.text.trim();
      if (genderCode != null) fields['gender'] = genderCode;
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
      if (_avatarFile != null) {
        formMap['avatar'] = await MultipartFile.fromFile(
            _avatarFile!.path, filename: 'avatar.jpg');
      }

      logger.d('createProfile → POST ${AppApi.register}');
      logger.d('createProfile champs texte: $fields');
      logger.d('createProfile fichiers: {'
          'selfie_front: ${selfieFront.value?.path}, '
          'selfie_left: ${selfieLeft.value?.path}, '
          'selfie_right: ${selfieRight.value?.path}, '
          'id_card_front: ${_idCardFrontFile?.path}, '
          'id_card_back: ${_idCardBackFile?.path}, '
          'avatar: ${_avatarFile?.path}'
          '}');
      logger.d('createProfile token présent: ${token.isNotEmpty}');

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

      logger.d('createProfile réponse [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('createProfile → succès, navigation dashboard passager');
        // Mettre à jour le token retourné par register
        final body = response.data?['body'] as Map?;
        final newToken = body?['token'] as String?;
        if (newToken != null && newToken.isNotEmpty) {
          UserController.instance.token.value = newToken;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', newToken);
        }
        UserController.instance.setRole('passenger');
        await UserController.instance.setProfileComplete(true);
        Get.offAllNamed(AppRoutes.dashboardPassenger);
      } else {
        final msg = response.data?['message'] as String? ??
            response.data?['error'] as String? ??
            'Erreur lors de la soumission (${response.statusCode}).';
        logger.w('createProfile → échec: $msg');
        UIHelper().showSnackBar('MINIZON', msg, 2);
      }
    } catch (e, st) {
      logger.e('createProfile → exception', error: e, stackTrace: st);
      UIHelper().showSnackBar(
          'MINIZON', 'Erreur réseau. Vérifiez votre connexion.', 2);
    } finally {
      isSubmitting.value = false;
      update();
    }
  }

  void continueLater() {
    UIHelper().showSnackBar('MINIZON', 'Vous pourrez compléter plus tard.', 1);
  }

  Future<void> addAvatarPhoto() async {
    final XFile? file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Images',
          mimeTypes: ['image/jpeg', 'image/png', 'image/webp', 'image/gif'],
          extensions: ['jpg', 'jpeg', 'png', 'webp', 'gif'],
        ),
      ],
    );
    if (file == null) return;
    _avatarFile = file;
    avatarImageName.value = file.name;
    update();
  }

  @override
  void onClose() {
    lastNameController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();
    neighborhoodController.dispose();
    addressController.dispose();
    super.onClose();
  }
}

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

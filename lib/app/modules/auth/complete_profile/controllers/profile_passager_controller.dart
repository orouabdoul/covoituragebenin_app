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

class ProfilePassagerController extends GetxController {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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

  // register_token (nouveau compte) ou null (utilisateur existant avec auth token)
  String? _registerToken;
  String _authPhone = '';

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
      // Nouveau utilisateur : numéro saisi à l'auth (retirer +229)
      final local = _authPhone.startsWith('+229')
          ? _authPhone.substring(4)
          : _authPhone;
      phoneController.text = local;
    } else if (_registerToken == null) {
      // Utilisateur existant : numéro depuis la session
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

  Future<void> createProfile() async {
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Prénom et nom sont requis.', 2);
      return;
    }

    // Nouveau compte → register_token requis ; utilisateur existant → auth token
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

      final Map<String, dynamic> fields = {
        'role_name': 'passenger',
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
      };

      if (isNewRegistration) {
        fields['register_token'] = _registerToken!;
      } else {
        final userUuid = UserController.instance.user.value?.uuid;
        if (userUuid != null) fields['user_uuid'] = userUuid;
      }

      if (emailController.text.trim().isNotEmpty) {
        fields['email'] = emailController.text.trim();
      }
      final phone = phoneController.text.trim();
      if (phone.isNotEmpty && phone != '01') fields['phone'] = phone;
      if (selectedCity.value != null) fields['city'] = selectedCity.value!;
      if (selectedNeighborhood.value != null) fields['neighborhood'] = selectedNeighborhood.value!;
      if (addressController.text.trim().isNotEmpty) fields['address_details'] = addressController.text.trim();
      if (genderCode != null) fields['gender'] = genderCode;

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

      logger.d('createProfile → POST ${AppApi.register} (new=$isNewRegistration)');
      logger.d('createProfile champs: $fields');

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

      logger.d('createProfile réponse [${response.statusCode}]: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        logger.i('createProfile → succès, navigation dashboard passager');
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

        uc.setRole('passenger');
        await uc.setProfileComplete(true);
        Get.offAllNamed(AppRoutes.dashboardPassenger);
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

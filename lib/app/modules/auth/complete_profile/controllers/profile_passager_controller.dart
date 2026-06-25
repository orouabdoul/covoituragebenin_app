import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/face_verification_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class ProfilePassagerController extends GetxController {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController neighborhoodController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final RxInt progress = 60.obs;
  final RxString avatarImageName = ''.obs;
  final Rxn<String> selectedGender = Rxn<String>();

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

  Future<void> createProfile() async {
    await UserController.instance.setProfileComplete(true);
    Get.offAllNamed(AppRoutes.dashboardPassenger);
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

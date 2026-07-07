import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:covoiturage_benin_app/app/core/services/passenger/profile/passenger_profile_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'profil_controller.dart';

class EditProfileController extends GetxController {
  final firstNameController  = TextEditingController();
  final lastNameController   = TextEditingController();
  final emailController      = TextEditingController();
  final cityController       = TextEditingController();
  final neighborhoodController = TextEditingController();

  final Rxn<XFile> avatarFile = Rxn<XFile>();
  final isSaving = false.obs;

  final _picker = ImagePicker();
  late final PassengerProfileService _profileService;

  @override
  void onInit() {
    super.onInit();
    _profileService = Get.find<PassengerProfileService>();
    _prefillFromProfile();
  }

  void _prefillFromProfile() {
    if (!Get.isRegistered<ProfilController>()) return;
    final profil = Get.find<ProfilController>();
    final name = profil.profileSummary.name.trim();
    if (name.isNotEmpty) {
      final parts = name.split(RegExp(r'\s+'));
      firstNameController.text = parts.first;
      if (parts.length > 1) lastNameController.text = parts.skip(1).join(' ');
    }
  }

  bool get hasAvatar => avatarFile.value != null;

  Future<void> pickAvatar() async {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AvatarSourceSheet(controller: this),
    );
  }

  Future<void> _pickFromGallery() async {
    Get.back();
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) avatarFile.value = file;
  }

  Future<void> _pickFromCamera() async {
    Get.back();
    final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file != null) avatarFile.value = file;
  }

  String? validateFirstName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Le prénom est requis';
    if (v.trim().length < 2) return 'Minimum 2 caractères';
    return null;
  }

  String? validateLastName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Le nom est requis';
    if (v.trim().length < 2) return 'Minimum 2 caractères';
    return null;
  }

  Future<void> save(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;

    final result = await _profileService.updateProfile(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      city: cityController.text.trim(),
      neighborhood: neighborhoodController.text.trim(),
    );

    isSaving.value = false;

    if (result.isSuccess) {
      // Recharge le profil pour refléter les modifications
      if (Get.isRegistered<ProfilController>()) {
        Get.find<ProfilController>().refresh();
      }
      Get.back(result: true);
      Get.snackbar(
        'Profil mis à jour',
        'Vos informations ont été sauvegardées.',
        backgroundColor: const Color(0xFF00A86B),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.check_circle_rounded, color: Colors.white),
      );
    } else {
      final msg = result.error == AppError.validationError
          ? 'Données invalides. Vérifiez les champs.'
          : 'Une erreur est survenue. Réessayez.';
      Get.snackbar(
        'Erreur',
        msg,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    cityController.dispose();
    neighborhoodController.dispose();
    super.onClose();
  }
}

class _AvatarSourceSheet extends StatelessWidget {
  const _AvatarSourceSheet({required this.controller});
  final EditProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Changer la photo',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF8), shape: BoxShape.circle),
              child: const Icon(Icons.photo_library_rounded, color: Color(0xFF00A86B)),
            ),
            title: const Text('Galerie photo',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            onTap: controller._pickFromGallery,
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF0F9FF), shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0EA5E9)),
            ),
            title: const Text('Appareil photo',
                style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            onTap: controller._pickFromCamera,
          ),
        ],
      ),
    );
  }
}

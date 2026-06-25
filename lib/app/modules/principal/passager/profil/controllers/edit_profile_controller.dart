import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';

class EditProfileController extends GetxController {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final bioController = TextEditingController();

  final Rxn<XFile> avatarFile = Rxn<XFile>();
  final isSaving = false.obs;
  final isSaved = false.obs;

  final _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    nameController.text = AppStrings.passengerProfileName;
    phoneController.text = AppStrings.passengerProfilePhone;
    emailController.text = 'passager@minizon.bj';
    bioController.text = '';
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

  String? validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Le nom est requis';
    if (v.trim().length < 2) return 'Minimum 2 caractères';
    return null;
  }

  String? validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Le numéro est requis';
    final digits = v.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Numéro invalide';
    return null;
  }

  void save(GlobalKey<FormState> formKey) {
    if (!formKey.currentState!.validate()) return;
    isSaving.value = true;
    Future.delayed(const Duration(milliseconds: 1200), () {
      isSaving.value = false;
      isSaved.value = true;
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
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    bioController.dispose();
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
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 16),
          const Text('Changer la photo', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF0FDF8), shape: BoxShape.circle),
              child: const Icon(Icons.photo_library_rounded, color: Color(0xFF00A86B)),
            ),
            title: const Text('Galerie photo', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            onTap: controller._pickFromGallery,
          ),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF0F9FF), shape: BoxShape.circle),
              child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0EA5E9)),
            ),
            title: const Text('Appareil photo', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w500)),
            onTap: controller._pickFromCamera,
          ),
        ],
      ),
    );
  }
}

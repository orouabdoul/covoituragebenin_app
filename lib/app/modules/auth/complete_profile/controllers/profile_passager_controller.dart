import 'package:file_selector/file_selector.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class ProfilePassagerController extends GetxController {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxInt progress = 60.obs;
  final RxString avatarImageName = ''.obs;

  void createProfile() {
    Get.offAllNamed(AppRoutes.dashboardPassenger);
  }

  void continueLater() {
    Get.snackbar('MINIZON', 'Vous pourrez compléter plus tard.');
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

    if (file == null) {
      return;
    }

    avatarImageName.value = file.name;
    update();
  }

  @override
  void onClose() {
    lastNameController.dispose();
    firstNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}

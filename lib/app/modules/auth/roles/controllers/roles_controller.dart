import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum RoleType {
  driver,
  passenger,
}

class RolesController extends GetxController {
  final Rxn<RoleType> selectedRole = Rxn<RoleType>();

  bool get hasSelection => selectedRole.value != null;

  void selectRole(RoleType role) {
    if (selectedRole.value == role) {
      return;
    }

    selectedRole.value = role;
    update();
  }

  void continueAction() {
    if (!hasSelection) {
      Get.snackbar('MINIZON', 'Veuillez choisir un profil avant de continuer.');
      return;
    }

    Get.toNamed(AppRoutes.register);
  }

  void chooseLater() {
    Get.snackbar('MINIZON', 'Vous pourrez choisir votre profil plus tard.');
  }
}
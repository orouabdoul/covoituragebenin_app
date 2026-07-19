import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/auth_mode.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum RoleType {
  driver,
  passenger,
}

class RolesController extends GetxController {
  final Rxn<RoleType> selectedRole = Rxn<RoleType>();
  bool _skipAuth = false;

  bool get hasSelection => selectedRole.value != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      _skipAuth = args['skipAuth'] == true;
    }
  }

  void selectRole(RoleType role) {
    if (selectedRole.value == role) return;
    selectedRole.value = role;
    update();
  }

  void continueAction() {
    if (!hasSelection) {
      UIHelper().showSnackBar('MINIZON', 'Veuillez choisir un profil avant de continuer.', 2);
      return;
    }

    if (_skipAuth) {
      final isDriver = selectedRole.value == RoleType.driver;
      final roleString = isDriver ? 'driver' : 'passenger';
      UserController.instance.setRole(roleString);
      // Synchroniser le rôle côté serveur (le serveur assigne "passenger" par défaut)
      Get.find<AuthService>().setUserRole(roleString);
      Get.offAllNamed(
        isDriver
            ? AppRoutes.completeProfileDriver
            : AppRoutes.completeProfilePassenger,
      );
      return;
    }

    Get.toNamed(
      AppRoutes.register,
      arguments: {'role': selectedRole.value, 'mode': AuthMode.register},
    );
  }

  void chooseLater() {
    UIHelper().showSnackBar('MINIZON', 'Vous pourrez choisir votre profil plus tard.', 1);
  }
}

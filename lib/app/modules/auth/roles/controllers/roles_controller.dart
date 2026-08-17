import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/auth_mode.dart';
import 'package:covoiturage_benin_app/app/core/controller/user_controller.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/auth/register/controllers/input_phone_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum RoleType {
  driver,
  passenger,
}

class RolesController extends GetxController {
  final Rxn<RoleType> selectedRole = Rxn<RoleType>();
  bool _skipAuth = false;
  String _storedPhone = '';
  String? _registerToken;
  String _authPhone = '';

  bool get hasSelection => selectedRole.value != null;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      _skipAuth = args['skipAuth'] == true;
      _storedPhone = args['phone'] as String? ?? '';
      _registerToken = args['registerToken'] as String?;
      _authPhone = args['phone'] as String? ?? '';
    }
    if (_storedPhone.isEmpty && Get.isRegistered<InputPhoneController>()) {
      _storedPhone = Get.find<InputPhoneController>().phoneController.text.trim();
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

      if (_registerToken != null) {
        // Nouveau compte : transmettre le register_token et le numéro à l'écran de profil
        Get.offAllNamed(
          isDriver
              ? AppRoutes.completeProfileDriver
              : AppRoutes.completeProfilePassenger,
          arguments: {
            'registerToken': _registerToken,
            'phone': _authPhone,
          },
        );
      } else {
        // Utilisateur existant avec profil incomplet : corriger le rôle côté serveur
        final roleString = isDriver ? 'driver' : 'passenger';
        UserController.instance.setRole(roleString);
        Get.find<AuthService>().setUserRole(roleString);
        Get.offAllNamed(
          isDriver
              ? AppRoutes.completeProfileDriver
              : AppRoutes.completeProfilePassenger,
        );
      }
      return;
    }

    Get.toNamed(
      AppRoutes.register,
      arguments: {
        'role': selectedRole.value,
        'mode': AuthMode.register,
        'phone': _storedPhone,
      },
    );
  }

  void chooseLater() {
    UIHelper().showSnackBar('MINIZON', 'Vous pourrez choisir votre profil plus tard.', 1);
  }
}

import 'package:get/get.dart';

enum DriverType {
  car,
  moto,
}

class ProfileDriverController extends GetxController {
  final Rx<DriverType> selectedDriverType = DriverType.car.obs;
  final RxInt progress = 75.obs;

  void selectDriverType(DriverType type) {
    if (selectedDriverType.value == type) {
      return;
    }

    selectedDriverType.value = type;
    update();
  }

  void continueProfile() {
    Get.snackbar('MINIZON', 'Suite du profil à connecter ensuite.');
  }

  void addVehiclePhoto() {
    Get.snackbar('MINIZON', 'Ajout de photo à brancher.');
  }

  void addRequiredDocument() {
    Get.snackbar('MINIZON', 'Ajout de document à brancher.');
  }
}
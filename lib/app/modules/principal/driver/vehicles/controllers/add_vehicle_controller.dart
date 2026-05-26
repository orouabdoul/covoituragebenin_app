import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';

enum VehicleType { car, motorcycle }

class AddVehicleController extends GetxController {
  final RxnInt currentStep = RxnInt(0);
  final selectedVehicleType = Rxn<VehicleType>(VehicleType.car);

  final brandController = TextEditingController();
  final modelController = TextEditingController();
  final colorController = TextEditingController();
  final yearController = TextEditingController();
  final licensePlateController = TextEditingController();
  final seatsController = TextEditingController();
  final fuelController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    currentStep.value = 0;
  }

  void selectVehicleType(VehicleType type) {
    selectedVehicleType.value = type;
  }

  void onBack() => Get.back();

  void onSaveAsDraft() {
    Get.snackbar(AppStrings.appName, AppStrings.driverVehicleSaveDraft);
  }

  void onAddPhoto(String photoType) {
    Get.snackbar(AppStrings.appName, 'Ajouter photo: $photoType');
  }

  void onAddDocument(String documentType) {
    Get.snackbar(AppStrings.appName, 'Ajouter document: $documentType');
  }

  void onRegisterVehicle() {
    Get.snackbar(AppStrings.appName, AppStrings.driverVehicleRegister);
  }

  @override
  void onClose() {
    brandController.dispose();
    modelController.dispose();
    colorController.dispose();
    yearController.dispose();
    licensePlateController.dispose();
    seatsController.dispose();
    fuelController.dispose();
    super.onClose();
  }
}

class VehicleTypeCard {
  final VehicleType type;
  final String title;
  final String subtitle;
  final IconData icon;

  const VehicleTypeCard({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class PhotoUploadSlot {
  final String label;
  final IconData icon;

  const PhotoUploadSlot({required this.label, required this.icon});
}

class DocumentItem {
  final String label;
  final String description;
  final String buttonLabel;
  final Color badgeColor;
  final IconData icon;

  const DocumentItem({
    required this.label,
    required this.description,
    required this.buttonLabel,
    required this.badgeColor,
    required this.icon,
  });
}

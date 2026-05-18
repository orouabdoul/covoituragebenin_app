import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum DriverType { car, moto }

class ProfileDriverController extends GetxController {
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController vehicleBrandController = TextEditingController();
  final TextEditingController vehicleModelController = TextEditingController();
  final TextEditingController vehicleColorController = TextEditingController();
  final TextEditingController vehicleSeatsController = TextEditingController();
  final TextEditingController plateController = TextEditingController();

  final Rx<DriverType> selectedDriverType = DriverType.car.obs;
  final RxInt progress = 75.obs;
  final RxString vehiclePhotoName = ''.obs;
  final RxString registrationDocumentName = ''.obs;
  final RxString licenseDocumentName = ''.obs;

  void selectDriverType(DriverType type) {
    if (selectedDriverType.value == type) {
      return;
    }

    selectedDriverType.value = type;
    update();
  }

  void continueProfile() {
    Get.offAllNamed(AppRoutes.dashboardDriver);
  }

  Future<void> addVehiclePhoto() async {
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

    vehiclePhotoName.value = file.name;
    update();
  }

  Future<void> addRequiredDocument({required bool isLicense}) async {
    final XFile? file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'Documents',
          mimeTypes: [
            'application/pdf',
            'image/jpeg',
            'image/png',
            'application/msword',
            'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          ],
          extensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
        ),
      ],
    );

    if (file == null) {
      return;
    }

    if (isLicense) {
      licenseDocumentName.value = file.name;
    } else {
      registrationDocumentName.value = file.name;
    }

    update();
  }

  @override
  void onClose() {
    lastNameController.dispose();
    firstNameController.dispose();
    phoneController.dispose();
    vehicleBrandController.dispose();
    vehicleModelController.dispose();
    vehicleColorController.dispose();
    vehicleSeatsController.dispose();
    plateController.dispose();
    super.onClose();
  }
}

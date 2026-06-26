import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

class DriverSafetyController extends GetxController {
  final RxBool isSharingLocation = false.obs;
  final RxBool sosPressActive = false.obs;

  void onSosPressed() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFFF1F2),
        title: const Text('Envoyer une alerte SOS ?',
            style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w800)),
        content: const Text(
          'Cette action contactera immédiatement le support MINIZON et vos contacts d\'urgence.',
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              Get.back();
              UIHelper().showSnackBar('SOS', 'Alerte envoyée ! Aide en route.', 2);
            },
            child: const Text('Confirmer', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void toggleLocationSharing() {
    isSharingLocation.value = !isSharingLocation.value;
    UIHelper().showSnackBar(
      'MINIZON',
      isSharingLocation.value
          ? 'Partage de position activé.'
          : 'Partage de position désactivé.',
      isSharingLocation.value ? 0 : 1,
    );
  }

  void onAddEmergencyContact() {
    UIHelper().showSnackBar('MINIZON', 'Ajout de contact bientôt disponible.', 1);
  }

  void onCallSupport() {
    UIHelper().showSnackBar('MINIZON', 'Appel support…', 1);
  }

  void onReportIncident() {
    UIHelper().showSnackBar('MINIZON', 'Signalement disponible bientôt.', 1);
  }
}

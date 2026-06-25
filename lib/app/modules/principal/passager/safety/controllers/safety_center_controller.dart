import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

class EmergencyContact {
  final String id;
  final String name;
  final String phone;
  final String relation;
  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });
}

class SafetyCenterController extends GetxController {
  final sosActivated = false.obs;
  final isSharingTrip = false.obs;

  final emergencyContacts = <EmergencyContact>[
    const EmergencyContact(id: '1', name: 'Maman Adjoua', phone: '+229 97 12 34 56', relation: 'Famille'),
    const EmergencyContact(id: '2', name: 'Frère Kouamé', phone: '+229 96 78 90 12', relation: 'Famille'),
  ].obs;

  void triggerSOS() {
    Get.dialog(
      _SOSConfirmDialog(onConfirm: _activateSOS),
      barrierDismissible: false,
    );
  }

  void _activateSOS() {
    sosActivated.value = true;
    Get.snackbar(
      '🆘 Alerte SOS activée',
      'Vos contacts d\'urgence ont été notifiés avec votre position.',
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

  void cancelSOS() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Annuler l\'alerte ?', style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
          'Êtes-vous en sécurité ?\nVoulez-vous annuler l\'alerte SOS ?',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Non, garder SOS')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.back();
              sosActivated.value = false;
              Get.snackbar(
                'Alerte annulée',
                'L\'alerte SOS a été désactivée.',
                backgroundColor: AppColors.textSecondary,
                colorText: Colors.white,
              );
            },
            child: const Text('Oui, je suis en sécurité', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void toggleShareTrip() {
    isSharingTrip.value = !isSharingTrip.value;
    Get.snackbar(
      isSharingTrip.value ? 'Trajet partagé ✓' : 'Partage arrêté',
      isSharingTrip.value
          ? 'Vos contacts peuvent suivre votre trajet en temps réel.'
          : 'Le partage de trajet a été désactivé.',
      backgroundColor: isSharingTrip.value ? AppColors.primary : AppColors.textHint,
      colorText: Colors.white,
    );
  }

  void callService(String name, String number) {
    Get.snackbar(
      'Appel en cours',
      'Composition du $number ($name)...',
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
    );
  }

  void removeContact(int index) {
    emergencyContacts.removeAt(index);
  }

  void addContact() {
    Get.snackbar(
      'Bientôt disponible',
      'L\'ajout de contacts sera disponible prochainement.',
      backgroundColor: AppColors.textSecondary,
      colorText: Colors.white,
    );
  }
}

class _SOSConfirmDialog extends StatelessWidget {
  const _SOSConfirmDialog({required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 28),
          SizedBox(width: 10),
          Text('Alerte SOS', style: TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
      content: const Text(
        'Voulez-vous déclencher une alerte SOS ?\n\nVos contacts d\'urgence seront immédiatement notifiés avec votre position actuelle.',
        style: TextStyle(height: 1.6),
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Annuler')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDC2626),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          onPressed: () {
            Get.back();
            onConfirm();
          },
          child: const Text(
            'CONFIRMER SOS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

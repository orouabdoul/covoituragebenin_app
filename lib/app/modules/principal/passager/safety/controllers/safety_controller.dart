import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SafetyController extends GetxController {
  final sosActivated = false.obs;
  final isSharingTrip = false.obs;
  final shareCode = ''.obs;

  final emergencyContacts = <Map<String, String>>[
    {'name': 'Maman', 'phone': '+229 97 XX XX XX', 'initials': 'MA'},
    {'name': 'Papa', 'phone': '+229 95 XX XX XX', 'initials': 'PA'},
  ].obs;

  void showSOSConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0x1AEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_rounded, color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Activer le SOS ?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: Color(0xFF111111),
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Vos contacts d\'urgence et MINIZON seront alertés avec votre position. Cette action est réservée aux situations de danger réel.',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            color: Color(0xFF4B5563),
            height: 1.6,
          ),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text(
              'Annuler',
              style: TextStyle(fontFamily: 'Inter', color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _activateSOS();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: const Text(
              'ENVOYER SOS',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _activateSOS() {
    sosActivated.value = true;
    Get.snackbar(
      '🆘 SOS Activé',
      'Vos contacts d\'urgence ont été alertés. Restez calme.',
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.warning_rounded, color: Colors.white),
    );
  }

  void cancelSOS() {
    sosActivated.value = false;
    Get.snackbar(
      'SOS Annulé',
      'L\'alerte a été désactivée.',
      backgroundColor: const Color(0xFF374151),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void shareTrip() {
    final code = 'MINIZON-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    shareCode.value = code;
    isSharingTrip.value = true;
    Get.snackbar(
      'Trajet partagé',
      'Votre lien de suivi a été créé.',
      backgroundColor: const Color(0xFF00A86B),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.share_rounded, color: Colors.white),
    );
  }

  void copyShareLink() {
    final link = 'https://minizon.bj/track/${shareCode.value}';
    Clipboard.setData(ClipboardData(text: link));
    Get.snackbar(
      'Copié !',
      'Lien de suivi copié dans le presse-papiers.',
      backgroundColor: const Color(0xFF374151),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void stopSharing() {
    isSharingTrip.value = false;
    shareCode.value = '';
  }

  void addEmergencyContact() {
    Get.snackbar(
      'Bientôt disponible',
      'L\'ajout de contacts d\'urgence sera disponible prochainement.',
      backgroundColor: const Color(0xFF374151),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void callEmergencyContact(String phone) {
    Get.snackbar(
      'Appel en cours',
      'Appel vers $phone...',
      backgroundColor: const Color(0xFF00A86B),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.phone_rounded, color: Colors.white),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/safety/passenger_safety_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/safety_model.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

export 'package:covoiturage_benin_app/app/data/models/passenger/safety_model.dart'
    show EmergencyContact;

class SafetyCenterController extends GetxController {
  PassengerSafetyService get _service => Get.find<PassengerSafetyService>();

  final sosActivated   = false.obs;
  final isSharingTrip  = false.obs;
  final shareCode      = ''.obs;

  final emergencyContacts = <EmergencyContact>[].obs;

  // Add contact form
  final addNameController     = TextEditingController();
  final addPhoneController    = TextEditingController();
  final selectedRelation      = 'Famille'.obs;
  final isAddingContact       = false.obs;

  static const _relationOptions = ['Famille', 'Ami·e', 'Collègue', 'Autre'];

  @override
  void onInit() {
    super.onInit();
    _loadContext();
  }

  Future<void> _loadContext() async {
    final result = await _service.fetchContext();
    if (result.isSuccess) {
      final ctx = result.data!;
      sosActivated.value  = ctx.sosActive;
      isSharingTrip.value = ctx.tripShareActive;
      shareCode.value     = ctx.tripShareCode ?? '';
      emergencyContacts.assignAll(ctx.contacts);
    } else {
      logger.e('passengerSafety context: ${result.error}');
    }
  }

  // ── SOS ──────────────────────────────────────────────────────────────────

  void triggerSOS() {
    Get.dialog(
      _SOSConfirmDialog(onConfirm: _activateSOS),
      barrierDismissible: false,
    );
  }

  Future<void> _activateSOS() async {
    final result = await _service.activateSOS();
    if (result.isSuccess) {
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
    } else if (result.error != AppError.socket) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'activer l\'alerte SOS. Réessayez.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
    }
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
            onPressed: () async {
              Get.back();
              final result = await _service.cancelSOS();
              if (result.isSuccess) {
                sosActivated.value = false;
                Get.snackbar(
                  'Alerte annulée',
                  'L\'alerte SOS a été désactivée.',
                  backgroundColor: AppColors.textSecondary,
                  colorText: Colors.white,
                );
              } else if (result.error != AppError.socket) {
                Get.snackbar(
                  'Erreur',
                  'Impossible d\'annuler l\'alerte. Réessayez.',
                  backgroundColor: AppColors.warning,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('Oui, je suis en sécurité', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Trip Share ────────────────────────────────────────────────────────────

  Future<void> toggleShareTrip() async {
    if (isSharingTrip.value) {
      final result = await _service.stopTripShare();
      if (result.isSuccess) {
        isSharingTrip.value = false;
        shareCode.value = '';
        Get.snackbar(
          'Partage arrêté',
          'Le partage de trajet a été désactivé.',
          backgroundColor: AppColors.textHint,
          colorText: Colors.white,
        );
      } else if (result.error != AppError.socket) {
        Get.snackbar('Erreur', 'Impossible d\'arrêter le partage.', backgroundColor: AppColors.warning, colorText: Colors.white);
      }
    } else {
      final result = await _service.startTripShare();
      if (result.isSuccess) {
        isSharingTrip.value = true;
        shareCode.value = result.data!;
        final code = result.data!;
        Get.snackbar(
          'Trajet partagé ✓',
          code.isNotEmpty
              ? 'Lien : minizon.bj/track/$code'
              : 'Vos contacts peuvent suivre votre trajet en temps réel.',
          backgroundColor: AppColors.primary,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      } else if (result.error != AppError.socket) {
        Get.snackbar('Erreur', 'Impossible de démarrer le partage.', backgroundColor: AppColors.warning, colorText: Colors.white);
      }
    }
  }

  // ── Emergency Services ────────────────────────────────────────────────────

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

  // ── Emergency Contacts ────────────────────────────────────────────────────

  Future<void> removeContact(int index) async {
    if (index >= emergencyContacts.length) return;
    final contact = emergencyContacts[index];
    emergencyContacts.removeAt(index);
    final result = await _service.deleteContact(contact.id);
    if (!result.isSuccess) {
      emergencyContacts.insert(index, contact);
      if (result.error != AppError.socket) {
        Get.snackbar('Erreur', 'Impossible de supprimer le contact.', backgroundColor: AppColors.warning, colorText: Colors.white);
      }
    }
  }

  void addContact() {
    addNameController.clear();
    addPhoneController.clear();
    selectedRelation.value = _relationOptions.first;
    Get.bottomSheet(
      _AddContactSheet(controller: this, relations: _relationOptions),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _submitNewContact() async {
    final name     = addNameController.text.trim();
    final phone    = addPhoneController.text.trim();
    final relation = selectedRelation.value;

    if (name.isEmpty || phone.isEmpty) {
      Get.snackbar('Champs requis', 'Veuillez remplir le nom et le téléphone.', backgroundColor: AppColors.warning, colorText: Colors.white);
      return;
    }
    isAddingContact.value = true;
    final result = await _service.addContact(name: name, phone: phone, relation: relation);
    isAddingContact.value = false;
    if (result.isSuccess) {
      emergencyContacts.add(result.data!);
      Get.back();
      Get.snackbar('Contact ajouté ✓', '$name a été ajouté à vos contacts d\'urgence.', backgroundColor: AppColors.primary, colorText: Colors.white);
    } else if (result.error == AppError.validationError) {
      Get.snackbar('Données invalides', 'Vérifiez le numéro de téléphone.', backgroundColor: AppColors.warning, colorText: Colors.white);
    } else if (result.error != AppError.socket) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter le contact.', backgroundColor: AppColors.warning, colorText: Colors.white);
    }
  }

  @override
  void onClose() {
    addNameController.dispose();
    addPhoneController.dispose();
    super.onClose();
  }
}

// ── SOS Confirm Dialog ────────────────────────────────────────────────────────

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

// ── Add Contact Bottom Sheet ──────────────────────────────────────────────────

class _AddContactSheet extends StatelessWidget {
  const _AddContactSheet({required this.controller, required this.relations});
  final SafetyCenterController controller;
  final List<String> relations;

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Padding(
            padding: EdgeInsets.symmetric(vertical: responsive.h(12)),
            child: Center(
              child: Container(
                width: responsive.w(40),
                height: responsive.h(4),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(responsive.w(20), 0, responsive.w(20), responsive.h(28)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nouveau contact d\'urgence', style: AppTextStyles.h6(responsive)),
                SizedBox(height: responsive.h(20)),
                // Name
                Text('Nom complet', style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                SizedBox(height: responsive.h(8)),
                TextField(
                  controller: controller.addNameController,
                  style: AppTextStyles.body(responsive),
                  textCapitalization: TextCapitalization.words,
                  decoration: _inputDecoration('Ex: Jean Dupont', responsive),
                ),
                SizedBox(height: responsive.h(14)),
                // Phone
                Text('Numéro de téléphone', style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                SizedBox(height: responsive.h(8)),
                TextField(
                  controller: controller.addPhoneController,
                  style: AppTextStyles.body(responsive),
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('+229 97 00 00 00', responsive),
                ),
                SizedBox(height: responsive.h(14)),
                // Relation
                Text('Relation', style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                SizedBox(height: responsive.h(8)),
                Obx(() => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: relations.asMap().entries.map((e) {
                      final selected = controller.selectedRelation.value == e.value;
                      return Padding(
                        padding: EdgeInsets.only(right: e.key < relations.length - 1 ? responsive.w(8) : 0),
                        child: GestureDetector(
                          onTap: () => controller.selectedRelation.value = e.value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(7)),
                            decoration: BoxDecoration(
                              color: selected ? AppColors.primary : AppColors.surfaceMuted,
                              borderRadius: BorderRadius.circular(9999),
                              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                            ),
                            child: Text(
                              e.value,
                              style: AppTextStyles.caption(responsive).copyWith(
                                color: selected ? Colors.white : AppColors.textSecondary,
                                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )),
                SizedBox(height: responsive.h(20)),
                Obx(() => controller.isAddingContact.value
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3))
                    : AppPrimaryButton(
                        responsive: responsive,
                        label: 'Ajouter le contact',
                        onTap: controller._submitNewContact,
                        height: responsive.h(52),
                        borderRadius: responsive.radius(14),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, AppResponsive responsive) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
      filled: true,
      fillColor: AppColors.surfaceMuted,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      contentPadding: EdgeInsets.all(responsive.w(14)),
    );
  }
}

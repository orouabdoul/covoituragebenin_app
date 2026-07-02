import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/providers/safety_provider.dart';

class EmergencyContact {
  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  final String id;
  final String name;
  final String phone;
  final String relation;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => EmergencyContact(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: json['phone'] as String,
        relation: (json['relation'] as String?) ?? 'Proche',
      );
}

class DriverSafetyController extends GetxController {
  final _provider = SafetyProvider();

  final RxBool isLoading        = false.obs;
  final RxBool isSharingLocation = false.obs;
  final RxList<EmergencyContact> emergencyContacts = <EmergencyContact>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadContacts();
  }

  // ── Chargement initial ────────────────────────────────────────────────────

  Future<void> _loadContacts() async {
    isLoading.value = true;
    final result = await _provider.fetchContacts();
    isLoading.value = false;

    if (result.isSuccess) {
      emergencyContacts.assignAll(
        result.data!.map(EmergencyContact.fromJson),
      );
    }
    // Échec silencieux — contacts restent vides, l'UI l'indique déjà
  }

  // ── SOS ──────────────────────────────────────────────────────────────────

  void onSosPressed() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: const Color(0xFFFFF1F2),
        title: const Text(
          'Envoyer une alerte SOS ?',
          style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w800),
        ),
        content: const Text(
          "Cette action contactera immédiatement le support MINIZON et vos contacts d'urgence. Une équipe sera dépêchée dans les plus brefs délais.",
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Get.back();
              final result = await _provider.sendSos();
              if (result.isSuccess) {
                UIHelper().showSnackBar('SOS', 'Alerte envoyée ! Aide en route.', 2);
              } else {
                UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
              }
            },
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location sharing ──────────────────────────────────────────────────────

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

  // ── Emergency contacts ────────────────────────────────────────────────────

  void onAddEmergencyContact() {
    final nameCtrl     = TextEditingController();
    final phoneCtrl    = TextEditingController();
    final relationCtrl = TextEditingController();

    Get.bottomSheet(
      _ContactForm(
        nameController:     nameCtrl,
        phoneController:    phoneCtrl,
        relationController: relationCtrl,
        onSave: () async {
          final name     = nameCtrl.text.trim();
          final phone    = phoneCtrl.text.trim();
          final relation = relationCtrl.text.trim();

          if (name.isEmpty || phone.isEmpty) {
            UIHelper().showSnackBar('MINIZON', 'Nom et téléphone requis.', 2);
            return;
          }

          Get.back();
          nameCtrl.dispose();
          phoneCtrl.dispose();
          relationCtrl.dispose();

          final result = await _provider.addContact(
            name:     name,
            phone:    phone,
            relation: relation.isEmpty ? 'Proche' : relation,
          );

          if (result.isSuccess) {
            emergencyContacts.assignAll(result.data!.map(EmergencyContact.fromJson));
            UIHelper().showSnackBar('MINIZON', 'Contact ajouté avec succès.', 0);
          } else {
            UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
          }
        },
        onCancel: () {
          Get.back();
          nameCtrl.dispose();
          phoneCtrl.dispose();
          relationCtrl.dispose();
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onRemoveContact(EmergencyContact contact) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce contact ?'),
        content: Text("${contact.name} sera retiré de vos contacts d'urgence."),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Get.back();
              // Rollback optimiste
              final backup = List<EmergencyContact>.from(emergencyContacts);
              emergencyContacts.removeWhere((c) => c.id == contact.id);

              final result = await _provider.removeContact(contact.id);
              if (result.isSuccess) {
                emergencyContacts.assignAll(result.data!.map(EmergencyContact.fromJson));
                UIHelper().showSnackBar('MINIZON', 'Contact supprimé.', 1);
              } else {
                emergencyContacts.assignAll(backup); // rollback
                UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(color: Color(0xFFEF4444))),
          ),
        ],
      ),
    );
  }

  // ── Support call ──────────────────────────────────────────────────────────

  void onCallSupport() {
    const supportNumber = '+229 21 31 00 00';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_rounded, color: Color(0xFF00A86B)),
            SizedBox(width: 10),
            Text('Support MINIZON', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Disponible 24h/24 · 7j/7'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                supportNumber,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00A86B),
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: supportNumber));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro copié dans le presse-papiers.', 0);
            },
            child: const Text('Copier le numéro',
                style: TextStyle(color: Color(0xFF00A86B), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Incident report ───────────────────────────────────────────────────────

  void onReportIncident() {
    Get.bottomSheet(
      _IncidentReportSheet(
        onSubmit: (category, description) async {
          Get.back();
          final result = await _provider.reportIncident(
            category:    category,
            description: description.isEmpty ? null : description,
          );
          if (result.isSuccess) {
            UIHelper().showSnackBar(
              'MINIZON',
              'Incident signalé. Notre équipe vous contacte sous 30 min.',
              0,
            );
          } else {
            UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
          }
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  // ── Emergency numbers ─────────────────────────────────────────────────────

  void onCallEmergencyNumber(String number, String label) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Appeler $label', style: const TextStyle(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: number));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro $number copié.', 0);
            },
            child: const Text('Copier',
                style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Form widget (contact d'urgence) ──────────────────────────────────────────

class _ContactForm extends StatelessWidget {
  const _ContactForm({
    required this.nameController,
    required this.phoneController,
    required this.relationController,
    required this.onSave,
    required this.onCancel,
  });
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController relationController;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Ajouter un contact d'urgence",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              "Ce contact sera notifié en cas d'alerte SOS.",
              style: TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            _FormInput(controller: nameController,     label: 'Nom complet', hint: 'Ex: Jean Dupont',       icon: Icons.person_rounded),
            const SizedBox(height: 12),
            _FormInput(controller: phoneController,    label: 'Téléphone',   hint: '+229 97 00 00 00',      icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _FormInput(controller: relationController, label: 'Relation',    hint: 'Ex: Époux, Frère, Ami…', icon: Icons.favorite_rounded),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onCancel,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Text('Annuler',
                            style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: onSave,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('Enregistrer',
                            style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FormInput extends StatelessWidget {
  const _FormInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textGhost),
              prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Incident report sheet ─────────────────────────────────────────────────────

class _IncidentReportSheet extends StatefulWidget {
  const _IncidentReportSheet({required this.onSubmit});
  final void Function(String category, String description) onSubmit;

  @override
  State<_IncidentReportSheet> createState() => _IncidentReportSheetState();
}

class _IncidentReportSheetState extends State<_IncidentReportSheet> {
  String? _selectedCategory;
  final _descCtrl = TextEditingController();

  static const _categories = [
    ('Passager agressif',  Icons.person_off_rounded,  Color(0xFFEF4444)),
    ('Accident de route',  Icons.car_crash_rounded,   Color(0xFFF59E0B)),
    ('Panne de véhicule',  Icons.car_repair_rounded,  Color(0xFF6366F1)),
    ('Vol ou tentative',   Icons.warning_rounded,     Color(0xFFDC2626)),
    ('Harcèlement',        Icons.report_rounded,      Color(0xFFF97316)),
    ('Autre incident',     Icons.more_horiz_rounded,  Color(0xFF9CA3AF)),
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                children: [
                  Icon(Icons.flag_rounded, color: Color(0xFFF59E0B), size: 22),
                  SizedBox(width: 8),
                  Text('Signaler un incident',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Votre rapport est confidentiel et traité en priorité.',
                  style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              const Text("Type d'incident",
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((c) {
                  final isSelected = _selectedCategory == c.$1;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = c.$1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? c.$3.withValues(alpha: 0.12)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? c.$3 : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(c.$2, size: 14, color: isSelected ? c.$3 : AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(c.$1,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                color: isSelected ? c.$3 : AppColors.textPrimary,
                              )),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              const Text('Description (optionnel)',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: TextField(
                  controller: _descCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: "Décrivez ce qui s'est passé…",
                    hintStyle: TextStyle(color: AppColors.textGhost),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: _selectedCategory == null
                    ? () => UIHelper()
                        .showSnackBar('MINIZON', "Sélectionnez un type d'incident.", 2)
                    : () => widget.onSubmit(_selectedCategory!, _descCtrl.text.trim()),
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _selectedCategory == null
                        ? AppColors.textGhost
                        : const Color(0xFFF59E0B),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Envoyer le signalement',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontSize: 15)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

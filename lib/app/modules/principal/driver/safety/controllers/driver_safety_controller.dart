import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/safety/safety_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/safety/safety_service_impl.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';

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
        id: json['id']?.toString() ?? '',
        name: (json['name'] as String?) ?? '',
        phone: (json['phone'] as String?) ?? '',
        relation: (json['relation'] as String?) ?? 'Proche',
      );
}

class DriverSafetyController extends GetxController {
  static const _kSupportPhone = '+229 21 31 00 00';

  SafetyService get _service => Get.find<SafetyService>();

  String _errorMsg(dynamic error) {
    final svc = _service;
    if (error == AppError.validationError && svc is SafetyServiceImpl) {
      return svc.lastValidationMessage ?? (error as AppError).message;
    }
    return (error as AppError).message;
  }

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
    final result = await _service.fetchContacts();
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
        backgroundColor: AppColors.dangerSurface,
        title: const Text(
          'Envoyer une alerte SOS ?',
          style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          "Cette action contactera immédiatement le support MINIZON et vos contacts d'urgence. Une équipe sera dépêchée dans les plus brefs délais.",
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              Get.back();
              final result = await _service.sendSos();
              if (result.isSuccess) {
                UIHelper().showSnackBar('SOS', 'Alerte envoyée ! Aide en route.', 0);
              } else {
                UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
              }
            },
            child: const Text(
              'Confirmer',
              style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location sharing ──────────────────────────────────────────────────────

  bool _isTogglingLocation = false;

  Future<void> toggleLocationSharing() async {
    if (_isTogglingLocation) return;
    _isTogglingLocation = true;
    final newValue = !isSharingLocation.value;
    isSharingLocation.value = newValue;
    final result = await _service.updateLocationSharing(newValue);
    if (result.isSuccess) {
      UIHelper().showSnackBar(
        'MINIZON',
        newValue ? 'Partage de position activé.' : 'Partage de position désactivé.',
        newValue ? 0 : 1,
      );
    } else {
      isSharingLocation.value = !newValue;
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
    _isTogglingLocation = false;
  }

  // ── Emergency contacts ────────────────────────────────────────────────────

  void onAddEmergencyContact() {
    Get.bottomSheet(
      _ContactForm(
        onSave: (name, phone, relation) async {
          final result = await _service.addContact(
            name:     name,
            phone:    phone,
            relation: relation.isEmpty ? 'Proche' : relation,
          );
          if (result.isSuccess) {
            Get.back();
            emergencyContacts.assignAll(result.data!.map(EmergencyContact.fromJson));
            UIHelper().showSnackBar('MINIZON', 'Contact ajouté avec succès.', 0);
          } else {
            UIHelper().showSnackBar('MINIZON', _errorMsg(result.error), 2);
          }
        },
        onCancel: Get.back,
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

              final result = await _service.removeContact(contact.id);
              if (result.isSuccess) {
                emergencyContacts.assignAll(result.data!.map(EmergencyContact.fromJson));
                UIHelper().showSnackBar('MINIZON', 'Contact supprimé.', 1);
              } else {
                emergencyContacts.assignAll(backup); // rollback
                UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
              }
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }

  // ── Support call ──────────────────────────────────────────────────────────

  void onCallSupport() {
    const supportNumber = _kSupportPhone;
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.headset_mic_rounded, color: AppColors.primary),
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
                color: AppColors.successSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                supportNumber,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
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
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
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
          final result = await _service.reportIncident(
            category:    category,
            description: description.isEmpty ? null : description,
          );
          if (result.isSuccess) {
            UIHelper().showSnackBar(
              'MINIZON',
              'Incident signalé. Notre équipe vous contacte sous 30 min.',
              0,
            );
            return true;
          } else {
            UIHelper().showSnackBar('MINIZON', _errorMsg(result.error), 2);
            return false;
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
                color: AppColors.dangerSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.danger,
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
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Form widget (contact d'urgence) ──────────────────────────────────────────

class _ContactForm extends StatefulWidget {
  const _ContactForm({required this.onSave, required this.onCancel});
  final Future<void> Function(String name, String phone, String relation) onSave;
  final VoidCallback onCancel;

  @override
  State<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<_ContactForm> {
  bool _isSaving = false;
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _relationCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relationCtrl.dispose();
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
            _FormInput(controller: _nameCtrl,     label: 'Nom complet', hint: 'Ex: Jean Dupont',        icon: Icons.person_rounded),
            const SizedBox(height: 12),
            _FormInput(controller: _phoneCtrl,    label: 'Téléphone',   hint: '+229 97 00 00 00',       icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _FormInput(controller: _relationCtrl, label: 'Relation',    hint: 'Ex: Époux, Frère, Ami…', icon: Icons.favorite_rounded),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _isSaving ? null : widget.onCancel,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.transparent),
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
                    onTap: _isSaving
                        ? null
                        : () async {
                            final name     = _nameCtrl.text.trim();
                            final phone    = _phoneCtrl.text.trim();
                            final relation = _relationCtrl.text.trim();
                            if (name.isEmpty || phone.isEmpty) {
                              UIHelper().showSnackBar('MINIZON', 'Nom et téléphone requis.', 2);
                              return;
                            }
                            setState(() => _isSaving = true);
                            await widget.onSave(name, phone, relation);
                            if (mounted) setState(() => _isSaving = false);
                          },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _isSaving
                            ? AppColors.primary.withValues(alpha: 0.6)
                            : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Enregistrer',
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
            border: Border.all(color: Colors.transparent, width: 1.5),
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
  final Future<bool> Function(String category, String description) onSubmit;

  @override
  State<_IncidentReportSheet> createState() => _IncidentReportSheetState();
}

class _IncidentReportSheetState extends State<_IncidentReportSheet> {
  String? _selectedCategory;
  bool _isSending = false;
  final _descCtrl = TextEditingController();

  static const _categories = [
    ('Passager agressif',  Icons.person_off_rounded,  AppColors.danger),
    ('Accident de route',  Icons.car_crash_rounded,   AppColors.warning),
    ('Panne de véhicule',  Icons.car_repair_rounded,  AppColors.primary),
    ('Vol ou tentative',   Icons.warning_rounded,     AppColors.danger),
    ('Harcèlement',        Icons.report_rounded,      AppColors.accent),
    ('Autre incident',     Icons.more_horiz_rounded,  AppColors.textHint),
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
                  Icon(Icons.flag_rounded, color: AppColors.warning, size: 22),
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
                          color: isSelected ? c.$3 : Colors.transparent,
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
                  border: Border.all(color: Colors.transparent, width: 1.5),
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
                onTap: _isSending
                    ? null
                    : _selectedCategory == null
                        ? () => UIHelper()
                            .showSnackBar('MINIZON', "Sélectionnez un type d'incident.", 2)
                        : () async {
                            setState(() => _isSending = true);
                            final success = await widget.onSubmit(
                                _selectedCategory!, _descCtrl.text.trim());
                            if (!mounted) return;
                            if (success) {
                              Get.back();
                            } else {
                              setState(() => _isSending = false);
                            }
                          },
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _isSending || _selectedCategory == null
                        ? AppColors.textGhost
                        : AppColors.warning,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _isSending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Envoyer le signalement',
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class PassengerConfirmation {
  PassengerConfirmation({
    required this.name,
    required this.initial,
    required this.hasConfirmed,
  });
  final String name;
  final String initial;
  bool hasConfirmed;
}

class EndTripController extends GetxController {
  final RxBool isConfirming = false.obs;
  final RxList<PassengerConfirmation> confirmations = <PassengerConfirmation>[
    PassengerConfirmation(name: 'Aminata Koné', initial: 'A', hasConfirmed: false),
    PassengerConfirmation(name: 'Kwame Asante', initial: 'K', hasConfirmed: true),
  ].obs;

  final String tripRoute = 'Cotonou → Porto-Novo';
  final String realDuration = '1h 52min';
  final double distanceKm = 36.2;
  final int passengersCount = 2;
  final double grossRevenue = 5000;
  final double commission = 500;

  double get netRevenue => grossRevenue - commission;

  int get confirmedCount =>
      confirmations.where((c) => c.hasConfirmed).length;

  bool get allConfirmed => confirmations.every((c) => c.hasConfirmed);

  String get availableDate {
    final tomorrow = DateTime.now().add(const Duration(hours: 24));
    return '${tomorrow.day}/${tomorrow.month}/${tomorrow.year} à ${tomorrow.hour.toString().padLeft(2, '0')}:${tomorrow.minute.toString().padLeft(2, '0')}';
  }

  void onConfirmEnd() async {
    isConfirming.value = true;
    await Future.delayed(const Duration(milliseconds: 1200));
    isConfirming.value = false;
    UIHelper().showSnackBar(
      'MINIZON',
      'Trajet terminé ! Les passagers ont été notifiés.',
      0,
    );
    Get.offAllNamed(AppRoutes.dashboardDriver);
  }

  void onReportIssue() {
    String? selectedCategory;
    final descCtrl = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          const categories = [
            ('Passager agressif', Icons.person_off_rounded, Color(0xFFEF4444)),
            ('Accident de route', Icons.car_crash_rounded, Color(0xFFF59E0B)),
            ('Passager n\'était pas là', Icons.location_off_rounded, Color(0xFF6366F1)),
            ('Paiement refusé', Icons.payment_rounded, Color(0xFFF97316)),
            ('Autre incident', Icons.more_horiz_rounded, Color(0xFF9CA3AF)),
          ];
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
                    child: Container(width: 40, height: 4,
                        decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999))),
                  ),
                  const SizedBox(height: 16),
                  const Text('Signaler un incident', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Votre signalement est traité en priorité.', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: categories.map((c) {
                      final isSelected = selectedCategory == c.$1;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = c.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? c.$3.withOpacity(0.12) : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? c.$3 : AppColors.border, width: isSelected ? 2 : 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(c.$2, size: 14, color: isSelected ? c.$3 : AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(c.$1, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400, color: isSelected ? c.$3 : AppColors.textPrimary)),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border, width: 1.5)),
                    child: TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(hintText: 'Décrivez l\'incident (optionnel)…', hintStyle: TextStyle(color: AppColors.textGhost), border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: selectedCategory == null
                        ? () => UIHelper().showSnackBar('MINIZON', 'Sélectionnez un type d\'incident.', 2)
                        : () {
                            Get.back();
                            descCtrl.dispose();
                            UIHelper().showSnackBar('MINIZON', 'Incident signalé. Notre équipe vous contacte sous 30 min.', 0);
                          },
                    child: Container(
                      width: double.infinity, height: 50,
                      decoration: BoxDecoration(
                        color: selectedCategory == null ? AppColors.textGhost : const Color(0xFFF59E0B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(child: Text('Envoyer le signalement', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15))),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/end_trip/end_trip_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/end_trip_summary_model.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trip_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class EndTripController extends GetxController {
  EndTripService get _service => Get.find<EndTripService>();

  final RxBool isLoading   = false.obs;
  final RxBool hasError    = false.obs;
  final RxBool isConfirming = false.obs;

  final Rxn<EndTripSummaryModel> _data = Rxn<EndTripSummaryModel>();
  EndTripSummaryModel? get data => _data.value;

  late final String _uuid;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final trip = args?['trip'] as TripModel?;
    _uuid = trip?.id ?? (args?['uuid'] as String? ?? '');
    _fetchEndSummary();
  }

  @override
  Future<void> refresh() => _fetchEndSummary();

  Future<void> _fetchEndSummary() async {
    if (_uuid.isEmpty) {
      hasError.value = true;
      return;
    }
    isLoading.value = true;
    hasError.value  = false;

    final result = await _service.fetchEndSummary(_uuid);
    isLoading.value = false;

    if (result.isSuccess) {
      _data.value = result.data;
    } else {
      hasError.value = true;
      if (result.error != AppError.socket) {
        UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
      }
    }
  }

  Future<void> onConfirmEnd() async {
    isConfirming.value = true;
    final result = await _service.endTrip(_uuid);
    isConfirming.value = false;

    if (result.isSuccess) {
      UIHelper().showSnackBar('MINIZON', 'Trajet terminé ! Les passagers ont été notifiés.', 0);
      Get.offAllNamed(AppRoutes.dashboardDriver);
    } else {
      UIHelper().showSnackBar('MINIZON', result.error!.message, 2);
    }
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
            ("Passager n'était pas là", Icons.location_off_rounded, Color(0xFF6366F1)),
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
                  const Text('Signaler un incident',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Votre signalement est traité en priorité.',
                      style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((c) {
                      final isSelected = selectedCategory == c.$1;
                      return GestureDetector(
                        onTap: () => setState(() => selectedCategory = c.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? c.$3.withOpacity(0.12) : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? c.$3 : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(c.$2, size: 14, color: isSelected ? c.$3 : AppColors.textMuted),
                            const SizedBox(width: 6),
                            Text(c.$1,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  color: isSelected ? c.$3 : AppColors.textPrimary,
                                )),
                          ]),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: "Décrivez l'incident (optionnel)…",
                        hintStyle: TextStyle(color: AppColors.textGhost),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: selectedCategory == null
                        ? () => UIHelper().showSnackBar(
                            'MINIZON', "Sélectionnez un type d'incident.", 2)
                        : () {
                            Get.back();
                            descCtrl.dispose();
                            UIHelper().showSnackBar('MINIZON',
                                'Incident signalé. Notre équipe vous contacte sous 30 min.', 0);
                          },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: selectedCategory == null
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
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

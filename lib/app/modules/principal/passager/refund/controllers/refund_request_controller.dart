import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

class RefundRequestController extends GetxController {
  final selectedReason = Rxn<String>();
  final isSubmitting = false.obs;
  final submitted = false.obs;
  final noteController = TextEditingController();

  final refundAmount = 0.obs;
  final tripRef = ''.obs;
  final tripRoute = ''.obs;
  final tripDate = ''.obs;

  final reasons = const [
    'Conducteur a annulé le trajet',
    'Trajet non effectué',
    'Problème technique / panne',
    'Mauvaise conduite du conducteur',
    'Itinéraire non respecté',
    'Autre raison',
  ];

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map) {
        refundAmount.value = (savedArgs['amount'] as int?) ?? 5500;
        tripRef.value = (savedArgs['ref'] as String?) ?? 'REF-2024-12-001';
        tripRoute.value = (savedArgs['route'] as String?) ?? 'Cotonou → Porto-Novo';
        tripDate.value = (savedArgs['date'] as String?) ?? '15 Déc 2024';
      } else {
        refundAmount.value = 5500;
        tripRef.value = 'REF-2024-12-001';
        tripRoute.value = 'Cotonou → Porto-Novo';
        tripDate.value = '15 Déc 2024';
      }
    });
  }

  String get formattedAmount {
    final str = refundAmount.value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(' ');
      buffer.write(str[i]);
    }
    return '$buffer FCFA';
  }

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  void submitRequest() {
    if (selectedReason.value == null) {
      Get.snackbar(
        'Motif requis',
        'Veuillez sélectionner un motif de remboursement.',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }
    isSubmitting.value = true;
    Future.delayed(const Duration(milliseconds: 1800), () {
      isSubmitting.value = false;
      submitted.value = true;
    });
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class RefundController extends GetxController {
  static const int maxProofImages = 3;

  final selectedReason = Rxn<String>();
  final isSubmitting = false.obs;
  final isSubmitted = false.obs;
  final descriptionController = TextEditingController();
  final proofImages = <XFile>[].obs;

  final refundAmount = 0.obs;
  final tripOrigin = ''.obs;
  final tripDestination = ''.obs;
  final tripDate = ''.obs;
  final transactionRef = ''.obs;

  final _picker = ImagePicker();

  final reasons = const [
    'Conducteur absent au rendez-vous',
    'Trajet annulé par le conducteur',
    'Trajet non conforme à la description',
    'Problème de sécurité',
    'Double paiement accidentel',
    'Autre raison',
  ];

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final args = savedArgs as Map<String, dynamic>?;
      if (args != null) {
        refundAmount.value = args['amount'] as int? ?? 0;
        tripOrigin.value = args['origin'] as String? ?? 'Cotonou';
        tripDestination.value = args['destination'] as String? ?? 'Porto-Novo';
        tripDate.value = args['date'] as String? ?? '24 juin 2026';
        transactionRef.value = args['ref'] as String? ?? 'TXN-000000';
      } else {
        refundAmount.value = 3500;
        tripOrigin.value = 'Cotonou';
        tripDestination.value = 'Parakou';
        tripDate.value = '24 juin 2026';
        transactionRef.value = 'TXN-202606241';
      }
    });
  }

  String get formattedAmount {
    final n = refundAmount.value;
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      return remainder == 0
          ? '$thousands 000 FCFA'
          : '$thousands ${remainder.toString().padLeft(3, '0')} FCFA';
    }
    return '$n FCFA';
  }

  void selectReason(String reason) {
    selectedReason.value = reason;
  }

  Future<void> pickProofImages() async {
    if (proofImages.length >= maxProofImages) return;
    final remaining = maxProofImages - proofImages.length;
    final picked = await _picker.pickMultiImage(limit: remaining);
    if (picked.isNotEmpty) {
      proofImages.addAll(picked);
    }
  }

  Future<void> pickFromCamera() async {
    if (proofImages.length >= maxProofImages) return;
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      proofImages.add(picked);
    }
  }

  void removeProofImage(int index) {
    proofImages.removeAt(index);
  }

  void submitRefund() {
    if (selectedReason.value == null) {
      Get.snackbar(
        'Raison requise',
        'Veuillez sélectionner une raison pour le remboursement.',
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    isSubmitting.value = true;
    Future.delayed(const Duration(seconds: 2), () {
      isSubmitting.value = false;
      isSubmitted.value = true;
    });
  }

  void viewRefundHistory() {
    Get.snackbar(
      'Bientôt disponible',
      'L\'historique des remboursements sera disponible prochainement.',
      backgroundColor: const Color(0xFF374151),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  void goToReservations() {
    Get.until((r) => r.settings.name == '/passenger-reservations');
  }

  void goHome() {
    Get.until((r) => r.settings.name == '/passenger-home');
  }

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}

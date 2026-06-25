import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class RefundController extends GetxController {
  final selectedReason = Rxn<String>();
  final isSubmitting = false.obs;
  final isSubmitted = false.obs;
  final descriptionController = TextEditingController();

  final refundAmount = 0.obs;
  final tripOrigin = ''.obs;
  final tripDestination = ''.obs;
  final tripDate = ''.obs;
  final transactionRef = ''.obs;

  final RxList<XFile> proofImages = RxList([]);
  final _picker = ImagePicker();

  static const int maxProofImages = 5;

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
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
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
    if (proofImages.length >= maxProofImages) {
      Get.snackbar(
        'Limite atteinte',
        'Vous pouvez joindre au maximum $maxProofImages photos.',
        backgroundColor: const Color(0xFFF59E0B),
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    final remaining = maxProofImages - proofImages.length;
    final images = await _picker.pickMultiImage(limit: remaining);
    if (images.isNotEmpty) {
      proofImages.addAll(images);
    }
  }

  Future<void> pickFromCamera() async {
    if (proofImages.length >= maxProofImages) return;
    final image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) proofImages.add(image);
  }

  void removeProofImage(int index) {
    if (index >= 0 && index < proofImages.length) {
      proofImages.removeAt(index);
    }
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

  void goToReservations() => BottonNavController.goToTab(2);

  void goHome() => BottonNavController.goToTab(0);

  void viewRefundHistory() => Get.toNamed(AppRoutes.passengerRefundHistory);

  @override
  void onClose() {
    descriptionController.dispose();
    super.onClose();
  }
}

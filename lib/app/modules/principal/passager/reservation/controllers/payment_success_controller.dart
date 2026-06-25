import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/principal/passager/messager/controllers/messager_controller.dart';
import '../../search/controllers/search_controller.dart';

class PaymentSuccessController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();
  final transactionRef = ''.obs;
  final totalAmount = 0.obs;
  final reservedSeats = 1.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final r = args['ride'];
      if (r is SearchRide) ride.value = r;
      final ref = args['ref'];
      if (ref is String) transactionRef.value = ref;
      final amount = args['amount'];
      if (amount is int) totalAmount.value = amount;
      final seats = args['seats'];
      if (seats is int) reservedSeats.value = seats;
    }
    if (transactionRef.value.isEmpty) {
      transactionRef.value = '#TXN-${(DateTime.now().millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';
    }
  }

  String get formattedAmount {
    final formatted = totalAmount.value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ' ',
    );
    return '$formatted FCFA';
  }

  void callDriver() {
    final driverName = ride.value?.driverName ?? 'votre conducteur';
    Get.snackbar(
      'Appeler $driverName',
      'Numéro : +229 97 12 34 56',
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      icon: const Icon(Icons.phone_rounded, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 4),
    );
  }

  void messageDriver() {
    final driverName = ride.value?.driverName ?? 'Votre conducteur';
    final origin = ride.value?.origin ?? '';
    final destination = ride.value?.destination ?? '';
    MessagerController.openDriverChat(
      driverName: driverName,
      tripRoute: origin.isNotEmpty ? '$origin → $destination' : '',
    );
  }

  void goToReservations() => BottonNavController.goToTab(2);

  void goHome() => BottonNavController.goToTab(0);
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../search/controllers/search_controller.dart';

class LiveTrackingController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();

  // Simulation: driver progress 0.0 (depart) → 1.0 (arrivee)
  final driverProgress = 0.05.obs;
  final etaMinutes = 45.obs;
  final distanceRemainingKm = 87.obs;
  final driverSpeedKmh = 95.obs;
  final isTracking = true.obs;
  final tripEnded = false.obs;

  final List<String> quickMessages = const [
    'Je suis au point de départ',
    'J\'ai un peu de retard',
    'Où êtes-vous exactement ?',
    'Je vous vois !',
  ];

  Timer? _simulationTimer;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final r = args['ride'];
      if (r is SearchRide) ride.value = r;
    }
    _startSimulation();
  }

  void _startSimulation() {
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1600), (_) {
      if (driverProgress.value < 1.0) {
        driverProgress.value = (driverProgress.value + 0.0025).clamp(0.0, 1.0);
        final remaining = 1.0 - driverProgress.value;
        etaMinutes.value = (remaining * 45).round().clamp(0, 45);
        distanceRemainingKm.value = (remaining * 87).round().clamp(0, 87);
        driverSpeedKmh.value = 90 + (driverProgress.value * 10).round();
      } else {
        _simulationTimer?.cancel();
        isTracking.value = false;
        tripEnded.value = true;
        Future.delayed(const Duration(seconds: 2), _onTripEnded);
      }
    });
  }

  void _onTripEnded() {
    Get.toNamed(
      AppRoutes.passengerTripConfirmation,
      arguments: {'ride': ride.value},
    );
  }

  void callDriver() {
    Get.snackbar(
      'Appel conducteur',
      'Connexion en cours…',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  void triggerSOS() {
    Get.dialog(
      _SOSDialog(),
    );
  }

  void sendQuickMessage(String message) {
    Get.snackbar(
      'Message envoyé',
      message,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  @override
  void onClose() {
    _simulationTimer?.cancel();
    super.onClose();
  }
}

// Inline dialog — avoids a separate file for a simple confirmation.
class _SOSDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('⚠️ Alerte SOS'),
      content: const Text(
        'Voulez-vous envoyer une alerte d\'urgence à vos contacts et appeler le 117 (Police) ?',
      ),
      actions: [
        TextButton(onPressed: Get.back, child: const Text('Annuler')),
        TextButton(
          onPressed: () {
            Get.back();
            Get.snackbar('SOS envoyé', 'Alerte envoyée à vos contacts d\'urgence.',
                duration: const Duration(seconds: 3), snackPosition: SnackPosition.TOP);
          },
          child: const Text('CONFIRMER', style: TextStyle(color: Color(0xFFEF4444))),
        ),
      ],
    );
  }
}

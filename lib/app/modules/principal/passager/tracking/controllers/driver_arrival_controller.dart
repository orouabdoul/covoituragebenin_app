import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../../search/controllers/search_controller.dart';

enum DriverArrivalStatus { onTheWay, arriving, arrived }

class DriverArrivalController extends GetxController {
  final Rxn<SearchRide> ride = Rxn<SearchRide>();

  final etaMinutes = 8.obs;
  final driverProgress = 0.65.obs;
  final status = DriverArrivalStatus.onTheWay.obs;

  final List<String> quickMessages = const [
    'Je suis au point de rendez-vous',
    'J\'arrive dans 2 minutes',
    'Je suis en chemin',
    'Je vous vois !',
  ];

  Timer? _etaTimer;

  @override
  void onInit() {
    super.onInit();
    final dynamic savedArgs = Get.arguments;
    _simulateArrival();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (savedArgs is Map<String, dynamic>) {
        final r = savedArgs['ride'];
        if (r is SearchRide) ride.value = r;
      }
    });
  }

  void _simulateArrival() {
    _etaTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (etaMinutes.value > 0) {
        etaMinutes.value--;
        driverProgress.value = (driverProgress.value + 0.05).clamp(0.0, 1.0);
        if (etaMinutes.value <= 2 && status.value == DriverArrivalStatus.onTheWay) {
          status.value = DriverArrivalStatus.arriving;
        }
        if (etaMinutes.value == 0) {
          status.value = DriverArrivalStatus.arrived;
          _etaTimer?.cancel();
        }
      }
    });
  }

  String get statusLabel {
    switch (status.value) {
      case DriverArrivalStatus.onTheWay:
        return 'En route vers vous';
      case DriverArrivalStatus.arriving:
        return 'Arrive dans moins de 2 min';
      case DriverArrivalStatus.arrived:
        return 'Arrivé au point de rendez-vous';
    }
  }

  void callDriver() {
    Get.snackbar(
      'Appel conducteur',
      'Connexion en cours…',
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  void sendMessage(String msg) {
    Get.snackbar('Message envoyé', msg,
        duration: const Duration(seconds: 2), snackPosition: SnackPosition.TOP);
  }

  void goToLiveTracking() {
    _etaTimer?.cancel();
    Get.toNamed(
      AppRoutes.passengerLiveTracking,
      arguments: {'ride': ride.value},
    );
  }

  @override
  void onClose() {
    _etaTimer?.cancel();
    super.onClose();
  }
}

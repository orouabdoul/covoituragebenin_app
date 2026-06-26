import 'package:get/get.dart';

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
    UIHelper().showSnackBar('MINIZON', 'Signalement disponible bientôt.', 1);
  }
}

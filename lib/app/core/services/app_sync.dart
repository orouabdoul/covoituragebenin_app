import 'package:get/get.dart';

/// Service singleton de synchronisation inter-contrôleurs.
///
/// Les contrôleurs fenix:true ne rappellent pas onInit() lors des retours
/// de navigation. Ce service expose des compteurs réactifs auxquels ils
/// s'abonnent via ever() pour déclencher un re-fetch après chaque action.
///
/// Usage — déclencheur (après une action POST/PUT/DELETE) :
///   AppSync.i.refreshPassenger();
///
/// Usage — consommateur (dans onInit() d'un contrôleur fenix:true) :
///   ever(AppSync.i.passengerData, (_) => _fetch());
class AppSync extends GetxService {
  static AppSync get i => Get.find<AppSync>();

  /// Données passager : accueil + liste des réservations.
  final RxInt passengerData = 0.obs;

  /// Tableau de bord conducteur.
  final RxInt driverDashboard = 0.obs;

  /// Liste des trajets conducteur.
  final RxInt driverTrips = 0.obs;

  // ── Helpers ────────────────────────────────────────────────────────────────

  void refreshPassenger() => passengerData.value++;

  void refreshDriverDashboard() => driverDashboard.value++;

  void refreshDriverTrips() => driverTrips.value++;

  void refreshDriver() {
    driverDashboard.value++;
    driverTrips.value++;
  }

  void refreshAll() {
    passengerData.value++;
    driverDashboard.value++;
    driverTrips.value++;
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/services/app_sync.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

/// Routes BottomNav racines : rafraîchit l'onglet actif quand on y revient.
const _kDashboardRoutes = {
  AppRoutes.dashboardPassenger,
  AppRoutes.dashboardDriver,
};

/// Sous-pages passager persistantes sur le stack : rafraîchit les données passager.
const _kPassengerSubRoutes = {
  AppRoutes.passengerReservations,
  AppRoutes.passengerReservationDetail,
  AppRoutes.passengerReservationConfirmation,
  AppRoutes.passengerWaitingApproval,
  AppRoutes.passengerPaymentSuccess,
  AppRoutes.passengerLiveTracking,
  AppRoutes.passengerDriverArrival,
  AppRoutes.passengerTripConfirmation,
  AppRoutes.passengerTripHistory,
  AppRoutes.passengerMyReviews,
  AppRoutes.passengerNotifications,
  AppRoutes.passengerRefundHistory,
  AppRoutes.passengerRefundRequest,
};

/// Sous-pages conducteur persistantes sur le stack : rafraîchit les données conducteur.
const _kDriverSubRoutes = {
  AppRoutes.driverTrips,
  AppRoutes.driverReservations,
  AppRoutes.driverTripDetail,
  AppRoutes.driverActiveTrip,
  AppRoutes.driverRunningTrip,
  AppRoutes.driverEndTrip,
  AppRoutes.driverNotifications,
  AppRoutes.driverPaymentHistory,
  AppRoutes.driverStatistics,
  AppRoutes.driverReviews,
  AppRoutes.driverTripReviews,
  AppRoutes.driverWithdraw,
};

/// [NavigatorObserver] global : déclenche AppSync chaque fois que l'utilisateur
/// revient en arrière (pop) vers n'importe quelle page de données.
///
/// Enregistré dans `GetMaterialApp(navigatorObservers: [AppSyncRouteObserver()])`.
class AppSyncRouteObserver extends NavigatorObserver {
  DateTime? _lastSync;

  /// Délai minimal pour éviter des syncs en cascade (ex : double pop rapide).
  static const _kMinInterval = Duration(milliseconds: 600);

  // ── Callbacks NavigatorObserver ─────────────────────────────────────────

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _handleReturn(previousRoute?.settings.name);
  }

  // ── Logique principale ──────────────────────────────────────────────────

  void _handleReturn(String? routeName) {
    if (routeName == null || routeName.isEmpty) return;

    if (_kDashboardRoutes.contains(routeName)) {
      _syncCurrentTab();
    } else if (_kPassengerSubRoutes.contains(routeName)) {
      _syncPassenger();
    } else if (_kDriverSubRoutes.contains(routeName)) {
      _syncDriver();
    }
  }

  // ── Actions sync ────────────────────────────────────────────────────────

  void _syncCurrentTab() {
    if (!_canSync()) return;
    if (!Get.isRegistered<BottonNavController>()) return;
    try {
      Get.find<BottonNavController>().refreshCurrentTab();
    } catch (_) {}
  }

  void _syncPassenger() {
    if (!_canSync()) return;
    try { AppSync.i.refreshPassenger(); } catch (_) {}
  }

  void _syncDriver() {
    if (!_canSync()) return;
    try { AppSync.i.refreshDriver(); } catch (_) {}
  }

  // ── Anti-cascade ────────────────────────────────────────────────────────

  bool _canSync() {
    final now = DateTime.now();
    if (_lastSync != null && now.difference(_lastSync!) < _kMinInterval) {
      return false;
    }
    _lastSync = now;
    return true;
  }
}

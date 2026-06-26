import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

// ── Quick request (with live countdown) ────────────────────────────────────

class QuickRequest {
  QuickRequest({
    required this.id,
    required this.passengerName,
    required this.passengerInitial,
    required this.rating,
    required this.routeLabel,
    required this.amount,
    required this.seats,
    required this.expiresInSeconds,
  }) : remainingSeconds = expiresInSeconds.obs;

  final String id;
  final String passengerName;
  final String passengerInitial;
  final double rating;
  final String routeLabel;
  final double amount;
  final int seats;
  final int expiresInSeconds;
  final RxInt remainingSeconds;
  Timer? _timer;

  String get countdownLabel {
    final s = remainingSeconds.value;
    if (s <= 0) return 'Expirée';
    final m = s ~/ 60;
    final sec = s % 60;
    return m == 0 ? '${sec}s' : '${m}m ${sec.toString().padLeft(2, '0')}s';
  }

  bool get isUrgent => remainingSeconds.value <= 120;

  void startTimer(VoidCallback onExpire) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        _timer?.cancel();
        onExpire();
      }
    });
  }

  void cancelTimer() => _timer?.cancel();
}

// ── Legacy models (kept for view compatibility) ─────────────────────────────

class DriverSummary {
  const DriverSummary({
    required this.todayLabel,
    required this.todayValue,
    required this.weekLabel,
    required this.weekValue,
    required this.monthLabel,
    required this.monthValue,
    required this.pendingLabel,
    required this.pendingValue,
    required this.commissionLabel,
    required this.commissionValue,
  });

  final String todayLabel;
  final String todayValue;
  final String weekLabel;
  final String weekValue;
  final String monthLabel;
  final String monthValue;
  final String pendingLabel;
  final String pendingValue;
  final String commissionLabel;
  final String commissionValue;
}

class DriverMetric {
  const DriverMetric({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
    this.progress,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final double? progress;
}

class DriverTripCard {
  const DriverTripCard({
    required this.statusLabel,
    required this.time,
    required this.departureLabel,
    required this.departure,
    required this.destinationLabel,
    required this.destination,
    required this.passengersLabel,
    required this.avatarUrls,
  });

  final String statusLabel;
  final String time;
  final String departureLabel;
  final String departure;
  final String destinationLabel;
  final String destination;
  final String passengersLabel;
  final List<String> avatarUrls;
}

/// Alias pour compatibilité avec home_view.dart qui référence DriverTrip.
typedef DriverTrip = DriverTripCard;

// ignore: avoid_implementing_value_types
class DriverRequest {
  const DriverRequest({
    required this.name,
    required this.rating,
    required this.route,
    required this.timeAgo,
    required this.seats,
    required this.status,
    required this.statusColor,
    required this.statusBackground,
    required this.avatarUrl,
  });

  final String name;
  final String rating;
  final String route;
  final String timeAgo;
  final String seats;
  final String status;
  final Color statusColor;
  final Color statusBackground;
  final String avatarUrl;
}

class DriverAction {
  const DriverAction({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    this.route,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String? route;
}

class DriverWallet {
  const DriverWallet({
    required this.balance,
    required this.blockedAmount,
    required this.methods,
  });

  final String balance;
  final String blockedAmount;
  final List<String> methods;
}

class DriverLevel {
  const DriverLevel({
    required this.currentLevel,
    required this.progressLabel,
    required this.progressValue,
    required this.badges,
  });

  final String currentLevel;
  final String progressLabel;
  final String progressValue;
  final List<DriverBadge> badges;
}

class DriverBadge {
  const DriverBadge({
    required this.label,
    required this.color,
    required this.icon,
    required this.iconColor,
  });

  final String label;
  final Color color;
  final IconData icon;
  final Color iconColor;
}

class DriverNotificationItem {
  const DriverNotificationItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.iconBackground,
  });

  final String title;
  final String subtitle;
  final String time;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final Color iconBackground;
}

class ActivityItem {
  const ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.time,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String time;
}

// ── Controller ──────────────────────────────────────────────────────────────

class DriverHomeController extends GetxController {
  // ── Reactive state ───────────────────────────────────────────────────────
  final RxBool isOnline = true.obs;
  final RxBool isLoadingDashboard = false.obs;
  final RxInt selectedWalletMethod = 0.obs;
  final RxInt pendingRequestsCount = 2.obs;

  // ── Quick requests with countdown ────────────────────────────────────────
  final RxList<QuickRequest> quickRequests = <QuickRequest>[
    QuickRequest(
      id: 'q1',
      passengerName: 'Aminata Koné',
      passengerInitial: 'A',
      rating: 4.9,
      routeLabel: 'Cotonou → Porto-Novo',
      amount: 5000,
      seats: 2,
      expiresInSeconds: 272,
    ),
    QuickRequest(
      id: 'q2',
      passengerName: 'Kwame Asante',
      passengerInitial: 'K',
      rating: 4.7,
      routeLabel: 'Cotonou → Porto-Novo',
      amount: 2500,
      seats: 1,
      expiresInSeconds: 78,
    ),
  ].obs;

  // ── Static data (legacy, kept for view) ──────────────────────────────────
  final DriverSummary summary = const DriverSummary(
    todayLabel: 'Revenus d\'aujourd\'hui',
    todayValue: '48 500 FCFA',
    weekLabel: 'Semaine',
    weekValue: '285K',
    monthLabel: 'Mois',
    monthValue: '1.2M',
    pendingLabel: 'En attente',
    pendingValue: '12K',
    commissionLabel: 'Commission MINIZON',
    commissionValue: '4 850 FCFA (10%)',
  );

  final List<DriverMetric> metrics = const [
    DriverMetric(
      title: 'Trajets effectués',
      value: '12',
      icon: Icons.route_rounded,
      color: Color(0x1900A86B),
      iconColor: Color(0xFF00A86B),
    ),
    DriverMetric(
      title: 'Passagers transportés',
      value: '34',
      icon: Icons.groups_rounded,
      color: Color(0x19F4B400),
      iconColor: Color(0xFFF4B400),
    ),
    DriverMetric(
      title: 'Note moyenne',
      value: '4.9',
      icon: Icons.star_rounded,
      color: Color(0x1922C55E),
      iconColor: Color(0xFF22C55E),
      progress: 0.98,
    ),
    DriverMetric(
      title: 'Taux acceptation',
      value: '96%',
      icon: Icons.verified_rounded,
      color: Color(0x193B82F6),
      iconColor: Color(0xFF3B82F6),
      progress: 0.96,
    ),
  ];

  // kept as DriverTripCard to not clash with models/trip_model.dart TripModel
  final DriverTripCard nextTrip = const DriverTripCard(
    statusLabel: 'Confirmé',
    time: '14:30',
    departureLabel: 'Départ',
    departure: 'Place de l\'Étoile Rouge',
    destinationLabel: 'Destination',
    destination: 'Aéroport de Cotonou',
    passengersLabel: '2 passagers confirmés',
    avatarUrls: [],
  );

  final List<DriverRequest> recentRequests = const [
    DriverRequest(
      name: 'Mariama Diallo',
      rating: '4.8 · 23 trajets',
      route: 'Cotonou → Porto-Novo',
      timeAgo: 'Il y a 5 min',
      seats: '2 places demandées',
      status: 'Payé',
      statusColor: Color(0xFF16A34A),
      statusBackground: Color(0x1922C55E),
      avatarUrl: '',
    ),
    DriverRequest(
      name: 'Koffi Mensah',
      rating: '5.0 · 45 trajets',
      route: 'Abomey-Calavi → Cotonou',
      timeAgo: 'Il y a 12 min',
      seats: '1 place demandée',
      status: 'En attente',
      statusColor: Color(0xFFF4B400),
      statusBackground: Color(0x19F4B400),
      avatarUrl: '',
    ),
  ];

  final List<DriverAction> actions = const [
    DriverAction(
      label: 'Publier',
      icon: Icons.add_road_rounded,
      backgroundColor: Color(0x1900A86B),
      iconColor: Color(0xFF00A86B),
      route: 'driverAddTrip',
    ),
    DriverAction(
      label: 'Réservations',
      icon: Icons.event_note_rounded,
      backgroundColor: Color(0x19F4B400),
      iconColor: Color(0xFFF4B400),
      route: 'driverReservations',
    ),
    DriverAction(
      label: 'Retirer',
      icon: Icons.account_balance_wallet_outlined,
      backgroundColor: Color(0x1900A86B),
      iconColor: Color(0xFF00A86B),
      route: 'driverWithdraw',
    ),
    DriverAction(
      label: 'Mes trajets',
      icon: Icons.route_rounded,
      backgroundColor: Color(0x193B82F6),
      iconColor: Color(0xFF3B82F6),
      route: 'driverTrips',
    ),
    DriverAction(
      label: 'Support',
      icon: Icons.support_agent_rounded,
      backgroundColor: Color(0x19A855F7),
      iconColor: Color(0xFFA855F7),
      route: 'driverSupportCenter',
    ),
    DriverAction(
      label: 'Statistiques',
      icon: Icons.bar_chart_rounded,
      backgroundColor: Color(0x196366F1),
      iconColor: Color(0xFF6366F1),
      route: 'driverStatistics',
    ),
  ];

  final DriverWallet wallet = const DriverWallet(
    balance: '245 600 F',
    blockedAmount: '12 500 FCFA',
    methods: ['MTN Money', 'Moov Money'],
  );

  final DriverLevel level = const DriverLevel(
    currentLevel: 'Conducteur Premium',
    progressLabel: 'Progrès vers Expert',
    progressValue: '75%',
    badges: [
      DriverBadge(
        label: 'Fiable',
        color: Color(0x3300A86B),
        icon: Icons.verified_rounded,
        iconColor: Color(0xFF00A86B),
      ),
      DriverBadge(
        label: 'Top 10%',
        color: Color(0x33F4B400),
        icon: Icons.workspace_premium_rounded,
        iconColor: Color(0xFFF4B400),
      ),
      DriverBadge(
        label: 'Rapide',
        color: Color(0x333B82F6),
        icon: Icons.speed_rounded,
        iconColor: Color(0xFF3B82F6),
      ),
    ],
  );

  final List<DriverNotificationItem> notifications = const [
    DriverNotificationItem(
      title: 'Paiement reçu',
      subtitle: '8,500 FCFA crédités sur votre compte',
      time: 'Il y a 5 min',
      backgroundColor: Color(0x0C00A86B),
      borderColor: Color(0xFF00A86B),
      icon: Icons.payments_rounded,
      iconBackground: Color(0xFF00A86B),
    ),
    DriverNotificationItem(
      title: 'Nouvelle réservation',
      subtitle: 'Marie souhaite réserver 2 places',
      time: 'Il y a 12 min',
      backgroundColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFE5E7EB),
      icon: Icons.event_available_rounded,
      iconBackground: Color(0xFF3B82F6),
    ),
    DriverNotificationItem(
      title: 'Promotion spéciale',
      subtitle: 'Gagnez 5000 F de bonus ce weekend',
      time: 'Il y a 1h',
      backgroundColor: Color(0xFFFFFFFF),
      borderColor: Color(0xFFE5E7EB),
      icon: Icons.local_offer_rounded,
      iconBackground: Color(0xFFF4B400),
    ),
  ];

  final List<ActivityItem> recentActivity = const [
    ActivityItem(
      icon: Icons.payments_rounded,
      iconColor: Color(0xFF16A34A),
      iconBg: Color(0xFFDCFCE7),
      title: 'Paiement reçu',
      subtitle: '8 500 FCFA — Aminata Koné',
      time: 'Il y a 5 min',
    ),
    ActivityItem(
      icon: Icons.star_rounded,
      iconColor: Color(0xFFF4B400),
      iconBg: Color(0xFFFFFBEB),
      title: 'Nouvel avis reçu',
      subtitle: '⭐⭐⭐⭐⭐ — "Très ponctuel et agréable"',
      time: 'Il y a 38 min',
    ),
    ActivityItem(
      icon: Icons.check_circle_rounded,
      iconColor: Color(0xFF2563EB),
      iconBg: Color(0xFFDBEAFE),
      title: 'Trajet terminé',
      subtitle: 'Cotonou → Porto-Novo · 4 500 FCFA nets',
      time: 'Hier 17:42',
    ),
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _startQuickRequestTimers();
  }

  void _startQuickRequestTimers() {
    for (final r in quickRequests) {
      r.startTimer(() => _onRequestExpired(r));
    }
  }

  void _onRequestExpired(QuickRequest r) {
    quickRequests.remove(r);
    pendingRequestsCount.value = quickRequests.length;
    UIHelper().showSnackBar(
        'MINIZON', 'Demande de ${r.passengerName} expirée.', 1);
  }

  @override
  void onClose() {
    for (final r in quickRequests) {
      r.cancelTimer();
    }
    super.onClose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void toggleAvailability() {
    isOnline.value = !isOnline.value;
    UIHelper().showSnackBar(
      'MINIZON',
      isOnline.value ? '🟢 Vous êtes maintenant en ligne.' : '⚪ Hors ligne.',
      isOnline.value ? 0 : 1,
    );
  }

  void onQuickAccept(QuickRequest r) {
    r.cancelTimer();
    quickRequests.remove(r);
    pendingRequestsCount.value = quickRequests.length;
    UIHelper().showSnackBar(
        'MINIZON', '✅ ${r.passengerName} accepté(e) !', 0);
  }

  void onQuickReject(QuickRequest r) {
    r.cancelTimer();
    quickRequests.remove(r);
    pendingRequestsCount.value = quickRequests.length;
    UIHelper().showSnackBar(
        'MINIZON', 'Demande de ${r.passengerName} refusée.', 2);
  }

  void onSeeAllRequests() => Get.toNamed(AppRoutes.driverReservations);
  void onPublishTrip() => Get.toNamed(AppRoutes.driverAddTrip);

  void selectWalletMethod(int index) => selectedWalletMethod.value = index;

  void showInfo(String message) =>
      UIHelper().showSnackBar('MINIZON', message, 1);

  void onSeeDetails() => Get.toNamed(AppRoutes.driverTripDetail);
  void onContact() =>
      UIHelper().showSnackBar('MINIZON', 'Appel passager bientôt disponible.', 1);

  void onRequestAction(String action, DriverRequest request) =>
      showInfo('$action : ${request.name}');

  void onQuickAction(String action) {
    final routeMap = {
      'Publier': AppRoutes.driverAddTrip,
      'Réservations': AppRoutes.driverReservations,
      'Retirer': AppRoutes.driverWithdraw,
      'Mes trajets': AppRoutes.driverTrips,
      'Support': AppRoutes.driverSupportCenter,
      'Statistiques': AppRoutes.driverStatistics,
    };
    final route = routeMap[action];
    if (route != null) {
      Get.toNamed(route);
    } else {
      showInfo(action);
    }
  }

  void onNotifications() => Get.toNamed(AppRoutes.driverNotifications);
}

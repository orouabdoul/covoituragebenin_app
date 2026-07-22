import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/booking/booking_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/home/dashboard_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/notifications/notifications_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/extensions.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/dashboard_model.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/notification_driver_model.dart';
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
  final RxBool isProcessing = false.obs;
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

// ── Models ──────────────────────────────────────────────────────────────────

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
    this.uuid = '',
    required this.statusLabel,
    required this.time,
    required this.departureLabel,
    required this.departure,
    required this.destinationLabel,
    required this.destination,
    required this.passengersLabel,
    required this.avatarUrls,
    this.tripProgress = 0.0,
    this.completedStops = 0,
    this.totalStops = 0,
  });

  final String uuid;
  final String statusLabel;
  final String time;
  final String departureLabel;
  final String departure;
  final String destinationLabel;
  final String destination;
  final String passengersLabel;
  final List<String> avatarUrls;
  final double tripProgress;
  final int completedStops;
  final int totalStops;

  Color get statusColor => switch (statusLabel) {
    'En attente' => const Color(0xFFF4B400),
    'Confirmé'   => const Color(0xFF00A86B),
    'En cours'   => const Color(0xFF3B82F6),
    'Terminé'    => const Color(0xFF6B7280),
    'Annulé'     => const Color(0xFFE53935),
    _            => const Color(0xFF00A86B),
  };

  Color get statusBg => statusColor.withValues(alpha: 0.12);
}

/// Alias pour compatibilité avec home_view.dart qui référence DriverTrip.
typedef DriverTrip = DriverTripCard;

// ignore: avoid_implementing_value_types
class DriverRequest {
  const DriverRequest({
    required this.id,
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

  final String id;
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
    required this.progressFraction,
    required this.badges,
  });

  final String currentLevel;
  final String progressLabel;
  final String progressValue;
  final double progressFraction;
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


// ── Controller ──────────────────────────────────────────────────────────────

class DriverHomeController extends GetxController {
  DashboardService get _service => Get.find<DashboardService>();
  NotificationsService get _notifService => Get.find<NotificationsService>();

  // ── État réactif ─────────────────────────────────────────────────────────
  final RxBool isOnline = true.obs;
  final RxBool isLoadingDashboard = false.obs;
  final RxBool hasLoadError = false.obs;
  final RxInt selectedWalletMethod = 0.obs;
  final RxInt pendingRequestsCount = 0.obs;
  final RxInt dashboardVersion = 0.obs;
  final RxString availabilityMode = 'normal'.obs;

  // ── Demandes rapides avec compte à rebours ───────────────────────────────
  final RxList<QuickRequest> quickRequests = <QuickRequest>[].obs;

  // ── Données du tableau de bord (réactives) ───────────────────────────────
  final summary = Rx<DriverSummary>(const DriverSummary(
    todayLabel: 'Revenus d\'aujourd\'hui',
    todayValue: '—',
    weekLabel: 'Semaine',
    weekValue: '—',
    monthLabel: 'Mois',
    monthValue: '—',
    pendingLabel: 'En attente',
    pendingValue: '—',
    commissionLabel: 'Commission MINIZON',
    commissionValue: '—',
  ));

  final metrics = <DriverMetric>[
    const DriverMetric(
      title: 'Trajets effectués',
      value: '—',
      icon: Icons.route_rounded,
      color: Color(0x1900A86B),
      iconColor: Color(0xFF00A86B),
    ),
    const DriverMetric(
      title: 'Passagers transportés',
      value: '—',
      icon: Icons.groups_rounded,
      color: Color(0x19F4B400),
      iconColor: Color(0xFFF4B400),
    ),
    const DriverMetric(
      title: 'Note moyenne',
      value: '—',
      icon: Icons.star_rounded,
      color: Color(0x1922C55E),
      iconColor: Color(0xFF22C55E),
    ),
    const DriverMetric(
      title: 'Taux acceptation',
      value: '—',
      icon: Icons.verified_rounded,
      color: Color(0x193B82F6),
      iconColor: Color(0xFF3B82F6),
    ),
  ].obs;

  final nextTrip = Rx<DriverTripCard?>(null);

  final recentRequests = <DriverRequest>[].obs;

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

  final wallet = Rx<DriverWallet>(const DriverWallet(
    balance: '—',
    blockedAmount: '—',
    methods: ['MTN Money', 'Moov Money'],
  ));

  final level = Rx<DriverLevel>(const DriverLevel(
    currentLevel: '—',
    progressLabel: 'Progrès',
    progressValue: '0%',
    progressFraction: 0.0,
    badges: [],
  ));

  final RxList<DriverNotificationModel> notifications =
      <DriverNotificationModel>[].obs;
  final RxInt unreadNotifCount = 0.obs;


  // ── Cycle de vie ─────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadDashboard();
    _loadNotifications();
  }

  Future<void> _loadDashboard() async {
    isLoadingDashboard.value = true;
    hasLoadError.value = false;
    final result = await _service.fetchDashboard();
    isLoadingDashboard.value = false;
    if (result.isSuccess) {
      _applyDashboard(result.data!);
    } else {
      if (dashboardVersion.value == 0) hasLoadError.value = true;
      logger.w('dashboard load failed: ${result.error}');
    }
  }

  @override
  Future<void> refresh() => Future.wait([_loadDashboard(), _loadNotifications()]);

  Future<void> _loadNotifications() async {
    final result = await _notifService.fetchNotifications(perPage: 5);
    if (result.isSuccess) {
      notifications.assignAll(result.data!.notifications);
      unreadNotifCount.value = result.data!.unreadCount;
    } else {
      logger.w('notifications load failed: ${result.error}');
    }
  }

  void _applyDashboard(DashboardModel data) {
    final isFirstLoad = dashboardVersion.value == 0;

    isOnline.value = data.isOnline;
    availabilityMode.value = data.availabilityMode;

    summary.value = DriverSummary(
      todayLabel: 'Revenus d\'aujourd\'hui',
      todayValue: data.summary.todayEarnings.toCurrency,
      weekLabel: 'Semaine',
      weekValue: _shortAmount(data.summary.weekEarnings),
      monthLabel: 'Mois',
      monthValue: _shortAmount(data.summary.monthEarnings),
      pendingLabel: 'En attente',
      pendingValue: _shortAmount(data.summary.pendingCount),
      commissionLabel: 'Commission MINIZON',
      commissionValue: data.summary.totalCommission.toCurrency,
    );

    metrics.assignAll(data.metrics.map(_metricFromApi));

    const visibleStatuses = {'pending', 'confirmed', 'active', 'in_progress', 'started'};
    if (data.nextTrip != null && visibleStatuses.contains(data.nextTrip!.status)) {
      final t = data.nextTrip!;
      final depLabel = t.departureNeighborhood.isNotEmpty
          ? '${t.departureNeighborhood}, ${t.departureCity}'
          : t.departureCity;
      final arrLabel = t.arrivalNeighborhood.isNotEmpty
          ? '${t.arrivalNeighborhood}, ${t.arrivalCity}'
          : t.arrivalCity;
      nextTrip.value = DriverTripCard(
        uuid: t.uuid,
        statusLabel: _statusLabel(t.status),
        time: _formatTime(t.departureTime),
        departureLabel: 'Départ',
        departure: depLabel,
        destinationLabel: 'Destination',
        destination: arrLabel,
        passengersLabel: '${t.passengersCount} passager${t.passengersCount > 1 ? 's' : ''} confirmé${t.passengersCount > 1 ? 's' : ''}',
        avatarUrls: t.passengers.map((p) => p.name).toList(),
        tripProgress: (t.status == 'in_progress' || t.status == 'started') ? 0.5 : 0.0,
      );
    } else {
      nextTrip.value = null;
    }

    for (final r in quickRequests) {
      r.cancelTimer();
    }
    final newQuick = data.quickRequests.map((r) {
      return QuickRequest(
        id: r.uuid,
        passengerName: r.passenger.name,
        passengerInitial: r.passenger.initials.isNotEmpty
            ? r.passenger.initials[0]
            : r.passenger.name.isNotEmpty
                ? r.passenger.name[0]
                : '?',
        rating: r.passenger.rating,
        routeLabel: '${r.trip.departureCity} → ${r.trip.arrivalCity}',
        amount: 0,
        seats: r.seatsBooked,
        expiresInSeconds: _expirySeconds(r.createdAt),
      );
    }).toList();
    quickRequests.assignAll(newQuick);
    for (final r in quickRequests) {
      r.startTimer(() => _onRequestExpired(r));
    }
    pendingRequestsCount.value = quickRequests.length;

    recentRequests.assignAll(
      data.recentRequests
          .where((r) => r.status != 'cancelled' && r.status != 'accepted')
          .map((r) {
        final statusInfo = _requestStatusInfo(r.status);
        return DriverRequest(
          id: r.uuid,
          name: r.passenger.name,
          rating: '${r.passenger.rating.toStringAsFixed(1)} ★',
          route: '${r.trip.departureCity} → ${r.trip.arrivalCity}',
          timeAgo: _timeAgo(r.createdAt),
          seats: '${r.seatsBooked} place${r.seatsBooked > 1 ? 's' : ''} demandée${r.seatsBooked > 1 ? 's' : ''}',
          status: statusInfo.$1,
          statusColor: statusInfo.$2,
          statusBackground: statusInfo.$3,
          avatarUrl: r.passenger.name,
        );
      }),
    );

    wallet.value = DriverWallet(
      balance: data.wallet.availableBalance.toCurrency,
      blockedAmount: data.wallet.blockedAmount.toCurrency,
      methods: const ['MTN Money', 'Moov Money'],
    );

    level.value = DriverLevel(
      currentLevel: data.level.currentLevel,
      progressLabel: 'Progrès vers ${data.level.nextLevel} (${data.level.tripsToNext} trajets)',
      progressValue: '${(data.level.progress * 100).toStringAsFixed(0)}%',
      progressFraction: data.level.progress.clamp(0.0, 1.0),
      badges: data.level.badges.map(_badgeFromApi).toList(),
    );

    dashboardVersion.value++;

    // Mise en disponibilité automatique à la première connexion
    if (isFirstLoad && !data.isOnline) {
      _autoSetOnline();
    }
  }

  Future<void> _autoSetOnline() async {
    isOnline.value = true;
    final result = await _service.updateAvailability(
      isOnline: true,
      mode: availabilityMode.value,
    );
    if (result.isSuccess) {
      availabilityMode.value = result.data!.mode;
    } else {
      logger.w('Auto-availability failed: ${result.error}');
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

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _shortAmount(int amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      final k = amount / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return '$amount';
  }

  String _formatTime(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '—';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _statusLabel(String status) => switch (status) {
        'pending' => 'En attente',
        'confirmed' => 'Confirmé',
        'active' => 'En cours',
        'completed' => 'Terminé',
        'cancelled' => 'Annulé',
        _ => status,
      };

  int _expirySeconds(String createdAt) {
    final created = DateTime.tryParse(createdAt) ?? DateTime.now();
    final expires = created.add(const Duration(minutes: 15));
    return expires.difference(DateTime.now()).inSeconds.clamp(0, 900);
  }

  String _timeAgo(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '—';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Il y a ${diff.inDays}j';
  }

  (String, Color, Color) _requestStatusInfo(String status) => switch (status) {
        'accepted' => ('Accepté', const Color(0xFF16A34A), const Color(0x1922C55E)),
        'rejected' => ('Refusé', const Color(0xFFDC2626), const Color(0x19EF4444)),
        'cancelled' => ('Annulé', const Color(0xFF6B7280), const Color(0x196B7280)),
        _ => ('En attente', const Color(0xFFF4B400), const Color(0x19F4B400)),
      };

  DriverMetric _metricFromApi(DashboardMetricData m) {
    final displayValue = m.value is double
        ? (m.value as double).toStringAsFixed(1)
        : '${m.value}';
    final progress = m.progress > 0 ? m.progress : null;
    return switch (m.key) {
      'trips' => DriverMetric(
          title: m.label,
          value: displayValue,
          icon: Icons.route_rounded,
          color: const Color(0x1900A86B),
          iconColor: const Color(0xFF00A86B),
          progress: progress,
        ),
      'passengers' => DriverMetric(
          title: m.label,
          value: displayValue,
          icon: Icons.groups_rounded,
          color: const Color(0x19F4B400),
          iconColor: const Color(0xFFF4B400),
          progress: progress,
        ),
      'rating' => DriverMetric(
          title: m.label,
          value: displayValue,
          icon: Icons.star_rounded,
          color: const Color(0x1922C55E),
          iconColor: const Color(0xFF22C55E),
          progress: progress,
        ),
      'acceptance_rate' => DriverMetric(
          title: m.label,
          value: '${(m.value is num ? (m.value as num).toDouble() * 100 : 0).toStringAsFixed(0)}%',
          icon: Icons.verified_rounded,
          color: const Color(0x193B82F6),
          iconColor: const Color(0xFF3B82F6),
          progress: m.value is num ? (m.value as num).toDouble() : progress,
        ),
      _ => DriverMetric(
          title: m.label,
          value: displayValue,
          icon: Icons.analytics_rounded,
          color: const Color(0x193B82F6),
          iconColor: const Color(0xFF3B82F6),
          progress: progress,
        ),
    };
  }

  DriverBadge _badgeFromApi(DashboardBadgeData b) => switch (b.key) {
        'top_rated' => DriverBadge(
            label: b.label,
            color: const Color(0x3300A86B),
            icon: Icons.verified_rounded,
            iconColor: const Color(0xFF00A86B),
          ),
        'top_driver' || 'top_10' => DriverBadge(
            label: b.label,
            color: const Color(0x33F4B400),
            icon: Icons.workspace_premium_rounded,
            iconColor: const Color(0xFFF4B400),
          ),
        'fast' || 'punctual' => DriverBadge(
            label: b.label,
            color: const Color(0x333B82F6),
            icon: Icons.speed_rounded,
            iconColor: const Color(0xFF3B82F6),
          ),
        _ => DriverBadge(
            label: b.label,
            color: const Color(0x33A855F7),
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFA855F7),
          ),
      };

  // ── Actions ──────────────────────────────────────────────────────────────

  Future<void> toggleAvailability() async {
    final newState = !isOnline.value;
    isOnline.value = newState;
    UIHelper().showSnackBar(
      'MINIZON',
      newState ? '🟢 Vous êtes maintenant en ligne.' : '⚪ Hors ligne.',
      newState ? 0 : 1,
    );
    final result = await _service.updateAvailability(
      isOnline: newState,
      mode: availabilityMode.value,
    );
    if (!result.isSuccess) {
      isOnline.value = !newState;
      UIHelper().showSnackBar('MINIZON', 'Erreur de mise à jour de la disponibilité.', 2);
    } else {
      availabilityMode.value = result.data!.mode;
    }
  }

  Future<void> onQuickAccept(QuickRequest r) async {
    if (r.isProcessing.value) return;
    logger.d('onQuickAccept uuid=${r.id}');
    if (r.id.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Identifiant de réservation manquant.', 2);
      return;
    }
    r.isProcessing.value = true;
    final result = await Get.find<BookingService>().acceptBooking(r.id);
    r.isProcessing.value = false;
    if (result.isSuccess) {
      r.cancelTimer();
      quickRequests.remove(r);
      pendingRequestsCount.value = quickRequests.length;
      recentRequests.removeWhere((req) => req.id == r.id);
      UIHelper().showSnackBar('MINIZON', '✅ ${r.passengerName} accepté(e) !', 0);
      _loadDashboard();
    } else {
      UIHelper().showSnackBar('MINIZON', 'Erreur lors de l\'acceptation. Réessayez.', 2);
    }
  }

  Future<void> onQuickReject(QuickRequest r) async {
    if (r.isProcessing.value) return;
    logger.d('onQuickReject uuid=${r.id}');
    if (r.id.isEmpty) {
      UIHelper().showSnackBar('MINIZON', 'Identifiant de réservation manquant.', 2);
      return;
    }
    r.isProcessing.value = true;
    final result = await Get.find<BookingService>().rejectBooking(r.id);
    r.isProcessing.value = false;
    if (result.isSuccess) {
      r.cancelTimer();
      quickRequests.remove(r);
      pendingRequestsCount.value = quickRequests.length;
      UIHelper().showSnackBar('MINIZON', 'Demande de ${r.passengerName} refusée.', 2);
      _loadDashboard();
    } else {
      UIHelper().showSnackBar('MINIZON', 'Erreur lors du refus. Réessayez.', 2);
    }
  }

  void onSeeAllRequests() => Get.toNamed(AppRoutes.driverReservations);
  void onPublishTrip() => Get.toNamed(AppRoutes.driverAddTrip);

  void selectWalletMethod(int index) => selectedWalletMethod.value = index;

  void showInfo(String message) =>
      UIHelper().showSnackBar('MINIZON', message, 1);

  void onSeeDetails() {
    final uuid = nextTrip.value?.uuid ?? '';
    if (uuid.isEmpty) return;
    Get.toNamed(AppRoutes.driverTripDetail, arguments: {'uuid': uuid});
  }

  void onContact() {
    const phone = '+229 97 XX XX XX';
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.call_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Text('Appeler le passager', style: TextStyle(fontSize: 16)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F7EF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(phone,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,
                      color: AppColors.primary, letterSpacing: 1)),
            ),
            const SizedBox(height: 6),
            const Text('Numéro masqué pour votre sécurité',
                style: TextStyle(fontSize: 11, color: AppColors.textGhost)),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: phone));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro copié.', 0);
            },
            child: const Text('Copier',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

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

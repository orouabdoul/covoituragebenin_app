import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/app_sync.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/phone_utils.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trip_model.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trips_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum TrajetFilterType { all, active, pending, completed, canceled }

class TrajetController extends GetxController {
  TripsService get _service => Get.find<TripsService>();

  final Rx<TrajetFilterType> selectedFilter = TrajetFilterType.all.obs;
  final RxBool isLoading = false.obs;
  final RxInt _tripsVersion = 0.obs;
  // Horloge réactive : utilisée par chaque carte pour surveiller isStartEnabled
  // indépendamment de l'Obx parent. Incrémentée toutes les 5 s.
  final RxInt clockTick = 0.obs;

  // ── Filter counts (updated from API filter_counts) ────────────────────────
  var _filterCounts = const {
    TrajetFilterType.all: 0,
    TrajetFilterType.active: 0,
    TrajetFilterType.pending: 0,
    TrajetFilterType.completed: 0,
    TrajetFilterType.canceled: 0,
  };

  // ── Trips cache per filter ────────────────────────────────────────────────
  final Map<TrajetFilterType, List<TrajetCardData>> _tripsByFilter = {
    TrajetFilterType.all: [],
    TrajetFilterType.active: [],
    TrajetFilterType.pending: [],
    TrajetFilterType.completed: [],
    TrajetFilterType.canceled: [],
  };
  bool _autoCancelInProgress = false;
  Timer? _autoCancelTimer;
  Timer? _refreshTimer;       // 5 s  : clockTick → Obx bouton réévalue isStartEnabled
  Timer? _pendingRefreshTimer; // 60 s : recharge les données API pour les trajets pending proches

  // ── Getters used by the view (inside Obx — reads _tripsVersion) ──────────

  List<TrajetFilterSummary> get filters {
    final _ = _tripsVersion.value;
    return [
      TrajetFilterSummary(
        type: TrajetFilterType.all,
        label: 'Tous',
        count: '${_filterCounts[TrajetFilterType.all] ?? 0}',
      ),
      TrajetFilterSummary(
        type: TrajetFilterType.active,
        label: AppStrings.trajetActiveFilter,
        count: '${_filterCounts[TrajetFilterType.active] ?? 0}',
      ),
      TrajetFilterSummary(
        type: TrajetFilterType.pending,
        label: AppStrings.trajetPendingFilter,
        count: '${_filterCounts[TrajetFilterType.pending] ?? 0}',
      ),
      TrajetFilterSummary(
        type: TrajetFilterType.completed,
        label: AppStrings.trajetCompletedFilter,
        count: '${_filterCounts[TrajetFilterType.completed] ?? 0}',
      ),
      TrajetFilterSummary(
        type: TrajetFilterType.canceled,
        label: AppStrings.trajetCanceledFilter,
        count: '${_filterCounts[TrajetFilterType.canceled] ?? 0}',
      ),
    ];
  }

  List<TrajetCardData> get visibleTrips {
    final _ = _tripsVersion.value;
    return _tripsByFilter[selectedFilter.value] ?? const [];
  }

  // ── Lifecycle ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadTrips(selectedFilter.value);
    _autoCancelTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _loadTrips(selectedFilter.value);
    });
    // Toutes les 5 s : clockTick force chaque carte à réévaluer isStartEnabled
    // dans son propre Obx, sans passer par l'Obx parent.
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      clockTick.value++;
      _tripsVersion.value = clockTick.value;
    });
    // Toutes les 60 s : si des trajets pending ont leur départ dans l'heure,
    // recharge silencieusement pour capturer enabled=true du backend.
    _pendingRefreshTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _silentRefreshIfPendingNear();
    });
    ever(AppSync.i.driverTrips, (_) {
      _tripsByFilter.clear();
      _loadTrips(selectedFilter.value);
    });
  }

  @override
  void onClose() {
    _autoCancelTimer?.cancel();
    _refreshTimer?.cancel();
    _pendingRefreshTimer?.cancel();
    super.onClose();
  }

  // ── API ───────────────────────────────────────────────────────────────────

  Future<void> _loadTrips(TrajetFilterType filter) async {
    isLoading.value = true;
    final result = await _service.fetchTrips(status: _filterStatus(filter));
    isLoading.value = false;
    if (result.isSuccess) {
      final autoCancelled = await _autoCancelExpiredTrips(result.data!.trips);
      _applyTripsData(
        autoCancelled ? (await _service.fetchTrips(status: _filterStatus(filter))).data ?? result.data! : result.data!,
        filter,
      );
    } else {
      logger.w('driverTrips failed: ${result.error}');
      UIHelper().showSnackBar('MINIZON', result.error?.message ?? 'Impossible de charger les trajets.', 2);
    }
  }

  Future<bool> _autoCancelExpiredTrips(List<TripItemData> trips) async {
    if (_autoCancelInProgress) return false;
    _autoCancelInProgress = true;
    var cancelledCount = 0;

    for (final trip in trips) {
      if (trip.uuid.isEmpty || trip.status != 'pending') continue;
      final departure = DateTime.tryParse(trip.departureTime)?.toLocal();
      if (departure == null ||
          DateTime.now().isBefore(departure.add(const Duration(hours: 3)))) {
        continue;
      }

      final cancellation = await _service.cancelTrip(trip.uuid);
      if (cancellation.isSuccess) cancelledCount++;
    }

    _autoCancelInProgress = false;
    if (cancelledCount == 0) return false;

    UIHelper().showSnackBar(
      'Trajet annulé',
      cancelledCount == 1
          ? 'Votre trajet a été annulé automatiquement après 3 heures.'
          : '$cancelledCount trajets ont été annulés automatiquement après 3 heures.',
      4,
    );
    AppSync.i.refreshDriverTrips();
    return true;
  }

  void _applyTripsData(TripsModel data, TrajetFilterType filter) {
    final totalCount = data.filterCounts.all > 0
        ? data.filterCounts.all
        : data.filterCounts.pending +
            data.filterCounts.active +
            data.filterCounts.completed +
            data.filterCounts.cancelled;

    _filterCounts = {
      TrajetFilterType.all: totalCount,
      TrajetFilterType.active: data.filterCounts.active,
      TrajetFilterType.pending: data.filterCounts.pending,
      TrajetFilterType.completed: data.filterCounts.completed,
      TrajetFilterType.canceled: data.filterCounts.cancelled,
    };

    _tripsByFilter[filter] = data.trips.map(_tripItemToCard).toList();
    _tripsVersion.value++;
  }

  /// Vérifie si au moins un trajet pending part dans l'heure.
  bool _hasPendingNearDeparture() {
    final trips = <TrajetCardData>[
      ...?_tripsByFilter[TrajetFilterType.pending],
      ...?_tripsByFilter[TrajetFilterType.all],
    ];
    return trips.any((t) {
      if (t.status != 'pending' || t.departureAt.isEmpty) return false;
      final dt = DateTime.tryParse(t.departureAt);
      if (dt == null) return false;
      return dt.toUtc().difference(DateTime.now().toUtc()).inMinutes <= 60;
    });
  }

  /// Recharge silencieusement la liste courante (sans indicateur de chargement)
  /// pour mettre à jour primary_action.enabled depuis le backend.
  Future<void> _silentRefreshIfPendingNear() async {
    if (!_hasPendingNearDeparture()) return;
    final result = await _service.fetchTrips(status: _filterStatus(selectedFilter.value));
    if (result.isSuccess) {
      _applyTripsData(result.data!, selectedFilter.value);
    }
  }

  TrajetCardData _tripItemToCard(TripItemData t) {
    final statusStyle = _statusStyle(t.status);
    final actionLabel = t.primaryAction?.label ?? _defaultActionLabel(t.status);
    final actionEnabled = t.primaryAction?.enabled ?? t.passengers.isNotEmpty;
    final card = TrajetCardData(
      uuid: t.uuid,
      status: t.status,
      statusLabel: t.statusLabel.isNotEmpty ? t.statusLabel : _defaultStatusLabel(t.status),
      statusBackground: statusStyle.$1,
      statusColor: statusStyle.$2,
      publishedAgo: t.publishedAgo,
      origin: t.displayOrigin,
      originPoint: t.originPoint,
      destination: t.displayDestination,
      destinationPoint: t.destinationPoint,
      departureLabel: AppStrings.trajetDeparture,
      departureTime: t.departureTimeLabel.isNotEmpty
          ? t.departureTimeLabel
          : _formatTime(t.departureTime),
      departureAt: t.departureAt,
      seatsLabel: AppStrings.trajetSeats,
      seatsValue: '${t.seatsBooked}/${t.seatsTotal}',
      priceLabel: AppStrings.trajetPrice,
      priceValue: t.priceLabel,
      passengers: t.passengers.map((p) => p.initials).toList(),
      passengerActionLabel: actionLabel,
      passengerActionEnabled: actionEnabled,
      primaryActionCode: t.primaryAction?.action ?? '',
      canCancel: t.canCancel,
      canEdit: t.canEdit,
      note: t.note?.isNotEmpty == true ? t.note : null,
      noteBackground: t.note?.isNotEmpty == true ? AppColors.accentLight : null,
      noteColor: t.note?.isNotEmpty == true ? AppColors.accent : null,
      reviewsCount: t.reviewsSummary?.count,
      hasPendingReply: t.reviewsSummary?.hasPendingReply ?? false,
    );
    return card;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _filterStatus(TrajetFilterType filter) => switch (filter) {
        TrajetFilterType.all => 'all',
        TrajetFilterType.active => 'active',
        TrajetFilterType.pending => 'pending',
        TrajetFilterType.completed => 'completed',
        TrajetFilterType.canceled => 'cancelled',
      };

  (Color, Color) _statusStyle(String status) => switch (status) {
        'active' => (AppColors.primary, AppColors.white),
        'pending' => (AppColors.accentMedium, AppColors.accent),
        'completed' => (AppColors.completedLight, AppColors.blueDark),
        'cancelled' => (AppColors.dangerLight, AppColors.danger),
        _ => (AppColors.surfaceMuted, AppColors.textMuted),
      };

  String _defaultStatusLabel(String status) => switch (status) {
        'active' => AppStrings.trajetStatusActive,
        'pending' => AppStrings.trajetStatusPending,
        'completed' => AppStrings.trajetStatusCompleted,
        'cancelled' => AppStrings.trajetStatusCanceled,
        _ => status,
      };

  String _defaultActionLabel(String status) => switch (status) {
        'active' => AppStrings.trajetViewPassengers,
        'pending' => AppStrings.trajetReviewRequest,
        'completed' => AppStrings.trajetSeeReceipt,
        _ => AppStrings.trajetNoPassengers,
      };

  String _formatTime(String isoDate) {
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return '—';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void selectFilter(TrajetFilterType filter) {
    selectedFilter.value = filter;
    _loadTrips(filter);
  }

  void forceRefreshActive() => _loadTrips(TrajetFilterType.active);

  void onCreateTrip() => Get.toNamed(AppRoutes.driverAddTrip);

  void onPrimaryAction(TrajetCardData trip) {
    // Les trajets pending dont isStartEnabled=true → toujours démarrer,
    // peu importe ce que l'API a mis dans primaryActionCode.
    if (trip.status == 'pending' && trip.isStartEnabled) {
      Get.toNamed(AppRoutes.driverActiveTrip,
          arguments: {'trip': _toTripModel(trip)});
      return;
    }
    switch (trip.primaryActionCode) {
      case 'start':
        // Sécurité : si le bouton est cliqué mais fenêtre pas encore ouverte
        UIHelper().showSnackBar(
            'MINIZON', 'Le départ est prévu dans plus de 5 minutes.', 1);
      case 'navigate':
        Get.toNamed(AppRoutes.driverRunningTrip,
            arguments: {'uuid': trip.uuid});
      case 'view':
        Get.toNamed(AppRoutes.driverTripDetail,
            arguments: {'uuid': trip.uuid});
      case 'none':
        break;
      default:
        switch (trip.status) {
          case 'active' || 'in_progress':
            Get.toNamed(AppRoutes.driverRunningTrip,
                arguments: {'uuid': trip.uuid});
          default:
            Get.toNamed(AppRoutes.driverTripDetail,
                arguments: {'uuid': trip.uuid});
        }
    }
  }

  /// Tap sur le corps de la card
  void onCardTap(TrajetCardData trip) {
    switch (trip.status) {
      case 'active' || 'in_progress':
        // Trajet actif → carte interactive en temps réel
        Get.toNamed(AppRoutes.driverInteractiveMap,
            arguments: {'uuid': trip.uuid, 'trip': _toTripModel(trip)});
      case 'pending':
        Get.toNamed(AppRoutes.driverTripDetail,
            arguments: {'uuid': trip.uuid});
      default:
        // Terminé ou annulé → détail
        Get.toNamed(AppRoutes.driverTripDetail,
            arguments: {'uuid': trip.uuid});
    }
  }

  /// Construit un TripModel minimal depuis TrajetCardData pour le fallback carte.
  TripModel _toTripModel(TrajetCardData t) => TripModel(
        id: t.uuid,
        origin: t.origin,
        originPoint: t.originPoint.isNotEmpty ? t.originPoint : null,
        destination: t.destination,
        destinationPoint: t.destinationPoint.isNotEmpty ? t.destinationPoint : null,
        departureTime: t.departureTime,
        departureAt: t.departureAt.isNotEmpty ? t.departureAt : null,
        totalSeats: 4,
        status: TripStatus.active,
        passengers: t.passengers
            .asMap()
            .entries
            .map((e) => TripPassengerModel(
                  id: 'p${e.key}',
                  name: e.value,
                  avatarInitial: e.value.isNotEmpty
                      ? e.value[0].toUpperCase()
                      : '?',
                  rating: 0,
                  tripsCount: 0,
                  seatsBooked: 1,
                  amount: 0,
                  paymentStatus: PassengerPaymentStatus.pending,
                  isVerified: false,
                ))
            .toList(),
        pricePerSeat: 0,
        distanceKm: 0,
        durationMin: 0,
        publishedAgo: t.publishedAgo,
      );

  Future<void> onPassengers(TrajetCardData trip) async {
    if (trip.uuid.isEmpty) return;
    final result = await _service.fetchTripPassengers(trip.uuid);
    if (!result.isSuccess) {
      UIHelper().showSnackBar(
          'MINIZON', 'Impossible de charger les passagers.', 2);
      return;
    }
    _showPassengersSheet(result.data!);
  }

  void _showPassengersSheet(TripPassengersModel data) {
    Get.bottomSheet(
      Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.75),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(9999)),
              ),
            ),
            const SizedBox(height: 16),
            Text(data.tripRoute,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${data.totalBooked} passager${data.totalBooked > 1 ? 's' : ''}',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 16),
            if (data.passengers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('Aucun passager pour ce trajet.',
                      style: TextStyle(color: AppColors.textMuted)),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: data.passengers.length,
                  separatorBuilder: (ctx, idx) =>
                      const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (_, i) {
                    final p = data.passengers[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(p.initials,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.fullName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14)),
                                const SizedBox(height: 2),
                                Text(
                                  '${p.seatsBooked} place${p.seatsBooked > 1 ? 's' : ''} · ${_bookingStatusLabel(p.bookingStatus)}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if (p.phone.isNotEmpty)
                            GestureDetector(
                              onTap: () => _callPassenger(p),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.10),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.call_rounded,
                                    size: 18, color: AppColors.primary),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _callPassenger(TripPassengerDetailData p) => PhoneUtils.call(p.phone);

  void onSecondaryAction(String label, TrajetCardData trip) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(9999)),
              ),
            ),
            const SizedBox(height: 16),
            Text(trip.routeLabel,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            if (trip.canEdit)
              _OptionTile(
                icon: Icons.edit_rounded,
                label: 'Modifier le trajet',
                onTap: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.driverEditTrip,
                    arguments: {'uuid': trip.uuid},
                  );
                },
              ),
            if (trip.canCancel) ...[
              if (trip.canEdit)
                const Divider(height: 1, color: AppColors.border),
              _OptionTile(
                icon: Icons.cancel_outlined,
                label: 'Annuler le trajet',
                color: AppColors.danger,
                onTap: () {
                  Get.back();
                  _confirmCancel(trip);
                },
              ),
            ],
            if (!trip.canEdit && !trip.canCancel)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Aucune action disponible.',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _confirmCancel(TrajetCardData trip) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Annuler le trajet ?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
            'Le trajet "${trip.routeLabel}" sera annulé. Les passagers seront notifiés.'),
        actions: [
          TextButton(
              onPressed: Get.back,
              child: const Text('Non',
                  style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              Get.back();
              _cancelTrip(trip);
            },
            child: const Text('Annuler le trajet',
                style: TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelTrip(TrajetCardData trip) async {
    final result = await _service.cancelTrip(trip.uuid);
    if (!result.isSuccess) {
      UIHelper().showSnackBar(
          'MINIZON', 'Impossible d\'annuler ce trajet.', 2);
      return;
    }
    // Remove from current filter list and refresh
    _tripsByFilter[selectedFilter.value]
        ?.removeWhere((t) => t.uuid == trip.uuid);
    _filterCounts = {
      ..._filterCounts,
      selectedFilter.value:
          (_filterCounts[selectedFilter.value] ?? 1) - 1,
      TrajetFilterType.canceled:
          (_filterCounts[TrajetFilterType.canceled] ?? 0) + 1,
    };
    _tripsVersion.value++;
    UIHelper().showSnackBar('MINIZON', 'Trajet annulé avec succès.', 0);
  }

  String _bookingStatusLabel(String status) => switch (status) {
        'accepted' => 'Accepté',
        'pending' => 'En attente',
        'rejected' => 'Refusé',
        'cancelled' => 'Annulé',
        _ => status,
      };

  void showInfo(String message) =>
      UIHelper().showSnackBar('MINIZON', message, 1);

  void onViewTripReviews(TrajetCardData trip) {
    Get.toNamed(
      AppRoutes.driverTripReviews,
      arguments: {'tripUuid': trip.uuid, 'tripRoute': trip.routeLabel},
    );
  }
}

// ── Option tile for the secondary action sheet ──────────────────────────────

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600)),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ── Models ──────────────────────────────────────────────────────────────────

class TrajetFilterSummary {
  const TrajetFilterSummary({
    required this.type,
    required this.label,
    required this.count,
  });

  final TrajetFilterType type;
  final String label;
  final String count;
}

class TrajetCardData {
  const TrajetCardData({
    required this.uuid,
    required this.status,
    required this.statusLabel,
    required this.statusBackground,
    required this.statusColor,
    required this.publishedAgo,
    required this.origin,
    this.originPoint = '',
    required this.destination,
    this.destinationPoint = '',
    required this.departureLabel,
    required this.departureTime,
    this.departureAt = '',
    required this.seatsLabel,
    required this.seatsValue,
    required this.priceLabel,
    required this.priceValue,
    required this.passengers,
    required this.passengerActionLabel,
    this.passengerActionEnabled = true,
    this.primaryActionCode = '',
    this.canCancel = false,
    this.canEdit = false,
    this.note,
    this.noteBackground,
    this.noteColor,
    this.reviewsCount,
    this.hasPendingReply = false,
  });

  final String uuid;
  final String status;
  final String statusLabel;
  final Color statusBackground;
  final Color statusColor;
  final String publishedAgo;
  final String origin;
  final String originPoint;
  final String destination;
  final String destinationPoint;
  final String departureLabel;
  final String departureTime;
  final String departureAt;
  final String seatsLabel;
  final String seatsValue;
  final String priceLabel;
  final String priceValue;
  final List<String> passengers;
  final String passengerActionLabel;
  final bool passengerActionEnabled;
  final String primaryActionCode;
  final bool canCancel;
  final bool canEdit;
  final String? note;
  final Color? noteBackground;
  final Color? noteColor;
  final int? reviewsCount;
  final bool hasPendingReply;

  String get routeLabel => '$origin → $destination';

  /// Bouton "Démarrer" actif si le trajet est pending ET qu'on est dans la
  /// fenêtre de 5 min avant le départ (calculé localement depuis departureAt)
  /// OU si le backend a déjà confirmé enabled=true (passengerActionEnabled).
  bool get isStartEnabled {
    if (status != 'pending') return passengerActionEnabled;
    // Signal backend : si l'API a déjà calculé enabled=true, respecter ce choix.
    if (passengerActionEnabled) return true;
    // Signal local : calcul temps-réel (actif dès le tick de 5 s suivant).
    if (departureAt.isEmpty) return false;
    final dt = DateTime.tryParse(departureAt);
    if (dt == null) return false;
    final depUtc = dt.isUtc ? dt : dt.toUtc();
    return DateTime.now().toUtc().isAfter(depUtc.subtract(const Duration(minutes: 5)));
  }
}

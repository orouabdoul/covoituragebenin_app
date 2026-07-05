import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/trips/trips_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/trips_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

enum TrajetFilterType { active, pending, completed, canceled }

class TrajetController extends GetxController {
  TripsService get _service => Get.find<TripsService>();

  final Rx<TrajetFilterType> selectedFilter = TrajetFilterType.active.obs;
  final RxBool isLoading = false.obs;
  final RxInt _tripsVersion = 0.obs;

  // ── Filter counts (updated from API filter_counts) ────────────────────────
  var _filterCounts = const {
    TrajetFilterType.active: 0,
    TrajetFilterType.pending: 0,
    TrajetFilterType.completed: 0,
    TrajetFilterType.canceled: 0,
  };

  // ── Trips cache per filter ────────────────────────────────────────────────
  final Map<TrajetFilterType, List<TrajetCardData>> _tripsByFilter = {
    TrajetFilterType.active: [],
    TrajetFilterType.pending: [],
    TrajetFilterType.completed: [],
    TrajetFilterType.canceled: [],
  };

  // ── Getters used by the view (inside Obx — reads _tripsVersion) ──────────

  List<TrajetFilterSummary> get filters {
    final _ = _tripsVersion.value;
    return [
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
  }

  // ── API ───────────────────────────────────────────────────────────────────

  Future<void> _loadTrips(TrajetFilterType filter) async {
    isLoading.value = true;
    final result = await _service.fetchTrips(status: _filterStatus(filter));
    isLoading.value = false;
    if (result.isSuccess) {
      _applyTripsData(result.data!, filter);
    } else {
      logger.w('driverTrips failed: ${result.error}');
    }
  }

  void _applyTripsData(TripsModel data, TrajetFilterType filter) {
    // Update filter counts from API
    _filterCounts = {
      TrajetFilterType.active: data.filterCounts.active,
      TrajetFilterType.pending: data.filterCounts.pending,
      TrajetFilterType.completed: data.filterCounts.completed,
      TrajetFilterType.canceled: data.filterCounts.cancelled,
    };

    // Map API trips to UI model
    _tripsByFilter[filter] =
        data.trips.map(_tripItemToCard).toList();

    _tripsVersion.value++;
  }

  TrajetCardData _tripItemToCard(TripItemData t) {
    final statusStyle = _statusStyle(t.status);
    final actionLabel = t.primaryAction?.label ?? _defaultActionLabel(t.status);
    final actionEnabled = t.primaryAction?.enabled ?? t.passengers.isNotEmpty;

    return TrajetCardData(
      uuid: t.uuid,
      statusLabel: t.statusLabel.isNotEmpty ? t.statusLabel : _defaultStatusLabel(t.status),
      statusBackground: statusStyle.$1,
      statusColor: statusStyle.$2,
      publishedAgo: t.publishedAgo,
      origin: t.origin,
      destination: t.destination,
      departureLabel: AppStrings.trajetDeparture,
      departureTime: t.departureTimeLabel.isNotEmpty
          ? t.departureTimeLabel
          : _formatTime(t.departureTime),
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
      noteBackground: t.note?.isNotEmpty == true
          ? const Color(0x19F4B400)
          : null,
      noteColor: t.note?.isNotEmpty == true
          ? const Color(0xFFF4B400)
          : null,
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _filterStatus(TrajetFilterType filter) => switch (filter) {
        TrajetFilterType.active => 'active',
        TrajetFilterType.pending => 'pending',
        TrajetFilterType.completed => 'completed',
        TrajetFilterType.canceled => 'cancelled',
      };

  (Color, Color) _statusStyle(String status) => switch (status) {
        'active' => (AppColors.primary, AppColors.white),
        'pending' => (const Color(0x33F4B400), const Color(0xFFF4B400)),
        'completed' => (const Color(0x193B82F6), const Color(0xFF2563EB)),
        'cancelled' => (const Color(0x19E53935), const Color(0xFFE53935)),
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
    // Load from API if not cached yet (list is empty)
    if (_tripsByFilter[filter]?.isEmpty ?? true) {
      _loadTrips(filter);
    }
  }

  void onCreateTrip() => Get.toNamed(AppRoutes.driverAddTrip);

  void onPrimaryAction(TrajetCardData trip) {
    switch (trip.primaryActionCode) {
      case 'start':
      case 'navigate':
        Get.toNamed(AppRoutes.driverInteractiveMap,
            arguments: {'trip': trip});
      default:
        if (selectedFilter.value == TrajetFilterType.active) {
          Get.toNamed(AppRoutes.driverInteractiveMap,
              arguments: {'trip': trip});
        } else {
          UIHelper().showSnackBar(
              'MINIZON', '${trip.passengerActionLabel} — ${trip.routeLabel}', 1);
        }
    }
  }

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

  void _callPassenger(TripPassengerDetailData p) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(p.initials,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
              child: Text(p.fullName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                  color: const Color(0xFFE6F7EF),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(p.phone,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                      letterSpacing: 1)),
            ),
            const SizedBox(height: 8),
            const Text('Numéro masqué pour votre sécurité',
                style: TextStyle(fontSize: 11, color: AppColors.textGhost)),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: p.phone));
              Get.back();
              UIHelper().showSnackBar('MINIZON', 'Numéro copié.', 0);
            },
            child: const Text('Copier',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

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
                    AppRoutes.driverAddTrip,
                    arguments: {'uuid': trip.uuid, 'isEdit': true},
                  );
                },
              ),
            if (trip.canCancel) ...[
              if (trip.canEdit)
                const Divider(height: 1, color: AppColors.border),
              _OptionTile(
                icon: Icons.cancel_outlined,
                label: 'Annuler le trajet',
                color: const Color(0xFFE53935),
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
                    color: Color(0xFFE53935),
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
    required this.statusLabel,
    required this.statusBackground,
    required this.statusColor,
    required this.publishedAgo,
    required this.origin,
    required this.destination,
    required this.departureLabel,
    required this.departureTime,
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
  });

  final String uuid;
  final String statusLabel;
  final Color statusBackground;
  final Color statusColor;
  final String publishedAgo;
  final String origin;
  final String destination;
  final String departureLabel;
  final String departureTime;
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

  String get routeLabel => '$origin → $destination';
}

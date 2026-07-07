import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/services/passenger/trips/passenger_trips_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/app_errors.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/data/models/passenger/trip_history_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

export 'package:covoiturage_benin_app/app/data/models/passenger/trip_history_model.dart'
    show TripRecord;

class TripHistoryController extends GetxController {
  PassengerTripsService get _service => Get.find<PassengerTripsService>();

  final selectedFilter = 'all'.obs;
  final isLoading = false.obs;
  final hasError = false.obs;

  final filterLabels = const [
    {'key': 'all', 'label': 'Tous'},
    {'key': 'upcoming', 'label': 'À venir'},
    {'key': 'completed', 'label': 'Terminés'},
    {'key': 'cancelled', 'label': 'Annulés'},
  ];

  final RxList<TripRecord> trips = <TripRecord>[].obs;

  // Counts from API summary (more accurate than counting the list)
  final countUpcoming  = 0.obs;
  final countCompleted = 0.obs;
  final countCancelled = 0.obs;

  List<TripRecord> get filteredTrips {
    final f = selectedFilter.value;
    if (f == 'all') return trips;
    return trips.where((t) => t.status == f).toList();
  }

  int countByStatus(String status) {
    switch (status) {
      case 'upcoming':  return countUpcoming.value;
      case 'completed': return countCompleted.value;
      case 'cancelled': return countCancelled.value;
      default: return trips.where((t) => t.status == status).length;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    isLoading.value = true;
    hasError.value = false;
    final result = await _service.fetchHistory();
    isLoading.value = false;
    if (result.isSuccess) {
      final data = result.data!;
      countUpcoming.value  = data.counts.upcoming;
      countCompleted.value = data.counts.completed;
      countCancelled.value = data.counts.cancelled;
      trips.assignAll(data.trips);
    } else {
      hasError.value = true;
      logger.e('passengerTripHistory: ${result.error}');
      if (result.error == AppError.socket) return;
    }
  }

  @override
  Future<void> refresh() => _loadHistory();

  String formattedPrice(int price) {
    final str = price.toString();
    final buf = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buf.write(' ');
      buf.write(str[i]);
    }
    return '$buf FCFA';
  }

  void selectFilter(String filter) => selectedFilter.value = filter;

  void rebookTrip(TripRecord trip) => BottonNavController.goToTab(1);

  void requestRefund(TripRecord trip) {
    Get.toNamed(
      AppRoutes.passengerRefundRequest,
      arguments: {
        'bookingUuid': trip.id,
        'amount': trip.price,
        'route': '${trip.origin} → ${trip.destination}',
        'date': trip.date,
        'ref': 'REF-${trip.id}',
      },
    );
  }

  void viewDetails(TripRecord trip) {
    Get.bottomSheet(
      _TripDetailSheet(trip: trip, controller: this),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
    );
  }
}

// ── Detail Bottom Sheet ──────────────────────────────────────────────────────

class _TripDetailSheet extends StatelessWidget {
  const _TripDetailSheet({required this.trip, required this.controller});
  final TripRecord trip;
  final TripHistoryController controller;

  Color get _statusColor => switch (trip.status) {
    'completed' => AppColors.primary,
    'cancelled' => const Color(0xFFEF4444),
    _ => const Color(0xFF6366F1),
  };

  String get _statusLabel => switch (trip.status) {
    'completed' => 'Terminé',
    'cancelled' => 'Annulé',
    _ => 'À venir',
  };

  IconData get _statusIcon => switch (trip.status) {
    'completed' => Icons.check_circle_rounded,
    'cancelled' => Icons.cancel_rounded,
    _ => Icons.schedule_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      minChildSize: 0.50,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: responsive.h(12)),
            child: Center(
              child: Container(
                width: responsive.w(40),
                height: responsive.h(4),
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: EdgeInsets.symmetric(horizontal: responsive.w(20)),
              children: [
                Row(
                  children: [
                    Icon(_statusIcon, size: responsive.text(18), color: _statusColor),
                    SizedBox(width: responsive.w(8)),
                    Text(_statusLabel, style: AppTextStyles.subtitle(responsive).copyWith(color: _statusColor, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Text(trip.id, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint, fontFamily: 'monospace')),
                  ],
                ),
                SizedBox(height: responsive.h(16)),
                Container(
                  padding: EdgeInsets.all(responsive.w(16)),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(responsive.radius(14)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(responsive: responsive, icon: Icons.trip_origin_rounded, iconColor: AppColors.primary, label: 'Départ', value: '${trip.origin} · ${trip.time}'),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: responsive.h(6)),
                        child: Container(height: 1, color: AppColors.border),
                      ),
                      _DetailRow(responsive: responsive, icon: Icons.location_on_rounded, iconColor: const Color(0xFFEF4444), label: 'Arrivée', value: trip.destination),
                    ],
                  ),
                ),
                SizedBox(height: responsive.h(16)),
                _InfoCard(responsive: responsive, children: [
                  _DetailRow(responsive: responsive, icon: Icons.calendar_today_rounded, label: 'Date', value: trip.date),
                  Divider(color: AppColors.border, height: responsive.h(20)),
                  _DetailRow(responsive: responsive, icon: Icons.person_rounded, label: 'Conducteur', value: trip.driverName),
                  Divider(color: AppColors.border, height: responsive.h(20)),
                  _DetailRow(responsive: responsive, icon: Icons.directions_car_rounded, label: 'Véhicule', value: '${trip.vehicle} · ${trip.vehiclePlate}'),
                  Divider(color: AppColors.border, height: responsive.h(20)),
                  _DetailRow(responsive: responsive, icon: Icons.event_seat_rounded, label: 'Places', value: '${trip.seats} place${trip.seats > 1 ? 's' : ''}'),
                  Divider(color: AppColors.border, height: responsive.h(20)),
                  _DetailRow(
                    responsive: responsive,
                    icon: Icons.payments_rounded,
                    label: 'Total payé',
                    value: controller.formattedPrice(trip.price * trip.seats),
                    valueStyle: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                  if (trip.rating != null) ...[
                    Divider(color: AppColors.border, height: responsive.h(20)),
                    _RatingRow(responsive: responsive, rating: trip.rating!),
                  ],
                ]),
                SizedBox(height: responsive.h(20)),
                if (trip.status == 'cancelled')
                  OutlinedButton.icon(
                    onPressed: () { Get.back(); controller.requestRefund(trip); },
                    icon: Icon(Icons.account_balance_wallet_rounded, size: responsive.text(16)),
                    label: const Text('Demander un remboursement'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.40)),
                      padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(12))),
                    ),
                  ),
                if (trip.status == 'upcoming' || trip.status == 'completed')
                  OutlinedButton.icon(
                    onPressed: () { Get.back(); controller.rebookTrip(trip); },
                    icon: Icon(Icons.repeat_rounded, size: responsive.text(16)),
                    label: const Text('Réserver à nouveau'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.40)),
                      padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(12))),
                    ),
                  ),
                SizedBox(height: responsive.h(32)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.responsive, required this.children});
  final AppResponsive responsive;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(responsive.radius(14)),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(children: children),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.responsive,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.valueStyle,
  });
  final AppResponsive responsive;
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: responsive.text(15), color: iconColor ?? AppColors.textHint),
        SizedBox(width: responsive.w(10)),
        Expanded(
          child: Text(label, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
        ),
        Text(
          value,
          style: valueStyle ?? AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.responsive, required this.rating});
  final AppResponsive responsive;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.star_rounded, size: responsive.text(15), color: AppColors.warning),
        SizedBox(width: responsive.w(10)),
        Expanded(
          child: Text('Votre note', style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
        ),
        Row(
          children: List.generate(5, (i) => Icon(
            i < rating.round() ? Icons.star_rounded : Icons.star_outline_rounded,
            size: responsive.text(14),
            color: AppColors.warning,
          )),
        ),
      ],
    );
  }
}

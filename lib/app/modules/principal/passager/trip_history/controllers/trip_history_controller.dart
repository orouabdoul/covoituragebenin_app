import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';

class TripRecord {
  final String id;
  final String origin;
  final String destination;
  final String date;
  final String time;
  final String driverName;
  final String vehicle;
  final String vehiclePlate;
  final int price;
  final int seats;
  final String status; // 'upcoming' | 'completed' | 'cancelled'
  final double? rating;
  const TripRecord({
    required this.id,
    required this.origin,
    required this.destination,
    required this.date,
    required this.time,
    required this.driverName,
    required this.vehicle,
    required this.vehiclePlate,
    required this.price,
    required this.seats,
    required this.status,
    this.rating,
  });
}

class TripHistoryController extends GetxController {
  final selectedFilter = 'all'.obs;

  final filterLabels = const [
    {'key': 'all', 'label': 'Tous'},
    {'key': 'upcoming', 'label': 'À venir'},
    {'key': 'completed', 'label': 'Terminés'},
    {'key': 'cancelled', 'label': 'Annulés'},
  ];

  final trips = <TripRecord>[
    const TripRecord(
      id: 'TR001',
      origin: 'Cotonou',
      destination: 'Parakou',
      date: '28 Juin 2026',
      time: '06:00',
      driverName: 'Koffi Amédégnato',
      vehicle: 'Toyota Corolla',
      vehiclePlate: 'BJ 1234 AB',
      price: 8500,
      seats: 1,
      status: 'upcoming',
    ),
    const TripRecord(
      id: 'TR002',
      origin: 'Porto-Novo',
      destination: 'Abomey',
      date: '30 Juin 2026',
      time: '09:30',
      driverName: 'Sébastien Houénou',
      vehicle: 'Honda Accord',
      vehiclePlate: 'BJ 5678 CD',
      price: 4200,
      seats: 2,
      status: 'upcoming',
    ),
    const TripRecord(
      id: 'TR003',
      origin: 'Cotonou',
      destination: 'Porto-Novo',
      date: '20 Juin 2026',
      time: '07:00',
      driverName: 'Ahoua Bello',
      vehicle: 'Peugeot 308',
      vehiclePlate: 'BJ 9012 EF',
      price: 2500,
      seats: 1,
      status: 'completed',
      rating: 5,
    ),
    const TripRecord(
      id: 'TR004',
      origin: 'Abomey-Calavi',
      destination: 'Cotonou',
      date: '15 Juin 2026',
      time: '08:00',
      driverName: 'Yaovi Djossou',
      vehicle: 'Renault Logan',
      vehiclePlate: 'BJ 3456 GH',
      price: 1500,
      seats: 1,
      status: 'completed',
      rating: 4,
    ),
    const TripRecord(
      id: 'TR005',
      origin: 'Cotonou',
      destination: 'Lokossa',
      date: '10 Juin 2026',
      time: '10:00',
      driverName: 'Clément Hounkpévi',
      vehicle: 'Toyota Camry',
      vehiclePlate: 'BJ 7890 IJ',
      price: 5500,
      seats: 2,
      status: 'completed',
      rating: 5,
    ),
    const TripRecord(
      id: 'TR006',
      origin: 'Cotonou',
      destination: 'Natitingou',
      date: '5 Juin 2026',
      time: '05:30',
      driverName: 'Rachid Alafia',
      vehicle: 'Mitsubishi Galant',
      vehiclePlate: 'BJ 2345 KL',
      price: 12000,
      seats: 1,
      status: 'cancelled',
    ),
    const TripRecord(
      id: 'TR007',
      origin: 'Porto-Novo',
      destination: 'Cotonou',
      date: '1 Juin 2026',
      time: '16:00',
      driverName: 'Prosper Tokponto',
      vehicle: 'Nissan Sentra',
      vehiclePlate: 'BJ 6789 MN',
      price: 2000,
      seats: 1,
      status: 'cancelled',
    ),
  ].obs;

  List<TripRecord> get filteredTrips {
    final f = selectedFilter.value;
    if (f == 'all') return trips;
    return trips.where((t) => t.status == f).toList();
  }

  int countByStatus(String status) => trips.where((t) => t.status == status).length;

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
          // Handle
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
                // Title
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
                // Route
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
                // Info rows
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
                // Actions
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../../search/controllers/search_controller.dart';
import '../bindings/detail_reservation_binding.dart';
import '../controllers/detail_reservation_controller.dart';
import '../controllers/reservation_controller.dart';

class DetailJourneyView extends StatelessWidget {
  const DetailJourneyView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<DetailReservationController>()) {
      DetailReservationBinding().dependencies();
    }
    final DetailReservationController controller =
        Get.find<DetailReservationController>();
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                responsive.adaptive(
                    phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                responsive.adaptive(
                    phone: 8, smallPhone: 8, tablet: 12, desktop: 16),
                responsive.adaptive(
                    phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                responsive.adaptive(
                    phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
              ),
              children: [
                _HeaderBar(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),

                // ── Statut réservation (existante seulement) ─────────────
                Obx(() {
                  final r = controller.existingReservation;
                  if (!controller.isExistingReservation.value || r == null) {
                    return const SizedBox.shrink();
                  }
                  return Column(children: [
                    _BookingStatusCard(responsive: responsive, reservation: r),
                    SizedBox(height: responsive.h(16)),
                  ]);
                }),

                // ── Conducteur ───────────────────────────────────────────
                Obx(() =>
                    _DriverCard(responsive: responsive, ride: controller.ride.value)),
                SizedBox(height: responsive.h(16)),

                // ── Métriques conducteur (réactives) ─────────────────────
                _MetricRow(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),

                // ── Véhicule ─────────────────────────────────────────────
                Obx(() =>
                    _VehicleCard(responsive: responsive, ride: controller.ride.value)),
                SizedBox(height: responsive.h(16)),

                // ── Points passager (prise/dépose avec adresses) ──────────
                Obx(() {
                  if (!controller.isExistingReservation.value) return const SizedBox.shrink();
                  final r = controller.existingReservation;
                  if (r == null) return const SizedBox.shrink();
                  return Column(children: [
                    _PassengerRouteCard(
                        responsive: responsive, reservation: r),
                    SizedBox(height: responsive.h(16)),
                  ]);
                }),

                // ── Itinéraire complet du trajet ──────────────────────────
                Obx(() =>
                    _ItineraryCard(responsive: responsive, ride: controller.ride.value)),
                SizedBox(height: responsive.h(16)),

                // ── Conditions ────────────────────────────────────────────
                _ConditionsCard(responsive: responsive),
                SizedBox(height: responsive.h(16)),

                // ── Détails prix et commission ────────────────────────────
                _PriceCard(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),

                // ── Avis passagers ────────────────────────────────────────
                _ReviewsCard(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),

                // ── Actions selon contexte ────────────────────────────────
                Obx(() {
                  if (controller.isExistingReservation.value) {
                    return _ExistingReservationActions(
                      responsive: responsive,
                      controller: controller,
                    );
                  }
                  return Column(
                    children: [
                      AppPrimaryButton(
                        responsive: responsive,
                        label: AppStrings.searchReserve,
                        onTap: controller.bookNow,
                        backgroundColor: AppColors.primary,
                        textColor: AppColors.white,
                        borderRadius: responsive.radius(16),
                        height: responsive.h(56),
                      ),
                      SizedBox(height: responsive.h(8)),
                      Center(
                        child: Text(
                          AppStrings.reservationAcceptedCancellation,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(responsive)
                              .copyWith(color: AppColors.textHint),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Header Bar ─────────────────────────────────────────────────────────────

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DetailReservationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(
          phone: 16, smallPhone: 14, tablet: 16, desktop: 18)),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.chevron_left_rounded, onTap: Get.back),
          const Spacer(),
          Text(AppStrings.reservationDetailTitle,
              style: AppTextStyles.title(responsive)),
          const Spacer(),
          Obx(
            () => _CircleIconButton(
              icon: controller.isFavorite.value
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              iconColor: controller.isFavorite.value
                  ? AppColors.primary
                  : AppColors.textPrimary,
              onTap: controller.toggleFavorite,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton(
      {required this.icon, required this.onTap, this.iconColor});

  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          width: responsive.w(40),
          height: responsive.w(40),
          decoration: ShapeDecoration(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: Icon(icon,
              size: responsive.text(22),
              color: iconColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── Section Card ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.responsive, required this.child});

  final AppResponsive responsive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(
          phone: 20, smallPhone: 18, tablet: 20, desktop: 20)),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(
              color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

// ── Booking Status Card ────────────────────────────────────────────────────

class _BookingStatusCard extends StatelessWidget {
  const _BookingStatusCard(
      {required this.responsive, required this.reservation});

  final AppResponsive responsive;
  final ReservationItem reservation;

  Color get _statusColor {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return AppColors.warning;
      case ReservationStatus.confirmed:
        return reservation.isPaid ? AppColors.primary : AppColors.warning;
      case ReservationStatus.inProgress:
        return AppColors.primary;
      case ReservationStatus.completed:
        return AppColors.textSecondary;
      case ReservationStatus.cancelled:
        return AppColors.danger;
    }
  }

  String get _statusLabel {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return 'En attente de confirmation';
      case ReservationStatus.confirmed:
        return reservation.isPaid
            ? 'Confirmée et payée'
            : 'Confirmée — Paiement requis';
      case ReservationStatus.inProgress:
        return 'Trajet en cours';
      case ReservationStatus.completed:
        return 'Trajet terminé';
      case ReservationStatus.cancelled:
        return 'Réservation annulée';
    }
  }

  IconData get _statusIcon {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return Icons.hourglass_top_rounded;
      case ReservationStatus.confirmed:
        return reservation.isPaid
            ? Icons.check_circle_rounded
            : Icons.payment_rounded;
      case ReservationStatus.inProgress:
        return Icons.directions_car_filled_rounded;
      case ReservationStatus.completed:
        return Icons.task_alt_rounded;
      case ReservationStatus.cancelled:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    final refId = reservation.bookingRef.isNotEmpty
        ? reservation.bookingRef
        : '#${reservation.id.length > 8 ? reservation.id.substring(0, 8).toUpperCase() : reservation.id.toUpperCase()}';

    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Column(
        children: [
          // Bandeau statut
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: responsive.w(16), vertical: responsive.h(10)),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(responsive.radius(16)),
                topRight: Radius.circular(responsive.radius(16)),
              ),
              border: Border(
                  bottom: BorderSide(color: color.withValues(alpha: 0.20))),
            ),
            child: Row(
              children: [
                Icon(_statusIcon, size: responsive.text(16), color: color),
                SizedBox(width: responsive.w(8)),
                Expanded(
                  child: Text(_statusLabel,
                      style: AppTextStyles.subtitle(responsive).copyWith(
                          color: color, fontWeight: FontWeight.w700)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(8), vertical: responsive.h(3)),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    refId,
                    style: AppTextStyles.caption(responsive).copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ),
          // Infos réservation
          Padding(
            padding: EdgeInsets.all(responsive.w(16)),
            child: Row(
              children: [
                _InfoCell(
                  responsive: responsive,
                  icon: Icons.event_seat_rounded,
                  label: 'Places',
                  value:
                      '${reservation.seatsCount} place${reservation.seatsCount > 1 ? 's' : ''}',
                ),
                _VertDivider(responsive: responsive),
                _InfoCell(
                  responsive: responsive,
                  icon: Icons.calendar_today_outlined,
                  label: 'Date',
                  value: reservation.departureDate,
                ),
                _VertDivider(responsive: responsive),
                _InfoCell(
                  responsive: responsive,
                  icon: Icons.schedule_rounded,
                  label: 'Heure',
                  value: reservation.departureTime,
                ),
              ],
            ),
          ),
          // Raison annulation
          if (reservation.status == ReservationStatus.cancelled &&
              reservation.cancelReason != null)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(16), vertical: responsive.h(10)),
              decoration: BoxDecoration(
                color: AppColors.dangerSurface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(responsive.radius(16)),
                  bottomRight: Radius.circular(responsive.radius(16)),
                ),
                border:
                    const Border(top: BorderSide(color: AppColors.dangerBorder)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 14, color: AppColors.danger),
                  SizedBox(width: responsive.w(8)),
                  Expanded(
                      child: Text(
                    'Motif : ${reservation.cancelReason}',
                    style: AppTextStyles.caption(responsive)
                        .copyWith(color: AppColors.dangerDark),
                  )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoCell extends StatelessWidget {
  const _InfoCell(
      {required this.responsive,
      required this.icon,
      required this.label,
      required this.value});

  final AppResponsive responsive;
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: responsive.text(16), color: AppColors.textHint),
          SizedBox(height: responsive.h(4)),
          Text(label,
              style: AppTextStyles.caption(responsive)
                  .copyWith(color: AppColors.textHint, fontSize: 10)),
          SizedBox(height: responsive.h(2)),
          Text(value,
              style: AppTextStyles.caption(responsive)
                  .copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: responsive.h(40), color: AppColors.border);
  }
}

// ── Driver Card ────────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final SearchRide? ride;

  @override
  Widget build(BuildContext context) {
    final String driverName = ride?.driverName ?? 'Conducteur';
    final String driverInitials = ride?.driverInitials ?? '';
    final String driverRating = ride?.rating ?? '—';
    final String vehicleName = ride?.vehicle ?? '—';
    final String vehiclePlate = ride?.vehiclePlate ?? '';
    final String reviewCount = ride?.reviewCount ?? '0';

    return _SectionCard(
      responsive: responsive,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _LocalAvatar(
                  size: responsive.w(80),
                  label: driverName,
                  initials: driverInitials),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: responsive.w(20),
                  height: responsive.w(20),
                  decoration: ShapeDecoration(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Icon(Icons.verified_rounded,
                      size: responsive.text(12), color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(width: responsive.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(driverName,
                            style: AppTextStyles.h6(responsive))),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: responsive.w(8),
                          vertical: responsive.h(2)),
                      decoration: ShapeDecoration(
                        color: AppColors.primaryLight,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AppColors.border),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded,
                              size: responsive.text(12),
                              color: AppColors.primary),
                          SizedBox(width: responsive.w(4)),
                          Text(driverRating,
                              style: AppTextStyles.body(responsive)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.h(4)),
                Text(
                  '$reviewCount avis · Conducteur vérifié',
                  style: AppTextStyles.caption(responsive)
                      .copyWith(color: AppColors.textHint),
                ),
                SizedBox(height: responsive.h(8)),
                Wrap(
                  spacing: responsive.w(8),
                  runSpacing: responsive.h(8),
                  children: [
                    if (vehiclePlate.isNotEmpty)
                      _SmallChip(text: vehiclePlate, responsive: responsive),
                    if (vehicleName.isNotEmpty && vehicleName != '—')
                      _SmallChip(text: vehicleName, responsive: responsive),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.text, required this.responsive});

  final String text;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: responsive.w(12), vertical: responsive.h(6)),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Text(text,
          style: AppTextStyles.caption(responsive)
              .copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

// ── Metric Row ─────────────────────────────────────────────────────────────

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DetailReservationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rate = controller.acceptanceRate.value;
      final resp = controller.responseTime.value;
      final since = controller.memberSince.value;
      return Row(
        children: [
          Expanded(
              child: _MetricCard(
                  value: rate.isNotEmpty ? rate : '—',
                  label: "Taux d'acceptation",
                  responsive: responsive)),
          SizedBox(width: responsive.w(12)),
          Expanded(
              child: _MetricCard(
                  value: resp.isNotEmpty ? resp : '—',
                  label: 'Temps réponse',
                  responsive: responsive)),
          SizedBox(width: responsive.w(12)),
          Expanded(
              child: _MetricCard(
                  value: since.isNotEmpty ? since : '—',
                  label: 'Sur MINIZON',
                  responsive: responsive)),
        ],
      );
    });
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(
      {required this.value, required this.label, required this.responsive});

  final String value;
  final String label;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: responsive.h(12), horizontal: responsive.w(8)),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
      ),
      child: Column(
        children: [
          Text(value,
              textAlign: TextAlign.center,
              style: AppTextStyles.price(responsive)
                  .copyWith(fontSize: responsive.text(20))),
          SizedBox(height: responsive.h(4)),
          Text(label,
              textAlign: TextAlign.center,
              style: AppTextStyles.caption(responsive)),
        ],
      ),
    );
  }
}

// ── Vehicle Card ───────────────────────────────────────────────────────────

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final SearchRide? ride;

  @override
  Widget build(BuildContext context) {
    final String vehicle = ride?.vehicle ?? '—';
    final String vehiclePlate = ride?.vehiclePlate ?? '';

    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car_rounded, color: AppColors.primary),
              SizedBox(width: responsive.w(8)),
              Text(AppStrings.reservationVehicleTitle,
                  style: AppTextStyles.h6(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              Container(
                width: responsive.w(88),
                height: responsive.w(88),
                decoration: ShapeDecoration(
                  color: AppColors.surface,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(Icons.directions_car_filled_rounded,
                    color: AppColors.primary, size: 40),
              ),
              SizedBox(width: responsive.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle, style: AppTextStyles.h6(responsive)),
                    SizedBox(height: responsive.h(4)),
                    Text(AppStrings.reservationVehicleCondition,
                        style: AppTextStyles.body(responsive)
                            .copyWith(color: AppColors.textHint)),
                    SizedBox(height: responsive.h(10)),
                    Wrap(
                      spacing: responsive.w(8),
                      runSpacing: responsive.h(6),
                      children: [
                        if (vehiclePlate.isNotEmpty)
                          _SmallChip(
                              text: vehiclePlate, responsive: responsive),
                        _SmallChip(
                            text: AppStrings.reservationVehicleAttribute,
                            responsive: responsive),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Passenger Route Card ───────────────────────────────────────────────────

class _PassengerRouteCard extends StatelessWidget {
  const _PassengerRouteCard(
      {required this.responsive, required this.reservation});

  final AppResponsive responsive;
  final ReservationItem reservation;

  @override
  Widget build(BuildContext context) {
    final hasFullTrip = reservation.tripOrigin.isNotEmpty &&
        reservation.tripDestination.isNotEmpty;
    final pickupDiffersFromTrip = hasFullTrip &&
        reservation.displayPickupCity.toLowerCase() !=
            reservation.tripOrigin.toLowerCase();

    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place_rounded, color: AppColors.primary),
              SizedBox(width: responsive.w(8)),
              Text('Votre montée & descente',
                  style: AppTextStyles.h6(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          // Prise en charge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(children: [
                Container(
                  width: responsive.w(12),
                  height: responsive.w(12),
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                ),
                Container(
                    width: 2,
                    height: responsive.h(52),
                    color: AppColors.border),
              ]),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Prise en charge',
                        style: AppTextStyles.caption(responsive).copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: responsive.h(2)),
                    Text(reservation.displayPickupCity,
                        style: AppTextStyles.subtitle(responsive)),
                    if (reservation.displayPickupNote.isNotEmpty) ...[
                      SizedBox(height: responsive.h(2)),
                      Text(reservation.displayPickupNote,
                          style: AppTextStyles.caption(responsive)
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                    if (reservation.displayPickupAddress.isNotEmpty) ...[
                      SizedBox(height: responsive.h(2)),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: AppColors.textHint),
                        SizedBox(width: responsive.w(3)),
                        Flexible(
                            child: Text(
                          reservation.displayPickupAddress,
                          style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.textHint, fontSize: 11),
                        )),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Dépose
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: responsive.w(12),
                height: responsive.w(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.danger, width: 2),
                  color: Colors.white,
                ),
                child: Center(
                    child: Container(
                  width: responsive.w(5),
                  height: responsive.w(5),
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: AppColors.danger),
                )),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dépose',
                        style: AppTextStyles.caption(responsive).copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600)),
                    SizedBox(height: responsive.h(2)),
                    Text(reservation.displayDropoffCity,
                        style: AppTextStyles.subtitle(responsive)),
                    if (reservation.displayDropoffNote.isNotEmpty) ...[
                      SizedBox(height: responsive.h(2)),
                      Text(reservation.displayDropoffNote,
                          style: AppTextStyles.caption(responsive)
                              .copyWith(color: AppColors.textSecondary)),
                    ],
                    if (reservation.displayDropoffAddress.isNotEmpty) ...[
                      SizedBox(height: responsive.h(2)),
                      Row(children: [
                        const Icon(Icons.location_on_outlined,
                            size: 11, color: AppColors.textHint),
                        SizedBox(width: responsive.w(3)),
                        Flexible(
                            child: Text(
                          reservation.displayDropoffAddress,
                          style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.textHint, fontSize: 11),
                        )),
                      ]),
                    ],
                  ],
                ),
              ),
            ],
          ),
          // Contexte trajet complet du conducteur
          if (hasFullTrip) ...[
            SizedBox(height: responsive.h(12)),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(12), vertical: responsive.h(8)),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(responsive.radius(10)),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                const Icon(Icons.directions_car_outlined,
                    size: 13, color: AppColors.textHint),
                SizedBox(width: responsive.w(8)),
                Flexible(
                    child: Text(
                  pickupDiffersFromTrip
                      ? 'Trajet : ${reservation.tripOrigin} → ${reservation.tripDestination}'
                      : 'Trajet complet : ${reservation.tripOrigin} → ${reservation.tripDestination}',
                  style: AppTextStyles.caption(responsive)
                      .copyWith(color: AppColors.textSecondary),
                )),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Itinerary Card ─────────────────────────────────────────────────────────

class _ItineraryCard extends StatelessWidget {
  const _ItineraryCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final SearchRide? ride;

  @override
  Widget build(BuildContext context) {
    final String origin =
        (ride?.origin.isNotEmpty ?? false) ? ride!.origin : '—';
    final String destination =
        (ride?.destination.isNotEmpty ?? false) ? ride!.destination : '—';
    final String departureTime = ride?.departureTime ?? '';
    final String arrivalTime = ride?.arrivalTime ?? '';
    final String departureNote = ride?.departureNote ?? '';
    final String arrivalNote = ride?.arrivalNote ?? '';
    final String duration = ride?.duration ?? '';
    final String? waypoint =
        (ride?.waypointCity?.isNotEmpty ?? false) ? ride!.waypointCity : null;
    final String? waypointNote = ride?.waypointNote;

    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, color: AppColors.primary),
              SizedBox(width: responsive.w(8)),
              Text(AppStrings.reservationItineraryTitle,
                  style: AppTextStyles.h6(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          _JourneyStop(
            responsive: responsive,
            color: AppColors.primary,
            label: AppStrings.reservationJourneyDeparture,
            time: departureTime,
            title: origin,
            subtitle: departureNote,
            hasLine: true,
          ),
          if (waypoint != null) ...[
            SizedBox(height: responsive.h(12)),
            _JourneyStop(
              responsive: responsive,
              color: Colors.white,
              outlined: true,
              outlineColor: AppColors.warning,
              label: AppStrings.reservationJourneyStop,
              title: waypoint,
              subtitle: waypointNote ?? '',
              hasLine: true,
            ),
          ],
          SizedBox(height: responsive.h(12)),
          _JourneyStop(
            responsive: responsive,
            color: AppColors.danger,
            label: AppStrings.reservationJourneyArrival,
            time: arrivalTime,
            title: destination,
            subtitle: arrivalNote,
            hasLine: false,
          ),
          if (duration.isNotEmpty) ...[
            SizedBox(height: responsive.h(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Durée estimée',
                    style: AppTextStyles.body(responsive)
                        .copyWith(color: AppColors.textSecondary)),
                Row(children: [
                  const Icon(Icons.timelapse_rounded,
                      size: 16, color: AppColors.primary),
                  SizedBox(width: responsive.w(6)),
                  Text(duration,
                      style: AppTextStyles.subtitle(responsive)
                          .copyWith(color: AppColors.primary)),
                ]),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _JourneyStop extends StatelessWidget {
  const _JourneyStop({
    required this.responsive,
    required this.color,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.hasLine,
    this.time,
    this.outlined = false,
    this.outlineColor,
  });

  final AppResponsive responsive;
  final Color color;
  final String label;
  final String title;
  final String subtitle;
  final bool hasLine;
  final String? time;
  final bool outlined;
  final Color? outlineColor;

  @override
  Widget build(BuildContext context) {
    final borderColor = outlineColor ?? color;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: responsive.w(12),
              height: responsive.w(12),
              decoration: ShapeDecoration(
                color: outlined ? Colors.white : color,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                      color: outlined ? borderColor : AppColors.border,
                      width: outlined ? 2 : 1),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            if (hasLine)
              Container(
                  width: 2,
                  height: responsive.h(44),
                  color: AppColors.border),
          ],
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time != null && time!.isNotEmpty ? '$label · $time' : label,
                style: AppTextStyles.caption(responsive)
                    .copyWith(color: AppColors.textHint),
              ),
              SizedBox(height: responsive.h(2)),
              Text(title, style: AppTextStyles.subtitle(responsive)),
              if (subtitle.isNotEmpty) ...[
                SizedBox(height: responsive.h(2)),
                Text(subtitle,
                    style: AppTextStyles.body(responsive)
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ── Conditions Card ────────────────────────────────────────────────────────

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_rounded, color: AppColors.primary),
              SizedBox(width: responsive.w(8)),
              Text(AppStrings.reservationConditionsTitle,
                  style: AppTextStyles.h6(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          _ConditionRow(
              responsive: responsive,
              title: AppStrings.reservationAvailableSeats,
              subtitle: AppStrings.reservationFreeSeatsText),
          SizedBox(height: responsive.h(12)),
          _ConditionRow(
              responsive: responsive,
              title: AppStrings.reservationLuggage,
              subtitle: AppStrings.reservationLuggageText),
          SizedBox(height: responsive.h(12)),
          _ConditionRow(
              responsive: responsive,
              title: AppStrings.reservationNoSmoking,
              subtitle: AppStrings.reservationSmokingText),
          SizedBox(height: responsive.h(12)),
          _ConditionRow(
              responsive: responsive,
              title: AppStrings.reservationMood,
              subtitle: AppStrings.reservationMoodText),
        ],
      ),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow(
      {required this.responsive, required this.title, required this.subtitle});

  final AppResponsive responsive;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: responsive.w(32),
          height: responsive.w(32),
          decoration: ShapeDecoration(
            color: AppColors.primaryLight,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: Icon(Icons.check_rounded,
              size: responsive.text(18), color: AppColors.primary),
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.subtitle(responsive)),
              SizedBox(height: responsive.h(2)),
              Text(subtitle,
                  style: AppTextStyles.body(responsive)
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Price Card ─────────────────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DetailReservationController controller;

  String _fmt(int value) {
    final text = value
        .toString()
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
    return '$text FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = controller.existingReservation;
      final ride = controller.ride.value;

      int unitPrice, seatsCount, subtotal, serviceFee, total;
      bool isProrated = false;
      bool hasBreakdown = false;

      if (r != null) {
        seatsCount = r.seatsCount;
        final bd = r.priceBreakdown;
        if (bd != null && bd.calculatedPricePerSeat > 0) {
          // Utiliser les champs exacts de l'API
          unitPrice = bd.calculatedPricePerSeat;
          subtotal = bd.subtotal;
          serviceFee = bd.serviceFee;
          total = bd.total;
          isProrated = seatsCount > 1;
          hasBreakdown = true;
        } else if (r.totalPriceValue > 0) {
          unitPrice = r.totalPriceValue;
          subtotal = unitPrice * seatsCount;
          serviceFee = (subtotal * 0.05).round();
          total = subtotal + serviceFee;
          isProrated = seatsCount > 1;
          hasBreakdown = true;
        } else {
          unitPrice = 0;
          subtotal = 0;
          serviceFee = 0;
          total = 0;
          hasBreakdown = false;
        }
      } else {
        seatsCount = 1;
        unitPrice = ride?.priceValue ?? 0;
        subtotal = unitPrice;
        serviceFee = (unitPrice * 0.05).round();
        total = subtotal + serviceFee;
        hasBreakdown = unitPrice > 0;
      }

      return _SectionCard(
        responsive: responsive,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.payments_rounded, color: AppColors.primary),
                SizedBox(width: responsive.w(8)),
                Expanded(
                    child: Text(AppStrings.reservationPriceDetailsTitle,
                        style: AppTextStyles.h6(responsive))),
                if (isProrated)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: responsive.w(8), vertical: responsive.h(3)),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAccent,
                      borderRadius: BorderRadius.circular(9999),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.30)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_outline,
                          size: responsive.text(11), color: AppColors.primary),
                      SizedBox(width: responsive.w(4)),
                      Text('Au prorata',
                          style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11)),
                    ]),
                  ),
              ],
            ),
            SizedBox(height: responsive.h(16)),
            if (hasBreakdown) ...[
              _PriceLineRow(
                  responsive: responsive,
                  left: 'Prix par place',
                  right: _fmt(unitPrice)),
              SizedBox(height: responsive.h(8)),
              _PriceLineRow(
                  responsive: responsive,
                  left: 'Nombre de places',
                  right: '× $seatsCount'),
              SizedBox(height: responsive.h(8)),
              if (seatsCount > 1) ...[
                _PriceLineRow(
                    responsive: responsive,
                    left: 'Sous-total',
                    right: _fmt(subtotal)),
                SizedBox(height: responsive.h(8)),
              ],
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(12), vertical: responsive.h(8)),
                decoration: BoxDecoration(
                  color: AppColors.warningSurface,
                  borderRadius: BorderRadius.circular(responsive.radius(10)),
                  border: Border.all(color: AppColors.warningSurface),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 13, color: AppColors.warning),
                  SizedBox(width: responsive.w(8)),
                  Expanded(
                      child: Text(
                    'Frais de service MINIZON (5%) : ${_fmt(serviceFee)}',
                    style: AppTextStyles.caption(responsive)
                        .copyWith(color: AppColors.badgeSilver),
                  )),
                ]),
              ),
              SizedBox(height: responsive.h(12)),
              Container(height: 1, color: AppColors.border),
              SizedBox(height: responsive.h(12)),
            ],
            // Total
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(20), vertical: responsive.h(14)),
              decoration: ShapeDecoration(
                color: AppColors.primaryLight,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.reservationTotalToPay,
                            style: AppTextStyles.subtitle(responsive)),
                        if (r?.isPaid == true)
                          Text('Payé',
                              style: AppTextStyles.caption(responsive).copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600)),
                      ]),
                  Text(
                    hasBreakdown
                        ? _fmt(total)
                        : (r?.totalPrice ?? ride?.price ?? '—'),
                    style: AppTextStyles.price(responsive),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _PriceLineRow extends StatelessWidget {
  const _PriceLineRow(
      {required this.responsive, required this.left, required this.right});

  final AppResponsive responsive;
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
            child: Text(left,
                style: AppTextStyles.body(responsive)
                    .copyWith(color: AppColors.textSecondary))),
        Text(right,
            style: AppTextStyles.body(responsive)
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Reviews Card ───────────────────────────────────────────────────────────

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DetailReservationController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded,
                      color: AppColors.primary),
                  SizedBox(width: responsive.w(8)),
                  Text(AppStrings.reservationReviewsTitle,
                      style: AppTextStyles.h6(responsive)),
                ],
              ),
              TextButton(
                onPressed: controller.onViewAllReviews,
                child: Text(AppStrings.reservationViewAll,
                    style: AppTextStyles.body(responsive).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: responsive.h(12)),
          Obx(() {
            final reviews = controller.apiReviews;
            if (controller.isLoading.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: responsive.h(16)),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              );
            }
            if (reviews.isNotEmpty) {
              final shown = reviews.take(2).toList();
              return Column(
                children: shown
                    .asMap()
                    .entries
                    .map((e) => Column(
                          children: [
                            if (e.key > 0) SizedBox(height: responsive.h(14)),
                            _ReviewItem(
                              responsive: responsive,
                              name: e.value.reviewerName,
                              rating: e.value.rating.toStringAsFixed(1),
                              date: e.value.date,
                              body: e.value.comment,
                            ),
                          ],
                        ))
                    .toList(),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(vertical: responsive.h(8)),
              child: Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded,
                      size: responsive.text(16), color: AppColors.textHint),
                  SizedBox(width: responsive.w(8)),
                  Text(
                    'Aucun avis pour ce conducteur pour l\'instant.',
                    style: AppTextStyles.body(responsive)
                        .copyWith(color: AppColors.textHint),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem(
      {required this.responsive,
      required this.name,
      required this.rating,
      required this.date,
      required this.body});

  final AppResponsive responsive;
  final String name;
  final String rating;
  final String date;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _LocalAvatar(size: responsive.w(40), label: name, circle: true),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name,
                      style: AppTextStyles.body(responsive)
                          .copyWith(fontWeight: FontWeight.w600)),
                  Row(children: [
                    Icon(Icons.star_rounded,
                        size: responsive.text(14), color: AppColors.warning),
                    SizedBox(width: responsive.w(4)),
                    Text(rating,
                        style: AppTextStyles.body(responsive)
                            .copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ],
              ),
              SizedBox(height: responsive.h(4)),
              Text(date,
                  style: AppTextStyles.caption(responsive)
                      .copyWith(color: AppColors.textHint)),
              SizedBox(height: responsive.h(8)),
              Text(body,
                  style: AppTextStyles.body(responsive).copyWith(
                      color: AppColors.textSecondary, height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Existing Reservation Actions ───────────────────────────────────────────

class _ExistingReservationActions extends StatelessWidget {
  const _ExistingReservationActions(
      {required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DetailReservationController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.reservationStatus;
      return _buildContent(context, status);
    });
  }

  Widget _buildContent(BuildContext context, ReservationStatus? status) {
    if (status == ReservationStatus.pending) {
      return Column(children: [
        _StatusBanner(
          responsive: responsive,
          icon: Icons.hourglass_top_rounded,
          title: 'En attente de confirmation',
          message:
              'Le conducteur doit confirmer votre réservation avant que vous puissiez procéder au paiement.',
          bgColor: AppColors.warningSurface,
          borderColor: AppColors.warningSurface,
          iconColor: AppColors.warning,
          textColor: AppColors.badgeSilver,
        ),
        SizedBox(height: responsive.h(12)),
        Obx(() => AppPrimaryButton(
              responsive: responsive,
              label: controller.isContactingDriver.value
                  ? 'Connexion…'
                  : 'Contacter le conducteur',
              onTap: controller.isContactingDriver.value
                  ? () {}
                  : controller.contactDriver,
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              borderRadius: responsive.radius(16),
              height: responsive.h(54),
            )),
        SizedBox(height: responsive.h(10)),
        AppPrimaryButton(
          responsive: responsive,
          label: 'Annuler la réservation',
          onTap: controller.cancelReservation,
          backgroundColor: AppColors.dangerSurface,
          textColor: AppColors.danger,
          borderRadius: responsive.radius(16),
          height: responsive.h(54),
        ),
      ]);
    }

    if (status == ReservationStatus.confirmed) {
      return Obx(() {
        final isPaid = controller.isPaid;
        return Column(children: [
          _StatusBanner(
            responsive: responsive,
            icon: Icons.check_circle_rounded,
            title: isPaid
                ? 'Réservation confirmée et payée'
                : 'Confirmée — Paiement requis',
            message: isPaid
                ? 'Votre place est réservée. Préparez-vous pour votre trajet !'
                : "Le conducteur a accepté votre réservation. Procédez au paiement pour confirmer définitivement.",
            bgColor: AppColors.successSurface,
            borderColor: AppColors.successSurface,
            iconColor: AppColors.success,
            textColor: AppColors.success,
          ),
          SizedBox(height: responsive.h(12)),
          if (!isPaid) ...[
            AppPrimaryButton(
              responsive: responsive,
              label: 'Payer maintenant',
              onTap: controller.payNow,
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              borderRadius: responsive.radius(16),
              height: responsive.h(54),
            ),
            SizedBox(height: responsive.h(10)),
          ],
          Obx(() => AppPrimaryButton(
                responsive: responsive,
                label: controller.isContactingDriver.value
                    ? 'Connexion…'
                    : 'Contacter le conducteur',
                onTap: controller.isContactingDriver.value
                    ? () {}
                    : controller.contactDriver,
                backgroundColor: AppColors.surfaceMuted,
                textColor: AppColors.textPrimary,
                borderRadius: responsive.radius(16),
                height: responsive.h(54),
              )),
          if (!isPaid) ...[
            SizedBox(height: responsive.h(10)),
            AppPrimaryButton(
              responsive: responsive,
              label: 'Annuler la réservation',
              onTap: controller.cancelReservation,
              backgroundColor: AppColors.dangerSurface,
              textColor: AppColors.danger,
              borderRadius: responsive.radius(16),
              height: responsive.h(54),
            ),
          ],
        ]);
      });
    }

    if (status == ReservationStatus.inProgress) {
      return Column(children: [
        _StatusBanner(
          responsive: responsive,
          icon: Icons.directions_car_filled_rounded,
          title: 'Trajet en cours',
          message: 'Votre conducteur est en route. Profitez de votre trajet !',
          bgColor: AppColors.successSurface,
          borderColor: AppColors.successSurface,
          iconColor: AppColors.primary,
          textColor: AppColors.successDark,
        ),
        SizedBox(height: responsive.h(12)),
        Obx(() => AppPrimaryButton(
              responsive: responsive,
              label: controller.isContactingDriver.value
                  ? 'Connexion…'
                  : 'Contacter le conducteur',
              onTap: controller.isContactingDriver.value
                  ? () {}
                  : controller.contactDriver,
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              borderRadius: responsive.radius(16),
              height: responsive.h(54),
            )),
      ]);
    }

    if (status == ReservationStatus.completed) {
      return Column(children: [
        _StatusBanner(
          responsive: responsive,
          icon: Icons.task_alt_rounded,
          title: 'Trajet terminé',
          message:
              "Merci d'avoir voyagé avec MINIZON. N'oubliez pas d'évaluer votre conducteur !",
          bgColor: AppColors.surfaceMuted,
          borderColor: AppColors.border,
          iconColor: AppColors.textSecondary,
          textColor: AppColors.textSecondary,
        ),
        SizedBox(height: responsive.h(12)),
        Obx(() => AppPrimaryButton(
              responsive: responsive,
              label: controller.isContactingDriver.value
                  ? 'Connexion…'
                  : 'Contacter le conducteur',
              onTap: controller.isContactingDriver.value
                  ? () {}
                  : controller.contactDriver,
              backgroundColor: AppColors.surfaceMuted,
              textColor: AppColors.textPrimary,
              borderRadius: responsive.radius(16),
              height: responsive.h(54),
            )),
        SizedBox(height: responsive.h(10)),
        Obx(() => AppPrimaryButton(
              responsive: responsive,
              label: controller.isDownloadingInvoice.value
                  ? 'Génération…'
                  : 'Télécharger la facture',
              onTap: controller.isDownloadingInvoice.value
                  ? () {}
                  : controller.downloadInvoice,
              backgroundColor: AppColors.successSurface,
              textColor: AppColors.primary,
              borderRadius: responsive.radius(16),
              height: responsive.h(54),
            )),
      ]);
    }

    if (status == ReservationStatus.cancelled) {
      return _StatusBanner(
        responsive: responsive,
        icon: Icons.cancel_rounded,
        title: 'Réservation annulée',
        message:
            'Cette réservation a été annulée. Vous pouvez rechercher un autre trajet.',
        bgColor: AppColors.dangerSurface,
        borderColor: AppColors.dangerBorder,
        iconColor: AppColors.danger,
        textColor: AppColors.dangerDark,
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.responsive,
    required this.icon,
    required this.title,
    required this.message,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
  });

  final AppResponsive responsive;
  final IconData icon;
  final String title;
  final String message;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(14)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(responsive.radius(14)),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: responsive.text(18), color: iconColor),
          SizedBox(width: responsive.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.bodyMedium(responsive).copyWith(
                        fontWeight: FontWeight.w700, color: iconColor)),
                SizedBox(height: responsive.h(4)),
                Text(message,
                    style: AppTextStyles.bodySmall(responsive)
                        .copyWith(color: textColor, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Avatar ─────────────────────────────────────────────────────────────────

class _LocalAvatar extends StatelessWidget {
  const _LocalAvatar(
      {required this.size,
      required this.label,
      this.initials,
      this.circle = false});

  final double size;
  final String label;
  final String? initials;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final resolvedInitials =
        (initials != null && initials!.isNotEmpty) ? initials! : _initials(label);
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(circle ? 9999 : 16),
        ),
      ),
      child: Center(
        child: Text(
          resolvedInitials,
          style: TextStyle(
            color: AppColors.primary,
            fontSize: size * 0.34,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty) return 'M';
  final first = parts.first.isNotEmpty ? parts.first[0] : 'M';
  final second =
      parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
  return (first + second).toUpperCase();
}

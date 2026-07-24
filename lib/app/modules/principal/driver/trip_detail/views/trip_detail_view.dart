import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../../../../../data/models/driver/trip_model.dart';
import '../controllers/trip_detail_controller.dart';

class TripDetailView extends StatelessWidget {
  const TripDetailView({super.key});

  TripDetailController get _controller =>
      Get.isRegistered<TripDetailController>()
          ? Get.find<TripDetailController>()
          : Get.put(TripDetailController());

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final responsive = AppResponsive(context);
    final r = responsive;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        final _ = controller.tripVersion.value;
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final trip = controller.trip;
        final isActionable = trip.status == TripStatus.pending ||
            trip.status == TripStatus.active;
        return SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: r.maxContentWidth),
              child: Column(
                children: [
                  _Header(r: r, controller: controller),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                      ),
                      children: [
                        SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 20, desktop: 24)),
                        _StatusCard(r: r, trip: trip),
                        SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                        _RouteCard(r: r, trip: trip),
                        SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                        _PassengersCard(r: r, controller: controller),
                        SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                        _FinancesCard(r: r, trip: trip),
                        SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                        _StatsRow(r: r, trip: trip),
                        SizedBox(height: r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                        if (isActionable) ...[
                          _MapButton(r: r, controller: controller),
                          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                        ],
                        if (controller.canStart) ...[
                          _StartButton(r: r, controller: controller),
                          SizedBox(height: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
                        ],
                        if (controller.canCancel)
                          _CancelButton(r: r, controller: controller),
                        SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.r, required this.controller});
  final AppResponsive r;
  final TripDetailController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        vertical: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
      ),
      color: AppColors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              height: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(r.adaptive(phone: 10, smallPhone: 9, tablet: 12, desktop: 14)),
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Expanded(
            child: Text(
              'Détail du trajet',
              style: AppTextStyles.homeCardTitle(r).copyWith(
                color: AppColors.textPrimary,
                fontSize: r.adaptive(phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
              ),
            ),
          ),
          if (controller.canEdit)
            GestureDetector(
              onTap: controller.onEditTrip,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
                  vertical: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAccent,
                  borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.edit_rounded,
                      size: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
                      color: AppColors.primary,
                    ),
                    SizedBox(width: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                    Text(
                      'Modifier',
                      style: AppTextStyles.labelSmall(r).copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Status Card ─────────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.r, required this.trip});
  final AppResponsive r;
  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: trip.statusBackground,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: trip.statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14),
              vertical: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6),
            ),
            decoration: BoxDecoration(
              color: trip.statusColor,
              borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
            ),
            child: Text(
              trip.statusLabel,
              style: AppTextStyles.labelSmall(r).copyWith(
                color: trip.statusTextColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
          Text(
            trip.publishedAgo,
            style: AppTextStyles.bodySmall(r).copyWith(
              color: trip.statusColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Route Card ──────────────────────────────────────────────────────────────

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.r, required this.trip});
  final AppResponsive r;
  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RouteRow(
            r: r,
            icon: Icons.radio_button_checked_rounded,
            iconColor: AppColors.primary,
            label: 'Départ',
            value: trip.origin,
            time: trip.departureTime,
          ),
          Padding(
            padding: EdgeInsets.only(
              left: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12),
            ),
            child: Column(
              children: List.generate(
                3,
                (_) => Container(
                  width: 2,
                  height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
                  color: AppColors.border,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
              ),
            ),
          ),
          _RouteRow(
            r: r,
            icon: Icons.location_on_rounded,
            iconColor: const Color(0xFFEF4444),
            label: 'Arrivée',
            value: trip.destination,
            time: '~16:35',
          ),
          if (trip.vehicleLabel != null) ...[
            Divider(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28), color: AppColors.border),
            Row(
              children: [
                Icon(
                  Icons.directions_car_rounded,
                  size: r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20),
                  color: AppColors.textMuted,
                ),
                SizedBox(width: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
                Text(
                  trip.vehicleLabel!,
                  style: AppTextStyles.bodySmall(r).copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.r,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.time,
  });
  final AppResponsive r;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
          color: iconColor,
        ),
        SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall(r).copyWith(
                  color: AppColors.textHint,
                ),
              ),
              SizedBox(height: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4)),
              Text(
                value,
                style: AppTextStyles.bodyMedium(r).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14),
            vertical: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6),
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(r.adaptive(phone: 8, smallPhone: 7, tablet: 10, desktop: 12)),
          ),
          child: Text(
            time,
            style: AppTextStyles.bodySmall(r).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Passengers Card ──────────────────────────────────────────────────────────

class _PassengersCard extends StatelessWidget {
  const _PassengersCard({required this.r, required this.controller});
  final AppResponsive r;
  final TripDetailController controller;

  @override
  Widget build(BuildContext context) {
    final trip = controller.trip;
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Passagers',
                style: AppTextStyles.homeCardTitle(r).copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12),
                  vertical: r.adaptive(phone: 3, smallPhone: 2, tablet: 4, desktop: 5),
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceAccent,
                  borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                ),
                child: Text(
                  '${trip.bookedSeats}/${trip.totalSeats} places',
                  style: AppTextStyles.labelSmall(r).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          ...trip.passengers.map((p) => _PassengerRow(r: r, passenger: p, controller: controller)),
          ...List.generate(
            trip.availableSeats,
            (_) => _EmptySeatRow(r: r),
          ),
        ],
      ),
    );
  }
}

class _PassengerRow extends StatelessWidget {
  const _PassengerRow({
    required this.r,
    required this.passenger,
    required this.controller,
  });
  final AppResponsive r;
  final TripPassengerModel passenger;
  final TripDetailController controller;

  @override
  Widget build(BuildContext context) {
    final isPaid = passenger.paymentStatus == PassengerPaymentStatus.paid;
    return Padding(
      padding: EdgeInsets.only(bottom: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
      child: Row(
        children: [
          Container(
            width: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
            height: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
            decoration: BoxDecoration(
              color: AppColors.surfaceAccent,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              passenger.avatarInitial,
              style: AppTextStyles.bodyMedium(r).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      passenger.name,
                      style: AppTextStyles.bodyMedium(r).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (passenger.isVerified) ...[
                      SizedBox(width: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                      Icon(
                        Icons.verified_rounded,
                        size: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18),
                        color: AppColors.primary,
                      ),
                    ],
                  ],
                ),
                SizedBox(height: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4)),
                Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      size: r.adaptive(phone: 12, smallPhone: 11, tablet: 14, desktop: 16),
                      color: AppColors.accent,
                    ),
                    SizedBox(width: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4)),
                    Text(
                      '${passenger.rating} · ${passenger.tripsCount} trajets',
                      style: AppTextStyles.labelSmall(r).copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12),
                  vertical: r.adaptive(phone: 3, smallPhone: 2, tablet: 4, desktop: 5),
                ),
                decoration: BoxDecoration(
                  color: isPaid
                      ? AppColors.surfaceSuccess
                      : const Color(0x19F4B400),
                  borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                ),
                child: Text(
                  isPaid ? 'Payé ✓' : 'En attente',
                  style: AppTextStyles.labelSmall(r).copyWith(
                    color: isPaid
                        ? AppColors.success
                        : const Color(0xFFF4B400),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
              GestureDetector(
                onTap: () => controller.onContactPassenger(passenger),
                child: Icon(
                  Icons.phone_rounded,
                  size: r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20),
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySeatRow extends StatelessWidget {
  const _EmptySeatRow({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
      child: Row(
        children: [
          Container(
            width: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
            height: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
            ),
            child: Icon(
              Icons.person_add_outlined,
              size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
              color: AppColors.textGhost,
            ),
          ),
          SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
          Text(
            'Place disponible',
            style: AppTextStyles.bodySmall(r).copyWith(
              color: AppColors.textGhost,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Finances Card ────────────────────────────────────────────────────────────

class _FinancesCard extends StatelessWidget {
  const _FinancesCard({required this.r, required this.trip});
  final AppResponsive r;
  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Finances',
            style: AppTextStyles.homeCardTitle(r).copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          _FinRow(r: r, label: 'Montant total', value: '${trip.totalRevenue.toStringAsFixed(0)} FCFA', isTotal: false),
          SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
          _FinRow(
            r: r,
            label: 'Commission MINIZON (${trip.commissionRate}%)',
            value: '-${trip.commission.toStringAsFixed(0)} FCFA',
            isTotal: false,
            valueColor: const Color(0xFFE53935),
          ),
          Divider(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28), color: AppColors.border),
          _FinRow(r: r, label: 'Vos revenus nets', value: '${trip.netRevenue.toStringAsFixed(0)} FCFA', isTotal: true),
        ],
      ),
    );
  }
}

class _FinRow extends StatelessWidget {
  const _FinRow({
    required this.r,
    required this.label,
    required this.value,
    required this.isTotal,
    this.valueColor,
  });
  final AppResponsive r;
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: isTotal
                ? AppTextStyles.bodyMedium(r).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  )
                : AppTextStyles.bodySmall(r).copyWith(
                    color: AppColors.textMuted,
                  ),
          ),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.bodyMedium(r).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                )
              : AppTextStyles.bodySmall(r).copyWith(
                  color: valueColor ?? AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }
}

// ── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.r, required this.trip});
  final AppResponsive r;
  final TripModel trip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatChip(
            r: r,
            icon: Icons.straighten_rounded,
            value: '${trip.distanceKm} km',
            label: 'Distance',
            color: AppColors.info,
          ),
        ),
        SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
        Expanded(
          child: _StatChip(
            r: r,
            icon: Icons.timer_outlined,
            value: trip.durationLabel,
            label: 'Durée estimée',
            color: AppColors.accent,
          ),
        ),
        SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
        Expanded(
          child: _StatChip(
            r: r,
            icon: Icons.event_seat_rounded,
            value: '${trip.availableSeats} libre${trip.availableSeats > 1 ? 's' : ''}',
            label: 'Places dispo',
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.r,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final AppResponsive r;
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24), color: color),
          SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
          Text(
            value,
            style: AppTextStyles.bodySmall(r).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4)),
          Text(
            label,
            style: AppTextStyles.labelSmall(r).copyWith(
              color: AppColors.textGhost,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Buttons ──────────────────────────────────────────────────────────────────

class _MapButton extends StatelessWidget {
  const _MapButton({required this.r, required this.controller});
  final AppResponsive r;
  final TripDetailController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onViewMap,
      child: Container(
        height: r.adaptive(phone: 48, smallPhone: 44, tablet: 52, desktop: 56),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_rounded,
              size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
              color: AppColors.primary,
            ),
            SizedBox(width: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
            Text(
              'Voir sur la carte',
              style: AppTextStyles.bodyMedium(r).copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.r, required this.controller});
  final AppResponsive r;
  final TripDetailController controller;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      label: 'Démarrer le trajet',
      onPressed: controller.onStartTrip,
      icon: Icons.play_arrow_rounded,
    );
  }
}

class _CancelButton extends StatelessWidget {
  const _CancelButton({required this.r, required this.controller});
  final AppResponsive r;
  final TripDetailController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.onCancelTrip,
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14),
          ),
          child: Text(
            'Annuler ce trajet',
            style: AppTextStyles.bodySmall(r).copyWith(
              color: const Color(0xFFE53935),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

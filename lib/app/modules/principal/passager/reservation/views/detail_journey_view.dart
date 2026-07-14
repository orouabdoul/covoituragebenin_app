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
    final DetailReservationController controller = Get.find<DetailReservationController>();
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                responsive.adaptive(phone: 8, smallPhone: 8, tablet: 12, desktop: 16),
                responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
                responsive.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
              ),
              children: [
                _HeaderBar(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),
                Obx(() => _DriverCard(responsive: responsive, ride: controller.ride.value)),
                SizedBox(height: responsive.h(16)),
                _MetricRow(responsive: responsive),
                SizedBox(height: responsive.h(16)),
                Obx(() => _VehicleCard(responsive: responsive, ride: controller.ride.value)),
                SizedBox(height: responsive.h(16)),
                Obx(() => _ItineraryCard(responsive: responsive, ride: controller.ride.value)),
                SizedBox(height: responsive.h(16)),
                _ConditionsCard(responsive: responsive),
                SizedBox(height: responsive.h(16)),
                Obx(() => _PriceCard(responsive: responsive, ride: controller.ride.value)),
                SizedBox(height: responsive.h(16)),
                _ReviewsCard(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),
                Obx(() {
                  if (controller.isExistingReservation.value) {
                    return _ExistingReservationActions(responsive: responsive, controller: controller);
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
                          style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
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

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DetailReservationController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 18)),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: Icons.chevron_left_rounded, onTap: Get.back),
          const Spacer(),
          Text(AppStrings.reservationDetailTitle, style: AppTextStyles.title(responsive)),
          const Spacer(),
          Obx(
            () => _CircleIconButton(
              icon: controller.isFavorite.value ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              iconColor: controller.isFavorite.value ? AppColors.primary : AppColors.textPrimary,
              onTap: controller.toggleFavorite,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap, this.iconColor});

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
            color: const Color(0xFFF5F5F5),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: Icon(icon, size: responsive.text(22), color: iconColor ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.responsive, required this.child});

  final AppResponsive responsive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20)),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: child,
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final SearchRide? ride;

  @override
  Widget build(BuildContext context) {
    final String driverName = ride?.driverName ?? AppStrings.reservationSampleDriver;
    final String driverRating = ride?.rating ?? AppStrings.passengerProfileRating;
    final String vehicleName = ride?.vehicle ?? AppStrings.reservationSampleVehicle;

    return _SectionCard(
      responsive: responsive,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _LocalAvatar(size: responsive.w(80), label: driverName),
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  width: responsive.w(20),
                  height: responsive.w(20),
                  decoration: ShapeDecoration(
                    color: const Color(0xFF00A86B),
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(color: AppColors.border),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Icon(Icons.verified_rounded, size: responsive.text(12), color: Colors.white),
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
                    Expanded(child: Text(driverName, style: AppTextStyles.h6(responsive))),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(2)),
                      decoration: ShapeDecoration(
                        color: const Color(0x1900A86B),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: AppColors.border),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.primary),
                          SizedBox(width: responsive.w(4)),
                          Text(driverRating, style: AppTextStyles.body(responsive)),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.h(6)),
                Text(AppStrings.reservationVerifiedLicense, style: AppTextStyles.caption(responsive)),
                SizedBox(height: responsive.h(4)),
                Text(AppStrings.reservationQuickReply, style: AppTextStyles.caption(responsive)),
                SizedBox(height: responsive.h(8)),
                Wrap(
                  spacing: responsive.w(8),
                  runSpacing: responsive.h(8),
                  children: [
                    _SmallChip(text: AppStrings.reservationSamplePlate, responsive: responsive),
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
      padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(6)),
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: Text(text, style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MetricCard(value: '98%', label: 'Taux d\'acceptation', responsive: responsive)),
        SizedBox(width: responsive.w(12)),
        Expanded(child: _MetricCard(value: '5 min', label: 'Temps réponse', responsive: responsive)),
        SizedBox(width: responsive.w(12)),
        Expanded(child: _MetricCard(value: '3 ans', label: 'Sur MINIZON', responsive: responsive)),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.value, required this.label, required this.responsive});

  final String value;
  final String label;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: responsive.h(12), horizontal: responsive.w(8)),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
      ),
      child: Column(
        children: [
          Text(value, textAlign: TextAlign.center, style: AppTextStyles.price(responsive).copyWith(fontSize: responsive.text(22))),
          SizedBox(height: responsive.h(4)),
          Text(label, textAlign: TextAlign.center, style: AppTextStyles.caption(responsive)),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final SearchRide? ride;

  @override
  Widget build(BuildContext context) {
    final String vehicle = ride?.vehicle ?? AppStrings.reservationSampleVehicle;

    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car_rounded, color: AppColors.primary),
              SizedBox(width: responsive.w(8)),
              Text(AppStrings.reservationVehicleTitle, style: AppTextStyles.h6(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              Container(
                width: responsive.w(96),
                height: responsive.w(96),
                decoration: ShapeDecoration(
                  color: const Color(0xFFF5F5F5),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Icon(Icons.directions_car_filled_rounded, color: AppColors.primary),
              ),
              SizedBox(width: responsive.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vehicle, style: AppTextStyles.h6(responsive)),
                    SizedBox(height: responsive.h(6)),
                    Text(AppStrings.reservationVehicleCondition, style: AppTextStyles.body(responsive)),
                    SizedBox(height: responsive.h(8)),
                    Wrap(
                      spacing: responsive.w(8),
                      runSpacing: responsive.h(8),
                      children: [
                        _SmallChip(text: AppStrings.reservationSamplePlate, responsive: responsive),
                        _SmallChip(text: AppStrings.reservationVehicleAttribute, responsive: responsive),
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

class _ItineraryCard extends StatelessWidget {
  const _ItineraryCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final SearchRide? ride;

  @override
  Widget build(BuildContext context) {
    final String origin = ride?.origin ?? 'Cotonou';
    final String destination = ride?.destination ?? 'Abomey-Calavi';
    final String departureTime = ride?.departureTime ?? '08:00';
    final String arrivalTime = ride?.arrivalTime ?? '09:30';
    final String departureNote = ride?.departureNote ?? 'Carrefour Vêdoko';
    final String arrivalNote = ride?.arrivalNote ?? 'Université d\'Abomey-Calavi';
    final String duration = ride?.duration ?? '1h 30min';

    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.route_rounded, color: AppColors.primary),
              SizedBox(width: responsive.w(8)),
              Text(AppStrings.reservationItineraryTitle, style: AppTextStyles.h6(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          _JourneyStop(
            responsive: responsive,
            color: const Color(0xFF00A86B),
            label: AppStrings.reservationJourneyDeparture,
            time: departureTime,
            title: origin,
            subtitle: departureNote,
          ),
          SizedBox(height: responsive.h(12)),
          _JourneyStop(
            responsive: responsive,
            color: Colors.white,
            outlined: true,
            label: AppStrings.reservationJourneyStop,
            title: 'Calavi',
            subtitle: 'Carrefour PK14',
          ),
          SizedBox(height: responsive.h(12)),
          _JourneyStop(
            responsive: responsive,
            color: const Color(0xFFE53935),
            label: AppStrings.reservationJourneyArrival,
            time: arrivalTime,
            title: destination,
            subtitle: arrivalNote,
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.reservationDistanceLabel, style: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600)),
              Text(duration, style: AppTextStyles.h6(responsive)),
            ],
          ),
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
    this.time,
    this.outlined = false,
  });

  final AppResponsive responsive;
  final Color color;
  final String label;
  final String title;
  final String subtitle;
  final String? time;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
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
                  side: BorderSide(color: outlined ? color : AppColors.border, width: outlined ? 2 : 1),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            Container(width: 2, height: responsive.h(36), color: AppColors.border),
          ],
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time == null ? label : '$label • $time', style: AppTextStyles.caption(responsive)),
              SizedBox(height: responsive.h(2)),
              Text(title, style: AppTextStyles.subtitle(responsive)),
              SizedBox(height: responsive.h(2)),
              Text(subtitle, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

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
              Text(AppStrings.reservationConditionsTitle, style: AppTextStyles.h6(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          _ConditionRow(responsive: responsive, title: AppStrings.reservationAvailableSeats, subtitle: AppStrings.reservationFreeSeatsText),
          SizedBox(height: responsive.h(12)),
          _ConditionRow(responsive: responsive, title: AppStrings.reservationLuggage, subtitle: AppStrings.reservationLuggageText),
          SizedBox(height: responsive.h(12)),
          _ConditionRow(responsive: responsive, title: AppStrings.reservationNoSmoking, subtitle: AppStrings.reservationSmokingText),
          SizedBox(height: responsive.h(12)),
          _ConditionRow(responsive: responsive, title: AppStrings.reservationMood, subtitle: AppStrings.reservationMoodText),
        ],
      ),
    );
  }
}

class _ConditionRow extends StatelessWidget {
  const _ConditionRow({required this.responsive, required this.title, required this.subtitle});

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
            color: const Color(0x1900A86B),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: Icon(Icons.check_rounded, size: responsive.text(18), color: AppColors.primary),
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.subtitle(responsive)),
              SizedBox(height: responsive.h(2)),
              Text(subtitle, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({required this.responsive, required this.ride});

  final AppResponsive responsive;
  final SearchRide? ride;

  int _extractPrice(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 2500;
  }

  String _formatPrice(int value) {
    final text = value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
    return '$text FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final int basePrice = _extractPrice(ride?.price ?? '2,500 F');
    final int serviceFee = (basePrice * 0.05).round();
    final int total = basePrice + serviceFee;

    return _SectionCard(
      responsive: responsive,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payments_rounded, color: AppColors.primary),
              SizedBox(width: responsive.w(8)),
              Text(AppStrings.reservationPriceDetailsTitle, style: AppTextStyles.h6(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(12)),
          _PriceLine(left: AppStrings.reservationPriceLabel, right: _formatPrice(basePrice), responsive: responsive),
          SizedBox(height: responsive.h(10)),
          _PriceLine(left: AppStrings.reservationPerSeat, right: '1', responsive: responsive),
          SizedBox(height: responsive.h(12)),
          Container(height: 1, color: const Color(0xFFF3F4F6)),
          SizedBox(height: responsive.h(12)),
          _PriceLine(left: AppStrings.reservationServiceFee, right: _formatPrice(serviceFee), responsive: responsive),
          SizedBox(height: responsive.h(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: responsive.w(20), vertical: responsive.h(12)),
            decoration: ShapeDecoration(
              color: const Color(0x0C00A86B),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.reservationTotalToPay, style: AppTextStyles.subtitle(responsive)),
                Text(_formatPrice(total), style: AppTextStyles.price(responsive)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.left, required this.right, required this.responsive});

  final String left;
  final String right;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(left, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary))),
        Text(right, style: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

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
                  const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.primary),
                  SizedBox(width: responsive.w(8)),
                  Text(AppStrings.reservationReviewsTitle, style: AppTextStyles.h6(responsive)),
                ],
              ),
              TextButton(
                onPressed: controller.onViewAllReviews,
                child: Text(AppStrings.reservationViewAll, style: AppTextStyles.body(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          SizedBox(height: responsive.h(12)),
          _ReviewItem(
            responsive: responsive,
            name: 'Marie Kouadio',
            rating: '5.0',
            date: 'Il y a 2 jours',
            body: AppStrings.reservationSampleReview,
          ),
          SizedBox(height: responsive.h(16)),
          _ReviewItem(
            responsive: responsive,
            name: 'Jean Akakpo',
            rating: '4.8',
            date: 'Il y a 1 semaine',
            body: 'Excellent trajet, bonne conduite et respect des horaires.',
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem({required this.responsive, required this.name, required this.rating, required this.date, required this.body});

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
                  Text(name, style: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600)),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: responsive.text(14), color: AppColors.warning),
                      SizedBox(width: responsive.w(4)),
                      Text(rating, style: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: responsive.h(4)),
              Text(date, style: AppTextStyles.caption(responsive)),
              SizedBox(height: responsive.h(8)),
              Text(body, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary, height: 1.6)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Boutons selon statut de réservation existante ─────────────────────────

class _ExistingReservationActions extends StatelessWidget {
  const _ExistingReservationActions({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DetailReservationController controller;

  @override
  Widget build(BuildContext context) {
    final status = controller.reservationStatus;

    if (status == ReservationStatus.pending) {
      return Column(
        children: [
          // Bandeau info attente
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.w(14)),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(responsive.radius(14)),
              border: Border.all(color: const Color(0xFFFFE082)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.hourglass_top_rounded,
                    size: responsive.text(18), color: const Color(0xFFFFA000)),
                SizedBox(width: responsive.w(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'En attente de confirmation',
                        style: AppTextStyles.bodyMedium(responsive).copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFF57F17),
                        ),
                      ),
                      SizedBox(height: responsive.h(4)),
                      Text(
                        'Le conducteur doit confirmer votre réservation avant que vous puissiez procéder au paiement.',
                        style: AppTextStyles.bodySmall(responsive).copyWith(
                          color: const Color(0xFF795548),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.h(12)),
          Obx(() => AppPrimaryButton(
            responsive: responsive,
            label: controller.isContactingDriver.value ? 'Connexion…' : 'Contacter le conducteur',
            onTap: controller.isContactingDriver.value ? () {} : controller.contactDriver,
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            borderRadius: responsive.radius(16),
            height: responsive.h(56),
          )),
          SizedBox(height: responsive.h(12)),
          AppPrimaryButton(
            responsive: responsive,
            label: 'Annuler la réservation',
            onTap: controller.cancelReservation,
            backgroundColor: const Color(0xFFFEF2F2),
            textColor: const Color(0xFFEF4444),
            borderRadius: responsive.radius(16),
            height: responsive.h(56),
          ),
        ],
      );
    }

    if (status == ReservationStatus.confirmed) {
      final isPaid = controller.isPaid;
      return Column(
        children: [
          // Bandeau info confirmé
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.w(14)),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8F1),
              borderRadius: BorderRadius.circular(responsive.radius(14)),
              border: Border.all(color: const Color(0xFFC8E6C9)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded,
                    size: responsive.text(18), color: const Color(0xFF43A047)),
                SizedBox(width: responsive.w(10)),
                Expanded(
                  child: Text(
                    isPaid
                        ? 'Réservation confirmée et payée. Votre place est réservée.'
                        : 'Réservation confirmée par le conducteur. Vous pouvez maintenant procéder au paiement.',
                    style: AppTextStyles.bodySmall(responsive).copyWith(
                      color: const Color(0xFF2E7D32),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.h(12)),
          if (!isPaid)
            AppPrimaryButton(
              responsive: responsive,
              label: 'Payer maintenant',
              onTap: controller.payNow,
              backgroundColor: AppColors.primary,
              textColor: AppColors.white,
              borderRadius: responsive.radius(16),
              height: responsive.h(56),
            ),
          if (!isPaid) SizedBox(height: responsive.h(12)),
          Obx(() => AppPrimaryButton(
            responsive: responsive,
            label: controller.isContactingDriver.value ? 'Connexion…' : 'Contacter le conducteur',
            onTap: controller.isContactingDriver.value ? () {} : controller.contactDriver,
            backgroundColor: AppColors.surfaceMuted,
            textColor: AppColors.textPrimary,
            borderRadius: responsive.radius(16),
            height: responsive.h(56),
          )),
        ],
      );
    }

    // completed, cancelled, inProgress → pas d'action
    return const SizedBox.shrink();
  }
}

class _LocalAvatar extends StatelessWidget {
  const _LocalAvatar({required this.size, required this.label, this.circle = false});

  final double size;
  final String label;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final initials = _initials(label);
    return Container(
      width: size,
      height: size,
      decoration: ShapeDecoration(
        color: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(circle ? 9999 : 16),
        ),
      ),
      child: Center(
        child: Text(
          initials,
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
  if (parts.isEmpty) {
    return 'M';
  }

  final first = parts.first.isNotEmpty ? parts.first[0] : 'M';
  final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
  return (first + second).toUpperCase();
}
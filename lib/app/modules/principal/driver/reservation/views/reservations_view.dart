import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/reservations_controller.dart';

class ReservationsView extends GetView<ReservationsController> {
  const ReservationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                responsive.adaptive(
                  phone: 16,
                  smallPhone: 14,
                  tablet: 20,
                  desktop: 24,
                ),
                responsive.adaptive(
                  phone: 12,
                  smallPhone: 10,
                  tablet: 14,
                  desktop: 16,
                ),
                responsive.adaptive(
                  phone: 16,
                  smallPhone: 14,
                  tablet: 20,
                  desktop: 24,
                ),
                responsive.adaptive(
                  phone: 24,
                  smallPhone: 20,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
              children: [
                _TopCard(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(12)),
                _FilterTabs(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),
                ...controller.visibleReservations.asMap().entries.expand((
                  entry,
                ) {
                  final index = entry.key;
                  final reservation = entry.value;

                  return [
                    _ReservationCard(
                      responsive: responsive,
                      reservation: reservation,
                      onReject: () =>
                          controller.onRejectReservation(reservation),
                      onDetails: () =>
                          controller.onShowReservation(reservation),
                      onAccept: () =>
                          controller.onAcceptReservation(reservation),
                    ),
                    if (index != controller.visibleReservations.length - 1)
                      SizedBox(height: responsive.h(16)),
                  ];
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final ReservationsController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.adaptive(
          phone: 16,
          smallPhone: 14,
          tablet: 18,
          desktop: 20,
        ),
        vertical: responsive.adaptive(
          phone: 12,
          smallPhone: 12,
          tablet: 14,
          desktop: 16,
        ),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.surfaceSoft),
          borderRadius: BorderRadius.circular(responsive.radius(20)),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          AppCircularButton(
            responsive: responsive,
            icon: Icons.arrow_back_rounded,
            onTap: controller.onBack,
            size: responsive.w(40),
          ),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Column(
              children: [
                Text(
                  AppStrings.driverReservationsTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.profileSectionTitle(
                    responsive,
                  ).copyWith(fontSize: responsive.text(18)),
                ),
                SizedBox(height: responsive.h(2)),
                Text(
                  AppStrings.driverReservationsSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(responsive),
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.w(12)),
          Stack(
            clipBehavior: Clip.none,
            children: [
              AppCircularButton(
                responsive: responsive,
                icon: Icons.notifications_none_rounded,
                onTap: controller.onNotificationTap,
                size: responsive.w(40),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: responsive.w(20),
                  height: responsive.w(20),
                  decoration: ShapeDecoration(
                    color: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '3',
                      style: AppTextStyles.caption(responsive).copyWith(
                        color: AppColors.white,
                        fontSize: responsive.text(11),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final ReservationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.all(
          responsive.adaptive(
            phone: 16,
            smallPhone: 14,
            tablet: 16,
            desktop: 16,
          ),
        ),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.surfaceSoft),
            borderRadius: BorderRadius.circular(responsive.radius(20)),
          ),
        ),
        child: Row(
          children: [
            for (var index = 0; index < controller.filters.length; index++) ...[
              if (index == 0)
                SizedBox(
                  width: responsive.w(92),
                  child: _FilterChip(
                    responsive: responsive,
                    summary: controller.filters[index],
                    selected: controller.selectedFilterIndex.value == index,
                    onTap: () => controller.selectFilter(index),
                  ),
                )
              else if (index == 1)
                SizedBox(
                  width: responsive.w(117),
                  child: Padding(
                    padding: EdgeInsets.only(left: responsive.w(8)),
                    child: _FilterChip(
                      responsive: responsive,
                      summary: controller.filters[index],
                      selected: controller.selectedFilterIndex.value == index,
                      onTap: () => controller.selectFilter(index),
                    ),
                  ),
                )
              else
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: responsive.w(8)),
                    child: _FilterChip(
                      responsive: responsive,
                      summary: controller.filters[index],
                      selected: controller.selectedFilterIndex.value == index,
                      onTap: () => controller.selectFilter(index),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.responsive,
    required this.summary,
    required this.selected,
    required this.onTap,
  });

  final AppResponsive responsive;
  final ReservationFilterSummary summary;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = selected
        ? AppColors.primary
        : AppColors.surfaceMuted;
    final Color textColor = selected
        ? AppColors.white
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          height: responsive.adaptive(
            phone: 36,
            smallPhone: 34,
            tablet: 36,
            desktop: 36,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16),
            vertical: responsive.h(8),
          ),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: AppColors.border),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: Center(
            child: Text(
              '${summary.label} (${summary.count})',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.profileSectionLabel(
                responsive,
              ).copyWith(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.responsive,
    required this.reservation,
    required this.onReject,
    required this.onDetails,
    required this.onAccept,
  });

  final AppResponsive responsive;
  final DriverReservationRequest reservation;
  final VoidCallback onReject;
  final VoidCallback onDetails;
  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20),
      ),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.surfaceSoft),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 4,
            decoration: ShapeDecoration(
              color: reservation.passengerTypeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                    child: Image.network(
                      reservation.avatarUrl,
                      width: responsive.w(56),
                      height: responsive.w(56),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: responsive.w(56),
                        height: responsive.w(56),
                        color: AppColors.surfaceMuted,
                        child: Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.textGhost,
                          size: responsive.text(24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: responsive.w(18),
                      height: responsive.w(18),
                      padding: EdgeInsets.all(responsive.w(3)),
                      decoration: ShapeDecoration(
                        color: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                          side: const BorderSide(color: AppColors.white),
                        ),
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        size: 10,
                        color: AppColors.white,
                      ),
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
                          child: Text(
                            reservation.passengerName,
                            style: AppTextStyles.h6(responsive),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(8),
                            vertical: responsive.h(4),
                          ),
                          decoration: ShapeDecoration(
                            color: reservation.passengerTypeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          child: Text(
                            reservation.passengerType,
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.h(8)),
                    Row(
                      children: [
                        Container(
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                              side: const BorderSide(color: AppColors.border),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: responsive.text(14),
                                color: AppColors.warning,
                              ),
                              SizedBox(width: responsive.w(4)),
                              Text(
                                reservation.rating,
                                style: AppTextStyles.caption(responsive),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: responsive.w(8)),
                        Text('•', style: AppTextStyles.caption(responsive)),
                        SizedBox(width: responsive.w(8)),
                        Text(
                          reservation.tripsCount,
                          style: AppTextStyles.caption(responsive),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.w(12)),
            decoration: ShapeDecoration(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reservation.seatsRequested,
                      style: AppTextStyles.profileSectionLabel(responsive)
                          .copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    Text(
                      reservation.price,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.profileSectionLabel(responsive)
                          .copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: responsive.h(10)),
                Row(
                  children: [
                    Container(
                      width: responsive.w(14),
                      height: responsive.w(14),
                      decoration: ShapeDecoration(
                        color: AppColors.surfaceSoft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    SizedBox(width: responsive.w(6)),
                    Expanded(
                      child: Text(
                        reservation.paymentLabel,
                        style: AppTextStyles.caption(responsive),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.h(16)),
          Text(
            reservation.routeLabel,
            style: AppTextStyles.profileSectionLabel(responsive).copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: responsive.h(12)),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  responsive: responsive,
                  label: reservation.secondaryActionLabel,
                  backgroundColor: const Color(0xFFE53935),
                  textColor: AppColors.white,
                  onTap: onReject,
                ),
              ),
              SizedBox(width: responsive.w(8)),
              _IconActionButton(
                responsive: responsive,
                icon: Icons.chat_bubble_outline_rounded,
                backgroundColor: AppColors.surfaceMuted,
                iconColor: AppColors.textSecondary,
                onTap: onDetails,
              ),
              SizedBox(width: responsive.w(8)),
              Expanded(
                child: _ActionButton(
                  responsive: responsive,
                  label: reservation.primaryActionLabel,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  onTap: onAccept,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.responsive,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  final AppResponsive responsive;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        child: Container(
          height: responsive.adaptive(
            phone: 44,
            smallPhone: 42,
            tablet: 44,
            desktop: 44,
          ),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.profileSectionLabel(
                responsive,
              ).copyWith(color: textColor, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.responsive,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
    required this.onTap,
  });

  final AppResponsive responsive;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(14)),
        child: Container(
          width: responsive.w(48),
          height: responsive.w(44),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(14)),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: Icon(icon, color: iconColor, size: responsive.text(18)),
        ),
      ),
    );
  }
}

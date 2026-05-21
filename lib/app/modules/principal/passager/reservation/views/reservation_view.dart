import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/reservation_controller.dart';

class ReservationView extends StatelessWidget {
  const ReservationView({super.key});

  @override
  Widget build(BuildContext context) {
    final ReservationController controller = Get.isRegistered<ReservationController>()
        ? Get.find<ReservationController>()
        : Get.put(ReservationController());
    final responsive = AppResponsive(context);
    final double pagePadding = responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                pagePadding,
                responsive.adaptive(phone: 8, smallPhone: 8, tablet: 12, desktop: 16),
                pagePadding,
                responsive.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
              ),
              children: [
                _TopCard(responsive: responsive),
                SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                _StatusTabs(responsive: responsive, controller: controller),
                SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24)),
                for (var index = 0; index < controller.reservations.length; index++) ...[
                  _ReservationCard(
                    responsive: responsive,
                    reservation: controller.reservations[index],
                    onCancel: controller.cancelReservation,
                    onContact: controller.contactDriver,
                  ),
                  if (index != controller.reservations.length - 1)
                    SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopCard extends StatelessWidget {
  const _TopCard({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              AppStrings.reservationTitle,
              style: AppTextStyles.rolesCardTitle(responsive),
            ),
          ),
          Container(
            decoration: ShapeDecoration(
              color: AppColors.surfaceSoft,
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: AppColors.border),
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
            ),
            child: Icon(Icons.tune_rounded, size: responsive.text(18), color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StatusTabs extends StatelessWidget {
  const _StatusTabs({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final ReservationController controller;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: List.generate(controller.statusTabs.length, (index) {
          final tab = controller.statusTabs[index];
          final bool selected = controller.selectedStatusIndex.value == index;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == controller.statusTabs.length - 1 ? 0 : responsive.w(4)),
              child: GestureDetector(
                onTap: () => controller.selectStatus(index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(8)),
                  decoration: ShapeDecoration(
                    color: selected ? AppColors.white : const Color(0xFFF5F5F5),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: selected ? AppColors.border : AppColors.border),
                      borderRadius: BorderRadius.circular(responsive.radius(8)),
                    ),
                    shadows: selected
                        ? const [
                            BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
                          ]
                        : const [],
                  ),
                  child: Center(
                    child: Text(
                      tab.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      style: AppTextStyles.bottomNavLabel(
                        responsive,
                        color: selected ? const Color(0xFF00A86B) : const Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.responsive,
    required this.reservation,
    required this.onCancel,
    required this.onContact,
  });

  final AppResponsive responsive;
  final ReservationItem reservation;
  final ValueChanged<ReservationItem> onCancel;
  final ValueChanged<ReservationItem> onContact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _DriverAvatar(responsive: responsive),
                  SizedBox(width: responsive.w(12)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reservation.driverName, style: AppTextStyles.h6(responsive)),
                      SizedBox(height: responsive.h(2)),
                      Row(
                        children: [
                          Icon(Icons.star_rounded, size: responsive.text(14), color: AppColors.warning),
                          SizedBox(width: responsive.w(4)),
                          Text(reservation.rating, style: AppTextStyles.caption(responsive)),
                          SizedBox(width: responsive.w(6)),
                          Text('•', style: AppTextStyles.caption(responsive)),
                          SizedBox(width: responsive.w(6)),
                          Text(reservation.vehicle, style: AppTextStyles.caption(responsive)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(reservation.price, style: AppTextStyles.h6(responsive)),
                  Text(AppStrings.reservationPerSeat, style: AppTextStyles.caption(responsive)),
                ],
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          _RouteBlock(responsive: responsive, reservation: reservation),
          SizedBox(height: responsive.h(16)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _Dot(color: const Color(0xFFF4B400), responsive: responsive),
                  SizedBox(width: responsive.w(8)),
                  Text(
                    reservation.statusLabel,
                    style: AppTextStyles.caption(responsive).copyWith(
                      color: const Color(0xFFF4B400),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(reservation.statusNote, style: AppTextStyles.caption(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(14)),
          Row(
            children: [
              Expanded(
                child: AppPrimaryButton(
                  responsive: responsive,
                  label: AppStrings.reservationCancel,
                  onTap: () => onCancel(reservation),
                  backgroundColor: const Color(0xFFF5F5F5),
                  textColor: const Color(0xFF374151),
                  borderColor: AppColors.border,
                  borderRadius: responsive.radius(12),
                  height: responsive.h(44),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: AppPrimaryButton(
                  responsive: responsive,
                  label: AppStrings.reservationContact,
                  onTap: () => onContact(reservation),
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.white,
                  borderRadius: responsive.radius(12),
                  height: responsive.h(44),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsive.w(48),
      height: responsive.w(48),
      decoration: ShapeDecoration(
        color: AppColors.surfaceAccent,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, color: AppColors.primary),
      ),
    );
  }
}

class _RouteBlock extends StatelessWidget {
  const _RouteBlock({required this.responsive, required this.reservation});

  final AppResponsive responsive;
  final ReservationItem reservation;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _Dot(color: const Color(0xFF00A86B), responsive: responsive),
            Container(width: 2, height: responsive.h(32), color: AppColors.border),
            _Dot(color: const Color(0xFFF4B400), responsive: responsive),
          ],
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PlaceLine(title: reservation.departureCity, subtitle: reservation.departureNote, responsive: responsive),
              SizedBox(height: responsive.h(18)),
              _PlaceLine(title: reservation.arrivalCity, subtitle: reservation.arrivalNote, responsive: responsive),
            ],
          ),
        ),
        SizedBox(width: responsive.w(12)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(reservation.departureTime, style: AppTextStyles.caption(responsive)),
            SizedBox(height: responsive.h(8)),
            Text(reservation.seatsLabel, textAlign: TextAlign.right, style: AppTextStyles.caption(responsive)),
          ],
        ),
      ],
    );
  }
}

class _PlaceLine extends StatelessWidget {
  const _PlaceLine({required this.title, required this.subtitle, required this.responsive});

  final String title;
  final String subtitle;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h6(responsive)),
        SizedBox(height: responsive.h(2)),
        Text(subtitle, style: AppTextStyles.caption(responsive)),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.responsive});

  final Color color;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: responsive.w(12),
      height: responsive.w(12),
      decoration: ShapeDecoration(
        color: color,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.border),
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }
}
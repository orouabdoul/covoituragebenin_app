import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/end_trip_summary_model.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/end_trip_controller.dart';

class EndTripView extends StatelessWidget {
  const EndTripView({super.key});

  EndTripController get _controller =>
      Get.isRegistered<EndTripController>()
          ? Get.find<EndTripController>()
          : Get.put(EndTripController());

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: r.maxContentWidth),
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.hasError.value || controller.data == null) {
                return _ErrorState(r: r, onRetry: controller.refresh);
              }
              return _Content(r: r, controller: controller);
            }),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.r, required this.onRetry});
  final AppResponsive r;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded,
                size: r.adaptive(phone: 56, smallPhone: 48, tablet: 64, desktop: 72),
                color: AppColors.textGhost),
            SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
            Text(
              'Impossible de charger les données',
              style: AppTextStyles.bodyMedium(r).copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
            AppButton(label: 'Réessayer', onPressed: onRetry, icon: Icons.refresh_rounded),
          ],
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.r, required this.controller});
  final AppResponsive r;
  final EndTripController controller;

  @override
  Widget build(BuildContext context) {
    final data = controller.data!;
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: r.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
        ),
        children: [
          SizedBox(height: r.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40)),
          _SuccessHero(r: r, data: data),
          SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
          _TripSummaryCard(r: r, data: data),
          SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          _PassengerConfirmationCard(r: r, data: data, controller: controller),
          SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          _PaymentTimerCard(r: r, availableDate: data.availableDate),
          SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
          Obx(() => AppButton(
                label: controller.isConfirming.value
                    ? 'Confirmation…'
                    : 'Confirmer la fin du trajet',
                onPressed:
                    controller.isConfirming.value ? null : controller.onConfirmEnd,
                icon: Icons.check_circle_rounded,
              )),
          SizedBox(height: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
          GestureDetector(
            onTap: controller.onReportIssue,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
                child: Text(
                  'Signaler un problème',
                  style: AppTextStyles.bodySmall(r).copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
        ],
      ),
    );
  }
}

class _SuccessHero extends StatelessWidget {
  const _SuccessHero({required this.r, required this.data});
  final AppResponsive r;
  final EndTripSummaryModel data;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: r.adaptive(phone: 80, smallPhone: 72, tablet: 92, desktop: 104),
          height: r.adaptive(phone: 80, smallPhone: 72, tablet: 92, desktop: 104),
          decoration: const BoxDecoration(
            color: AppColors.surfaceSuccess,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.flag_rounded,
            size: r.adaptive(phone: 40, smallPhone: 36, tablet: 46, desktop: 52),
            color: AppColors.success,
          ),
        ),
        SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
        Text(
          'Trajet terminé !',
          style: AppTextStyles.h4(r).copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
        Text(
          data.tripRoute,
          style: AppTextStyles.bodyMedium(r).copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
        Text(
          'Durée réelle : ${data.realDuration}',
          style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textHint),
        ),
      ],
    );
  }
}

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({required this.r, required this.data});
  final AppResponsive r;
  final EndTripSummaryModel data;

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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem2(r: r, icon: Icons.route_rounded, value: '${data.distanceKm}km', label: 'Distance'),
              _SummaryItem2(r: r, icon: Icons.timer_rounded, value: data.realDuration, label: 'Durée'),
              _SummaryItem2(r: r, icon: Icons.people_rounded, value: '${data.passengersCount}', label: 'Passagers'),
            ],
          ),
          Divider(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28), color: AppColors.border),
          _RevRow(r: r, label: 'Montant brut', value: '${data.grossRevenue.toStringAsFixed(0)} FCFA', isBold: false),
          SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
          _RevRow(
            r: r,
            label: 'Commission (${data.commissionRate}%)',
            value: '-${data.commission.toStringAsFixed(0)} FCFA',
            isBold: false,
            valueColor: const Color(0xFFE53935),
          ),
          Divider(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20), color: AppColors.border),
          _RevRow(r: r, label: 'Vos revenus nets', value: '${data.netRevenue.toStringAsFixed(0)} FCFA', isBold: true),
        ],
      ),
    );
  }
}

class _SummaryItem2 extends StatelessWidget {
  const _SummaryItem2({required this.r, required this.icon, required this.value, required this.label});
  final AppResponsive r;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon,
            size: r.adaptive(phone: 22, smallPhone: 20, tablet: 24, desktop: 26),
            color: AppColors.primary),
        SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
        Text(value,
            style: AppTextStyles.bodyMedium(r)
                .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
        Text(label, style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}

class _RevRow extends StatelessWidget {
  const _RevRow(
      {required this.r, required this.label, required this.value, required this.isBold, this.valueColor});
  final AppResponsive r;
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTextStyles.bodyMedium(r)
                  .copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700)
              : AppTextStyles.bodySmall(r).copyWith(color: AppColors.textMuted),
        ),
        Text(
          value,
          style: isBold
              ? AppTextStyles.bodyMedium(r)
                  .copyWith(color: AppColors.primary, fontWeight: FontWeight.w800)
              : AppTextStyles.bodySmall(r).copyWith(
                  color: valueColor ?? AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PassengerConfirmationCard extends StatelessWidget {
  const _PassengerConfirmationCard(
      {required this.r, required this.data, required this.controller});
  final AppResponsive r;
  final EndTripSummaryModel data;
  final EndTripController controller;

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
          Row(
            children: [
              Text('Confirmation passagers',
                  style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary)),
              const Spacer(),
              Text(
                '${data.confirmedCount}/${data.confirmations.length}',
                style: AppTextStyles.bodySmall(r).copyWith(
                  color: data.allConfirmed ? AppColors.primary : AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
          Text(
            'Les passagers ont reçu une notification pour confirmer.',
            style: AppTextStyles.bodySmall(r).copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          ...data.confirmations.map((c) => Padding(
                padding: EdgeInsets.only(
                    bottom: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12)),
                child: Row(
                  children: [
                    Container(
                      width: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
                      height: r.adaptive(phone: 36, smallPhone: 32, tablet: 40, desktop: 44),
                      decoration: BoxDecoration(
                        color: c.hasConfirmed ? AppColors.surfaceSuccess : AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        c.initial,
                        style: AppTextStyles.bodySmall(r).copyWith(
                          color: c.hasConfirmed ? AppColors.success : AppColors.textMuted,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
                    Expanded(
                      child: Text(c.name,
                          style: AppTextStyles.bodySmall(r).copyWith(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                    ),
                    Icon(
                      c.hasConfirmed ? Icons.check_circle_rounded : Icons.access_time_rounded,
                      size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                      color: c.hasConfirmed ? AppColors.primary : AppColors.warning,
                    ),
                    SizedBox(width: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                    Text(
                      c.hasConfirmed ? 'Confirmé' : 'En attente',
                      style: AppTextStyles.labelSmall(r).copyWith(
                        color: c.hasConfirmed ? AppColors.primary : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _PaymentTimerCard extends StatelessWidget {
  const _PaymentTimerCard({required this.r, required this.availableDate});
  final AppResponsive r;
  final String availableDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: const Color(0x0CF4B400),
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.schedule_rounded,
            size: r.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40),
            color: AppColors.accent,
          ),
          SizedBox(width: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Délai de sécurité 24h',
                  style: AppTextStyles.bodySmall(r).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                Text(
                  'Vos fonds seront disponibles $availableDate',
                  style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

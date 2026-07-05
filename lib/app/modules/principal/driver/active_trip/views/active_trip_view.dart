import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/pre_departure_model.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/active_trip_controller.dart';

class ActiveTripView extends StatelessWidget {
  const ActiveTripView({super.key});

  ActiveTripController get _controller =>
      Get.isRegistered<ActiveTripController>()
          ? Get.find<ActiveTripController>()
          : Get.put(ActiveTripController());

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
            child: Column(
              children: [
                _Header(r: r),
                Expanded(
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.r, required this.controller});
  final AppResponsive r;
  final ActiveTripController controller;

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
          SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
          _ReadinessHero(r: r, data: data),
          SizedBox(height: r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
          _ChecklistCard(r: r, checklist: data.checklist),
          SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          _TripSummaryCard(r: r, trip: data.trip),
          SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          _StopsCard(r: r, stops: data.stops),
          SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
          _StartButton(r: r, controller: controller),
          SizedBox(height: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
        ],
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

class _Header extends StatelessWidget {
  const _Header({required this.r});
  final AppResponsive r;

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
              child: Icon(Icons.arrow_back_rounded,
                  size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
                  color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Text(
            'Prêt à partir ?',
            style: AppTextStyles.homeCardTitle(r).copyWith(
              color: AppColors.textPrimary,
              fontSize: r.adaptive(phone: 17, smallPhone: 15, tablet: 19, desktop: 21),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadinessHero extends StatelessWidget {
  const _ReadinessHero({required this.r, required this.data});
  final AppResponsive r;
  final PreDepartureModel data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 20, smallPhone: 16, tablet: 24, desktop: 28)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A86B), Color(0xFF008F5A)],
        ),
        borderRadius: BorderRadius.circular(r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 24)),
      ),
      child: Column(
        children: [
          Icon(
            data.allGreen ? Icons.check_circle_rounded : Icons.pending_rounded,
            size: r.adaptive(phone: 48, smallPhone: 44, tablet: 56, desktop: 64),
            color: Colors.white,
          ),
          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          Text(
            data.allGreen ? 'Tout est prêt !' : 'Vérification en cours…',
            style: AppTextStyles.h5(r).copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8)),
          Text(
            '${data.trip.origin} → ${data.trip.destination}',
            style: AppTextStyles.bodySmall(r).copyWith(
              color: Colors.white.withOpacity(0.85),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: r.adaptive(phone: 16, smallPhone: 12, tablet: 18, desktop: 20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _HeroStat(
                r: r,
                icon: Icons.access_time_rounded,
                value: data.trip.departureTimeFormatted,
                label: 'Départ',
              ),
              SizedBox(width: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
              _HeroStat(
                r: r,
                icon: Icons.groups_rounded,
                value: '${data.trip.passengersCount}',
                label: 'Passagers',
              ),
              SizedBox(width: r.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32)),
              _HeroStat(
                r: r,
                icon: Icons.straighten_rounded,
                value: '${data.trip.distanceKm}km',
                label: 'Distance',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.r, required this.icon, required this.value, required this.label});
  final AppResponsive r;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon,
            size: r.adaptive(phone: 18, smallPhone: 16, tablet: 20, desktop: 22),
            color: Colors.white.withOpacity(0.85)),
        SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
        Text(value,
            style: AppTextStyles.bodyMedium(r).copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
        Text(label,
            style: AppTextStyles.labelSmall(r).copyWith(color: Colors.white.withOpacity(0.75))),
      ],
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.r, required this.checklist});
  final AppResponsive r;
  final List<PreDepartureChecklistItem> checklist;

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
            'Vérification avant départ',
            style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
          ...checklist.map((item) => Padding(
                padding: EdgeInsets.only(
                    bottom: r.adaptive(phone: 10, smallPhone: 8, tablet: 12, desktop: 14)),
                child: Row(
                  children: [
                    Container(
                      width: r.adaptive(phone: 28, smallPhone: 26, tablet: 32, desktop: 36),
                      height: r.adaptive(phone: 28, smallPhone: 26, tablet: 32, desktop: 36),
                      decoration: BoxDecoration(
                        color: item.isDone ? AppColors.surfaceSuccess : AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isDone ? Icons.check_rounded : Icons.close_rounded,
                        size: r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20),
                        color: item.isDone ? AppColors.success : AppColors.textGhost,
                      ),
                    ),
                    SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
                    Expanded(
                      child: Text(
                        item.label,
                        style: AppTextStyles.bodySmall(r).copyWith(
                          color: item.isDone ? AppColors.textPrimary : AppColors.textMuted,
                          fontWeight: item.isDone ? FontWeight.w500 : FontWeight.w400,
                        ),
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

class _TripSummaryCard extends StatelessWidget {
  const _TripSummaryCard({required this.r, required this.trip});
  final AppResponsive r;
  final PreDepartureTripSummary trip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(r.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
      decoration: BoxDecoration(
        color: AppColors.surfaceAccent,
        borderRadius: BorderRadius.circular(r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(r: r, icon: Icons.people_rounded, value: '${trip.passengersCount}', label: 'Passagers'),
          _Divider(r: r),
          _SummaryItem(r: r, icon: Icons.route_rounded, value: '${trip.distanceKm}km', label: 'Trajet'),
          _Divider(r: r),
          _SummaryItem(r: r, icon: Icons.timer_outlined, value: trip.durationLabel, label: 'Durée'),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.r, required this.icon, required this.value, required this.label});
  final AppResponsive r;
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon,
            size: r.adaptive(phone: 20, smallPhone: 18, tablet: 22, desktop: 24),
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

class _Divider extends StatelessWidget {
  const _Divider({required this.r});
  final AppResponsive r;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: r.adaptive(phone: 40, smallPhone: 36, tablet: 44, desktop: 48),
      color: AppColors.primary.withOpacity(0.2),
    );
  }
}

class _StopsCard extends StatelessWidget {
  const _StopsCard({required this.r, required this.stops});
  final AppResponsive r;
  final List<PreDepartureStop> stops;

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
              Text(
                'Votre itinéraire optimisé',
                style: AppTextStyles.homeCardTitle(r).copyWith(color: AppColors.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: r.adaptive(phone: 8, smallPhone: 6, tablet: 10, desktop: 12),
                  vertical: r.adaptive(phone: 3, smallPhone: 2, tablet: 4, desktop: 5),
                ),
                decoration: BoxDecoration(
                  color: const Color(0x193B82F6),
                  borderRadius: BorderRadius.circular(r.adaptive(phone: 20, smallPhone: 18, tablet: 24, desktop: 28)),
                ),
                child: Text(
                  '${stops.length} arrêts',
                  style: AppTextStyles.labelSmall(r).copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.adaptive(phone: 14, smallPhone: 12, tablet: 16, desktop: 18)),
          ...stops.asMap().entries.map((entry) {
            final i = entry.key;
            final stop = entry.value;
            final isLast = i == stops.length - 1;
            return _StopRow(r: r, stop: stop, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({required this.r, required this.stop, required this.isLast});
  final AppResponsive r;
  final PreDepartureStop stop;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final stopColor = stop.isPickup ? AppColors.info : const Color(0xFFEF4444);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: r.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40),
              height: r.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40),
              decoration: BoxDecoration(
                color: stopColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${stop.index}',
                  style: AppTextStyles.labelSmall(r).copyWith(
                    color: stopColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: r.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40),
                color: AppColors.border,
              ),
          ],
        ),
        SizedBox(width: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: r.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: r.adaptive(phone: 6, smallPhone: 5, tablet: 7, desktop: 8),
                        vertical: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4),
                      ),
                      decoration: BoxDecoration(
                        color: stopColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(
                            r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                      ),
                      child: Text(
                        stop.isPickup ? 'Prise en charge' : 'Dépose',
                        style: AppTextStyles.labelSmall(r).copyWith(
                          color: stopColor,
                          fontWeight: FontWeight.w700,
                          fontSize: r.adaptive(phone: 10, smallPhone: 9, tablet: 11, desktop: 12),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      stop.eta,
                      style: AppTextStyles.labelSmall(r).copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: r.adaptive(phone: 4, smallPhone: 3, tablet: 5, desktop: 6)),
                Text(
                  stop.passengerName,
                  style: AppTextStyles.bodySmall(r).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: r.adaptive(phone: 2, smallPhone: 1, tablet: 3, desktop: 4)),
                Text(
                  stop.address,
                  style: AppTextStyles.labelSmall(r).copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.r, required this.controller});
  final AppResponsive r;
  final ActiveTripController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => AppButton(
          label: controller.isStarting.value ? 'Démarrage…' : 'Démarrer la navigation',
          onPressed: controller.isStarting.value ? null : controller.onStartNavigation,
          icon: Icons.navigation_rounded,
        ));
  }
}

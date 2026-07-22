import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';

import '../controllers/running_trip_controller.dart';

class RunningTripView extends StatelessWidget {
  const RunningTripView({super.key});

  RunningTripController get _ctrl => Get.find<RunningTripController>();

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    final ctrl = _ctrl;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _Header(r: r),
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: r.w(16)),
                children: [
                  SizedBox(height: r.h(20)),
                  _HeroBanner(r: r, ctrl: ctrl),
                  SizedBox(height: r.h(16)),
                  _PassengersCard(r: r, ctrl: ctrl),
                  SizedBox(height: r.h(24)),
                  _ContactButton(r: r, ctrl: ctrl),
                  SizedBox(height: r.h(12)),
                  _MapButton(r: r, ctrl: ctrl),
                  SizedBox(height: r.h(12)),
                  _TerminateButton(r: r, ctrl: ctrl),
                  SizedBox(height: r.h(32)),
                ],
              ),
            ),
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
      padding: EdgeInsets.symmetric(horizontal: r.w(16), vertical: r.h(12)),
      color: AppColors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: Get.back,
            child: Container(
              width: r.w(36),
              height: r.w(36),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(r.radius(10)),
              ),
              child: Icon(Icons.arrow_back_rounded,
                  size: r.text(18), color: AppColors.textPrimary),
            ),
          ),
          SizedBox(width: r.w(12)),
          Text('Trajet en cours',
              style: AppTextStyles.h6(r)
                  .copyWith(color: AppColors.textPrimary)),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.w(10), vertical: r.h(4)),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(r.radius(20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: r.w(6)),
                Text('En cours',
                    style: AppTextStyles.caption(r).copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.r, required this.ctrl});
  final AppResponsive r;
  final RunningTripController ctrl;

  @override
  Widget build(BuildContext context) {
    final trip = ctrl.tripSummary;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.w(20)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00A86B), Color(0xFF007A50)],
        ),
        borderRadius: BorderRadius.circular(r.radius(18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.directions_car_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                'Trajet démarré',
                style: AppTextStyles.subtitle(r).copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          SizedBox(height: r.h(12)),
          Row(
            children: [
              const Icon(Icons.trip_origin_rounded,
                  color: Colors.white70, size: 16),
              SizedBox(width: r.w(6)),
              Expanded(
                child: Text(
                  trip?.origin ?? '–',
                  style: AppTextStyles.bodySmall(r)
                      .copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: r.h(4)),
          Padding(
            padding: EdgeInsets.only(left: r.w(22)),
            child: Container(
                width: 2, height: r.h(14), color: Colors.white38),
          ),
          SizedBox(height: r.h(4)),
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: Colors.white70, size: 16),
              SizedBox(width: r.w(6)),
              Expanded(
                child: Text(
                  trip?.destination ?? '–',
                  style: AppTextStyles.bodySmall(r)
                      .copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: r.h(16)),
          Row(
            children: [
              _StatChip(
                r: r,
                icon: Icons.groups_rounded,
                label: '${trip?.passengersCount ?? ctrl.stops.where((s) => s.isPickup).length} passagers',
              ),
              SizedBox(width: r.w(8)),
              if (trip?.durationLabel.isNotEmpty == true)
                _StatChip(
                  r: r,
                  icon: Icons.timer_outlined,
                  label: trip!.durationLabel,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.r, required this.icon, required this.label});
  final AppResponsive r;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.w(10), vertical: r.h(5)),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(r.radius(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          SizedBox(width: r.w(5)),
          Text(label,
              style: AppTextStyles.caption(r).copyWith(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _PassengersCard extends StatelessWidget {
  const _PassengersCard({required this.r, required this.ctrl});
  final AppResponsive r;
  final RunningTripController ctrl;

  @override
  Widget build(BuildContext context) {
    final stops = ctrl.stops;
    if (stops.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(r.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(r.radius(14)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Passagers à bord',
              style: AppTextStyles.subtitle(r)
                  .copyWith(fontWeight: FontWeight.w700)),
          SizedBox(height: r.h(12)),
          ...stops.map((s) => Padding(
                padding: EdgeInsets.only(bottom: r.h(10)),
                child: Row(
                  children: [
                    Container(
                      width: r.w(38),
                      height: r.w(38),
                      decoration: BoxDecoration(
                        color: s.isPickup
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : const Color(0x19EF4444),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          s.passengerName.isNotEmpty
                              ? s.passengerName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: s.isPickup
                                ? AppColors.primary
                                : const Color(0xFFEF4444),
                            fontWeight: FontWeight.w800,
                            fontSize: r.text(15),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: r.w(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.passengerName,
                              style: AppTextStyles.bodySmall(r).copyWith(
                                  fontWeight: FontWeight.w600)),
                          Text(
                            s.isPickup
                                ? 'Prise en charge — ${s.address}'
                                : 'Dépose — ${s.address}',
                            style: AppTextStyles.caption(r)
                                .copyWith(color: AppColors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (s.phone.isNotEmpty)
                      Icon(Icons.phone_rounded,
                          size: r.text(16), color: AppColors.primary),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({required this.r, required this.ctrl});
  final AppResponsive r;
  final RunningTripController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                ctrl.isSending.value ? null : ctrl.onContactAll,
            icon: ctrl.isSending.value
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Icon(Icons.message_rounded, size: 20),
            label: Text(ctrl.isSending.value
                ? 'Envoi en cours…'
                : 'Contacter tous les passagers'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D4ED8),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: r.h(14)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r.radius(14)),
              ),
              elevation: 0,
              textStyle: AppTextStyles.subtitle(r)
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ));
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.r, required this.ctrl});
  final AppResponsive r;
  final RunningTripController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: ctrl.onViewMap,
        icon: const Icon(Icons.map_rounded, size: 20),
        label: const Text('Voir la carte interactive'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          padding: EdgeInsets.symmetric(vertical: r.h(14)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.radius(14)),
          ),
          textStyle: AppTextStyles.subtitle(r)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _TerminateButton extends StatelessWidget {
  const _TerminateButton({required this.r, required this.ctrl});
  final AppResponsive r;
  final RunningTripController ctrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _confirmTerminate(context, r, ctrl),
        icon: const Icon(Icons.flag_rounded, size: 20),
        label: const Text('Terminer le trajet'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEF4444),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: r.h(14)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(r.radius(14)),
          ),
          elevation: 0,
          textStyle: AppTextStyles.subtitle(r)
              .copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _confirmTerminate(
      BuildContext context, AppResponsive r, RunningTripController ctrl) {
    Get.dialog(
      AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(r.radius(20))),
        title: const Text('Terminer le trajet ?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text(
            'Vous allez terminer ce trajet. Les passagers seront notifiés.'),
        actions: [
          TextButton(
              onPressed: Get.back,
              child: const Text('Annuler',
                  style: TextStyle(color: AppColors.textMuted))),
          TextButton(
            onPressed: () {
              Get.back();
              ctrl.onTerminate();
            },
            child: const Text('Terminer',
                style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

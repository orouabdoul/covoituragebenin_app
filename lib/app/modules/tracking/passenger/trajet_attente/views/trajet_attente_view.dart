import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/trajet_attente_controller.dart';

class TrajetAttenteView extends StatelessWidget {
  const TrajetAttenteView({super.key});

  @override
  Widget build(BuildContext context) {
    final c   = Get.find<TrajetAttenteController>();
    final res = AppResponsive(context);
    final sh  = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // ── Carte (55% de l'écran) ──────────────────────────────────────
          SizedBox(
            height: sh * 0.55,
            child: _MapLayer(controller: c),
          ),

          // ── Panneau bas draggable ───────────────────────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.48,
            minChildSize: 0.40,
            maxChildSize: 0.78,
            builder: (_, scrollCtrl) => _BottomPanel(
              c: c,
              res: res,
              scrollCtrl: scrollCtrl,
            ),
          ),

          // ── Header ─────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: res.w(12), vertical: res.h(4)),
              child: Row(
                children: [
                  _CircleBtn(
                      icon: Icons.arrow_back_rounded, onTap: Get.back),
                  const Spacer(),
                  Obx(() => c.isTransitioning.value
                      ? const SizedBox.shrink()
                      : _CircleBtn(
                          icon: Icons.refresh_rounded, onTap: c.refreshNow)),
                ],
              ),
            ),
          ),

          // ── Overlay de transition ───────────────────────────────────────
          Obx(() => c.isTransitioning.value
              ? _TransitionOverlay(res: res)
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// ── Carte ─────────────────────────────────────────────────────────────────────

class _MapLayer extends StatelessWidget {
  const _MapLayer({required this.controller});
  final TrajetAttenteController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dep    = controller.departurePt.value;
      final arr    = controller.arrivalPt.value;
      final route  = controller.routePoints.toList();
      final status = controller.tripStatus.value;

      // Couleur pointillés selon statut
      final routeColor = status == 'active'
          ? const Color(0xFF93C5FD)
          : status == 'completed'
              ? const Color(0xFF9CA3AF)
              : const Color(0xFFF59E0B); // pending → orange

      return FlutterMap(
        mapController: controller.mapCtrl,
        options: MapOptions(
          initialCenter: dep,
          initialZoom: 12,
          interactionOptions:
              const InteractionOptions(flags: InteractiveFlag.all),
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.covoiturage_benin_app',
          ),
          // Itinéraire planifié (pointillés orange)
          if (route.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route,
                  color: routeColor.withValues(alpha: 0.85),
                  strokeWidth: 4.5,
                  pattern: StrokePattern.dashed(segments: const <double>[12, 8]),
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              _marker(dep, const Color(0xFF10B981), Icons.trip_origin_rounded,
                  'Départ'),
              _marker(arr, const Color(0xFFEF4444), Icons.location_on_rounded,
                  'Arrivée'),
            ],
          ),
        ],
      );
    });
  }

  static Marker _marker(LatLng pt, Color color, IconData icon, String label) {
    return Marker(
      point: pt,
      width: 52,
      height: 66,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding:
                const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(4)),
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Panneau bas ───────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.c,
    required this.res,
    required this.scrollCtrl,
  });
  final TrajetAttenteController c;
  final AppResponsive res;
  final ScrollController scrollCtrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 20,
              offset: Offset(0, -4))
        ],
      ),
      child: ListView(
        controller: scrollCtrl,
        padding: EdgeInsets.fromLTRB(
            res.w(20), 0, res.w(20), res.h(32)),
        children: [
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: res.h(10)),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.borderStrong,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Countdown
          Obx(() => _CountdownCard(
                label: c.countdownLabel.value,
                expired: c.countdownExpired.value,
                res: res,
              )),
          SizedBox(height: res.h(16)),
          // Titre itinéraire
          Text('Votre trajet',
              style: AppTextStyles.h6(res)
                  .copyWith(color: AppColors.textSecondary)),
          SizedBox(height: res.h(8)),
          Obx(() => _RouteRow(
                dep: c.departureCity.value,
                arr: c.arrivalCity.value,
                time: c.departureTime.value,
                res: res,
              )),
          SizedBox(height: res.h(16)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: res.h(16)),
          // Conducteur
          Obx(() => _DriverRow(
                name: c.driverName.value,
                res: res,
              )),
          SizedBox(height: res.h(20)),
          // Bouton appel
          _CallBtn(onTap: c.callDriver, res: res),
          SizedBox(height: res.h(12)),
          Center(
            child: Text(
              'Actualisation automatique toutes les 30 secondes',
              style: AppTextStyles.caption(res)
                  .copyWith(color: AppColors.textHint, fontSize: res.text(11)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sous-widgets ──────────────────────────────────────────────────────────────

class _CountdownCard extends StatelessWidget {
  const _CountdownCard(
      {required this.label, required this.expired, required this.res});
  final String label;
  final bool expired;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    final color = expired ? AppColors.accent : AppColors.primary;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: res.w(16), vertical: res.h(14)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(res.radius(14)),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            expired
                ? Icons.timer_off_rounded
                : Icons.hourglass_top_rounded,
            color: color,
            size: 22,
          ),
          SizedBox(width: res.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expired ? 'Départ imminent' : 'Avant le départ',
                  style: AppTextStyles.caption(res).copyWith(
                      color: color, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: res.h(2)),
                Text(
                  label.isEmpty ? 'Calcul…' : label,
                  style: AppTextStyles.h6(res).copyWith(
                      color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({
    required this.dep,
    required this.arr,
    required this.time,
    required this.res,
  });
  final String dep;
  final String arr;
  final String time;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PointRow(
            color: const Color(0xFF10B981),
            icon: Icons.trip_origin_rounded,
            label: dep.isNotEmpty ? dep : '—',
            res: res),
        Padding(
          padding: EdgeInsets.only(left: res.w(16)),
          child: Container(
              width: 2, height: 20, color: AppColors.borderStrong),
        ),
        _PointRow(
            color: const Color(0xFFEF4444),
            icon: Icons.location_on_rounded,
            label: arr.isNotEmpty ? arr : '—',
            res: res),
        if (time.isNotEmpty) ...[
          SizedBox(height: res.h(6)),
          Row(
            children: [
              Icon(Icons.schedule_rounded,
                  size: 14, color: AppColors.textHint),
              SizedBox(width: res.w(4)),
              Text(time,
                  style: AppTextStyles.caption(res)
                      .copyWith(color: AppColors.textHint)),
            ],
          )
        ],
      ],
    );
  }
}

class _PointRow extends StatelessWidget {
  const _PointRow({
    required this.color,
    required this.icon,
    required this.label,
    required this.res,
  });
  final Color color;
  final IconData icon;
  final String label;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: res.w(10)),
        Expanded(
          child: Text(label,
              style: AppTextStyles.body(res)
                  .copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.name, required this.res});
  final String name;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(initials,
                style: AppTextStyles.h6(res).copyWith(
                    color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
        ),
        SizedBox(width: res.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : 'Conducteur',
                style: AppTextStyles.body(res)
                    .copyWith(fontWeight: FontWeight.w700),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Votre conducteur',
                style: AppTextStyles.caption(res)
                    .copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: res.w(8), vertical: res.h(4)),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Text(
            'En attente',
            style: AppTextStyles.caption(res).copyWith(
                color: AppColors.success, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _CallBtn extends StatelessWidget {
  const _CallBtn({required this.onTap, required this.res});
  final VoidCallback onTap;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.call_rounded, size: 18),
        label: const Text('Appeler le conducteur'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: EdgeInsets.symmetric(vertical: res.h(14)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(res.radius(14))),
          textStyle: AppTextStyles.body(res)
              .copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _TransitionOverlay extends StatelessWidget {
  const _TransitionOverlay({required this.res});
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.88),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 3),
            SizedBox(height: res.h(16)),
            Text('Le conducteur a démarré !',
                style: AppTextStyles.h5(res)
                    .copyWith(color: Colors.white)),
            SizedBox(height: res.h(6)),
            Text('Chargement du suivi en direct…',
                style: AppTextStyles.body(res)
                    .copyWith(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child:
            Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

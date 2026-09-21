import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/trajet_actif_controller.dart';

class TrajetActifView extends StatelessWidget {
  const TrajetActifView({super.key});

  @override
  Widget build(BuildContext context) {
    final c   = Get.find<TrajetActifController>();
    final res = AppResponsive(context);
    final sh  = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          SizedBox(height: sh * 0.58, child: _MapLayer(c: c)),
          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.38,
            maxChildSize: 0.72,
            builder: (_, scroll) =>
                _BottomPanel(c: c, res: res, scroll: scroll),
          ),
          _TopBar(c: c, res: res),
          Obx(() => c.tripEnded.value
              ? const SizedBox.shrink()
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// ── Carte ─────────────────────────────────────────────────────────────────────

class _MapLayer extends StatelessWidget {
  const _MapLayer({required this.c});
  final TrajetActifController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final vehicle   = c.vehicleLatLng.value;
      final departure = c.departurePt.value;
      final arrival   = c.arrivalPt.value;
      final trail     = c.gpsTrail.toList();
      final route     = c.routePoints.toList();
      final color     = Color(c.vehicleMarkerColor);

      return FlutterMap(
        mapController: c.mapCtrl,
        options: MapOptions(
          initialCenter: vehicle,
          initialZoom: 13,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
          onPositionChanged: (_, hasGesture) {
            if (hasGesture) c.cameraFollows.value = false;
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.covoiturage_benin_app',
          ),
          // Itinéraire OSRM planifié
          if (route.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route,
                  color: const Color(0xFF93C5FD).withValues(alpha: 0.7),
                  strokeWidth: 4,
                  pattern: StrokePattern.dashed(segments: const <double>[10, 6]),
                ),
              ],
            ),
          // Tracé GPS temps réel (bleu solide)
          if (trail.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: trail,
                  color: const Color(0xFF1A5FB4),
                  strokeWidth: 4,
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              // Départ
              _pinMarker(departure, const Color(0xFF10B981),
                  Icons.trip_origin_rounded, 'Départ'),
              // Arrivée
              _pinMarker(arrival, const Color(0xFFEF4444),
                  Icons.location_on_rounded, 'Arrivée'),
              // Véhicule conducteur
              Marker(
                point: vehicle,
                width: 46,
                height: 46,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.directions_car_rounded,
                      color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  static Marker _pinMarker(
      LatLng pt, Color color, IconData icon, String label) {
    return Marker(
      point: pt,
      width: 52,
      height: 66,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2.5),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding:
                const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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

// ── Header ─────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.c, required this.res});
  final TrajetActifController c;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: res.w(12), vertical: res.h(4)),
        child: Row(
          children: [
            _CircleBtn(icon: Icons.arrow_back_rounded, onTap: Get.back),
            const Spacer(),
            _CircleBtn(
                icon: Icons.fit_screen_rounded, onTap: c.fitAll),
            SizedBox(width: res.w(8)),
            Obx(() => _CircleBtn(
                  icon: c.cameraFollows.value
                      ? Icons.gps_fixed_rounded
                      : Icons.gps_not_fixed_rounded,
                  onTap: c.toggleCamera,
                  active: c.cameraFollows.value,
                )),
          ],
        ),
      ),
    );
  }
}

// ── Panneau bas ───────────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.c,
    required this.res,
    required this.scroll,
  });
  final TrajetActifController c;
  final AppResponsive res;
  final ScrollController scroll;

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
        controller: scroll,
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
          // Statut + GPS stale
          Obx(() => Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: c.hasVehicleGps.value
                          ? AppColors.success
                          : AppColors.textHint,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: res.w(6)),
                  Expanded(
                    child: Text(c.statusLabel,
                        style: AppTextStyles.body(res).copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                  ),
                  if (c.gpsStale.value)
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: res.w(8), vertical: res.h(3)),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.danger.withValues(alpha: 0.3)),
                      ),
                      child: Text('GPS perdu',
                          style: AppTextStyles.caption(res).copyWith(
                              color: AppColors.danger,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              )),
          SizedBox(height: res.h(12)),
          // Infos distance / ETA / vitesse
          Obx(() => Row(
                children: [
                  _StatChip(
                    icon: Icons.route_rounded,
                    value: c.distanceRemainKm.value < 1
                        ? '${(c.distanceRemainKm.value * 1000).round()} m'
                        : '${c.distanceRemainKm.value.toStringAsFixed(1)} km',
                    label: 'Restant',
                    res: res,
                  ),
                  SizedBox(width: res.w(10)),
                  _StatChip(
                    icon: Icons.schedule_rounded,
                    value: c.etaMinutes.value,
                    label: 'ETA',
                    res: res,
                  ),
                  SizedBox(width: res.w(10)),
                  _StatChip(
                    icon: Icons.speed_rounded,
                    value: '${c.vehicleSpeed.value.round()} km/h',
                    label: 'Vitesse',
                    res: res,
                  ),
                ],
              )),
          SizedBox(height: res.h(12)),
          // Barre de progression
          Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(c.departureCity.value,
                          style: AppTextStyles.caption(res)
                              .copyWith(color: AppColors.textHint)),
                      const Spacer(),
                      Text(c.arrivalCity.value,
                          style: AppTextStyles.caption(res)
                              .copyWith(color: AppColors.textHint)),
                    ],
                  ),
                  SizedBox(height: res.h(4)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: c.progressPct.value.clamp(0.0, 1.0),
                      minHeight: 7,
                      backgroundColor: AppColors.borderStrong,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              )),
          SizedBox(height: res.h(16)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: res.h(16)),
          // Conducteur
          Obx(() => _DriverRow(
                name: c.driverName.value,
                res: res,
                hasGps: c.hasVehicleGps.value,
              )),
          SizedBox(height: res.h(16)),
          // Bouton appel
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: c.callDriver,
              icon: const Icon(Icons.call_rounded, size: 18),
              label: const Text('Appeler le conducteur'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                    color: AppColors.primary, width: 1.5),
                padding:
                    EdgeInsets.symmetric(vertical: res.h(14)),
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(res.radius(14))),
                textStyle: AppTextStyles.body(res)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(height: res.h(10)),
          Center(
            child: Text(
              'Mise à jour toutes les 5 secondes',
              style: AppTextStyles.caption(res).copyWith(
                  color: AppColors.textHint,
                  fontSize: res.text(11)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sous-widgets ──────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.res,
  });
  final IconData icon;
  final String value;
  final String label;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: res.w(8), vertical: res.h(10)),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            SizedBox(height: res.h(3)),
            Text(value,
                style: AppTextStyles.body(res).copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: res.text(13)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            Text(label,
                style: AppTextStyles.caption(res)
                    .copyWith(color: AppColors.textHint)),
          ],
        ),
      ),
    );
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({
    required this.name,
    required this.res,
    required this.hasGps,
  });
  final String name;
  final AppResponsive res;
  final bool hasGps;

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
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        SizedBox(width: res.w(12)),
        Expanded(
          child: Text(
            name.isNotEmpty ? name : 'Conducteur',
            style: AppTextStyles.body(res)
                .copyWith(fontWeight: FontWeight.w700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (!hasGps)
          Padding(
            padding: EdgeInsets.only(left: res.w(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.portable_wifi_off_rounded,
                    size: 14, color: AppColors.textHint),
                SizedBox(width: res.w(4)),
                Text('Pas de GPS',
                    style: AppTextStyles.caption(res)
                        .copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
      ],
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 8,
                offset: Offset(0, 2))
          ],
        ),
        child: Icon(icon,
            size: 20,
            color:
                active ? Colors.white : AppColors.textPrimary),
      ),
    );
  }
}

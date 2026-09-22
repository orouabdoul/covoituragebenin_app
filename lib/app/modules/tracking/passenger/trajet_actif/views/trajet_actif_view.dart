import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/trajet_actif_controller.dart';

class TrajetActifView extends GetView<TrajetActifController> {
  const TrajetActifView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          _MapLayer(c: controller),
          _BottomSheet(c: controller),
          _TopBar(c: controller),
        ],
      ),
    );
  }
}

// ─── Map ─────────────────────────────────────────────────────────────────────

class _MapLayer extends StatelessWidget {
  const _MapLayer({required this.c});
  final TrajetActifController c;

  static const _benin = LatLng(9.3077, 2.3158);

  static bool _isBenin(LatLng p) =>
      (p.latitude - _benin.latitude).abs() < 1e-4 &&
      (p.longitude - _benin.longitude).abs() < 1e-4;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: h * 0.60,
      child: Obx(() => FlutterMap(
            mapController: c.mapCtrl,
            options: MapOptions(
              initialCenter: c.departurePt.value,
              initialZoom: 11.0,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.minizon.app',
              ),
              if (c.routePoints.length >= 2)
                PolylineLayer(polylines: [
                  Polyline(
                    points: List.unmodifiable(c.routePoints),
                    color: AppColors.primary.withValues(alpha: 0.30),
                    strokeWidth: 5,
                    pattern:
                        StrokePattern.dashed(segments: [12, 8]),
                  ),
                ]),
              if (c.gpsTrail.length >= 2)
                PolylineLayer(polylines: [
                  Polyline(
                    points: List.unmodifiable(c.gpsTrail),
                    color: AppColors.primary,
                    strokeWidth: 3.5,
                  ),
                ]),
              MarkerLayer(markers: [
                Marker(
                  point: c.departurePt.value,
                  width: 36,
                  height: 36,
                  child: _CityPin(
                    color: AppColors.success,
                    icon: Icons.trip_origin_rounded,
                  ),
                ),
                Marker(
                  point: c.arrivalPt.value,
                  width: 36,
                  height: 36,
                  child: _CityPin(
                    color: AppColors.danger,
                    icon: Icons.location_on_rounded,
                  ),
                ),
                if (!_isBenin(c.vehicleLatLng.value))
                  Marker(
                    point: c.vehicleLatLng.value,
                    width: 44,
                    height: 44,
                    child: _VehicleDot(colorValue: c.vehicleMarkerColor),
                  ),
              ]),
            ],
          )),
    );
  }
}

class _CityPin extends StatelessWidget {
  const _CityPin({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.40),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      );
}

class _VehicleDot extends StatelessWidget {
  const _VehicleDot({required this.colorValue});
  final int colorValue;

  @override
  Widget build(BuildContext context) {
    final color = Color(colorValue);
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: const Icon(Icons.directions_car_filled_rounded,
          color: Colors.white, size: 22),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.c});
  final TrajetActifController c;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _MapBtn(icon: Icons.arrow_back_rounded, onTap: Get.back),
            const Spacer(),
            _MapBtn(icon: Icons.fit_screen_rounded, onTap: c.fitAll),
            const SizedBox(width: 8),
            Obx(() => _MapBtn(
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

class _MapBtn extends StatelessWidget {
  const _MapBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.white,
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : AppColors.textPrimary,
            size: 20,
          ),
        ),
      );
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({required this.c});
  final TrajetActifController c;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.46,
      minChildSize: 0.20,
      maxChildSize: 0.78,
      builder: (ctx, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: ListView(
          controller: scroll,
          padding: EdgeInsets.zero,
          children: [
            _Handle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatusRow(c: c, r: r),
                  const SizedBox(height: 16),
                  _MetricsRow(c: c, r: r),
                  const SizedBox(height: 16),
                  _ProgressBar(c: c, r: r),
                  const _Separator(),
                  _DriverCard(c: c, r: r),
                  const SizedBox(height: 16),
                  _PrimaryBtn(
                    onTap: c.callDriver,
                    icon: Icons.phone_rounded,
                    label: 'Appeler le conducteur',
                    color: AppColors.success,
                    r: r,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      'Mise à jour toutes les 5 secondes',
                      style: AppTextStyles.caption(r)
                          .copyWith(color: AppColors.textHint),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.paddingOf(context).bottom + 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40,
          height: 4,
          margin: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFD1D5DB),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F5)),
      );
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.c, required this.r});
  final TrajetActifController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final label = c.statusLabel;
      final stale = c.gpsStale.value;
      return Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.h5(r),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (stale) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.signal_wifi_off_rounded,
                      size: 13, color: AppColors.accent),
                  const SizedBox(width: 4),
                  Text('GPS perdu',
                      style: AppTextStyles.labelSmall(r)
                          .copyWith(color: AppColors.accent)),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({required this.c, required this.r});
  final TrajetActifController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
          children: [
            _MetricChip(
              icon: Icons.route_rounded,
              value: '${c.distanceRemainKm.value.toStringAsFixed(1)} km',
              label: 'Restant',
              color: AppColors.primary,
              r: r,
            ),
            const SizedBox(width: 10),
            _MetricChip(
              icon: Icons.access_time_rounded,
              value: c.etaMinutes.value,
              label: 'Arrivée',
              color: AppColors.success,
              r: r,
            ),
            const SizedBox(width: 10),
            _MetricChip(
              icon: Icons.speed_rounded,
              value: '${c.vehicleSpeed.value.toStringAsFixed(0)} km/h',
              label: 'Vitesse',
              color: AppColors.accent,
              r: r,
            ),
          ],
        ));
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.r,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: color.withValues(alpha: 0.16), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 6),
              Text(value,
                  style: AppTextStyles.h6(r).copyWith(color: color)),
              Text(label, style: AppTextStyles.labelSmall(r)),
            ],
          ),
        ),
      );
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.c, required this.r});
  final TrajetActifController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pct = c.progressPct.value.clamp(0.0, 1.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  c.departureCity.value,
                  style: AppTextStyles.bodySmall(r)
                      .copyWith(color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Text(
                  c.arrivalCity.value,
                  style: AppTextStyles.bodySmall(r)
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: const Color(0xFFEEF0F3),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
            ),
          ),
        ],
      );
    });
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.c, required this.r});
  final TrajetActifController c;
  final AppResponsive r;

  static String _initials(String n) {
    final parts =
        n.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = c.driverName.value;
      return Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.20),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                _initials(name),
                style:
                    AppTextStyles.h5(r).copyWith(color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'Conducteur',
                  style: AppTextStyles.subtitle(r),
                ),
                Text('Conducteur', style: AppTextStyles.caption(r)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 4),
                Text(
                  'En route',
                  style: AppTextStyles.labelSmall(r)
                      .copyWith(color: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _PrimaryBtn extends StatelessWidget {
  const _PrimaryBtn({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    required this.r,
  });
  final VoidCallback onTap;
  final IconData icon;
  final String label;
  final Color color;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: 20),
          label: Text(label, style: AppTextStyles.button(r)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}

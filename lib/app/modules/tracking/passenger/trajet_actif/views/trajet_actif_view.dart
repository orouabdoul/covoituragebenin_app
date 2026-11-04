import 'dart:math' as math;
import 'dart:ui' as ui;

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
          // Bannière démarrage conducteur
          Obx(() => controller.driverJustStarted.value
              ? _DriverStartedBanner(c: controller)
              : const SizedBox.shrink()),
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
      (p.latitude  - _benin.latitude).abs()  < 1e-4 &&
      (p.longitude - _benin.longitude).abs() < 1e-4;

  static int _splitIdx(List<LatLng> pts, LatLng veh) {
    if (pts.length < 2) return 0;
    int best = 0;
    double bestD = double.infinity;
    for (int i = 0; i < pts.length; i++) {
      final dlat = pts[i].latitude  - veh.latitude;
      final dlng = pts[i].longitude - veh.longitude;
      final d = dlat * dlat + dlng * dlng;
      if (d < bestD) { bestD = d; best = i; }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: h * 0.62,
      child: Obx(() {
        final route   = List<LatLng>.unmodifiable(c.routePoints);   // itinéraire complet
        final segment = List<LatLng>.unmodifiable(c.segmentPoints); // segment passager
        final veh     = c.vehicleLatLng.value;
        final hasVeh  = !_isBenin(veh);
        final hasSeg  = segment.length >= 2;

        final split = (route.length >= 2 && hasVeh)
            ? _splitIdx(route, veh)
            : 0;
        final traveled = (route.length >= 2 && split > 1)
            ? route.sublist(0, split + 1)
            : <LatLng>[];
        final remaining = route.length >= 2
            ? (split > 0 ? route.sublist(split) : route)
            : <LatLng>[];

        return FlutterMap(
          mapController: c.mapCtrl,
          options: MapOptions(
            initialCenter: c.departurePt.value,
            initialZoom: 11.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
            // Désactiver le suivi caméra si l'utilisateur touche la carte
            onMapEvent: (event) {
              if (event is MapEventMoveStart &&
                  event.source != MapEventSource.mapController) {
                c.cameraFollows.value = false;
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.minizon.app',
            ),

            // ── Itinéraire complet du trajet ──────────────────────────────
            // Portion restante
            if (remaining.length >= 2)
              PolylineLayer(polylines: [
                Polyline(
                  points: remaining,
                  color: hasSeg
                      ? const Color(0x30888888)
                      : AppColors.primary.withValues(alpha: 0.38),
                  strokeWidth: hasSeg ? 3.5 : 5,
                  pattern: StrokePattern.dashed(segments: [14, 7]),
                ),
              ]),
            // Portion parcourue
            if (traveled.length >= 2)
              PolylineLayer(polylines: [
                Polyline(
                  points: traveled,
                  color: hasSeg
                      ? const Color(0x55888888)
                      : AppColors.primary.withValues(alpha: 0.90),
                  strokeWidth: hasSeg ? 3.5 : 5.5,
                ),
              ]),

            // ── Segment passager (montée → descente) — halo blanc + orange ─
            if (hasSeg) ...[
              PolylineLayer(polylines: [
                Polyline(
                  points: segment,
                  color: Colors.white.withValues(alpha: 0.85),
                  strokeWidth: 11,
                ),
              ]),
              PolylineLayer(polylines: [
                Polyline(
                  points: segment,
                  color: AppColors.accent.withValues(alpha: 0.92),
                  strokeWidth: 5.5,
                ),
              ]),
            ],

            // ── Tracé GPS réel (historique) ───────────────────────────────
            if (c.gpsTrail.length >= 2)
              PolylineLayer(polylines: [
                Polyline(
                  points: List.unmodifiable(c.gpsTrail),
                  color: AppColors.primary,
                  strokeWidth: hasSeg ? 3 : 4,
                ),
              ]),

            // ── Marqueurs ─────────────────────────────────────────────────
            MarkerLayer(markers: [
              // Petits ronds gris aux extrémités du trajet complet
              if (hasSeg && !_isBenin(c.tripDeparturePt.value))
                Marker(
                  point: c.tripDeparturePt.value,
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  child: const _SmallDot(color: Color(0xFF888888)),
                ),
              if (hasSeg && !_isBenin(c.tripArrivalPt.value))
                Marker(
                  point: c.tripArrivalPt.value,
                  width: 14,
                  height: 14,
                  alignment: Alignment.center,
                  child: const _SmallDot(color: Color(0xFF888888)),
                ),
              // Marqueur montée passager (icône personne, vert)
              Marker(
                point: c.departurePt.value,
                width: 144,
                height: 108,
                alignment: Alignment.bottomCenter,
                child: _PassengerPin(
                  isPickup: true,
                  city: c.pickupCityLabel.value,
                  detail: c.pickupDetail.value,
                ),
              ),
              // Marqueur descente passager (icône drapeau, rouge)
              Marker(
                point: c.arrivalPt.value,
                width: 144,
                height: 108,
                alignment: Alignment.bottomCenter,
                child: _PassengerPin(
                  isPickup: false,
                  city: c.dropoffCityLabel.value,
                  detail: c.dropoffDetail.value,
                ),
              ),
              if (hasVeh)
                Marker(
                  point: veh,
                  width: 56,
                  height: 56,
                  child: _PulsingVehicle(colorValue: c.vehicleMarkerColor),
                ),
            ]),
          ],
        );
      }),
    );
  }
}

// ─── Small Dot ────────────────────────────────────────────────────────────────

class _SmallDot extends StatelessWidget {
  const _SmallDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
      );
}

// ─── Passenger Pin (icône personne / drapeau) ─────────────────────────────────

class _PassengerPin extends StatelessWidget {
  const _PassengerPin({
    required this.isPickup,
    required this.city,
    required this.detail,
  });
  final bool isPickup;
  final String city;
  final String detail;

  @override
  Widget build(BuildContext context) {
    // Même style que la carte conducteur : violet+personne pour prise, orange+drapeau pour dépôt
    final color = isPickup ? const Color(0xFF7C3AED) : const Color(0xFFF59E0B);
    final icon  = isPickup ? Icons.person_rounded : Icons.flag_rounded;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label pill blanc flottant
        if (city.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxWidth: 130),
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.22),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(color: color.withValues(alpha: 0.28), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  city,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 9,
                      height: 1.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        // Cercle icône
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.55),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 21),
        ),
        // Flèche
        ClipPath(
          clipper: _TriangleClipper(),
          child: Container(width: 12, height: 7, color: color),
        ),
        // Point au sol
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.45), blurRadius: 4),
            ],
          ),
        ),
      ],
    );
  }
}

class _TriangleClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) => ui.Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(size.width / 2, size.height)
    ..close();

  @override
  bool shouldReclip(_TriangleClipper _) => false;
}

// ─── Pulsing Vehicle Marker ───────────────────────────────────────────────────

class _PulsingVehicle extends StatefulWidget {
  const _PulsingVehicle({required this.colorValue});
  final int colorValue;

  @override
  State<_PulsingVehicle> createState() => _PulsingVehicleState();
}

class _PulsingVehicleState extends State<_PulsingVehicle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.colorValue);
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        final t = _ctrl.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: ((1 - t) * 0.55).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 1.0 + t * 1.5,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 1.5),
                  ),
                ),
              ),
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.50),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Driver Started Banner ────────────────────────────────────────────────────

class _DriverStartedBanner extends StatefulWidget {
  const _DriverStartedBanner({required this.c});
  final TrajetActifController c;

  @override
  State<_DriverStartedBanner> createState() => _DriverStartedBannerState();
}

class _DriverStartedBannerState extends State<_DriverStartedBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(r.w(16), r.h(64), r.w(16), 0),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -2.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: _anim, curve: Curves.elasticOut)),
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: r.w(16), vertical: r.h(12)),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.40),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: r.w(40),
                  height: r.w(40),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: r.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Le conducteur a démarré !',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.text(14),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Votre trajet est en cours',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: r.text(12),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.c.dismissDriverBanner,
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white.withValues(alpha: 0.80),
                    size: r.text(20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.c});
  final TrajetActifController c;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: r.w(12), vertical: r.h(8)),
        child: Row(
          children: [
            _MapBtn(icon: Icons.arrow_back_rounded, onTap: Get.back),
            const Spacer(),
            _MapBtn(icon: Icons.fit_screen_rounded, onTap: c.fitAll),
            SizedBox(width: r.w(8)),
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
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: r.w(40),
        height: r.w(40),
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
          size: r.text(20),
        ),
      ),
    );
  }
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({required this.c});
  final TrajetActifController c;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.44,
      minChildSize: 0.18,
      maxChildSize: 0.82,
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
              padding: EdgeInsets.fromLTRB(r.w(20), r.h(4), r.w(20), 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RouteHeader(c: c, r: r),
                  SizedBox(height: r.h(16)),
                  _MilestoneProgress(c: c, r: r),
                  SizedBox(height: r.h(16)),
                  _MetricsRow(c: c, r: r),
                  const _Separator(),
                  _TripTimeline(c: c, r: r),
                  const _Separator(),
                  _DriverCard(c: c, r: r),
                  SizedBox(height: r.h(16)),
                  _PrimaryBtn(
                    onTap: c.callDriver,
                    icon: Icons.phone_rounded,
                    label: 'Appeler le conducteur',
                    color: AppColors.success,
                    r: r,
                  ),
                  SizedBox(height: r.h(10)),
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
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Center(
      child: Container(
        width: r.w(40),
        height: r.h(4),
        margin: EdgeInsets.symmetric(vertical: r.h(12)),
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator();

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: r.h(16)),
      child: Divider(height: 1, thickness: 1, color: AppColors.surfaceMuted),
    );
  }
}

// ─── Route Header ─────────────────────────────────────────────────────────────

class _RouteHeader extends StatelessWidget {
  const _RouteHeader({required this.c, required this.r});
  final TrajetActifController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = c.tripStatus.value;
      final isActive    = s == 'active' || s == 'in_progress' || s == 'running';
      final isCompleted = s == 'completed' || s == 'ended';
      final color = isCompleted
          ? AppColors.success
          : isActive
              ? AppColors.primary
              : AppColors.warning;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.departureCity.value.isNotEmpty
                            ? c.departureCity.value
                            : 'Départ',
                        style: AppTextStyles.h5(r),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: r.w(6)),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: r.text(16),
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        c.arrivalCity.value.isNotEmpty
                            ? c.arrivalCity.value
                            : 'Arrivée',
                        style: AppTextStyles.h5(r),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: r.h(8)),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: r.w(10), vertical: r.h(4)),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isActive) ...[
                        _LiveDot(color: color),
                        SizedBox(width: r.w(6)),
                      ] else ...[
                        Icon(
                          isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_empty_rounded,
                          size: r.text(12),
                          color: color,
                        ),
                        SizedBox(width: r.w(4)),
                      ],
                      Text(
                        c.statusLabel,
                        style: AppTextStyles.labelSmall(r).copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (c.gpsStale.value) ...[
            SizedBox(width: r.w(8)),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: r.w(8), vertical: r.h(6)),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.signal_wifi_off_rounded,
                      size: r.text(16), color: AppColors.accent),
                  SizedBox(height: r.h(2)),
                  Text(
                    'GPS\nperdu',
                    style: AppTextStyles.caption(r)
                        .copyWith(color: AppColors.accent),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

// ─── Live Dot ─────────────────────────────────────────────────────────────────

class _LiveDot extends StatefulWidget {
  const _LiveDot({required this.color});
  final Color color;

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => Opacity(
          opacity: 0.3 + _ctrl.value * 0.7,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
}

// ─── Milestone Progress ───────────────────────────────────────────────────────

class _MilestoneProgress extends StatelessWidget {
  const _MilestoneProgress({required this.c, required this.r});
  final TrajetActifController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final pct = c.progressPct.value.clamp(0.0, 1.0);
      final pickupLabel = c.pickupCityLabel.value.isNotEmpty
          ? c.pickupCityLabel.value
          : c.departureCity.value;
      final dropoffLabel = c.dropoffCityLabel.value.isNotEmpty
          ? c.dropoffCityLabel.value
          : c.arrivalCity.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(builder: (_, box) {
            const dotDiam = 14.0;
            const carDiam = 28.0;
            final totalW  = box.maxWidth;
            final trackW  = totalW - dotDiam;
            final rawLeft = dotDiam / 2 + (trackW * pct) - carDiam / 2;
            final carLeft = rawLeft.clamp(0.0, totalW - carDiam);

            return SizedBox(
              height: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: dotDiam / 2, right: dotDiam / 2,
                    top: (36 - 6) / 2,
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: dotDiam / 2,
                    top: (36 - 6) / 2,
                    child: Container(
                      height: 6,
                      width: (trackW * pct).clamp(0.0, trackW),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0, top: (36 - dotDiam) / 2,
                    child: Container(
                      width: dotDiam, height: dotDiam,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withValues(alpha: 0.40),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0, top: (36 - dotDiam) / 2,
                    child: Container(
                      width: dotDiam, height: dotDiam,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.40),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: carLeft, top: (36 - carDiam) / 2,
                    child: Container(
                      width: carDiam, height: carDiam,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.40),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: r.h(8)),
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_circle_up_rounded,
                      size: r.text(12), color: const Color(0xFF7C3AED)),
                  SizedBox(width: r.w(4)),
                  Text(
                    pickupLabel,
                    style: AppTextStyles.caption(r).copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dropoffLabel,
                    style: AppTextStyles.caption(r).copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: r.w(4)),
                  Icon(Icons.arrow_circle_down_rounded,
                      size: r.text(12), color: const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
        ],
      );
    });
  }
}

// ─── Metrics Row ──────────────────────────────────────────────────────────────

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
          padding: EdgeInsets.symmetric(
              vertical: r.h(12), horizontal: r.w(10)),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.16), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: r.text(18)),
              SizedBox(height: r.h(6)),
              Text(value, style: AppTextStyles.h6(r).copyWith(color: color)),
              Text(label, style: AppTextStyles.labelSmall(r)),
            ],
          ),
        ),
      );
}

// ─── Driver Card ──────────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.c, required this.r});
  final TrajetActifController c;
  final AppResponsive r;

  static String _initials(String n) {
    final parts = n.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'C';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final name = c.driverName.value;
      final s = c.tripStatus.value;
      final isActive    = s == 'active' || s == 'in_progress' || s == 'running';
      final isCompleted = s == 'completed' || s == 'ended';
      final badgeColor = isCompleted
          ? AppColors.textSecondary
          : isActive
              ? AppColors.success
              : AppColors.warning;
      final badgeLabel = isActive
          ? 'En route'
          : isCompleted
              ? 'Arrivé'
              : 'En attente';

      final isPending = s == 'pending';
      final distToPickup = isPending && c.hasVehicleGps.value
          ? _distKm(c.vehicleLatLng.value, c.departurePt.value)
          : null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: r.w(52),
                height: r.w(52),
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
                    style: AppTextStyles.h5(r).copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              SizedBox(width: r.w(14)),
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
                padding: EdgeInsets.symmetric(
                    horizontal: r.w(10), vertical: r.h(5)),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: badgeColor.withValues(alpha: 0.22)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive) ...[
                      _LiveDot(color: badgeColor),
                      SizedBox(width: r.w(5)),
                    ],
                    Icon(
                      isActive
                          ? Icons.directions_car_filled_rounded
                          : isCompleted
                              ? Icons.check_circle_rounded
                              : Icons.hourglass_empty_rounded,
                      size: r.text(13),
                      color: badgeColor,
                    ),
                    SizedBox(width: r.w(4)),
                    Text(
                      badgeLabel,
                      style: AppTextStyles.labelSmall(r)
                          .copyWith(color: badgeColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Barre de position conducteur — visible quand en attente ou actif
          if (isPending || isActive) ...[
            SizedBox(height: r.h(10)),
            _DriverPositionBar(
              isPending: isPending,
              isActive: isActive,
              distToPickupKm: distToPickup,
              speed: c.vehicleSpeed.value,
              hasGps: c.hasVehicleGps.value,
              r: r,
            ),
          ],
        ],
      );
    });
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

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
        height: r.h(52),
        child: ElevatedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, size: r.text(20)),
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

// ─── Trip Timeline (remplace RouteStopsCard) ──────────────────────────────────

class _TripTimeline extends StatelessWidget {
  const _TripTimeline({required this.c, required this.r});
  final TrajetActifController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final hasPickup  = c.pickupCityLabel.value.isNotEmpty ||
          c.pickupDetail.value.isNotEmpty;
      final hasDropoff = c.dropoffCityLabel.value.isNotEmpty ||
          c.dropoffDetail.value.isNotEmpty;
      if (!hasPickup && !hasDropoff) return const SizedBox.shrink();

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Fil de la timeline ──────────────────────────────────
          SizedBox(
            width: r.w(32),
            child: Column(
              children: [
                // Dot montée
                Container(
                  width: r.w(32),
                  height: r.w(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF7C3AED), width: 2),
                  ),
                  child: Icon(Icons.person_rounded,
                      color: const Color(0xFF7C3AED), size: r.text(15)),
                ),
                // Ligne pointillée
                SizedBox(
                  height: r.h(48),
                  child: LayoutBuilder(builder: (_, box) {
                    const dashH = 5.0;
                    const gap   = 4.0;
                    final count = (box.maxHeight / (dashH + gap)).floor();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(count, (_) => Padding(
                        padding: const EdgeInsets.only(bottom: gap),
                        child: Container(
                          width: 2,
                          height: dashH,
                          color: AppColors.border,
                        ),
                      )),
                    );
                  }),
                ),
                // Dot descente
                Container(
                  width: r.w(32),
                  height: r.w(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF59E0B), width: 2),
                  ),
                  child: Icon(Icons.flag_rounded,
                      color: const Color(0xFFF59E0B), size: r.text(15)),
                ),
              ],
            ),
          ),
          SizedBox(width: r.w(14)),
          // ── Texte des arrêts ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: r.h(6)),
                _StopInfo(
                  label: 'MONTÉE',
                  city: c.pickupCityLabel.value,
                  detail: c.pickupDetail.value,
                  note: c.pickupNote.value,
                  color: const Color(0xFF7C3AED),
                  r: r,
                ),
                SizedBox(height: r.h(28)),
                _StopInfo(
                  label: 'DESCENTE',
                  city: c.dropoffCityLabel.value,
                  detail: c.dropoffDetail.value,
                  note: c.dropoffNote.value,
                  color: const Color(0xFFF59E0B),
                  r: r,
                ),
                SizedBox(height: r.h(4)),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _StopInfo extends StatelessWidget {
  const _StopInfo({
    required this.label,
    required this.city,
    required this.detail,
    required this.note,
    required this.color,
    required this.r,
  });
  final String label, city, detail, note;
  final Color color;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(r).copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        if (city.isNotEmpty) ...[
          SizedBox(height: r.h(2)),
          Text(
            city,
            style: AppTextStyles.bodySmall(r)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
        if (detail.isNotEmpty) ...[
          SizedBox(height: r.h(1)),
          Text(
            detail,
            style: AppTextStyles.caption(r)
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
        if (note.isNotEmpty) ...[
          SizedBox(height: r.h(3)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.push_pin_outlined, size: r.text(10), color: color),
              SizedBox(width: r.w(3)),
              Expanded(
                child: Text(
                  note,
                  style: AppTextStyles.caption(r).copyWith(
                    color: color,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─── Driver Position Bar ──────────────────────────────────────────────────────

class _DriverPositionBar extends StatelessWidget {
  const _DriverPositionBar({
    required this.isPending,
    required this.isActive,
    required this.distToPickupKm,
    required this.speed,
    required this.hasGps,
    required this.r,
  });
  final bool isPending;
  final bool isActive;
  final double? distToPickupKm;
  final double speed;
  final bool hasGps;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    final color  = isPending ? AppColors.warning : AppColors.primary;
    final String line1;
    final String line2;
    final IconData ico;

    if (isPending) {
      ico   = Icons.my_location_rounded;
      if (!hasGps) {
        line1 = 'Localisation GPS en attente…';
        line2 = 'Le conducteur n\'a pas encore partagé sa position';
      } else if (distToPickupKm != null && distToPickupKm! < 100) {
        final d = distToPickupKm!;
        line1 = d < 1.0
            ? '${(d * 1000).round()} m de votre point de montée'
            : '${d.toStringAsFixed(1)} km de votre point de montée';
        line2 = 'Le conducteur se dirige vers vous';
      } else {
        line1 = 'Conducteur en route vers votre arrêt';
        line2 = 'Mise à jour toutes les 5 secondes';
      }
    } else {
      ico   = Icons.speed_rounded;
      line1 = speed > 5
          ? '${speed.toStringAsFixed(0)} km/h · En circulation'
          : 'Conducteur en mouvement';
      line2 = 'Position mise à jour en temps réel';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(9)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: r.w(34),
            height: r.w(34),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(ico, color: color, size: r.text(16)),
          ),
          SizedBox(width: r.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line1,
                  style: AppTextStyles.bodySmall(r).copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                Text(
                  line2,
                  style: AppTextStyles.caption(r)
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (isActive && hasGps)
            _LiveDot(color: color),
        ],
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────

double _distKm(LatLng a, LatLng b) {
  const r = 6371.0;
  final dLat = (b.latitude  - a.latitude)  * math.pi / 180;
  final dLng = (b.longitude - a.longitude) * math.pi / 180;
  final x = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(a.latitude  * math.pi / 180) *
      math.cos(b.latitude  * math.pi / 180) *
      math.sin(dLng / 2) * math.sin(dLng / 2);
  return r * 2 * math.atan2(math.sqrt(x), math.sqrt(1 - x));
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/driver_arrival_controller.dart';

class DriverArrivalView extends StatelessWidget {
  const DriverArrivalView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<DriverArrivalController>()
        ? Get.find<DriverArrivalController>()
        : Get.put(DriverArrivalController());
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFF0),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Carte principale ───────────────────────────────────────────
          _ArrivalMap(controller: controller),

          // ── Barre du haut ──────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(child: _HeaderBar(r: r, controller: controller)),
          ),

          // ── Boutons flottants (droite) ─────────────────────────────────
          Positioned(
            bottom: r.h(390),
            right: r.w(16),
            child: _FloatingButtons(r: r, controller: controller),
          ),

          // ── Panneau du bas ─────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomPanel(r: r, controller: controller),
          ),
        ],
      ),
    );
  }
}

// ── Carte ──────────────────────────────────────────────────────────────────

class _ArrivalMap extends StatelessWidget {
  const _ArrivalMap({required this.controller});
  final DriverArrivalController controller;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: controller.mapController,
      options: MapOptions(
        initialCenter: controller.mapInitialCenter,
        initialZoom: controller.mapInitialZoom,
        minZoom: 5.0,
        maxZoom: 18.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom |
                 InteractiveFlag.drag       |
                 InteractiveFlag.doubleTapZoom,
        ),
      ),
      children: [
        // Tuiles OpenStreetMap
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.covoiturage.benin',
          maxZoom: 19,
        ),

        // ── Route du trajet : prise en charge → destination (gris) ──────
        PolylineLayer(polylines: [
          Polyline(
            points: [controller.pickupLatLng, controller.destinationLatLng],
            color: const Color(0xFF9DBBAB),
            strokeWidth: 5.0,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        ]),

        // ── Route conducteur → prise en charge (gris clair, totale) ─────
        PolylineLayer(polylines: [
          Polyline(
            points: [controller.driverStartLatLng, controller.pickupLatLng],
            color: const Color(0xFFCFD8DC),
            strokeWidth: 4.0,
            strokeCap: StrokeCap.round,
            strokeJoin: StrokeJoin.round,
          ),
        ]),

        // ── Route conducteur → prise en charge (vert, portion parcourue) ─
        Obx(() => PolylineLayer(polylines: [
          if (controller.driverProgress.value > 0)
            Polyline(
              points: [controller.driverStartLatLng, controller.driverLatLng.value],
              color: AppColors.primary,
              strokeWidth: 5.0,
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
              borderColor: Colors.white.withValues(alpha: 0.5),
              borderStrokeWidth: 2.0,
            ),
        ])),

        // ── Marqueurs ────────────────────────────────────────────────────
        Obx(() => MarkerLayer(markers: [

          // Destination / dépôt (rouge)
          Marker(
            point: controller.destinationLatLng,
            width: 52,
            height: 64,
            alignment: Alignment.bottomCenter,
            child: _DestinationPin(),
          ),

          // Prise en charge (bleu — position du passager)
          Marker(
            point: controller.pickupLatLng,
            width: 52,
            height: 64,
            alignment: Alignment.bottomCenter,
            child: _PickupPin(),
          ),

          // Conducteur (vert — en mouvement)
          Marker(
            point: controller.driverLatLng.value,
            width: 58,
            height: 58,
            child: _DriverCarMarker(
              isArrived: controller.status.value == DriverArrivalStatus.arrived,
            ),
          ),
        ])),
      ],
    );
  }
}

// ── Pins carte ─────────────────────────────────────────────────────────────

class _PickupPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Color(0x504444FF), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
        ),
        Container(
          width: 3, height: 12,
          decoration: const BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class _DestinationPin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: const [BoxShadow(color: Color(0x50EF4444), blurRadius: 10, offset: Offset(0, 3))],
          ),
          child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
        ),
        Container(
          width: 3, height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFFEF4444),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class _DriverCarMarker extends StatelessWidget {
  const _DriverCarMarker({this.isArrived = false});
  final bool isArrived;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isArrived ? AppColors.primary : const Color(0xFF00C278),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: (isArrived ? AppColors.primary : const Color(0xFF00C278)).withValues(alpha: 0.5),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        isArrived ? Icons.check_rounded : Icons.directions_car_filled_rounded,
        color: Colors.white,
        size: 26,
      ),
    );
  }
}

// ── Boutons flottants droite ────────────────────────────────────────────────

class _FloatingButtons extends StatelessWidget {
  const _FloatingButtons({required this.r, required this.controller});
  final AppResponsive r;
  final DriverArrivalController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voir tout (prise en charge + destination)
        _FabBtn(
          icon: Icons.fit_screen_rounded,
          onTap: controller.fitAllPoints,
          tooltip: 'Voir tout',
        ),
        SizedBox(height: r.h(10)),
        // Centrer sur le conducteur
        _FabBtn(
          icon: Icons.directions_car_filled_rounded,
          onTap: controller.centerOnDriver,
          color: AppColors.primary,
          tooltip: 'Conducteur',
        ),
      ],
    );
  }
}

class _FabBtn extends StatelessWidget {
  const _FabBtn({required this.icon, required this.onTap, this.color, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: r.w(44),
        height: r.w(44),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 8, offset: Offset(0, 2))],
        ),
        child: Icon(icon, color: color ?? AppColors.textPrimary, size: r.text(20)),
      ),
    );
  }
}

// ── Barre du haut ───────────────────────────────────────────────────────────

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.r, required this.controller});
  final AppResponsive r;
  final DriverArrivalController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.w(16), vertical: r.h(12)),
      child: Row(
        children: [
          _GlassBtn(icon: Icons.chevron_left_rounded, onTap: Get.back),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: r.w(16), vertical: r.h(8)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9999),
              boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 10)],
            ),
            child: Obx(() {
              final isArrived = controller.status.value == DriverArrivalStatus.arrived;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PulsingDot(color: isArrived ? AppColors.primary : AppColors.warning),
                  SizedBox(width: r.w(8)),
                  Text(
                    isArrived ? 'Conducteur arrivé !' : 'Conducteur en route',
                    style: AppTextStyles.caption(r).copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              );
            }),
          ),
          const Spacer(),
          _GlassBtn(
            icon: Icons.phone_rounded,
            onTap: controller.callDriver,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
        ..repeat(reverse: true);
    _scale = Tween(begin: 0.7, end: 1.0)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 8, height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  const _GlassBtn({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9999),
        child: Container(
          width: r.w(44),
          height: r.w(44),
          decoration: BoxDecoration(
            color: color != null ? color!.withValues(alpha: 0.15) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color ?? Colors.white.withValues(alpha: 0.5)),
            boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 8)],
          ),
          child: Icon(icon, size: r.text(20), color: color ?? AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ── Panneau du bas ──────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({required this.r, required this.controller});
  final AppResponsive r;
  final DriverArrivalController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(24))),
        boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      padding: EdgeInsets.fromLTRB(
        r.w(16), r.h(16), r.w(16),
        r.h(16) + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: r.w(36), height: r.h(4),
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999)),
            ),
          ),
          SizedBox(height: r.h(14)),

          // Statut + ETA
          _EtaRow(r: r, controller: controller),
          SizedBox(height: r.h(14)),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: r.h(14)),

          // Prise en charge → Destination
          _RouteRow(r: r, controller: controller),
          SizedBox(height: r.h(14)),
          Container(height: 1, color: AppColors.border),
          SizedBox(height: r.h(12)),

          // Infos conducteur
          _DriverRow(r: r, controller: controller),
          SizedBox(height: r.h(12)),

          // Messages rapides
          _QuickMessages(r: r, controller: controller),

          // Bouton CTA (quand conducteur arrivé)
          Obx(() => controller.status.value == DriverArrivalStatus.arrived
              ? Column(children: [
                  SizedBox(height: r.h(12)),
                  AppPrimaryButton(
                    responsive: r,
                    label: 'Trajet commencé → Suivre en direct',
                    onTap: controller.goToLiveTracking,
                    height: r.h(52),
                    borderRadius: r.radius(14),
                  ),
                ])
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

// ── ETA compacte ────────────────────────────────────────────────────────────

class _EtaRow extends StatelessWidget {
  const _EtaRow({required this.r, required this.controller});
  final AppResponsive r;
  final DriverArrivalController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isArrived  = controller.status.value == DriverArrivalStatus.arrived;
      final isArriving = controller.status.value == DriverArrivalStatus.arriving;
      final color = isArrived ? AppColors.primary : (isArriving ? AppColors.warning : AppColors.blue);

      return Row(
        children: [
          Container(
            width: r.w(48), height: r.w(48),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(
              isArrived ? Icons.check_circle_rounded : Icons.directions_car_filled_rounded,
              color: color, size: r.text(22),
            ),
          ),
          SizedBox(width: r.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isArrived ? 'Conducteur arrivé !' : 'Conducteur en route',
                  style: AppTextStyles.subtitle(r),
                ),
                SizedBox(height: r.h(2)),
                Text(
                  controller.statusLabel,
                  style: AppTextStyles.caption(r).copyWith(color: color),
                ),
              ],
            ),
          ),
          if (!isArrived)
            Container(
              padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(6)),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(r.radius(10)),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Text(
                '${controller.etaMinutes.value} min',
                style: AppTextStyles.subtitle(r).copyWith(color: color, fontWeight: FontWeight.w800),
              ),
            ),
        ],
      );
    });
  }
}

// ── Route prise en charge → destination ────────────────────────────────────

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.r, required this.controller});
  final AppResponsive r;
  final DriverArrivalController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ride           = controller.ride.value;
      final origin         = ride?.origin         ?? 'Prise en charge';
      final destination    = ride?.destination    ?? 'Destination';
      final departureNote  = ride?.departureNote  ?? '';
      final arrivalNote    = ride?.arrivalNote    ?? '';

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colonne icônes + ligne
          Column(
            children: [
              SizedBox(height: r.h(4)),
              Container(
                width: r.w(12), height: r.w(12),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [BoxShadow(color: AppColors.blue.withValues(alpha: 0.4), blurRadius: 4)],
                ),
              ),
              Container(
                width: 2,
                height: r.h(28),
                margin: EdgeInsets.symmetric(vertical: r.h(4)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.blue.withValues(alpha: 0.6), const Color(0xFFEF4444).withValues(alpha: 0.6)],
                  ),
                ),
              ),
              Icon(Icons.location_on_rounded, color: const Color(0xFFEF4444), size: r.text(18)),
            ],
          ),
          SizedBox(width: r.w(14)),
          // Textes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Prise en charge', style: AppTextStyles.caption(r).copyWith(color: AppColors.textMuted)),
                Text(origin, style: AppTextStyles.subtitle(r)),
                if (departureNote.isNotEmpty)
                  Text(departureNote, style: AppTextStyles.caption(r).copyWith(color: AppColors.textHint)),
                SizedBox(height: r.h(8)),
                Text('Dépôt / Destination', style: AppTextStyles.caption(r).copyWith(color: AppColors.textMuted)),
                Text(destination, style: AppTextStyles.subtitle(r)),
                if (arrivalNote.isNotEmpty)
                  Text(arrivalNote, style: AppTextStyles.caption(r).copyWith(color: AppColors.textHint)),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ── Infos conducteur ────────────────────────────────────────────────────────

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.r, required this.controller});
  final AppResponsive r;
  final DriverArrivalController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ride       = controller.ride.value;
      final driverName = ride?.driverName ?? 'Votre conducteur';
      final vehicle    = ride?.vehicle    ?? 'Véhicule';
      final rating     = ride?.rating     ?? '4.8';

      return Row(
        children: [
          _Avatar(name: driverName, size: r.w(44)),
          SizedBox(width: r.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(driverName, style: AppTextStyles.subtitle(r)),
                SizedBox(height: r.h(2)),
                Row(children: [
                  Icon(Icons.star_rounded, size: r.text(13), color: AppColors.warning),
                  SizedBox(width: r.w(4)),
                  Text('$rating · $vehicle', style: AppTextStyles.caption(r)),
                ]),
              ],
            ),
          ),
          _GlassBtn(icon: Icons.phone_rounded, onTap: controller.callDriver, color: AppColors.primary),
        ],
      );
    });
  }
}

// ── Messages rapides ────────────────────────────────────────────────────────

class _QuickMessages extends StatelessWidget {
  const _QuickMessages({required this.r, required this.controller});
  final AppResponsive r;
  final DriverArrivalController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: r.h(36),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: controller.quickMessages.length,
        separatorBuilder: (_, _) => SizedBox(width: r.w(8)),
        itemBuilder: (_, i) {
          final msg = controller.quickMessages[i];
          return InkWell(
            onTap: () => controller.sendMessage(msg),
            borderRadius: BorderRadius.circular(9999),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: r.w(14), vertical: r.h(6)),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(msg,
                  style: AppTextStyles.caption(r).copyWith(fontWeight: FontWeight.w500)),
            ),
          );
        },
      ),
    );
  }
}

// ── Widgets partagés ────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.size});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final parts  = name.trim().split(RegExp(r'\s+'));
    final first  = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : 'C';
    final second = parts.length > 1  && parts[1].isNotEmpty  ? parts[1][0]    : '';

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          (first + second).toUpperCase(),
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

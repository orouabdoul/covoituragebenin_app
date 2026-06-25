import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';

import '../controllers/interactive_map_controller.dart';

class InteractiveMapView extends StatelessWidget {
  const InteractiveMapView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InteractiveMapController>();
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFF8),
      body: Stack(
        children: [
          // ── Map canvas ─────────────────────────────────────────────
          Positioned.fill(
            child: AnimatedBuilder(
              animation: controller.pulseController,
              builder: (_, animChild) => CustomPaint(
                painter: _MapPainter(pulse: controller.pulseController.value),
                child: animChild,
              ),
            ),
          ),

          // ── Route polyline overlay ──────────────────────────────────
          Positioned.fill(
            child: Obx(() => CustomPaint(
              painter: _RoutePainter(stops: controller.stops.toList()),
            )),
          ),

          // ── Stop markers ────────────────────────────────────────────
          Positioned.fill(
            child: Obx(() => Stack(
              children: [
                for (var i = 0; i < controller.stops.length; i++)
                  _StopMarker(
                    responsive: responsive,
                    stop: controller.stops[i],
                    index: i + 1,
                    controller: controller,
                  ),
              ],
            )),
          ),

          // ── Top bar ─────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _TopBar(responsive: responsive, controller: controller),
          ),

          // ── Optimization banner ─────────────────────────────────────
          Obx(() => controller.showOptimizationBanner.value
              ? Positioned(
                  top: responsive.h(110),
                  left: responsive.w(16),
                  right: responsive.w(16),
                  child: _OptimizationBanner(responsive: responsive),
                )
              : const SizedBox.shrink()),

          // ── DraggableScrollableSheet for stops ──────────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.15,
            maxChildSize: 0.92,
            builder: (_, scrollCtrl) => _StopsPanel(
              responsive: responsive,
              controller: controller,
              scrollController: scrollCtrl,
            ),
          ),

          // ── Recalculate FAB ─────────────────────────────────────────
          Positioned(
            bottom: responsive.h(320),
            right: responsive.w(16),
            child: _RecalculateFab(responsive: responsive, controller: controller),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final InteractiveMapController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        responsive.w(16),
        MediaQuery.of(context).padding.top + responsive.h(8),
        responsive.w(16),
        responsive.h(12),
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: responsive.w(38),
                  height: responsive.w(38),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(responsive.radius(10)),
                  ),
                  child: Icon(Icons.arrow_back_rounded, size: responsive.text(20), color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Carte interactive du trajet', style: AppTextStyles.h6(responsive)),
                    Obx(() {
                      final done = controller.stops.where((s) => s.status == StopStatus.done).length;
                      return Text(
                        '$done/${controller.stops.length} arrêts complétés',
                        style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
                      );
                    }),
                  ],
                ),
              ),
              Obx(() => _StatChip(
                responsive: responsive,
                icon: Icons.route_rounded,
                label: controller.routeDistance.value,
                color: AppColors.primary,
              )),
              SizedBox(width: responsive.w(8)),
              Obx(() => _StatChip(
                responsive: responsive,
                icon: Icons.access_time_rounded,
                label: controller.routeEta.value,
                color: const Color(0xFF3B82F6),
              )),
            ],
          ),
          SizedBox(height: responsive.h(8)),
          // Progress bar
          Obx(() {
            final done = controller.stops.where((s) => s.status == StopStatus.done).length;
            final total = controller.stops.length;
            return ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: responsive.h(4),
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.responsive, required this.icon, required this.label, required this.color});

  final AppResponsive responsive;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(responsive.radius(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.text(12), color: color),
          SizedBox(width: responsive.w(4)),
          Text(label, style: AppTextStyles.caption(responsive).copyWith(color: color, fontWeight: FontWeight.w700, fontSize: responsive.text(11))),
        ],
      ),
    );
  }
}

// ── Optimization banner ───────────────────────────────────────────────────────

class _OptimizationBanner extends StatelessWidget {
  const _OptimizationBanner({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 18),
          SizedBox(width: responsive.w(8)),
          Expanded(
            child: Text(
              'Itinéraire recalculé — trajet optimisé avec succès',
              style: AppTextStyles.caption(responsive).copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Map marker ────────────────────────────────────────────────────────────────

class _StopMarker extends StatelessWidget {
  const _StopMarker({
    required this.responsive,
    required this.stop,
    required this.index,
    required this.controller,
  });

  final AppResponsive responsive;
  final MapStop stop;
  final int index;
  final InteractiveMapController controller;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final x = stop.posX * size.width;
    final y = stop.posY * (size.height * 0.65);

    final color = controller.stopColor(stop);
    final isDone = stop.status == StopStatus.done;
    final isApproaching = stop.status == StopStatus.approaching;

    return Positioned(
      left: x - responsive.w(18),
      top: y - responsive.w(36),
      child: GestureDetector(
        onTap: () => _showStopDetail(context, stop),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Pulse ring for approaching stop
            if (isApproaching)
              AnimatedBuilder(
                animation: controller.pulseController,
                builder: (_, pulseChild) => Container(
                  width: responsive.w(36) * (1 + controller.pulseController.value * 0.4),
                  height: responsive.w(36) * (1 + controller.pulseController.value * 0.4),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15 * (1 - controller.pulseController.value)),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            // Marker
            Container(
              width: responsive.w(36),
              height: responsive.w(36),
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFFE5E7EB) : color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Center(
                child: isDone
                    ? Icon(Icons.check_rounded, color: Colors.white, size: responsive.text(16))
                    : Text(
                        '$index',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: responsive.text(13)),
                      ),
              ),
            ),
            // Stem
            Container(width: 2, height: responsive.h(8), color: isDone ? const Color(0xFFE5E7EB) : color),
            // Pin bottom
            Container(
              width: responsive.w(6),
              height: responsive.w(6),
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFFE5E7EB) : color,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStopDetail(BuildContext context, MapStop stop) {
    final controller = Get.find<InteractiveMapController>();
    final responsive = AppResponsive(context);
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(responsive.w(20)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.radius(20))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999)))),
            SizedBox(height: responsive.h(16)),
            Row(
              children: [
                Container(
                  width: responsive.w(40),
                  height: responsive.w(40),
                  decoration: BoxDecoration(
                    color: controller.stopBgColor(stop),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    stop.type == StopType.pickup ? Icons.trip_origin_rounded : Icons.location_on_rounded,
                    color: controller.stopColor(stop),
                    size: responsive.text(20),
                  ),
                ),
                SizedBox(width: responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(stop.passengerName, style: AppTextStyles.subtitle(responsive).copyWith(fontWeight: FontWeight.w700)),
                      Text(controller.stopTypeLabel(stop.type), style: AppTextStyles.caption(responsive).copyWith(color: controller.stopColor(stop))),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(4)),
                  decoration: BoxDecoration(
                    color: controller.stopStatusColor(stop.status).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    controller.stopStatusLabel(stop.status),
                    style: AppTextStyles.caption(responsive).copyWith(color: controller.stopStatusColor(stop.status), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.h(14)),
            Row(
              children: [
                Icon(Icons.pin_drop_rounded, size: responsive.text(14), color: AppColors.textHint),
                SizedBox(width: responsive.w(6)),
                Expanded(child: Text(stop.address, style: AppTextStyles.caption(responsive))),
                Text(stop.eta, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
            if (stop.status != StopStatus.done) ...[
              SizedBox(height: responsive.h(16)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    controller.markStopDone(stop.id);
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text('Marquer comme terminé'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(12))),
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

// ── Stops panel ───────────────────────────────────────────────────────────────

class _StopsPanel extends StatelessWidget {
  const _StopsPanel({
    required this.responsive,
    required this.controller,
    required this.scrollController,
  });

  final AppResponsive responsive;
  final InteractiveMapController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.radius(24))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: responsive.h(10)),
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999)))),
                SizedBox(height: responsive.h(16)),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.w(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Arrêts du trajet', style: AppTextStyles.h6(responsive)),
                            Obx(() {
                              final approaching = controller.stops.where((s) => s.status == StopStatus.approaching).length;
                              return Text(
                                approaching > 0 ? '$approaching arrêt(s) en approche' : 'Glissez vers le haut pour voir tous les arrêts',
                                style: AppTextStyles.caption(responsive).copyWith(
                                  color: approaching > 0 ? const Color(0xFF3B82F6) : AppColors.textHint,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      Obx(() => _StatChip(
                        responsive: responsive,
                        icon: Icons.local_gas_station_rounded,
                        label: controller.routeFuel.value,
                        color: const Color(0xFFF59E0B),
                      )),
                    ],
                  ),
                ),
                SizedBox(height: responsive.h(16)),
              ],
            ),
          ),
          // Stop list
          Obx(() => SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _StopListTile(
                responsive: responsive,
                stop: controller.stops[i],
                index: i + 1,
                controller: controller,
                isLast: i == controller.stops.length - 1,
              ),
              childCount: controller.stops.length,
            ),
          )),
          SliverToBoxAdapter(child: SizedBox(height: responsive.h(32))),
        ],
      ),
    );
  }
}

class _StopListTile extends StatelessWidget {
  const _StopListTile({
    required this.responsive,
    required this.stop,
    required this.index,
    required this.controller,
    required this.isLast,
  });

  final AppResponsive responsive;
  final MapStop stop;
  final int index;
  final InteractiveMapController controller;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = controller.stopColor(stop);
    final isDone = stop.status == StopStatus.done;

    return Padding(
      padding: EdgeInsets.fromLTRB(responsive.w(16), 0, responsive.w(16), responsive.h(12)),
      child: GestureDetector(
        onTap: () {
          // Simulate tapping shows the bottom-sheet detail
          final markerWidget = _StopMarker(responsive: responsive, stop: stop, index: index, controller: controller);
          markerWidget._showStopDetail(context, stop);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(responsive.w(14)),
          decoration: BoxDecoration(
            color: isDone ? AppColors.surfaceMuted : color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(responsive.radius(14)),
            border: Border.all(
              color: isDone ? AppColors.border : color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              // Index badge
              Container(
                width: responsive.w(36),
                height: responsive.w(36),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFFE5E7EB) : color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? Icon(Icons.check_rounded, color: Colors.white, size: responsive.text(16))
                      : Text('$index', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: responsive.text(13))),
                ),
              ),
              // Vertical connector
              if (!isLast)
                Padding(
                  padding: EdgeInsets.only(left: responsive.w(16)),
                  child: Container(width: 2, height: responsive.h(40), color: AppColors.border),
                ),
              SizedBox(width: responsive.w(12)),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(stop.passengerName, style: AppTextStyles.subtitle(responsive).copyWith(fontWeight: FontWeight.w700, color: isDone ? AppColors.textGhost : AppColors.textPrimary)),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(3)),
                          decoration: BoxDecoration(
                            color: controller.stopStatusColor(stop.status).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Text(
                            controller.stopStatusLabel(stop.status),
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: controller.stopStatusColor(stop.status),
                              fontWeight: FontWeight.w600,
                              fontSize: responsive.text(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.h(2)),
                    Row(
                      children: [
                        Icon(
                          stop.type == StopType.pickup ? Icons.trip_origin_rounded : Icons.location_on_rounded,
                          size: responsive.text(12),
                          color: isDone ? AppColors.textGhost : color,
                        ),
                        SizedBox(width: responsive.w(4)),
                        Expanded(
                          child: Text(
                            stop.address,
                            style: AppTextStyles.caption(responsive).copyWith(color: isDone ? AppColors.textGhost : AppColors.textHint),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isDone) ...[
                          SizedBox(width: responsive.w(8)),
                          Text(
                            stop.eta,
                            style: AppTextStyles.caption(responsive).copyWith(color: color, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: responsive.h(4)),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: responsive.w(6), vertical: responsive.h(2)),
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.border : color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        controller.stopTypeLabel(stop.type),
                        style: AppTextStyles.caption(responsive).copyWith(
                          color: isDone ? AppColors.textGhost : color,
                          fontSize: responsive.text(10),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isDone)
                Icon(Icons.chevron_right_rounded, color: AppColors.textGhost, size: responsive.text(20)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Recalculate FAB ───────────────────────────────────────────────────────────

class _RecalculateFab extends StatelessWidget {
  const _RecalculateFab({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final InteractiveMapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: controller.recalculateRoute,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: responsive.w(52),
        height: responsive.w(52),
        decoration: BoxDecoration(
          color: controller.isRecalculating.value ? AppColors.textGhost : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.40), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: controller.isRecalculating.value
            ? const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
            : Icon(Icons.my_location_rounded, color: Colors.white, size: responsive.text(22)),
      ),
    ));
  }
}

// ── Map painter ───────────────────────────────────────────────────────────────

class _MapPainter extends CustomPainter {
  const _MapPainter({required this.pulse});

  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height * 0.65;
    final w = size.width;

    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = const Color(0xFFE8EFF8));

    // Water body (ocean/lagoon)
    final lagoonPath = Path()
      ..moveTo(0, h * 0.78)
      ..quadraticBezierTo(w * 0.3, h * 0.72, w * 0.55, h * 0.82)
      ..quadraticBezierTo(w * 0.75, h * 0.90, w, h * 0.80)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(lagoonPath, Paint()..color = const Color(0xFFC5D8F0));

    // Green zones (parks/vegetation)
    _drawBlock(canvas, Rect.fromLTWH(w * 0.05, h * 0.05, w * 0.12, h * 0.14), const Color(0xFFB8D4A8));
    _drawBlock(canvas, Rect.fromLTWH(w * 0.70, h * 0.10, w * 0.18, h * 0.12), const Color(0xFFB8D4A8));
    _drawBlock(canvas, Rect.fromLTWH(w * 0.40, h * 0.55, w * 0.10, h * 0.10), const Color(0xFFB8D4A8));

    // City blocks (light gray)
    final blockRects = [
      Rect.fromLTWH(w * 0.05, h * 0.22, w * 0.18, h * 0.22),
      Rect.fromLTWH(w * 0.27, h * 0.10, w * 0.14, h * 0.18),
      Rect.fromLTWH(w * 0.45, h * 0.10, w * 0.20, h * 0.16),
      Rect.fromLTWH(w * 0.70, h * 0.26, w * 0.22, h * 0.20),
      Rect.fromLTWH(w * 0.55, h * 0.42, w * 0.16, h * 0.18),
      Rect.fromLTWH(w * 0.10, h * 0.50, w * 0.26, h * 0.20),
    ];
    for (final r in blockRects) {
      _drawBlock(canvas, r, const Color(0xFFD8E2EC));
    }

    // Main roads (wider, darker)
    final roadPaint = Paint()
      ..color = const Color(0xFFF7F0E0)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    final roads = [
      [Offset(0, h * 0.35), Offset(w, h * 0.35)],
      [Offset(w * 0.35, 0), Offset(w * 0.35, h)],
      [Offset(0, h * 0.60), Offset(w, h * 0.60)],
      [Offset(w * 0.65, 0), Offset(w * 0.65, h * 0.70)],
      [Offset(0, h * 0.20), Offset(w * 0.60, h * 0.45)],
    ];
    for (final r in roads) {
      canvas.drawLine(r[0], r[1], roadPaint);
    }

    // Secondary roads (thinner)
    final secPaint = Paint()
      ..color = const Color(0xFFEEE8D8)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final secRoads = [
      [Offset(w * 0.15, 0), Offset(w * 0.15, h * 0.55)],
      [Offset(w * 0.55, h * 0.35), Offset(w * 0.55, h * 0.75)],
      [Offset(0, h * 0.48), Offset(w, h * 0.48)],
      [Offset(w * 0.80, 0), Offset(w * 0.80, h)],
    ];
    for (final r in secRoads) {
      canvas.drawLine(r[0], r[1], secPaint);
    }

    // Road center dashes
    _drawDashedLine(canvas, Offset(0, h * 0.35), Offset(w, h * 0.35), const Color(0xFFCCC6A8), 3);
    _drawDashedLine(canvas, Offset(w * 0.35, 0), Offset(w * 0.35, h), const Color(0xFFCCC6A8), 3);
  }

  void _drawBlock(Canvas canvas, Rect rect, Color color) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      Paint()..color = color,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color, double width) {
    final paint = Paint()..color = color..strokeWidth = width..strokeCap = StrokeCap.round;
    const dashLen = 12.0;
    const gapLen = 10.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    final ux = dx / len;
    final uy = dy / len;
    double dist = 0;
    while (dist < len) {
      final dashEnd = math.min(dist + dashLen, len);
      canvas.drawLine(
        Offset(start.dx + ux * dist, start.dy + uy * dist),
        Offset(start.dx + ux * dashEnd, start.dy + uy * dashEnd),
        paint,
      );
      dist += dashLen + gapLen;
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) => old.pulse != pulse;
}

// ── Route polyline painter ─────────────────────────────────────────────────────

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.stops});

  final List<MapStop> stops;

  @override
  void paint(Canvas canvas, Size size) {
    if (stops.length < 2) return;
    final h = size.height * 0.65;
    final w = size.width;

    final path = Path();
    final points = stops.map((s) => Offset(s.posX * w, s.posY * h)).toList();

    path.moveTo(points[0].dx, points[0].dy);
    for (var i = 1; i < points.length; i++) {
      final cp1 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i - 1].dy);
      final cp2 = Offset((points[i - 1].dx + points[i].dx) / 2, points[i].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, points[i].dx, points[i].dy);
    }

    // Shadow
    canvas.drawPath(path, Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

    // Route line
    canvas.drawPath(path, Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);

    // Arrow direction dots
    for (var i = 1; i < points.length; i++) {
      final mid = Offset((points[i - 1].dx + points[i].dx) / 2, (points[i - 1].dy + points[i].dy) / 2);
      canvas.drawCircle(mid, 3, Paint()..color = Colors.white);
      canvas.drawCircle(mid, 2, Paint()..color = AppColors.primary);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.stops != stops;
}

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';

import '../controllers/interactive_map_controller.dart';

// ── Root view ─────────────────────────────────────────────────────────────────

class InteractiveMapView extends StatefulWidget {
  const InteractiveMapView({super.key});

  @override
  State<InteractiveMapView> createState() => _InteractiveMapViewState();
}

class _InteractiveMapViewState extends State<InteractiveMapView> {
  final MapController _mapController = MapController();
  late final InteractiveMapController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<InteractiveMapController>();

    // Quand le controller signale un mouvement de caméra (départ chargé ou arrêt suivant)
    ever(_ctrl.mapMoveTo, (LatLng? pos) {
      if (pos == null || !mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(pos, _ctrl.mapMoveZoom.value);
        }
      });
    });

    // Fit-all quand les données arrivent
    ever(_ctrl.fitAllRequest, (_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _fitAllPoints();
      });
    });
  }

  void _fitAllPoints() {
    final allPts = [
      _ctrl.driverPosition.value,
      ..._ctrl.stops.map((s) => s.latlng),
    ];
    if (allPts.length < 2) {
      if (allPts.isNotEmpty) {
        _mapController.move(allPts.first, 14.0);
      }
      return;
    }
    final bounds = LatLngBounds.fromPoints(allPts);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(48, 120, 48, 320),
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: const Color(0xFFE8EFF8),
      body: Obx(() {
        final loading = _ctrl.isLoading.value;
        final hasError = _ctrl.hasError.value;

        return Stack(
          children: [
            // ── Carte OpenStreetMap ──────────────────────────────────
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                // Position initiale → Cotonou ; sera mise à jour dès GPS/API
                initialCenter: _ctrl.driverPosition.value,
                initialZoom: 13.0,
                minZoom: 8.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.covoiturage.benin',
                  // Garde les tuiles en mémoire pour éviter les re-téléchargements
                  maxNativeZoom: 18,
                  keepBuffer: 4,
                ),

                // Itinéraire — affiché seulement si ≥ 2 points (évite le crash)
                Obx(() {
                  final pts = _ctrl.routePolyline;
                  if (pts.length < 2) return const SizedBox.shrink();
                  return PolylineLayer(
                    polylines: [
                      Polyline(
                        points: pts,
                        color: AppColors.primary,
                        strokeWidth: 5.0,
                        borderColor: Colors.white.withValues(alpha: 0.85),
                        borderStrokeWidth: 2.5,
                      ),
                    ],
                  );
                }),

                // Marqueurs
                Obx(() => MarkerLayer(
                      markers: [
                        // Position conducteur
                        Marker(
                          point: _ctrl.driverPosition.value,
                          width: 52,
                          height: 52,
                          child: _DriverPositionMarker(controller: _ctrl),
                        ),
                        // Arrêts
                        for (var i = 0; i < _ctrl.stops.length; i++)
                          Marker(
                            point: _ctrl.stops[i].latlng,
                            width: 50,
                            height: 64,
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () => _showStopDetail(
                                context,
                                _ctrl.stops[i],
                                _ctrl,
                                r,
                              ),
                              child: _StopPin(
                                stop: _ctrl.stops[i],
                                index: i + 1,
                                controller: _ctrl,
                              ),
                            ),
                          ),
                      ],
                    )),
              ],
            ),

            // ── Top bar ──────────────────────────────────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(responsive: r, controller: _ctrl),
            ),

            // ── Bannière optimisation ─────────────────────────────────
            Obx(() => _ctrl.showOptimizationBanner.value
                ? Positioned(
                    top: r.h(110),
                    left: r.w(16),
                    right: r.w(16),
                    child: _OptimizationBanner(responsive: r),
                  )
                : const SizedBox.shrink()),

            // ── Overlay chargement ────────────────────────────────────
            if (loading)
              Positioned(
                top: r.h(110),
                left: r.w(16),
                right: r.w(16),
                child: _LoadingBanner(responsive: r),
              ),

            // ── Overlay erreur ────────────────────────────────────────
            if (hasError && !loading)
              Obx(() => Positioned(
                top: r.h(110),
                left: r.w(16),
                right: r.w(16),
                child: _ErrorBanner(
                  responsive: r,
                  message: _ctrl.errorMessage.value,
                  canRetry: _ctrl.canRetry.value,
                  onRetry: _ctrl.refresh,
                ),
              )),

            // ── Bannière mode hors-ligne (données locales) ────────────
            Obx(() => (_ctrl.isFallbackMode.value && !loading && !hasError)
                ? Positioned(
                    top: r.h(110),
                    left: r.w(16),
                    right: r.w(16),
                    child: _FallbackBanner(
                      responsive: r,
                      message: _ctrl.fallbackMessage.value,
                      onRetry: _ctrl.refresh,
                    ),
                  )
                : const SizedBox.shrink()),

            // ── Panel des arrêts (draggable) ──────────────────────────
            DraggableScrollableSheet(
              initialChildSize: 0.33,
              minChildSize: 0.14,
              maxChildSize: 0.92,
              builder: (_, scrollCtrl) => _StopsPanel(
                responsive: r,
                controller: _ctrl,
                scrollController: scrollCtrl,
              ),
            ),

            // ── FABs droite ───────────────────────────────────────────
            Positioned(
              bottom: r.h(310),
              right: r.w(16),
              child: Column(
                children: [
                  // Recalculer l'itinéraire
                  _RecalculateFab(responsive: r, controller: _ctrl),
                  SizedBox(height: r.h(10)),
                  // Centrer sur le conducteur
                  _CenterDriverFab(responsive: r, controller: _ctrl),
                  SizedBox(height: r.h(10)),
                  // Fit tous les arrêts
                  _FitAllFab(
                    responsive: r,
                    onTap: _fitAllPoints,
                  ),
                ],
              ),
            ),

            // ── Bouton Google Maps (bas gauche) ───────────────────────
            Positioned(
              bottom: r.h(310),
              left: r.w(16),
              child: _GoogleMapsFab(responsive: r, controller: _ctrl),
            ),
          ],
        );
      }),
    );
  }
}

// ── Stop detail bottom sheet ──────────────────────────────────────────────────

void _showStopDetail(
  BuildContext context,
  MapStop stop,
  InteractiveMapController ctrl,
  AppResponsive r,
) {
  // Sécurité : ne pas afficher si le widget n'est plus monté
  if (!context.mounted) return;

  Get.bottomSheet(
    Container(
      padding: EdgeInsets.fromLTRB(r.w(20), r.h(16), r.w(20), r.h(32)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          SizedBox(height: r.h(16)),

          // En-tête passager
          Row(
            children: [
              Container(
                width: r.w(40),
                height: r.w(40),
                decoration: BoxDecoration(
                  color: ctrl.stopBgColor(stop),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  stop.type == StopType.pickup
                      ? Icons.trip_origin_rounded
                      : Icons.location_on_rounded,
                  color: ctrl.stopColor(stop),
                  size: r.text(20),
                ),
              ),
              SizedBox(width: r.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stop.passengerName,
                      style: AppTextStyles.subtitle(r)
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      ctrl.stopTypeLabel(stop.type),
                      style: AppTextStyles.caption(r)
                          .copyWith(color: ctrl.stopColor(stop)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: r.w(8), vertical: r.h(4)),
                decoration: BoxDecoration(
                  color: ctrl
                      .stopStatusColor(stop.status)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  ctrl.stopStatusLabel(stop.status),
                  style: AppTextStyles.caption(r).copyWith(
                    color: ctrl.stopStatusColor(stop.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: r.h(14)),

          // Adresse + ETA
          Row(
            children: [
              Icon(Icons.pin_drop_rounded,
                  size: r.text(14), color: AppColors.textHint),
              SizedBox(width: r.w(6)),
              Expanded(
                child: Text(stop.address, style: AppTextStyles.caption(r)),
              ),
              if (stop.eta.isNotEmpty)
                Text(
                  stop.eta,
                  style: AppTextStyles.caption(r).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),

          SizedBox(height: r.h(16)),

          // Boutons de contact (appel + SMS) — affichés seulement si numéro disponible
          if (stop.phone != null && stop.phone!.isNotEmpty) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri(scheme: 'tel', path: stop.phone);
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    icon: const Icon(Icons.phone_rounded, size: 18),
                    label: const Text('Appeler'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF16A34A),
                      side: const BorderSide(color: Color(0xFF16A34A)),
                      padding: EdgeInsets.symmetric(vertical: r.h(12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.radius(12)),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: r.w(10)),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri(scheme: 'sms', path: stop.phone);
                      if (await canLaunchUrl(uri)) launchUrl(uri);
                    },
                    icon: const Icon(Icons.message_rounded, size: 18),
                    label: const Text('Message'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: r.h(12)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(r.radius(12)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: r.h(10)),
          ],

          // Bouton Google Maps
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Get.back();
                ctrl.openStopInGoogleMaps(stop);
              },
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Ouvrir dans Google Maps'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A73E8),
                side: const BorderSide(color: Color(0xFF1A73E8)),
                padding: EdgeInsets.symmetric(vertical: r.h(12)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.radius(12)),
                ),
              ),
            ),
          ),

          if (stop.status != StopStatus.done) ...[
            SizedBox(height: r.h(10)),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  ctrl.markStopDone(stop.id);
                },
                icon: const Icon(Icons.check_circle_rounded, size: 18),
                label: const Text('Marquer comme terminé'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: r.h(14)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.radius(12)),
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: r.h(8)),
        ],
      ),
    ),
    isScrollControlled: true,
    enableDrag: true,
  );
}

// ── Driver position marker ────────────────────────────────────────────────────

class _DriverPositionMarker extends StatelessWidget {
  const _DriverPositionMarker({required this.controller});

  final InteractiveMapController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller.pulseController,
      builder: (context, child) {
        final pulse = controller.pulseController.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 52 * (0.7 + pulse * 0.3),
              height: 52 * (0.7 + pulse * 0.3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.18 * (1 - pulse)),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Stop pin ──────────────────────────────────────────────────────────────────

class _StopPin extends StatelessWidget {
  const _StopPin({
    required this.stop,
    required this.index,
    required this.controller,
  });

  final MapStop stop;
  final int index;
  final InteractiveMapController controller;

  @override
  Widget build(BuildContext context) {
    final color = controller.stopColor(stop);
    final isDone = stop.status == StopStatus.done;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFE5E7EB) : color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: isDone ? 0.0 : 0.40),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
                : Text(
                    '$index',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
          ),
        ),
        Container(
          width: 2.5,
          height: 10,
          color: isDone ? const Color(0xFFE5E7EB) : color,
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isDone ? const Color(0xFFE5E7EB) : color,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
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
                    borderRadius:
                        BorderRadius.circular(responsive.radius(10)),
                  ),
                  child: Icon(Icons.arrow_back_rounded,
                      size: responsive.text(20),
                      color: AppColors.textPrimary),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Carte interactive du trajet',
                        style: AppTextStyles.h6(responsive)),
                    Obx(() {
                      final done = controller.stops
                          .where((s) => s.status == StopStatus.done)
                          .length;
                      final total = controller.stops.length;
                      if (controller.isLocating.value) {
                        return Text(
                          'Localisation GPS…',
                          style: AppTextStyles.caption(responsive)
                              .copyWith(color: AppColors.primary),
                        );
                      }
                      return Text(
                        total == 0
                            ? 'Chargement du trajet…'
                            : '$done/$total arrêts complétés',
                        style: AppTextStyles.caption(responsive)
                            .copyWith(color: AppColors.textHint),
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
          Obx(() {
            final done = controller.stops
                .where((s) => s.status == StopStatus.done)
                .length;
            final total = controller.stops.length;
            return ClipRRect(
              borderRadius: BorderRadius.circular(9999),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : done / total,
                minHeight: responsive.h(4),
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.responsive,
    required this.icon,
    required this.label,
    required this.color,
  });

  final AppResponsive responsive;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (label == '–' || label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(8),
        vertical: responsive.h(4),
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(responsive.radius(8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: responsive.text(12), color: color),
          SizedBox(width: responsive.w(4)),
          Text(
            label,
            style: AppTextStyles.caption(responsive).copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: responsive.text(11),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Banners ───────────────────────────────────────────────────────────────────

class _OptimizationBanner extends StatelessWidget {
  const _OptimizationBanner({required this.responsive});
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: responsive.w(14), vertical: responsive.h(10)),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 18),
          SizedBox(width: responsive.w(8)),
          Expanded(
            child: Text(
              'Itinéraire recalculé — trajet optimisé avec succès',
              style: AppTextStyles.caption(responsive)
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingBanner extends StatelessWidget {
  const _LoadingBanner({required this.responsive});
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: responsive.w(14), vertical: responsive.h(10)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: responsive.w(10)),
          Text(
            'Chargement du trajet…',
            style: AppTextStyles.caption(responsive)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.responsive,
    required this.onRetry,
    required this.message,
    required this.canRetry,
  });
  final AppResponsive responsive;
  final VoidCallback onRetry;
  final String message;
  final bool canRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: responsive.w(14), vertical: responsive.h(10)),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_rounded,
              color: Color(0xFFE53935), size: 18),
          SizedBox(width: responsive.w(8)),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption(responsive)
                  .copyWith(color: const Color(0xFFE53935)),
            ),
          ),
          if (canRetry) ...[
            SizedBox(width: responsive.w(8)),
            GestureDetector(
              onTap: onRetry,
              child: Text(
                'Réessayer',
                style: AppTextStyles.caption(responsive).copyWith(
                  color: const Color(0xFFE53935),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Fallback mode banner ──────────────────────────────────────────────────────

class _FallbackBanner extends StatelessWidget {
  const _FallbackBanner({required this.responsive, required this.message, required this.onRetry});
  final AppResponsive responsive;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: responsive.w(14), vertical: responsive.h(10)),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(responsive.radius(12)),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFFD97706), size: 18),
          SizedBox(width: responsive.w(8)),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption(responsive)
                  .copyWith(color: const Color(0xFFD97706)),
            ),
          ),
          GestureDetector(
            onTap: onRetry,
            child: Text(
              'Actualiser',
              style: AppTextStyles.caption(responsive).copyWith(
                color: const Color(0xFFD97706),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(responsive.radius(24))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: responsive.h(10)),
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
                SizedBox(height: responsive.h(16)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: responsive.w(16)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Arrêts du trajet',
                                style: AppTextStyles.h6(responsive)),
                            Obx(() {
                              final approaching = controller.stops
                                  .where(
                                      (s) => s.status == StopStatus.approaching)
                                  .length;
                              return Text(
                                approaching > 0
                                    ? '$approaching arrêt(s) en approche'
                                    : 'Glissez pour voir tous les arrêts',
                                style: AppTextStyles.caption(responsive)
                                    .copyWith(
                                  color: approaching > 0
                                      ? const Color(0xFF3B82F6)
                                      : AppColors.textHint,
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
          Obx(() {
            if (controller.stops.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(16), vertical: responsive.h(24)),
                  child: Center(
                    child: Text(
                      'Aucun arrêt chargé',
                      style: AppTextStyles.caption(responsive),
                    ),
                  ),
                ),
              );
            }
            return SliverList(
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
            );
          }),
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
      padding: EdgeInsets.fromLTRB(
        responsive.w(16),
        0,
        responsive.w(16),
        responsive.h(12),
      ),
      child: GestureDetector(
        onTap: () => _showStopDetail(context, stop, controller, responsive),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.all(responsive.w(14)),
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.surfaceMuted
                : color.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(responsive.radius(14)),
            border: Border.all(
              color:
                  isDone ? AppColors.border : color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: responsive.w(36),
                height: responsive.w(36),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFFE5E7EB) : color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? Icon(Icons.check_rounded,
                          color: Colors.white, size: responsive.text(16))
                      : Text(
                          '$index',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: responsive.text(13),
                          ),
                        ),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stop.passengerName,
                            style: AppTextStyles.subtitle(responsive).copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDone
                                  ? AppColors.textGhost
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(8),
                            vertical: responsive.h(3),
                          ),
                          decoration: BoxDecoration(
                            color: controller
                                .stopStatusColor(stop.status)
                                .withValues(alpha: 0.12),
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
                          stop.type == StopType.pickup
                              ? Icons.trip_origin_rounded
                              : Icons.location_on_rounded,
                          size: responsive.text(12),
                          color: isDone ? AppColors.textGhost : color,
                        ),
                        SizedBox(width: responsive.w(4)),
                        Expanded(
                          child: Text(
                            stop.address,
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: isDone
                                  ? AppColors.textGhost
                                  : AppColors.textHint,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isDone && stop.eta.isNotEmpty) ...[
                          SizedBox(width: responsive.w(8)),
                          Text(
                            stop.eta,
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: responsive.h(4)),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: responsive.w(6),
                        vertical: responsive.h(2),
                      ),
                      decoration: BoxDecoration(
                        color: isDone
                            ? AppColors.border
                            : color.withValues(alpha: 0.12),
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
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.textGhost, size: responsive.text(20)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAB widgets ───────────────────────────────────────────────────────────────

class _RecalculateFab extends StatelessWidget {
  const _RecalculateFab({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final InteractiveMapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Tooltip(
          message: 'Recalculer l\'itinéraire',
          child: GestureDetector(
            onTap: controller.recalculateRoute,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: responsive.w(48),
              height: responsive.w(48),
              decoration: BoxDecoration(
                color: controller.isRecalculating.value
                    ? AppColors.textGhost
                    : AppColors.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.40),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: controller.isRecalculating.value
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Icon(Icons.route_rounded,
                      color: Colors.white, size: responsive.text(20)),
            ),
          ),
        ));
  }
}

class _CenterDriverFab extends StatelessWidget {
  const _CenterDriverFab({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final InteractiveMapController controller;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Centrer sur ma position',
      child: GestureDetector(
        onTap: controller.centerOnDriver,
        child: Container(
          width: responsive.w(48),
          height: responsive.w(48),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.my_location_rounded,
              color: AppColors.primary, size: responsive.text(20)),
        ),
      ),
    );
  }
}

class _FitAllFab extends StatelessWidget {
  const _FitAllFab({required this.responsive, required this.onTap});
  final AppResponsive responsive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Voir tous les arrêts',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: responsive.w(48),
          height: responsive.w(48),
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(Icons.fit_screen_rounded,
              color: AppColors.textSecondary, size: responsive.text(20)),
        ),
      ),
    );
  }
}

class _GoogleMapsFab extends StatelessWidget {
  const _GoogleMapsFab({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final InteractiveMapController controller;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Naviguer avec Google Maps',
      child: GestureDetector(
        onTap: controller.openNextStopInGoogleMaps,
        child: Container(
          height: responsive.w(48),
          padding: EdgeInsets.symmetric(horizontal: responsive.w(14)),
          decoration: BoxDecoration(
            color: const Color(0xFF1A73E8),
            borderRadius: BorderRadius.circular(responsive.radius(24)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A73E8).withValues(alpha: 0.40),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.map_rounded, color: Colors.white, size: 18),
              SizedBox(width: responsive.w(6)),
              Text(
                'Google Maps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: responsive.text(13),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

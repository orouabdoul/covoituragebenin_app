import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/trajet_attente_controller.dart';

class TrajetAttenteView extends GetView<TrajetAttenteController> {
  const TrajetAttenteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.hasError.value) {
          return _ErrorState();
        }
        return Stack(
          children: [
            _MapLayer(c: controller),
            Obx(() => controller.isTransitioning.value
                ? _TransitionOverlay()
                : const SizedBox.shrink()),
            _BottomSheet(c: controller),
            _TopBar(c: controller),
          ],
        );
      }),
    );
  }
}

// ─── Map ─────────────────────────────────────────────────────────────────────

class _MapLayer extends StatelessWidget {
  const _MapLayer({required this.c});
  final TrajetAttenteController c;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: h * 0.56,
      child: Obx(() {
        final status = c.tripStatus.value;
        final routeColor = _routeColor(status);

        return FlutterMap(
          mapController: c.mapCtrl,
          options: MapOptions(
            initialCenter: c.departurePt.value,
            initialZoom: 10.0,
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
                  color: routeColor.withValues(alpha: 0.55),
                  strokeWidth: 5,
                  pattern:
                      StrokePattern.dashed(segments: [12, 8]),
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
            ]),
          ],
        );
      }),
    );
  }

  static Color _routeColor(String status) {
    switch (status) {
      case 'active':
      case 'in_progress':
      case 'started':
        return AppColors.primary;
      case 'completed':
        return AppColors.textHint;
      default:
        return AppColors.accent;
    }
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

// ─── Transition Overlay ───────────────────────────────────────────────────────

class _TransitionOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Container(
      color: AppColors.primary.withValues(alpha: 0.90),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(
              'Le conducteur a démarré !',
              style: AppTextStyles.h4(r).copyWith(color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Ouverture du suivi en direct…',
              style: AppTextStyles.muted(r)
                  .copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.c});
  final TrajetAttenteController c;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _MapBtn(icon: Icons.arrow_back_rounded, onTap: Get.back),
            const Spacer(),
            _MapBtn(
              icon: Icons.refresh_rounded,
              onTap: c.refreshNow,
            ),
          ],
        ),
      ),
    );
  }
}

class _MapBtn extends StatelessWidget {
  const _MapBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      );
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  const _BottomSheet({required this.c});
  final TrajetAttenteController c;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.50,
      minChildSize: 0.22,
      maxChildSize: 0.80,
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
                  _CountdownCard(c: c, r: r),
                  const SizedBox(height: 20),
                  _RouteRow(c: c, r: r),
                  const _Separator(),
                  _DriverRow(c: c, r: r),
                  const SizedBox(height: 16),
                  _CallBtn(c: c, r: r),
                  const SizedBox(height: 10),
                  _AutoRefreshHint(r: r),
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

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({required this.c, required this.r});
  final TrajetAttenteController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expired = c.countdownExpired.value;
      final label = c.countdownLabel.value;
      final bg = expired
          ? AppColors.success.withValues(alpha: 0.08)
          : AppColors.primary.withValues(alpha: 0.06);
      final iconColor = expired ? AppColors.success : AppColors.primary;
      final icon =
          expired ? Icons.directions_car_rounded : Icons.hourglass_top_rounded;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expired
                        ? 'Départ imminent'
                        : 'Avant le départ',
                    style: AppTextStyles.caption(r)
                        .copyWith(color: iconColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label.isNotEmpty ? label : '—',
                    style: AppTextStyles.h4(r)
                        .copyWith(color: iconColor),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _RouteRow extends StatelessWidget {
  const _RouteRow({required this.c, required this.r});
  final TrajetAttenteController c;
  final AppResponsive r;

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw) ??
        DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (dt == null) return raw;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${h}h$m';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dep = c.departureCity.value;
      final arr = c.arrivalCity.value;
      final time = _formatTime(c.departureTime.value);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Votre trajet',
              style: AppTextStyles.bodyMedium(r)
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 28,
                    color: const Color(0xFFD1D5DB),
                  ),
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dep.isNotEmpty ? dep : '—',
                      style: AppTextStyles.subtitle(r),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            arr.isNotEmpty ? arr : '—',
                            style: AppTextStyles.subtitle(r),
                          ),
                        ),
                        if (time.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: 12,
                                    color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: AppTextStyles.labelSmall(r)
                                      .copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _DriverRow extends StatelessWidget {
  const _DriverRow({required this.c, required this.r});
  final TrajetAttenteController c;
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
              color: AppColors.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  'En attente',
                  style: AppTextStyles.labelSmall(r)
                      .copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _CallBtn extends StatelessWidget {
  const _CallBtn({required this.c, required this.r});
  final TrajetAttenteController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: c.callDriver,
          icon: const Icon(Icons.phone_rounded, size: 20),
          label: Text('Appeler le conducteur',
              style: AppTextStyles.button(r)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      );
}

class _AutoRefreshHint extends StatelessWidget {
  const _AutoRefreshHint({required this.r});
  final AppResponsive r;

  @override
  Widget build(BuildContext context) => Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sync_rounded, size: 13, color: AppColors.textHint),
            const SizedBox(width: 5),
            Text(
              'Actualisation auto toutes les 30 secondes',
              style: AppTextStyles.caption(r)
                  .copyWith(color: AppColors.textHint),
            ),
          ],
        ),
      );
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 64, color: AppColors.danger),
            const SizedBox(height: 16),
            Text('Réservation introuvable', style: AppTextStyles.h4(r)),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger les données de votre trajet.',
              style: AppTextStyles.muted(r),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: Get.back,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Retour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

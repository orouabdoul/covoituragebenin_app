import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/mon_trajet_controller.dart';

class MonTrajetView extends GetView<MonTrajetController> {
  const MonTrajetView({super.key});

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
  final MonTrajetController c;

  static const _benin = LatLng(9.3077, 2.3158);

  static bool _isBenin(LatLng p) =>
      (p.latitude - _benin.latitude).abs() < 1e-4 &&
      (p.longitude - _benin.longitude).abs() < 1e-4;

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.sizeOf(context).height;
    return SizedBox(
      height: h * 0.56,
      child: Obx(() => FlutterMap(
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
                    color: AppColors.primary.withValues(alpha: 0.85),
                    strokeWidth: 5,
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
                // Passenger pickup markers
                ...c.passengers.asMap().entries
                    .where((e) =>
                        e.value.pickupLat != null &&
                        e.value.pickupLng != null)
                    .map((e) => Marker(
                          point: LatLng(
                              e.value.pickupLat!, e.value.pickupLng!),
                          width: 32,
                          height: 32,
                          child: _PassengerPin(number: e.key + 1),
                        )),
                // My position (driver)
                if (!_isBenin(c.myLatLng.value))
                  Marker(
                    point: c.myLatLng.value,
                    width: 44,
                    height: 44,
                    child: _DriverDot(),
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

class _PassengerPin extends StatelessWidget {
  const _PassengerPin({required this.number});
  final int number;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.40),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}

class _DriverDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.45),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.navigation_rounded,
            color: Colors.white, size: 22),
      );
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.c});
  final MonTrajetController c;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            _MapBtn(icon: Icons.arrow_back_rounded, onTap: Get.back),
            const Spacer(),
            Obx(() {
              final ready = c.gpsReady.value;
              final speed = c.mySpeedKmh.value;
              if (!ready) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.speed_rounded,
                        size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      '${speed.toStringAsFixed(0)} km/h',
                      style: AppTextStyles.bodyMedium(r)
                          .copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
              );
            }),
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
  final MonTrajetController c;

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
                  _TripHeader(c: c, r: r),
                  const SizedBox(height: 16),
                  _ItinerarySection(c: c, r: r),
                  const SizedBox(height: 20),
                  _ActionButtons(c: c, r: r),
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

class _TripHeader extends StatelessWidget {
  const _TripHeader({required this.c, required this.r});
  final MonTrajetController c;
  final AppResponsive r;

  String _formatTime(String raw) {
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw) ??
        DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (dt == null) return raw;
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} à ${h}h$m';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dep = c.departureCity.value;
      final arr = c.arrivalCity.value;
      final status = c.tripStatus.value;
      final time = _formatTime(c.departureTime.value);

      Color statusColor;
      String statusLabel;
      switch (status) {
        case 'active':
        case 'in_progress':
        case 'started':
          statusColor = AppColors.success;
          statusLabel = 'En route';
          break;
        case 'completed':
          statusColor = AppColors.textHint;
          statusLabel = 'Terminé';
          break;
        default:
          statusColor = AppColors.accent;
          statusLabel = 'En attente';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  dep.isNotEmpty && arr.isNotEmpty
                      ? '$dep → $arr'
                      : 'Mon trajet',
                  style: AppTextStyles.h5(r),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      statusLabel,
                      style: AppTextStyles.labelSmall(r)
                          .copyWith(color: statusColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (time.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.schedule_rounded,
                    size: 14, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(
                  'Départ : $time',
                  style: AppTextStyles.caption(r),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

// ─── Itinéraire vertical (style Google Maps) ─────────────────────────────────

class _ItinerarySection extends StatelessWidget {
  const _ItinerarySection({required this.c, required this.r});
  final MonTrajetController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dep = c.departureCity.value;
      final arr = c.arrivalCity.value;
      final pax = c.passengers;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.route_rounded,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text('Itinéraire',
                  style: AppTextStyles.bodyMedium(r)
                      .copyWith(color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          // Ligne de départ
          _StopRow(
            dot: _DotCircle(color: AppColors.success,
                icon: Icons.trip_origin_rounded),
            label: dep.isNotEmpty ? dep : 'Départ',
            sublabel: 'Point de départ',
            r: r,
          ),
          // Arrêts passagers
          ...pax.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            return _StopRow(
              connector: true,
              dot: _DotCircle(
                color: const Color(0xFF7C3AED),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              label: p.name,
              sublabel:
                  '${p.seats} place${p.seats > 1 ? 's' : ''} · Prise en charge',
              trailingPhone: p.phone.isNotEmpty
                  ? () => c.callPassenger(i)
                  : null,
              r: r,
            );
          }),
          // Ligne d'arrivée
          _StopRow(
            connector: true,
            dot: _DotCircle(color: AppColors.danger,
                icon: Icons.location_on_rounded),
            label: arr.isNotEmpty ? arr : 'Arrivée',
            sublabel: 'Destination finale',
            r: r,
          ),
          if (pax.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.people_outline_rounded,
                        color: AppColors.textHint, size: 18),
                    const SizedBox(width: 8),
                    Text('Aucun passager confirmé',
                        style: AppTextStyles.muted(r)),
                  ],
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _StopRow extends StatelessWidget {
  const _StopRow({
    required this.dot,
    required this.label,
    required this.sublabel,
    required this.r,
    this.connector = false,
    this.trailingPhone,
  });
  final Widget dot;
  final String label;
  final String sublabel;
  final AppResponsive r;
  final bool connector;
  final VoidCallback? trailingPhone;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                if (connector)
                  Container(width: 2, height: 14, color: const Color(0xFFD1D5DB)),
                dot,
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                  top: connector ? 14 : 0, bottom: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.subtitle(r)),
                  Text(sublabel,
                      style: AppTextStyles.caption(r)),
                ],
              ),
            ),
          ),
          if (trailingPhone != null) ...[
            Padding(
              padding: EdgeInsets.only(top: connector ? 14 : 0),
              child: GestureDetector(
                onTap: trailingPhone,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.phone_rounded,
                      size: 18, color: AppColors.success),
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
    );
  }
}

class _DotCircle extends StatelessWidget {
  const _DotCircle({required this.color, this.icon, this.child});
  final Color color;
  final IconData? icon;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 6,
            ),
          ],
        ),
        child: child ??
            Icon(icon, color: Colors.white, size: 15),
      );
}

// ─── Action Buttons ───────────────────────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.c, required this.r});
  final MonTrajetController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = c.tripStatus.value;
      final isPending =
          status == 'pending' || status == 'scheduled';
      final isActive = status == 'active' ||
          status == 'in_progress' ||
          status == 'started';
      final isCompleted = status == 'completed';

      if (isCompleted) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppColors.success.withValues(alpha: 0.20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Text('Trajet terminé',
                  style: AppTextStyles.bodyMedium(r)
                      .copyWith(color: AppColors.success)),
            ],
          ),
        );
      }

      return Column(
        children: [
          if (isPending)
            _Btn(
              onTap: c.isStarting.value ? null : c.startTrip,
              icon: Icons.play_arrow_rounded,
              label: c.isStarting.value
                  ? 'Démarrage…'
                  : 'Démarrer le trajet',
              color: AppColors.primary,
              r: r,
            ),
          if (isActive) ...[
            _Btn(
              onTap: c.isCompleting.value ? null : c.completeTrip,
              icon: Icons.flag_rounded,
              label: c.isCompleting.value
                  ? 'Finalisation…'
                  : 'Terminer le trajet',
              color: AppColors.danger,
              r: r,
            ),
          ],
        ],
      );
    });
  }
}

class _Btn extends StatelessWidget {
  const _Btn({
    required this.onTap,
    required this.icon,
    required this.label,
    required this.color,
    required this.r,
  });
  final VoidCallback? onTap;
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
          icon: onTap == null
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(icon, size: 20),
          label: Text(label, style: AppTextStyles.button(r)),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            disabledBackgroundColor: color.withValues(alpha: 0.60),
            disabledForegroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
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
            Text('Trajet introuvable', style: AppTextStyles.h4(r)),
            const SizedBox(height: 8),
            Text(
              'Impossible de charger les données du trajet.',
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

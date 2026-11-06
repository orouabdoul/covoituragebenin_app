import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
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
            // Overlay embarquement (plein écran, priorité max)
            Obx(() => controller.showBoardingOverlay.value
                ? _BoardingConfirmationOverlay(c: controller)
                : const SizedBox.shrink()),
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
    final r = AppResponsive(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(8)),
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
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return GestureDetector(
        onTap: onTap,
        child: Container(
          width: r.w(40),
          height: r.w(40),
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
          child: Icon(icon, color: AppColors.textPrimary, size: r.text(20)),
        ),
    );
  }
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
              padding: EdgeInsets.fromLTRB(r.w(20), r.h(4), r.w(20), 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CountdownCard(c: c, r: r),
                  SizedBox(height: r.h(20)),
                  _RouteRow(c: c, r: r),
                  const _Separator(),
                  _DriverRow(c: c, r: r),
                  SizedBox(height: r.h(16)),
                  _CallBtn(c: c, r: r),
                  SizedBox(height: r.h(10)),
                  _DriverAbsentBtn(c: c, r: r),
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
        padding: EdgeInsets.all(r.w(18)),
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
              width: r.w(44),
              height: r.w(44),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: r.text(22)),
            ),
            SizedBox(width: r.w(14)),
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
                    width: r.w(12),
                    height: r.w(12),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: r.w(2),
                    height: r.h(28),
                    color: AppColors.border,
                  ),
                  Container(
                    width: r.w(12),
                    height: r.w(12),
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
                            padding: EdgeInsets.symmetric(
                                horizontal: r.w(8), vertical: r.h(3)),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded,
                                    size: r.text(12),
                                    color: AppColors.primary),
                                SizedBox(width: r.w(4)),
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
                style:
                    AppTextStyles.h5(r).copyWith(color: AppColors.primary),
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
            padding:
                EdgeInsets.symmetric(horizontal: r.w(10), vertical: r.h(5)),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: r.w(7),
                  height: r.w(7),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: r.w(5)),
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
        height: r.h(52),
        child: ElevatedButton.icon(
          onPressed: c.callDriver,
          icon: Icon(Icons.phone_rounded, size: r.text(20)),
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

class _DriverAbsentBtn extends StatelessWidget {
  const _DriverAbsentBtn({required this.c, required this.r});
  final TrajetAttenteController c;
  final AppResponsive r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final canReport  = c.canReportDriverAbsent;
      final hasReported = c.hasReportedDriverAbsent.value;
      final isLoading  = c.isReportingDriverAbsent.value;

      if (hasReported) {
        return Padding(
          padding: EdgeInsets.only(bottom: r.h(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline_rounded,
                  size: 14, color: AppColors.textHint),
              const SizedBox(width: 6),
              Text('Absence signalée',
                  style: AppTextStyles.caption(r)
                      .copyWith(color: AppColors.textHint)),
            ],
          ),
        );
      }

      if (!canReport) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.only(bottom: r.h(8)),
        child: SizedBox(
          width: double.infinity,
          height: r.h(48),
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : () => _confirm(context),
            icon: isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.danger),
                  )
                : Icon(Icons.person_off_rounded,
                    size: r.text(18), color: AppColors.danger),
            label: Text(
              isLoading ? 'Signalement…' : 'Signaler conducteur absent',
              style: AppTextStyles.button(r).copyWith(color: AppColors.danger),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppColors.danger.withValues(alpha: 0.50)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      );
    });
  }

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Conducteur absent ?'),
        content: const Text(
          'Confirmez-vous que le conducteur ne s\'est pas présenté 15 minutes après l\'heure prévue ?\n\n'
          'Si tous les passagers confirment, le trajet sera annulé et vous serez remboursé(e).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
    if (confirmed == true) c.reportDriverAbsent();
  }
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
        padding: EdgeInsets.all(r.w(32)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: r.text(64), color: AppColors.danger),
            SizedBox(height: r.h(16)),
            Text('Réservation introuvable', style: AppTextStyles.h4(r)),
            SizedBox(height: r.h(8)),
            Text(
              'Impossible de charger les données de votre trajet.',
              style: AppTextStyles.muted(r),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.h(24)),
            ElevatedButton.icon(
              onPressed: Get.back,
              icon: Icon(Icons.arrow_back_rounded, size: r.text(20)),
              label: Text('Retour', style: AppTextStyles.button(r)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(r.radius(12))),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Overlay plein-écran : confirmation d'embarquement ────────────────────────

class _BoardingConfirmationOverlay extends StatefulWidget {
  const _BoardingConfirmationOverlay({required this.c});
  final TrajetAttenteController c;

  @override
  State<_BoardingConfirmationOverlay> createState() =>
      _BoardingConfirmationOverlayState();
}

class _BoardingConfirmationOverlayState
    extends State<_BoardingConfirmationOverlay> {
  bool _isConfirming = false;
  bool _isRefusing   = false;
  String? _gpsWarning;

  Future<void> _onConfirm() async {
    setState(() => _isConfirming = true);

    double? lat;
    double? lng;

    // Récupérer la position GPS du passager (best-effort, non bloquant)
    // Coordonnées envoyées au backend pour log — pas de blocage côté UI
    try {
      final perm = await Geolocator.checkPermission();
      if (perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {
      // GPS indisponible — on confirme quand même
    }

    await widget.c.confirmBoarding(lat: lat, lng: lng);
    if (mounted) setState(() => _isConfirming = false);
  }

  Future<void> _onConfirmAnyway() async {
    setState(() { _isConfirming = true; _gpsWarning = null; });
    await widget.c.confirmBoarding();
    if (mounted) setState(() => _isConfirming = false);
  }

  Future<void> _onRefuse() async {
    final r = AppResponsive(context);
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Confirmer le refus', style: AppTextStyles.h5(r)),
        content: Text(
          'Cela signalera un incident à notre équipe support. Êtes-vous sûr ?',
          style: AppTextStyles.bodyMedium(r),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Annuler',
                style: AppTextStyles.bodyMedium(r)
                    .copyWith(color: AppColors.textHint)),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _isRefusing = true);
    await widget.c.refuseBoarding();
    if (mounted) setState(() => _isRefusing = false);
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.directions_car_rounded,
                    color: AppColors.primary, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Confirmation d\'embarquement',
                style: AppTextStyles.h4(r).copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Votre conducteur indique que vous êtes à bord.\nConfirmez-vous ?',
                style: AppTextStyles.bodyMedium(r)
                    .copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              // Code d'identification — affiché si transmis par FCM
              Obx(() {
                final code = widget.c.boardingCode.value;
                if (code.isEmpty) return const SizedBox.shrink();
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Votre code d\'identification',
                            style: AppTextStyles.caption(r)
                                .copyWith(color: Colors.white54, fontSize: 11),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            code,
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 16,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lisez ce code à voix haute si nécessaire',
                            style: AppTextStyles.caption(r)
                                .copyWith(color: Colors.white38, fontSize: 10),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              if (_gpsWarning != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.50)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _gpsWarning!,
                          style: AppTextStyles.caption(r)
                              .copyWith(color: AppColors.warning),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              if (_gpsWarning != null)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isConfirming ? null : _onConfirmAnyway,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isConfirming
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : Text('Confirmer quand même',
                            style: AppTextStyles.button(r)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isConfirming ? null : _onConfirm,
                    icon: _isConfirming
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text('Oui, je suis à bord',
                        style: AppTextStyles.button(r)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: (_isRefusing || _isConfirming) ? null : _onRefuse,
                  icon: _isRefusing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white60),
                        )
                      : const Icon(Icons.close_rounded, size: 20),
                  label: Text('Non', style: AppTextStyles.button(r)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

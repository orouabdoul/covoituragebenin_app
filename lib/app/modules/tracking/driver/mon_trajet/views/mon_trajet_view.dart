import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/data/models/tracking/trip_tracking_model.dart';
import '../controllers/mon_trajet_controller.dart';

class MonTrajetView extends StatelessWidget {
  const MonTrajetView({super.key});

  @override
  Widget build(BuildContext context) {
    final c   = Get.find<MonTrajetController>();
    final res = AppResponsive(context);
    final sh  = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.hasError.value) {
          return _NoTripScreen(res: res);
        }
        return Stack(
          children: [
            SizedBox(height: sh * 0.55, child: _MapLayer(c: c)),
            DraggableScrollableSheet(
              initialChildSize: 0.48,
              minChildSize: 0.38,
              maxChildSize: 0.78,
              builder: (_, scroll) =>
                  _BottomPanel(c: c, res: res, scroll: scroll),
            ),
            _TopBar(c: c, res: res),
          ],
        );
      }),
    );
  }
}

// ── Pas de trajet ─────────────────────────────────────────────────────────────

class _NoTripScreen extends StatelessWidget {
  const _NoTripScreen({required this.res});
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(res.w(32)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.directions_car_outlined,
                  size: 72, color: AppColors.textHint),
              SizedBox(height: res.h(16)),
              Text('Aucun trajet actif',
                  style: AppTextStyles.h5(res)
                      .copyWith(color: AppColors.textPrimary)),
              SizedBox(height: res.h(8)),
              Text(
                'Vous n\'avez pas de trajet en cours ou prévu prochainement.',
                style: AppTextStyles.body(res)
                    .copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: res.h(24)),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: Get.back,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        EdgeInsets.symmetric(vertical: res.h(14)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(res.radius(14)),
                    ),
                  ),
                  child: const Text('Retour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Carte ─────────────────────────────────────────────────────────────────────

class _MapLayer extends StatelessWidget {
  const _MapLayer({required this.c});
  final MonTrajetController c;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final me         = c.myLatLng.value;
      final departure  = c.departurePt.value;
      final arrival    = c.arrivalPt.value;
      final route      = c.routePoints.toList();
      final paxList    = c.passengers.toList();
      final isActive   = c.tripStatus.value != 'pending' &&
          c.tripStatus.value != 'scheduled';

      // Couleur de la route selon statut
      final routeColor = isActive
          ? const Color(0xFF93C5FD)
          : const Color(0xFFF59E0B);

      return FlutterMap(
        mapController: c.mapCtrl,
        options: MapOptions(
          initialCenter: me,
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
          // Itinéraire OSRM
          if (route.length >= 2)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: route,
                  color: routeColor.withValues(alpha: 0.85),
                  strokeWidth: 4.5,
                  pattern: isActive
                      ? const StrokePattern.solid()
                      : StrokePattern.dashed(segments: const <double>[12, 8]),
                ),
              ],
            ),
          MarkerLayer(
            markers: [
              // Ma position (bleu)
              if (c.gpsReady.value)
                Marker(
                  point: me,
                  width: 44,
                  height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A5FB4),
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: const Color(0xFF1A5FB4)
                                .withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: const Icon(Icons.navigation_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              // Départ
              _pinMarker(departure, const Color(0xFF10B981),
                  Icons.trip_origin_rounded, 'Départ'),
              // Arrivée
              _pinMarker(arrival, const Color(0xFFEF4444),
                  Icons.location_on_rounded, 'Arrivée'),
              // Pickup passagers (numérotés)
              for (int i = 0; i < paxList.length; i++)
                if (paxList[i].pickupLat != null &&
                    paxList[i].pickupLng != null)
                  Marker(
                    point: LatLng(
                        paxList[i].pickupLat!, paxList[i].pickupLng!),
                    width: 36,
                    height: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text('${i + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w800)),
                      ),
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
  final MonTrajetController c;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: res.w(12), vertical: res.h(4)),
        child: Row(
          children: [
            _Btn(icon: Icons.arrow_back_rounded, onTap: Get.back),
            const Spacer(),
            Obx(() => Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: res.w(10), vertical: res.h(5)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x1A000000),
                          blurRadius: 8,
                          offset: Offset(0, 2))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: c.gpsReady.value
                              ? AppColors.success
                              : AppColors.textHint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: res.w(5)),
                      Text(
                        c.gpsReady.value
                            ? '${c.mySpeedKmh.value.round()} km/h'
                            : 'GPS…',
                        style: AppTextStyles.caption(res).copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary),
                      ),
                    ],
                  ),
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
  final MonTrajetController c;
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
          // Titre itinéraire
          Obx(() => Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${c.departureCity.value} → ${c.arrivalCity.value}',
                          style: AppTextStyles.h6(res)
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (c.departureTime.value.isNotEmpty)
                          Text(
                            'Départ : ${_formatTime(c.departureTime.value)}',
                            style: AppTextStyles.caption(res)
                                .copyWith(color: AppColors.textHint),
                          ),
                      ],
                    ),
                  ),
                  _StatusBadge(status: c.tripStatus.value, res: res),
                ],
              )),
          SizedBox(height: res.h(16)),

          // Passagers
          Obx(() {
            final pax = c.passengers.toList();
            if (pax.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${pax.length} passager${pax.length > 1 ? 's' : ''} confirmé${pax.length > 1 ? 's' : ''}',
                  style: AppTextStyles.body(res).copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary),
                ),
                SizedBox(height: res.h(8)),
                ...pax.asMap().entries.map(
                      (e) => _PassengerTile(
                        index: e.key,
                        pax: e.value,
                        res: res,
                        onCall: () => c.callPassenger(e.key),
                      ),
                    ),
              ],
            );
          }),

          SizedBox(height: res.h(16)),
          const Divider(height: 1, color: AppColors.border),
          SizedBox(height: res.h(16)),

          // Boutons Démarrer / Terminer
          Obx(() {
            final status = c.tripStatus.value;
            final isPending = status == 'pending' || status == 'scheduled';
            final isActive  = status == 'active' || status == 'in_progress' ||
                status == 'running' || status == 'started' ||
                status == 'picking_up' || status == 'picked_up' ||
                status == 'ongoing' || status == 'in_route';

            return Column(
              children: [
                if (isPending)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: c.isStarting.value ? null : c.startTrip,
                      icon: c.isStarting.value
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.play_arrow_rounded, size: 20),
                      label: Text(
                          c.isStarting.value ? 'Démarrage…' : 'Démarrer le trajet'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(vertical: res.h(15)),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(res.radius(14))),
                        textStyle: AppTextStyles.body(res)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (isActive) ...[
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed:
                          c.isCompleting.value ? null : c.completeTrip,
                      icon: c.isCompleting.value
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: AppColors.danger, strokeWidth: 2))
                          : const Icon(Icons.check_circle_outline_rounded,
                              size: 20),
                      label: Text(c.isCompleting.value
                          ? 'Enregistrement…'
                          : 'Terminer le trajet'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.danger,
                        side: const BorderSide(
                            color: AppColors.danger, width: 1.5),
                        padding:
                            EdgeInsets.symmetric(vertical: res.h(15)),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(res.radius(14))),
                        textStyle: AppTextStyles.body(res)
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  static String _formatTime(String raw) {
    final dt = DateTime.tryParse(raw) ??
        DateTime.tryParse(raw.replaceFirst(' ', 'T'));
    if (dt == null) return raw;
    final local = dt.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}h${local.minute.toString().padLeft(2, '0')}';
  }
}

// ── Ligne passager ────────────────────────────────────────────────────────────

class _PassengerTile extends StatelessWidget {
  const _PassengerTile({
    required this.index,
    required this.pax,
    required this.res,
    required this.onCall,
  });
  final int index;
  final ActivePassengerModel pax;
  final AppResponsive res;
  final VoidCallback onCall;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: res.h(8)),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${index + 1}',
                  style: AppTextStyles.body(res).copyWith(
                      color: const Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w800)),
            ),
          ),
          SizedBox(width: res.w(10)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pax.name,
                    style: AppTextStyles.body(res)
                        .copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                Text(
                  '${pax.seats} place${pax.seats > 1 ? 's' : ''}',
                  style: AppTextStyles.caption(res)
                      .copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ),
          if (pax.phone.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.call_rounded,
                  color: AppColors.primary, size: 20),
              onPressed: onCall,
              splashRadius: 20,
            ),
        ],
      ),
    );
  }
}

// ── Badge statut ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.res});
  final String status;
  final AppResponsive res;

  @override
  Widget build(BuildContext context) {
    late String label;
    late Color color;
    switch (status) {
      case 'pending':
      case 'scheduled':
        label = 'En attente';
        color = const Color(0xFFF59E0B);
        break;
      case 'active':
      case 'in_progress':
      case 'running':
      case 'started':
        label = 'En route';
        color = AppColors.success;
        break;
      case 'completed':
        label = 'Terminé';
        color = AppColors.textHint;
        break;
      default:
        label = status;
        color = AppColors.textHint;
    }
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: res.w(10), vertical: res.h(4)),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: AppTextStyles.caption(res).copyWith(
              color: color, fontWeight: FontWeight.w700)),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap});
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
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

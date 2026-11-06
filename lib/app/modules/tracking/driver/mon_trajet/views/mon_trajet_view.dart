import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import '../controllers/mon_trajet_controller.dart';

class MonTrajetView extends GetView<MonTrajetController> {
  const MonTrajetView({super.key});

  @override
  Widget build(BuildContext context) {
    // Injecter les callbacks depuis la vue
    controller.onBoardingTimeout = (bookingUuid, boardingCode) {
      _showBoardingCodeDialog(context, bookingUuid, boardingCode);
    };
    controller.onTripCompleted = (pendingAmount, releaseAt) {
      _showCompletionSheet(context, pendingAmount, releaseAt);
    };

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

  void _showBoardingCodeDialog(BuildContext context, String bookingUuid, String boardingCode) {
    final r             = AppResponsive(context);
    final codeCtrl      = TextEditingController(text: boardingCode);
    final isLoading     = false.obs;
    final isManualLoading = false.obs;
    final showCodeEntry = false.obs; // false = attente passager, true = saisie manuelle

    // Bouton "Téléphone mort" partagé par les deux modes
    Widget buildManualBtn() => Obx(() => TextButton.icon(
      onPressed: isManualLoading.value
          ? null
          : () async {
              isManualLoading.value = true;
              await controller.confirmBoardingManual(bookingUuid);
              isManualLoading.value = false;
            },
      icon: isManualLoading.value
          ? const SizedBox(
              width: 14, height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFF59E0B)),
            )
          : const Icon(Icons.phonelink_off_rounded, size: 16, color: Color(0xFFF59E0B)),
      label: Text(
        'Téléphone mort / Sans réseau',
        style: AppTextStyles.bodySmall(r).copyWith(
          color: const Color(0xFFF59E0B),
          fontWeight: FontWeight.w600,
        ),
      ),
    ));

    // Mode A — En attente de confirmation du passager
    Widget buildWaiting() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 36, height: 36,
          child: CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF7C3AED)),
        ),
        const SizedBox(height: 14),
        Text(
          'En attente de la confirmation du passager...',
          style: AppTextStyles.muted(r),
          textAlign: TextAlign.center,
        ),
        if (boardingCode.isNotEmpty) ...[
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.25)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Code : ',
                  style: AppTextStyles.caption(r)
                      .copyWith(color: const Color(0xFF7C3AED))),
                Text(
                  boardingCode,
                  style: const TextStyle(
                    fontSize: 28, fontWeight: FontWeight.w900,
                    letterSpacing: 10, color: Color(0xFF7C3AED),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 14),
        TextButton.icon(
          onPressed: () => showCodeEntry.value = true,
          icon: const Icon(Icons.keyboard_rounded, size: 15, color: Color(0xFF7C3AED)),
          label: Text(
            'Le passager lit son code à voix haute',
            style: AppTextStyles.bodySmall(r).copyWith(color: const Color(0xFF7C3AED)),
          ),
        ),
        Divider(color: AppColors.border),
        buildManualBtn(),
      ],
    );

    // Mode B — Saisie manuelle du code
    Widget buildEntry() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Entrez le code affiché sur le téléphone du passager',
          style: AppTextStyles.muted(r),
          textAlign: TextAlign.center,
        ),
        if (boardingCode.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            'Code de référence : $boardingCode',
            style: AppTextStyles.caption(r)
                .copyWith(color: const Color(0xFF7C3AED).withValues(alpha: 0.7)),
          ),
        ],
        const SizedBox(height: 18),
        TextField(
          controller: codeCtrl,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          autofocus: true,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 12),
          decoration: InputDecoration(
            counterText: '',
            hintText: '----',
            hintStyle: TextStyle(
              fontSize: 28, fontWeight: FontWeight.w700,
              letterSpacing: 12, color: AppColors.textHint,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: 8),
        Divider(color: AppColors.border),
        buildManualBtn(),
      ],
    );

    Get.dialog(
      PopScope(
        canPop: false,
        child: Obx(() {
          final isEntry = showCodeEntry.value;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Column(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isEntry ? Icons.keyboard_rounded : Icons.directions_car_filled_rounded,
                    color: const Color(0xFF7C3AED), size: 24),
                ),
                const SizedBox(height: 12),
                Text(isEntry ? 'Saisir le code' : 'Embarquement',
                    style: AppTextStyles.h5(r)),
              ],
            ),
            content: SingleChildScrollView(
              child: isEntry ? buildEntry() : buildWaiting(),
            ),
            actions: isEntry
                ? [
                    TextButton(
                      onPressed: () => showCodeEntry.value = false,
                      child: Text('Retour',
                          style: AppTextStyles.bodyMedium(r)
                              .copyWith(color: AppColors.textHint)),
                    ),
                    Obx(() => ElevatedButton(
                      onPressed: isLoading.value
                          ? null
                          : () async {
                              final code = codeCtrl.text.trim();
                              if (code.length != 4) return;
                              isLoading.value = true;
                              await controller.confirmBoardingByCode(bookingUuid, code);
                              isLoading.value = false;
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: isLoading.value
                          ? const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Valider'),
                    )),
                  ]
                : [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text('Annuler',
                          style: AppTextStyles.bodyMedium(r)
                              .copyWith(color: AppColors.textHint)),
                    ),
                  ],
          );
        }),
      ),
      barrierDismissible: false,
    );
  }

  void _showCompletionSheet(
      BuildContext context, double pendingAmount, String? releaseAt) {
    DateTime? releaseTime;
    if (releaseAt != null) {
      final parsed = DateTime.tryParse(releaseAt);
      if (parsed != null) releaseTime = parsed.isUtc ? parsed.toLocal() : parsed;
    }
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CompletionSheet(
        pendingAmount: pendingAmount,
        releaseAt: releaseTime,
        onClose: () {
          Get.back(); // ferme le sheet
          Future.delayed(const Duration(milliseconds: 300), () {
            Get.until((r) =>
                r.settings.name == AppRoutes.dashboardDriver || r.isFirst);
          });
        },
      ),
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
                // Points de prise passager (personne = en attente, check = embarqué)
                ...c.passengers
                    .where((p) => p.pickupLat != null && p.pickupLng != null)
                    .map((p) => Marker(
                          point: LatLng(p.pickupLat!, p.pickupLng!),
                          width: 36,
                          height: 36,
                          child: _PassengerPin(isBoarded: p.isBoarded),
                        )),
                // Points de dépôt passager (drapeau)
                ...c.passengers
                    .where((p) =>
                        p.dropoffLat != null && p.dropoffLng != null)
                    .map((p) => Marker(
                          point: LatLng(p.dropoffLat!, p.dropoffLng!),
                          width: 36,
                          height: 36,
                          child: const _PassengerDropoffPin(),
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
  const _PassengerPin({required this.isBoarded});
  final bool isBoarded;

  @override
  Widget build(BuildContext context) {
    final color = isBoarded ? AppColors.success : const Color(0xFF7C3AED);
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.40), blurRadius: 6),
        ],
      ),
      child: Icon(
        isBoarded ? Icons.check_rounded : Icons.person_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }
}

class _PassengerDropoffPin extends StatelessWidget {
  const _PassengerDropoffPin();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.40),
              blurRadius: 6,
            ),
          ],
        ),
        child: const Icon(Icons.flag_rounded, color: Colors.white, size: 16),
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
          // Arrêts prise en charge (violet)
          ...pax.asMap().entries.map((e) {
            final i = e.key;
            final p = e.value;
            return Obx(() {
              final cur       = c.passengers[i];
              final isPending = c.boardingPending.contains(p.bookingUuid);
              final isBoarded = cur.isBoarded;
              final isNoShow  = cur.isNoShow;
              final isNoShowPending = c.noShowPending.contains(p.bookingUuid);
              final isActive  = c.tripStatus.value == 'active' ||
                  c.tripStatus.value == 'in_progress' ||
                  c.tripStatus.value == 'started';
              final canNoShow = isActive && !isBoarded && !isNoShow && c.canReportNoShow(i);

              Color dotColor;
              Widget dotChild;
              String sublabel;
              if (isNoShow) {
                dotColor = AppColors.danger;
                dotChild = const Icon(Icons.person_off_rounded,
                    color: Colors.white, size: 14);
                sublabel = '${p.seats} place${p.seats > 1 ? 's' : ''} · Absent';
              } else if (isBoarded) {
                dotColor = AppColors.success;
                dotChild = const Icon(Icons.check_rounded,
                    color: Colors.white, size: 15);
                sublabel = '${p.seats} place${p.seats > 1 ? 's' : ''} · Embarqué';
              } else {
                dotColor = const Color(0xFF7C3AED);
                dotChild = Center(
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
                sublabel = '${p.seats} place${p.seats > 1 ? 's' : ''} · Prise en charge';
              }

              return _StopRow(
                connector: true,
                dot: _DotCircle(color: dotColor, child: dotChild),
                label: p.name,
                sublabel: sublabel,
                trailingPhone: p.phone.isNotEmpty && !isNoShow
                    ? () => c.callPassenger(i)
                    : null,
                trailingBoarding: isNoShow
                    ? null
                    : isActive && !isBoarded
                        ? canNoShow
                            ? _NoShowButton(
                                isPending: isNoShowPending,
                                onTap: isNoShowPending
                                    ? null
                                    : () => _confirmNoShow(context, c, i),
                              )
                            : _BoardingButton(
                                isPending: isPending,
                                bookingUuid: p.bookingUuid,
                                onTap: isPending
                                    ? () async { c.showBoardingDialog(p.bookingUuid); }
                                    : () => c.initiateBoarding(i),
                              )
                        : null,
                r: r,
              );
            });
          }),
          // Arrêts dépôt (amber) — uniquement si passager embarqué
          ...pax.asMap().entries
              .where((e) => e.value.isBoarded)
              .map((e) {
            final i = e.key;
            final p = e.value;
            return Obx(() {
              final isDropped   = c.passengers[i].isDroppedOff;
              final isDropping  = c.droppingOff.contains(p.bookingUuid);
              final isActive    = c.tripStatus.value == 'active' ||
                  c.tripStatus.value == 'in_progress' ||
                  c.tripStatus.value == 'started';
              return _StopRow(
                connector: true,
                dot: _DotCircle(
                  color: isDropped
                      ? AppColors.textHint
                      : const Color(0xFFF59E0B),
                  child: isDropped
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 15)
                      : Center(
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
                sublabel: isDropped
                    ? '${p.seats} place${p.seats > 1 ? 's' : ''} · Déposé'
                    : '${p.seats} place${p.seats > 1 ? 's' : ''} · À déposer',
                trailingBoarding: isActive && !isDropped
                    ? _DropoffButton(
                        isPending: isDropping,
                        onTap: isDropping
                            ? null
                            : () => c.dropoffPassenger(i),
                      )
                    : null,
                r: r,
              );
            });
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
    this.trailingBoarding,
  });
  final Widget dot;
  final String label;
  final String sublabel;
  final AppResponsive r;
  final bool connector;
  final VoidCallback? trailingPhone;
  final Widget? trailingBoarding;

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
          if (trailingBoarding != null) ...[
            Padding(
              padding: EdgeInsets.only(top: connector ? 10 : 0),
              child: trailingBoarding!,
            ),
            const SizedBox(width: 4),
          ],
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

// ── Bouton embarquement par passager ──────────────────────────────────────────

class _BoardingButton extends StatefulWidget {
  const _BoardingButton({
    required this.isPending,
    required this.bookingUuid,
    required this.onTap,
  });
  final bool isPending;
  final String bookingUuid;
  final Future<void> Function()? onTap;

  @override
  State<_BoardingButton> createState() => _BoardingButtonState();
}

class _BoardingButtonState extends State<_BoardingButton> {
  Timer? _countdownTimer;
  int _secondsLeft = 60;
  bool _isInitiating = false;

  @override
  void didUpdateWidget(_BoardingButton old) {
    super.didUpdateWidget(old);
    if (widget.isPending && !old.isPending) {
      _secondsLeft = 60;
      _countdownTimer?.cancel();
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        setState(() {
          if (_secondsLeft > 0) _secondsLeft--;
        });
      });
    } else if (!widget.isPending && old.isPending) {
      _countdownTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _countdownLabel {
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPending) {
      return GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.40),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 11,
                height: 11,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                _countdownLabel,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                '· Saisir code',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: (widget.onTap != null && !_isInitiating)
          ? () async {
              setState(() => _isInitiating = true);
              try {
                await widget.onTap!();
              } finally {
                if (mounted) setState(() => _isInitiating = false);
              }
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isInitiating)
              const SizedBox(
                width: 11, height: 11,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5, color: Color(0xFF7C3AED)),
              )
            else
              const Icon(Icons.how_to_reg_rounded,
                  size: 14, color: Color(0xFF7C3AED)),
            const SizedBox(width: 4),
            Text(
              _isInitiating ? 'Envoi...' : 'Embarquer',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Confirmation no-show (dialog) ────────────────────────────────────────────

Future<void> _confirmNoShow(
    BuildContext context, MonTrajetController c, int index) async {
  final name = index < c.passengers.length ? c.passengers[index].name : '?';
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Signaler une absence'),
      content: Text(
        '$name ne s\'est pas présenté(e) ?\n\n'
        'En confirmant, son paiement vous sera libéré en guise d\'indemnisation.',
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
          child: const Text('Confirmer l\'absence'),
        ),
      ],
    ),
  );
  if (confirmed == true) c.reportNoShow(index);
}

// ── Bouton dépôt par passager ─────────────────────────────────────────────────

class _DropoffButton extends StatelessWidget {
  const _DropoffButton({required this.isPending, required this.onTap});
  final bool isPending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Color(0xFFF59E0B),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.40),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_pin_circle_rounded,
                size: 14, color: Color(0xFFF59E0B)),
            SizedBox(width: 4),
            Text(
              'Déposer',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bouton no-show par passager ───────────────────────────────────────────────

class _NoShowButton extends StatelessWidget {
  const _NoShowButton({required this.isPending, required this.onTap});
  final bool isPending;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: AppColors.danger,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_rounded, size: 14, color: AppColors.danger),
            const SizedBox(width: 4),
            Text(
              'Absent',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
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
          status == 'started' ||
          status == 'picking_up' ||
          status == 'picked_up' ||
          status == 'ongoing' ||
          status == 'running' ||
          status == 'in_route';
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

      if (!isActive && !isPending) return const SizedBox.shrink();
      return _Btn(
        onTap: c.isCompleting.value ? null : c.completeTrip,
        icon: Icons.flag_rounded,
        label: c.isCompleting.value
            ? 'Finalisation…'
            : 'Terminer ma course',
        color: AppColors.danger,
        r: r,
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

// ─── Feuillet de fin de trajet — fenêtre 2h ───────────────────────────────────

class _CompletionSheet extends StatefulWidget {
  const _CompletionSheet({
    required this.pendingAmount,
    required this.releaseAt,
    required this.onClose,
  });
  final double pendingAmount;
  final DateTime? releaseAt;
  final VoidCallback onClose;

  @override
  State<_CompletionSheet> createState() => _CompletionSheetState();
}

class _CompletionSheetState extends State<_CompletionSheet> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_updateRemaining);
    });
  }

  void _updateRemaining() {
    if (widget.releaseAt == null) return;
    final diff = widget.releaseAt!.difference(DateTime.now());
    _remaining = diff.isNegative ? Duration.zero : diff;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _countdownLabel {
    final h = _remaining.inHours.toString().padLeft(2, '0');
    final m = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '${h}h ${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    final amountLabel =
        '${widget.pendingAmount.toStringAsFixed(0)} FCFA';
    final hasCountdown = widget.releaseAt != null && _remaining > Duration.zero;

    return Container(
      margin: EdgeInsets.only(
        bottom: MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 30),
          ),
          const SizedBox(height: 16),
          Text('Trajet terminé !', style: AppTextStyles.h4(r)),
          const SizedBox(height: 6),
          Text(
            'Bon travail. Vos passagers ont été déposés.',
            style: AppTextStyles.muted(r),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.20)),
            ),
            child: Column(
              children: [
                Text(
                  'Paiement en attente',
                  style: AppTextStyles.labelSmall(r)
                      .copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 6),
                Text(
                  amountLabel,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 32,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                if (hasCountdown) ...[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_top_rounded,
                          size: 16, color: AppColors.accent),
                      const SizedBox(width: 6),
                      Text(
                        'Disponible dans $_countdownLabel',
                        style: AppTextStyles.bodySmall(r).copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 18, color: AppColors.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Si votre passager confirme son avis maintenant, les fonds sont libérés immédiatement.',
                    style: AppTextStyles.bodySmall(r)
                        .copyWith(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: widget.onClose,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('OK, j\'ai compris',
                  style: AppTextStyles.button(r)),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/live_tracking_controller.dart';

class LiveTrackingView extends StatelessWidget {
	const LiveTrackingView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<LiveTrackingController>()
				? Get.find<LiveTrackingController>()
				: Get.put(LiveTrackingController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: Stack(
				fit: StackFit.expand,
				children: [
					// ── Carte plein écran ─────────────────────────────────────────
					Positioned.fill(child: _LiveMap(controller: controller)),

					// ── Barre du haut ─────────────────────────────────────────────
					Positioned(
						top: 0, left: 0, right: 0,
						child: SafeArea(
							child: _TopBar(responsive: responsive, controller: controller),
						),
					),

					// ── Boutons flottants droits ──────────────────────────────────
					Positioned(
						bottom: responsive.h(256),
						right: responsive.w(14),
						child: _FloatingButtons(controller: controller, responsive: responsive),
					),

					// ── Panneau du bas ────────────────────────────────────────────
					Positioned(
						bottom: 0, left: 0, right: 0,
						child: _BottomPanel(responsive: responsive, controller: controller),
					),

					// ── Banner d'attente (visible avant démarrage) ────────────────
					Obx(() {
						if (controller.tripStarted.value || controller.tripEnded.value) {
							return const SizedBox.shrink();
						}
						return Positioned(
							top: 0, left: 0, right: 0,
							child: SafeArea(
								child: _WaitingBanner(
										responsive: responsive, controller: controller),
							),
						);
					}),

					// ── Overlay fin de trajet ──────────────────────────────────────
					Obx(() {
						if (!controller.tripEnded.value) return const SizedBox.shrink();
						return Positioned.fill(
							child: _TripEndedOverlay(responsive: responsive),
						);
					}),
				],
			),
		);
	}
}

// ════════════════════════════════════════════════════════════════════════════
// CARTE INTERACTIVE
// ════════════════════════════════════════════════════════════════════════════

class _LiveMap extends StatelessWidget {
	const _LiveMap({required this.controller});
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		// Le FlutterMap n'est PAS dans un Obx — seules les couches internes le sont
		return FlutterMap(
			mapController: controller.mapController,
			options: MapOptions(
				initialCenter: controller.pickupLatLng.value,
				initialZoom: 12.0,
				minZoom: 4.5,
				maxZoom: 19.0,
				interactionOptions: const InteractionOptions(
					flags: InteractiveFlag.pinchZoom |
					       InteractiveFlag.drag       |
					       InteractiveFlag.doubleTapZoom,
				),
			),
			children: [
				// ── Tuiles CartoDB Voyager (style navigation proche Google Maps) ──
				TileLayer(
					urlTemplate:
						'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
					subdomains: const ['a', 'b', 'c', 'd'],
					userAgentPackageName: 'com.covoiturage.benin',
					maxZoom: 19,
					maxNativeZoom: 19,
				),

				// ── Route complète (gris clair) ─────────────────────────────────
				// Fond de ligne — s'affiche dès que OSRM répond
				Obx(() {
					final pts = controller.routePoints.toList();
					if (pts.length < 2) {
						// Ligne directe pickup→dropoff le temps que OSRM réponde
						final p = controller.pickupLatLng.value;
						final d = controller.dropoffLatLng.value;
						return PolylineLayer(polylines: [
							Polyline(
								points: [p, d],
								color: AppColors.borderStrong,
								strokeWidth: 7.0,
								strokeCap: StrokeCap.round,
								strokeJoin: StrokeJoin.round,
							),
						]);
					}
					return PolylineLayer(polylines: [
						Polyline(
							points: pts,
							color: AppColors.borderStrong,
							strokeWidth: 7.5,
							strokeCap: StrokeCap.round,
							strokeJoin: StrokeJoin.round,
							borderColor: AppColors.white31,
							borderStrokeWidth: 1.5,
						),
					]);
				}),

				// ── Portion parcourue (vert) — visible après démarrage ──────────
				Obx(() {
					if (!controller.tripStarted.value) return const SizedBox.shrink();
					final seg = controller.completedSegment;
					if (seg.length < 2) return const SizedBox.shrink();
					return PolylineLayer(polylines: [
						Polyline(
							points: seg,
							color: AppColors.primary,
							strokeWidth: 7.5,
							strokeCap: StrokeCap.round,
							strokeJoin: StrokeJoin.round,
							borderColor: AppColors.white25,
							borderStrokeWidth: 2.5,
						),
					]);
				}),

				// ── Marqueurs ────────────────────────────────────────────────────
				Obx(() {
					final pickup  = controller.pickupLatLng.value;
					final dropoff = controller.dropoffLatLng.value;
					final driver  = controller.driverLatLng.value;
					final started = controller.tripStarted.value;
					final heading = controller.driverHeading.value;

					return MarkerLayer(markers: [
						// Prise en charge (pickup) avec callout label
						Marker(
							point: pickup,
							width:  160,
							height: 62,
							alignment: Alignment.bottomCenter,
							child: _PickupCallout(label: controller.pickupCity),
						),
						// Dépôt (dropoff) avec callout label
						Marker(
							point: dropoff,
							width:  160,
							height: 62,
							alignment: Alignment.bottomCenter,
							child: _DropoffCallout(label: controller.dropoffCity),
						),
						// Voiture conducteur — visible dès qu'on a des coordonnées réelles
						if (started || controller.hasDriverCoords.value)
							Marker(
								point: driver,
								width:  72,
								height: 72,
								child: _CarMarker(headingDeg: heading),
							),
					]);
				}),
			],
		);
	}
}

// ════════════════════════════════════════════════════════════════════════════
// MARQUEURS CARTE
// ════════════════════════════════════════════════════════════════════════════

/// Callout vert "Départ" — style Google Maps
class _PickupCallout extends StatelessWidget {
	const _PickupCallout({required this.label});
	final String label;

	static const _bg = AppColors.primary;

	@override
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				// Bulle label
				Container(
					constraints: const BoxConstraints(maxWidth: 148),
					padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
					decoration: BoxDecoration(
						color: _bg,
						borderRadius: BorderRadius.circular(10),
						boxShadow: const [
							BoxShadow(color: AppColors.primary, blurRadius: 10, offset: Offset(0, 4)),
						],
					),
					child: Row(
						mainAxisSize: MainAxisSize.min,
						children: [
							const Icon(Icons.trip_origin_rounded, color: Colors.white, size: 10),
							const SizedBox(width: 5),
							Flexible(
								child: Text(
									label,
									style: const TextStyle(
										color: Colors.white,
										fontSize: 11.5,
										fontWeight: FontWeight.w700,
										fontFamily: 'Inter',
										letterSpacing: 0.1,
									),
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
								),
							),
						],
					),
				),
				// Pointe vers le bas
				_CalloutTip(color: _bg),
				// Cercle pin
				Container(
					width: 14, height: 14,
					decoration: BoxDecoration(
						color: _bg,
						shape: BoxShape.circle,
						border: Border.all(color: Colors.white, width: 2.5),
						boxShadow: const [BoxShadow(color: AppColors.primary, blurRadius: 6)],
					),
				),
			],
		);
	}
}

/// Callout rouge "Destination" — style Google Maps
class _DropoffCallout extends StatelessWidget {
	const _DropoffCallout({required this.label});
	final String label;

	static const _bg = AppColors.danger;

	@override
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			crossAxisAlignment: CrossAxisAlignment.center,
			children: [
				// Bulle label
				Container(
					constraints: const BoxConstraints(maxWidth: 148),
					padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
					decoration: BoxDecoration(
						color: _bg,
						borderRadius: BorderRadius.circular(10),
						boxShadow: const [
							BoxShadow(color: AppColors.danger, blurRadius: 10, offset: Offset(0, 4)),
						],
					),
					child: Row(
						mainAxisSize: MainAxisSize.min,
						children: [
							const Icon(Icons.flag_rounded, color: Colors.white, size: 10),
							const SizedBox(width: 5),
							Flexible(
								child: Text(
									label,
									style: const TextStyle(
										color: Colors.white,
										fontSize: 11.5,
										fontWeight: FontWeight.w700,
										fontFamily: 'Inter',
										letterSpacing: 0.1,
									),
									maxLines: 1,
									overflow: TextOverflow.ellipsis,
								),
							),
						],
					),
				),
				_CalloutTip(color: _bg),
				Container(
					width: 14, height: 14,
					decoration: BoxDecoration(
						color: _bg,
						shape: BoxShape.circle,
						border: Border.all(color: Colors.white, width: 2.5),
						boxShadow: const [BoxShadow(color: AppColors.danger, blurRadius: 6)],
					),
				),
			],
		);
	}
}

/// Triangle pointant vers le bas (connecteur callout → pin)
class _CalloutTip extends StatelessWidget {
	const _CalloutTip({required this.color});
	final Color color;

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: 12, height: 7,
			child: CustomPaint(painter: _TipPainter(color: color)),
		);
	}
}

class _TipPainter extends CustomPainter {
	const _TipPainter({required this.color});
	final Color color;

	@override
	void paint(Canvas canvas, Size size) {
		canvas.drawPath(
			Path()
				..moveTo(0, 0)
				..lineTo(size.width, 0)
				..lineTo(size.width / 2, size.height)
				..close(),
			Paint()..color = color,
		);
	}

	@override
	bool shouldRepaint(_TipPainter old) => old.color != color;
}

/// Voiture du conducteur — halo pulsant + rotation selon cap
class _CarMarker extends StatefulWidget {
	const _CarMarker({required this.headingDeg});
	final double headingDeg;

	@override
	State<_CarMarker> createState() => _CarMarkerState();
}

class _CarMarkerState extends State<_CarMarker>
		with SingleTickerProviderStateMixin {
	late final AnimationController _pulse;
	late final Animation<double> _scale;

	@override
	void initState() {
		super.initState();
		_pulse = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 1500),
		)..repeat(reverse: true);
		_scale = Tween<double>(begin: 1.0, end: 1.18).animate(
			CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
	}

	@override
	void dispose() {
		_pulse.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Transform.rotate(
			angle: widget.headingDeg * pi / 180,
			child: AnimatedBuilder(
				animation: _scale,
				builder: (ctx, child) => Transform.scale(
					scale: _scale.value,
					child: Container(
						margin: const EdgeInsets.all(6),
						decoration: BoxDecoration(
							color: Colors.white,
							shape: BoxShape.circle,
							border: Border.all(color: AppColors.primary, width: 2.5),
							boxShadow: [
								BoxShadow(
									color: AppColors.primary.withValues(alpha: 0.45),
									blurRadius: 18,
									spreadRadius: 2,
									offset: const Offset(0, 4),
								),
							],
						),
						child: const Icon(
							Icons.navigation_rounded,
							color: AppColors.primary,
							size: 28,
						),
					),
				),
			),
		);
	}
}

// ════════════════════════════════════════════════════════════════════════════
// BARRE DU HAUT
// ════════════════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
	const _TopBar({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(
					horizontal: responsive.w(14), vertical: responsive.h(10)),
			child: Row(
				children: [
					_GlassButton(icon: Icons.chevron_left_rounded, onTap: Get.back),
					const Spacer(),
					Obx(() => _StatusChip(
						started: controller.tripStarted.value,
						voiceOn: controller.voiceEnabled.value,
						responsive: responsive,
					)),
					const Spacer(),
					_GlassButton(
						icon: Icons.crisis_alert_rounded,
						onTap: controller.triggerSOS,
						color: AppColors.danger,
					),
				],
			),
		);
	}
}

class _StatusChip extends StatelessWidget {
	const _StatusChip({
		required this.started,
		required this.voiceOn,
		required this.responsive,
	});

	final bool started;
	final bool voiceOn;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
					horizontal: responsive.w(14), vertical: responsive.h(7)),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(9999),
				boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					_PulsingDot(color: started ? AppColors.primary : AppColors.warning),
					SizedBox(width: responsive.w(7)),
					Text(
						started ? 'Trajet en cours' : 'En attente',
						style: AppTextStyles.caption(responsive).copyWith(
								fontWeight: FontWeight.w700, color: AppColors.textPrimary),
					),
					if (!voiceOn) ...[
						SizedBox(width: responsive.w(6)),
						const Icon(Icons.volume_off_rounded,
								size: 13, color: AppColors.textHint),
					],
				],
			),
		);
	}
}

class _GlassButton extends StatelessWidget {
	const _GlassButton({required this.icon, required this.onTap, this.color});

	final IconData     icon;
	final VoidCallback onTap;
	final Color?       color;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(9999),
				child: Container(
					width:  responsive.w(44),
					height: responsive.w(44),
					decoration: BoxDecoration(
						color: color != null
								? color!.withValues(alpha: 0.14)
								: Colors.white,
						shape: BoxShape.circle,
						border: Border.all(
							color: color ?? Colors.white.withValues(alpha: 0.50)),
						boxShadow: const [
							BoxShadow(color: AppColors.shadow, blurRadius: 8),
						],
					),
					child: Icon(icon,
							size: responsive.text(20),
							color: color ?? AppColors.textPrimary),
				),
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

class _PulsingDotState extends State<_PulsingDot>
		with SingleTickerProviderStateMixin {
	late final AnimationController _anim;
	late final Animation<double>   _scale;

	@override
	void initState() {
		super.initState();
		_anim = AnimationController(
				vsync: this, duration: const Duration(milliseconds: 900))
				..repeat(reverse: true);
		_scale = Tween(begin: 0.65, end: 1.0)
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

// ════════════════════════════════════════════════════════════════════════════
// BOUTONS FLOTTANTS
// ════════════════════════════════════════════════════════════════════════════

class _FloatingButtons extends StatelessWidget {
	const _FloatingButtons({required this.controller, required this.responsive});

	final LiveTrackingController controller;
	final AppResponsive          responsive;

	@override
	Widget build(BuildContext context) {
		return Column(
			mainAxisSize: MainAxisSize.min,
			children: [
				// Centrer sur conducteur
				_MapFab(
					icon: Icons.my_location_rounded,
					color: AppColors.primary,
					onTap: controller.centerOnDriver,
					responsive: responsive,
				),
				SizedBox(height: responsive.h(10)),
				// Vue d'ensemble (pickup + dropoff + conducteur)
				_MapFab(
					icon: Icons.zoom_out_map_rounded,
					color: AppColors.textSecondary,
					onTap: controller.fitAllPoints,
					responsive: responsive,
				),
				SizedBox(height: responsive.h(10)),
				// Activer / couper la voix
				Obx(() => _MapFab(
					icon: controller.voiceEnabled.value
							? Icons.volume_up_rounded
							: Icons.volume_off_rounded,
					color: controller.voiceEnabled.value
							? AppColors.primary
							: AppColors.textHint,
					onTap: controller.toggleVoice,
					responsive: responsive,
				)),
			],
		);
	}
}

class _MapFab extends StatelessWidget {
	const _MapFab({
		required this.icon,
		required this.color,
		required this.onTap,
		required this.responsive,
	});

	final IconData     icon;
	final Color        color;
	final VoidCallback onTap;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: Container(
				width:  responsive.w(44),
				height: responsive.w(44),
				decoration: BoxDecoration(
					color: Colors.white,
					shape: BoxShape.circle,
					boxShadow: const [
						BoxShadow(
								color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
					],
				),
				child: Icon(icon, color: color, size: responsive.text(20)),
			),
		);
	}
}

// ════════════════════════════════════════════════════════════════════════════
// BANNER "EN ATTENTE"
// ════════════════════════════════════════════════════════════════════════════

class _WaitingBanner extends StatelessWidget {
	const _WaitingBanner({required this.responsive, required this.controller});

	final AppResponsive          responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final status = controller.apiTripStatus.value;
			// Si l'API indique un statut de démarrage, passer en mode "en cours"
			final isNearStart = status == 'picking_up' || status == 'accepted' || status == 'confirmed';
			final bgColor  = isNearStart ? AppColors.primarySurface : AppColors.warningSurface;
			final border   = isNearStart ? AppColors.primary : AppColors.warning;
			final iconColor= isNearStart ? AppColors.primary : AppColors.warning;
			final titleColor= isNearStart ? AppColors.blueDark : AppColors.warningDark;
			final subColor = isNearStart ? AppColors.primary : AppColors.warningDark;
			final icon     = isNearStart ? Icons.near_me_rounded   : Icons.access_time_rounded;

			return Padding(
				padding: EdgeInsets.only(
						top:   responsive.h(70),
						left:  responsive.w(14),
						right: responsive.w(14)),
				child: Container(
					width: double.infinity,
					padding: EdgeInsets.symmetric(
							horizontal: responsive.w(14), vertical: responsive.h(11)),
					decoration: BoxDecoration(
						color: bgColor,
						borderRadius: BorderRadius.circular(responsive.radius(14)),
						border: Border.all(color: border.withValues(alpha: 0.40)),
						boxShadow: const [
							BoxShadow(color: AppColors.shadow, blurRadius: 14, offset: Offset(0, 4)),
						],
					),
					child: Row(
						children: [
							Container(
								width:  responsive.w(36),
								height: responsive.w(36),
								decoration: BoxDecoration(
									color: iconColor.withValues(alpha: 0.14),
									shape: BoxShape.circle,
								),
								child: Icon(icon, color: iconColor, size: responsive.text(18)),
							),
							SizedBox(width: responsive.w(12)),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											controller.waitingStatusLabel,
											style: AppTextStyles.body(responsive).copyWith(
													fontWeight: FontWeight.w700, color: titleColor),
										),
										SizedBox(height: responsive.h(2)),
										Text(
											isNearStart
												? 'Le conducteur se dirige vers votre position.'
												: 'La carte s\'activera dès que le conducteur démarre.',
											style: AppTextStyles.caption(responsive)
													.copyWith(color: subColor),
										),
									],
								),
							),
							// Indicateur de polling (petite balle pulsante)
							_PollingDot(color: iconColor),
						],
					),
				),
			);
		});
	}
}

class _PollingDot extends StatefulWidget {
	const _PollingDot({required this.color});
	final Color color;

	@override
	State<_PollingDot> createState() => _PollingDotState();
}

class _PollingDotState extends State<_PollingDot>
		with SingleTickerProviderStateMixin {
	late final AnimationController _anim;

	@override
	void initState() {
		super.initState();
		_anim = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 900),
		)..repeat(reverse: true);
	}

	@override
	void dispose() {
		_anim.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return FadeTransition(
			opacity: _anim,
			child: Container(
				width: 8, height: 8,
				decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
			),
		);
	}
}

// ════════════════════════════════════════════════════════════════════════════
// PANNEAU DU BAS
// ════════════════════════════════════════════════════════════════════════════

class _BottomPanel extends StatelessWidget {
	const _BottomPanel({required this.responsive, required this.controller});

	final AppResponsive          responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		final safeBottom = MediaQuery.of(context).padding.bottom;
		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius:
						BorderRadius.vertical(top: Radius.circular(responsive.radius(22))),
				boxShadow: const [
					BoxShadow(color: AppColors.shadow, blurRadius: 22, offset: Offset(0, -4)),
				],
			),
			padding: EdgeInsets.fromLTRB(
				responsive.w(18),
				responsive.h(10),
				responsive.w(18),
				responsive.h(14) + safeBottom,
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					// Handle
					Container(
						width: responsive.w(34),
						height: responsive.h(4),
						decoration: BoxDecoration(
								color: AppColors.border,
								borderRadius: BorderRadius.circular(9999)),
					),
					SizedBox(height: responsive.h(12)),

					// Route prise en charge → dépôt
					_RouteRow(responsive: responsive, controller: controller),
					SizedBox(height: responsive.h(12)),
					_Divider(),

					// Métriques ETA / distance / vitesse
					Obx(() => controller.tripStarted.value
							? _MetricsRow(responsive: responsive, controller: controller)
							: _WaitingMetrics(responsive: responsive)),
					_Divider(),

					// Conducteur + bouton appel
					_DriverRow(responsive: responsive, controller: controller),
					SizedBox(height: responsive.h(12)),

					// Messages rapides
					_QuickMessages(responsive: responsive, controller: controller),
				],
			),
		);
	}
}

class _Divider extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		return Padding(
			padding: EdgeInsets.symmetric(vertical: responsive.h(10)),
			child: Container(height: 1, color: AppColors.border),
		);
	}
}

// ── Ligne route avec icônes départ / arrivée ─────────────────────────────────

class _RouteRow extends StatelessWidget {
	const _RouteRow({required this.responsive, required this.controller});

	final AppResponsive          responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				// Ligne verticale avec points colorés
				Column(
					children: [
						Container(
							width: 11, height: 11,
							decoration: const BoxDecoration(
									color: AppColors.primary, shape: BoxShape.circle),
						),
						Container(width: 2, height: 26, color: AppColors.border),
						Container(
							width: 11, height: 11,
							decoration: const BoxDecoration(
									color: AppColors.danger, shape: BoxShape.circle),
						),
					],
				),
				SizedBox(width: responsive.w(12)),
				// Labels
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								controller.pickupLabel,
								style: AppTextStyles.body(responsive)
										.copyWith(fontWeight: FontWeight.w600),
								maxLines: 1,
								overflow: TextOverflow.ellipsis,
							),
							SizedBox(height: responsive.h(12)),
							Text(
								controller.dropoffLabel,
								style: AppTextStyles.body(responsive)
										.copyWith(fontWeight: FontWeight.w600),
								maxLines: 1,
								overflow: TextOverflow.ellipsis,
							),
						],
					),
				),
			],
		);
	}
}

// ── Métriques ETA / distance / vitesse ───────────────────────────────────────

class _MetricsRow extends StatelessWidget {
	const _MetricsRow({required this.responsive, required this.controller});

	final AppResponsive          responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() => Row(
			children: [
				Expanded(
					child: _MetricTile(
						responsive: responsive,
						icon: Icons.schedule_rounded,
						iconColor: AppColors.primary,
						label: 'Arrivée',
						value: '${controller.etaMinutes.value} min',
					),
				),
				Container(width: 1, height: responsive.h(38), color: AppColors.border),
				Expanded(
					child: _MetricTile(
						responsive: responsive,
						icon: Icons.route_rounded,
						iconColor: AppColors.primary,
						label: 'Restant',
						value: '${controller.distanceRemainingKm.value} km',
					),
				),
				Container(width: 1, height: responsive.h(38), color: AppColors.border),
				Expanded(
					child: _MetricTile(
						responsive: responsive,
						icon: Icons.speed_rounded,
						iconColor: AppColors.warning,
						label: 'Vitesse',
						value: '${controller.driverSpeedKmh.value} km/h',
					),
				),
			],
		));
	}
}

class _WaitingMetrics extends StatelessWidget {
	const _WaitingMetrics({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(
					horizontal: responsive.w(14), vertical: responsive.h(10)),
			decoration: BoxDecoration(
				color: AppColors.surface,
				borderRadius: BorderRadius.circular(responsive.radius(10)),
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					const SizedBox(
						width: 14, height: 14,
						child: CircularProgressIndicator(
								strokeWidth: 2, color: AppColors.primary),
					),
					SizedBox(width: responsive.w(10)),
					Text(
						'En attente du démarrage du conducteur…',
						style: AppTextStyles.caption(responsive)
								.copyWith(color: AppColors.textSecondary),
					),
				],
			),
		);
	}
}

class _MetricTile extends StatelessWidget {
	const _MetricTile({
		required this.responsive,
		required this.icon,
		required this.iconColor,
		required this.label,
		required this.value,
	});

	final AppResponsive responsive;
	final IconData      icon;
	final Color         iconColor;
	final String        label;
	final String        value;

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Icon(icon, size: responsive.text(17), color: iconColor),
				SizedBox(height: responsive.h(3)),
				Text(value,
						style: AppTextStyles.subtitle(responsive)
								.copyWith(fontWeight: FontWeight.w700)),
				Text(label,
						style: AppTextStyles.caption(responsive),
						textAlign: TextAlign.center),
			],
		);
	}
}

// ── Conducteur + bouton appel ─────────────────────────────────────────────────

class _DriverRow extends StatelessWidget {
	const _DriverRow({required this.responsive, required this.controller});

	final AppResponsive          responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() => Row(
			children: [
				_DriverAvatar(name: controller.driverName, size: responsive.w(48)),
				SizedBox(width: responsive.w(12)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(controller.driverName,
									style: AppTextStyles.subtitle(responsive)
											.copyWith(fontWeight: FontWeight.w700)),
							SizedBox(height: responsive.h(2)),
							Row(
								children: [
									const Icon(Icons.star_rounded,
											size: 12, color: AppColors.warning),
									SizedBox(width: responsive.w(3)),
									Expanded(
										child: Text(
											'${controller.driverRating} · ${controller.vehicleLabel}',
											style: AppTextStyles.caption(responsive),
											overflow: TextOverflow.ellipsis,
										),
									),
								],
							),
						],
					),
				),
				_ActionButton(
					icon: Icons.phone_rounded,
					label: 'Appeler',
					color: AppColors.primary,
					onTap: controller.callDriver,
					responsive: responsive,
				),
			],
		));
	}
}

class _ActionButton extends StatelessWidget {
	const _ActionButton({
		required this.icon,
		required this.label,
		required this.color,
		required this.onTap,
		required this.responsive,
	});

	final IconData     icon;
	final String       label;
	final Color        color;
	final VoidCallback onTap;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(responsive.radius(12)),
			child: Container(
				padding: EdgeInsets.symmetric(
						horizontal: responsive.w(14), vertical: responsive.h(8)),
				decoration: BoxDecoration(
					color: color.withValues(alpha: 0.10),
					borderRadius: BorderRadius.circular(responsive.radius(12)),
					border: Border.all(color: color.withValues(alpha: 0.30)),
				),
				child: Column(
					children: [
						Icon(icon, size: responsive.text(20), color: color),
						SizedBox(height: responsive.h(2)),
						Text(label,
								style: AppTextStyles.caption(responsive).copyWith(
										color: color, fontWeight: FontWeight.w600)),
					],
				),
			),
		);
	}
}

// ── Messages rapides ──────────────────────────────────────────────────────────

class _QuickMessages extends StatelessWidget {
	const _QuickMessages({required this.responsive, required this.controller});

	final AppResponsive          responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			height: responsive.h(36),
			child: ListView.separated(
				scrollDirection: Axis.horizontal,
				itemCount: controller.quickMessages.length,
				separatorBuilder: (_, _) => SizedBox(width: responsive.w(8)),
				itemBuilder: (_, i) {
					final msg = controller.quickMessages[i];
					return InkWell(
						onTap: () => controller.sendQuickMessage(msg),
						borderRadius: BorderRadius.circular(9999),
						child: Container(
							padding: EdgeInsets.symmetric(
									horizontal: responsive.w(13), vertical: responsive.h(5)),
							decoration: BoxDecoration(
								color: AppColors.surfaceMuted,
								borderRadius: BorderRadius.circular(9999),
								border: Border.all(color: AppColors.border),
							),
							child: Text(msg,
									style: AppTextStyles.caption(responsive)
											.copyWith(fontWeight: FontWeight.w500)),
						),
					);
				},
			),
		);
	}
}

// ════════════════════════════════════════════════════════════════════════════
// OVERLAY FIN DE TRAJET
// ════════════════════════════════════════════════════════════════════════════

class _TripEndedOverlay extends StatelessWidget {
	const _TripEndedOverlay({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			color: Colors.black.withValues(alpha: 0.60),
			child: Center(
				child: Container(
					margin: EdgeInsets.symmetric(horizontal: responsive.w(32)),
					padding: EdgeInsets.all(responsive.w(28)),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(responsive.radius(24)),
					),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							Container(
								width:  responsive.w(72),
								height: responsive.w(72),
								decoration: const BoxDecoration(
										shape: BoxShape.circle, color: AppColors.primaryLight),
								child: const Icon(Icons.check_circle_rounded,
										color: AppColors.primary, size: 40),
							),
							SizedBox(height: responsive.h(16)),
							Text('Vous êtes arrivé !',
									style: AppTextStyles.h6(responsive)
											.copyWith(fontSize: responsive.text(18))),
							SizedBox(height: responsive.h(6)),
							Text("Redirection vers l'évaluation…",
									style: AppTextStyles.caption(responsive),
									textAlign: TextAlign.center),
							SizedBox(height: responsive.h(16)),
							const SizedBox(
								width: 28, height: 28,
								child: CircularProgressIndicator(
										color: AppColors.primary, strokeWidth: 2.5),
							),
						],
					),
				),
			),
		);
	}
}

// ════════════════════════════════════════════════════════════════════════════
// AVATAR CONDUCTEUR
// ════════════════════════════════════════════════════════════════════════════

class _DriverAvatar extends StatelessWidget {
	const _DriverAvatar({required this.name, required this.size});

	final String name;
	final double size;

	@override
	Widget build(BuildContext context) {
		final parts    = name.trim().split(RegExp(r'\s+'));
		final first    = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : 'C';
		final second   = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
		final initials = (first + second).toUpperCase();

		return Container(
			width: size, height: size,
			decoration: BoxDecoration(
				color: AppColors.successSurface,
				borderRadius: BorderRadius.circular(14),
				border: Border.all(color: AppColors.border),
			),
			child: Center(
				child: Text(
					initials,
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

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/live_tracking_controller.dart';

class LiveTrackingView extends StatelessWidget {
	const LiveTrackingView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller =
				Get.isRegistered<LiveTrackingController>()
						? Get.find<LiveTrackingController>()
						: Get.put(LiveTrackingController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: const Color(0xFFE8EFF0),
			body: Stack(
				fit: StackFit.expand,
				children: [
					// ── Vraie carte OpenStreetMap ──────────────────────────────
					Positioned.fill(
						child: _RealMap(controller: controller),
					),

					// ── Barre du haut ──────────────────────────────────────────
					Positioned(
						top: 0, left: 0, right: 0,
						child: SafeArea(
							child: _TopBar(responsive: responsive, controller: controller),
						),
					),

					// ── Panneau du bas ─────────────────────────────────────────
					Positioned(
						bottom: 0, left: 0, right: 0,
						child: _BottomPanel(responsive: responsive, controller: controller),
					),

					// ── Bouton centrer ─────────────────────────────────────────
					Positioned(
						bottom: responsive.h(220),
						right: responsive.w(16),
						child: _CenterButton(controller: controller, responsive: responsive),
					),

					// ── Overlay fin de trajet ──────────────────────────────────
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

// ── Vraie carte ────────────────────────────────────────────────────────────

class _RealMap extends StatelessWidget {
	const _RealMap({required this.controller});

	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return FlutterMap(
			mapController: controller.mapController,
			options: const MapOptions(
				initialCenter: LatLng(7.8000, 2.3000), // Centre Bénin
				initialZoom: 7.5,
				minZoom: 5.0,
				maxZoom: 18.0,
				interactionOptions: InteractionOptions(
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

				// Trace grise (trajet complet)
				PolylineLayer(polylines: [
					Polyline(
						points: LiveTrackingController.routePoints,
						color: const Color(0xFFBEC8C0),
						strokeWidth: 6.0,
						strokeCap: StrokeCap.round,
						strokeJoin: StrokeJoin.round,
					),
				]),

				// Trace verte (portion déjà parcourue) — réactive
				Obx(() => PolylineLayer(polylines: [
					Polyline(
						points: controller.completedSegment,
						color: AppColors.primary,
						strokeWidth: 6.5,
						strokeCap: StrokeCap.round,
						strokeJoin: StrokeJoin.round,
						borderColor: Colors.white.withValues(alpha: 0.55),
						borderStrokeWidth: 2.5,
					),
				])),

				// Marqueurs — réactifs
				Obx(() => MarkerLayer(markers: [
					// Origine (Cotonou)
					Marker(
						point: LiveTrackingController.routePoints.first,
						width: 36,
						height: 36,
						child: _OriginPin(),
					),
					// Destination (Parakou)
					Marker(
						point: LiveTrackingController.routePoints.last,
						width: 36,
						height: 50,
						alignment: Alignment.bottomCenter,
						child: _DestinationPin(),
					),
					// Conducteur (en mouvement)
					Marker(
						point: controller.driverLatLng.value,
						width: 56,
						height: 56,
						child: _CarMarker(),
					),
				])),
			],
		);
	}
}

// ── Marqueurs ──────────────────────────────────────────────────────────────

class _OriginPin extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				color: AppColors.primary,
				shape: BoxShape.circle,
				border: Border.all(color: Colors.white, width: 3),
				boxShadow: const [BoxShadow(color: Color(0x4000A86B), blurRadius: 8, offset: Offset(0, 3))],
			),
			child: const Icon(Icons.trip_origin_rounded, color: Colors.white, size: 16),
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
					width: 36,
					height: 36,
					decoration: const BoxDecoration(
						color: Color(0xFFEF4444),
						shape: BoxShape.circle,
					),
					child: const Icon(Icons.location_on_rounded, color: Colors.white, size: 20),
				),
				// Tige du pin
				Container(
					width: 3,
					height: 10,
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

class _CarMarker extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				color: AppColors.primary,
				shape: BoxShape.circle,
				border: Border.all(color: Colors.white, width: 3),
				boxShadow: const [
					BoxShadow(color: Color(0x5000A86B), blurRadius: 12, offset: Offset(0, 4)),
				],
			),
			child: const Icon(Icons.directions_car_filled_rounded, color: Colors.white, size: 26),
		);
	}
}

// ── Bouton centrer sur le conducteur ───────────────────────────────────────

class _CenterButton extends StatelessWidget {
	const _CenterButton({required this.controller, required this.responsive});

	final LiveTrackingController controller;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: () {
				try {
					controller.mapController.move(
						controller.driverLatLng.value,
						10.0,
					);
				} catch (_) {}
			},
			child: Container(
				width: responsive.w(44),
				height: responsive.w(44),
				decoration: BoxDecoration(
					color: Colors.white,
					shape: BoxShape.circle,
					boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 8, offset: Offset(0, 2))],
				),
				child: Icon(Icons.my_location_rounded, color: AppColors.primary, size: responsive.text(20)),
			),
		);
	}
}

// ── Barre du haut ──────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
	const _TopBar({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(12)),
			child: Row(
				children: [
					_GlassButton(icon: Icons.chevron_left_rounded, onTap: Get.back),
					const Spacer(),
					Container(
						padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(8)),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(9999),
							boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 10)],
						),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								_PulsingDot(),
								SizedBox(width: responsive.w(8)),
								Text('Trajet en cours',
										style: AppTextStyles.caption(responsive)
												.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
							],
						),
					),
					const Spacer(),
					_GlassButton(
						icon: Icons.crisis_alert_rounded,
						onTap: controller.triggerSOS,
						color: const Color(0xFFEF4444),
					),
				],
			),
		);
	}
}

class _GlassButton extends StatelessWidget {
	const _GlassButton({required this.icon, required this.onTap, this.color});

	final IconData icon;
	final VoidCallback onTap;
	final Color? color;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(9999),
				child: Container(
					width: responsive.w(44),
					height: responsive.w(44),
					decoration: BoxDecoration(
						color: color != null ? color!.withValues(alpha: 0.15) : Colors.white,
						shape: BoxShape.circle,
						border: Border.all(color: color ?? Colors.white.withValues(alpha: 0.5)),
						boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 8)],
					),
					child: Icon(icon, size: responsive.text(20), color: color ?? AppColors.textPrimary),
				),
			),
		);
	}
}

class _PulsingDot extends StatefulWidget {
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
				decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
			),
		);
	}
}

// ── Panneau du bas ─────────────────────────────────────────────────────────

class _BottomPanel extends StatelessWidget {
	const _BottomPanel({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.radius(24))),
				boxShadow: const [BoxShadow(color: Color(0x40000000), blurRadius: 20, offset: Offset(0, -4))],
			),
			padding: EdgeInsets.fromLTRB(
				responsive.w(20),
				responsive.h(20),
				responsive.w(20),
				responsive.h(20) + MediaQuery.of(context).padding.bottom,
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				children: [
					// Handle
					Container(
						width: responsive.w(36), height: responsive.h(4),
						decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999)),
					),
					SizedBox(height: responsive.h(16)),
					_EtaRow(responsive: responsive, controller: controller),
					SizedBox(height: responsive.h(16)),
					Container(height: 1, color: AppColors.border),
					SizedBox(height: responsive.h(16)),
					_DriverRow(responsive: responsive, controller: controller),
					SizedBox(height: responsive.h(16)),
					_QuickMessages(responsive: responsive, controller: controller),
				],
			),
		);
	}
}

class _EtaRow extends StatelessWidget {
	const _EtaRow({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() => Row(
			children: [
				Expanded(child: _MetricTile(
					responsive: responsive,
					icon: Icons.schedule_rounded,
					iconColor: AppColors.primary,
					label: 'Arrivée estimée',
					value: '${controller.etaMinutes.value} min',
				)),
				Container(width: 1, height: responsive.h(40), color: AppColors.border),
				Expanded(child: _MetricTile(
					responsive: responsive,
					icon: Icons.route_rounded,
					iconColor: AppColors.blue,
					label: 'Distance restante',
					value: '${controller.distanceRemainingKm.value} km',
				)),
				Container(width: 1, height: responsive.h(40), color: AppColors.border),
				Expanded(child: _MetricTile(
					responsive: responsive,
					icon: Icons.speed_rounded,
					iconColor: AppColors.warning,
					label: 'Vitesse',
					value: '${controller.driverSpeedKmh.value} km/h',
				)),
			],
		));
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
	final IconData icon;
	final Color iconColor;
	final String label;
	final String value;

	@override
	Widget build(BuildContext context) {
		return Column(
			children: [
				Icon(icon, size: responsive.text(18), color: iconColor),
				SizedBox(height: responsive.h(4)),
				Text(value, style: AppTextStyles.subtitle(responsive)),
				Text(label, style: AppTextStyles.caption(responsive), textAlign: TextAlign.center),
			],
		);
	}
}

class _DriverRow extends StatelessWidget {
	const _DriverRow({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final ride = controller.ride.value;
			final driverName = ride?.driverName ?? 'Votre conducteur';
			final vehicle    = ride?.vehicle   ?? 'Véhicule';
			final rating     = ride?.rating    ?? '4.8';

			return Row(
				children: [
					_DriverAvatar(name: driverName, size: responsive.w(48)),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(driverName, style: AppTextStyles.subtitle(responsive)),
								SizedBox(height: responsive.h(2)),
								Row(
									children: [
										Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.warning),
										SizedBox(width: responsive.w(4)),
										Text('$rating · $vehicle', style: AppTextStyles.caption(responsive)),
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
			);
		});
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

	final IconData icon;
	final String label;
	final Color color;
	final VoidCallback onTap;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(responsive.radius(12)),
			child: Container(
				padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(8)),
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
								style: AppTextStyles.caption(responsive)
										.copyWith(color: color, fontWeight: FontWeight.w600)),
					],
				),
			),
		);
	}
}

class _QuickMessages extends StatelessWidget {
	const _QuickMessages({required this.responsive, required this.controller});

	final AppResponsive responsive;
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
									horizontal: responsive.w(14), vertical: responsive.h(6)),
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

// ── Overlay fin de trajet ──────────────────────────────────────────────────

class _TripEndedOverlay extends StatelessWidget {
	const _TripEndedOverlay({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			color: Colors.black.withValues(alpha: 0.6),
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
								width: responsive.w(72),
								height: responsive.w(72),
								decoration: const BoxDecoration(
										shape: BoxShape.circle, color: Color(0x1900A86B)),
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

// ── Avatar conducteur ──────────────────────────────────────────────────────

class _DriverAvatar extends StatelessWidget {
	const _DriverAvatar({required this.name, required this.size});

	final String name;
	final double size;

	@override
	Widget build(BuildContext context) {
		final parts   = name.trim().split(RegExp(r'\s+'));
		final first   = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : 'C';
		final second  = parts.length > 1 && parts[1].isNotEmpty   ? parts[1][0]     : '';
		final initials = (first + second).toUpperCase();

		return Container(
			width: size, height: size,
			decoration: BoxDecoration(
				color: const Color(0xFFF5F5F5),
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

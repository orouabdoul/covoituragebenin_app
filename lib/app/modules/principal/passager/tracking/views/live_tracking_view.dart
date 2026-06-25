import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/live_tracking_controller.dart';

class LiveTrackingView extends StatelessWidget {
	const LiveTrackingView({super.key});

	@override
	Widget build(BuildContext context) {
		final LiveTrackingController controller =
				Get.isRegistered<LiveTrackingController>()
						? Get.find<LiveTrackingController>()
						: Get.put(LiveTrackingController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: const Color(0xFFE9EDE8),
			body: Stack(
				fit: StackFit.expand,
				children: [
					// Carte plein écran
					Positioned.fill(
						child: Obx(() => _AnimatedMap(
							progress: controller.driverProgress.value,
							origin: controller.ride.value?.origin ?? 'Cotonou',
							destination: controller.ride.value?.destination ?? 'Parakou',
						)),
					),
					// Barre du haut
					Positioned(
						top: 0,
						left: 0,
						right: 0,
						child: SafeArea(
							child: _TopBar(responsive: responsive, controller: controller),
						),
					),
					// Panneau du bas
					Positioned(
						bottom: 0,
						left: 0,
						right: 0,
						child: _BottomPanel(responsive: responsive, controller: controller),
					),
					// Indicateur de fin de trajet
					Obx(() {
						if (!controller.tripEnded.value) return const SizedBox.shrink();
						return Positioned.fill(child: _TripEndedOverlay(responsive: responsive));
					}),
				],
			),
		);
	}
}

// ── Top Bar ────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
	const _TopBar({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final LiveTrackingController controller;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.w(16),
				vertical: responsive.h(12),
			),
			child: Row(
				children: [
					_GlassButton(
						icon: Icons.chevron_left_rounded,
						onTap: Get.back,
					),
					const Spacer(),
					Container(
						padding: EdgeInsets.symmetric(
							horizontal: responsive.w(16),
							vertical: responsive.h(8),
						),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(9999),
							boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 10)],
						),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								Container(
									width: responsive.w(8),
									height: responsive.w(8),
									decoration: const BoxDecoration(
										shape: BoxShape.circle,
										color: AppColors.primary,
									),
								),
								SizedBox(width: responsive.w(8)),
								Text(
									'Trajet en cours',
									style: AppTextStyles.caption(responsive).copyWith(
										fontWeight: FontWeight.w700,
										color: AppColors.textPrimary,
									),
								),
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

// ── Bottom Panel ───────────────────────────────────────────────────────────

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
					// Drag handle
					Container(
						width: responsive.w(36),
						height: responsive.h(4),
						decoration: BoxDecoration(
							color: AppColors.border,
							borderRadius: BorderRadius.circular(9999),
						),
					),
					SizedBox(height: responsive.h(16)),
					// ETA Row
					_EtaRow(responsive: responsive, controller: controller),
					SizedBox(height: responsive.h(16)),
					Container(height: 1, color: AppColors.border),
					SizedBox(height: responsive.h(16)),
					// Driver row
					_DriverRow(responsive: responsive, controller: controller),
					SizedBox(height: responsive.h(16)),
					// Quick messages
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
				Expanded(
					child: _MetricTile(
						responsive: responsive,
						icon: Icons.schedule_rounded,
						iconColor: AppColors.primary,
						label: 'Arrivée estimée',
						value: '${controller.etaMinutes.value} min',
					),
				),
				Container(width: 1, height: responsive.h(40), color: AppColors.border),
				Expanded(
					child: _MetricTile(
						responsive: responsive,
						icon: Icons.route_rounded,
						iconColor: AppColors.blue,
						label: 'Distance restante',
						value: '${controller.distanceRemainingKm.value} km',
					),
				),
				Container(width: 1, height: responsive.h(40), color: AppColors.border),
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
			final vehicle = ride?.vehicle ?? 'Véhicule';
			final rating = ride?.rating ?? '4.8';

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
						Text(label, style: AppTextStyles.caption(responsive).copyWith(color: color, fontWeight: FontWeight.w600)),
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
							padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(6)),
							decoration: BoxDecoration(
								color: AppColors.surfaceMuted,
								borderRadius: BorderRadius.circular(9999),
								border: Border.all(color: AppColors.border),
							),
							child: Text(msg, style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w500)),
						),
					);
				},
			),
		);
	}
}

// ── Trip Ended Overlay ─────────────────────────────────────────────────────

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
								decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x1900A86B)),
								child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 40),
							),
							SizedBox(height: responsive.h(16)),
							Text('Vous êtes arrivé !', style: AppTextStyles.h6(responsive).copyWith(fontSize: responsive.text(18))),
							SizedBox(height: responsive.h(6)),
							Text('Redirection vers l\'évaluation…',
								style: AppTextStyles.caption(responsive), textAlign: TextAlign.center),
							SizedBox(height: responsive.h(16)),
							const SizedBox(
								width: 28, height: 28,
								child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
							),
						],
					),
				),
			),
		);
	}
}

// ── Animated Map (CustomPainter) ───────────────────────────────────────────

class _AnimatedMap extends StatefulWidget {
	const _AnimatedMap({required this.progress, required this.origin, required this.destination});

	final double progress;
	final String origin;
	final String destination;

	@override
	State<_AnimatedMap> createState() => _AnimatedMapState();
}

class _AnimatedMapState extends State<_AnimatedMap> with SingleTickerProviderStateMixin {
	late AnimationController _pulseCtrl;

	@override
	void initState() {
		super.initState();
		_pulseCtrl = AnimationController(
			duration: const Duration(milliseconds: 1000),
			vsync: this,
		)..repeat(reverse: true);
	}

	@override
	void dispose() {
		_pulseCtrl.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: _pulseCtrl,
			builder: (_, _) => Stack(
				fit: StackFit.expand,
				children: [
					CustomPaint(
						painter: _MapPainter(
							driverProgress: widget.progress,
							pulseValue: _pulseCtrl.value,
						),
					),
					_MapLabels(
						origin: widget.origin,
						destination: widget.destination,
					),
				],
			),
		);
	}
}

class _MapPainter extends CustomPainter {
	_MapPainter({required this.driverProgress, required this.pulseValue});

	final double driverProgress;
	final double pulseValue;

	// Route bezier control points (normalized 0..1)
	static const _p0 = Offset(0.12, 0.85);
	static const _p1 = Offset(0.28, 0.72);
	static const _p2 = Offset(0.42, 0.52);
	static const _p3 = Offset(0.52, 0.48);
	static const _p4 = Offset(0.62, 0.44);
	static const _p5 = Offset(0.78, 0.26);
	static const _p6 = Offset(0.88, 0.16);

	Offset _s(Offset n, Size size) => Offset(n.dx * size.width, n.dy * size.height);

	Offset _bezier(Size size, double t) {
		if (t <= 0.5) {
			final tt = t * 2;
			return _cubic(_s(_p0, size), _s(_p1, size), _s(_p2, size), _s(_p3, size), tt);
		}
		final tt = (t - 0.5) * 2;
		return _cubic(_s(_p3, size), _s(_p4, size), _s(_p5, size), _s(_p6, size), tt);
	}

	Offset _cubic(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
		final mt = 1 - t;
		return Offset(
			mt * mt * mt * p0.dx + 3 * mt * mt * t * p1.dx + 3 * mt * t * t * p2.dx + t * t * t * p3.dx,
			mt * mt * mt * p0.dy + 3 * mt * mt * t * p1.dy + 3 * mt * t * t * p2.dy + t * t * t * p3.dy,
		);
	}

	Path _buildPath(Size size) {
		final path = Path();
		final start = _s(_p0, size);
		path.moveTo(start.dx, start.dy);
		path.cubicTo(_s(_p1, size).dx, _s(_p1, size).dy, _s(_p2, size).dx, _s(_p2, size).dy, _s(_p3, size).dx, _s(_p3, size).dy);
		path.cubicTo(_s(_p4, size).dx, _s(_p4, size).dy, _s(_p5, size).dx, _s(_p5, size).dy, _s(_p6, size).dx, _s(_p6, size).dy);
		return path;
	}

	@override
	void paint(Canvas canvas, Size size) {
		_drawBackground(canvas, size);
		_drawGrid(canvas, size);
		_drawBlocks(canvas, size);
		_drawRouteShadow(canvas, size);
		_drawRoute(canvas, size);
		_drawOrigin(canvas, size);
		_drawDestination(canvas, size);
		_drawCar(canvas, size);
	}

	void _drawBackground(Canvas canvas, Size size) {
		canvas.drawRect(
			Rect.fromLTWH(0, 0, size.width, size.height),
			Paint()..color = const Color(0xFFE9EDE8),
		);
	}

	void _drawGrid(Canvas canvas, Size size) {
		final paint = Paint()
			..color = const Color(0xFFF6F4EC)
			..strokeWidth = size.width * 0.04;

		for (final y in [0.17, 0.35, 0.55, 0.75, 0.90]) {
			canvas.drawLine(Offset(0, size.height * y), Offset(size.width, size.height * y), paint);
		}
		for (final x in [0.22, 0.48, 0.72, 0.92]) {
			canvas.drawLine(Offset(size.width * x, 0), Offset(size.width * x, size.height), paint);
		}
	}

	void _drawBlocks(Canvas canvas, Size size) {
		final paint = Paint()..color = const Color(0xFFD6DBD2);
		final blocks = [
			[0.04, 0.03, 0.18, 0.13],
			[0.25, 0.03, 0.44, 0.13],
			[0.51, 0.03, 0.68, 0.13],
			[0.75, 0.03, 0.88, 0.13],
			[0.04, 0.20, 0.18, 0.31],
			[0.25, 0.20, 0.44, 0.31],
			[0.51, 0.20, 0.68, 0.31],
			[0.75, 0.20, 0.88, 0.31],
			[0.04, 0.38, 0.18, 0.51],
			[0.25, 0.38, 0.44, 0.51],
			[0.51, 0.38, 0.68, 0.51],
			[0.75, 0.38, 0.88, 0.51],
			[0.04, 0.58, 0.18, 0.71],
			[0.25, 0.58, 0.44, 0.71],
			[0.51, 0.58, 0.68, 0.71],
			[0.75, 0.58, 0.88, 0.71],
			[0.04, 0.78, 0.18, 0.87],
			[0.25, 0.78, 0.44, 0.87],
		];
		for (final b in blocks) {
			canvas.drawRRect(
				RRect.fromLTRBR(size.width * b[0], size.height * b[1], size.width * b[2], size.height * b[3], const Radius.circular(4)),
				paint,
			);
		}
	}

	void _drawRouteShadow(Canvas canvas, Size size) {
		canvas.drawPath(
			_buildPath(size),
			Paint()
				..color = const Color(0x5000A86B)
				..strokeWidth = 22
				..style = PaintingStyle.stroke
				..strokeCap = StrokeCap.round
				..strokeJoin = StrokeJoin.round
				..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
		);
	}

	void _drawRoute(Canvas canvas, Size size) {
		// Grey remaining
		canvas.drawPath(
			_buildPath(size),
			Paint()
				..color = const Color(0xFFB0B8B0)
				..strokeWidth = 8
				..style = PaintingStyle.stroke
				..strokeCap = StrokeCap.round,
		);
		// Green completed (approximated by drawing up to driver pos)
		if (driverProgress > 0) {
			final steps = 60;
			final completedPath = Path();
			final startPt = _bezier(size, 0);
			completedPath.moveTo(startPt.dx, startPt.dy);
			for (var i = 1; i <= steps; i++) {
				final t = (i / steps) * driverProgress;
				final pt = _bezier(size, t);
				completedPath.lineTo(pt.dx, pt.dy);
			}
			canvas.drawPath(
				completedPath,
				Paint()
					..color = const Color(0xFF00A86B)
					..strokeWidth = 8
					..style = PaintingStyle.stroke
					..strokeCap = StrokeCap.round
					..strokeJoin = StrokeJoin.round,
			);
		}
	}

	void _drawOrigin(Canvas canvas, Size size) {
		final pos = _s(_p0, size);
		canvas.drawCircle(pos, 12, Paint()..color = Colors.white);
		canvas.drawCircle(pos, 8, Paint()..color = const Color(0xFF00A86B));
		canvas.drawCircle(pos, 12, Paint()
			..color = const Color(0xFF00A86B)
			..strokeWidth = 2
			..style = PaintingStyle.stroke);
	}

	void _drawDestination(Canvas canvas, Size size) {
		final pos = _s(_p6, size);
		const pinColor = Color(0xFFEF4444);

		// Pin drop shape
		final path = Path();
		path.addOval(Rect.fromCenter(center: Offset(pos.dx, pos.dy - 18), width: 26, height: 26));
		path.moveTo(pos.dx - 6, pos.dy - 12);
		path.lineTo(pos.dx + 6, pos.dy - 12);
		path.lineTo(pos.dx, pos.dy + 2);
		path.close();
		canvas.drawPath(path, Paint()..color = pinColor);
		canvas.drawCircle(Offset(pos.dx, pos.dy - 18), 6, Paint()..color = Colors.white);

		// Pulse ring on destination
		canvas.drawCircle(
			Offset(pos.dx, pos.dy - 18),
			18 + pulseValue * 8,
			Paint()
				..color = const Color(0xFFEF4444).withValues(alpha: 0.20 - pulseValue * 0.15)
				..style = PaintingStyle.fill,
		);
	}

	void _drawCar(Canvas canvas, Size size) {
		final pos = _bezier(size, driverProgress);

		// Compute heading angle from previous point
		double angle = 0;
		if (driverProgress > 0.01) {
			final prev = _bezier(size, driverProgress - 0.01);
			angle = math.atan2(pos.dy - prev.dy, pos.dx - prev.dx);
		}

		// Outer pulse
		canvas.drawCircle(
			pos,
			28 + pulseValue * 10,
			Paint()..color = const Color(0xFF00A86B).withValues(alpha: 0.18 - pulseValue * 0.12),
		);

		// White ring
		canvas.drawCircle(pos, 22, Paint()..color = Colors.white);

		// Shadow under car
		canvas.drawCircle(
			pos,
			20,
			Paint()
				..color = const Color(0x3000A86B)
				..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
		);

		// Green body
		canvas.drawCircle(pos, 18, Paint()..color = const Color(0xFF00A86B));

		// Directional arrow (simplified triangle)
		canvas.save();
		canvas.translate(pos.dx, pos.dy);
		canvas.rotate(angle - math.pi / 2);
		final arrowPath = Path()
			..moveTo(0, -9)
			..lineTo(-5, 6)
			..lineTo(0, 3)
			..lineTo(5, 6)
			..close();
		canvas.drawPath(arrowPath, Paint()..color = Colors.white);
		canvas.restore();
	}

	@override
	bool shouldRepaint(_MapPainter old) =>
			old.driverProgress != driverProgress || old.pulseValue != pulseValue;
}

// ── Map Labels Overlay ─────────────────────────────────────────────────────

class _MapLabels extends StatelessWidget {
	const _MapLabels({required this.origin, required this.destination});

	final String origin;
	final String destination;

	@override
	Widget build(BuildContext context) {
		return Stack(
			children: [
				// Origin label (bottom-left)
				Positioned(
					left: MediaQuery.sizeOf(context).width * 0.06,
					bottom: MediaQuery.sizeOf(context).height * 0.16,
					child: _MapLabel(text: origin, color: AppColors.primary),
				),
				// Destination label (top-right)
				Positioned(
					right: MediaQuery.sizeOf(context).width * 0.06,
					top: MediaQuery.sizeOf(context).height * 0.11,
					child: _MapLabel(text: destination, color: const Color(0xFFEF4444)),
				),
			],
		);
	}
}

class _MapLabel extends StatelessWidget {
	const _MapLabel({required this.text, required this.color});

	final String text;
	final Color color;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(8),
				border: Border.all(color: color.withValues(alpha: 0.40)),
				boxShadow: const [BoxShadow(color: Color(0x30000000), blurRadius: 6)],
			),
			child: Text(
				text,
				style: TextStyle(
					color: color,
					fontSize: 11,
					fontWeight: FontWeight.w700,
					fontFamily: 'Inter',
				),
			),
		);
	}
}

// ── Shared: Driver Avatar ──────────────────────────────────────────────────

class _DriverAvatar extends StatelessWidget {
	const _DriverAvatar({required this.name, required this.size});

	final String name;
	final double size;

	@override
	Widget build(BuildContext context) {
		final parts = name.trim().split(RegExp(r'\s+'));
		final first = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : 'C';
		final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
		final initials = (first + second).toUpperCase();

		return Container(
			width: size,
			height: size,
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';

import '../controllers/reservation_controller.dart';

class ReservationView extends StatelessWidget {
	const ReservationView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<ReservationController>()
				? Get.find<ReservationController>()
				: Get.put(ReservationController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								_Header(responsive: responsive),
								_ActiveTripBanner(responsive: responsive, controller: controller),
								_StatusTabBar(responsive: responsive, controller: controller),
								Expanded(
									child: Obx(() {
										final items = controller.filteredReservations;
										if (items.isEmpty) {
											return _EmptyState(
												responsive: responsive,
												status: controller.statusTabs[controller.selectedStatusIndex.value].status,
											);
										}
										return ListView.separated(
											padding: EdgeInsets.symmetric(
												horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
												vertical: responsive.h(16),
											),
											itemCount: items.length,
											separatorBuilder: (_, _) => SizedBox(height: responsive.h(12)),
											itemBuilder: (_, i) => _ReservationCard(
												responsive: responsive,
												reservation: items[i],
												controller: controller,
											),
										);
									}),
								),
							],
						),
					),
				),
			),
		);
	}
}

// ── Header ─────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
	const _Header({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				vertical: responsive.h(16),
			),
			decoration: const BoxDecoration(
				color: AppColors.white,
				border: Border(bottom: BorderSide(color: AppColors.border)),
			),
			child: Row(
				children: [
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Mes réservations',
									style: AppTextStyles.title(responsive),
								),
								SizedBox(height: responsive.h(2)),
								Text(
									'Gérez tous vos trajets réservés',
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
								),
							],
						),
					),
					Container(
						width: responsive.w(40),
						height: responsive.w(40),
						decoration: BoxDecoration(
							color: AppColors.surfaceSoft,
							shape: BoxShape.circle,
							border: Border.all(color: AppColors.border),
						),
						child: Icon(Icons.tune_rounded, size: responsive.text(18), color: AppColors.textSecondary),
					),
				],
			),
		);
	}
}

// ── Active Trip Banner ─────────────────────────────────────────────────────

class _ActiveTripBanner extends StatelessWidget {
	const _ActiveTripBanner({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final ReservationController controller;

	@override
	Widget build(BuildContext context) {
		final active = controller.activeTrip;
		if (active == null) return const SizedBox.shrink();

		return GestureDetector(
			onTap: () => controller.trackLive(active),
			child: Container(
				width: double.infinity,
				margin: EdgeInsets.symmetric(
					horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
					vertical: responsive.h(10),
				),
				padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(12)),
				decoration: BoxDecoration(
					gradient: const LinearGradient(
						colors: [Color(0xFF00A86B), Color(0xFF059669)],
					),
					borderRadius: BorderRadius.circular(responsive.radius(14)),
					boxShadow: [
						BoxShadow(
							color: const Color(0xFF00A86B).withValues(alpha: 0.30),
							blurRadius: 12,
							offset: const Offset(0, 4),
						),
					],
				),
				child: Row(
					children: [
						Container(
							width: responsive.w(10),
							height: responsive.w(10),
							decoration: BoxDecoration(
								color: Colors.white,
								shape: BoxShape.circle,
								boxShadow: [BoxShadow(color: Colors.white.withValues(alpha: 0.50), blurRadius: 6)],
							),
						),
						SizedBox(width: responsive.w(10)),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										'Trajet en cours',
										style: AppTextStyles.caption(responsive).copyWith(
											color: Colors.white.withValues(alpha: 0.85),
											fontWeight: FontWeight.w600,
										),
									),
									Text(
										'${active.departureCity} → ${active.arrivalCity}',
										style: AppTextStyles.subtitle(responsive).copyWith(
											color: Colors.white,
											fontWeight: FontWeight.w700,
										),
									),
								],
							),
						),
						Row(
							children: [
								Text(
									'Suivre',
									style: AppTextStyles.caption(responsive).copyWith(
										color: Colors.white,
										fontWeight: FontWeight.w700,
									),
								),
								SizedBox(width: responsive.w(4)),
								const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white),
							],
						),
					],
				),
			),
		);
	}
}

// ── Status Tab Bar ─────────────────────────────────────────────────────────

class _StatusTabBar extends StatelessWidget {
	const _StatusTabBar({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final ReservationController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			color: AppColors.white,
			child: Obx(() => SingleChildScrollView(
				scrollDirection: Axis.horizontal,
				padding: EdgeInsets.symmetric(
					horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
					vertical: responsive.h(10),
				),
				child: Row(
					children: List.generate(controller.statusTabs.length, (i) {
						final tab = controller.statusTabs[i];
						final selected = controller.selectedStatusIndex.value == i;
						final color = _tabColor(tab.status);
						return Padding(
							padding: EdgeInsets.only(right: i < controller.statusTabs.length - 1 ? responsive.w(8) : 0),
							child: GestureDetector(
								onTap: () => controller.selectStatus(i),
								child: AnimatedContainer(
									duration: const Duration(milliseconds: 180),
									padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(8)),
									decoration: BoxDecoration(
										color: selected ? color.withValues(alpha: 0.12) : AppColors.surfaceMuted,
										borderRadius: BorderRadius.circular(9999),
										border: Border.all(
											color: selected ? color : AppColors.border,
											width: selected ? 1.5 : 1,
										),
									),
									child: Row(
										mainAxisSize: MainAxisSize.min,
										children: [
											Icon(_tabIcon(tab.status), size: responsive.text(12), color: selected ? color : AppColors.textHint),
											SizedBox(width: responsive.w(5)),
											Text(
												tab.label,
												style: AppTextStyles.caption(responsive).copyWith(
													color: selected ? color : AppColors.textSecondary,
													fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
												),
											),
										],
									),
								),
							),
						);
					}),
				),
			)),
		);
	}

	Color _tabColor(ReservationStatus s) {
		switch (s) {
			case ReservationStatus.pending: return const Color(0xFFF59E0B);
			case ReservationStatus.confirmed: return AppColors.blue;
			case ReservationStatus.inProgress: return AppColors.primary;
			case ReservationStatus.completed: return const Color(0xFF6B7280);
			case ReservationStatus.cancelled: return const Color(0xFFEF4444);
		}
	}

	IconData _tabIcon(ReservationStatus s) {
		switch (s) {
			case ReservationStatus.pending: return Icons.hourglass_top_rounded;
			case ReservationStatus.confirmed: return Icons.check_circle_outline_rounded;
			case ReservationStatus.inProgress: return Icons.directions_car_rounded;
			case ReservationStatus.completed: return Icons.task_alt_rounded;
			case ReservationStatus.cancelled: return Icons.cancel_outlined;
		}
	}
}

// ── Reservation Card (status-aware) ───────────────────────────────────────

class _ReservationCard extends StatelessWidget {
	const _ReservationCard({
		required this.responsive,
		required this.reservation,
		required this.controller,
	});

	final AppResponsive responsive;
	final ReservationItem reservation;
	final ReservationController controller;

	Color get _statusColor {
		switch (reservation.status) {
			case ReservationStatus.pending: return const Color(0xFFF59E0B);
			case ReservationStatus.confirmed:
				return reservation.isPaid ? AppColors.blue : const Color(0xFFF59E0B);
			case ReservationStatus.inProgress: return AppColors.primary;
			case ReservationStatus.completed: return const Color(0xFF6B7280);
			case ReservationStatus.cancelled: return const Color(0xFFEF4444);
		}
	}

	String get _statusLabel {
		switch (reservation.status) {
			case ReservationStatus.pending: return 'En attente de confirmation';
			case ReservationStatus.confirmed:
				return reservation.isPaid ? 'Confirmé — Trajet à venir' : 'Accepté par le conducteur — Paiement requis';
			case ReservationStatus.inProgress: return 'En cours de route';
			case ReservationStatus.completed: return 'Trajet terminé';
			case ReservationStatus.cancelled: return 'Réservation annulée';
		}
	}

	IconData get _statusIcon {
		switch (reservation.status) {
			case ReservationStatus.pending: return Icons.hourglass_top_rounded;
			case ReservationStatus.confirmed:
				return reservation.isPaid ? Icons.check_circle_rounded : Icons.payment_rounded;
			case ReservationStatus.inProgress: return Icons.directions_car_filled_rounded;
			case ReservationStatus.completed: return Icons.task_alt_rounded;
			case ReservationStatus.cancelled: return Icons.cancel_rounded;
		}
	}

	@override
	Widget build(BuildContext context) {
		final color = _statusColor;

		return Container(
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: BorderSide(
						color: reservation.status == ReservationStatus.inProgress
								? color.withValues(alpha: 0.40)
								: AppColors.border,
						width: reservation.status == ReservationStatus.inProgress ? 1.5 : 1,
					),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: [
					BoxShadow(
						color: reservation.status == ReservationStatus.inProgress
								? color.withValues(alpha: 0.12)
								: const Color(0x0C000000),
						blurRadius: reservation.status == ReservationStatus.inProgress ? 16 : 4,
						offset: const Offset(0, 2),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Status header band
					_StatusBand(
						responsive: responsive,
						color: color,
						icon: _statusIcon,
						label: _statusLabel,
						timeAgo: reservation.timeAgo,
						isInProgress: reservation.status == ReservationStatus.inProgress,
					),
					// Payment warning for confirmed but unpaid
					if (reservation.status == ReservationStatus.confirmed && !reservation.isPaid)
						_PaymentWarningBanner(responsive: responsive, onTap: () => controller.payNow(reservation)),
					// Cancel reason for cancelled
					if (reservation.status == ReservationStatus.cancelled && reservation.cancelReason != null)
						_CancelReasonBanner(responsive: responsive, reason: reservation.cancelReason!),
					// Main body
					Padding(
						padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								_DriverRow(responsive: responsive, reservation: reservation),
								SizedBox(height: responsive.h(14)),
								_RouteBlock(responsive: responsive, reservation: reservation),
								SizedBox(height: responsive.h(14)),
								_MetaRow(responsive: responsive, reservation: reservation),
								SizedBox(height: responsive.h(16)),
								_ActionButtons(
									responsive: responsive,
									reservation: reservation,
									controller: controller,
								),
							],
						),
					),
				],
			),
		);
	}
}

// ── Status Band ────────────────────────────────────────────────────────────

class _StatusBand extends StatelessWidget {
	const _StatusBand({
		required this.responsive,
		required this.color,
		required this.icon,
		required this.label,
		required this.timeAgo,
		required this.isInProgress,
	});

	final AppResponsive responsive;
	final Color color;
	final IconData icon;
	final String label;
	final String timeAgo;
	final bool isInProgress;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
			decoration: BoxDecoration(
				color: color.withValues(alpha: 0.07),
				borderRadius: BorderRadius.only(
					topLeft: Radius.circular(responsive.radius(16)),
					topRight: Radius.circular(responsive.radius(16)),
				),
				border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.15))),
			),
			child: Row(
				children: [
					if (isInProgress) ...[
						_PulsingDot(color: color),
						SizedBox(width: responsive.w(8)),
					] else ...[
						Icon(icon, size: responsive.text(14), color: color),
						SizedBox(width: responsive.w(6)),
					],
					Expanded(
						child: Text(
							label,
							style: AppTextStyles.caption(responsive).copyWith(
								color: color,
								fontWeight: FontWeight.w700,
							),
						),
					),
					Text(
						timeAgo,
						style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
					),
				],
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

class _PulsingDotState extends State<_PulsingDot> with SingleTickerProviderStateMixin {
	late final AnimationController _anim;
	late final Animation<double> _scale;

	@override
	void initState() {
		super.initState();
		_anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
			..repeat(reverse: true);
		_scale = Tween(begin: 0.7, end: 1.0).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
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
				width: 10,
				height: 10,
				decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
			),
		);
	}
}

// ── Payment Warning Banner ─────────────────────────────────────────────────

class _PaymentWarningBanner extends StatelessWidget {
	const _PaymentWarningBanner({required this.responsive, required this.onTap});
	final AppResponsive responsive;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: Container(
				width: double.infinity,
				padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
				color: const Color(0xFFFFF7ED),
				child: Row(
					children: [
						const Icon(Icons.payment_rounded, size: 16, color: Color(0xFFF59E0B)),
						SizedBox(width: responsive.w(8)),
						Expanded(
							child: Text(
								'Paiement en attente — Payez avant le départ',
								style: AppTextStyles.caption(responsive).copyWith(
									color: const Color(0xFF92400E),
									fontWeight: FontWeight.w600,
								),
							),
						),
						const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFF59E0B)),
					],
				),
			),
		);
	}
}

// ── Cancel Reason Banner ──────────────────────────────────────────────────

class _CancelReasonBanner extends StatelessWidget {
	const _CancelReasonBanner({required this.responsive, required this.reason});
	final AppResponsive responsive;
	final String reason;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
			color: const Color(0xFFFEF2F2),
			child: Row(
				children: [
					const Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFFEF4444)),
					SizedBox(width: responsive.w(8)),
					Expanded(
						child: Text(
							'Motif : $reason',
							style: AppTextStyles.caption(responsive).copyWith(color: const Color(0xFF991B1B)),
						),
					),
				],
			),
		);
	}
}

// ── Driver Row ─────────────────────────────────────────────────────────────

class _DriverRow extends StatelessWidget {
	const _DriverRow({required this.responsive, required this.reservation});
	final AppResponsive responsive;
	final ReservationItem reservation;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				_Avatar(initials: reservation.driverInitials, size: responsive.w(46)),
				SizedBox(width: responsive.w(12)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									Text(reservation.driverName, style: AppTextStyles.subtitle(responsive)),
									SizedBox(width: responsive.w(4)),
									Icon(Icons.verified_rounded, size: responsive.text(13), color: AppColors.primary),
								],
							),
							SizedBox(height: responsive.h(2)),
							Row(
								children: [
									Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.warning),
									SizedBox(width: responsive.w(3)),
									Text(
										'${reservation.rating} · ${reservation.reviewCount}',
										style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
									),
								],
							),
						],
					),
				),
				Column(
					crossAxisAlignment: CrossAxisAlignment.end,
					children: [
						Text(
							reservation.totalPrice,
							style: AppTextStyles.h6(responsive).copyWith(
								color: AppColors.primary,
								fontWeight: FontWeight.w800,
							),
						),
						Text(
							'${reservation.seatsCount} place${reservation.seatsCount > 1 ? 's' : ''}',
							style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
						),
					],
				),
			],
		);
	}
}

// ── Route Block ────────────────────────────────────────────────────────────

class _RouteBlock extends StatelessWidget {
	const _RouteBlock({required this.responsive, required this.reservation});
	final AppResponsive responsive;
	final ReservationItem reservation;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Column(
					children: [
						Container(
							width: responsive.w(11),
							height: responsive.w(11),
							decoration: const BoxDecoration(
								shape: BoxShape.circle,
								color: AppColors.primary,
							),
						),
						Container(width: 2, height: responsive.h(28), color: AppColors.border),
						Container(
							width: responsive.w(11),
							height: responsive.w(11),
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								border: Border.all(color: const Color(0xFFEF4444), width: 2),
								color: Colors.white,
							),
							child: Center(
								child: Container(
									width: responsive.w(4),
									height: responsive.w(4),
									decoration: const BoxDecoration(
										shape: BoxShape.circle,
										color: Color(0xFFEF4444),
									),
								),
							),
						),
					],
				),
				SizedBox(width: responsive.w(12)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							_PlaceLine(
								title: reservation.departureCity,
								subtitle: reservation.departureNote,
								responsive: responsive,
							),
							SizedBox(height: responsive.h(14)),
							_PlaceLine(
								title: reservation.arrivalCity,
								subtitle: reservation.arrivalNote,
								responsive: responsive,
							),
						],
					),
				),
				SizedBox(width: responsive.w(12)),
				Column(
					crossAxisAlignment: CrossAxisAlignment.end,
					children: [
						Text(
							reservation.departureTime,
							style: AppTextStyles.caption(responsive).copyWith(
								fontWeight: FontWeight.w700,
								color: AppColors.textPrimary,
							),
						),
						SizedBox(height: responsive.h(4)),
						Text(
							reservation.departureDate,
							style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
						),
					],
				),
			],
		);
	}
}

class _PlaceLine extends StatelessWidget {
	const _PlaceLine({required this.title, required this.subtitle, required this.responsive});
	final String title;
	final String subtitle;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(title, style: AppTextStyles.subtitle(responsive)),
				SizedBox(height: responsive.h(2)),
				Text(subtitle, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
			],
		);
	}
}

// ── Meta Row ───────────────────────────────────────────────────────────────

class _MetaRow extends StatelessWidget {
	const _MetaRow({required this.responsive, required this.reservation});
	final AppResponsive responsive;
	final ReservationItem reservation;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(8)),
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(responsive.radius(10)),
			),
			child: Wrap(
				spacing: responsive.w(10),
				runSpacing: responsive.h(6),
				children: [
					_MetaChip(
						responsive: responsive,
						icon: Icons.directions_car_outlined,
						label: reservation.vehicle,
					),
					_MetaChip(
						responsive: responsive,
						icon: Icons.pin_outlined,
						label: reservation.vehiclePlate,
					),
					if (reservation.status == ReservationStatus.inProgress && reservation.etaMinutes != null)
						_MetaChip(
							responsive: responsive,
							icon: Icons.schedule_rounded,
							label: '~${reservation.etaMinutes} min',
							color: AppColors.primary,
						),
				],
			),
		);
	}
}

class _MetaChip extends StatelessWidget {
	const _MetaChip({required this.responsive, required this.icon, required this.label, this.color});
	final AppResponsive responsive;
	final IconData icon;
	final String label;
	final Color? color;

	@override
	Widget build(BuildContext context) {
		final c = color ?? AppColors.textHint;
		return Row(
			mainAxisSize: MainAxisSize.min,
			children: [
				Icon(icon, size: responsive.text(12), color: c),
				SizedBox(width: responsive.w(4)),
				Text(
					label,
					style: AppTextStyles.caption(responsive).copyWith(
						color: c,
						fontWeight: color != null ? FontWeight.w600 : FontWeight.w400,
					),
				),
			],
		);
	}
}

// ── Action Buttons (context-aware) ────────────────────────────────────────

class _ActionButtons extends StatelessWidget {
	const _ActionButtons({
		required this.responsive,
		required this.reservation,
		required this.controller,
	});

	final AppResponsive responsive;
	final ReservationItem reservation;
	final ReservationController controller;

	@override
	Widget build(BuildContext context) {
		switch (reservation.status) {
			case ReservationStatus.pending:
				return _pendingActions();
			case ReservationStatus.confirmed:
				return _confirmedActions();
			case ReservationStatus.inProgress:
				return _inProgressActions();
			case ReservationStatus.completed:
				return _completedActions();
			case ReservationStatus.cancelled:
				return _cancelledActions();
		}
	}

	Widget _pendingActions() => Row(
		children: [
			Expanded(
				child: _Btn(
					responsive: responsive,
					label: 'Annuler',
					icon: Icons.close_rounded,
					color: AppColors.textSecondary,
					bg: AppColors.surfaceMuted,
					border: AppColors.border,
					onTap: () => controller.cancelReservation(reservation),
				),
			),
			SizedBox(width: responsive.w(10)),
			Expanded(
				child: _Btn(
					responsive: responsive,
					label: 'Voir détails',
					icon: Icons.info_outline_rounded,
					color: AppColors.white,
					bg: const Color(0xFF1D4ED8),
					onTap: () => controller.viewDetails(reservation),
				),
			),
		],
	);

	Widget _confirmedActions() {
		if (!reservation.isPaid) {
			return Column(
				children: [
					_Btn(
						responsive: responsive,
						label: 'Payer maintenant',
						icon: Icons.payment_rounded,
						color: AppColors.white,
						bg: const Color(0xFFF59E0B),
						fullWidth: true,
						onTap: () => controller.payNow(reservation),
					),
					SizedBox(height: responsive.h(8)),
					Row(
						children: [
							Expanded(
								child: _Btn(
									responsive: responsive,
									label: 'Annuler',
									icon: Icons.close_rounded,
									color: AppColors.textSecondary,
									bg: AppColors.surfaceMuted,
									border: AppColors.border,
									onTap: () => controller.cancelReservation(reservation),
								),
							),
							SizedBox(width: responsive.w(10)),
							Expanded(
								child: _Btn(
									responsive: responsive,
									label: 'Contacter',
									icon: Icons.chat_bubble_outline_rounded,
									color: AppColors.primary,
									bg: AppColors.surfaceAccent,
									border: const Color(0x3300A86B),
									onTap: () => controller.contactDriver(reservation),
								),
							),
						],
					),
				],
			);
		}
		return Row(
			children: [
				Expanded(
					child: _Btn(
						responsive: responsive,
						label: 'Contacter',
						icon: Icons.chat_bubble_outline_rounded,
						color: AppColors.textSecondary,
						bg: AppColors.surfaceMuted,
						border: AppColors.border,
						onTap: () => controller.contactDriver(reservation),
					),
				),
				SizedBox(width: responsive.w(10)),
				Expanded(
					child: _Btn(
						responsive: responsive,
						label: 'Voir trajet',
						icon: Icons.map_outlined,
						color: AppColors.white,
						bg: AppColors.primary,
						onTap: () => controller.viewDetails(reservation),
					),
				),
			],
		);
	}

	Widget _inProgressActions() => _Btn(
		responsive: responsive,
		label: 'Suivi en direct',
		icon: Icons.my_location_rounded,
		color: AppColors.white,
		bg: AppColors.primary,
		fullWidth: true,
		onTap: () => controller.trackLive(reservation),
	);

	Widget _completedActions() {
		if (!reservation.hasRated) {
			return Column(
				children: [
					_Btn(
						responsive: responsive,
						label: 'Évaluer le conducteur',
						icon: Icons.star_outline_rounded,
						color: AppColors.white,
						bg: const Color(0xFFF59E0B),
						fullWidth: true,
						onTap: () => controller.rateDriver(reservation),
					),
					SizedBox(height: responsive.h(8)),
					_Btn(
						responsive: responsive,
						label: 'Télécharger la facture',
						icon: Icons.download_rounded,
						color: AppColors.textSecondary,
						bg: AppColors.surfaceMuted,
						border: AppColors.border,
						fullWidth: true,
						onTap: () => controller.downloadInvoice(reservation),
					),
				],
			);
		}
		return Row(
			children: [
				Expanded(
					child: _Btn(
						responsive: responsive,
						label: 'Facture PDF',
						icon: Icons.download_rounded,
						color: AppColors.textSecondary,
						bg: AppColors.surfaceMuted,
						border: AppColors.border,
						onTap: () => controller.downloadInvoice(reservation),
					),
				),
				SizedBox(width: responsive.w(10)),
				Expanded(
					child: _Btn(
						responsive: responsive,
						label: 'Réserver à nouveau',
						icon: Icons.refresh_rounded,
						color: AppColors.white,
						bg: AppColors.primary,
						onTap: () => controller.rebookTrip(reservation),
					),
				),
			],
		);
	}

	Widget _cancelledActions() {
		final canRefund = reservation.isPaid && reservation.refundStatus == RefundStatus.none;
		if (canRefund) {
			return Column(
				children: [
					_Btn(
						responsive: responsive,
						label: 'Demander un remboursement',
						icon: Icons.account_balance_wallet_outlined,
						color: AppColors.white,
						bg: const Color(0xFFEF4444),
						fullWidth: true,
						onTap: () => controller.requestRefund(reservation),
					),
					SizedBox(height: responsive.h(8)),
					_Btn(
						responsive: responsive,
						label: 'Réserver à nouveau',
						icon: Icons.refresh_rounded,
						color: AppColors.textSecondary,
						bg: AppColors.surfaceMuted,
						border: AppColors.border,
						fullWidth: true,
						onTap: () => controller.rebookTrip(reservation),
					),
				],
			);
		}
		if (reservation.refundStatus == RefundStatus.pending) {
			return _RefundStatusChip(responsive: responsive, status: reservation.refundStatus);
		}
		return _Btn(
			responsive: responsive,
			label: 'Réserver à nouveau',
			icon: Icons.refresh_rounded,
			color: AppColors.white,
			bg: AppColors.primary,
			fullWidth: true,
			onTap: () => controller.rebookTrip(reservation),
		);
	}
}

class _RefundStatusChip extends StatelessWidget {
	const _RefundStatusChip({required this.responsive, required this.status});
	final AppResponsive responsive;
	final RefundStatus status;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
			decoration: BoxDecoration(
				color: const Color(0xFFFFF7ED),
				borderRadius: BorderRadius.circular(responsive.radius(10)),
				border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.40)),
			),
			child: Row(
				children: [
					const Icon(Icons.hourglass_top_rounded, size: 15, color: Color(0xFFF59E0B)),
					SizedBox(width: responsive.w(8)),
					Expanded(
						child: Text(
							'Remboursement en cours de traitement',
							style: AppTextStyles.caption(responsive).copyWith(
								color: const Color(0xFF92400E),
								fontWeight: FontWeight.w600,
							),
						),
					),
				],
			),
		);
	}
}

// ── Generic Action Button ─────────────────────────────────────────────────

class _Btn extends StatelessWidget {
	const _Btn({
		required this.responsive,
		required this.label,
		required this.icon,
		required this.color,
		required this.bg,
		required this.onTap,
		this.border,
		this.fullWidth = false,
	});

	final AppResponsive responsive;
	final String label;
	final IconData icon;
	final Color color;
	final Color bg;
	final Color? border;
	final VoidCallback onTap;
	final bool fullWidth;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(responsive.radius(12)),
			child: Container(
				width: fullWidth ? double.infinity : null,
				padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(11)),
				decoration: BoxDecoration(
					color: bg,
					borderRadius: BorderRadius.circular(responsive.radius(12)),
					border: border != null ? Border.all(color: border!) : null,
				),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
					children: [
						Icon(icon, size: responsive.text(14), color: color),
						SizedBox(width: responsive.w(6)),
						Text(
							label,
							style: AppTextStyles.caption(responsive).copyWith(
								color: color,
								fontWeight: FontWeight.w600,
							),
						),
					],
				),
			),
		);
	}
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
	const _EmptyState({required this.responsive, required this.status});
	final AppResponsive responsive;
	final ReservationStatus status;

	String get _message {
		switch (status) {
			case ReservationStatus.pending: return 'Aucune réservation en attente.\nVos nouvelles réservations apparaîtront ici.';
			case ReservationStatus.confirmed: return 'Aucun trajet confirmé.\nRéservez un trajet pour commencer.';
			case ReservationStatus.inProgress: return 'Aucun trajet en cours actuellement.';
			case ReservationStatus.completed: return 'Vous n\'avez pas encore effectué\nde trajet avec MINIZON.';
			case ReservationStatus.cancelled: return 'Aucune réservation annulée.';
		}
	}

	IconData get _icon {
		switch (status) {
			case ReservationStatus.pending: return Icons.hourglass_empty_rounded;
			case ReservationStatus.confirmed: return Icons.event_available_rounded;
			case ReservationStatus.inProgress: return Icons.directions_car_outlined;
			case ReservationStatus.completed: return Icons.route_rounded;
			case ReservationStatus.cancelled: return Icons.cancel_outlined;
		}
	}

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: EdgeInsets.symmetric(horizontal: responsive.w(32)),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Container(
							width: responsive.w(72),
							height: responsive.w(72),
							decoration: const BoxDecoration(
								shape: BoxShape.circle,
								color: AppColors.surfaceMuted,
							),
							child: Icon(_icon, size: responsive.text(32), color: AppColors.textHint),
						),
						SizedBox(height: responsive.h(16)),
						Text(
							_message,
							style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
							textAlign: TextAlign.center,
						),
					],
				),
			),
		);
	}
}

// ── Avatar ─────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
	const _Avatar({required this.initials, required this.size});
	final String initials;
	final double size;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: size,
			height: size,
			decoration: BoxDecoration(
				gradient: const LinearGradient(
					colors: [Color(0xFF00A86B), Color(0xFF10B981)],
				),
				shape: BoxShape.circle,
				border: Border.all(color: AppColors.border),
			),
			child: Center(
				child: Text(
					initials,
					style: TextStyle(
						color: Colors.white,
						fontSize: size * 0.32,
						fontFamily: 'Inter',
						fontWeight: FontWeight.w700,
					),
				),
			),
		);
	}
}

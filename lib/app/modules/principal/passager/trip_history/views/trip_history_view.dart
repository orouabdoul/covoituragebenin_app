import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/trip_history_controller.dart';

class TripHistoryView extends StatelessWidget {
	const TripHistoryView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<TripHistoryController>()
				? Get.find<TripHistoryController>()
				: Get.put(TripHistoryController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Column(
							children: [
								_HeaderBar(responsive: responsive, controller: controller),
								_FilterChips(responsive: responsive, controller: controller),
								Expanded(
									child: Obx(() {
										final items = controller.filteredTrips;
										if (items.isEmpty) {
											return _EmptyState(
												responsive: responsive,
												filter: controller.selectedFilter.value,
											);
										}
										return ListView.separated(
											padding: EdgeInsets.symmetric(
												horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
												vertical: responsive.h(16),
											),
											itemCount: items.length,
											separatorBuilder: (_, _) => SizedBox(height: responsive.h(12)),
											itemBuilder: (_, i) => _TripCard(
												responsive: responsive,
												controller: controller,
												trip: items[i],
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

class _HeaderBar extends StatelessWidget {
	const _HeaderBar({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final TripHistoryController controller;

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
			child: Column(
				children: [
					Row(
						children: [
							_RoundBtn(icon: Icons.chevron_left_rounded, onTap: Get.back),
							const Spacer(),
							Text('Mes trajets', style: AppTextStyles.title(responsive)),
							const Spacer(),
							SizedBox(width: responsive.w(40)),
						],
					),
					SizedBox(height: responsive.h(12)),
					// Stats row
					Obx(() => Row(
						children: [
							_StatChip(
								responsive: responsive,
								label: 'À venir',
								count: controller.countByStatus('upcoming'),
								color: AppColors.blue,
							),
							SizedBox(width: responsive.w(8)),
							_StatChip(
								responsive: responsive,
								label: 'Terminés',
								count: controller.countByStatus('completed'),
								color: AppColors.primary,
							),
							SizedBox(width: responsive.w(8)),
							_StatChip(
								responsive: responsive,
								label: 'Annulés',
								count: controller.countByStatus('cancelled'),
								color: const Color(0xFFEF4444),
							),
						],
					)),
				],
			),
		);
	}
}

class _StatChip extends StatelessWidget {
	const _StatChip({required this.responsive, required this.label, required this.count, required this.color});
	final AppResponsive responsive;
	final String label;
	final int count;
	final Color color;

	@override
	Widget build(BuildContext context) {
		return Expanded(
			child: Container(
				padding: EdgeInsets.symmetric(vertical: responsive.h(8)),
				decoration: BoxDecoration(
					color: color.withValues(alpha: 0.08),
					borderRadius: BorderRadius.circular(10),
					border: Border.all(color: color.withValues(alpha: 0.20)),
				),
				child: Column(
					children: [
						Text(
							'$count',
							style: TextStyle(
								color: color,
								fontSize: responsive.text(18),
								fontFamily: 'Inter',
								fontWeight: FontWeight.w800,
							),
						),
						SizedBox(height: responsive.h(2)),
						Text(
							label,
							style: AppTextStyles.caption(responsive).copyWith(color: color.withValues(alpha: 0.80)),
						),
					],
				),
			),
		);
	}
}

// ── Filter Chips ───────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
	const _FilterChips({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final TripHistoryController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			color: AppColors.white,
			padding: EdgeInsets.only(
				left: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				right: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				bottom: responsive.h(12),
			),
			child: SizedBox(
				height: responsive.h(36),
				child: Obx(() {
					final currentFilter = controller.selectedFilter.value;
					return ListView.separated(
						scrollDirection: Axis.horizontal,
						itemCount: controller.filterLabels.length,
						separatorBuilder: (_, _) => SizedBox(width: responsive.w(8)),
						itemBuilder: (_, i) {
							final item = controller.filterLabels[i];
							final key = item['key']!;
							final label = item['label']!;
							final selected = currentFilter == key;
							return InkWell(
								onTap: () => controller.selectFilter(key),
								borderRadius: BorderRadius.circular(9999),
								child: AnimatedContainer(
									duration: AppResponsive.fastDuration,
									padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(6)),
									decoration: BoxDecoration(
										color: selected ? AppColors.primary : AppColors.surfaceMuted,
										borderRadius: BorderRadius.circular(9999),
										border: Border.all(color: selected ? AppColors.primary : AppColors.border),
									),
									child: Text(
										label,
										style: AppTextStyles.caption(responsive).copyWith(
											color: selected ? Colors.white : AppColors.textSecondary,
											fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
										),
									),
								),
							);
						},
					);
				}),
			),
		);
	}
}

// ── Trip Card ──────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
	const _TripCard({required this.responsive, required this.controller, required this.trip});
	final AppResponsive responsive;
	final TripHistoryController controller;
	final TripRecord trip;

	Color get _statusColor {
		switch (trip.status) {
			case 'upcoming': return AppColors.blue;
			case 'completed': return AppColors.primary;
			case 'cancelled': return const Color(0xFFEF4444);
			default: return AppColors.textHint;
		}
	}

	String get _statusLabel {
		switch (trip.status) {
			case 'upcoming': return 'À venir';
			case 'completed': return 'Terminé';
			case 'cancelled': return 'Annulé';
			default: return trip.status;
		}
	}

	IconData get _statusIcon {
		switch (trip.status) {
			case 'upcoming': return Icons.schedule_rounded;
			case 'completed': return Icons.check_circle_rounded;
			case 'cancelled': return Icons.cancel_rounded;
			default: return Icons.circle;
		}
	}

	@override
	Widget build(BuildContext context) {
		final color = _statusColor;
		return Container(
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: BorderSide(color: trip.status == 'upcoming' ? color.withValues(alpha: 0.30) : AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
			),
			child: Column(
				children: [
					// Top bar: status + date + time
					Container(
						padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(10)),
						decoration: BoxDecoration(
							color: color.withValues(alpha: 0.06),
							borderRadius: BorderRadius.only(
								topLeft: Radius.circular(responsive.radius(16)),
								topRight: Radius.circular(responsive.radius(16)),
							),
							border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.15))),
						),
						child: Row(
							children: [
								Icon(_statusIcon, size: responsive.text(14), color: color),
								SizedBox(width: responsive.w(6)),
								Text(
									_statusLabel,
									style: AppTextStyles.caption(responsive).copyWith(color: color, fontWeight: FontWeight.w700),
								),
								const Spacer(),
								Icon(Icons.calendar_today_rounded, size: responsive.text(12), color: AppColors.textHint),
								SizedBox(width: responsive.w(4)),
								Text(
									trip.date,
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
								),
								SizedBox(width: responsive.w(8)),
								Icon(Icons.access_time_rounded, size: responsive.text(12), color: AppColors.textHint),
								SizedBox(width: responsive.w(4)),
								Text(
									trip.time,
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
								),
							],
						),
					),
					// Route section
					Padding(
						padding: EdgeInsets.all(responsive.w(14)),
						child: Column(
							children: [
								// Route visual
								Row(
									children: [
										Column(
											children: [
												Container(
													width: responsive.w(12),
													height: responsive.w(12),
													decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
												),
												Container(width: 2, height: responsive.h(28), color: AppColors.border),
												Container(
													width: responsive.w(12),
													height: responsive.w(12),
													decoration: BoxDecoration(
														shape: BoxShape.circle,
														color: Colors.white,
														border: Border.all(color: const Color(0xFFEF4444), width: 2),
													),
													child: Center(
														child: Container(
															width: responsive.w(5),
															height: responsive.w(5),
															decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEF4444)),
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
													Text(trip.origin, style: AppTextStyles.subtitle(responsive)),
													SizedBox(height: responsive.h(16)),
													Text(trip.destination, style: AppTextStyles.subtitle(responsive)),
												],
											),
										),
										Column(
											crossAxisAlignment: CrossAxisAlignment.end,
											children: [
												Text(
													controller.formattedPrice(trip.price),
													style: AppTextStyles.h6(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
												),
												SizedBox(height: responsive.h(14)),
												Row(
													children: [
														Icon(Icons.event_seat_rounded, size: responsive.text(12), color: AppColors.textHint),
														SizedBox(width: responsive.w(3)),
														Text(
															'${trip.seats} place${trip.seats > 1 ? 's' : ''}',
															style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
														),
													],
												),
											],
										),
									],
								),
								SizedBox(height: responsive.h(12)),
								Divider(color: AppColors.border, height: 1),
								SizedBox(height: responsive.h(12)),
								// Driver row
								Row(
									children: [
										_Avatar(name: trip.driverName, size: responsive.w(32)),
										SizedBox(width: responsive.w(8)),
										Expanded(
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text(trip.driverName, style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600)),
													Text(
														'${trip.vehicle} · ${trip.vehiclePlate}',
														style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
													),
												],
											),
										),
										if (trip.status == 'completed' && trip.rating != null)
											Row(
												children: [
													Icon(Icons.star_rounded, color: AppColors.warning, size: responsive.text(14)),
													SizedBox(width: responsive.w(3)),
													Text(
														'${trip.rating!.toStringAsFixed(0)}/5',
														style: AppTextStyles.caption(responsive).copyWith(
															color: AppColors.warning,
															fontWeight: FontWeight.w700,
														),
													),
												],
											),
									],
								),
								// Action buttons
								if (trip.status == 'completed' || trip.status == 'cancelled') ...[
									SizedBox(height: responsive.h(12)),
									Row(
										children: [
											Expanded(
												child: _ActionButton(
													responsive: responsive,
													label: 'Réserver à nouveau',
													icon: Icons.refresh_rounded,
													color: AppColors.primary,
													onTap: () => controller.rebookTrip(trip),
												),
											),
											if (trip.status == 'cancelled') ...[
												SizedBox(width: responsive.w(8)),
												Expanded(
													child: _ActionButton(
														responsive: responsive,
														label: 'Remboursement',
														icon: Icons.account_balance_wallet_outlined,
														color: const Color(0xFFEF4444),
														onTap: () => controller.requestRefund(trip),
													),
												),
											],
										],
									),
								],
							],
						),
					),
				],
			),
		);
	}
}

class _ActionButton extends StatelessWidget {
	const _ActionButton({required this.responsive, required this.label, required this.icon, required this.color, required this.onTap});
	final AppResponsive responsive;
	final String label;
	final IconData icon;
	final Color color;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(10),
			child: Container(
				padding: EdgeInsets.symmetric(vertical: responsive.h(8)),
				decoration: BoxDecoration(
					color: color.withValues(alpha: 0.08),
					borderRadius: BorderRadius.circular(10),
					border: Border.all(color: color.withValues(alpha: 0.25)),
				),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(icon, size: responsive.text(14), color: color),
						SizedBox(width: responsive.w(5)),
						Text(
							label,
							style: AppTextStyles.caption(responsive).copyWith(color: color, fontWeight: FontWeight.w600),
						),
					],
				),
			),
		);
	}
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
	const _EmptyState({required this.responsive, required this.filter});
	final AppResponsive responsive;
	final String filter;

	String get _message {
		switch (filter) {
			case 'upcoming': return 'Aucun trajet à venir.\nRéservez votre prochain voyage !';
			case 'completed': return 'Aucun trajet terminé pour l\'instant.';
			case 'cancelled': return 'Aucun trajet annulé.';
			default: return 'Vous n\'avez encore effectué\naucun trajet.';
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
							width: responsive.w(80),
							height: responsive.w(80),
							decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceMuted),
							child: Icon(Icons.route_rounded, size: responsive.text(36), color: AppColors.textHint),
						),
						SizedBox(height: responsive.h(20)),
						Text('Aucun trajet', style: AppTextStyles.subtitle(responsive)),
						SizedBox(height: responsive.h(8)),
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

// ── Shared ─────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
	const _Avatar({required this.name, required this.size});
	final String name;
	final double size;

	@override
	Widget build(BuildContext context) {
		final parts = name.trim().split(RegExp(r'\s+'));
		final a = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : 'C';
		final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
		return Container(
			width: size,
			height: size,
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				shape: BoxShape.circle,
				border: Border.all(color: AppColors.border),
			),
			child: Center(
				child: Text(
					(a + b).toUpperCase(),
					style: TextStyle(color: AppColors.primary, fontSize: size * 0.34, fontFamily: 'Inter', fontWeight: FontWeight.w700),
				),
			),
		);
	}
}

class _RoundBtn extends StatelessWidget {
	const _RoundBtn({required this.icon, required this.onTap});
	final IconData icon;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(9999),
				child: Container(
					width: responsive.w(40),
					height: responsive.w(40),
					decoration: BoxDecoration(
						shape: BoxShape.circle,
						color: AppColors.surfaceMuted,
						border: Border.all(color: AppColors.border),
					),
					child: Icon(icon, size: responsive.text(20), color: AppColors.textPrimary),
				),
			),
		);
	}
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/driver_arrival_controller.dart';

class DriverArrivalView extends StatelessWidget {
	const DriverArrivalView({super.key});

	@override
	Widget build(BuildContext context) {
		final DriverArrivalController controller =
				Get.isRegistered<DriverArrivalController>()
						? Get.find<DriverArrivalController>()
						: Get.put(DriverArrivalController());
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
								Expanded(
									child: ListView(
										padding: EdgeInsets.symmetric(
											horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
										),
										children: [
											SizedBox(height: responsive.h(24)),
											_EtaDisplay(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(24)),
											_MeetingPointCard(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(16)),
											_DriverCard(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(16)),
											_QuickMessagesCard(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(24)),
											Obx(() => controller.status.value == DriverArrivalStatus.arrived
													? AppPrimaryButton(
															responsive: responsive,
															label: 'Trajet commencé → Suivre en direct',
															onTap: controller.goToLiveTracking,
															height: responsive.h(56),
															borderRadius: responsive.radius(16),
														)
													: const SizedBox.shrink()),
											SizedBox(height: responsive.h(16)),
										],
									),
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
	final DriverArrivalController controller;

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
					_RoundBtn(icon: Icons.chevron_left_rounded, onTap: Get.back),
					const Spacer(),
					Column(
						children: [
							Text('Conducteur en route', style: AppTextStyles.title(responsive)),
							Obx(() => Text(
								controller.statusLabel,
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary),
							)),
						],
					),
					const Spacer(),
					_RoundBtn(
						icon: Icons.phone_rounded,
						onTap: controller.callDriver,
						color: AppColors.primary,
					),
				],
			),
		);
	}
}

class _RoundBtn extends StatelessWidget {
	const _RoundBtn({required this.icon, required this.onTap, this.color});

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
					width: responsive.w(40),
					height: responsive.w(40),
					decoration: BoxDecoration(
						shape: BoxShape.circle,
						color: color != null ? color!.withValues(alpha: 0.10) : AppColors.surfaceMuted,
						border: Border.all(color: color?.withValues(alpha: 0.30) ?? AppColors.border),
					),
					child: Icon(icon, size: responsive.text(18), color: color ?? AppColors.textPrimary),
				),
			),
		);
	}
}

// ── ETA Display ────────────────────────────────────────────────────────────

class _EtaDisplay extends StatelessWidget {
	const _EtaDisplay({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final DriverArrivalController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final isArrived = controller.status.value == DriverArrivalStatus.arrived;
			final isArriving = controller.status.value == DriverArrivalStatus.arriving;

			final color = isArrived ? AppColors.primary : (isArriving ? AppColors.warning : AppColors.blue);
			final label = isArrived
					? 'Votre conducteur est arrivé !'
					: 'Arrivée dans environ';

			return Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.w(24)),
				decoration: ShapeDecoration(
					color: color.withValues(alpha: 0.08),
					shape: RoundedRectangleBorder(
						side: BorderSide(color: color.withValues(alpha: 0.25)),
						borderRadius: BorderRadius.circular(responsive.radius(20)),
					),
				),
				child: Column(
					children: [
						if (!isArrived) ...[
							Text(label, style: AppTextStyles.body(responsive).copyWith(color: color)),
							SizedBox(height: responsive.h(8)),
							Text(
								'${controller.etaMinutes.value} min',
								style: TextStyle(
									color: color,
									fontSize: responsive.text(52),
									fontFamily: 'Inter',
									fontWeight: FontWeight.w800,
									letterSpacing: -2,
								),
							),
						] else ...[
							Icon(Icons.check_circle_rounded, color: color, size: responsive.text(48)),
							SizedBox(height: responsive.h(8)),
							Text(
								label,
								style: AppTextStyles.h6(responsive).copyWith(color: color, fontSize: responsive.text(18)),
								textAlign: TextAlign.center,
							),
						],
						SizedBox(height: responsive.h(12)),
						ClipRRect(
							borderRadius: BorderRadius.circular(9999),
							child: LinearProgressIndicator(
								value: controller.driverProgress.value,
								minHeight: responsive.h(6),
								backgroundColor: AppColors.border,
								valueColor: AlwaysStoppedAnimation<Color>(color),
							),
						),
					],
				),
			);
		});
	}
}

// ── Meeting Point Card ─────────────────────────────────────────────────────

class _MeetingPointCard extends StatelessWidget {
	const _MeetingPointCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final DriverArrivalController controller;

	@override
	Widget build(BuildContext context) {
		final ride = controller.ride.value;
		final origin = ride?.origin ?? 'Cotonou';
		final departureNote = ride?.departureNote ?? 'Point de départ';

		return _Card(
			responsive: responsive,
			child: Row(
				children: [
					Container(
						width: responsive.w(44),
						height: responsive.w(44),
						decoration: BoxDecoration(
							color: const Color(0x1900A86B),
							borderRadius: BorderRadius.circular(12),
						),
						child: Icon(Icons.place_rounded, color: AppColors.primary, size: responsive.text(22)),
					),
					SizedBox(width: responsive.w(14)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('Point de prise en charge', style: AppTextStyles.caption(responsive)),
								SizedBox(height: responsive.h(2)),
								Text(origin, style: AppTextStyles.subtitle(responsive)),
								SizedBox(height: responsive.h(2)),
								Text(departureNote, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint)),
							],
						),
					),
					Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: responsive.text(20)),
				],
			),
		);
	}
}

// ── Driver Card ────────────────────────────────────────────────────────────

class _DriverCard extends StatelessWidget {
	const _DriverCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final DriverArrivalController controller;

	@override
	Widget build(BuildContext context) {
		final ride = controller.ride.value;
		final driverName = ride?.driverName ?? 'Votre conducteur';
		final vehicle = ride?.vehicle ?? 'Véhicule';
		final rating = ride?.rating ?? '4.8';

		return _Card(
			responsive: responsive,
			child: Row(
				children: [
					_Avatar(name: driverName, size: responsive.w(56)),
					SizedBox(width: responsive.w(14)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(driverName, style: AppTextStyles.subtitle(responsive)),
								SizedBox(height: responsive.h(4)),
								Row(
									children: [
										Icon(Icons.star_rounded, size: responsive.text(14), color: AppColors.warning),
										SizedBox(width: responsive.w(4)),
										Text(rating, style: AppTextStyles.caption(responsive)),
										SizedBox(width: responsive.w(6)),
										const Text('·'),
										SizedBox(width: responsive.w(6)),
										Text(vehicle, style: AppTextStyles.caption(responsive)),
									],
								),
								SizedBox(height: responsive.h(4)),
								Container(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(2)),
									decoration: BoxDecoration(
										color: const Color(0x1900A86B),
										borderRadius: BorderRadius.circular(9999),
									),
									child: Text(
										'✓ Conducteur vérifié',
										style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
									),
								),
							],
						),
					),
					_RoundBtn(
						icon: Icons.phone_rounded,
						onTap: controller.callDriver,
						color: AppColors.primary,
					),
				],
			),
		);
	}
}

// ── Quick Messages Card ────────────────────────────────────────────────────

class _QuickMessagesCard extends StatelessWidget {
	const _QuickMessagesCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final DriverArrivalController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Messages rapides', style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(12)),
					Wrap(
						spacing: responsive.w(8),
						runSpacing: responsive.h(8),
						children: controller.quickMessages.map((msg) {
							return InkWell(
								onTap: () => controller.sendMessage(msg),
								borderRadius: BorderRadius.circular(9999),
								child: Container(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(8)),
									decoration: ShapeDecoration(
										color: AppColors.surfaceMuted,
										shape: RoundedRectangleBorder(
											side: const BorderSide(color: AppColors.border),
											borderRadius: BorderRadius.circular(9999),
										),
									),
									child: Text(msg, style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w500)),
								),
							);
						}).toList(),
					),
				],
			),
		);
	}
}

// ── Shared widgets ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
	const _Card({required this.responsive, required this.child});

	final AppResponsive responsive;
	final Widget child;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 2))],
			),
			child: child,
		);
	}
}

class _Avatar extends StatelessWidget {
	const _Avatar({required this.name, required this.size});

	final String name;
	final double size;

	@override
	Widget build(BuildContext context) {
		final parts = name.trim().split(RegExp(r'\s+'));
		final first = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : 'C';
		final second = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';

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
					(first + second).toUpperCase(),
					style: TextStyle(color: AppColors.primary, fontSize: size * 0.34, fontFamily: 'Inter', fontWeight: FontWeight.w700),
				),
			),
		);
	}
}

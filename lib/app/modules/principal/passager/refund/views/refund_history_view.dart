import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/refund_history_controller.dart';

class RefundHistoryView extends StatelessWidget {
	const RefundHistoryView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<RefundHistoryController>()
				? Get.find<RefundHistoryController>()
				: Get.put(RefundHistoryController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Column(
							children: [
								_HeaderBar(responsive: responsive),
								Obx(() {
									if (controller.isLoading.value) {
										return const Expanded(
											child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3)),
										);
									}
									if (controller.hasError.value) {
										return Expanded(
											child: Center(
												child: Padding(
													padding: EdgeInsets.all(responsive.w(24)),
													child: Column(
														mainAxisSize: MainAxisSize.min,
														children: [
															Icon(Icons.cloud_off_rounded, size: responsive.text(40), color: AppColors.textHint),
															SizedBox(height: responsive.h(12)),
															Text(
																'Impossible de charger l\'historique.',
																textAlign: TextAlign.center,
																style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary),
															),
															SizedBox(height: responsive.h(16)),
															AppPrimaryButton(
																responsive: responsive,
																label: 'Réessayer',
																onTap: controller.refresh,
																height: responsive.h(44),
																borderRadius: responsive.radius(12),
															),
														],
													),
												),
											),
										);
									}
									if (controller.items.isEmpty) {
										return Expanded(child: _EmptyState(responsive: responsive));
									}
									return Expanded(
										child: ListView.separated(
											padding: EdgeInsets.symmetric(
												horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
												vertical: responsive.h(20),
											),
											itemCount: controller.items.length,
											separatorBuilder: (_, i) => SizedBox(height: responsive.h(12)),
											itemBuilder: (_, i) => _RefundCard(
												responsive: responsive,
												item: controller.items[i],
											),
										),
									);
								}),
							],
						),
					),
				),
			),
		);
	}
}

// ── Header ──────────────────────────────────────────────────────────────────

class _HeaderBar extends StatelessWidget {
	const _HeaderBar({required this.responsive});
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
					_RoundBtn(icon: Icons.chevron_left_rounded, onTap: Get.back),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('Mes demandes de remboursement', style: AppTextStyles.title(responsive)),
								Text(
									'Suivi de vos demandes',
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
								),
							],
						),
					),
				],
			),
		);
	}
}

// ── Refund Card ─────────────────────────────────────────────────────────────

class _RefundCard extends StatelessWidget {
	const _RefundCard({required this.responsive, required this.item});
	final AppResponsive responsive;
	final RefundHistoryItem item;

	_StatusConfig get _config => switch (item.historyStatus) {
		RefundHistoryStatus.pending => _StatusConfig(
			label: 'En attente',
			icon: Icons.hourglass_top_rounded,
			color: const Color(0xFFF59E0B),
			bg: const Color(0xFFFFFBEB),
		),
		RefundHistoryStatus.underReview => _StatusConfig(
			label: 'En cours d\'examen',
			icon: Icons.manage_search_rounded,
			color: const Color(0xFF6366F1),
			bg: const Color(0xFFF0F0FF),
		),
		RefundHistoryStatus.approved => _StatusConfig(
			label: 'Approuvé',
			icon: Icons.check_circle_outline_rounded,
			color: AppColors.primary,
			bg: const Color(0xFFF0FDF8),
		),
		RefundHistoryStatus.refunded => _StatusConfig(
			label: 'Remboursé',
			icon: Icons.account_balance_wallet_rounded,
			color: AppColors.primary,
			bg: const Color(0xFFF0FDF8),
		),
		RefundHistoryStatus.rejected => _StatusConfig(
			label: 'Refusé',
			icon: Icons.cancel_outlined,
			color: const Color(0xFFEF4444),
			bg: const Color(0xFFFFF5F5),
		),
	};

	@override
	Widget build(BuildContext context) {
		final cfg = _config;
		return Container(
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: BorderSide(color: cfg.color.withValues(alpha: 0.20)),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 6, offset: Offset(0, 2))],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Status banner
					Container(
						width: double.infinity,
						padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(10)),
						decoration: BoxDecoration(
							color: cfg.bg,
							borderRadius: BorderRadius.only(
								topLeft: Radius.circular(responsive.radius(16)),
								topRight: Radius.circular(responsive.radius(16)),
							),
						),
						child: Row(
							children: [
								Icon(cfg.icon, size: responsive.text(14), color: cfg.color),
								SizedBox(width: responsive.w(6)),
								Text(
									cfg.label,
									style: AppTextStyles.caption(responsive).copyWith(
										color: cfg.color,
										fontWeight: FontWeight.w700,
									),
								),
								const Spacer(),
								Text(
									item.id,
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.textHint,
										fontFamily: 'monospace',
									),
								),
							],
						),
					),
					// Body
					Padding(
						padding: EdgeInsets.all(responsive.w(16)),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Expanded(
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.start,
												children: [
													Text(item.route, style: AppTextStyles.subtitle(responsive)),
													SizedBox(height: responsive.h(2)),
													Text(
														item.date,
														style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
													),
												],
											),
										),
										Text(
											item.amount,
											style: AppTextStyles.subtitle(responsive).copyWith(
												color: cfg.color,
												fontWeight: FontWeight.w800,
												fontSize: responsive.text(16),
											),
										),
									],
								),
								SizedBox(height: responsive.h(10)),
								Container(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(6)),
									decoration: BoxDecoration(
										color: AppColors.surfaceMuted,
										borderRadius: BorderRadius.circular(responsive.radius(8)),
										border: Border.all(color: AppColors.border),
									),
									child: Text(
										item.reason,
										style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
									),
								),
								if (item.processedDate != null) ...[
									SizedBox(height: responsive.h(10)),
									Row(
										children: [
											Icon(Icons.schedule_rounded, size: responsive.text(12), color: AppColors.textHint),
											SizedBox(width: responsive.w(4)),
											Text(
												'Traité le ${item.processedDate}',
												style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
											),
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

// ── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
	const _EmptyState({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(32)),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Container(
						width: responsive.w(80),
						height: responsive.w(80),
						decoration: BoxDecoration(
							color: AppColors.surfaceAccent,
							shape: BoxShape.circle,
						),
						child: Icon(Icons.history_rounded, size: responsive.text(36), color: AppColors.primary),
					),
					SizedBox(height: responsive.h(20)),
					Text(
						'Aucune demande',
						style: AppTextStyles.title(responsive),
						textAlign: TextAlign.center,
					),
					SizedBox(height: responsive.h(8)),
					Text(
						'Vos demandes de remboursement apparaîtront ici une fois soumises.',
						style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
						textAlign: TextAlign.center,
					),
				],
			),
		);
	}
}

// ── Shared ──────────────────────────────────────────────────────────────────

class _StatusConfig {
	const _StatusConfig({required this.label, required this.icon, required this.color, required this.bg});
	final String label;
	final IconData icon;
	final Color color;
	final Color bg;
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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/revenus_controller.dart';

double _niceMax(double value) {
  if (value <= 0) return 30000;
  const candidates = [3000, 6000, 9000, 12000, 15000, 18000, 21000, 24000,
    27000, 30000, 45000, 60000, 90000, 120000, 150000, 180000, 210000,
    300000, 600000, 900000, 1200000];
  for (final c in candidates) {
    if (c >= value) return c.toDouble();
  }
  return (value / 3).ceilToDouble() * 3;
}

String _fmtAxisLabel(double amount) {
  if (amount <= 0) return '0';
  return amount.toInt().toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class RevenusView extends StatelessWidget {
	const RevenusView({super.key});

	RevenusController get _controller =>
			Get.isRegistered<RevenusController>()
					? Get.find<RevenusController>()
					: Get.put(RevenusController());

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		final controller = _controller;

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: ListView(
							padding: EdgeInsets.fromLTRB(
								responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
								responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
								responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
								responsive.adaptive(phone: 32, smallPhone: 28, tablet: 36, desktop: 40),
							),
							children: [
								_TopHeader(responsive: responsive, controller: controller),
								SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
								_HeroBalanceCard(
									responsive: responsive,
									controller: controller,
								),
								SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
								_PendingIncomeCard(responsive: responsive, controller: controller),
								SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 18, desktop: 20)),
								_SectionRow(
									responsive: responsive,
									title: AppStrings.revenuesRecentTransactions,
									trailing: AppStrings.revenuesViewAll,
								),
								SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
								Obx(() => _WeeklyChartCard(responsive: responsive, points: controller.weeklyPoints.toList())),
								SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 18)),
								Obx(() {
									if (controller.isLoading.value) {
										return const Center(child: CircularProgressIndicator());
									}
									if (controller.transactions.isEmpty) {
										return const SizedBox.shrink();
									}
									return Column(
										children: [
											for (var index = 0; index < controller.transactions.length; index++) ...[
												_TransactionCard(
													responsive: responsive,
													transaction: controller.transactions[index],
												),
												if (index != controller.transactions.length - 1)
													SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
											],
										],
									);
								}),
								SizedBox(height: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 18)),
								_SectionTitle(
									responsive: responsive,
									title: AppStrings.revenuesMethodsTitle,
								),
								SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
								Obx(() {
									final methods = List<RevenueMethod>.from(controller.methods);
									final items = <Widget>[];
									for (var i = 0; i < methods.length; i++) {
										final method = methods[i];
										items.add(Dismissible(
											key: ValueKey('${method.title}_${method.subtitle}'),
											direction: DismissDirection.horizontal,
											background: Container(
												alignment: Alignment.centerLeft,
												padding: const EdgeInsets.only(left: 20),
												decoration: BoxDecoration(
													color: AppColors.primary,
													borderRadius: BorderRadius.circular(responsive.radius(16)),
												),
												child: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
											),
											secondaryBackground: Container(
												alignment: Alignment.centerRight,
												padding: const EdgeInsets.only(right: 20),
												decoration: BoxDecoration(
													color: Color(0xFFE53935),
													borderRadius: BorderRadius.circular(responsive.radius(16)),
												),
												child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 22),
											),
											confirmDismiss: (direction) async {
												if (direction == DismissDirection.startToEnd) {
													controller.editMethod(method);
													return false;
												}
												return await Get.dialog<bool>(
													AlertDialog(
														shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
														title: const Text('Supprimer la méthode',
																style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
														content: Text('Supprimer "${method.title}" ?\nCette action est irréversible.'),
														actions: [
															TextButton(
																onPressed: () => Get.back(result: false),
																child: const Text('Annuler',
																		style: TextStyle(color: AppColors.textMuted)),
															),
															TextButton(
																onPressed: () => Get.back(result: true),
																child: const Text('Supprimer',
																		style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700)),
															),
														],
													),
												) ?? false;
											},
											onDismissed: (_) {
												controller.methods.remove(method);
												UIHelper().showSnackBar(AppStrings.appName, '${method.title} supprimé.', 0);
											},
											child: _MethodCard(
												responsive: responsive,
												method: method,
												onTap: () => controller.onMethodTap(method),
											),
										));
										if (i < methods.length - 1) {
											items.add(SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)));
										}
									}
									return Column(children: items);
								}),
								SizedBox(height: responsive.adaptive(phone: 12, smallPhone: 10, tablet: 12, desktop: 12)),
								_AddMethodButton(
									responsive: responsive,
									onTap: controller.onAddMethod,
								),
							],
						),
					),
				),
			),
		);
	}
}

class _TopHeader extends StatelessWidget {
	const _TopHeader({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final RevenusController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20),
				vertical: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16),
			),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [
					BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
				],
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Text(
						AppStrings.revenuesTitle,
						style: AppTextStyles.rolesCardTitle(responsive).copyWith(
							fontSize: responsive.text(18),
							color: AppColors.textPrimary,
						),
					),
					AppCircularButton(
						responsive: responsive,
						icon: Icons.receipt_long_outlined,
						onTap: controller.onHistory,
						size: responsive.adaptive(phone: 40, smallPhone: 40, tablet: 40, desktop: 40),
					),
				],
			),
		);
	}
}

class _HeroBalanceCard extends StatelessWidget {
	const _HeroBalanceCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final RevenusController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.only(
				top: responsive.adaptive(phone: 24, smallPhone: 22, tablet: 24, desktop: 24),
				left: responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20),
				right: responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20),
				bottom: responsive.adaptive(phone: 24, smallPhone: 22, tablet: 24, desktop: 24),
			),
			decoration: ShapeDecoration(
				gradient: const LinearGradient(
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
					colors: [AppColors.primary, AppColors.success],
				),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.only(
						bottomLeft: Radius.circular(responsive.radius(32)),
						bottomRight: Radius.circular(responsive.radius(32)),
					),
				),
			),
			child: Stack(
				clipBehavior: Clip.none,
				children: [
					Positioned(
						left: -64,
						top: 176,
						child: Opacity(
							opacity: 0.05,
							child: Container(
								width: 129,
								height: 128,
								decoration: ShapeDecoration(
									color: AppColors.white,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(9999),
										side: const BorderSide(color: AppColors.border),
									),
								),
							),
						),
					),
					Positioned(
						right: -20,
						top: -80,
						child: Opacity(
							opacity: 0.05,
							child: Container(
								width: 161,
								height: 160,
								decoration: ShapeDecoration(
									color: AppColors.white,
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(9999),
										side: const BorderSide(color: AppColors.border),
									),
								),
							),
						),
					),
					Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									Expanded(
										child: Row(
											children: [
												Icon(Icons.account_balance_wallet_outlined, size: responsive.text(16), color: AppColors.white.withValues(alpha: 0.85)),
												SizedBox(width: responsive.w(8)),
												Text(
													AppStrings.revenuesAvailableBalance,
													style: AppTextStyles.caption(responsive).copyWith(
														color: AppColors.white.withValues(alpha: 0.90),
														fontSize: responsive.text(14),
														fontWeight: FontWeight.w600,
													),
												),
											],
										),
									),
									Text(
										AppStrings.revenuesCurrency,
										style: AppTextStyles.caption(responsive).copyWith(
											color: AppColors.white.withValues(alpha: 0.90),
											fontSize: responsive.text(14),
											fontWeight: FontWeight.w600,
										),
									),
								],
							),
							SizedBox(height: responsive.h(12)),
							Obx(() => Text(
								controller.availableBalance.value,
								style: AppTextStyles.rolesCardTitle(responsive).copyWith(
									color: AppColors.white,
									fontSize: responsive.text(48),
									fontWeight: FontWeight.w700,
									height: 1,
								),
							)),
							SizedBox(height: responsive.h(8)),
							Text(
								AppStrings.revenuesCurrency,
								style: AppTextStyles.rolesCardDescription(responsive).copyWith(
									color: AppColors.white,
									fontSize: responsive.text(18),
									fontWeight: FontWeight.w600,
								),
							),
							SizedBox(height: responsive.h(16)),
							Row(
								children: [
									Expanded(
										child: AppPrimaryButton(
											responsive: responsive,
											label: AppStrings.revenuesWithdraw,
											onTap: controller.onWithdraw,
											height: responsive.adaptive(phone: 56, smallPhone: 52, tablet: 56, desktop: 56),
											backgroundColor: AppColors.white,
											textColor: AppColors.primary,
											borderColor: AppColors.border,
											borderRadius: responsive.radius(16),
										),
									),
									SizedBox(width: responsive.w(12)),
									Expanded(
										child: AppPrimaryButton(
											responsive: responsive,
											label: AppStrings.revenuesHistory,
											onTap: controller.onHistory,
											height: responsive.adaptive(phone: 56, smallPhone: 52, tablet: 56, desktop: 56),
											backgroundColor: AppColors.accent,
											textColor: AppColors.textPrimary,
											borderColor: AppColors.accent,
											borderRadius: responsive.radius(16),
										),
									),
								],
							),
						],
					),
				],
			),
		);
	}
}

class _PendingIncomeCard extends StatelessWidget {
	const _PendingIncomeCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final RevenusController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20)),
			decoration: ShapeDecoration(
				color: const Color(0x19F4B400),
				shape: RoundedRectangleBorder(
					side: const BorderSide(width: 2, color: AppColors.accent),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Row(
								children: [
									Container(
										width: 40,
										height: 40,
										decoration: ShapeDecoration(
											color: AppColors.accent,
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(9999),
												side: const BorderSide(color: AppColors.border),
											),
										),
										child: Icon(Icons.schedule_rounded, color: AppColors.white, size: responsive.text(20)),
									),
									SizedBox(width: responsive.w(12)),
									Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												AppStrings.revenuesPendingIncome,
												style: AppTextStyles.caption(responsive).copyWith(
													color: AppColors.textPrimary,
													fontSize: responsive.text(12),
													fontWeight: FontWeight.w600,
												),
											),
											SizedBox(height: responsive.h(2)),
											Obx(() => Text(
												'${controller.pendingIncome.value} ${AppStrings.revenuesCurrency}',
												style: AppTextStyles.rolesCardTitle(responsive).copyWith(
													color: AppColors.textPrimary,
													fontSize: responsive.text(20),
													fontWeight: FontWeight.w700,
												),
											)),
										],
									),
								],
							),
							AppCircularButton(
								responsive: responsive,
								icon: Icons.arrow_forward_ios_rounded,
								onTap: controller.onHistory,
								size: responsive.adaptive(phone: 36, smallPhone: 36, tablet: 36, desktop: 36),
							),
						],
					),
					SizedBox(height: responsive.h(12)),
					Row(
						children: [
							Container(
								width: 12,
								height: 12,
								decoration: ShapeDecoration(
									color: AppColors.primary,
									shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
								),
							),
							SizedBox(width: responsive.w(8)),
							Expanded(
								child: Text(
									AppStrings.revenuesAvailableIn48h,
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.textPrimary,
										fontWeight: FontWeight.w500,
									),
								),
							),
						],
					),
				],
			),
		);
	}
}

class _SectionRow extends StatelessWidget {
	const _SectionRow({required this.responsive, required this.title, required this.trailing});

	final AppResponsive responsive;
	final String title;
	final String trailing;

	@override
	Widget build(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Text(
					title,
					style: AppTextStyles.rolesCardTitle(responsive).copyWith(
						fontSize: responsive.text(16),
						color: AppColors.textPrimary,
					),
				),
				Text(
					trailing,
					style: AppTextStyles.rolesSecondaryAction(responsive).copyWith(
						color: AppColors.primary,
						decoration: TextDecoration.none,
						fontWeight: FontWeight.w600,
					),
				),
			],
		);
	}
}

class _WeeklyChartCard extends StatelessWidget {
	const _WeeklyChartCard({required this.responsive, required this.points});

	final AppResponsive responsive;
	final List<WeeklyRevenuePoint> points;

	@override
	Widget build(BuildContext context) {
		final double rawMax = points.fold<double>(0, (maxValue, point) => math.max(maxValue, point.amount));
		final double maxAmount = _niceMax(rawMax);
		const dayLabels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
		final todayLabel = dayLabels[DateTime.now().weekday - 1];

		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [
					BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text(
								AppStrings.revenuesWeeklyIncome,
								style: AppTextStyles.rolesCardTitle(responsive).copyWith(
									fontSize: responsive.text(16),
									color: AppColors.textPrimary,
								),
							),
							Row(
								children: [
									Container(
										width: 12,
										height: 12,
										decoration: ShapeDecoration(
											color: AppColors.accent,
											shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
										),
									),
									SizedBox(width: responsive.w(4)),
									Text(
										'7j',
										style: AppTextStyles.caption(responsive).copyWith(
											color: AppColors.primary,
											fontSize: responsive.text(14),
											fontWeight: FontWeight.w600,
										),
									),
								],
							),
						],
					),
					SizedBox(height: responsive.h(16)),
					SizedBox(
						height: responsive.adaptive(phone: 200, smallPhone: 190, tablet: 210, desktop: 220),
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.stretch,
							children: [
								SizedBox(
									width: responsive.w(54),
									child: Column(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										crossAxisAlignment: CrossAxisAlignment.end,
										children: [
											Text(_fmtAxisLabel(maxAmount),       style: const TextStyle(fontSize: 11, fontFamily: 'Inter')),
											Text(_fmtAxisLabel(maxAmount * 2/3), style: const TextStyle(fontSize: 11, fontFamily: 'Inter')),
											Text(_fmtAxisLabel(maxAmount / 3),   style: const TextStyle(fontSize: 11, fontFamily: 'Inter')),
											const Text('0',                      style: TextStyle(fontSize: 11, fontFamily: 'Inter')),
										],
									),
								),
								SizedBox(width: responsive.w(8)),
								Expanded(
									child: Column(
										children: [
											Expanded(
												child: Row(
													crossAxisAlignment: CrossAxisAlignment.end,
													children: [
														for (final point in points)
															Expanded(
																child: Padding(
																	padding: EdgeInsets.symmetric(horizontal: responsive.w(4)),
																	child: Column(
																		mainAxisAlignment: MainAxisAlignment.end,
																		children: [
																			Container(
																				width: double.infinity,
																				height: maxAmount > 0 ? (point.amount / maxAmount) * responsive.adaptive(phone: 120, smallPhone: 112, tablet: 124, desktop: 128) : 0.0,
																				decoration: ShapeDecoration(
																					color: point.label == todayLabel ? AppColors.primary : AppColors.surfaceSoft,
																					shape: RoundedRectangleBorder(
																						borderRadius: BorderRadius.circular(responsive.radius(10)),
																					),
																				),
																			),
																		],
																	),
																),
															),
													],
												),
											),
											SizedBox(height: responsive.h(10)),
											Row(
												children: [
													for (final point in points)
														Expanded(
															child: Text(
																point.label,
																textAlign: TextAlign.center,
																style: AppTextStyles.caption(responsive).copyWith(
																	color: AppColors.textPrimary,
																	fontSize: responsive.text(11),
																),
															),
														),
												],
											),
										],
									),
								),
							],
						),
					),
				],
			),
		);
	}
}

class _TransactionCard extends StatelessWidget {
	const _TransactionCard({required this.responsive, required this.transaction});

	final AppResponsive responsive;
	final RevenueTransaction transaction;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [
					BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
				],
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Expanded(
						child: Row(
							children: [
								Container(
									width: responsive.w(48),
									height: responsive.w(48),
									decoration: ShapeDecoration(
										color: transaction.iconBackground,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(responsive.radius(12)),
											side: const BorderSide(color: AppColors.border),
										),
									),
									child: Icon(transaction.icon, color: AppColors.primary, size: responsive.text(20)),
								),
								SizedBox(width: responsive.w(12)),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												transaction.title,
												style: AppTextStyles.homeCardTitle(responsive).copyWith(
													fontSize: responsive.text(14),
													color: AppColors.textPrimary,
												),
											),
											SizedBox(height: responsive.h(2)),
											Text(
												transaction.dateLabel,
												style: AppTextStyles.caption(responsive).copyWith(
													color: AppColors.textHint,
													fontSize: responsive.text(12),
												),
											),
										],
									),
								),
							],
						),
					),
					SizedBox(width: responsive.w(8)),
					Column(
						crossAxisAlignment: CrossAxisAlignment.end,
						children: [
							Text(
								transaction.amount,
								style: AppTextStyles.rolesCardTitle(responsive).copyWith(
									color: transaction.amountColor,
									fontSize: responsive.text(16),
									fontWeight: FontWeight.w700,
								),
							),
							SizedBox(height: responsive.h(4)),
							Container(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(4)),
								decoration: ShapeDecoration(
									color: transaction.statusColor.withValues(alpha: 0.10),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(9999),
										side: const BorderSide(color: AppColors.border),
									),
								),
								child: Text(
									transaction.statusLabel,
									style: AppTextStyles.caption(responsive).copyWith(
										color: transaction.statusColor,
										fontSize: responsive.text(12),
										fontWeight: FontWeight.w600,
									),
								),
							),
						],
					),
				],
			),
		);
	}
}

class _MethodCard extends StatelessWidget {
	const _MethodCard({required this.responsive, required this.method, required this.onTap});

	final AppResponsive responsive;
	final RevenueMethod method;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [
					BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
				],
			),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.spaceBetween,
				children: [
					Row(
						children: [
							Container(
								width: responsive.w(48),
								height: responsive.w(48),
								decoration: ShapeDecoration(
									color: method.color.withValues(alpha: 0.15),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(responsive.radius(12)),
										side: const BorderSide(color: AppColors.border),
									),
								),
								child: Icon(method.icon, color: method.color, size: responsive.text(20)),
							),
							SizedBox(width: responsive.w(12)),
							Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text(
										method.title,
										style: AppTextStyles.homeCardTitle(responsive).copyWith(
											fontSize: responsive.text(14),
											color: AppColors.textPrimary,
										),
									),
									SizedBox(height: responsive.h(2)),
									Text(
										method.subtitle,
										style: AppTextStyles.caption(responsive).copyWith(
											color: AppColors.textHint,
											fontSize: responsive.text(12),
										),
									),
								],
							),
						],
					),
					AppCircularButton(
						responsive: responsive,
						icon: Icons.more_vert_rounded,
						onTap: onTap,
						size: responsive.adaptive(phone: 36, smallPhone: 36, tablet: 36, desktop: 36),
					),
				],
			),
		);
	}
}

class _AddMethodButton extends StatelessWidget {
	const _AddMethodButton({required this.responsive, required this.onTap});

	final AppResponsive responsive;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return AppPrimaryButton(
			responsive: responsive,
			label: AppStrings.revenuesAddMethod,
			onTap: onTap,
			height: responsive.adaptive(phone: 56, smallPhone: 52, tablet: 56, desktop: 56),
			backgroundColor: AppColors.surfaceMuted,
			textColor: AppColors.primary,
			borderColor: const Color(0x33111111),
			borderRadius: responsive.radius(16),
		);
	}
}

class _SectionTitle extends StatelessWidget {
	const _SectionTitle({required this.responsive, required this.title});

	final AppResponsive responsive;
	final String title;

	@override
	Widget build(BuildContext context) {
		return Text(
			title,
			style: AppTextStyles.rolesCardTitle(responsive).copyWith(
				fontSize: responsive.text(16),
				color: AppColors.textPrimary,
			),
		);
	}
}

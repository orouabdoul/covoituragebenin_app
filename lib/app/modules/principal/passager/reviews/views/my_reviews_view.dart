import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/my_reviews_controller.dart';

class MyReviewsView extends StatelessWidget {
	const MyReviewsView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<MyReviewsController>()
				? Get.find<MyReviewsController>()
				: Get.put(MyReviewsController(Get.find()));
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
								Expanded(
									child: Obx(() {
										final version = controller.reviewsVersion.value;
										if (controller.isLoading.value && version == 0) {
											return const Center(
												child: CircularProgressIndicator(color: AppColors.primary),
											);
										}
										if (controller.hasLoadError.value && version == 0) {
											return _ErrorBody(
												responsive: responsive,
												onRetry: () => controller.refresh(),
											);
										}
										if (controller.reviews.isEmpty) {
											return _EmptyState(responsive: responsive);
										}
										return RefreshIndicator(
											onRefresh: controller.refresh,
											color: AppColors.primary,
											child: ListView(
												physics: const AlwaysScrollableScrollPhysics(),
												padding: EdgeInsets.symmetric(
													horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
													vertical: responsive.h(16),
												),
												children: [
													_RatingSummaryCard(responsive: responsive, controller: controller),
													SizedBox(height: responsive.h(20)),
													Text(
														'Mes avis (${controller.reviews.length})',
														style: AppTextStyles.subtitle(responsive).copyWith(fontWeight: FontWeight.w700),
													),
													SizedBox(height: responsive.h(12)),
													...controller.reviews.asMap().entries.map((e) => Padding(
														padding: EdgeInsets.only(bottom: e.key < controller.reviews.length - 1 ? responsive.h(12) : 0),
														child: _ReviewCard(responsive: responsive, review: e.value),
													)),
													SizedBox(height: responsive.h(16)),
												],
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

// ── Error body ─────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
	const _ErrorBody({required this.responsive, required this.onRetry});
	final AppResponsive responsive;
	final VoidCallback onRetry;

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Padding(
				padding: EdgeInsets.all(responsive.w(32)),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(Icons.cloud_off_rounded, size: responsive.text(48), color: AppColors.textHint),
						SizedBox(height: responsive.h(16)),
						Text(
							'Impossible de charger les avis',
							style: AppTextStyles.subtitle(responsive),
							textAlign: TextAlign.center,
						),
						SizedBox(height: responsive.h(8)),
						Text(
							'Vérifiez votre connexion et réessayez.',
							style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
							textAlign: TextAlign.center,
						),
						SizedBox(height: responsive.h(24)),
						AppPrimaryButton(
							responsive: responsive,
							label: 'Réessayer',
							onTap: onRetry,
						),
					],
				),
			),
		);
	}
}

// ── Header ─────────────────────────────────────────────────────────────────

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
					const Spacer(),
					Column(
						children: [
							Text('Mes avis', style: AppTextStyles.title(responsive)),
							Text(
								'Vos évaluations de conducteurs',
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
							),
						],
					),
					const Spacer(),
					SizedBox(width: responsive.w(40)),
				],
			),
		);
	}
}

// ── Rating Summary Card ────────────────────────────────────────────────────

class _RatingSummaryCard extends StatelessWidget {
	const _RatingSummaryCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final MyReviewsController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(20)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(20)),
				),
				shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, 3))],
			),
			child: Row(
				children: [
					// Big average number
					Column(
						children: [
							Text(
								controller.formattedAverage,
								style: TextStyle(
									color: AppColors.warning,
									fontSize: responsive.text(52),
									fontFamily: 'Inter',
									fontWeight: FontWeight.w800,
									letterSpacing: -2,
									height: 1,
								),
							),
							SizedBox(height: responsive.h(6)),
							_StarRow(rating: controller.averageRating.round(), size: responsive.text(16)),
							SizedBox(height: responsive.h(4)),
							Text(
								'${controller.reviews.length} avis donnés',
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
							),
						],
					),
					SizedBox(width: responsive.w(24)),
					// Star breakdown bars
					Expanded(
						child: Column(
							children: List.generate(5, (i) {
								final stars = 5 - i;
								final fraction = controller.fractionByRating(stars);
								final count = controller.countByRating(stars);
								return Padding(
									padding: EdgeInsets.only(bottom: i < 4 ? responsive.h(6) : 0),
									child: Row(
										children: [
											Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.warning),
											SizedBox(width: responsive.w(4)),
											Text(
												'$stars',
												style: AppTextStyles.caption(responsive).copyWith(
													color: AppColors.textSecondary,
													fontWeight: FontWeight.w600,
												),
											),
											SizedBox(width: responsive.w(8)),
											Expanded(
												child: ClipRRect(
													borderRadius: BorderRadius.circular(9999),
													child: LinearProgressIndicator(
														value: fraction,
														minHeight: responsive.h(6),
														backgroundColor: AppColors.surfaceMuted,
														valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
													),
												),
											),
											SizedBox(width: responsive.w(6)),
											SizedBox(
												width: responsive.w(14),
												child: Text(
													'$count',
													style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
													textAlign: TextAlign.right,
												),
											),
										],
									),
								);
							}),
						),
					),
				],
			),
		);
	}
}

// ── Review Card ────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
	const _ReviewCard({required this.responsive, required this.review});
	final AppResponsive responsive;
	final ReviewRecord review;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
				shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					// Driver + meta row
					Row(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							_Avatar(name: review.driverName, size: responsive.w(44)),
							SizedBox(width: responsive.w(12)),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(review.driverName, style: AppTextStyles.subtitle(responsive)),
										SizedBox(height: responsive.h(2)),
										Text(
											review.route,
											style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary),
										),
										SizedBox(height: responsive.h(2)),
										Text(
											review.date,
											style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
										),
									],
								),
							),
							Column(
								crossAxisAlignment: CrossAxisAlignment.end,
								children: [
									_StarRow(rating: review.rating, size: responsive.text(16)),
									SizedBox(height: responsive.h(4)),
									Text(
										'${review.rating}/5',
										style: AppTextStyles.caption(responsive).copyWith(
											color: AppColors.warning,
											fontWeight: FontWeight.w800,
										),
									),
								],
							),
						],
					),
					// Tags
					if (review.tags.isNotEmpty) ...[
						SizedBox(height: responsive.h(12)),
						Wrap(
							spacing: responsive.w(6),
							runSpacing: responsive.h(6),
							children: review.tags.map((tag) => Container(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(4)),
								decoration: BoxDecoration(
									color: AppColors.primary.withValues(alpha: 0.08),
									borderRadius: BorderRadius.circular(9999),
									border: Border.all(color: AppColors.primary.withValues(alpha: 0.20)),
								),
								child: Text(
									tag,
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w500,
									),
								),
							)).toList(),
						),
					],
					// Comment
					if (review.comment != null) ...[
						SizedBox(height: responsive.h(12)),
						Container(
							width: double.infinity,
							padding: EdgeInsets.all(responsive.w(12)),
							decoration: BoxDecoration(
								color: AppColors.surfaceMuted,
								borderRadius: BorderRadius.circular(10),
								border: Border.all(color: AppColors.border),
							),
							child: Row(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Icon(
										Icons.format_quote_rounded,
										size: responsive.text(16),
										color: AppColors.primary.withValues(alpha: 0.50),
									),
									SizedBox(width: responsive.w(6)),
									Expanded(
										child: Text(
											review.comment!,
											style: AppTextStyles.body(responsive).copyWith(
												color: AppColors.textSecondary,
												height: 1.5,
												fontStyle: FontStyle.italic,
											),
										),
									),
								],
							),
						),
					],
				],
			),
		);
	}
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
	const _EmptyState({required this.responsive});
	final AppResponsive responsive;

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
							child: Icon(Icons.star_border_rounded, size: responsive.text(36), color: AppColors.textHint),
						),
						SizedBox(height: responsive.h(20)),
						Text('Aucun avis', style: AppTextStyles.subtitle(responsive)),
						SizedBox(height: responsive.h(8)),
						Text(
							'Vos évaluations de conducteurs\napparaîtront ici après chaque trajet.',
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

class _StarRow extends StatelessWidget {
	const _StarRow({required this.rating, required this.size});
	final int rating;
	final double size;

	@override
	Widget build(BuildContext context) {
		return Row(
			mainAxisSize: MainAxisSize.min,
			children: List.generate(5, (i) => Icon(
				i < rating ? Icons.star_rounded : Icons.star_border_rounded,
				color: AppColors.warning,
				size: size,
			)),
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
		final a = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first[0] : 'C';
		final b = parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
		return Container(
			width: size,
			height: size,
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(size * 0.28),
				border: Border.all(color: AppColors.border),
			),
			child: Center(
				child: Text(
					(a + b).toUpperCase(),
					style: TextStyle(color: AppColors.primary, fontSize: size * 0.32, fontFamily: 'Inter', fontWeight: FontWeight.w700),
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

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import '../controllers/trip_confirmation_controller.dart';

class TripConfirmationView extends StatelessWidget {
	const TripConfirmationView({super.key});

	@override
	Widget build(BuildContext context) {
		final TripConfirmationController controller =
				Get.isRegistered<TripConfirmationController>()
						? Get.find<TripConfirmationController>()
						: Get.put(TripConfirmationController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Obx(() {
							if (controller.submitted.value) {
								return _SubmittedState(responsive: responsive, controller: controller);
							}
							return _MainContent(responsive: responsive, controller: controller);
						}),
					),
				),
			),
		);
	}
}

// ── Main Content ───────────────────────────────────────────────────────────

class _MainContent extends StatelessWidget {
	const _MainContent({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final TripConfirmationController controller;

	@override
	Widget build(BuildContext context) {
		return ListView(
			padding: EdgeInsets.fromLTRB(
				responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				responsive.h(8),
				responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				responsive.h(32),
			),
			children: [
				_HeaderBar(responsive: responsive),
				SizedBox(height: responsive.h(20)),
				_TripSummary(responsive: responsive, controller: controller),
				SizedBox(height: responsive.h(16)),
				_ConfirmCard(responsive: responsive, controller: controller),
				SizedBox(height: responsive.h(16)),
				Obx(() => controller.tripConfirmed.value
						? _RatingCard(responsive: responsive, controller: controller)
						: const SizedBox.shrink()),
				Obx(() => controller.tripConfirmed.value
						? SizedBox(height: responsive.h(16))
						: const SizedBox.shrink()),
				Obx(() => controller.tripConfirmed.value && controller.rating.value > 0
						? _QuickTagsCard(responsive: responsive, controller: controller)
						: const SizedBox.shrink()),
				Obx(() => controller.tripConfirmed.value && controller.rating.value > 0
						? SizedBox(height: responsive.h(16))
						: const SizedBox.shrink()),
				Obx(() => controller.tripConfirmed.value && controller.rating.value > 0
						? _ReviewField(responsive: responsive, controller: controller)
						: const SizedBox.shrink()),
				Obx(() => controller.tripConfirmed.value && controller.rating.value > 0
						? SizedBox(height: responsive.h(16))
						: const SizedBox.shrink()),
				Obx(() {
					if (!controller.tripConfirmed.value) return const SizedBox.shrink();
					if (controller.rating.value > 0) {
						return Column(
							children: [
								AppPrimaryButton(
									responsive: responsive,
									label: controller.isSubmitting.value ? 'Envoi en cours…' : 'Envoyer mon avis',
									onTap: controller.isSubmitting.value ? () {} : controller.submitReview,
									enabled: !controller.isSubmitting.value,
									height: responsive.h(56),
									borderRadius: responsive.radius(16),
								),
								SizedBox(height: responsive.h(10)),
								AppPrimaryButton(
									responsive: responsive,
									label: 'Passer',
									onTap: controller.skipReview,
									backgroundColor: AppColors.white,
									textColor: AppColors.textHint,
									borderColor: AppColors.border,
									height: responsive.h(48),
									borderRadius: responsive.radius(16),
								),
							],
						);
					}
					return AppPrimaryButton(
						responsive: responsive,
						label: 'Terminer sans évaluer',
						onTap: controller.skipReview,
						backgroundColor: AppColors.white,
						textColor: AppColors.textSecondary,
						borderColor: AppColors.border,
						height: responsive.h(48),
						borderRadius: responsive.radius(16),
					);
				}),
			],
		);
	}
}

// ── Header ─────────────────────────────────────────────────────────────────

class _HeaderBar extends StatelessWidget {
	const _HeaderBar({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(vertical: responsive.h(12)),
			child: Row(
				children: [
					const SizedBox(width: 40),
					const Spacer(),
					Text('Trajet terminé', style: AppTextStyles.title(responsive)),
					const Spacer(),
					const SizedBox(width: 40),
				],
			),
		);
	}
}

// ── Trip Summary Card ──────────────────────────────────────────────────────

class _TripSummary extends StatelessWidget {
	const _TripSummary({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final TripConfirmationController controller;

	@override
	Widget build(BuildContext context) {
		final ride = controller.ride.value;
		final origin = ride?.origin ?? 'Cotonou';
		final destination = ride?.destination ?? 'Porto-Novo';
		final duration = ride?.duration ?? '3h30';
		final driver = ride?.driverName ?? 'Votre conducteur';

		return _Card(
			responsive: responsive,
			child: Column(
				children: [
					Row(
						children: [
							Container(
								width: responsive.w(48),
								height: responsive.w(48),
								decoration: BoxDecoration(
									color: const Color(0x1900A86B),
									borderRadius: BorderRadius.circular(12),
								),
								child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primary),
							),
							SizedBox(width: responsive.w(14)),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text(
											'$origin → $destination',
											style: AppTextStyles.subtitle(responsive),
										),
										SizedBox(height: responsive.h(2)),
										Text(
											'Durée : $duration · Avec $driver',
											style: AppTextStyles.caption(responsive),
										),
									],
								),
							),
							Container(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(4)),
								decoration: BoxDecoration(
									color: const Color(0x1900A86B),
									borderRadius: BorderRadius.circular(9999),
									border: Border.all(color: const Color(0x3300A86B)),
								),
								child: Text(
									'Terminé ✓',
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w700,
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

// ── Confirm Card ───────────────────────────────────────────────────────────

class _ConfirmCard extends StatelessWidget {
	const _ConfirmCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final TripConfirmationController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final confirmed = controller.tripConfirmed.value;

			return _Card(
				responsive: responsive,
				child: Column(
					children: [
						if (!confirmed) ...[
							Text(
								'Confirmez-vous que le trajet est bien terminé ?',
								style: AppTextStyles.h6(responsive),
								textAlign: TextAlign.center,
							),
							SizedBox(height: responsive.h(20)),
							AppPrimaryButton(
								responsive: responsive,
								label: 'Oui, le trajet est terminé',
								onTap: controller.confirmTrip,
								height: responsive.h(56),
								borderRadius: responsive.radius(14),
							),
							SizedBox(height: responsive.h(10)),
							AppPrimaryButton(
								responsive: responsive,
								label: 'Signaler un problème',
								onTap: () => controller.hasIssue.value = !controller.hasIssue.value,
								backgroundColor: const Color(0xFFFEF2F2),
								textColor: const Color(0xFFEF4444),
								borderColor: const Color(0xFFFCA5A5),
								height: responsive.h(48),
								borderRadius: responsive.radius(14),
							),
							SizedBox(height: responsive.h(4)),
							Obx(() {
								if (!controller.hasIssue.value) return const SizedBox.shrink();
								return Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										SizedBox(height: responsive.h(12)),
										Text('Quel est le problème ?', style: AppTextStyles.subtitle(responsive)),
										SizedBox(height: responsive.h(10)),
										Wrap(
											spacing: responsive.w(8),
											runSpacing: responsive.h(8),
											children: controller.issueOptions.map((issue) {
												return Obx(() {
													final selected = controller.selectedIssues.contains(issue);
													return InkWell(
														onTap: () => controller.toggleIssue(issue),
														borderRadius: BorderRadius.circular(9999),
														child: Container(
															padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(6)),
															decoration: BoxDecoration(
																color: selected ? const Color(0xFFFEF2F2) : AppColors.surfaceMuted,
																borderRadius: BorderRadius.circular(9999),
																border: Border.all(color: selected ? const Color(0xFFEF4444) : AppColors.border),
															),
															child: Text(
																issue,
																style: AppTextStyles.caption(responsive).copyWith(
																	color: selected ? const Color(0xFFEF4444) : AppColors.textSecondary,
																	fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
																),
															),
														),
													);
												});
											}).toList(),
										),
									],
								);
							}),
						] else ...[
							Row(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Icon(Icons.check_circle_rounded, color: AppColors.primary, size: responsive.text(20)),
									SizedBox(width: responsive.w(8)),
									Text(
										'Trajet confirmé',
										style: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.primary),
									),
								],
							),
						],
					],
				),
			);
		});
	}
}

// ── Rating Card ────────────────────────────────────────────────────────────

class _RatingCard extends StatelessWidget {
	const _RatingCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final TripConfirmationController controller;

	@override
	Widget build(BuildContext context) {
		final ride = controller.ride.value;
		final driverName = ride?.driverName ?? 'Votre conducteur';

		return _Card(
			responsive: responsive,
			child: Column(
				children: [
					_DriverAvatar(name: driverName, size: responsive.w(60)),
					SizedBox(height: responsive.h(12)),
					Text(driverName, style: AppTextStyles.subtitle(responsive)),
					SizedBox(height: responsive.h(4)),
					Text(
						'Comment s\'est passé votre trajet ?',
						style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
					),
					SizedBox(height: responsive.h(20)),
					Obx(() => Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: List.generate(5, (i) {
							final filled = i < controller.rating.value;
							return GestureDetector(
								onTap: () => controller.setRating(i + 1),
								child: Padding(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(6)),
									child: AnimatedSwitcher(
										duration: AppResponsive.fastDuration,
										child: Icon(
											filled ? Icons.star_rounded : Icons.star_border_rounded,
											key: ValueKey(filled),
											size: responsive.text(38),
											color: filled ? const Color(0xFFF59E0B) : AppColors.border,
										),
									),
								),
							);
						}),
					)),
					SizedBox(height: responsive.h(8)),
					Obx(() => Text(
						_ratingLabel(controller.rating.value),
						style: AppTextStyles.body(responsive).copyWith(
							color: controller.rating.value > 0 ? const Color(0xFFF59E0B) : AppColors.textHint,
							fontWeight: FontWeight.w600,
						),
					)),
				],
			),
		);
	}

	String _ratingLabel(int r) {
		switch (r) {
			case 1: return 'Très mauvais';
			case 2: return 'Mauvais';
			case 3: return 'Correct';
			case 4: return 'Bien';
			case 5: return 'Excellent !';
			default: return 'Appuyez pour noter';
		}
	}
}

// ── Quick Tags Card ────────────────────────────────────────────────────────

class _QuickTagsCard extends StatelessWidget {
	const _QuickTagsCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final TripConfirmationController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Décrivez votre expérience', style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(12)),
					Obx(() => Wrap(
						spacing: responsive.w(8),
						runSpacing: responsive.h(8),
						children: controller.quickTags.map((tag) {
							final selected = controller.selectedTags.contains(tag);
							return GestureDetector(
								onTap: () => controller.toggleTag(tag),
								child: AnimatedContainer(
									duration: AppResponsive.fastDuration,
									padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(8)),
									decoration: BoxDecoration(
										color: selected ? const Color(0x0C00A86B) : AppColors.surfaceMuted,
										borderRadius: BorderRadius.circular(9999),
										border: Border.all(
											color: selected ? AppColors.primary : AppColors.border,
											width: selected ? 1.5 : 1,
										),
									),
									child: Text(
										(selected ? '✓ ' : '') + tag,
										style: AppTextStyles.caption(responsive).copyWith(
											color: selected ? AppColors.primary : AppColors.textSecondary,
											fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
										),
									),
								),
							);
						}).toList(),
					)),
				],
			),
		);
	}
}

// ── Review Field ───────────────────────────────────────────────────────────

class _ReviewField extends StatelessWidget {
	const _ReviewField({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final TripConfirmationController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Avis écrit (optionnel)', style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(10)),
					Container(
						decoration: BoxDecoration(
							color: AppColors.surfaceMuted,
							borderRadius: BorderRadius.circular(responsive.radius(12)),
							border: Border.all(color: AppColors.border),
						),
						child: TextField(
							controller: controller.reviewController,
							maxLines: 3,
							style: AppTextStyles.body(responsive),
							decoration: InputDecoration(
								border: InputBorder.none,
								contentPadding: EdgeInsets.all(responsive.w(14)),
								hintText: 'Partagez votre expérience avec ce conducteur…',
								hintStyle: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
							),
						),
					),
				],
			),
		);
	}
}

// ── Submitted State ────────────────────────────────────────────────────────

class _SubmittedState extends StatelessWidget {
	const _SubmittedState({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final TripConfirmationController controller;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.fromLTRB(
				responsive.adaptive(phone: 24, smallPhone: 20, tablet: 32, desktop: 48),
				0,
				responsive.adaptive(phone: 24, smallPhone: 20, tablet: 32, desktop: 48),
				responsive.h(40),
			),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					_SuccessCircle(size: responsive.w(110)),
					SizedBox(height: responsive.h(28)),
					Text(
						'Merci pour votre avis !',
						style: AppTextStyles.h6(responsive).copyWith(fontSize: responsive.text(22)),
						textAlign: TextAlign.center,
					),
					SizedBox(height: responsive.h(10)),
					Text(
						'Votre évaluation aide la communauté\nà voyager en toute confiance.',
						style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
						textAlign: TextAlign.center,
					),
					SizedBox(height: responsive.h(32)),
					// Stars display
					Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: List.generate(5, (i) => Padding(
							padding: EdgeInsets.symmetric(horizontal: responsive.w(4)),
							child: Icon(
								i < controller.rating.value ? Icons.star_rounded : Icons.star_border_rounded,
								color: const Color(0xFFF59E0B),
								size: responsive.text(28),
							),
						)),
					),
					SizedBox(height: responsive.h(40)),
					AppPrimaryButton(
						responsive: responsive,
						label: 'Retour à l\'accueil',
						onTap: controller.goHome,
						height: responsive.h(56),
						borderRadius: responsive.radius(16),
					),
					SizedBox(height: responsive.h(12)),
					AppPrimaryButton(
						responsive: responsive,
						label: 'Voir mes réservations',
						onTap: () => BottonNavController.goToTab(2),
						backgroundColor: AppColors.white,
						textColor: AppColors.textSecondary,
						borderColor: AppColors.border,
						height: responsive.h(48),
						borderRadius: responsive.radius(16),
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
			padding: EdgeInsets.all(responsive.w(20)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(20)),
				),
				shadows: const [BoxShadow(color: Color(0x0C000000), blurRadius: 8, offset: Offset(0, 2))],
			),
			child: child,
		);
	}
}

class _DriverAvatar extends StatelessWidget {
	const _DriverAvatar({required this.name, required this.size});

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
				borderRadius: BorderRadius.circular(16),
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

class _SuccessCircle extends StatelessWidget {
	const _SuccessCircle({required this.size});

	final double size;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: size,
			height: size,
			decoration: BoxDecoration(
				shape: BoxShape.circle,
				color: const Color(0x1900A86B),
				boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.15), blurRadius: 20, spreadRadius: 4)],
			),
			child: Icon(Icons.favorite_rounded, color: AppColors.primary, size: size * 0.45),
		);
	}
}

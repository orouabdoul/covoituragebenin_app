import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/trust_hub_controller.dart';

class TrustHubView extends StatelessWidget {
	const TrustHubView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<TrustHubController>()
				? Get.find<TrustHubController>()
				: Get.put(TrustHubController());
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
									child: ListView(
										padding: EdgeInsets.only(
											bottom: responsive.h(32),
										),
										children: [
											_HeroCard(responsive: responsive),
											Padding(
												padding: EdgeInsets.symmetric(
													horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
												),
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														SizedBox(height: responsive.h(24)),
														_SectionTitle(responsive: responsive, title: 'Notre promesse MINIZON'),
														SizedBox(height: responsive.h(12)),
														_PromiseCard(
															responsive: responsive,
															icon: Icons.verified_user_rounded,
															iconColor: AppColors.primary,
															title: 'Remboursement garanti',
															body: 'Si votre conducteur ne se présente pas ou annule le trajet, vous êtes remboursé(e) intégralement en moins de 48h. Sans condition, sans discussion.',
														),
														SizedBox(height: responsive.h(10)),
														_PromiseCard(
															responsive: responsive,
															icon: Icons.badge_rounded,
															iconColor: AppColors.blue,
															title: 'Conducteurs soigneusement vérifiés',
															body: 'Chaque conducteur passe par un processus de vérification rigoureux : pièce d\'identité, permis de conduire valide et inspection du véhicule.',
														),
														SizedBox(height: responsive.h(10)),
														_PromiseCard(
															responsive: responsive,
															icon: Icons.headset_mic_rounded,
															iconColor: const Color(0xFF8B5CF6),
															title: 'Support humain 24h/24 · 7j/7',
															body: 'Une vraie personne de notre équipe est disponible à toute heure pour vous aider, en français ou en fon. Vous n\'êtes jamais seul(e).',
														),
														SizedBox(height: responsive.h(10)),
														_PromiseCard(
															responsive: responsive,
															icon: Icons.lock_rounded,
															iconColor: AppColors.warning,
															title: 'Paiements 100% sécurisés',
															body: 'Votre argent est sécurisé jusqu\'à la confirmation du trajet. En cas de problème, il vous est restitué immédiatement.',
														),
														SizedBox(height: responsive.h(28)),
														_SectionTitle(responsive: responsive, title: 'Vos droits en tant que passager'),
														SizedBox(height: responsive.h(12)),
														_RightsCard(responsive: responsive),
														SizedBox(height: responsive.h(28)),
														_SectionTitle(responsive: responsive, title: 'Comment nous vérifions les conducteurs'),
														SizedBox(height: responsive.h(12)),
														_VerificationSteps(responsive: responsive),
														SizedBox(height: responsive.h(28)),
														_StatsCard(responsive: responsive),
														SizedBox(height: responsive.h(28)),
														_SectionTitle(responsive: responsive, title: 'Accès rapide'),
														SizedBox(height: responsive.h(12)),
														_QuickActionsRow(responsive: responsive, controller: controller),
														SizedBox(height: responsive.h(20)),
														_EngagementFooter(responsive: responsive),
													],
												),
											),
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
							Text('Espace confiance', style: AppTextStyles.title(responsive)),
							Text(
								'Votre sécurité, notre engagement',
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary),
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

// ── Hero Card ──────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
	const _HeroCard({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 24, smallPhone: 20, tablet: 32, desktop: 48),
				vertical: responsive.h(36),
			),
			decoration: const BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
					colors: [Color(0xFF00A86B), Color(0xFF007A4E)],
				),
			),
			child: Column(
				children: [
					Container(
						width: responsive.w(80),
						height: responsive.w(80),
						decoration: BoxDecoration(
							color: Colors.white.withValues(alpha: 0.15),
							shape: BoxShape.circle,
						),
						child: Icon(
							Icons.shield_rounded,
							color: Colors.white,
							size: responsive.text(40),
						),
					),
					SizedBox(height: responsive.h(20)),
					Text(
						'Chaque trajet MINIZON\nest protégé',
						textAlign: TextAlign.center,
						style: TextStyle(
							color: Colors.white,
							fontSize: responsive.text(22),
							fontFamily: 'Inter',
							fontWeight: FontWeight.w800,
							height: 1.3,
						),
					),
					SizedBox(height: responsive.h(12)),
					Text(
						'Conducteurs vérifiés · Paiements sécurisés · Support 24/7',
						textAlign: TextAlign.center,
						style: TextStyle(
							color: Colors.white.withValues(alpha: 0.85),
							fontSize: responsive.text(13),
							fontFamily: 'Inter',
							fontWeight: FontWeight.w400,
							height: 1.5,
						),
					),
					SizedBox(height: responsive.h(24)),
					// Trust badges row
					Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							_HeroBadge(responsive: responsive, icon: Icons.verified_rounded, label: 'Vérifié'),
							SizedBox(width: responsive.w(16)),
							_HeroBadge(responsive: responsive, icon: Icons.lock_rounded, label: 'Sécurisé'),
							SizedBox(width: responsive.w(16)),
							_HeroBadge(responsive: responsive, icon: Icons.favorite_rounded, label: 'Garanti'),
						],
					),
				],
			),
		);
	}
}

class _HeroBadge extends StatelessWidget {
	const _HeroBadge({required this.responsive, required this.icon, required this.label});
	final AppResponsive responsive;
	final IconData icon;
	final String label;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(7)),
			decoration: BoxDecoration(
				color: Colors.white.withValues(alpha: 0.15),
				borderRadius: BorderRadius.circular(9999),
				border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
			),
			child: Row(
				children: [
					Icon(icon, color: Colors.white, size: responsive.text(13)),
					SizedBox(width: responsive.w(5)),
					Text(
						label,
						style: TextStyle(
							color: Colors.white,
							fontSize: responsive.text(12),
							fontFamily: 'Inter',
							fontWeight: FontWeight.w600,
						),
					),
				],
			),
		);
	}
}

// ── Section Title ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
	const _SectionTitle({required this.responsive, required this.title});
	final AppResponsive responsive;
	final String title;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Container(width: responsive.w(4), height: responsive.h(18), color: AppColors.primary),
				SizedBox(width: responsive.w(10)),
				Text(title, style: AppTextStyles.h6(responsive).copyWith(fontWeight: FontWeight.w700)),
			],
		);
	}
}

// ── Promise Card ───────────────────────────────────────────────────────────

class _PromiseCard extends StatelessWidget {
	const _PromiseCard({
		required this.responsive,
		required this.icon,
		required this.iconColor,
		required this.title,
		required this.body,
	});
	final AppResponsive responsive;
	final IconData icon;
	final Color iconColor;
	final String title;
	final String body;

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
				shadows: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
			),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						width: responsive.w(46),
						height: responsive.w(46),
						decoration: BoxDecoration(
							color: iconColor.withValues(alpha: 0.10),
							borderRadius: BorderRadius.circular(12),
						),
						child: Icon(icon, color: iconColor, size: responsive.text(22)),
					),
					SizedBox(width: responsive.w(14)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(title, style: AppTextStyles.subtitle(responsive).copyWith(fontWeight: FontWeight.w700)),
								SizedBox(height: responsive.h(5)),
								Text(
									body,
									style: AppTextStyles.body(responsive).copyWith(
										color: AppColors.textSecondary,
										height: 1.55,
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

// ── Rights Card ────────────────────────────────────────────────────────────

class _RightsCard extends StatelessWidget {
	const _RightsCard({required this.responsive});
	final AppResponsive responsive;

	static const _rights = [
		_Right(
			icon: Icons.cancel_rounded,
			color: Color(0xFFEF4444),
			title: 'Droit d\'annulation sans frais',
			body: 'Vous pouvez annuler votre réservation jusqu\'à 1 heure avant le départ sans aucuns frais.',
		),
		_Right(
			icon: Icons.account_balance_wallet_rounded,
			color: Color(0xFF00A86B),
			title: 'Droit au remboursement complet',
			body: 'Si le conducteur est absent ou annule, vous êtes intégralement remboursé(e), sans démarche complexe.',
		),
		_Right(
			icon: Icons.security_rounded,
			color: Color(0xFF3B82F6),
			title: 'Droit à un trajet sûr',
			body: 'Vous pouvez signaler tout problème de sécurité pendant ou après le trajet. Nous prenons chaque signalement au sérieux.',
		),
		_Right(
			icon: Icons.privacy_tip_rounded,
			color: Color(0xFF8B5CF6),
			title: 'Droit à la protection de vos données',
			body: 'Vos informations personnelles ne sont jamais partagées avec des tiers sans votre consentement explicite.',
		),
	];

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
				shadows: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
			),
			child: Column(
				children: _rights.asMap().entries.map((e) {
					final right = e.value;
					final isLast = e.key == _rights.length - 1;
					return Column(
						children: [
							Row(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Container(
										width: responsive.w(38),
										height: responsive.w(38),
										decoration: BoxDecoration(
											color: right.color.withValues(alpha: 0.10),
											borderRadius: BorderRadius.circular(10),
										),
										child: Icon(right.icon, color: right.color, size: responsive.text(18)),
									),
									SizedBox(width: responsive.w(12)),
									Expanded(
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													right.title,
													style: AppTextStyles.caption(responsive).copyWith(
														fontWeight: FontWeight.w700,
														color: AppColors.textPrimary,
													),
												),
												SizedBox(height: responsive.h(3)),
												Text(
													right.body,
													style: AppTextStyles.caption(responsive).copyWith(
														color: AppColors.textSecondary,
														height: 1.5,
													),
												),
											],
										),
									),
								],
							),
							if (!isLast) ...[
								SizedBox(height: responsive.h(12)),
								const Divider(color: AppColors.border, height: 1),
								SizedBox(height: responsive.h(12)),
							],
						],
					);
				}).toList(),
			),
		);
	}
}

class _Right {
	final IconData icon;
	final Color color;
	final String title;
	final String body;
	const _Right({required this.icon, required this.color, required this.title, required this.body});
}

// ── Verification Steps ─────────────────────────────────────────────────────

class _VerificationSteps extends StatelessWidget {
	const _VerificationSteps({required this.responsive});
	final AppResponsive responsive;

	static const _steps = [
		_Step(label: 'Vérification de l\'identité', detail: 'Copie de la pièce d\'identité nationale (CIN) validée par notre équipe.'),
		_Step(label: 'Permis de conduire valide', detail: 'Permis vérifié et en cours de validité. Catégorie adaptée au véhicule utilisé.'),
		_Step(label: 'Inspection du véhicule', detail: 'Photos du véhicule examinées. Immatriculation et assurance vérifiées.'),
		_Step(label: 'Évaluation par la communauté', detail: 'Note minimale requise pour rester actif sur la plateforme. Zéro tolérance pour les abus.'),
	];

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
				shadows: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
			),
			child: Column(
				children: _steps.asMap().entries.map((e) {
					final step = e.value;
					final index = e.key;
					final isLast = index == _steps.length - 1;
					return IntrinsicHeight(
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Column(
									children: [
										Container(
											width: responsive.w(32),
											height: responsive.w(32),
											decoration: const BoxDecoration(
												shape: BoxShape.circle,
												color: AppColors.primary,
											),
											child: Center(
												child: Text(
													'${index + 1}',
													style: TextStyle(
														color: Colors.white,
														fontSize: responsive.text(13),
														fontFamily: 'Inter',
														fontWeight: FontWeight.w800,
													),
												),
											),
										),
										if (!isLast)
											Expanded(
												child: Container(
													width: 2,
													margin: EdgeInsets.symmetric(vertical: responsive.h(4)),
													decoration: BoxDecoration(
														color: AppColors.primary.withValues(alpha: 0.25),
														borderRadius: BorderRadius.circular(9999),
													),
												),
											),
									],
								),
								SizedBox(width: responsive.w(14)),
								Expanded(
									child: Padding(
										padding: EdgeInsets.only(bottom: isLast ? 0 : responsive.h(16), top: responsive.h(4)),
										child: Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(
													step.label,
													style: AppTextStyles.subtitle(responsive).copyWith(fontWeight: FontWeight.w600),
												),
												SizedBox(height: responsive.h(3)),
												Text(
													step.detail,
													style: AppTextStyles.body(responsive).copyWith(
														color: AppColors.textSecondary,
														height: 1.5,
													),
												),
											],
										),
									),
								),
							],
						),
					);
				}).toList(),
			),
		);
	}
}

class _Step {
	final String label;
	final String detail;
	const _Step({required this.label, required this.detail});
}

// ── Stats Card ─────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
	const _StatsCard({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(20)),
			decoration: ShapeDecoration(
				color: const Color(0xFFF0FDF8),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Color(0x3300A86B)),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Column(
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Icon(Icons.star_rounded, color: AppColors.warning, size: responsive.text(16)),
							SizedBox(width: responsive.w(6)),
							Text(
								'MINIZON en chiffres',
								style: AppTextStyles.subtitle(responsive).copyWith(
									color: AppColors.primary,
									fontWeight: FontWeight.w700,
								),
							),
						],
					),
					SizedBox(height: responsive.h(16)),
					Row(
						children: [
							_Stat(responsive: responsive, value: '1 200+', label: 'Conducteurs\nvérifiés'),
							_StatDivider(),
							_Stat(responsive: responsive, value: '98%', label: 'Taux de\nsatisfaction'),
							_StatDivider(),
							_Stat(responsive: responsive, value: '24h', label: 'Délai\nremboursement'),
						],
					),
				],
			),
		);
	}
}

class _Stat extends StatelessWidget {
	const _Stat({required this.responsive, required this.value, required this.label});
	final AppResponsive responsive;
	final String value;
	final String label;

	@override
	Widget build(BuildContext context) {
		return Expanded(
			child: Column(
				children: [
					Text(
						value,
						style: TextStyle(
							color: AppColors.primary,
							fontSize: responsive.text(22),
							fontFamily: 'Inter',
							fontWeight: FontWeight.w800,
							letterSpacing: -0.5,
						),
					),
					SizedBox(height: responsive.h(4)),
					Text(
						label,
						style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary, height: 1.4),
						textAlign: TextAlign.center,
					),
				],
			),
		);
	}
}

class _StatDivider extends StatelessWidget {
	@override
	Widget build(BuildContext context) {
		return Container(width: 1, height: 40, color: const Color(0x3300A86B));
	}
}

// ── Quick Actions Row ──────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
	const _QuickActionsRow({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final TrustHubController controller;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				_QuickBtn(
					responsive: responsive,
					icon: Icons.shield_rounded,
					label: 'Sécurité',
					color: const Color(0xFFEF4444),
					onTap: controller.goToSafety,
				),
				SizedBox(width: responsive.w(10)),
				_QuickBtn(
					responsive: responsive,
					icon: Icons.headset_mic_rounded,
					label: 'Support',
					color: AppColors.primary,
					onTap: controller.goToSupport,
				),
				SizedBox(width: responsive.w(10)),
				_QuickBtn(
					responsive: responsive,
					icon: Icons.account_balance_wallet_rounded,
					label: 'Remboursement',
					color: AppColors.blue,
					onTap: controller.goToRefund,
				),
			],
		);
	}
}

class _QuickBtn extends StatelessWidget {
	const _QuickBtn({required this.responsive, required this.icon, required this.label, required this.color, required this.onTap});
	final AppResponsive responsive;
	final IconData icon;
	final String label;
	final Color color;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return Expanded(
			child: GestureDetector(
				onTap: onTap,
				child: Container(
					padding: EdgeInsets.symmetric(vertical: responsive.h(14)),
					decoration: ShapeDecoration(
						color: AppColors.white,
						shape: RoundedRectangleBorder(
							side: BorderSide(color: color.withValues(alpha: 0.25)),
							borderRadius: BorderRadius.circular(responsive.radius(14)),
						),
						shadows: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
					),
					child: Column(
						children: [
							Container(
								width: responsive.w(40),
								height: responsive.w(40),
								decoration: BoxDecoration(
									color: color.withValues(alpha: 0.10),
									shape: BoxShape.circle,
								),
								child: Icon(icon, color: color, size: responsive.text(20)),
							),
							SizedBox(height: responsive.h(8)),
							Text(
								label,
								style: AppTextStyles.caption(responsive).copyWith(
									fontWeight: FontWeight.w600,
									color: AppColors.textSecondary,
								),
								textAlign: TextAlign.center,
							),
						],
					),
				),
			),
		);
	}
}

// ── Engagement Footer ──────────────────────────────────────────────────────

class _EngagementFooter extends StatelessWidget {
	const _EngagementFooter({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: BoxDecoration(
				color: AppColors.surfaceMuted,
				borderRadius: BorderRadius.circular(responsive.radius(16)),
				border: Border.all(color: AppColors.border),
			),
			child: Row(
				children: [
					Text('💚', style: TextStyle(fontSize: responsive.text(22))),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Text(
							'MINIZON s\'engage à ce que chaque passager arrive à destination en toute sécurité, quoi qu\'il arrive.',
							style: AppTextStyles.body(responsive).copyWith(
								color: AppColors.textSecondary,
								height: 1.55,
								fontStyle: FontStyle.italic,
							),
						),
					),
				],
			),
		);
	}
}

// ── Shared ─────────────────────────────────────────────────────────────────

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

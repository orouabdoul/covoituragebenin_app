import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/payment_success_controller.dart';

class PaymentSuccessView extends StatelessWidget {
	const PaymentSuccessView({super.key});

	@override
	Widget build(BuildContext context) {
		final PaymentSuccessController controller =
				Get.isRegistered<PaymentSuccessController>()
						? Get.find<PaymentSuccessController>()
						: Get.put(PaymentSuccessController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.white,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: ListView(
							padding: EdgeInsets.fromLTRB(
								responsive.adaptive(phone: 24, smallPhone: 20, tablet: 32, desktop: 48),
								responsive.h(24),
								responsive.adaptive(phone: 24, smallPhone: 20, tablet: 32, desktop: 48),
								responsive.h(40),
							),
							children: [
								_SuccessHero(responsive: responsive),
								SizedBox(height: responsive.h(32)),
								_AmountDisplay(responsive: responsive, controller: controller),
								SizedBox(height: responsive.h(28)),
								_TripDetailsCard(responsive: responsive, controller: controller),
								SizedBox(height: responsive.h(20)),
								_DriverContactCard(responsive: responsive, controller: controller),
								SizedBox(height: responsive.h(20)),
								_NextStepsCard(responsive: responsive),
								SizedBox(height: responsive.h(20)),
								_ShareArrivalTile(responsive: responsive),
								SizedBox(height: responsive.h(20)),
								_TrustBadge(responsive: responsive),
								SizedBox(height: responsive.h(24)),
								AppPrimaryButton(
									responsive: responsive,
									label: 'Voir mes réservations',
									onTap: controller.goToReservations,
									backgroundColor: AppColors.primary,
									textColor: Colors.white,
									height: responsive.h(56),
									borderRadius: responsive.radius(16),
								),
								SizedBox(height: responsive.h(12)),
								AppPrimaryButton(
									responsive: responsive,
									label: 'Retour à l\'accueil',
									onTap: controller.goHome,
									backgroundColor: Colors.white,
									textColor: AppColors.textSecondary,
									borderColor: AppColors.border,
									height: responsive.h(56),
									borderRadius: responsive.radius(16),
								),
							],
						),
					),
				),
			),
		);
	}
}

// ── Hero Section ───────────────────────────────────────────────────────────

class _SuccessHero extends StatefulWidget {
	const _SuccessHero({required this.responsive});

	final AppResponsive responsive;

	@override
	State<_SuccessHero> createState() => _SuccessHeroState();
}

class _SuccessHeroState extends State<_SuccessHero> with SingleTickerProviderStateMixin {
	late AnimationController _ctrl;
	late Animation<double> _scale;
	late Animation<double> _opacity;

	@override
	void initState() {
		super.initState();
		_ctrl = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
		_scale = Tween<double>(begin: 0.5, end: 1.0).animate(
			CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
		);
		_opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
			CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
		);
		_ctrl.forward();
	}

	@override
	void dispose() {
		_ctrl.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final size = widget.responsive.w(120);

		return AnimatedBuilder(
			animation: _ctrl,
			builder: (_, _) => Opacity(
				opacity: _opacity.value,
				child: Center(
					child: Column(
						children: [
							Transform.scale(
								scale: _scale.value,
								child: Stack(
									alignment: Alignment.center,
									children: [
										Container(
											width: size,
											height: size,
											decoration: BoxDecoration(
												shape: BoxShape.circle,
												color: const Color(0x1400A86B),
											),
										),
										Container(
											width: size * 0.78,
											height: size * 0.78,
											decoration: BoxDecoration(
												shape: BoxShape.circle,
												color: const Color(0x2A00A86B),
											),
										),
										Container(
											width: size * 0.58,
											height: size * 0.58,
											decoration: const BoxDecoration(
												shape: BoxShape.circle,
												color: AppColors.primary,
											),
											child: Icon(
												Icons.check_rounded,
												color: Colors.white,
												size: size * 0.30,
											),
										),
									],
								),
							),
							SizedBox(height: widget.responsive.h(20)),
							Text(
								'Paiement confirmé !',
								style: AppTextStyles.h6(widget.responsive).copyWith(
									fontSize: widget.responsive.text(22),
									color: AppColors.primary,
								),
							),
							SizedBox(height: widget.responsive.h(6)),
							Text(
								'Votre place est réservée',
								style: AppTextStyles.body(widget.responsive).copyWith(color: AppColors.textHint),
							),
						],
					),
				),
			),
		);
	}
}

// ── Amount Display ─────────────────────────────────────────────────────────

class _AmountDisplay extends StatelessWidget {
	const _AmountDisplay({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final PaymentSuccessController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() => Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(20)),
			decoration: ShapeDecoration(
				color: const Color(0x0C00A86B),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Color(0x3300A86B)),
					borderRadius: BorderRadius.circular(responsive.radius(20)),
				),
			),
			child: Column(
				children: [
					Text(
						controller.formattedAmount,
						style: TextStyle(
							color: AppColors.primary,
							fontSize: responsive.text(32),
							fontFamily: 'Inter',
							fontWeight: FontWeight.w800,
							letterSpacing: -1.0,
						),
					),
					SizedBox(height: responsive.h(4)),
					Text(
						'payés avec succès',
						style: AppTextStyles.body(responsive).copyWith(color: AppColors.primary.withValues(alpha: 0.75)),
					),
					SizedBox(height: responsive.h(12)),
					Container(
						padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(6)),
						decoration: ShapeDecoration(
							color: AppColors.white,
							shape: RoundedRectangleBorder(
								side: const BorderSide(color: Color(0x3300A86B)),
								borderRadius: BorderRadius.circular(9999),
							),
						),
						child: Text(
							'Réf : ${controller.transactionRef.value}',
							style: AppTextStyles.caption(responsive).copyWith(
								color: AppColors.textSecondary,
								fontWeight: FontWeight.w600,
								fontFamily: 'monospace',
							),
						),
					),
				],
			),
		));
	}
}

// ── Trip Details Card ──────────────────────────────────────────────────────

class _TripDetailsCard extends StatelessWidget {
	const _TripDetailsCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final PaymentSuccessController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final ride = controller.ride.value;
			final origin = ride?.origin ?? 'Cotonou';
			final destination = ride?.destination ?? 'Porto-Novo';
			final time = ride?.departureTime ?? '—';
			final driver = ride?.driverName ?? 'Votre conducteur';
			final vehicle = ride?.vehicle ?? '—';
			final seats = controller.reservedSeats.value;

			return Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.w(20)),
				decoration: ShapeDecoration(
					color: AppColors.white,
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: AppColors.border),
						borderRadius: BorderRadius.circular(responsive.radius(20)),
					),
					shadows: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 2))],
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Text('Détails du trajet', style: AppTextStyles.h6(responsive)),
						SizedBox(height: responsive.h(16)),
						_DetailRow(
							responsive: responsive,
							icon: Icons.place_rounded,
							iconColor: AppColors.primary,
							label: 'Trajet',
							value: '$origin  →  $destination',
						),
						_Divider(responsive: responsive),
						_DetailRow(
							responsive: responsive,
							icon: Icons.schedule_rounded,
							iconColor: AppColors.blue,
							label: 'Départ',
							value: time,
						),
						_Divider(responsive: responsive),
						_DetailRow(
							responsive: responsive,
							icon: Icons.person_rounded,
							iconColor: const Color(0xFF8B5CF6),
							label: 'Conducteur',
							value: driver,
						),
						_Divider(responsive: responsive),
						_DetailRow(
							responsive: responsive,
							icon: Icons.directions_car_rounded,
							iconColor: AppColors.warning,
							label: 'Véhicule',
							value: vehicle,
						),
						_Divider(responsive: responsive),
						_DetailRow(
							responsive: responsive,
							icon: Icons.people_alt_rounded,
							iconColor: const Color(0xFF06B6D4),
							label: 'Places réservées',
							value: '$seats place${seats > 1 ? 's' : ''}',
						),
					],
				),
			);
		});
	}
}

class _DetailRow extends StatelessWidget {
	const _DetailRow({
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
		return Padding(
			padding: EdgeInsets.symmetric(vertical: responsive.h(10)),
			child: Row(
				children: [
					Container(
						width: responsive.w(36),
						height: responsive.w(36),
						decoration: BoxDecoration(
							color: iconColor.withValues(alpha: 0.10),
							borderRadius: BorderRadius.circular(10),
						),
						child: Icon(icon, size: responsive.text(16), color: iconColor),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(label, style: AppTextStyles.caption(responsive)),
								SizedBox(height: responsive.h(1)),
								Text(value, style: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600)),
							],
						),
					),
				],
			),
		);
	}
}

class _Divider extends StatelessWidget {
	const _Divider({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(height: 1, color: AppColors.border);
	}
}

// ── Next Steps ─────────────────────────────────────────────────────────────

class _NextStepsCard extends StatelessWidget {
	const _NextStepsCard({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(20)),
			decoration: ShapeDecoration(
				color: const Color(0xFFFFFBEB),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Color(0xFFFDE68A)),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Icon(Icons.tips_and_updates_rounded, size: responsive.text(18), color: const Color(0xFFF59E0B)),
							SizedBox(width: responsive.w(8)),
							Text(
								'Prochaines étapes',
								style: AppTextStyles.subtitle(responsive).copyWith(color: const Color(0xFF92400E)),
							),
						],
					),
					SizedBox(height: responsive.h(12)),
					_StepItem(
						responsive: responsive,
						number: '1',
						text: 'Rendez-vous au point de prise en charge à l\'heure indiquée.',
					),
					SizedBox(height: responsive.h(8)),
					_StepItem(
						responsive: responsive,
						number: '2',
						text: 'Vous recevrez une notification quand le conducteur est en route.',
					),
					SizedBox(height: responsive.h(8)),
					_StepItem(
						responsive: responsive,
						number: '3',
						text: 'Bon voyage ! N\'oubliez pas d\'évaluer votre conducteur à l\'arrivée.',
					),
				],
			),
		);
	}
}

// ── Share Arrival Tile ─────────────────────────────────────────────────────

class _ShareArrivalTile extends StatefulWidget {
	const _ShareArrivalTile({required this.responsive});
	final AppResponsive responsive;

	@override
	State<_ShareArrivalTile> createState() => _ShareArrivalTileState();
}

class _ShareArrivalTileState extends State<_ShareArrivalTile> {
	bool _sharing = false;

	@override
	Widget build(BuildContext context) {
		final responsive = widget.responsive;
		return AnimatedContainer(
			duration: AppResponsive.fastDuration,
			padding: EdgeInsets.all(responsive.w(14)),
			decoration: ShapeDecoration(
				color: _sharing ? const Color(0xFFF0FDF8) : AppColors.white,
				shape: RoundedRectangleBorder(
					side: BorderSide(color: _sharing ? const Color(0x3300A86B) : AppColors.border),
					borderRadius: BorderRadius.circular(14),
				),
			),
			child: Row(
				children: [
					Container(
						width: responsive.w(40),
						height: responsive.w(40),
						decoration: BoxDecoration(
							color: (_sharing ? AppColors.primary : AppColors.textSecondary).withValues(alpha: 0.10),
							shape: BoxShape.circle,
						),
						child: Icon(
							Icons.share_location_rounded,
							color: _sharing ? AppColors.primary : AppColors.textSecondary,
							size: responsive.text(20),
						),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Partager mon arrivée',
									style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w700),
								),
								SizedBox(height: responsive.h(2)),
								Text(
									_sharing
											? 'Vos proches seront notifiés à votre arrivée ✓'
											: 'Prévenez un proche que vous voyagez en sécurité',
									style: AppTextStyles.caption(responsive).copyWith(
										color: _sharing ? AppColors.primary : AppColors.textHint,
										fontSize: responsive.text(11),
										height: 1.4,
									),
								),
							],
						),
					),
					SizedBox(width: responsive.w(8)),
					Switch(
						value: _sharing,
						onChanged: (v) => setState(() => _sharing = v),
						activeThumbColor: AppColors.primary,
					),
				],
			),
		);
	}
}

// ── Trust Badge ────────────────────────────────────────────────────────────

class _TrustBadge extends StatelessWidget {
	const _TrustBadge({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.center,
			children: [
				Icon(Icons.shield_rounded, color: AppColors.primary, size: responsive.text(14)),
				SizedBox(width: responsive.w(6)),
				Text(
					'Trajet protégé MINIZON · Paiement 100% sécurisé',
					style: AppTextStyles.caption(responsive).copyWith(
						color: AppColors.textHint,
						fontSize: responsive.text(11),
					),
				),
			],
		);
	}
}

// ── Driver Contact Card ────────────────────────────────────────────────────

class _DriverContactCard extends StatelessWidget {
	const _DriverContactCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final PaymentSuccessController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final driverName = controller.ride.value?.driverName ?? 'Votre conducteur';

			return Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.w(20)),
				decoration: ShapeDecoration(
					color: const Color(0xFFF0FDF8),
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: Color(0x3300A86B)),
						borderRadius: BorderRadius.circular(responsive.radius(16)),
					),
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								Icon(Icons.support_agent_rounded, size: responsive.text(18), color: AppColors.primary),
								SizedBox(width: responsive.w(8)),
								Expanded(
									child: Text(
										'Contacter $driverName',
										style: AppTextStyles.subtitle(responsive),
										overflow: TextOverflow.ellipsis,
									),
								),
							],
						),
						SizedBox(height: responsive.h(4)),
						Text(
							'Besoin de précisions sur le point de rencontre ?',
							style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
						),
						SizedBox(height: responsive.h(16)),
						Row(
							children: [
								Expanded(
									child: _ContactButton(
										responsive: responsive,
										icon: Icons.phone_rounded,
										label: 'Appeler',
										color: AppColors.primary,
										onTap: controller.callDriver,
									),
								),
								SizedBox(width: responsive.w(12)),
								Expanded(
									child: _ContactButton(
										responsive: responsive,
										icon: Icons.chat_bubble_outline_rounded,
										label: 'Message',
										color: AppColors.blue,
										onTap: controller.messageDriver,
									),
								),
							],
						),
					],
				),
			);
		});
	}
}

class _ContactButton extends StatelessWidget {
	const _ContactButton({
		required this.responsive,
		required this.icon,
		required this.label,
		required this.color,
		required this.onTap,
	});

	final AppResponsive responsive;
	final IconData icon;
	final String label;
	final Color color;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return GestureDetector(
			onTap: onTap,
			child: Container(
				padding: EdgeInsets.symmetric(vertical: responsive.h(12)),
				decoration: ShapeDecoration(
					color: color.withValues(alpha: 0.10),
					shape: RoundedRectangleBorder(
						side: BorderSide(color: color.withValues(alpha: 0.25)),
						borderRadius: BorderRadius.circular(responsive.radius(12)),
					),
				),
				child: Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(icon, color: color, size: responsive.text(18)),
						SizedBox(width: responsive.w(6)),
						Text(
							label,
							style: AppTextStyles.body(responsive).copyWith(
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

// ── Step Item ──────────────────────────────────────────────────────────────

class _StepItem extends StatelessWidget {
	const _StepItem({required this.responsive, required this.number, required this.text});

	final AppResponsive responsive;
	final String number;
	final String text;

	@override
	Widget build(BuildContext context) {
		return Row(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Container(
					width: responsive.w(20),
					height: responsive.w(20),
					decoration: const BoxDecoration(
						shape: BoxShape.circle,
						color: Color(0xFFF59E0B),
					),
					child: Center(
						child: Text(
							number,
							style: TextStyle(
								color: Colors.white,
								fontSize: responsive.text(11),
								fontWeight: FontWeight.w700,
								fontFamily: 'Inter',
							),
						),
					),
				),
				SizedBox(width: responsive.w(10)),
				Expanded(
					child: Text(
						text,
						style: AppTextStyles.body(responsive).copyWith(
							color: const Color(0xFF78350F),
							height: 1.5,
						),
					),
				),
			],
		);
	}
}

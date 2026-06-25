import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/safety_controller.dart';

class SafetyView extends StatelessWidget {
	const SafetyView({super.key});

	@override
	Widget build(BuildContext context) {
		final SafetyController controller =
				Get.isRegistered<SafetyController>()
						? Get.find<SafetyController>()
						: Get.put(SafetyController());
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
										padding: EdgeInsets.symmetric(
											horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
										),
										children: [
											SizedBox(height: responsive.h(16)),
											_SOSSection(
												responsive: responsive,
												controller: controller,
												context: context,
											),
											SizedBox(height: responsive.h(20)),
											_ShareTripCard(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(16)),
											_EmergencyContactsCard(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(16)),
											_SafetyTipsCard(responsive: responsive),
											SizedBox(height: responsive.h(24)),
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
							Text('Sécurité', style: AppTextStyles.title(responsive)),
							Text(
								'Votre protection en trajet',
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary),
							),
						],
					),
					const Spacer(),
					Container(
						width: responsive.w(40),
						height: responsive.w(40),
						decoration: BoxDecoration(
							color: const Color(0x1AEF4444),
							shape: BoxShape.circle,
						),
						child: Icon(Icons.shield_rounded, color: const Color(0xFFEF4444), size: responsive.text(20)),
					),
				],
			),
		);
	}
}

// ── SOS Section ────────────────────────────────────────────────────────────

class _SOSSection extends StatelessWidget {
	const _SOSSection({
		required this.responsive,
		required this.controller,
		required this.context,
	});

	final AppResponsive responsive;
	final SafetyController controller;
	final BuildContext context;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final activated = controller.sosActivated.value;

			return Column(
				children: [
					// Status banner
					if (activated)
						Container(
							width: double.infinity,
							padding: EdgeInsets.symmetric(
								horizontal: responsive.w(16),
								vertical: responsive.h(10),
							),
							margin: EdgeInsets.only(bottom: responsive.h(16)),
							decoration: BoxDecoration(
								color: const Color(0xFFEF4444),
								borderRadius: BorderRadius.circular(responsive.radius(12)),
							),
							child: Row(
								children: [
									const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
									SizedBox(width: responsive.w(8)),
									Expanded(
										child: Text(
											'SOS activé — Vos contacts ont été alertés',
											style: AppTextStyles.caption(responsive).copyWith(
												color: Colors.white,
												fontWeight: FontWeight.w700,
											),
										),
									),
								],
							),
						),

					// Big SOS button
					GestureDetector(
						onTap: activated
								? controller.cancelSOS
								: () => controller.showSOSConfirm(context),
						child: _PulsingSOSButton(
							responsive: responsive,
							activated: activated,
						),
					),

					SizedBox(height: responsive.h(10)),
					Text(
						activated
								? 'Appuyez pour annuler l\'alerte SOS'
								: 'Appuyez longuement en cas de danger',
						style: AppTextStyles.caption(responsive).copyWith(
							color: activated ? const Color(0xFFEF4444) : AppColors.textHint,
						),
						textAlign: TextAlign.center,
					),
				],
			);
		});
	}
}

class _PulsingSOSButton extends StatefulWidget {
	const _PulsingSOSButton({required this.responsive, required this.activated});
	final AppResponsive responsive;
	final bool activated;

	@override
	State<_PulsingSOSButton> createState() => _PulsingSOSButtonState();
}

class _PulsingSOSButtonState extends State<_PulsingSOSButton>
		with SingleTickerProviderStateMixin {
	late AnimationController _anim;
	late Animation<double> _scale;

	@override
	void initState() {
		super.initState();
		_anim = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 900),
		)..repeat(reverse: true);
		_scale = Tween<double>(begin: 0.95, end: 1.05).animate(
			CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
		);
	}

	@override
	void dispose() {
		_anim.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final r = widget.responsive;
		final activated = widget.activated;
		final color = activated ? const Color(0xFFDC2626) : const Color(0xFFEF4444);
		final size = r.w(140);

		return AnimatedBuilder(
			animation: _anim,
			builder: (_, _) {
				return Stack(
					alignment: Alignment.center,
					children: [
						// Pulse rings (only when activated)
						if (activated) ...[
							Transform.scale(
								scale: 1.0 + _scale.value * 0.2,
								child: Container(
									width: size + r.w(40),
									height: size + r.w(40),
									decoration: BoxDecoration(
										shape: BoxShape.circle,
										color: const Color(0xFFEF4444).withValues(alpha: 0.08 * _scale.value),
									),
								),
							),
							Container(
								width: size + r.w(20),
								height: size + r.w(20),
								decoration: BoxDecoration(
									shape: BoxShape.circle,
									color: const Color(0xFFEF4444).withValues(alpha: 0.12),
								),
							),
						],

						// Main button
						Container(
							width: size,
							height: size,
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								color: color,
								boxShadow: [
									BoxShadow(
										color: color.withValues(alpha: 0.35),
										blurRadius: 24,
										spreadRadius: 4,
									),
								],
							),
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: [
									Icon(
										activated ? Icons.cancel_rounded : Icons.sos_rounded,
										color: Colors.white,
										size: r.text(40),
									),
									SizedBox(height: r.h(4)),
									Text(
										activated ? 'ANNULER' : 'SOS',
										style: TextStyle(
											color: Colors.white,
											fontFamily: 'Inter',
											fontWeight: FontWeight.w900,
											fontSize: r.text(activated ? 12 : 22),
											letterSpacing: 2,
										),
									),
								],
							),
						),
					],
				);
			},
		);
	}
}

// ── Share Trip Card ─────────────────────────────────────────────────────────

class _ShareTripCard extends StatelessWidget {
	const _ShareTripCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SafetyController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final sharing = controller.isSharingTrip.value;
			return _Card(
				responsive: responsive,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								Container(
									width: responsive.w(44),
									height: responsive.w(44),
									decoration: BoxDecoration(
										color: const Color(0x1900A86B),
										borderRadius: BorderRadius.circular(12),
									),
									child: Icon(Icons.share_location_rounded, color: AppColors.primary, size: responsive.text(22)),
								),
								SizedBox(width: responsive.w(14)),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text('Partager mon trajet', style: AppTextStyles.h6(responsive)),
											Text(
												sharing ? 'Suivi en temps réel actif' : 'Envoyez votre position à un proche',
												style: AppTextStyles.caption(responsive),
											),
										],
									),
								),
								if (sharing)
									Container(
										padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(3)),
										decoration: BoxDecoration(
											color: const Color(0x1900A86B),
											borderRadius: BorderRadius.circular(9999),
										),
										child: Text(
											'ACTIF',
											style: AppTextStyles.caption(responsive).copyWith(
												color: AppColors.primary,
												fontWeight: FontWeight.w700,
												fontSize: responsive.text(10),
											),
										),
									),
							],
						),

						if (sharing) ...[
							SizedBox(height: responsive.h(14)),
							Container(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(10)),
								decoration: BoxDecoration(
									color: AppColors.surfaceMuted,
									borderRadius: BorderRadius.circular(responsive.radius(10)),
									border: Border.all(color: AppColors.border),
								),
								child: Row(
									children: [
										Expanded(
											child: Text(
												'minizon.bj/track/${controller.shareCode.value}',
												style: AppTextStyles.caption(responsive).copyWith(
													fontFamily: 'monospace',
													color: AppColors.textMuted,
												),
												overflow: TextOverflow.ellipsis,
											),
										),
										SizedBox(width: responsive.w(8)),
										InkWell(
											onTap: controller.copyShareLink,
											borderRadius: BorderRadius.circular(6),
											child: Icon(Icons.copy_rounded, size: responsive.text(16), color: AppColors.primary),
										),
									],
								),
							),
							SizedBox(height: responsive.h(10)),
							Row(
								children: [
									Expanded(
										child: _OutlineBtn(
											responsive: responsive,
											label: 'Arrêter',
											color: const Color(0xFFEF4444),
											onTap: controller.stopSharing,
										),
									),
									SizedBox(width: responsive.w(10)),
									Expanded(
										child: _OutlineBtn(
											responsive: responsive,
											label: 'Copier le lien',
											color: AppColors.primary,
											onTap: controller.copyShareLink,
										),
									),
								],
							),
						] else ...[
							SizedBox(height: responsive.h(14)),
							SizedBox(
								width: double.infinity,
								child: ElevatedButton.icon(
									onPressed: controller.shareTrip,
									icon: const Icon(Icons.share_rounded, size: 16),
									label: Text(
										'Partager ce trajet',
										style: AppTextStyles.button(responsive).copyWith(fontSize: responsive.text(14)),
									),
									style: ElevatedButton.styleFrom(
										backgroundColor: AppColors.primary,
										foregroundColor: Colors.white,
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(responsive.radius(12))),
										padding: EdgeInsets.symmetric(vertical: responsive.h(12)),
										elevation: 0,
									),
								),
							),
						],
					],
				),
			);
		});
	}
}

// ── Emergency Contacts Card ────────────────────────────────────────────────

class _EmergencyContactsCard extends StatelessWidget {
	const _EmergencyContactsCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SafetyController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() => _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Container(
								width: responsive.w(44),
								height: responsive.w(44),
								decoration: BoxDecoration(
									color: const Color(0x1A3B82F6),
									borderRadius: BorderRadius.circular(12),
								),
								child: Icon(Icons.contacts_rounded, color: AppColors.blue, size: responsive.text(22)),
							),
							SizedBox(width: responsive.w(14)),
							Expanded(
								child: Text('Contacts d\'urgence', style: AppTextStyles.h6(responsive)),
							),
							InkWell(
								onTap: controller.addEmergencyContact,
								borderRadius: BorderRadius.circular(8),
								child: Container(
									padding: EdgeInsets.all(responsive.w(6)),
									decoration: BoxDecoration(
										color: const Color(0x1900A86B),
										borderRadius: BorderRadius.circular(8),
									),
									child: Icon(Icons.add_rounded, color: AppColors.primary, size: responsive.text(16)),
								),
							),
						],
					),
					SizedBox(height: responsive.h(14)),
					...controller.emergencyContacts.map((contact) => Padding(
						padding: EdgeInsets.only(bottom: responsive.h(8)),
						child: Row(
							children: [
								Container(
									width: responsive.w(40),
									height: responsive.w(40),
									decoration: BoxDecoration(
										color: const Color(0x1A3B82F6),
										shape: BoxShape.circle,
									),
									child: Center(
										child: Text(
											contact['initials']!,
											style: TextStyle(
												color: AppColors.blue,
												fontFamily: 'Inter',
												fontWeight: FontWeight.w700,
												fontSize: responsive.text(14),
											),
										),
									),
								),
								SizedBox(width: responsive.w(12)),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(contact['name']!, style: AppTextStyles.subtitle(responsive).copyWith(fontSize: responsive.text(14))),
											Text(contact['phone']!, style: AppTextStyles.caption(responsive)),
										],
									),
								),
								InkWell(
									onTap: () => controller.callEmergencyContact(contact['phone']!),
									borderRadius: BorderRadius.circular(9999),
									child: Container(
										padding: EdgeInsets.all(responsive.w(8)),
										decoration: BoxDecoration(
											color: const Color(0x1900A86B),
											shape: BoxShape.circle,
											border: Border.all(color: const Color(0x3300A86B)),
										),
										child: Icon(Icons.phone_rounded, color: AppColors.primary, size: responsive.text(16)),
									),
								),
							],
						),
					)),
				],
			),
		));
	}
}

// ── Safety Tips Card ────────────────────────────────────────────────────────

class _SafetyTipsCard extends StatelessWidget {
	const _SafetyTipsCard({required this.responsive});
	final AppResponsive responsive;

	static const _tips = [
		(Icons.verified_user_rounded, 'Vérifiez toujours l\'identité du conducteur avant de monter'),
		(Icons.share_location_rounded, 'Partagez votre trajet avec un proche'),
		(Icons.no_photography_rounded, 'Ne partagez pas d\'informations personnelles sensibles'),
		(Icons.support_agent_rounded, 'Contactez le support en cas de problème avec un conducteur'),
	];

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Container(
								width: responsive.w(44),
								height: responsive.w(44),
								decoration: BoxDecoration(
									color: const Color(0x1AF59E0B),
									borderRadius: BorderRadius.circular(12),
								),
								child: Icon(Icons.lightbulb_rounded, color: AppColors.warning, size: responsive.text(22)),
							),
							SizedBox(width: responsive.w(14)),
							Text('Conseils de sécurité', style: AppTextStyles.h6(responsive)),
						],
					),
					SizedBox(height: responsive.h(14)),
					..._tips.map((tip) => Padding(
						padding: EdgeInsets.only(bottom: responsive.h(10)),
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Container(
									margin: EdgeInsets.only(top: responsive.h(1)),
									width: responsive.w(28),
									height: responsive.w(28),
									decoration: BoxDecoration(
										color: const Color(0x1AF59E0B),
										borderRadius: BorderRadius.circular(7),
									),
									child: Icon(tip.$1, color: AppColors.warning, size: responsive.text(14)),
								),
								SizedBox(width: responsive.w(10)),
								Expanded(
									child: Text(
										tip.$2,
										style: AppTextStyles.body(responsive).copyWith(height: 1.5),
									),
								),
							],
						),
					)),
				],
			),
		);
	}
}

// ── Shared ──────────────────────────────────────────────────────────────────

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

class _OutlineBtn extends StatelessWidget {
	const _OutlineBtn({
		required this.responsive,
		required this.label,
		required this.color,
		required this.onTap,
	});
	final AppResponsive responsive;
	final String label;
	final Color color;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(responsive.radius(10)),
			child: Container(
				padding: EdgeInsets.symmetric(vertical: responsive.h(10)),
				decoration: ShapeDecoration(
					shape: RoundedRectangleBorder(
						side: BorderSide(color: color.withValues(alpha: 0.50)),
						borderRadius: BorderRadius.circular(responsive.radius(10)),
					),
				),
				child: Center(
					child: Text(
						label,
						style: AppTextStyles.caption(responsive).copyWith(
							color: color,
							fontWeight: FontWeight.w700,
						),
					),
				),
			),
		);
	}
}

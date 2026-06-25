import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import '../controllers/safety_center_controller.dart';

class SafetyCenterView extends StatelessWidget {
	const SafetyCenterView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<SafetyCenterController>()
				? Get.find<SafetyCenterController>()
				: Get.put(SafetyCenterController());
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
								Obx(() => controller.sosActivated.value
										? _SOSActiveBanner(responsive: responsive, controller: controller)
										: const SizedBox.shrink()),
								Expanded(
									child: ListView(
										padding: EdgeInsets.symmetric(
											horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
											vertical: responsive.h(20),
										),
										children: [
											_SOSButton(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(24)),
											_ShareTripCard(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(16)),
											_EmergencyServicesCard(responsive: responsive, controller: controller),
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
							Text('Centre de sécurité', style: AppTextStyles.title(responsive)),
							Text(
								'Votre sécurité est notre priorité',
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

// ── SOS Active Banner ──────────────────────────────────────────────────────

class _SOSActiveBanner extends StatelessWidget {
	const _SOSActiveBanner({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SafetyCenterController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				vertical: responsive.h(12),
			),
			color: const Color(0xFFDC2626),
			child: Row(
				children: [
					const Icon(Icons.warning_rounded, color: Colors.white, size: 20),
					SizedBox(width: responsive.w(10)),
					Expanded(
						child: Text(
							'Alerte SOS active — Vos contacts ont été notifiés',
							style: AppTextStyles.caption(responsive).copyWith(
								color: Colors.white,
								fontWeight: FontWeight.w600,
							),
						),
					),
					InkWell(
						onTap: controller.cancelSOS,
						borderRadius: BorderRadius.circular(8),
						child: Padding(
							padding: EdgeInsets.all(responsive.w(4)),
							child: Text(
								'Annuler',
								style: AppTextStyles.caption(responsive).copyWith(
									color: Colors.white,
									fontWeight: FontWeight.w700,
									decoration: TextDecoration.underline,
									decorationColor: Colors.white,
								),
							),
						),
					),
				],
			),
		);
	}
}

// ── SOS Button (animated) ──────────────────────────────────────────────────

class _SOSButton extends StatefulWidget {
	const _SOSButton({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SafetyCenterController controller;

	@override
	State<_SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<_SOSButton> with SingleTickerProviderStateMixin {
	late final AnimationController _anim;
	late final Animation<double> _scale;
	late final Worker _worker;

	@override
	void initState() {
		super.initState();
		_anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
		_scale = Tween<double>(begin: 0.92, end: 1.0).animate(
			CurvedAnimation(parent: _anim, curve: Curves.easeInOut),
		);
		_worker = ever(widget.controller.sosActivated, (bool active) {
			if (active) {
				_anim.repeat(reverse: true);
			} else {
				_anim.stop();
				_anim.reset();
			}
		});
	}

	@override
	void dispose() {
		_worker.dispose();
		_anim.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Obx(() {
				final active = widget.controller.sosActivated.value;
				return GestureDetector(
					onTap: active ? widget.controller.cancelSOS : widget.controller.triggerSOS,
					child: AnimatedBuilder(
						animation: _anim,
						builder: (_, _) => Stack(
							alignment: Alignment.center,
							children: [
								// Outer pulse rings (only when active)
								if (active) ...[
									Container(
										width: widget.responsive.w(168),
										height: widget.responsive.w(168),
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											color: const Color(0xFFDC2626).withValues(alpha: 0.08 + 0.06 * _scale.value),
										),
									),
									Container(
										width: widget.responsive.w(140),
										height: widget.responsive.w(140),
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											color: const Color(0xFFDC2626).withValues(alpha: 0.14 + 0.06 * _scale.value),
										),
									),
								],
								// Main button
								Transform.scale(
									scale: active ? _scale.value : 1.0,
									child: Container(
										width: widget.responsive.w(112),
										height: widget.responsive.w(112),
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											color: active ? const Color(0xFFDC2626) : const Color(0xFFEF4444),
											boxShadow: [
												BoxShadow(
													color: const Color(0xFFDC2626).withValues(alpha: active ? 0.50 : 0.28),
													blurRadius: active ? 28 : 18,
													spreadRadius: active ? 6 : 0,
												),
											],
										),
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: [
												Icon(
													active ? Icons.cancel_rounded : Icons.sos_rounded,
													color: Colors.white,
													size: widget.responsive.text(34),
												),
												SizedBox(height: widget.responsive.h(4)),
												Text(
													active ? 'ANNULER' : 'SOS',
													style: TextStyle(
														color: Colors.white,
														fontSize: widget.responsive.text(active ? 11 : 15),
														fontFamily: 'Inter',
														fontWeight: FontWeight.w800,
														letterSpacing: 2.5,
													),
												),
											],
										),
									),
								),
							],
						),
					),
				);
			}),
		);
	}
}

// ── Share Trip Card ────────────────────────────────────────────────────────

class _ShareTripCard extends StatelessWidget {
	const _ShareTripCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SafetyCenterController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Obx(() {
				final sharing = controller.isSharingTrip.value;
				return Row(
					children: [
						Container(
							width: responsive.w(44),
							height: responsive.w(44),
							decoration: BoxDecoration(
								color: (sharing ? AppColors.primary : AppColors.textSecondary).withValues(alpha: 0.12),
								borderRadius: BorderRadius.circular(12),
							),
							child: Icon(
								Icons.share_location_rounded,
								color: sharing ? AppColors.primary : AppColors.textSecondary,
								size: responsive.text(22),
							),
						),
						SizedBox(width: responsive.w(14)),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Text('Partager mon trajet', style: AppTextStyles.subtitle(responsive)),
									SizedBox(height: responsive.h(2)),
									Text(
										sharing
												? 'Vos contacts suivent votre trajet en direct'
												: 'Partagez votre position avec vos proches',
										style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary, height: 1.4),
									),
								],
							),
						),
						SizedBox(width: responsive.w(12)),
						Switch(
							value: sharing,
							onChanged: (_) => controller.toggleShareTrip(),
							activeThumbColor: AppColors.primary,
						),
					],
				);
			}),
		);
	}
}

// ── Emergency Services Card ────────────────────────────────────────────────

class _EmergencyServicesCard extends StatelessWidget {
	const _EmergencyServicesCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SafetyCenterController controller;

	static const _services = [
		{'name': 'Police', 'number': '117', 'icon': Icons.local_police_rounded, 'color': 0xFF1D4ED8},
		{'name': 'SAMU', 'number': '13', 'icon': Icons.medical_services_rounded, 'color': 0xFFDC2626},
		{'name': 'Pompiers', 'number': '118', 'icon': Icons.local_fire_department_rounded, 'color': 0xFFF97316},
	];

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Services d\'urgence', style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(14)),
					Row(
						children: _services.map((s) {
							final color = Color(s['color'] as int);
							return Expanded(
								child: GestureDetector(
									onTap: () => controller.callService(s['name'] as String, s['number'] as String),
									child: Column(
										children: [
											Container(
												width: responsive.w(52),
												height: responsive.w(52),
												decoration: BoxDecoration(
													color: color.withValues(alpha: 0.12),
													shape: BoxShape.circle,
													border: Border.all(color: color.withValues(alpha: 0.25)),
												),
												child: Icon(s['icon'] as IconData, color: color, size: responsive.text(24)),
											),
											SizedBox(height: responsive.h(8)),
											Text(
												s['number'] as String,
												style: TextStyle(
													color: color,
													fontSize: responsive.text(16),
													fontFamily: 'Inter',
													fontWeight: FontWeight.w800,
												),
											),
											SizedBox(height: responsive.h(2)),
											Text(
												s['name'] as String,
												style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
											),
										],
									),
								),
							);
						}).toList(),
					),
				],
			),
		);
	}
}

// ── Emergency Contacts Card ────────────────────────────────────────────────

class _EmergencyContactsCard extends StatelessWidget {
	const _EmergencyContactsCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final SafetyCenterController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Text('Contacts d\'urgence', style: AppTextStyles.h6(responsive)),
							const Spacer(),
							InkWell(
								onTap: controller.addContact,
								borderRadius: BorderRadius.circular(8),
								child: Container(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(4)),
									decoration: BoxDecoration(
										color: AppColors.primary.withValues(alpha: 0.10),
										borderRadius: BorderRadius.circular(8),
									),
									child: Row(
										children: [
											Icon(Icons.add_rounded, color: AppColors.primary, size: responsive.text(14)),
											SizedBox(width: responsive.w(4)),
											Text('Ajouter', style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600)),
										],
									),
								),
							),
						],
					),
					SizedBox(height: responsive.h(14)),
					Obx(() {
						if (controller.emergencyContacts.isEmpty) {
							return Padding(
								padding: EdgeInsets.symmetric(vertical: responsive.h(12)),
								child: Text(
									'Aucun contact d\'urgence ajouté',
									style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
									textAlign: TextAlign.center,
								),
							);
						}
						return Column(
							children: List.generate(controller.emergencyContacts.length, (i) {
								final contact = controller.emergencyContacts[i];
								return Dismissible(
									key: ValueKey(contact.id),
									direction: DismissDirection.endToStart,
									background: Container(
										alignment: Alignment.centerRight,
										padding: EdgeInsets.only(right: responsive.w(16)),
										decoration: BoxDecoration(
											color: const Color(0xFFEF4444).withValues(alpha: 0.15),
											borderRadius: BorderRadius.circular(12),
										),
										child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
									),
									onDismissed: (_) => controller.removeContact(i),
									child: Container(
										margin: EdgeInsets.only(bottom: responsive.h(i < controller.emergencyContacts.length - 1 ? 10 : 0)),
										padding: EdgeInsets.all(responsive.w(12)),
										decoration: BoxDecoration(
											color: AppColors.surfaceMuted,
											borderRadius: BorderRadius.circular(12),
											border: Border.all(color: AppColors.border),
										),
										child: Row(
											children: [
												Container(
													width: responsive.w(40),
													height: responsive.w(40),
													decoration: BoxDecoration(
														color: AppColors.primary.withValues(alpha: 0.12),
														shape: BoxShape.circle,
													),
													child: Center(
														child: Text(
															contact.name.isNotEmpty ? contact.name[0].toUpperCase() : 'C',
															style: TextStyle(color: AppColors.primary, fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: responsive.text(16)),
														),
													),
												),
												SizedBox(width: responsive.w(12)),
												Expanded(
													child: Column(
														crossAxisAlignment: CrossAxisAlignment.start,
														children: [
															Text(contact.name, style: AppTextStyles.subtitle(responsive)),
															SizedBox(height: responsive.h(2)),
															Text(contact.phone, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary)),
														],
													),
												),
												Container(
													padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(3)),
													decoration: BoxDecoration(
														color: AppColors.surfaceMuted,
														borderRadius: BorderRadius.circular(9999),
														border: Border.all(color: AppColors.border),
													),
													child: Text(contact.relation, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
												),
											],
										),
									),
								);
							}),
						);
					}),
				],
			),
		);
	}
}

// ── Safety Tips Card ───────────────────────────────────────────────────────

class _SafetyTipsCard extends StatelessWidget {
	const _SafetyTipsCard({required this.responsive});
	final AppResponsive responsive;

	static const _tips = [
		'Vérifiez toujours que la plaque d\'immatriculation correspond à celle dans l\'application avant de monter.',
		'Partagez votre trajet avec un proche avant chaque voyage.',
		'Asseyez-vous à l\'arrière du véhicule pour plus de sécurité.',
		'En cas de danger immédiat, appelez le 117 (Police) ou utilisez le bouton SOS.',
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
							Icon(Icons.tips_and_updates_rounded, color: AppColors.warning, size: responsive.text(20)),
							SizedBox(width: responsive.w(8)),
							Text('Conseils de sécurité', style: AppTextStyles.h6(responsive)),
						],
					),
					SizedBox(height: responsive.h(14)),
					..._tips.asMap().entries.map((e) => Padding(
						padding: EdgeInsets.only(bottom: e.key < _tips.length - 1 ? responsive.h(12) : 0),
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Container(
									width: responsive.w(22),
									height: responsive.w(22),
									decoration: BoxDecoration(
										color: AppColors.primary.withValues(alpha: 0.12),
										shape: BoxShape.circle,
									),
									child: Center(
										child: Text(
											'${e.key + 1}',
											style: TextStyle(color: AppColors.primary, fontSize: responsive.text(11), fontFamily: 'Inter', fontWeight: FontWeight.w700),
										),
									),
								),
								SizedBox(width: responsive.w(10)),
								Expanded(
									child: Text(
										e.value,
										style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary, height: 1.5),
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

// ── Shared ─────────────────────────────────────────────────────────────────

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
				shadows: const [BoxShadow(color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))],
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

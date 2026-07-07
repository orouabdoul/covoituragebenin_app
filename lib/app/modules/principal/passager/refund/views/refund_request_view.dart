import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/principal/botton_nav/controllers/botton_nav_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/refund_request_controller.dart';

class RefundRequestView extends StatelessWidget {
	const RefundRequestView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<RefundRequestController>()
				? Get.find<RefundRequestController>()
				: Get.put(RefundRequestController());
		final responsive = AppResponsive(context);

		return Obx(() => Stack(
			children: [
				Scaffold(
					backgroundColor: AppColors.surface,
					body: SafeArea(
						child: Center(
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
								child: Obx(() => controller.submitted.value
										? _SuccessState(responsive: responsive, controller: controller)
										: Column(
												children: [
													_HeaderBar(responsive: responsive),
													Expanded(
														child: ListView(
															padding: EdgeInsets.symmetric(
																horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
																vertical: responsive.h(16),
															),
															children: [
																_TripCard(responsive: responsive, controller: controller),
																SizedBox(height: responsive.h(16)),
																_ReasonsCard(responsive: responsive, controller: controller),
																SizedBox(height: responsive.h(16)),
																_NoteCard(responsive: responsive, controller: controller),
																SizedBox(height: responsive.h(16)),
																_RefundSummaryCard(responsive: responsive, controller: controller),
																SizedBox(height: responsive.h(24)),
																AppPrimaryButton(
																	responsive: responsive,
																	label: 'Soumettre la demande',
																	onTap: controller.submitRequest,
																	height: responsive.h(56),
																	borderRadius: responsive.radius(16),
																),
																SizedBox(height: responsive.h(16)),
																Center(
																	child: Text(
																		'Traitement sous 5 à 7 jours ouvrables',
																		style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
																	),
																),
																SizedBox(height: responsive.h(16)),
															],
														),
													),
												],
											)),
							),
						),
					),
				),
				if (controller.isSubmitting.value)
					const _LoadingOverlay(),
			],
		));
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
							Text('Demande de remboursement', style: AppTextStyles.title(responsive)),
							Text(
								'Nous traitons votre demande rapidement',
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

// ── Trip Card ──────────────────────────────────────────────────────────────

class _TripCard extends StatelessWidget {
	const _TripCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundRequestController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Trajet concerné', style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(14)),
					Container(
						padding: EdgeInsets.all(responsive.w(14)),
						decoration: BoxDecoration(
							color: AppColors.surfaceMuted,
							borderRadius: BorderRadius.circular(12),
							border: Border.all(color: AppColors.border),
						),
						child: Column(
							children: [
								Obx(() => Row(
									children: [
										const _RouteDot(color: AppColors.primary, filled: true),
										SizedBox(width: responsive.w(10)),
										Expanded(
											child: Text(
												controller.tripRoute.value.split('→').first.trim(),
												style: AppTextStyles.subtitle(responsive),
											),
										),
									],
								)),
								Padding(
									padding: EdgeInsets.only(left: responsive.w(6)),
									child: Container(
										width: 2,
										height: responsive.h(18),
										color: AppColors.border,
									),
								),
								Obx(() => Row(
									children: [
										const _RouteDot(color: Color(0xFFEF4444), filled: false),
										SizedBox(width: responsive.w(10)),
										Expanded(
											child: Text(
												controller.tripRoute.value.contains('→')
														? controller.tripRoute.value.split('→').last.trim()
														: 'Destination',
												style: AppTextStyles.subtitle(responsive),
											),
										),
									],
								)),
								SizedBox(height: responsive.h(12)),
								Divider(color: AppColors.border, height: 1),
								SizedBox(height: responsive.h(12)),
								Obx(() => Row(
									children: [
										_InfoPill(
											icon: Icons.calendar_today_rounded,
											label: controller.tripDate.value,
											responsive: responsive,
										),
										SizedBox(width: responsive.w(8)),
										_InfoPill(
											icon: Icons.tag_rounded,
											label: controller.tripRef.value,
											responsive: responsive,
										),
									],
								)),
							],
						),
					),
				],
			),
		);
	}
}

class _RouteDot extends StatelessWidget {
	const _RouteDot({required this.color, required this.filled});
	final Color color;
	final bool filled;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: 14,
			height: 14,
			decoration: BoxDecoration(
				shape: BoxShape.circle,
				color: filled ? color : Colors.white,
				border: Border.all(color: color, width: 2),
			),
		);
	}
}

class _InfoPill extends StatelessWidget {
	const _InfoPill({required this.icon, required this.label, required this.responsive});
	final IconData icon;
	final String label;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(5)),
			decoration: BoxDecoration(
				color: AppColors.white,
				borderRadius: BorderRadius.circular(9999),
				border: Border.all(color: AppColors.border),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(icon, size: responsive.text(12), color: AppColors.textHint),
					SizedBox(width: responsive.w(4)),
					Text(label, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
				],
			),
		);
	}
}

// ── Reasons Card ───────────────────────────────────────────────────────────

class _ReasonsCard extends StatelessWidget {
	const _ReasonsCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundRequestController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Text('Motif du remboursement', style: AppTextStyles.h6(responsive)),
							SizedBox(width: responsive.w(4)),
							Text('*', style: TextStyle(color: const Color(0xFFEF4444), fontSize: responsive.text(14), fontWeight: FontWeight.w700)),
						],
					),
					SizedBox(height: responsive.h(14)),
					Obx(() => Column(
						children: controller.reasons.map((reason) {
							final selected = controller.selectedReason.value == reason.key;
							return GestureDetector(
								onTap: () => controller.selectReason(reason.key),
								child: AnimatedContainer(
									duration: AppResponsive.fastDuration,
									margin: EdgeInsets.only(bottom: responsive.h(8)),
									padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(12)),
									decoration: ShapeDecoration(
										color: selected ? const Color(0xFFF0FDF8) : AppColors.surfaceMuted,
										shape: RoundedRectangleBorder(
											side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
											borderRadius: BorderRadius.circular(12),
										),
									),
									child: Row(
										children: [
											AnimatedContainer(
												duration: AppResponsive.fastDuration,
												width: responsive.w(20),
												height: responsive.w(20),
												decoration: BoxDecoration(
													shape: BoxShape.circle,
													color: selected ? AppColors.primary : Colors.transparent,
													border: Border.all(
														color: selected ? AppColors.primary : AppColors.border,
														width: selected ? 0 : 2,
													),
												),
												child: selected
														? Icon(Icons.check_rounded, color: Colors.white, size: responsive.text(12))
														: null,
											),
											SizedBox(width: responsive.w(12)),
											Expanded(
												child: Text(
													reason.label,
													style: AppTextStyles.body(responsive).copyWith(
														color: selected ? AppColors.textPrimary : AppColors.textSecondary,
														fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
													),
												),
											),
										],
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

// ── Note Card ──────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
	const _NoteCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundRequestController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text(
						'Détails supplémentaires (optionnel)',
						style: AppTextStyles.h6(responsive),
					),
					SizedBox(height: responsive.h(12)),
					TextField(
						controller: controller.noteController,
						maxLines: 4,
						style: AppTextStyles.body(responsive),
						decoration: InputDecoration(
							hintText: 'Décrivez le problème en détail pour accélérer le traitement...',
							hintStyle: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint),
							filled: true,
							fillColor: AppColors.surfaceMuted,
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: const BorderSide(color: AppColors.border),
							),
							enabledBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: const BorderSide(color: AppColors.border),
							),
							focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(12),
								borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
							),
							contentPadding: EdgeInsets.all(responsive.w(14)),
						),
					),
				],
			),
		);
	}
}

// ── Refund Summary Card ────────────────────────────────────────────────────

class _RefundSummaryCard extends StatelessWidget {
	const _RefundSummaryCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundRequestController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
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
						children: [
							Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: responsive.text(20)),
							SizedBox(width: responsive.w(10)),
							Text('Montant à rembourser', style: AppTextStyles.subtitle(responsive)),
							const Spacer(),
							Obx(() => Text(
								controller.formattedAmount,
								style: AppTextStyles.h6(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
							)),
						],
					),
					SizedBox(height: responsive.h(12)),
					Divider(color: AppColors.primary.withValues(alpha: 0.20), height: 1),
					SizedBox(height: responsive.h(12)),
					Row(
						children: [
							Icon(Icons.schedule_rounded, size: responsive.text(14), color: AppColors.textHint),
							SizedBox(width: responsive.w(6)),
							Text(
								'Délai estimé : 5 à 7 jours ouvrables',
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
							),
						],
					),
					SizedBox(height: responsive.h(6)),
					Row(
						children: [
							Icon(Icons.info_outline_rounded, size: responsive.text(14), color: AppColors.textHint),
							SizedBox(width: responsive.w(6)),
							Expanded(
								child: Text(
									'Le remboursement sera effectué sur le même moyen de paiement.',
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary, height: 1.4),
								),
							),
						],
					),
				],
			),
		);
	}
}

// ── Success State ──────────────────────────────────────────────────────────

class _SuccessState extends StatefulWidget {
	const _SuccessState({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundRequestController controller;

	@override
	State<_SuccessState> createState() => _SuccessStateState();
}

class _SuccessStateState extends State<_SuccessState> with SingleTickerProviderStateMixin {
	late final AnimationController _anim;
	late final Animation<double> _scale;
	late final Animation<double> _opacity;

	@override
	void initState() {
		super.initState();
		_anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
		_scale = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _anim, curve: Curves.elasticOut));
		_opacity = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _anim, curve: const Interval(0, 0.5)));
		_anim.forward();
	}

	@override
	void dispose() {
		_anim.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final responsive = widget.responsive;
		return Padding(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 32, smallPhone: 24, tablet: 48, desktop: 64),
			),
			child: AnimatedBuilder(
				animation: _anim,
				builder: (_, _) => Opacity(
					opacity: _opacity.value,
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Transform.scale(
								scale: _scale.value,
								child: Container(
									width: responsive.w(100),
									height: responsive.w(100),
									decoration: const BoxDecoration(
										shape: BoxShape.circle,
										color: Color(0xFFF0FDF8),
										boxShadow: [BoxShadow(color: Color(0x2200A86B), blurRadius: 24, spreadRadius: 8)],
									),
									child: Icon(Icons.check_circle_rounded, color: AppColors.primary, size: responsive.text(52)),
								),
							),
							SizedBox(height: responsive.h(28)),
							Text(
								'Demande envoyée !',
								style: AppTextStyles.h6(responsive).copyWith(fontWeight: FontWeight.w800),
								textAlign: TextAlign.center,
							),
							SizedBox(height: responsive.h(12)),
							Text(
								'Votre demande de remboursement a été soumise avec succès. Notre équipe l\'examinera et vous tiendra informé.',
								style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary, height: 1.6),
								textAlign: TextAlign.center,
							),
							SizedBox(height: responsive.h(24)),
							Container(
								padding: EdgeInsets.all(responsive.w(16)),
								decoration: ShapeDecoration(
									color: const Color(0xFFF0FDF8),
									shape: RoundedRectangleBorder(
										side: const BorderSide(color: Color(0x3300A86B)),
										borderRadius: BorderRadius.circular(16),
									),
								),
								child: Column(
									children: [
										_SummaryRow(icon: Icons.payments_rounded, label: 'Montant', value: widget.controller.formattedAmount, responsive: responsive, valueColor: AppColors.primary),
										SizedBox(height: responsive.h(10)),
										_SummaryRow(icon: Icons.schedule_rounded, label: 'Délai', value: '5–7 jours ouvrables', responsive: responsive),
									],
								),
							),
							SizedBox(height: responsive.h(32)),
							AppPrimaryButton(
								responsive: responsive,
								label: 'Retour à l\'accueil',
								onTap: () => BottonNavController.goToTab(0),
								height: responsive.h(56),
								borderRadius: responsive.radius(16),
							),
						],
					),
				),
			),
		);
	}
}

class _SummaryRow extends StatelessWidget {
	const _SummaryRow({required this.icon, required this.label, required this.value, required this.responsive, this.valueColor});
	final IconData icon;
	final String label;
	final String value;
	final AppResponsive responsive;
	final Color? valueColor;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Icon(icon, size: responsive.text(16), color: AppColors.primary),
				SizedBox(width: responsive.w(10)),
				Text(label, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary)),
				const Spacer(),
				Text(
					value,
					style: AppTextStyles.subtitle(responsive).copyWith(
						color: valueColor ?? AppColors.textPrimary,
						fontWeight: FontWeight.w700,
					),
				),
			],
		);
	}
}

// ── Loading Overlay ────────────────────────────────────────────────────────

class _LoadingOverlay extends StatelessWidget {
	const _LoadingOverlay();

	@override
	Widget build(BuildContext context) {
		return Container(
			color: Colors.black54,
			child: Center(
				child: Container(
					padding: const EdgeInsets.all(28),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(20),
						boxShadow: const [BoxShadow(color: Color(0x20000000), blurRadius: 24)],
					),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						children: [
							const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
							const SizedBox(height: 20),
							const Text(
								'Envoi en cours...',
								style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600, color: AppColors.textPrimary),
							),
						],
					),
				),
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

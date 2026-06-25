import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/refund_controller.dart';

class RefundView extends StatelessWidget {
	const RefundView({super.key});

	@override
	Widget build(BuildContext context) {
		final RefundController controller =
				Get.isRegistered<RefundController>()
						? Get.find<RefundController>()
						: Get.put(RefundController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: Obx(() {
				if (controller.isSubmitted.value) {
					return SafeArea(
						child: Center(
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
								child: _SubmittedState(responsive: responsive, controller: controller),
							),
						),
					);
				}
				return SafeArea(
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
												SizedBox(height: responsive.h(20)),
												_TripSummaryCard(responsive: responsive, controller: controller),
												SizedBox(height: responsive.h(16)),
												_AmountCard(responsive: responsive, controller: controller),
												SizedBox(height: responsive.h(16)),
												_ReasonCard(responsive: responsive, controller: controller),
												SizedBox(height: responsive.h(16)),
												_DescriptionCard(responsive: responsive, controller: controller),
												SizedBox(height: responsive.h(16)),
												_ProofCard(responsive: responsive, controller: controller),
												SizedBox(height: responsive.h(16)),
												_PolicyCard(responsive: responsive),
												SizedBox(height: responsive.h(24)),
												Obx(() => AppPrimaryButton(
													responsive: responsive,
													label: controller.isSubmitting.value
															? 'Envoi en cours...'
															: 'Soumettre la demande',
													onTap: controller.isSubmitting.value ? () {} : controller.submitRefund,
													height: responsive.h(56),
													borderRadius: responsive.radius(16),
																			)),
												SizedBox(height: responsive.h(24)),
											],
										),
									),
								],
							),
						),
					),
				);
			}),
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
							Text('Demande de remboursement', style: AppTextStyles.title(responsive)),
							Text(
								'Traitement sous 3–7 jours ouvrables',
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

// ── Trip Summary ────────────────────────────────────────────────────────────

class _TripSummaryCard extends StatelessWidget {
	const _TripSummaryCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundController controller;

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
									color: AppColors.surfaceAccentStrong,
									borderRadius: BorderRadius.circular(12),
								),
								child: Icon(Icons.directions_car_rounded, color: AppColors.primary, size: responsive.text(22)),
							),
							SizedBox(width: responsive.w(14)),
							Expanded(
								child: Column(
									crossAxisAlignment: CrossAxisAlignment.start,
									children: [
										Text('Trajet concerné', style: AppTextStyles.caption(responsive)),
										Text(
											'${controller.tripOrigin.value} → ${controller.tripDestination.value}',
											style: AppTextStyles.subtitle(responsive),
										),
										Text(
											controller.tripDate.value,
											style: AppTextStyles.caption(responsive),
										),
									],
								),
							),
						],
					),
					SizedBox(height: responsive.h(12)),
					Container(
						width: double.infinity,
						padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(8)),
						decoration: BoxDecoration(
							color: AppColors.surfaceMuted,
							borderRadius: BorderRadius.circular(responsive.radius(8)),
							border: Border.all(color: AppColors.border),
						),
						child: Row(
							children: [
								Icon(Icons.receipt_long_rounded, size: responsive.text(14), color: AppColors.textHint),
								SizedBox(width: responsive.w(8)),
								Text(
									'Réf: ${controller.transactionRef.value}',
									style: AppTextStyles.caption(responsive).copyWith(fontFamily: 'monospace'),
								),
							],
						),
					),
				],
			),
		));
	}
}

// ── Amount Card ─────────────────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
	const _AmountCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() => Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(20)),
			decoration: ShapeDecoration(
				color: const Color(0xFFF0FDF8),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Color(0x3300A86B)),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Row(
				children: [
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Montant à rembourser',
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
								),
								SizedBox(height: responsive.h(4)),
								Text(
									controller.formattedAmount,
									style: TextStyle(
										color: AppColors.primary,
										fontFamily: 'Inter',
										fontWeight: FontWeight.w800,
										fontSize: responsive.text(28),
										letterSpacing: -1,
									),
								),
							],
						),
					),
					Container(
						padding: EdgeInsets.all(responsive.w(12)),
						decoration: BoxDecoration(
							color: const Color(0x1900A86B),
							shape: BoxShape.circle,
						),
						child: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: responsive.text(26)),
					),
				],
			),
		));
	}
}

// ── Reason Card ─────────────────────────────────────────────────────────────

class _ReasonCard extends StatelessWidget {
	const _ReasonCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundController controller;

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
								width: responsive.w(8),
								height: responsive.w(8),
								decoration: const BoxDecoration(
									shape: BoxShape.circle,
									color: Color(0xFFEF4444),
								),
							),
							SizedBox(width: responsive.w(6)),
							Text(
								'Raison du remboursement',
								style: AppTextStyles.h6(responsive),
							),
						],
					),
					SizedBox(height: responsive.h(14)),
					...controller.reasons.map((reason) {
						final selected = controller.selectedReason.value == reason;
						return GestureDetector(
							onTap: () => controller.selectReason(reason),
							child: AnimatedContainer(
								duration: AppResponsive.fastDuration,
								margin: EdgeInsets.only(bottom: responsive.h(8)),
								padding: EdgeInsets.symmetric(
									horizontal: responsive.w(14),
									vertical: responsive.h(12),
								),
								decoration: ShapeDecoration(
									color: selected ? const Color(0xFFF0FDF8) : AppColors.surfaceMuted,
									shape: RoundedRectangleBorder(
										side: BorderSide(
											color: selected ? const Color(0x5500A86B) : AppColors.border,
											width: selected ? 1.5 : 1.0,
										),
										borderRadius: BorderRadius.circular(responsive.radius(10)),
									),
								),
								child: Row(
									children: [
										AnimatedContainer(
											duration: AppResponsive.fastDuration,
											width: responsive.w(18),
											height: responsive.w(18),
											decoration: BoxDecoration(
												shape: BoxShape.circle,
												color: selected ? AppColors.primary : AppColors.surfaceMuted,
												border: Border.all(
													color: selected ? AppColors.primary : AppColors.borderStrong,
													width: 1.5,
												),
											),
											child: selected
													? Icon(Icons.check_rounded, color: Colors.white, size: responsive.text(10))
													: null,
										),
										SizedBox(width: responsive.w(12)),
										Expanded(
											child: Text(
												reason,
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
					}),
				],
			),
		));
	}
}

// ── Description Card ────────────────────────────────────────────────────────

class _DescriptionCard extends StatelessWidget {
	const _DescriptionCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Détails supplémentaires', style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(4)),
					Text(
						'Optionnel — décrivez votre situation',
						style: AppTextStyles.caption(responsive),
					),
					SizedBox(height: responsive.h(12)),
					TextField(
						controller: controller.descriptionController,
						maxLines: 4,
						style: AppTextStyles.body(responsive).copyWith(color: AppColors.textPrimary),
						decoration: InputDecoration(
							hintText: 'Ex: Le conducteur n\'est pas arrivé au point de rendez-vous après 30 minutes d\'attente...',
							hintStyle: AppTextStyles.body(responsive).copyWith(color: AppColors.textGhost, height: 1.5),
							filled: true,
							fillColor: AppColors.surfaceMuted,
							contentPadding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(12)),
							border: OutlineInputBorder(
								borderRadius: BorderRadius.circular(responsive.radius(10)),
								borderSide: const BorderSide(color: AppColors.border),
							),
							enabledBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(responsive.radius(10)),
								borderSide: const BorderSide(color: AppColors.border),
							),
							focusedBorder: OutlineInputBorder(
								borderRadius: BorderRadius.circular(responsive.radius(10)),
								borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
							),
						),
					),
				],
			),
		);
	}
}

// ── Policy Card ─────────────────────────────────────────────────────────────

class _PolicyCard extends StatelessWidget {
	const _PolicyCard({required this.responsive});
	final AppResponsive responsive;

	static const _points = [
		'Le remboursement sera crédité sur votre mode de paiement original',
		'Le délai de traitement est de 3 à 7 jours ouvrables',
		'Vous recevrez une confirmation par SMS une fois votre demande traitée',
		'En cas de refus, un agent vous contactera pour plus d\'informations',
	];

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: BoxDecoration(
				color: const Color(0xFFFFFBEB),
				borderRadius: BorderRadius.circular(responsive.radius(14)),
				border: Border.all(color: const Color(0x40F59E0B)),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Icon(Icons.info_outline_rounded, color: AppColors.warning, size: responsive.text(18)),
							SizedBox(width: responsive.w(8)),
							Text(
								'Politique de remboursement',
								style: AppTextStyles.caption(responsive).copyWith(
									color: AppColors.warning,
									fontWeight: FontWeight.w700,
								),
							),
						],
					),
					SizedBox(height: responsive.h(10)),
					..._points.map((p) => Padding(
						padding: EdgeInsets.only(bottom: responsive.h(6)),
						child: Row(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('• ', style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint)),
								Expanded(
									child: Text(
										p,
										style: AppTextStyles.body(responsive).copyWith(color: AppColors.textMuted, height: 1.5),
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

// ── Proof Card ──────────────────────────────────────────────────────────────

class _ProofCard extends StatelessWidget {
	const _ProofCard({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundController controller;

	@override
	Widget build(BuildContext context) {
		return _Card(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Icon(Icons.photo_library_outlined, size: responsive.text(16), color: AppColors.primary),
							SizedBox(width: responsive.w(8)),
							Text('Preuves (optionnel)', style: AppTextStyles.h6(responsive)),
							const Spacer(),
							Obx(() => Text(
								'${controller.proofImages.length}/${RefundController.maxProofImages}',
								style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
							)),
						],
					),
					SizedBox(height: responsive.h(6)),
					Text(
						'Photos, captures d\'écran ou reçus liés à votre demande',
						style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary),
					),
					SizedBox(height: responsive.h(14)),
					// Thumbnails grid
					Obx(() {
						final images = controller.proofImages;
						return Wrap(
							spacing: responsive.w(8),
							runSpacing: responsive.h(8),
							children: [
								...images.asMap().entries.map((e) => _Thumbnail(
									responsive: responsive,
									path: e.value.path,
									onRemove: () => controller.removeProofImage(e.key),
								)),
								if (images.length < RefundController.maxProofImages)
									_AddPhotoButton(responsive: responsive, controller: controller),
							],
						);
					}),
				],
			),
		);
	}
}

class _Thumbnail extends StatelessWidget {
	const _Thumbnail({required this.responsive, required this.path, required this.onRemove});
	final AppResponsive responsive;
	final String path;
	final VoidCallback onRemove;

	@override
	Widget build(BuildContext context) {
		final size = responsive.w(72);
		return Stack(
			clipBehavior: Clip.none,
			children: [
				Container(
					width: size,
					height: size,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.circular(responsive.radius(8)),
						border: Border.all(color: AppColors.border),
						image: DecorationImage(
							image: FileImage(File(path)),
							fit: BoxFit.cover,
						),
					),
				),
				Positioned(
					top: -responsive.h(6),
					right: -responsive.w(6),
					child: GestureDetector(
						onTap: onRemove,
						child: Container(
							width: responsive.w(20),
							height: responsive.w(20),
							decoration: const BoxDecoration(
								color: Color(0xFFEF4444),
								shape: BoxShape.circle,
							),
							child: Icon(Icons.close_rounded, size: responsive.text(12), color: Colors.white),
						),
					),
				),
			],
		);
	}
}

class _AddPhotoButton extends StatelessWidget {
	const _AddPhotoButton({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundController controller;

	@override
	Widget build(BuildContext context) {
		final size = responsive.w(72);
		return GestureDetector(
			onTap: () => _showSourcePicker(context),
			child: Container(
				width: size,
				height: size,
				decoration: BoxDecoration(
					color: AppColors.surfaceAccent,
					borderRadius: BorderRadius.circular(responsive.radius(8)),
					border: Border.all(color: AppColors.primary.withValues(alpha: 0.30), width: 1.5),
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(Icons.add_photo_alternate_outlined, size: responsive.text(22), color: AppColors.primary),
						SizedBox(height: responsive.h(4)),
						Text(
							'Ajouter',
							style: AppTextStyles.caption(responsive).copyWith(
								color: AppColors.primary,
								fontSize: responsive.text(10),
								fontWeight: FontWeight.w600,
							),
						),
					],
				),
			),
		);
	}

	void _showSourcePicker(BuildContext context) {
		final responsive = AppResponsive(context);
		showModalBottomSheet(
			context: context,
			backgroundColor: AppColors.white,
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.radius(20))),
			),
			builder: (_) => Padding(
				padding: EdgeInsets.fromLTRB(responsive.w(20), responsive.h(16), responsive.w(20), responsive.h(32)),
				child: Column(
					mainAxisSize: MainAxisSize.min,
					children: [
						Container(
							width: responsive.w(40),
							height: responsive.h(4),
							decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
						),
						SizedBox(height: responsive.h(16)),
						Text('Ajouter une preuve', style: AppTextStyles.subtitle(responsive)),
						SizedBox(height: responsive.h(16)),
						ListTile(
							leading: Container(
								padding: EdgeInsets.all(responsive.w(8)),
								decoration: BoxDecoration(color: AppColors.surfaceAccent, shape: BoxShape.circle),
								child: Icon(Icons.photo_library_rounded, color: AppColors.primary),
							),
							title: Text('Galerie photo', style: AppTextStyles.body(responsive)),
							subtitle: Text('Sélectionner depuis la galerie', style: AppTextStyles.caption(responsive)),
							onTap: () {
								Get.back();
								controller.pickProofImages();
							},
						),
						ListTile(
							leading: Container(
								padding: EdgeInsets.all(responsive.w(8)),
								decoration: BoxDecoration(color: const Color(0xFFF0F9FF), shape: BoxShape.circle),
								child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0EA5E9)),
							),
							title: Text('Appareil photo', style: AppTextStyles.body(responsive)),
							subtitle: Text('Prendre une nouvelle photo', style: AppTextStyles.caption(responsive)),
							onTap: () {
								Get.back();
								controller.pickFromCamera();
							},
						),
					],
				),
			),
		);
	}
}

// ── Submitted State ──────────────────────────────────────────────────────────

class _SubmittedState extends StatelessWidget {
	const _SubmittedState({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final RefundController controller;

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.adaptive(phone: 24, smallPhone: 20, tablet: 40, desktop: 60),
			),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					_SuccessIcon(responsive: responsive),
					SizedBox(height: responsive.h(24)),
					Text(
						'Demande envoyée !',
						style: AppTextStyles.title(responsive).copyWith(
							fontSize: responsive.text(22),
							color: AppColors.primary,
						),
						textAlign: TextAlign.center,
					),
					SizedBox(height: responsive.h(12)),
					Text(
						'Votre demande de remboursement a été soumise. Nous l\'examinerons dans les 24 heures et vous informerons par SMS.',
						style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
						textAlign: TextAlign.center,
					),
					SizedBox(height: responsive.h(32)),
					// Refund amount display
					Obx(() => Container(
						padding: EdgeInsets.symmetric(horizontal: responsive.w(24), vertical: responsive.h(16)),
						decoration: ShapeDecoration(
							color: const Color(0xFFF0FDF8),
							shape: RoundedRectangleBorder(
								side: const BorderSide(color: Color(0x3300A86B)),
								borderRadius: BorderRadius.circular(responsive.radius(16)),
							),
						),
						child: Column(
							children: [
								Text(
									'Montant en cours de traitement',
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
								),
								SizedBox(height: responsive.h(6)),
								Text(
									controller.formattedAmount,
									style: AppTextStyles.price(responsive).copyWith(fontSize: responsive.text(28)),
								),
								SizedBox(height: responsive.h(4)),
								Text(
									'3–7 jours ouvrables',
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary),
								),
							],
						),
					)),
					SizedBox(height: responsive.h(32)),
					AppPrimaryButton(
						responsive: responsive,
						label: 'Voir mes réservations',
						onTap: controller.goToReservations,
						height: responsive.h(56),
						borderRadius: responsive.radius(16),
					),
					SizedBox(height: responsive.h(12)),
					OutlinedButton.icon(
						onPressed: controller.viewRefundHistory,
						icon: Icon(Icons.history_rounded, size: responsive.text(16)),
						label: Text('Voir mes demandes de remboursement'),
						style: OutlinedButton.styleFrom(
							foregroundColor: AppColors.primary,
							side: BorderSide(color: AppColors.primary.withValues(alpha: 0.40)),
							padding: EdgeInsets.symmetric(vertical: responsive.h(14), horizontal: responsive.w(16)),
							shape: RoundedRectangleBorder(
								borderRadius: BorderRadius.circular(responsive.radius(14)),
							),
							textStyle: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600),
						),
					),
					SizedBox(height: responsive.h(12)),
					InkWell(
						onTap: controller.goHome,
						borderRadius: BorderRadius.circular(9999),
						child: Padding(
							padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(10)),
							child: Text(
								'Retour à l\'accueil',
								style: AppTextStyles.body(responsive).copyWith(
									color: AppColors.textHint,
									fontWeight: FontWeight.w500,
								),
							),
						),
					),
				],
			),
		);
	}
}

class _SuccessIcon extends StatefulWidget {
	const _SuccessIcon({required this.responsive});
	final AppResponsive responsive;

	@override
	State<_SuccessIcon> createState() => _SuccessIconState();
}

class _SuccessIconState extends State<_SuccessIcon>
		with SingleTickerProviderStateMixin {
	late AnimationController _anim;
	late Animation<double> _scale;
	late Animation<double> _fade;

	@override
	void initState() {
		super.initState();
		_anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
		_scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
		_fade = CurvedAnimation(parent: _anim, curve: Curves.easeIn);
		_anim.forward();
	}

	@override
	void dispose() {
		_anim.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		final r = widget.responsive;
		return FadeTransition(
			opacity: _fade,
			child: ScaleTransition(
				scale: _scale,
				child: Container(
					width: r.w(96),
					height: r.w(96),
					decoration: const BoxDecoration(
						shape: BoxShape.circle,
						color: Color(0x1900A86B),
					),
					child: Icon(
						Icons.account_balance_wallet_rounded,
						color: AppColors.primary,
						size: r.text(44),
					),
				),
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

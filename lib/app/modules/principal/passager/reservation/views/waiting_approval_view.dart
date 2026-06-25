import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/waiting_approval_controller.dart';

class WaitingApprovalView extends StatelessWidget {
	const WaitingApprovalView({super.key});

	@override
	Widget build(BuildContext context) {
		final WaitingApprovalController controller =
				Get.isRegistered<WaitingApprovalController>()
						? Get.find<WaitingApprovalController>()
						: Get.put(WaitingApprovalController());
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Obx(() => _buildBody(context, responsive, controller)),
					),
				),
			),
		);
	}

	Widget _buildBody(BuildContext context, AppResponsive responsive, WaitingApprovalController controller) {
		switch (controller.status.value) {
			case WaitingStatus.accepted:
				return _AcceptedContent(responsive: responsive);
			case WaitingStatus.rejected:
				return _RejectedContent(responsive: responsive, controller: controller);
			case WaitingStatus.timeout:
				return _TimeoutContent(responsive: responsive, controller: controller);
			case WaitingStatus.pending:
				return _PendingContent(responsive: responsive, controller: controller);
		}
	}
}

// ── Pending ────────────────────────────────────────────────────────────────

class _PendingContent extends StatelessWidget {
	const _PendingContent({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final WaitingApprovalController controller;

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
				_HeaderBar(responsive: responsive, title: 'Demande envoyée'),
				SizedBox(height: responsive.h(40)),
				Center(child: _PulseCircle(size: responsive.w(120), color: AppColors.primary)),
				SizedBox(height: responsive.h(32)),
				Text(
					'En attente de confirmation',
					textAlign: TextAlign.center,
					style: AppTextStyles.h6(responsive).copyWith(fontSize: responsive.text(20)),
				),
				SizedBox(height: responsive.h(8)),
				Text(
					'Le conducteur a généralement moins\nde 5 minutes pour répondre.',
					textAlign: TextAlign.center,
					style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
				),
				SizedBox(height: responsive.h(28)),
				_CountdownBar(responsive: responsive, controller: controller),
				SizedBox(height: responsive.h(16)),
				_GuaranteeBanner(responsive: responsive),
				SizedBox(height: responsive.h(16)),
				_TripInfoCard(responsive: responsive, controller: controller),
				SizedBox(height: responsive.h(32)),
				AppPrimaryButton(
					responsive: responsive,
					label: 'Annuler la demande',
					onTap: controller.cancelRequest,
					backgroundColor: AppColors.white,
					textColor: const Color(0xFFEF4444),
					borderColor: const Color(0xFFEF4444),
					height: responsive.h(56),
					borderRadius: responsive.radius(16),
				),
			],
		);
	}
}

// ── Accepted ───────────────────────────────────────────────────────────────

class _AcceptedContent extends StatelessWidget {
	const _AcceptedContent({required this.responsive});

	final AppResponsive responsive;

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
				_HeaderBar(responsive: responsive, title: 'Demande acceptée'),
				SizedBox(height: responsive.h(48)),
				Center(child: _PulseCircle(size: responsive.w(120), color: AppColors.primary)),
				SizedBox(height: responsive.h(32)),
				Text(
					'Votre trajet est confirmé !',
					textAlign: TextAlign.center,
					style: AppTextStyles.h6(responsive).copyWith(fontSize: responsive.text(20)),
				),
				SizedBox(height: responsive.h(8)),
				Text(
					'Le conducteur vous attend.\nRendez-vous au point de départ.',
					textAlign: TextAlign.center,
					style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
				),
				SizedBox(height: responsive.h(32)),
				AppPrimaryButton(
					responsive: responsive,
					label: 'Voir le conducteur',
					onTap: Get.back,
					height: responsive.h(56),
					borderRadius: responsive.radius(16),
				),
			],
		);
	}
}

// ── Rejected ───────────────────────────────────────────────────────────────

class _RejectedContent extends StatelessWidget {
	const _RejectedContent({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final WaitingApprovalController controller;

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
				_HeaderBar(responsive: responsive, title: 'Demande refusée'),
				SizedBox(height: responsive.h(48)),
				Center(child: _PulseCircle(size: responsive.w(120), color: const Color(0xFFEF4444))),
				SizedBox(height: responsive.h(32)),
				Text(
					'Le conducteur a refusé',
					textAlign: TextAlign.center,
					style: AppTextStyles.h6(responsive).copyWith(fontSize: responsive.text(20)),
				),
				SizedBox(height: responsive.h(8)),
				Text(
					'Ne vous inquiétez pas, vous serez\nremboursé intégralement sous 24h.',
					textAlign: TextAlign.center,
					style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
				),
				SizedBox(height: responsive.h(32)),
				AppPrimaryButton(
					responsive: responsive,
					label: 'Chercher un autre trajet',
					onTap: controller.searchAnother,
					height: responsive.h(56),
					borderRadius: responsive.radius(16),
				),
				SizedBox(height: responsive.h(12)),
				AppPrimaryButton(
					responsive: responsive,
					label: 'Demander un remboursement',
					onTap: controller.requestRefund,
					backgroundColor: AppColors.white,
					textColor: AppColors.primary,
					borderColor: AppColors.primary,
					height: responsive.h(56),
					borderRadius: responsive.radius(16),
				),
			],
		);
	}
}

// ── Timeout ────────────────────────────────────────────────────────────────

class _TimeoutContent extends StatelessWidget {
	const _TimeoutContent({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final WaitingApprovalController controller;

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
				_HeaderBar(responsive: responsive, title: 'Délai expiré'),
				SizedBox(height: responsive.h(48)),
				Center(child: _PulseCircle(size: responsive.w(120), color: AppColors.warning)),
				SizedBox(height: responsive.h(32)),
				Text(
					'Pas de réponse du conducteur',
					textAlign: TextAlign.center,
					style: AppTextStyles.h6(responsive).copyWith(fontSize: responsive.text(20)),
				),
				SizedBox(height: responsive.h(8)),
				Text(
					'Le conducteur n\'a pas répondu à temps.\nVotre remboursement est automatique.',
					textAlign: TextAlign.center,
					style: AppTextStyles.body(responsive).copyWith(color: AppColors.textHint, height: 1.6),
				),
				SizedBox(height: responsive.h(32)),
				AppPrimaryButton(
					responsive: responsive,
					label: 'Chercher un autre trajet',
					onTap: controller.searchAnother,
					height: responsive.h(56),
					borderRadius: responsive.radius(16),
				),
			],
		);
	}
}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _HeaderBar extends StatelessWidget {
	const _HeaderBar({required this.responsive, required this.title});

	final AppResponsive responsive;
	final String title;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(vertical: responsive.h(16)),
			child: Row(
				children: [
					_RoundIconButton(icon: Icons.chevron_left_rounded, onTap: Get.back),
					const Spacer(),
					Text(title, style: AppTextStyles.title(responsive)),
					const Spacer(),
					SizedBox(width: responsive.w(40)),
				],
			),
		);
	}
}

class _RoundIconButton extends StatelessWidget {
	const _RoundIconButton({required this.icon, required this.onTap});

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
					decoration: ShapeDecoration(
						color: AppColors.white,
						shape: RoundedRectangleBorder(
							side: const BorderSide(color: AppColors.border),
							borderRadius: BorderRadius.circular(9999),
						),
					),
					child: Icon(icon, size: responsive.text(22), color: AppColors.textPrimary),
				),
			),
		);
	}
}

class _CountdownBar extends StatelessWidget {
	const _CountdownBar({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final WaitingApprovalController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() => Column(
			children: [
				Row(
					mainAxisAlignment: MainAxisAlignment.spaceBetween,
					children: [
						Text('Temps restant', style: AppTextStyles.caption(responsive)),
						Text(
							controller.timeLabel,
							style: AppTextStyles.caption(responsive).copyWith(
								color: AppColors.primary,
								fontWeight: FontWeight.w700,
							),
						),
					],
				),
				SizedBox(height: responsive.h(8)),
				ClipRRect(
					borderRadius: BorderRadius.circular(9999),
					child: LinearProgressIndicator(
						value: controller.progressFraction,
						minHeight: responsive.h(8),
						backgroundColor: AppColors.border,
						valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
					),
				),
			],
		));
	}
}

class _GuaranteeBanner extends StatelessWidget {
	const _GuaranteeBanner({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(
				horizontal: responsive.w(14),
				vertical: responsive.h(12),
			),
			decoration: ShapeDecoration(
				color: const Color(0xFFF0FDF8),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: Color(0x3300A86B)),
					borderRadius: BorderRadius.circular(14),
				),
			),
			child: Row(
				children: [
					Container(
						width: responsive.w(36),
						height: responsive.w(36),
						decoration: BoxDecoration(
							color: AppColors.primary.withValues(alpha: 0.12),
							shape: BoxShape.circle,
						),
						child: Icon(Icons.shield_rounded, color: AppColors.primary, size: responsive.text(18)),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Votre argent est en sécurité',
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w700,
									),
								),
								SizedBox(height: responsive.h(2)),
								Text(
									'Remboursement intégral garanti si le conducteur refuse ou ne répond pas.',
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.textSecondary,
										fontSize: responsive.text(11),
										height: 1.4,
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

class _TripInfoCard extends StatelessWidget {
	const _TripInfoCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final WaitingApprovalController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final ride = controller.ride.value;
			final origin = ride?.origin ?? 'Cotonou';
			final destination = ride?.destination ?? 'Porto-Novo';
			final time = ride?.departureTime ?? '14h30';
			final driver = ride?.driverName ?? 'Conducteur';
			final rating = ride?.rating ?? '4.8';
			final price = ride?.price ?? '2 500 FCFA';
			final seats = controller.reservedSeats.value;

			return Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20)),
				decoration: ShapeDecoration(
					color: AppColors.white,
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: AppColors.border),
						borderRadius: BorderRadius.circular(responsive.radius(20)),
					),
					shadows: const [
						BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, 4)),
					],
				),
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							children: [
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(origin, style: AppTextStyles.title(responsive).copyWith(fontSize: responsive.text(15))),
											SizedBox(height: responsive.h(2)),
											Text(time, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint)),
										],
									),
								),
								Container(
									padding: EdgeInsets.all(responsive.w(8)),
									decoration: BoxDecoration(
										color: AppColors.primary.withValues(alpha: 0.08),
										shape: BoxShape.circle,
									),
									child: Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: responsive.text(16)),
								),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.end,
										children: [
											Text(destination, style: AppTextStyles.title(responsive).copyWith(fontSize: responsive.text(15))),
											SizedBox(height: responsive.h(2)),
											Text(price, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
										],
									),
								),
							],
						),
						const Divider(height: 24, color: Color(0xFFF3F4F6)),
						Row(
							children: [
								Container(
									width: responsive.w(36),
									height: responsive.w(36),
									decoration: BoxDecoration(
										gradient: const LinearGradient(
											colors: [Color(0xFF00A86B), Color(0xFF10B981)],
											begin: Alignment.topLeft,
											end: Alignment.bottomRight,
										),
										shape: BoxShape.circle,
									),
									child: Center(
										child: Text(
											driver.isNotEmpty ? driver[0].toUpperCase() : 'C',
											style: AppTextStyles.caption(responsive).copyWith(color: Colors.white, fontWeight: FontWeight.w700),
										),
									),
								),
								SizedBox(width: responsive.w(10)),
								Expanded(
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(driver, style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600)),
											Row(
												children: [
													Icon(Icons.star_rounded, size: responsive.text(12), color: AppColors.warning),
													SizedBox(width: responsive.w(3)),
													Text(rating, style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textSecondary)),
												],
											),
										],
									),
								),
								Container(
									padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(4)),
									decoration: BoxDecoration(
										color: AppColors.primary.withValues(alpha: 0.08),
										borderRadius: BorderRadius.circular(9999),
									),
									child: Text(
										'$seats place${seats > 1 ? 's' : ''}',
										style: AppTextStyles.caption(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
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

// ── Animated widgets ───────────────────────────────────────────────────────

class _PulseCircle extends StatefulWidget {
	const _PulseCircle({required this.size, required this.color});

	final double size;
	final Color color;

	@override
	State<_PulseCircle> createState() => _PulseCircleState();
}

class _PulseCircleState extends State<_PulseCircle> with SingleTickerProviderStateMixin {
	late AnimationController _animController;
	late Animation<double> _scaleAnim;
	late Animation<double> _opacityAnim;

	@override
	void initState() {
		super.initState();
		_animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
			..repeat(reverse: false);
		_scaleAnim = Tween<double>(begin: 1.0, end: 1.35).animate(
			CurvedAnimation(parent: _animController, curve: Curves.easeOut),
		);
		_opacityAnim = Tween<double>(begin: 0.35, end: 0.0).animate(
			CurvedAnimation(parent: _animController, curve: Curves.easeOut),
		);
	}

	@override
	void dispose() {
		_animController.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: widget.size * 1.5,
			height: widget.size * 1.5,
			child: Stack(
				alignment: Alignment.center,
				children: [
					AnimatedBuilder(
						animation: _animController,
						builder: (_, _) => Opacity(
							opacity: _opacityAnim.value,
							child: Container(
								width: widget.size * _scaleAnim.value,
								height: widget.size * _scaleAnim.value,
								decoration: BoxDecoration(
									color: widget.color.withValues(alpha: 0.20),
									shape: BoxShape.circle,
								),
							),
						),
					),
					Container(
						width: widget.size,
						height: widget.size,
						decoration: BoxDecoration(
							color: widget.color.withValues(alpha: 0.12),
							shape: BoxShape.circle,
						),
						child: Icon(Icons.directions_car_filled_rounded, color: widget.color, size: widget.size * 0.45),
					),
				],
			),
		);
	}
}

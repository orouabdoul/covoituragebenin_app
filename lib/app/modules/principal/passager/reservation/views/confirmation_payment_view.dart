import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/confirmation_reservation_controller.dart';

class ConfirmationPaymentView extends StatelessWidget {
	const ConfirmationPaymentView({super.key});

	@override
	Widget build(BuildContext context) {
		final ConfirmationReservationController controller =
				Get.isRegistered<ConfirmationReservationController>()
						? Get.find<ConfirmationReservationController>()
						: Get.put(ConfirmationReservationController());
		final responsive = AppResponsive(context);
		final dynamic rawArgs = Get.arguments;
		final int navTotal = rawArgs is Map ? ((rawArgs['totalAmount'] as int?) ?? 0) : 0;

		return Stack(
			children: [
				Scaffold(
					backgroundColor: AppColors.surface,
					body: SafeArea(
						child: Center(
							child: ConstrainedBox(
								constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
								child: ListView(
									padding: EdgeInsets.fromLTRB(
										responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
										responsive.h(8),
										responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
										responsive.h(32),
									),
									children: [
										_HeaderBar(responsive: responsive),
										SizedBox(height: responsive.h(20)),
										_TripSummaryCard(responsive: responsive, controller: controller, navTotal: navTotal),
										SizedBox(height: responsive.h(16)),
										_PaymentMethodCard(responsive: responsive, controller: controller),
										SizedBox(height: responsive.h(16)),
										_PaymentInputSection(responsive: responsive, controller: controller),
										SizedBox(height: responsive.h(16)),
										_SecurityCard(responsive: responsive),
										SizedBox(height: responsive.h(24)),
										Obx(() {
											final displayAmount = navTotal > 0 ? navTotal : controller.totalAmount;
											return AppPrimaryButton(
												responsive: responsive,
												label: controller.isProcessingPayment.value
														? 'Traitement en cours…'
														: 'Payer ${_formatAmount(displayAmount)} FCFA',
												onTap: controller.isProcessingPayment.value ? () {} : controller.confirmPayment,
												enabled: !controller.isProcessingPayment.value,
												backgroundColor: AppColors.primary,
												textColor: Colors.white,
												borderRadius: responsive.radius(16),
												height: responsive.h(56),
											);
										}),
									],
								),
							),
						),
					),
				),
				Obx(() => controller.isProcessingPayment.value
						? _ProcessingOverlay(responsive: responsive)
						: const SizedBox.shrink()),
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
		return Container(
			width: double.infinity,
			padding: EdgeInsets.symmetric(vertical: responsive.h(16)),
			child: Row(
				children: [
					_RoundIconButton(icon: Icons.chevron_left_rounded, onTap: Get.back),
					const Spacer(),
					Text('Paiement', style: AppTextStyles.title(responsive)),
					const Spacer(),
					_RoundIconButton(
						icon: Icons.lock_rounded,
						onTap: () => Get.dialog(
							AlertDialog(
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
								title: const Row(children: [
									Icon(Icons.lock_rounded, color: AppColors.primary, size: 20),
									SizedBox(width: 8),
									Text('Paiement sécurisé', style: TextStyle(fontSize: 15)),
								]),
								content: const Text(
									'Vos informations de paiement sont chiffrées et protégées. MINIZON ne stocke jamais vos données bancaires.',
								),
								actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
							),
						),
						color: AppColors.primary,
					),
				],
			),
		);
	}
}

class _RoundIconButton extends StatelessWidget {
	const _RoundIconButton({required this.icon, required this.onTap, this.color});

	final IconData icon;
	final VoidCallback onTap;
	final Color? color;

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		final iconColor = color ?? AppColors.textPrimary;

		return Material(
			color: Colors.transparent,
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(9999),
				child: Container(
					width: responsive.w(40),
					height: responsive.w(40),
					decoration: ShapeDecoration(
						color: color != null ? color!.withValues(alpha: 0.10) : AppColors.white,
						shape: RoundedRectangleBorder(
							side: BorderSide(color: color != null ? color!.withValues(alpha: 0.30) : AppColors.border),
							borderRadius: BorderRadius.circular(9999),
						),
					),
					child: Icon(icon, size: responsive.text(18), color: iconColor),
				),
			),
		);
	}
}

// ── Trip Summary ───────────────────────────────────────────────────────────

class _TripSummaryCard extends StatelessWidget {
	const _TripSummaryCard({
		required this.responsive,
		required this.controller,
		required this.navTotal,
	});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;
	final int navTotal;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final ride = controller.ride.value;
			final origin = ride?.origin ?? '—';
			final destination = ride?.destination ?? '—';
			final time = ride?.departureTime ?? '—';
			final total = navTotal > 0 ? navTotal : controller.totalAmount;
			final seats = controller.reservedSeats.value;

			return _SectionCard(
				responsive: responsive,
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Row(
							mainAxisAlignment: MainAxisAlignment.spaceBetween,
							children: [
								Text('Résumé du trajet', style: AppTextStyles.h6(responsive)),
								_StatusBadge(label: 'Accepté ✓', color: AppColors.primary, responsive: responsive),
							],
						),
						SizedBox(height: responsive.h(16)),
						_RouteRow(responsive: responsive, origin: origin, destination: destination, time: time),
						SizedBox(height: responsive.h(16)),
						Container(height: 1, color: AppColors.border),
						SizedBox(height: responsive.h(16)),
						Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								_PriceLine(
									responsive: responsive,
									label: 'Places réservées',
									value: '$seats place${seats > 1 ? 's' : ''}',
								),
								SizedBox(height: responsive.h(10)),
								Container(height: 1, color: AppColors.border),
								SizedBox(height: responsive.h(10)),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Text('Total à payer', style: AppTextStyles.subtitle(responsive)),
										Text(
											total > 0 ? '${_formatAmount(total)} FCFA' : '---',
											style: AppTextStyles.price(responsive),
										),
									],
								),
							],
						),
					],
				),
			);
		});
	}
}

class _RouteRow extends StatelessWidget {
	const _RouteRow({
		required this.responsive,
		required this.origin,
		required this.destination,
		required this.time,
	});

	final AppResponsive responsive;
	final String origin;
	final String destination;
	final String time;

	@override
	Widget build(BuildContext context) {
		return Row(
			children: [
				Column(
					children: [
						Container(
							width: responsive.w(10),
							height: responsive.w(10),
							decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
						),
						Container(width: 2, height: responsive.h(28), color: AppColors.border),
						Container(
							width: responsive.w(10),
							height: responsive.w(10),
							decoration: BoxDecoration(
								shape: BoxShape.circle,
								border: Border.all(color: AppColors.primary, width: 2),
							),
						),
					],
				),
				SizedBox(width: responsive.w(12)),
				Expanded(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(origin, style: AppTextStyles.subtitle(responsive)),
							SizedBox(height: responsive.h(14)),
							Text(destination, style: AppTextStyles.subtitle(responsive)),
						],
					),
				),
				Column(
					crossAxisAlignment: CrossAxisAlignment.end,
					children: [
						Text(
							time,
							style: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600),
						),
					],
				),
			],
		);
	}
}

class _PriceLine extends StatelessWidget {
	const _PriceLine({required this.responsive, required this.label, required this.value});

	final AppResponsive responsive;
	final String label;
	final String value;

	@override
	Widget build(BuildContext context) {
		return Row(
			mainAxisAlignment: MainAxisAlignment.spaceBetween,
			children: [
				Text(label, style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary)),
				Text(value, style: AppTextStyles.body(responsive).copyWith(fontWeight: FontWeight.w600)),
			],
		);
	}
}

// ── Payment Method Selector ────────────────────────────────────────────────

class _PaymentMethodCard extends StatelessWidget {
	const _PaymentMethodCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;

	@override
	Widget build(BuildContext context) {
		return _SectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Méthode de paiement', style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(12)),
					Obx(
						() => Column(
							children: List.generate(controller.paymentMethods.length, (index) {
								final method = controller.paymentMethods[index];
								final selected = controller.selectedPaymentIndex.value == index;

								return Padding(
									padding: EdgeInsets.only(
										bottom: index == controller.paymentMethods.length - 1 ? 0 : responsive.h(10),
									),
									child: InkWell(
										onTap: () => controller.selectPayment(index),
										borderRadius: BorderRadius.circular(responsive.radius(14)),
										child: Container(
											padding: EdgeInsets.all(responsive.w(14)),
											decoration: ShapeDecoration(
												color: selected ? AppColors.primaryLight : Colors.white,
												shape: RoundedRectangleBorder(
													side: BorderSide(
														width: selected ? 2 : 1,
														color: selected ? AppColors.primary : AppColors.border,
													),
													borderRadius: BorderRadius.circular(responsive.radius(14)),
												),
											),
											child: Row(
												children: [
													Container(
														width: responsive.w(40),
														height: responsive.w(40),
														decoration: ShapeDecoration(
															color: method.resolvedBackgroundColor,
															shape: RoundedRectangleBorder(
																borderRadius: BorderRadius.circular(10),
															),
														),
														child: Icon(method.iconData, size: responsive.text(20), color: AppColors.primary),
													),
													SizedBox(width: responsive.w(12)),
													Expanded(
														child: Column(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																Text(method.title, style: AppTextStyles.subtitle(responsive)),
																Text(method.description, style: AppTextStyles.caption(responsive)),
															],
														),
													),
													AnimatedContainer(
														duration: AppResponsive.fastDuration,
														width: responsive.w(20),
														height: responsive.w(20),
														decoration: BoxDecoration(
															shape: BoxShape.circle,
															color: selected ? AppColors.primary : Colors.white,
															border: Border.all(
																color: selected ? AppColors.primary : AppColors.border,
															),
														),
													),
												],
											),
										),
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

// ── Dynamic Payment Input ──────────────────────────────────────────────────

class _PaymentInputSection extends StatelessWidget {
	const _PaymentInputSection({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;

	@override
	Widget build(BuildContext context) {
		return Obx(() {
			final index = controller.selectedPaymentIndex.value;
			if (index == 0) return _MobileMoneyCard(responsive: responsive, controller: controller);
			return _CardPaymentCard(responsive: responsive, controller: controller);
		});
	}
}

class _MobileMoneyCard extends StatelessWidget {
	const _MobileMoneyCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;

	@override
	Widget build(BuildContext context) {
		return _SectionCard(
			responsive: responsive,
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Text('Mobile Money', style: AppTextStyles.h6(responsive)),
					SizedBox(height: responsive.h(4)),
					Text(
						'Choisissez votre opérateur',
						style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
					),
					SizedBox(height: responsive.h(14)),
					Obx(() => Row(
						children: MobileMoneyService.values.map((service) {
							final selected = controller.selectedMobileService.value == service;
							final isLast = service == MobileMoneyService.values.last;
							return Expanded(
								child: Padding(
									padding: EdgeInsets.only(right: isLast ? 0 : responsive.w(10)),
									child: GestureDetector(
										onTap: () => controller.selectMobileService(service),
										child: AnimatedContainer(
											duration: const Duration(milliseconds: 180),
											padding: EdgeInsets.symmetric(vertical: responsive.h(10), horizontal: responsive.w(6)),
											decoration: BoxDecoration(
												color: selected
														? _ServiceLogo.brandColor(service).withValues(alpha: 0.08)
														: AppColors.white,
												borderRadius: BorderRadius.circular(responsive.radius(12)),
												border: Border.all(
													color: selected
															? _ServiceLogo.brandColor(service)
															: AppColors.border,
													width: selected ? 2 : 1,
												),
												boxShadow: selected
														? [BoxShadow(color: _ServiceLogo.brandColor(service).withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 2))]
														: null,
											),
											child: Column(
												children: [
													_ServiceLogo(service: service, size: responsive.w(48)),
													SizedBox(height: responsive.h(6)),
													Text(
														_ServiceLogo.shortLabel(service),
														style: AppTextStyles.caption(responsive).copyWith(
															color: selected
																	? _ServiceLogo.brandColor(service)
																	: AppColors.textSecondary,
															fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
															fontSize: responsive.text(10),
														),
														textAlign: TextAlign.center,
													),
												],
											),
										),
									),
								),
							);
						}).toList(),
					)),
					SizedBox(height: responsive.h(16)),
					_InputField(
						responsive: responsive,
						prefix: '🇧🇯 +229',
						hintText: '01 97 XX XX XX',
						controller: controller.paymentContactController,
						keyboardType: TextInputType.phone,
						inputFormatters: [
							FilteringTextInputFormatter.digitsOnly,
							LengthLimitingTextInputFormatter(10),
						],
					),
				],
			),
		);
	}
}

class _ServiceLogo extends StatelessWidget {
	const _ServiceLogo({required this.service, required this.size});

	final MobileMoneyService service;
	final double size;

	static Color brandColor(MobileMoneyService s) {
		switch (s) {
			case MobileMoneyService.mtn:     return AppColors.badgeYellow;
			case MobileMoneyService.moov:    return AppColors.primary;
			case MobileMoneyService.celtiis: return AppColors.danger;
		}
	}

	static String shortLabel(MobileMoneyService s) {
		switch (s) {
			case MobileMoneyService.mtn:     return 'MTN MoMo';
			case MobileMoneyService.moov:    return 'Moov Money';
			case MobileMoneyService.celtiis: return 'Celtiis';
		}
	}

	static String _assetPath(MobileMoneyService s) {
		switch (s) {
			case MobileMoneyService.mtn:     return 'assets/images/operators/mtn.png';
			case MobileMoneyService.moov:    return 'assets/images/operators/moov.png';
			case MobileMoneyService.celtiis: return 'assets/images/operators/celtiis.jpg';
		}
	}

	@override
	Widget build(BuildContext context) {
		return SizedBox(
			width: size,
			height: size,
			child: ClipRRect(
				borderRadius: BorderRadius.circular(size * 0.18),
				child: Image.asset(
					_assetPath(service),
					fit: BoxFit.contain,
					errorBuilder: (context, error, stack) => _FallbackLogo(service: service, size: size),
				),
			),
		);
	}
}

class _FallbackLogo extends StatelessWidget {
	const _FallbackLogo({required this.service, required this.size});

	final MobileMoneyService service;
	final double size;

	@override
	Widget build(BuildContext context) {
		final color = _ServiceLogo.brandColor(service);
		final isDark = service == MobileMoneyService.mtn;

		switch (service) {
			case MobileMoneyService.mtn:
				return _MtnFallback(size: size, color: color, isDark: isDark);
			case MobileMoneyService.moov:
				return _MoovFallback(size: size, color: color);
			case MobileMoneyService.celtiis:
				return _CeltisFallback(size: size, color: color);
		}
	}
}

// MTN — fond jaune, texte "MTN" noir gras
class _MtnFallback extends StatelessWidget {
	const _MtnFallback({required this.size, required this.color, required this.isDark});
	final double size;
	final Color color;
	final bool isDark;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: size,
			height: size,
			decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(size * 0.18)),
			child: Center(
				child: Text(
					'MTN',
					style: TextStyle(
						fontSize: size * 0.30,
						fontWeight: FontWeight.w900,
						color: AppColors.textPrimary,
						fontFamily: 'Inter',
						letterSpacing: size * 0.01,
					),
				),
			),
		);
	}
}

// Moov — fond bleu, "moov" blanc + barre bleue foncée
class _MoovFallback extends StatelessWidget {
	const _MoovFallback({required this.size, required this.color});
	final double size;
	final Color color;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: size,
			height: size,
			decoration: BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
					colors: [color, AppColors.blueDark],
				),
				borderRadius: BorderRadius.circular(size * 0.18),
			),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Text(
						'moov',
						style: TextStyle(
							fontSize: size * 0.28,
							fontWeight: FontWeight.w800,
							color: Colors.white,
							fontFamily: 'Inter',
							letterSpacing: -size * 0.01,
						),
					),
					Text(
						'money',
						style: TextStyle(
							fontSize: size * 0.16,
							fontWeight: FontWeight.w500,
							color: Colors.white.withValues(alpha: 0.85),
							fontFamily: 'Inter',
						),
					),
				],
			),
		);
	}
}

// Celtiis — fond rouge, "celtiis" blanc
class _CeltisFallback extends StatelessWidget {
	const _CeltisFallback({required this.size, required this.color});
	final double size;
	final Color color;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: size,
			height: size,
			decoration: BoxDecoration(
				gradient: LinearGradient(
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
					colors: [color, AppColors.dangerDark],
				),
				borderRadius: BorderRadius.circular(size * 0.18),
			),
			child: Center(
				child: Text(
					'celtiis',
					style: TextStyle(
						fontSize: size * 0.22,
						fontWeight: FontWeight.w700,
						color: Colors.white,
						fontFamily: 'Inter',
						letterSpacing: size * 0.005,
					),
				),
			),
		);
	}
}

class _CardPaymentCard extends StatelessWidget {
	const _CardPaymentCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ConfirmationReservationController controller;

	@override
	Widget build(BuildContext context) {
		return _SectionCard(
			responsive: responsive,
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Container(
						width: responsive.w(44),
						height: responsive.w(44),
						decoration: BoxDecoration(
							color: AppColors.primary.withValues(alpha: 0.08),
							borderRadius: BorderRadius.circular(responsive.radius(12)),
						),
						child: Icon(Icons.credit_card_rounded, color: AppColors.primary, size: responsive.text(22)),
					),
					SizedBox(width: responsive.w(14)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('Carte Visa / MasterCard', style: AppTextStyles.subtitle(responsive)),
								SizedBox(height: responsive.h(6)),
								Text(
									'Vous serez redirigé vers la page sécurisée FedaPay pour saisir vos informations de carte bancaire.',
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.textSecondary,
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

// ── Security ───────────────────────────────────────────────────────────────

class _SecurityCard extends StatelessWidget {
	const _SecurityCard({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: AppColors.primaryLight,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.primaryMedium),
					borderRadius: BorderRadius.circular(responsive.radius(14)),
				),
			),
			child: Row(
				children: [
					Icon(Icons.lock_rounded, size: responsive.text(18), color: AppColors.primary),
					SizedBox(width: responsive.w(10)),
					Expanded(
						child: Text(
							'Paiement 100% sécurisé · Chiffrement SSL 256-bit',
							style: AppTextStyles.caption(responsive).copyWith(
								color: AppColors.primary,
								fontWeight: FontWeight.w500,
							),
						),
					),
				],
			),
		);
	}
}

// ── Processing overlay ─────────────────────────────────────────────────────

class _ProcessingOverlay extends StatelessWidget {
	const _ProcessingOverlay({required this.responsive});

	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Positioned.fill(
			child: Container(
				color: Colors.black.withValues(alpha: 0.45),
				child: Center(
					child: Container(
						padding: EdgeInsets.all(responsive.w(32)),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.circular(responsive.radius(20)),
						),
						child: Column(
							mainAxisSize: MainAxisSize.min,
							children: [
								const SizedBox(
									width: 48,
									height: 48,
									child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
								),
								SizedBox(height: responsive.h(20)),
								Text(
									'Traitement du paiement…',
									style: AppTextStyles.subtitle(responsive),
								),
								SizedBox(height: responsive.h(4)),
								Text(
									'Ne fermez pas l\'application',
									style: AppTextStyles.caption(responsive),
								),
							],
						),
					),
				),
			),
		);
	}
}

// ── Shared card & field widgets ────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
	const _SectionCard({required this.responsive, required this.child});

	final AppResponsive responsive;
	final Widget child;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.adaptive(phone: 20, smallPhone: 18, tablet: 20, desktop: 20)),
			decoration: ShapeDecoration(
				color: AppColors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(20)),
				),
				shadows: const [BoxShadow(color: AppColors.shadowSoft, blurRadius: 12, offset: Offset(0, 2))],
			),
			child: child,
		);
	}
}

class _InputField extends StatelessWidget {
	const _InputField({
		required this.responsive,
		required this.prefix,
		required this.hintText,
		required this.controller,
		required this.keyboardType,
		required this.inputFormatters,
	});

	final AppResponsive responsive;
	final String prefix;
	final String hintText;
	final TextEditingController controller;
	final TextInputType keyboardType;
	final List<TextInputFormatter> inputFormatters;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(14), vertical: responsive.h(12)),
			decoration: ShapeDecoration(
				color: AppColors.surfaceMuted,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(12)),
				),
			),
			child: Row(
				children: [
					Text(
						prefix,
						style: AppTextStyles.body(responsive).copyWith(color: AppColors.textSecondary),
					),
					Container(
						height: responsive.h(20),
						width: 1,
						color: AppColors.border,
						margin: EdgeInsets.symmetric(horizontal: responsive.w(10)),
					),
					Expanded(
						child: TextField(
							controller: controller,
							keyboardType: keyboardType,
							inputFormatters: inputFormatters,
							style: AppTextStyles.subtitle(responsive),
							decoration: InputDecoration(
								isDense: true,
								border: InputBorder.none,
								hintText: hintText,
								hintStyle: AppTextStyles.subtitle(responsive).copyWith(color: AppColors.textHint),
							),
						),
					),
				],
			),
		);
	}
}

class _StatusBadge extends StatelessWidget {
	const _StatusBadge({required this.label, required this.color, required this.responsive});

	final String label;
	final Color color;
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(4)),
			decoration: ShapeDecoration(
				color: color.withValues(alpha: 0.10),
				shape: RoundedRectangleBorder(
					side: BorderSide(color: color.withValues(alpha: 0.30)),
					borderRadius: BorderRadius.circular(9999),
				),
			),
			child: Text(
				label,
				style: AppTextStyles.caption(responsive).copyWith(color: color, fontWeight: FontWeight.w600),
			),
		);
	}
}

// ── Helpers ────────────────────────────────────────────────────────────────

String _formatAmount(int value) {
	return value.toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
}


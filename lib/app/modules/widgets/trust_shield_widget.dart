import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

/// Bannière réutilisable "Trajet protégé MINIZON".
/// Affiche un badge rassurant avec lien optionnel vers l'espace confiance.
class TrustShieldWidget extends StatelessWidget {
	const TrustShieldWidget({
		super.key,
		required this.responsive,
		this.showLearnMore = true,
		this.compact = false,
	});

	final AppResponsive responsive;
	final bool showLearnMore;
	final bool compact;

	@override
	Widget build(BuildContext context) {
		if (compact) return _CompactBadge(responsive: responsive);
		return _FullBanner(responsive: responsive, showLearnMore: showLearnMore);
	}
}

class _FullBanner extends StatelessWidget {
	const _FullBanner({required this.responsive, required this.showLearnMore});
	final AppResponsive responsive;
	final bool showLearnMore;

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
						width: responsive.w(38),
						height: responsive.w(38),
						decoration: BoxDecoration(
							color: AppColors.primary.withValues(alpha: 0.12),
							shape: BoxShape.circle,
						),
						child: Icon(Icons.shield_rounded, color: AppColors.primary, size: responsive.text(20)),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(
									'Trajet protégé MINIZON',
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w700,
									),
								),
								SizedBox(height: responsive.h(2)),
								Text(
									'Remboursement garanti · Conducteur vérifié · Support 24/7',
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.textSecondary,
										fontSize: responsive.text(11),
										height: 1.4,
									),
								),
							],
						),
					),
					if (showLearnMore) ...[
						SizedBox(width: responsive.w(8)),
						InkWell(
							onTap: () => Get.toNamed(AppRoutes.passengerTrustHub),
							borderRadius: BorderRadius.circular(8),
							child: Padding(
								padding: EdgeInsets.all(responsive.w(4)),
								child: Text(
									'En savoir +',
									style: AppTextStyles.caption(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w600,
										decoration: TextDecoration.underline,
										decorationColor: AppColors.primary,
										fontSize: responsive.text(11),
									),
								),
							),
						),
					],
				],
			),
		);
	}
}

class _CompactBadge extends StatelessWidget {
	const _CompactBadge({required this.responsive});
	final AppResponsive responsive;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: responsive.w(10), vertical: responsive.h(5)),
			decoration: BoxDecoration(
				color: const Color(0xFFF0FDF8),
				borderRadius: BorderRadius.circular(9999),
				border: Border.all(color: const Color(0x3300A86B)),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Icon(Icons.shield_rounded, color: AppColors.primary, size: responsive.text(12)),
					SizedBox(width: responsive.w(5)),
					Text(
						'Trajet protégé',
						style: AppTextStyles.caption(responsive).copyWith(
							color: AppColors.primary,
							fontWeight: FontWeight.w600,
							fontSize: responsive.text(11),
						),
					),
				],
			),
		);
	}
}

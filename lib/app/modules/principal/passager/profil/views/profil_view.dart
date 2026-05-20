import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';

import '../controller/profil_controller.dart';

class ProfilView extends GetView<ProfilController> {
	const ProfilView({super.key});

	@override
	Widget build(BuildContext context) {
		final AppResponsive responsive = AppResponsive(context);
		final double pagePadding = responsive.adaptive(
			phone: 16,
			smallPhone: 14,
			tablet: 24,
			desktop: 32,
		);

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: SingleChildScrollView(
					child: Center(
						child: ConstrainedBox(
							constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.stretch,
								children: [
									_HeaderSection(responsive: responsive, controller: controller),
									Transform.translate(
										offset: Offset(0, -responsive.h(40)),
										child: Padding(
											padding: EdgeInsets.symmetric(horizontal: pagePadding),
											child: Column(
												crossAxisAlignment: CrossAxisAlignment.stretch,
												children: [
													_SummaryCard(responsive: responsive, controller: controller),
													SizedBox(height: responsive.h(24)),
													_StatCard(responsive: responsive, controller: controller, value: '', label: '', leadingIcon: null,),
													SizedBox(height: responsive.h(24)),
													_TrustCard(responsive: responsive, controller: controller),
													SizedBox(height: responsive.h(24)),
													_SettingsCard(responsive: responsive, controller: controller),
													SizedBox(height: responsive.h(24)),
													_PaymentMethodsCard(responsive: responsive, controller: controller),
													SizedBox(height: responsive.h(24)),
													_RecentTripsCard(responsive: responsive, controller: controller),
												],
											),
										),
									),
								],
							),
						),
					),
				),
			),
		);
	}
}

class _HeaderSection extends StatelessWidget {
	const _HeaderSection({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ProfilController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.only(
				top: responsive.adaptive(phone: 48, smallPhone: 42, tablet: 56, desktop: 64),
				left: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				right: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
				bottom: responsive.adaptive(phone: 80, smallPhone: 72, tablet: 88, desktop: 96),
			),
			decoration: const ShapeDecoration(
				gradient: LinearGradient(
					begin: Alignment.topLeft,
					end: Alignment.bottomRight,
					colors: [Color(0xFF00A86B), Color(0xFF008F5A)],
				),
				shape: RoundedRectangleBorder(
					side: BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.only(
						bottomLeft: Radius.circular(24),
						bottomRight: Radius.circular(24),
					),
				),
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						crossAxisAlignment: CrossAxisAlignment.center,
						children: [
							Text(
								AppStrings.passengerProfileTitle,
								style: AppTextStyles.profileHeroTitle(responsive).copyWith(
									fontSize: responsive.text(20),
								),
							),
							_HeaderIconButton(
								responsive: responsive,
								icon: Icons.settings_rounded,
								onTap: controller.openSecurity,
							),
						],
					),
				],
			),
		);
	}
}

class _SummaryCard extends StatelessWidget {
	const _SummaryCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ProfilController controller;

	@override
	Widget build(BuildContext context) {
		final summary = controller.profileSummary;

		return Container(
			padding: EdgeInsets.all(responsive.adaptive(phone: 24, smallPhone: 20, tablet: 26, desktop: 28)),
			decoration: ShapeDecoration(
				color: Colors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
				shadows: const [
					BoxShadow(color: Color(0x19000000), blurRadius: 25, offset: Offset(0, 20)),
					BoxShadow(color: Color(0x19000000), blurRadius: 10, offset: Offset(0, 8)),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.center,
				children: [
					Stack(
						clipBehavior: Clip.none,
						alignment: Alignment.center,
						children: [
							Container(
								width: responsive.w(96),
								height: responsive.w(96),
								clipBehavior: Clip.antiAlias,
								decoration: ShapeDecoration(
									shape: RoundedRectangleBorder(
										side: const BorderSide(width: 4, color: Colors.white),
										borderRadius: BorderRadius.circular(9999),
									),
									shadows: const [
										BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
										BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
									],
								),
								child: Image.network(summary.avatarUrl, fit: BoxFit.cover),
							),
							Positioned(
								right: -responsive.w(2),
								bottom: -responsive.w(2),
								child: Container(
									width: responsive.w(28),
									height: responsive.w(28),
									padding: EdgeInsets.all(responsive.w(6)),
									decoration: const ShapeDecoration(
										color: AppColors.primary,
										shape: RoundedRectangleBorder(
											side: BorderSide(color: AppColors.border),
											borderRadius: BorderRadius.all(Radius.circular(9999)),
										),
										shadows: [
											BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
											BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
										],
									),
									child: const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
								),
							),
						],
					),
					SizedBox(height: responsive.h(12)),
					Text(
						summary.name,
						style: AppTextStyles.profileSectionTitle(responsive).copyWith(
							fontSize: responsive.text(20),
						),
					),
					SizedBox(height: responsive.h(4)),
					Text(summary.phone, style: AppTextStyles.profileMeta(responsive)),
					SizedBox(height: responsive.h(12)),
					Container(
						padding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(8)),
						decoration: ShapeDecoration(
							color: const Color(0x1900A86B),
							shape: RoundedRectangleBorder(
								side: const BorderSide(color: AppColors.border),
								borderRadius: BorderRadius.circular(9999),
							),
						),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							children: [
								Container(
									width: responsive.w(12),
									height: responsive.w(12),
									decoration: const ShapeDecoration(
										color: AppColors.primary,
										shape: CircleBorder(),
									),
								),
								SizedBox(width: responsive.w(8)),
								Text(
									AppStrings.passengerProfileVerified,
									style: AppTextStyles.profileMeta(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w600,
									),
								),
							],
						),
					),
					SizedBox(height: responsive.h(24)),
					Row(
						children: [
							Expanded(
								child: _StatCard(
									responsive: responsive,
									value: controller.metrics[0].value,
									label: controller.metrics[0].label,
									leadingIcon: Icons.star_rounded,
                  trailingStars: true, controller: controller,
								),
							),
							SizedBox(width: responsive.w(16)),
							Expanded(
								child: _StatCard(
									responsive: responsive,
									value: controller.metrics[1].value,
									label: controller.metrics[1].label,
									leadingIcon: Icons.route_rounded, controller: null,
								),
							),
						],
					),
				],
			),
		);
	}
}




class _StatCard extends StatelessWidget {
	const _StatCard({
		required this.responsive,
		required this.value,
		required this.label,
		required this.leadingIcon,
		this.trailingStars = false, required ProfilController controller,
	});

	final AppResponsive responsive;
	final String value;
	final String label;
	final IconData leadingIcon;
	final bool trailingStars;

	@override
	Widget build(BuildContext context) {
		return Container(
			height: responsive.adaptive(phone: 108, smallPhone: 100, tablet: 112, desktop: 120),
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: const Color(0x7FF5F5F5),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Column(
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Text(
						value,
						textAlign: TextAlign.center,
						style: AppTextStyles.profileSectionTitle(responsive).copyWith(
							fontSize: responsive.text(24),
						),
					),
					SizedBox(height: responsive.h(4)),
					if (trailingStars)
						Row(
							mainAxisAlignment: MainAxisAlignment.center,
							children: [
								Icon(leadingIcon, size: responsive.text(16), color: const Color(0xFFF4B400)),
								SizedBox(width: responsive.w(4)),
								Text(label, style: AppTextStyles.profileMeta(responsive)),
							],
						)
					else
						Text(
							label,
							textAlign: TextAlign.center,
							style: AppTextStyles.profileMeta(responsive).copyWith(color: AppColors.textSecondary),
						),
				],
			),
		);
	}
}

class _TrustCard extends StatelessWidget {
	const _TrustCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ProfilController controller;

	@override
	Widget build(BuildContext context) {
		final trust = controller.trustCard;

		return Container(
			padding: EdgeInsets.all(responsive.w(24)),
			decoration: ShapeDecoration(
				color: Colors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
				shadows: const [
					BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
					BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text(
								trust.title,
								style: AppTextStyles.profileSectionTitle(responsive),
							),
							Container(
								padding: EdgeInsets.symmetric(horizontal: responsive.w(12), vertical: responsive.h(4)),
								decoration: ShapeDecoration(
									color: const Color(0x1900A86B),
									shape: RoundedRectangleBorder(
										side: const BorderSide(color: AppColors.border),
										borderRadius: BorderRadius.circular(9999),
									),
								),
								child: Text(
									trust.level,
									style: AppTextStyles.profileMeta(responsive).copyWith(
										color: AppColors.primary,
										fontWeight: FontWeight.w600,
									),
								),
							),
						],
					),
					SizedBox(height: responsive.h(16)),
					_TrustLine(responsive: responsive, title: trust.verifiedNumber),
					SizedBox(height: responsive.h(12)),
					_TrustLine(responsive: responsive, title: trust.identityDocument),
					SizedBox(height: responsive.h(12)),
					_TrustLine(responsive: responsive, title: trust.verifiedEmail),
				],
			),
		);
	}
}

class _TrustLine extends StatelessWidget {
	const _TrustLine({required this.responsive, required this.title});

	final AppResponsive responsive;
	final String title;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(16)),
			decoration: ShapeDecoration(
				color: const Color(0x7FF5F5F5),
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Row(
				children: [
					Container(
						width: responsive.w(32),
						height: responsive.w(32),
						decoration: const ShapeDecoration(
							color: Color(0x1900A86B),
							shape: CircleBorder(),
						),
						child: const Icon(Icons.verified_rounded, color: AppColors.primary, size: 18),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Text(
							title,
							style: AppTextStyles.profileFieldValue(responsive).copyWith(
								color: AppColors.textSecondary,
							),
						),
					),
					const Icon(Icons.chevron_right_rounded, color: AppColors.textGhost),
				],
			),
		);
	}
}

class _SettingsCard extends StatelessWidget {
	const _SettingsCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ProfilController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(24)),
			decoration: ShapeDecoration(
				color: Colors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
				shadows: const [
					BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
					BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text(AppStrings.passengerProfileSettingsTitle, style: AppTextStyles.profileSectionTitle(responsive)),
							const SizedBox.shrink(),
						],
					),
					SizedBox(height: responsive.h(16)),
					for (int index = 0; index < controller.settings.length; index++) ...[
						_SettingsTile(
							responsive: responsive,
							icon: _settingIcon(controller.settings[index].icon),
							title: controller.settings[index].title,
							onTap: () => _settingAction(controller, controller.settings[index].icon),
						),
						if (index != controller.settings.length - 1) SizedBox(height: responsive.h(12)),
					],
				],
			),
		);
	}
}

class _SettingsTile extends StatelessWidget {
	const _SettingsTile({
		required this.responsive,
		required this.icon,
		required this.title,
		required this.onTap,
	});

	final AppResponsive responsive;
	final IconData icon;
	final String title;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(responsive.radius(16)),
			child: Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.w(16)),
				decoration: ShapeDecoration(
					color: const Color(0x7FF5F5F5),
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: AppColors.border),
						borderRadius: BorderRadius.circular(responsive.radius(16)),
					),
				),
				child: Row(
					children: [
						Container(
							width: responsive.w(40),
							height: responsive.w(40),
							decoration: const ShapeDecoration(
								color: Color(0x1900A86B),
								shape: CircleBorder(),
							),
							child: Icon(icon, color: AppColors.primary, size: responsive.text(18)),
						),
						SizedBox(width: responsive.w(12)),
						Expanded(
							child: Text(title, style: AppTextStyles.profileFieldValue(responsive)),
						),
						const Icon(Icons.chevron_right_rounded, color: AppColors.textGhost),
					],
				),
			),
		);
	}
}

IconData _settingIcon(String key) {
	switch (key) {
		case 'edit':
			return Icons.edit_outlined;
		case 'shield':
			return Icons.shield_outlined;
		case 'notifications':
			return Icons.notifications_none_rounded;
		case 'support':
			return Icons.support_agent_rounded;
		default:
			return Icons.chevron_right_rounded;
	}
}

void _settingAction(ProfilController controller, String key) {
	switch (key) {
		case 'edit':
			controller.editProfile();
			break;
		case 'shield':
			controller.openSecurity();
			break;
		case 'notifications':
			controller.openNotifications();
			break;
		case 'support':
			controller.openSupport();
			break;
	}
}

class _PaymentMethodsCard extends StatelessWidget {
	const _PaymentMethodsCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ProfilController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(24)),
			decoration: ShapeDecoration(
				color: Colors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
				shadows: const [
					BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
					BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text(AppStrings.passengerProfilePaymentTitle, style: AppTextStyles.profileSectionTitle(responsive)),
							InkWell(
								onTap: controller.addPaymentMethod,
								child: Padding(
									padding: EdgeInsets.symmetric(vertical: responsive.h(4)),
									child: Text(
										AppStrings.passengerProfileAdd,
										style: AppTextStyles.profileMeta(responsive).copyWith(
											color: AppColors.primary,
											fontWeight: FontWeight.w600,
										),
									),
								),
							),
						],
					),
					SizedBox(height: responsive.h(16)),
					for (int index = 0; index < controller.paymentMethods.length; index++) ...[
						_PaymentTile(responsive: responsive, method: controller.paymentMethods[index]),
						if (index != controller.paymentMethods.length - 1) SizedBox(height: responsive.h(12)),
					],
				],
			),
		);
	}
}

class _PaymentTile extends StatelessWidget {
	const _PaymentTile({required this.responsive, required this.method});

	final AppResponsive responsive;
	final PaymentMethod method;

	@override
	Widget build(BuildContext context) {
		return Container(
			width: double.infinity,
			padding: EdgeInsets.all(responsive.w(12)),
			decoration: ShapeDecoration(
				color: const Color(0x4CF5F5F5),
				shape: RoundedRectangleBorder(
					side: BorderSide(color: method.selected ? const Color(0x3300A86B) : AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(16)),
				),
			),
			child: Row(
				children: [
					Container(
						width: responsive.w(40),
						height: responsive.w(32),
						alignment: Alignment.center,
						decoration: ShapeDecoration(
							gradient: LinearGradient(
								begin: const Alignment(-0.00, 0.50),
								end: const Alignment(1.00, 0.50),
								colors: [Color(method.accentStart), Color(method.accentEnd)],
							),
							shape: RoundedRectangleBorder(
								side: const BorderSide(color: AppColors.border),
								borderRadius: BorderRadius.circular(responsive.radius(8)),
							),
						),
						child: Text(
							method.provider,
							style: AppTextStyles.caption(responsive).copyWith(
								color: Colors.white,
								fontWeight: FontWeight.w700,
							),
						),
					),
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text(method.title, style: AppTextStyles.profileFieldValue(responsive).copyWith(fontWeight: FontWeight.w600)),
								SizedBox(height: responsive.h(2)),
								Text(method.subtitle, style: AppTextStyles.profileMeta(responsive)),
							],
						),
					),
					Container(
						width: responsive.w(24),
						height: responsive.w(24),
						decoration: ShapeDecoration(
							color: method.selected ? AppColors.primary : Colors.white,
							shape: RoundedRectangleBorder(
								side: BorderSide(color: method.selected ? AppColors.primary : AppColors.border),
								borderRadius: BorderRadius.circular(9999),
							),
						),
						child: Icon(
							method.selected ? Icons.check_rounded : Icons.circle_outlined,
							color: Colors.white,
							size: responsive.text(12),
						),
					),
				],
			),
		);
	}
}

class _RecentTripsCard extends StatelessWidget {
	const _RecentTripsCard({required this.responsive, required this.controller});

	final AppResponsive responsive;
	final ProfilController controller;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: EdgeInsets.all(responsive.w(24)),
			decoration: ShapeDecoration(
				color: Colors.white,
				shape: RoundedRectangleBorder(
					side: const BorderSide(color: AppColors.border),
					borderRadius: BorderRadius.circular(responsive.radius(24)),
				),
				shadows: const [
					BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
					BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: MainAxisAlignment.spaceBetween,
						children: [
							Text(AppStrings.passengerProfileRecentTripsTitle, style: AppTextStyles.profileSectionTitle(responsive)),
							InkWell(
								onTap: controller.viewAllTrips,
								child: Padding(
									padding: EdgeInsets.symmetric(vertical: responsive.h(4)),
									child: Text(
										AppStrings.passengerProfileSeeAll,
										style: AppTextStyles.profileMeta(responsive).copyWith(
											color: AppColors.primary,
											fontWeight: FontWeight.w600,
										),
									),
								),
							),
						],
					),
					SizedBox(height: responsive.h(16)),
					for (int index = 0; index < controller.recentTrips.length; index++) ...[
						_RecentTripTile(
							responsive: responsive,
							trip: controller.recentTrips[index],
							onTap: () => controller.openTrip(controller.recentTrips[index]),
						),
						if (index != controller.recentTrips.length - 1) SizedBox(height: responsive.h(16)),
					],
				],
			),
		);
	}
}

class _RecentTripTile extends StatelessWidget {
	const _RecentTripTile({required this.responsive, required this.trip, required this.onTap});

	final AppResponsive responsive;
	final RecentTrip trip;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(responsive.radius(16)),
			child: Container(
				width: double.infinity,
				padding: EdgeInsets.all(responsive.w(16)),
				decoration: ShapeDecoration(
					color: const Color(0x7FF5F5F5),
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: AppColors.border),
						borderRadius: BorderRadius.circular(responsive.radius(16)),
					),
				),
				child: Row(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						Column(
							children: [
								Container(
									width: responsive.w(12),
									height: responsive.w(12),
									decoration: const ShapeDecoration(
										color: AppColors.primary,
										shape: CircleBorder(),
									),
								),
								Container(width: responsive.w(1), height: responsive.h(32), color: AppColors.border),
								Container(
									width: responsive.w(12),
									height: responsive.w(12),
									decoration: const ShapeDecoration(
										color: Color(0xFFE53935),
										shape: CircleBorder(),
									),
								),
							],
						),
						SizedBox(width: responsive.w(12)),
						Expanded(
							child: Column(
								crossAxisAlignment: CrossAxisAlignment.start,
								children: [
									Row(
										mainAxisAlignment: MainAxisAlignment.spaceBetween,
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Expanded(
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														Text(trip.title, style: AppTextStyles.profileFieldValue(responsive).copyWith(fontWeight: FontWeight.w600)),
														SizedBox(height: responsive.h(2)),
														Text(trip.time, style: AppTextStyles.profileMeta(responsive)),
													],
												),
											),
											Text(
												trip.price,
												style: AppTextStyles.profileFieldValue(responsive).copyWith(
													color: AppColors.primary,
													fontWeight: FontWeight.w700,
												),
											),
										],
									),
									SizedBox(height: responsive.h(8)),
									Row(
										children: [
											Row(
												children: [
													Icon(Icons.star_rounded, size: responsive.text(14), color: const Color(0xFFF4B400)),
													SizedBox(width: responsive.w(4)),
													Text(trip.rating, style: AppTextStyles.profileMeta(responsive)),
												],
											),
											SizedBox(width: responsive.w(16)),
											Text(trip.driver, style: AppTextStyles.profileMeta(responsive)),
										],
									),
								],
							),
						),
					],
				),
			),
		);
	}
}

class _HeaderIconButton extends StatelessWidget {
	const _HeaderIconButton({required this.responsive, required this.icon, required this.onTap});

	final AppResponsive responsive;
	final IconData icon;
	final VoidCallback onTap;

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: onTap,
			borderRadius: BorderRadius.circular(9999),
			child: Container(
				width: responsive.w(40),
				height: responsive.w(40),
				padding: EdgeInsets.all(responsive.w(8)),
				decoration: ShapeDecoration(
					color: Colors.white.withValues(alpha: 0.20),
					shape: RoundedRectangleBorder(
						side: const BorderSide(color: AppColors.border),
						borderRadius: BorderRadius.circular(9999),
					),
				),
				child: Icon(icon, color: Colors.white, size: responsive.text(18)),
			),
		);
	}
}

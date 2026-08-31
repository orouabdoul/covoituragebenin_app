import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/auth/register/controllers/input_phone_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class InputPhoneView extends GetView<InputPhoneController> {
	const InputPhoneView({super.key});
	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);
		return Scaffold(
			backgroundColor: AppColors.surfaceMuted,
			body: SafeArea(
				child: Container(
					decoration: const BoxDecoration(
						gradient: LinearGradient(
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
							colors: [AppColors.primary, AppColors.success],
						),
					),
					child: SingleChildScrollView(
						child: Column(
							children: [
								Padding(
									padding: EdgeInsets.fromLTRB(
										responsive.w(24),
										responsive.h(24),
										responsive.w(24),
										responsive.h(32),
									),
									child: Column(
										children: [
											ClipRRect(
												borderRadius: BorderRadius.circular(responsive.radius(16)),
												child: Image.asset(
													'assets/minizon/icon.png',
													width: responsive.w(80),
													height: responsive.w(80),
													fit: BoxFit.cover,
												),
											),
											SizedBox(height: responsive.h(16)),
											Text(AppStrings.registerWelcome, textAlign: TextAlign.center, style: AppTextStyles.registerHeroTitle(responsive).copyWith(color: AppColors.white)),
											Text(AppStrings.appName, textAlign: TextAlign.center, style: AppTextStyles.registerBrand(responsive).copyWith(color: AppColors.white)),
											SizedBox(height: responsive.h(8)),
											Obx(() => Text(
									'Votre covoiturage sécurisé en \n${controller.selectedCountryName.value}',
									textAlign: TextAlign.center,
									style: AppTextStyles.registerTagline(responsive).copyWith(color: Colors.white.withAlpha(217)),
								)),
										],
									),
								),
								Container(
									width: double.infinity,
									padding: EdgeInsets.fromLTRB(
										responsive.w(24),
										responsive.h(32),
										responsive.w(24),
										responsive.h(48),
									),
									decoration: ShapeDecoration(
										color: AppColors.white,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.only(
												topLeft: Radius.circular(responsive.radius(32)),
												topRight: Radius.circular(responsive.radius(32)),
											),
										),
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(AppStrings.registerTitle, style: AppTextStyles.registerSectionTitle(responsive)),
											SizedBox(height: responsive.h(8)),
											Text(AppStrings.registerSubtitle, style: AppTextStyles.registerBody(responsive)),
											SizedBox(height: responsive.h(24)),
											GestureDetector(
												onTap: controller.selectCountry,
												child: AppField(
													responsive: responsive,
													label: AppStrings.registerCountryLabel,
													labelStyle: AppTextStyles.registerLabel(responsive),
													child: Obx(() => Row(
														children: [
															Text(controller.selectedCountryFlag.value, style: AppTextStyles.registerSectionTitle(responsive).copyWith(fontSize: responsive.text(24))),
															SizedBox(width: responsive.w(12)),
															Expanded(child: Text(controller.selectedCountryDisplay.value, style: AppTextStyles.registerBody(responsive).copyWith(color: AppColors.textStrong, fontWeight: FontWeight.w500))),
															Icon(Icons.keyboard_arrow_down_rounded, size: responsive.text(20), color: AppColors.textHint),
														],
													)),
												),
											),
											SizedBox(height: responsive.h(16)),
											AppField(
												responsive: responsive,
												label: AppStrings.registerPhoneLabel,
												labelStyle: AppTextStyles.registerLabel(responsive),
												helperText: AppStrings.registerPhoneHelp,
												helperStyle: AppTextStyles.registerHelp(responsive),
												child: TextField(
													controller: controller.phoneController,
													onChanged: controller.onPhoneChanged,
													keyboardType: TextInputType.number,
													inputFormatters: [
														FilteringTextInputFormatter.digitsOnly,
														LengthLimitingTextInputFormatter(10),
													],
													style: AppTextStyles.registerField(responsive),
													decoration: InputDecoration(
														border: InputBorder.none,
														enabledBorder: InputBorder.none,
														focusedBorder: InputBorder.none,
														disabledBorder: InputBorder.none,
														errorBorder: InputBorder.none,
														focusedErrorBorder: InputBorder.none,
														filled: false,
														isDense: true,
														contentPadding: EdgeInsets.zero,
														hintText: AppStrings.registerPhoneHint,
														hintStyle: AppTextStyles.registerField(responsive).copyWith(color: AppColors.textGhost),
													),
												),
											),
											Obx(() {
												if (!controller.hasStartedTyping.value) return const SizedBox.shrink();
												return Padding(
													padding: EdgeInsets.only(top: responsive.h(10)),
													child: _PhoneValidationBar(
														cond1: controller.condStartsWith01.value,
														cond2: controller.condPrefix.value,
														cond3: controller.condLength.value,
													),
												);
											}),
											SizedBox(height: responsive.h(24)),
											Obx(
												() => AppPrimaryButton(
													responsive: responsive,
													label: AppStrings.rolesContinue,
													enabled: controller.canContinueRx.value,
													onTap: controller.continueWithPhone,
												),
											),
											SizedBox(height: responsive.h(24)),
											Center(child: Text(AppStrings.registerAlternative, style: AppTextStyles.registerBody(responsive))),
											SizedBox(height: responsive.h(16)),
											OutlinedButton.icon(
												style: OutlinedButton.styleFrom(
													side: const BorderSide(width: 2, color: Colors.transparent),
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(responsive.radius(16)),
													),
													minimumSize: Size(double.infinity, responsive.h(56)),
													foregroundColor: AppColors.textSecondary,
												),
												onPressed: controller.continueWithEmail,
												icon: Icon(Icons.email_outlined, size: responsive.text(18)),
												label: Text(AppStrings.registerEmail, style: AppTextStyles.registerLabel(responsive).copyWith(fontSize: responsive.text(16))),
											),
											SizedBox(height: responsive.h(20)),
											Text.rich(
												TextSpan(
													style: AppTextStyles.registerBody(responsive).copyWith(fontSize: responsive.text(14)),
													children: [
														const TextSpan(text: AppStrings.registerTermsPrefix),
														TextSpan(text: AppStrings.registerTerms, style: AppTextStyles.registerBody(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: responsive.text(14))),
														const TextSpan(text: AppStrings.registerAnd),
														TextSpan(text: AppStrings.registerPrivacy, style: AppTextStyles.registerBody(responsive).copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: responsive.text(14))),
													],
												),
												textAlign: TextAlign.center,
											),
											SizedBox(height: responsive.h(24)),
											Center(
												child: Row(
													mainAxisSize: MainAxisSize.min,
													children: [
														Icon(Icons.verified_user_outlined, size: responsive.text(14), color: AppColors.textGhost),
														SizedBox(width: responsive.w(8)),
														Text(AppStrings.registerSsl, style: AppTextStyles.registerMuted(responsive)),
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

class _PhoneValidationBar extends StatelessWidget {
	final bool cond1; // commence par 01
	final bool cond2; // préfixe opérateur valide
	final bool cond3; // 10 chiffres

	const _PhoneValidationBar({
		required this.cond1,
		required this.cond2,
		required this.cond3,
	});

	bool get _allValid => cond1 && cond2 && cond3;

	String get _message {
		if (!cond1) return 'Le numéro doit commencer par 01';
		if (!cond2) return 'Préfixe opérateur non reconnu (MTN, Moov, Celtiis)';
		if (!cond3) return 'Continuez la saisie…';
		return 'Numéro valide';
	}

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			mainAxisSize: MainAxisSize.min,
			children: [
				Row(
					children: [
						_PhoneSegment(filled: cond1),
						const SizedBox(width: 5),
						_PhoneSegment(filled: cond2),
						const SizedBox(width: 5),
						_PhoneSegment(filled: cond3),
					],
				),
				const SizedBox(height: 7),
				AnimatedSwitcher(
					duration: const Duration(milliseconds: 250),
					transitionBuilder: (child, anim) => FadeTransition(
						opacity: anim,
						child: SlideTransition(
							position: Tween<Offset>(
								begin: const Offset(0, 0.3),
								end: Offset.zero,
							).animate(anim),
							child: child,
						),
					),
					child: Row(
						key: ValueKey(_message),
						mainAxisSize: MainAxisSize.min,
						children: [
							if (_allValid)
								Padding(
									padding: const EdgeInsets.only(right: 5),
									child: Icon(
										Icons.check_circle_rounded,
										size: 13,
										color: AppColors.success,
									),
								),
							Text(
								_message,
								style: TextStyle(
									fontSize: 12,
									color: _allValid ? AppColors.success : AppColors.textSecondary,
									fontWeight: _allValid ? FontWeight.w600 : FontWeight.w400,
								),
							),
						],
					),
				),
			],
		);
	}
}

class _PhoneSegment extends StatelessWidget {
	final bool filled;
	const _PhoneSegment({required this.filled});

	@override
	Widget build(BuildContext context) {
		return Expanded(
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 350),
				curve: Curves.easeOut,
				height: 3.5,
				decoration: BoxDecoration(
					color: filled ? AppColors.success : AppColors.border,
					borderRadius: BorderRadius.circular(9999),
				),
			),
		);
	}
}

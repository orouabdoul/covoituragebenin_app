import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/auth/register/controllers/input_phone_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InputPhoneView extends GetView<InputPhoneController> {
	const InputPhoneView({super.key});

	@override
	Widget build(BuildContext context) {
		final responsive = AppResponsive(context);

		return Scaffold(
			backgroundColor: const Color(0xFFF5F5F5),
			body: SafeArea(
				child: Container(
					decoration: const BoxDecoration(
						gradient: LinearGradient(
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
							colors: [Color(0xFF00A86B), Color(0xFF008F5A)],
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
											Container(
												width: responsive.w(80),
												height: responsive.w(80),
												decoration: ShapeDecoration(
													color: Colors.white,
													shape: RoundedRectangleBorder(
														borderRadius: BorderRadius.circular(responsive.radius(16)),
													),
													shadows: const [
														BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
														BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
													],
												),
												child: Center(
													child: Text('MZ', style: AppTextStyles.registerSectionTitle(responsive).copyWith(color: AppColors.primary)),
												),
											),
											SizedBox(height: responsive.h(16)),
											Text(AppStrings.registerWelcome, textAlign: TextAlign.center, style: AppTextStyles.registerHeroTitle(responsive)),
											Text(AppStrings.appName, textAlign: TextAlign.center, style: AppTextStyles.registerBrand(responsive)),
											SizedBox(height: responsive.h(8)),
											Text(AppStrings.registerTagline, textAlign: TextAlign.center, style: AppTextStyles.registerTagline(responsive)),
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
										color: Colors.white,
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.only(
												topLeft: Radius.circular(responsive.radius(32)),
												topRight: Radius.circular(responsive.radius(32)),
											),
										),
									),
									child: GetBuilder<InputPhoneController>(
										builder: (controller) => Column(
											crossAxisAlignment: CrossAxisAlignment.start,
											children: [
												Text(AppStrings.registerTitle, style: AppTextStyles.registerSectionTitle(responsive)),
												SizedBox(height: responsive.h(8)),
												Text(AppStrings.registerSubtitle, style: AppTextStyles.registerBody(responsive)),
												SizedBox(height: responsive.h(24)),
															AppField(
																responsive: responsive,
																label: AppStrings.registerCountryLabel,
																labelStyle: AppTextStyles.registerLabel(responsive),
																child: Row(
																	children: [
																		Text('🇧🇯', style: AppTextStyles.registerSectionTitle(responsive).copyWith(fontSize: responsive.text(24))),
																		SizedBox(width: responsive.w(12)),
																		Expanded(child: Text(AppStrings.registerCountryValue, style: AppTextStyles.registerBody(responsive).copyWith(color: Colors.black, fontWeight: FontWeight.w500))),
																		Icon(Icons.keyboard_arrow_down_rounded, size: responsive.text(20), color: const Color(0xFF6B7280)),
																	],
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
																	keyboardType: TextInputType.phone,
																	style: AppTextStyles.registerField(responsive),
																	decoration: InputDecoration.collapsed(
																		hintText: AppStrings.registerPhoneHint,
																		hintStyle: AppTextStyles.registerField(responsive).copyWith(color: const Color(0xFF9CA3AF)),
																	),
																),
															),
												SizedBox(height: responsive.h(24)),
												AppPrimaryButton(
													responsive: responsive,
													label: AppStrings.rolesContinue,
													enabled: controller.canContinue,
													onTap: controller.continueWithPhone,
												),
												SizedBox(height: responsive.h(24)),
												Center(child: Text(AppStrings.registerAlternative, style: AppTextStyles.registerBody(responsive))),
												SizedBox(height: responsive.h(16)),
												OutlinedButton.icon(
													style: OutlinedButton.styleFrom(
														side: const BorderSide(width: 2, color: AppColors.border),
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(responsive.radius(16)),
														),
														minimumSize: Size(double.infinity, responsive.h(56)),
														foregroundColor: const Color(0xFF374151),
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
															Icon(Icons.verified_user_outlined, size: responsive.text(14), color: const Color(0xFF9CA3AF)),
															SizedBox(width: responsive.w(8)),
															Text(AppStrings.registerSsl, style: AppTextStyles.registerMuted(responsive)),
														],
													),
												),
											],
										),
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

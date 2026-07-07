import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import '../controllers/edit_profile_controller.dart';

class EditProfileView extends StatelessWidget {
	const EditProfileView({super.key});

	@override
	Widget build(BuildContext context) {
		final controller = Get.isRegistered<EditProfileController>()
				? Get.find<EditProfileController>()
				: Get.put(EditProfileController());
		final responsive = AppResponsive(context);
		final formKey = GlobalKey<FormState>();

		return Scaffold(
			backgroundColor: AppColors.surface,
			body: SafeArea(
				child: Center(
					child: ConstrainedBox(
						constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
						child: Column(
							children: [
								_HeaderBar(responsive: responsive, controller: controller, formKey: formKey),
								Expanded(
									child: ListView(
										padding: EdgeInsets.symmetric(
											horizontal: responsive.adaptive(phone: 16, smallPhone: 14, tablet: 24, desktop: 32),
											vertical: responsive.h(24),
										),
										children: [
											_AvatarSection(responsive: responsive, controller: controller),
											SizedBox(height: responsive.h(24)),
											Form(
												key: formKey,
												child: Column(
													children: [
														_Field(
															responsive: responsive,
															label: 'Prénom',
															hint: 'Votre prénom',
															icon: Icons.person_outline_rounded,
															controller: controller.firstNameController,
															validator: controller.validateFirstName,
															textInputAction: TextInputAction.next,
														),
														SizedBox(height: responsive.h(16)),
														_Field(
															responsive: responsive,
															label: 'Nom',
															hint: 'Votre nom de famille',
															icon: Icons.person_outline_rounded,
															controller: controller.lastNameController,
															validator: controller.validateLastName,
															textInputAction: TextInputAction.next,
														),
														SizedBox(height: responsive.h(16)),
														_Field(
															responsive: responsive,
															label: 'Adresse e-mail',
															hint: 'votre@email.com',
															icon: Icons.email_outlined,
															controller: controller.emailController,
															keyboardType: TextInputType.emailAddress,
															textInputAction: TextInputAction.next,
														),
														SizedBox(height: responsive.h(16)),
														_Field(
															responsive: responsive,
															label: 'Ville',
															hint: 'Ex: Cotonou',
															icon: Icons.location_city_outlined,
															controller: controller.cityController,
															textInputAction: TextInputAction.next,
														),
														SizedBox(height: responsive.h(16)),
														_Field(
															responsive: responsive,
															label: 'Quartier',
															hint: 'Ex: Cadjehoun',
															icon: Icons.place_outlined,
															controller: controller.neighborhoodController,
															textInputAction: TextInputAction.done,
														),
													],
												),
											),
											SizedBox(height: responsive.h(32)),
											Obx(() => AppPrimaryButton(
												responsive: responsive,
												label: controller.isSaving.value ? 'Sauvegarde...' : 'Enregistrer les modifications',
												onTap: controller.isSaving.value ? () {} : () => controller.save(formKey),
												height: responsive.h(56),
												borderRadius: responsive.radius(16),
											)),
											SizedBox(height: responsive.h(12)),
											TextButton(
												onPressed: Get.back,
												child: Text(
													'Annuler',
													style: AppTextStyles.body(responsive).copyWith(
														color: AppColors.textHint,
														fontWeight: FontWeight.w500,
													),
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

// ── Header ──────────────────────────────────────────────────────────────────

class _HeaderBar extends StatelessWidget {
	const _HeaderBar({required this.responsive, required this.controller, required this.formKey});
	final AppResponsive responsive;
	final EditProfileController controller;
	final GlobalKey<FormState> formKey;

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
					SizedBox(width: responsive.w(12)),
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('Modifier le profil', style: AppTextStyles.title(responsive)),
								Text(
									'Vos informations personnelles',
									style: AppTextStyles.caption(responsive).copyWith(color: AppColors.textHint),
								),
							],
						),
					),
				],
			),
		);
	}
}

// ── Avatar ──────────────────────────────────────────────────────────────────

class _AvatarSection extends StatelessWidget {
	const _AvatarSection({required this.responsive, required this.controller});
	final AppResponsive responsive;
	final EditProfileController controller;

	@override
	Widget build(BuildContext context) {
		return Center(
			child: Column(
				children: [
					GestureDetector(
						onTap: controller.pickAvatar,
						child: Stack(
							clipBehavior: Clip.none,
							children: [
								Obx(() {
									final file = controller.avatarFile.value;
									return Container(
										width: responsive.w(96),
										height: responsive.w(96),
										decoration: BoxDecoration(
											shape: BoxShape.circle,
											border: Border.all(color: AppColors.border, width: 3),
										),
										child: ClipOval(
											child: file != null
													? Image.file(File(file.path), fit: BoxFit.cover)
													: Image.network(
															'https://placehold.co/96x96.png',
															fit: BoxFit.cover,
															errorBuilder: (_, _e, _s) => const Icon(
																Icons.person_rounded,
																color: AppColors.textHint,
																size: 48,
															),
														),
										),
									);
								}),
								Positioned(
									right: 0,
									bottom: 0,
									child: Container(
										width: responsive.w(30),
										height: responsive.w(30),
										decoration: BoxDecoration(
											color: AppColors.primary,
											shape: BoxShape.circle,
											border: Border.all(color: AppColors.white, width: 2),
										),
										child: Icon(Icons.camera_alt_rounded, size: responsive.text(14), color: Colors.white),
									),
								),
							],
						),
					),
					SizedBox(height: responsive.h(8)),
					TextButton.icon(
						onPressed: controller.pickAvatar,
						icon: Icon(Icons.upload_rounded, size: responsive.text(14)),
						label: const Text('Changer la photo'),
						style: TextButton.styleFrom(
							foregroundColor: AppColors.primary,
							textStyle: AppTextStyles.caption(responsive).copyWith(fontWeight: FontWeight.w600),
						),
					),
				],
			),
		);
	}
}

// ── Field ───────────────────────────────────────────────────────────────────

class _Field extends StatelessWidget {
	const _Field({
		required this.responsive,
		required this.label,
		required this.hint,
		required this.icon,
		required this.controller,
		this.validator,
		this.keyboardType,
		this.textInputAction = TextInputAction.next,
	});

	final AppResponsive responsive;
	final String label;
	final String hint;
	final IconData icon;
	final TextEditingController controller;
	final String? Function(String?)? validator;
	final TextInputType? keyboardType;
	final TextInputAction textInputAction;

	@override
	Widget build(BuildContext context) {
		return Column(
			crossAxisAlignment: CrossAxisAlignment.start,
			children: [
				Text(
					label,
					style: AppTextStyles.caption(responsive).copyWith(
						fontWeight: FontWeight.w600,
						color: AppColors.textSecondary,
					),
				),
				SizedBox(height: responsive.h(6)),
				TextFormField(
					controller: controller,
					validator: validator,
					keyboardType: keyboardType,
					textInputAction: textInputAction,
					style: AppTextStyles.body(responsive).copyWith(color: AppColors.textPrimary),
					decoration: InputDecoration(
						hintText: hint,
						hintStyle: AppTextStyles.body(responsive).copyWith(color: AppColors.textGhost),
						prefixIcon: Padding(
							padding: EdgeInsets.symmetric(horizontal: responsive.w(12)),
							child: Icon(icon, size: responsive.text(18), color: AppColors.textHint),
						),
						prefixIconConstraints: BoxConstraints(minWidth: responsive.w(44)),
						filled: true,
						fillColor: AppColors.surfaceMuted,
						contentPadding: EdgeInsets.symmetric(horizontal: responsive.w(16), vertical: responsive.h(14)),
						border: OutlineInputBorder(
							borderRadius: BorderRadius.circular(responsive.radius(12)),
							borderSide: const BorderSide(color: AppColors.border),
						),
						enabledBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(responsive.radius(12)),
							borderSide: const BorderSide(color: AppColors.border),
						),
						focusedBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(responsive.radius(12)),
							borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
						),
						errorBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(responsive.radius(12)),
							borderSide: const BorderSide(color: Color(0xFFEF4444)),
						),
						focusedErrorBorder: OutlineInputBorder(
							borderRadius: BorderRadius.circular(responsive.radius(12)),
							borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
						),
					),
				),
			],
		);
	}
}

// ── Shared ──────────────────────────────────────────────────────────────────

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

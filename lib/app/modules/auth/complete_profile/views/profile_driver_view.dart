import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/auth/complete_profile/controllers/profile_driver_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileDriverView extends GetView<ProfileDriverController> {
  const ProfileDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(16),
                  vertical: responsive.h(20),
                ),
                child: GetBuilder<ProfileDriverController>(
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _ProgressCard(
                          responsive: responsive,
                          progress: controller.progress.value,
                        ),
                        SizedBox(height: responsive.h(20)),
                        _HeroCard(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _SectionCard(
                          responsive: responsive,
                          title: AppStrings.profileSectionPersonal,
                          icon: Icons.badge_outlined,
                          child: Column(
                            children: [
                              AppField(
                                responsive: responsive,
                                label: AppStrings.profileFieldLastName,
                                labelStyle: AppTextStyles.profileSectionLabel(
                                  responsive,
                                ),
                                controller: controller.lastNameController,
                                hintText: AppStrings.profileFieldLastNameHint,
                                textStyle: AppTextStyles.profileFieldValue(
                                  responsive,
                                ),
                                hintStyle: AppTextStyles.profileFieldValue(
                                  responsive,
                                ).copyWith(color: AppColors.textGhost),
                              ),
                              SizedBox(height: responsive.h(16)),
                              AppField(
                                responsive: responsive,
                                label: AppStrings.profileFieldFirstName,
                                labelStyle: AppTextStyles.profileSectionLabel(
                                  responsive,
                                ),
                                controller: controller.firstNameController,
                                hintText: AppStrings.profileFieldFirstNameHint,
                                textStyle: AppTextStyles.profileFieldValue(
                                  responsive,
                                ),
                                hintStyle: AppTextStyles.profileFieldValue(
                                  responsive,
                                ).copyWith(color: AppColors.textGhost),
                              ),
                              SizedBox(height: responsive.h(16)),
                              AppField(
                                responsive: responsive,
                                label: AppStrings.profileFieldPhone,
                                labelStyle: AppTextStyles.profileSectionLabel(
                                  responsive,
                                ),
                                backgroundColor: AppColors.surfaceAccent,
                                borderColor: AppColors.primary,
                                helperText:
                                    AppStrings.profileSectionPhoneVerified,
                                helperStyle: AppTextStyles.profileMeta(
                                  responsive,
                                ).copyWith(color: AppColors.primary),
                                controller: controller.phoneController,
                                keyboardType: TextInputType.phone,
                                hintText: '+229 01 97 45 67 89',
                                textStyle: AppTextStyles.profileFieldValue(
                                  responsive,
                                ),
                                hintStyle: AppTextStyles.profileFieldValue(
                                  responsive,
                                ).copyWith(color: AppColors.textGhost),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.h(20)),
                        _SectionCard(
                          responsive: responsive,
                          title: AppStrings.profileSectionVehicle,
                          icon: Icons.directions_car_rounded,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: AppField(
                                      responsive: responsive,
                                      label:
                                          AppStrings.profileFieldVehicleBrand,
                                      labelStyle:
                                          AppTextStyles.profileSectionLabel(
                                            responsive,
                                          ),
                                      backgroundColor: AppColors.surfaceMuted,
                                      controller:
                                          controller.vehicleBrandController,
                                      hintText:
                                          AppStrings.profileVehicleBrandValue,
                                      textStyle:
                                          AppTextStyles.profileFieldValue(
                                            responsive,
                                          ),
                                      hintStyle:
                                          AppTextStyles.profileFieldValue(
                                            responsive,
                                          ).copyWith(
                                            color: AppColors.textGhost,
                                          ),
                                    ),
                                  ),
                                  SizedBox(width: responsive.w(12)),
                                  Expanded(
                                    child: AppField(
                                      responsive: responsive,
                                      label:
                                          AppStrings.profileFieldVehicleModel,
                                      labelStyle:
                                          AppTextStyles.profileSectionLabel(
                                            responsive,
                                          ),
                                      controller:
                                          controller.vehicleModelController,
                                      hintText:
                                          AppStrings.profileVehicleModelValue,
                                      textStyle:
                                          AppTextStyles.profileFieldValue(
                                            responsive,
                                          ),
                                      hintStyle:
                                          AppTextStyles.profileFieldValue(
                                            responsive,
                                          ).copyWith(
                                            color: AppColors.textGhost,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: responsive.h(16)),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppField(
                                      responsive: responsive,
                                      label:
                                          AppStrings.profileFieldVehicleColor,
                                      labelStyle:
                                          AppTextStyles.profileSectionLabel(
                                            responsive,
                                          ),
                                      backgroundColor: AppColors.surfaceMuted,
                                      controller:
                                          controller.vehicleColorController,
                                      hintText:
                                          AppStrings.profileVehicleColorValue,
                                      textStyle:
                                          AppTextStyles.profileFieldValue(
                                            responsive,
                                          ),
                                      hintStyle:
                                          AppTextStyles.profileFieldValue(
                                            responsive,
                                          ).copyWith(
                                            color: AppColors.textGhost,
                                          ),
                                    ),
                                  ),
                                  SizedBox(width: responsive.w(12)),
                                  Expanded(
                                    child: AppField(
                                      responsive: responsive,
                                      label:
                                          AppStrings.profileFieldVehicleSeats,
                                      labelStyle:
                                          AppTextStyles.profileSectionLabel(
                                            responsive,
                                          ),
                                      backgroundColor: AppColors.surfaceMuted,
                                      controller:
                                          controller.vehicleSeatsController,
                                      hintText:
                                          AppStrings.profileVehicleSeatsValue,
                                      keyboardType: TextInputType.number,
                                      textStyle:
                                          AppTextStyles.profileFieldValue(
                                            responsive,
                                          ),
                                      hintStyle:
                                          AppTextStyles.profileFieldValue(
                                            responsive,
                                          ).copyWith(
                                            color: AppColors.textGhost,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: responsive.h(16)),
                              AppField(
                                responsive: responsive,
                                label: AppStrings.profileFieldPlate,
                                labelStyle: AppTextStyles.profileSectionLabel(
                                  responsive,
                                ),
                                controller: controller.plateController,
                                hintText: AppStrings.profileVehiclePlateValue,
                                textStyle: AppTextStyles.profileFieldValue(
                                  responsive,
                                ),
                                hintStyle: AppTextStyles.profileFieldValue(
                                  responsive,
                                ).copyWith(color: AppColors.textGhost),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.h(20)),
                        _SectionCard(
                          responsive: responsive,
                          title: AppStrings.profileSectionDocuments,
                          icon: Icons.description_outlined,
                          child: Column(
                            children: [
                              _DocumentUploadTile(
                                responsive: responsive,
                                title: AppStrings.profileFieldVehiclePhoto,
                                subtitle:
                                    AppStrings.profileFieldVehiclePhotoHint,
                                actionLabel: AppStrings.profileUploadPhoto,
                                icon: Icons.photo_camera_outlined,
                                onTap: controller.addVehiclePhoto,
                                selectedValue:
                                    controller.vehiclePhotoName.value,
                              ),
                              SizedBox(height: responsive.h(16)),
                              _DocumentUploadTile(
                                responsive: responsive,
                                title: AppStrings.profileFieldRegistration,
                                subtitle:
                                    AppStrings.profileFieldRegistrationHint,
                                actionLabel: AppStrings.profileUploadDocument,
                                icon: Icons.folder_open_rounded,
                                onTap: () => controller.addRequiredDocument(
                                  isLicense: false,
                                ),
                                selectedValue:
                                    controller.registrationDocumentName.value,
                              ),
                              SizedBox(height: responsive.h(16)),
                              _DocumentUploadTile(
                                responsive: responsive,
                                title: AppStrings.profileFieldLicense,
                                subtitle: AppStrings.profileFieldLicenseHint,
                                actionLabel: AppStrings.profileUploadDocument,
                                icon: Icons.badge_outlined,
                                onTap: () => controller.addRequiredDocument(
                                  isLicense: true,
                                ),
                                selectedValue:
                                    controller.licenseDocumentName.value,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.h(20)),
                        _TrustCard(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _ProgressSummary(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        AppPrimaryButton(
                          responsive: responsive,
                          label: AppStrings.profilePrimaryAction,
                          onTap: controller.continueProfile,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppCircularButton(
          responsive: responsive,
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: Get.back,
          size: responsive.w(40),
        ),
        Row(
          children: [
            Container(
              width: responsive.w(32),
              height: responsive.w(32),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(8)),
                ),
              ),
              child: Text(
                'M',
                style: AppTextStyles.profileSectionTitle(responsive).copyWith(
                  color: AppColors.white,
                  fontSize: responsive.text(16),
                ),
              ),
            ),
            SizedBox(width: responsive.w(8)),
            Text(
              AppStrings.appName,
              style: AppTextStyles.profileSectionTitle(responsive),
            ),
            SizedBox(width: responsive.w(70)),
            AppCircularButton(
              responsive: responsive,
              icon: Icons.person_outline_rounded,
              onTap: () {},
              size: responsive.w(40),
              filled: false,
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.responsive, required this.progress});

  final AppResponsive responsive;
  final int progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.profileProgressLabel,
              style: AppTextStyles.profileMeta(responsive),
            ),
            Text('${progress}%', style: AppTextStyles.profileMeta(responsive)),
          ],
        ),
        SizedBox(height: responsive.h(8)),
        ClipRRect(
          borderRadius: BorderRadius.circular(9999),
          child: Stack(
            children: [
              Container(height: responsive.h(8), color: AppColors.border),
              FractionallySizedBox(
                widthFactor: progress / 100,
                child: Container(
                  height: responsive.h(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.warning],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(24)),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.success],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: responsive.w(56),
                height: responsive.w(56),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(responsive.radius(16)),
                ),
                child: Icon(
                  Icons.verified_outlined,
                  color: AppColors.white,
                  size: responsive.text(28),
                ),
              ),
              SizedBox(width: responsive.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.profileHeroTitle,
                      style: AppTextStyles.profileHeroTitle(responsive),
                    ),
                    SizedBox(height: responsive.h(4)),
                    Text(
                      AppStrings.profileHeroSubtitle,
                      style: AppTextStyles.profileHeroSubtitle(responsive),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                color: AppColors.white,
                size: 16,
              ),
              SizedBox(width: responsive.w(8)),
              Text(
                AppStrings.profileHeroTime,
                style: AppTextStyles.profileHeroSubtitle(
                  responsive,
                ).copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.responsive,
    required this.title,
    required this.icon,
    required this.child,
  });

  final AppResponsive responsive;
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(24)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.surfaceSoft),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: responsive.w(40),
                height: responsive.w(40),
                decoration: ShapeDecoration(
                  color: AppColors.surfaceAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: responsive.text(18),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Text(title, style: AppTextStyles.profileSectionTitle(responsive)),
            ],
          ),
          SizedBox(height: responsive.h(24)),
          child,
        ],
      ),
    );
  }
}

class _DocumentUploadTile extends StatelessWidget {
  const _DocumentUploadTile({
    required this.responsive,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.onTap,
    required this.selectedValue,
  });

  final AppResponsive responsive;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final VoidCallback onTap;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    return AppField(
      responsive: responsive,
      label: title,
      labelStyle: AppTextStyles.profileSectionLabel(responsive),
      backgroundColor: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: responsive.w(48),
            height: responsive.w(48),
            decoration: ShapeDecoration(
              color: AppColors.surfaceAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: responsive.text(20),
            ),
          ),
          SizedBox(height: responsive.h(12)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.profileSectionTitle(
              responsive,
            ).copyWith(fontSize: responsive.text(16)),
          ),
          SizedBox(height: responsive.h(4)),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.profileMeta(responsive),
          ),
          if (selectedValue.isNotEmpty) ...[
            SizedBox(height: responsive.h(8)),
            Text(
              selectedValue,
              textAlign: TextAlign.center,
              style: AppTextStyles.profileMeta(
                responsive,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
          SizedBox(height: responsive.h(12)),
          AppChipButton(
            responsive: responsive,
            label: actionLabel,
            onTap: onTap,
          ),
        ],
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  const _TrustCard({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(24)),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.00, 0.50),
          end: Alignment(1.00, 0.50),
          colors: [AppColors.surfaceAccent, AppColors.surfaceWarning],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(
            width: 1,
            color: AppColors.surfaceAccentStrong,
          ),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.w(40),
            height: responsive.w(40),
            decoration: ShapeDecoration(
              color: AppColors.surfaceAccentStrong,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: AppColors.primary,
              size: responsive.text(18),
            ),
          ),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.profileSectionSecurity,
                  style: AppTextStyles.profileSectionTitle(responsive),
                ),
                SizedBox(height: responsive.h(4)),
                Text(
                  AppStrings.profileSectionSecurityHint,
                  style: AppTextStyles.profileMeta(responsive),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.profileSectionProgress,
              style: AppTextStyles.profileSectionLabel(responsive),
            ),
            SizedBox(height: responsive.h(2)),
            Text(
              AppStrings.profileSectionProgressHint,
              style: AppTextStyles.profileMeta(responsive),
            ),
          ],
        ),
        Container(
          width: responsive.w(48),
          height: responsive.w(48),
          decoration: ShapeDecoration(
            color: AppColors.surfaceAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
            ),
          ),
          child: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.primary,
            size: responsive.text(24),
          ),
        ),
      ],
    );
  }
}

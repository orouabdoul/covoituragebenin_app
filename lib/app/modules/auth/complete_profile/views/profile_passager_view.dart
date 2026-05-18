import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/auth/complete_profile/controllers/profile_passager_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePassagerView extends GetView<ProfilePassagerController> {
  const ProfilePassagerView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.w(16),
                  responsive.h(12),
                  responsive.w(16),
                  responsive.h(24),
                ),
                child: GetBuilder<ProfilePassagerController>(
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(responsive: responsive),
                        SizedBox(height: responsive.h(24)),
                        _ProgressCard(
                          responsive: responsive,
                          progress: controller.progress.value,
                        ),
                        SizedBox(height: responsive.h(20)),
                        _HeroCard(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _AvatarCard(
                          responsive: responsive,
                          onTap: controller.addAvatarPhoto,
                          selectedValue: controller.avatarImageName.value,
                        ),
                        SizedBox(height: responsive.h(20)),
                        _PersonalCard(
                          responsive: responsive,
                          controller: controller,
                        ),
                        SizedBox(height: responsive.h(20)),
                        _BenefitsCard(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _TrustCard(responsive: responsive),
                        SizedBox(height: responsive.h(24)),
                        AppPrimaryButton(
                          responsive: responsive,
                          label: AppStrings.passengerPrimaryAction,
                          onTap: controller.createProfile,
                        ),
                        SizedBox(height: responsive.h(12)),
                        Center(
                          child: AppTextButton(
                            responsive: responsive,
                            label: AppStrings.passengerSecondaryAction,
                            onTap: controller.continueLater,
                          ),
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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(16),
        vertical: responsive.h(12),
      ),
      decoration: const ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: AppColors.border),
        ),
        shadows: [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppCircularButton(
            responsive: responsive,
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: Get.back,
            size: responsive.w(40),
          ),
          Text(
            'Profil Premium',
            style: AppTextStyles.profileSectionTitle(
              responsive,
            ).copyWith(fontSize: responsive.text(16)),
          ),
          SizedBox(width: responsive.w(32)),
        ],
      ),
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
              AppStrings.passengerProgressLabel,
              style: AppTextStyles.profileSectionLabel(responsive),
            ),
            Text(
              AppStrings.passengerProgressValue,
              style: AppTextStyles.profileMeta(
                responsive,
              ).copyWith(color: AppColors.info, fontWeight: FontWeight.w700),
            ),
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
                      colors: [AppColors.success, AppColors.success],
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
          borderRadius: BorderRadius.circular(responsive.radius(16)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(12),
                  vertical: responsive.h(4),
                ),
                decoration: ShapeDecoration(
                  color: AppColors.warning,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Text(
                  AppStrings.passengerHeroBadge,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.star_rounded,
                color: AppColors.white.withValues(alpha: 0.95),
                size: responsive.text(20),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          Text(
            AppStrings.passengerHeroTitle,
            style: AppTextStyles.profileHeroTitle(
              responsive,
            ).copyWith(fontSize: responsive.text(20)),
          ),
          SizedBox(height: responsive.h(8)),
          Text(
            AppStrings.passengerHeroSubtitle,
            style: AppTextStyles.profileHeroSubtitle(
              responsive,
            ).copyWith(fontSize: responsive.text(14)),
          ),
          SizedBox(height: responsive.h(12)),
          Row(
            children: [
              const Icon(
                Icons.timer_outlined,
                color: AppColors.white,
                size: 16,
              ),
              SizedBox(width: responsive.w(8)),
              Text(
                AppStrings.passengerHeroTime,
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

class _AvatarCard extends StatelessWidget {
  const _AvatarCard({
    required this.responsive,
    required this.onTap,
    required this.selectedValue,
  });

  final AppResponsive responsive;
  final VoidCallback onTap;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(24)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: responsive.w(96),
                  height: responsive.w(96),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.border, AppColors.borderStrong],
                    ),
                    border: Border.all(
                      color: AppColors.white,
                      width: responsive.w(4),
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.white,
                    size: responsive.text(42),
                  ),
                ),
                Container(
                  width: responsive.w(32),
                  height: responsive.w(32),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.h(12)),
          Text(
            AppStrings.passengerPhotoTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.profileMeta(responsive),
          ),
          if (selectedValue.isNotEmpty) ...[
            SizedBox(height: responsive.h(6)),
            Text(
              selectedValue,
              textAlign: TextAlign.center,
              style: AppTextStyles.profileMeta(
                responsive,
              ).copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class _PersonalCard extends StatelessWidget {
  const _PersonalCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final ProfilePassagerController controller;

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      responsive: responsive,
      title: AppStrings.passengerSectionPersonal,
      icon: Icons.badge_outlined,
      child: Column(
        children: [
          AppField(
            responsive: responsive,
            label: AppStrings.passengerFieldLastName,
            labelStyle: AppTextStyles.profileSectionLabel(responsive),
            controller: controller.lastNameController,
            hintText: AppStrings.passengerFieldLastNameHint,
            textStyle: AppTextStyles.profileFieldValue(responsive),
            hintStyle: AppTextStyles.profileFieldValue(
              responsive,
            ).copyWith(color: AppColors.textGhost),
          ),
          SizedBox(height: responsive.h(16)),
          AppField(
            responsive: responsive,
            label: AppStrings.passengerFieldFirstName,
            labelStyle: AppTextStyles.profileSectionLabel(responsive),
            controller: controller.firstNameController,
            hintText: AppStrings.passengerFieldFirstNameHint,
            textStyle: AppTextStyles.profileFieldValue(responsive),
            hintStyle: AppTextStyles.profileFieldValue(
              responsive,
            ).copyWith(color: AppColors.textGhost),
          ),
          SizedBox(height: responsive.h(16)),
          AppField(
            responsive: responsive,
            label: AppStrings.passengerFieldEmail,
            labelStyle: AppTextStyles.profileSectionLabel(responsive),
            helperText: AppStrings.passengerEmailNote,
            helperStyle: AppTextStyles.profileMeta(responsive),
            controller: controller.emailController,
            hintText: AppStrings.passengerFieldEmailHint,
            textStyle: AppTextStyles.profileFieldValue(responsive),
            hintStyle: AppTextStyles.profileFieldValue(
              responsive,
            ).copyWith(color: AppColors.textGhost),
          ),
        ],
      ),
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      responsive: responsive,
      title: AppStrings.passengerSectionBenefits,
      icon: Icons.workspace_premium_outlined,
      child: Column(
        children: [
          _BenefitRow(
            responsive: responsive,
            icon: Icons.verified_rounded,
            label: AppStrings.passengerBenefitOne,
            color: AppColors.successLight,
          ),
          SizedBox(height: responsive.h(12)),
          _BenefitRow(
            responsive: responsive,
            icon: Icons.flash_on_rounded,
            label: AppStrings.passengerBenefitTwo,
            color: AppColors.blueLight,
          ),
          SizedBox(height: responsive.h(12)),
          _BenefitRow(
            responsive: responsive,
            icon: Icons.support_agent_rounded,
            label: AppStrings.passengerBenefitThree,
            color: AppColors.surfaceWarning,
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.responsive,
    required this.icon,
    required this.label,
    required this.color,
  });

  final AppResponsive responsive;
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: responsive.w(32),
          height: responsive.w(32),
          decoration: ShapeDecoration(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: Icon(
            icon,
            size: responsive.text(16),
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.profileMeta(
              responsive,
            ).copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
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
      padding: EdgeInsets.all(responsive.w(16)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(12)),
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
      child: Row(
        children: [
          Container(
            width: responsive.w(40),
            height: responsive.w(40),
            decoration: const BoxDecoration(
              color: AppColors.surfaceAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Text(
              'Profil vérifié et sécurisé',
              style: AppTextStyles.profileMeta(
                responsive,
              ).copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionContainer extends StatelessWidget {
  const _SectionContainer({
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
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          side: const BorderSide(color: AppColors.border),
        ),
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
                  size: responsive.text(18),
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.profileSectionTitle(responsive),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(20)),
          child,
        ],
      ),
    );
  }
}

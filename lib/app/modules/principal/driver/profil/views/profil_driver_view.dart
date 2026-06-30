import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controller/profil_driver_controller.dart';

class ProfilDriverView extends StatelessWidget {
  const ProfilDriverView({super.key});

  DriverProfileController get controller =>
      Get.isRegistered<DriverProfileController>()
          ? Get.find<DriverProfileController>()
          : Get.put(DriverProfileController());

  @override
  Widget build(BuildContext context) {
    final AppResponsive responsive = AppResponsive(context);
    final double horizontalPadding = responsive.adaptive(
      phone: 16,
      smallPhone: 14,
      tablet: 20,
      desktop: 24,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                responsive.adaptive(
                  phone: 12,
                  smallPhone: 10,
                  tablet: 14,
                  desktop: 16,
                ),
                horizontalPadding,
                responsive.adaptive(
                  phone: 24,
                  smallPhone: 20,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
              children: [
                _TopBar(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),
                _HeroCard(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(20)),
                _SectionTitle(
                  responsive: responsive,
                  title: AppStrings.driverProfileSectionTrust,
                ),
                SizedBox(height: responsive.h(12)),
                _VerificationGrid(
                  responsive: responsive,
                  controller: controller,
                ),
                SizedBox(height: responsive.h(20)),
                _SectionTitle(
                  responsive: responsive,
                  title: AppStrings.driverProfileSectionStats,
                ),
                SizedBox(height: responsive.h(12)),
                _StatsGrid(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(20)),
                _PersonalInfoSection(
                  responsive: responsive,
                  controller: controller,
                ),
                SizedBox(height: responsive.h(20)),
                _VehicleSection(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(20)),
                _DocumentsSection(
                  responsive: responsive,
                  controller: controller,
                ),
                SizedBox(height: responsive.h(20)),
                _PerformanceSection(responsive: responsive),
                SizedBox(height: responsive.h(20)),
                _PreferencesSection(
                  responsive: responsive,
                  controller: controller,
                ),
                SizedBox(height: responsive.h(20)),
                _SettingsSection(
                  responsive: responsive,
                  controller: controller,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(16),
        vertical: responsive.h(14),
      ),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(16)),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppStrings.driverProfileTitle,
            style: AppTextStyles.profileSectionTitle(responsive),
          ),
          Row(
            children: [
              AppCircularButton(
                responsive: responsive,
                icon: Icons.notifications_none_rounded,
                onTap: controller.onNotifications,
                size: responsive.w(40),
              ),
              SizedBox(width: responsive.w(8)),
              AppCircularButton(
                responsive: responsive,
                icon: Icons.tune_rounded,
                onTap: controller.onTune,
                size: responsive.w(40),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(20)),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.success],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(22)),
          side: const BorderSide(color: AppColors.border),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: responsive.w(96),
                height: responsive.w(96),
                decoration: ShapeDecoration(
                  color: AppColors.white.withValues(alpha: 0.20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                    side: const BorderSide(width: 4, color: AppColors.white),
                  ),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: AppColors.white,
                  size: responsive.text(48),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  width: responsive.w(30),
                  height: responsive.w(30),
                  decoration: ShapeDecoration(
                    color: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                      side: const BorderSide(width: 3, color: AppColors.white),
                    ),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: AppColors.white,
                    size: responsive.text(16),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(14)),
          Text(
            AppStrings.driverProfileName,
            style: AppTextStyles.profileSectionTitle(
              responsive,
            ).copyWith(color: AppColors.white, fontSize: responsive.text(24)),
          ),
          SizedBox(height: responsive.h(8)),
          Wrap(
            spacing: responsive.w(8),
            runSpacing: responsive.h(8),
            alignment: WrapAlignment.center,
            children: const [
              _HeroChip(label: AppStrings.driverProfileBadge),
              _HeroChip(label: 'Niveau 5'),
            ],
          ),
          SizedBox(height: responsive.h(8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.white.withValues(alpha: 0.90),
                size: responsive.text(14),
              ),
              SizedBox(width: responsive.w(4)),
              Text(
                AppStrings.driverProfileLocation,
                style: AppTextStyles.profileHeroSubtitle(responsive),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          Container(
            padding: EdgeInsets.all(responsive.w(14)),
            decoration: ShapeDecoration(
              color: AppColors.white.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: const [
                Expanded(
                  child: _HeroMetric(
                    value: AppStrings.driverProfileSummaryRating,
                    label: AppStrings.driverProfileSummaryRatingLabel,
                  ),
                ),
                Expanded(
                  child: _HeroMetric(
                    value: AppStrings.driverProfileSummaryTrips,
                    label: AppStrings.driverProfileSummaryTripsLabel,
                  ),
                ),
                Expanded(
                  child: _HeroMetric(
                    value: AppStrings.driverProfileSummaryTenure,
                    label: AppStrings.driverProfileSummaryTenureLabel,
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

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9999),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: -0.50,
        ),
      ),
    );
  }
}

class _HeroMetric extends StatelessWidget {
  const _HeroMetric({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 22,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
            height: 1.33,
            letterSpacing: -0.50,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white.withValues(alpha: 0.75),
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            height: 1.33,
            letterSpacing: -0.50,
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.responsive,
    required this.title,
    this.trailing,
  });

  final AppResponsive responsive;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.h6(responsive)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _VerificationGrid extends StatelessWidget {
  const _VerificationGrid({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileWidth = (constraints.maxWidth - responsive.w(12)) / 2;

        return Wrap(
          spacing: responsive.w(12),
          runSpacing: responsive.h(12),
          children: controller.verificationItems
              .map((item) {
                return SizedBox(
                  width: tileWidth,
                  child: Container(
                    padding: EdgeInsets.all(responsive.w(14)),
                    decoration: ShapeDecoration(
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsive.radius(16),
                        ),
                        side: const BorderSide(
                          color: AppColors.surfaceAccentWeak,
                        ),
                      ),
                      shadows: const [
                        BoxShadow(
                          color: AppColors.shadowSoft,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: responsive.w(40),
                          height: responsive.w(40),
                          decoration: ShapeDecoration(
                            color: AppColors.surfaceAccentStrong,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            size: responsive.text(18),
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: responsive.w(10)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: AppTextStyles.caption(responsive)
                                    .copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              Text(
                                item.status,
                                style: AppTextStyles.caption(
                                  responsive,
                                ).copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: responsive.text(16),
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double tileWidth = (constraints.maxWidth - responsive.w(12)) / 2;

        return Wrap(
          spacing: responsive.w(12),
          runSpacing: responsive.h(12),
          children: controller.stats
              .map((item) {
                final BoxDecoration decoration;
                final Color titleColor;
                final Color subtitleColor;

                if (item.emphasized) {
                  decoration = BoxDecoration(
                    gradient: LinearGradient(
                      colors: [item.accentStart, item.accentEnd],
                    ),
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      ),
                    ],
                  );
                  titleColor = AppColors.white;
                  subtitleColor = AppColors.white.withValues(alpha: 0.80);
                } else {
                  decoration = BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                    border: Border.all(color: AppColors.surfaceSoft),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadowSoft,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  );
                  titleColor = AppColors.textPrimary;
                  subtitleColor = AppColors.textHint;
                }

                return SizedBox(
                  width: tileWidth,
                  child: Container(
                    padding: EdgeInsets.all(responsive.w(14)),
                    decoration: decoration,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item.icon,
                          color: titleColor,
                          size: responsive.text(20),
                        ),
                        SizedBox(height: responsive.h(8)),
                        Text(
                          item.value,
                          style: AppTextStyles.profileSectionTitle(responsive)
                              .copyWith(
                                color: titleColor,
                                fontSize: responsive.text(24),
                              ),
                        ),
                        Text(
                          item.label,
                          style: AppTextStyles.caption(
                            responsive,
                          ).copyWith(color: subtitleColor),
                        ),
                      ],
                    ),
                  ),
                );
              })
              .toList(growable: false),
        );
      },
    );
  }
}

class _PersonalInfoSection extends StatelessWidget {
  const _PersonalInfoSection({
    required this.responsive,
    required this.controller,
  });

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          responsive: responsive,
          title: AppStrings.driverProfileSectionPersonal,
          trailing: GestureDetector(
            onTap: controller.onEditProfile,
            child: Text(
              AppStrings.driverProfileEdit,
              style: AppTextStyles.profileSectionLabel(
                responsive,
              ).copyWith(color: AppColors.primary),
            ),
          ),
        ),
        SizedBox(height: responsive.h(12)),
        Container(
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.surfaceSoft),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: controller.personalInfo
                .map((item) {
                  return _InfoRow(responsive: responsive, item: item);
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.responsive, required this.item});

  final AppResponsive responsive;
  final DriverPersonalInfoItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(16)),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.surfaceSoft)),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.w(40),
            height: responsive.w(40),
            decoration: ShapeDecoration(
              color: AppColors.surfaceSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            child: Icon(
              item.icon,
              color: AppColors.textHint,
              size: responsive.text(18),
            ),
          ),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label, style: AppTextStyles.caption(responsive)),
                Text(
                  item.value,
                  style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
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

class _VehicleSection extends StatelessWidget {
  const _VehicleSection({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          responsive: responsive,
          title: AppStrings.driverProfileSectionVehicles,
          trailing: AppChipButton(
            responsive: responsive,
            label: AppStrings.driverProfileAddVehicle,
            onTap: controller.onAddVehicle,
            backgroundColor: AppColors.primary,
            textColor: AppColors.white,
            borderColor: AppColors.primary,
            borderRadius: responsive.radius(12),
          ),
        ),
        SizedBox(height: responsive.h(12)),
        ...controller.vehicles.map((vehicle) {
          return Padding(
            padding: EdgeInsets.only(bottom: responsive.h(12)),
            child: _VehicleCard(
              responsive: responsive,
              vehicle: vehicle,
              onTap: () => controller.onVehicleTap(vehicle),
            ),
          );
        }),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.responsive,
    required this.vehicle,
    required this.onTap,
  });

  final AppResponsive responsive;
  final DriverVehicleItem vehicle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(responsive.w(16)),
        decoration: ShapeDecoration(
          color: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius(16)),
            side: BorderSide(
              color: vehicle.active ? AppColors.primary : AppColors.surfaceSoft,
              width: vehicle.active ? 2 : 1,
            ),
          ),
          shadows: const [
            BoxShadow(
              color: AppColors.shadowSoft,
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: responsive.w(74),
              height: responsive.w(74),
              decoration: ShapeDecoration(
                color: AppColors.surfaceSoft,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(12)),
                ),
              ),
              child: Icon(
                Icons.directions_car_rounded,
                color: AppColors.textHint,
                size: responsive.text(30),
              ),
            ),
            SizedBox(width: responsive.w(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          vehicle.title,
                          style: AppTextStyles.h6(responsive),
                        ),
                      ),
                      if (vehicle.active)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(8),
                            vertical: responsive.h(4),
                          ),
                          decoration: ShapeDecoration(
                            color: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: Text(
                            AppStrings.driverProfileVehicleActive,
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(8),
                            vertical: responsive.h(4),
                          ),
                          decoration: ShapeDecoration(
                            color: const Color(0x33F4B400),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: Text(
                            AppStrings.driverProfilePending,
                            style: AppTextStyles.caption(responsive).copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    vehicle.subtitle,
                    style: AppTextStyles.caption(responsive),
                  ),
                  SizedBox(height: responsive.h(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(8),
                      vertical: responsive.h(4),
                    ),
                    decoration: ShapeDecoration(
                      color: vehicle.active
                          ? AppColors.surfaceAccentStrong
                          : AppColors.surfaceSoft,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          responsive.radius(8),
                        ),
                      ),
                    ),
                    child: Text(
                      vehicle.plate,
                      style: AppTextStyles.caption(responsive).copyWith(
                        color: vehicle.active
                            ? AppColors.primary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
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

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          responsive: responsive,
          title: AppStrings.driverProfileSectionDocuments,
        ),
        SizedBox(height: responsive.h(12)),
        Container(
          padding: EdgeInsets.all(responsive.w(14)),
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.surfaceSoft),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: controller.documents
                .map((doc) {
                  return _DocumentRow(
                    responsive: responsive,
                    item: doc,
                    onTap: () => controller.onDocumentTap(doc),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.responsive,
    required this.item,
    required this.onTap,
  });

  final AppResponsive responsive;
  final DriverDocumentItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: responsive.w(40),
        height: responsive.w(40),
        decoration: ShapeDecoration(
          color: AppColors.surfaceAccentStrong,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Icon(
          item.icon,
          color: AppColors.primary,
          size: responsive.text(18),
        ),
      ),
      title: Text(
        item.title,
        style: AppTextStyles.profileSectionLabel(
          responsive,
        ).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        item.subtitle,
        style: AppTextStyles.caption(
          responsive,
        ).copyWith(color: AppColors.primary),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: AppColors.textHint,
        size: responsive.text(18),
      ),
    );
  }
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          responsive: responsive,
          title: AppStrings.driverProfileSectionPerformance,
        ),
        SizedBox(height: responsive.h(12)),
        Container(
          padding: EdgeInsets.all(responsive.w(18)),
          decoration: ShapeDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, Color(0xFFFB923C)],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.border),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.driverProfileCurrentLevel,
                        style: AppTextStyles.caption(responsive).copyWith(
                          color: AppColors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      Text(
                        AppStrings.driverProfileCurrentLevelValue,
                        style: AppTextStyles.profileSectionTitle(responsive)
                            .copyWith(
                              color: AppColors.white,
                              fontSize: responsive.text(24),
                            ),
                      ),
                    ],
                  ),
                  Container(
                    width: responsive.w(56),
                    height: responsive.w(56),
                    decoration: ShapeDecoration(
                      color: AppColors.white.withValues(alpha: 0.20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.white,
                      size: responsive.text(28),
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.h(14)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.driverProfileProgressLabel,
                    style: AppTextStyles.caption(
                      responsive,
                    ).copyWith(color: AppColors.white),
                  ),
                  Text(
                    AppStrings.driverProfileProgressValue,
                    style: AppTextStyles.caption(responsive).copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: responsive.h(6)),
              ClipRRect(
                borderRadius: BorderRadius.circular(9999),
                child: LinearProgressIndicator(
                  minHeight: responsive.h(8),
                  value: 0.75,
                  backgroundColor: AppColors.white.withValues(alpha: 0.30),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.white,
                  ),
                ),
              ),
              SizedBox(height: responsive.h(14)),
              Row(
                children: const [
                  Expanded(
                    child: _RewardChip(
                      label: AppStrings.driverProfileBadgeCount,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _RewardChip(
                      label: AppStrings.driverProfileTopPercent,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _RewardChip(
                      label: AppStrings.driverProfileBonusCount,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
          height: 1.33,
          letterSpacing: -0.50,
        ),
      ),
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({
    required this.responsive,
    required this.controller,
  });

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          responsive: responsive,
          title: AppStrings.driverProfileSectionPreferences,
        ),
        SizedBox(height: responsive.h(12)),
        Container(
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.surfaceSoft),
            ),
          ),
          child: Column(
            children: [
              Obx(
                () => _PreferenceSwitchRow(
                  responsive: responsive,
                  title: AppStrings.driverProfileAutoAvailability,
                  subtitle: AppStrings.driverProfileAutoAvailabilityHint,
                  icon: Icons.schedule_rounded,
                  value: controller.autoAvailability.value,
                  onChanged: controller.toggleAutoAvailability,
                ),
              ),
              const Divider(height: 1, color: AppColors.surfaceSoft),
              Obx(
                () => _PreferenceSwitchRow(
                  responsive: responsive,
                  title: AppStrings.driverProfileNotifications,
                  subtitle: AppStrings.driverProfileNotificationsHint,
                  icon: Icons.notifications_rounded,
                  value: controller.notificationsEnabled.value,
                  onChanged: controller.toggleNotifications,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PreferenceSwitchRow extends StatelessWidget {
  const _PreferenceSwitchRow({
    required this.responsive,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final AppResponsive responsive;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: responsive.w(40),
        height: responsive.w(40),
        decoration: ShapeDecoration(
          color: AppColors.surfaceSoft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Icon(icon, color: AppColors.textHint, size: responsive.text(18)),
      ),
      title: Text(
        title,
        style: AppTextStyles.profileSectionLabel(
          responsive,
        ).copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle, style: AppTextStyles.caption(responsive)),
      trailing: Switch.adaptive(
        value: value,
        // ignore: deprecated_member_use
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          responsive: responsive,
          title: AppStrings.driverProfileSectionSettings,
        ),
        SizedBox(height: responsive.h(12)),
        Container(
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.surfaceSoft),
            ),
            shadows: const [
              BoxShadow(
                color: AppColors.shadowSoft,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: controller.settings
                .map((setting) {
                  return ListTile(
                    onTap: () => controller.onSettingTap(setting),
                    leading: Icon(
                      setting.icon,
                      color: AppColors.textPrimary,
                      size: responsive.text(18),
                    ),
                    title: Text(
                      setting.title,
                      style: AppTextStyles.profileSectionLabel(
                        responsive,
                      ).copyWith(color: AppColors.textPrimary),
                    ),
                    trailing: setting.trailing == null
                        ? Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.textHint,
                            size: responsive.text(18),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                setting.trailing!,
                                style: AppTextStyles.caption(responsive),
                              ),
                              SizedBox(width: responsive.w(6)),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textHint,
                                size: responsive.text(18),
                              ),
                            ],
                          ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

import '../controllers/add_vehicle_controller.dart';

class AddVehicleView extends GetView<AddVehicleController> {
  const AddVehicleView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
                responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                responsive.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
              ),
              children: [
                _TopBar(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(24)),
                _HeroSection(responsive: responsive),
                SizedBox(height: responsive.h(24)),
                _VehicleTypeSelector(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(24)),
                _VehicleInfoForm(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(24)),
                _PhotoUploadSection(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(24)),
                _DocumentsSection(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(24)),
                _SecuritySection(responsive: responsive),
                SizedBox(height: responsive.h(24)),
                _RegisterButton(responsive: responsive, controller: controller),
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
  final AddVehicleController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 16, smallPhone: 14, tablet: 16, desktop: 16)),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.surfaceSoft),
          borderRadius: BorderRadius.circular(responsive.radius(20)),
        ),
      ),
      child: Row(
        children: [
          AppCircularButton(
            responsive: responsive,
            icon: Icons.arrow_back_rounded,
            onTap: controller.onBack,
            size: responsive.w(40),
          ),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Column(
              children: [
                Text(
                  AppStrings.driverVehicleTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.profileSectionTitle(responsive).copyWith(
                    fontSize: responsive.text(18),
                  ),
                ),
                SizedBox(height: responsive.h(2)),
                Container(
                  width: responsive.w(58),
                  height: responsive.h(6),
                  decoration: ShapeDecoration(
                    color: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.w(12)),
          AppCircularButton(
            responsive: responsive,
            icon: Icons.save_outlined,
            onTap: controller.onSaveAsDraft,
            size: responsive.w(40),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 24, smallPhone: 20, tablet: 24, desktop: 24)),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0, 0),
          end: Alignment(1, 1),
          colors: [Color(0xFF00A86B), Color(0xFF008F5A)],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: responsive.w(64),
            height: responsive.w(64),
            decoration: ShapeDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
              ),
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: AppColors.white,
              size: responsive.text(28),
            ),
          ),
          SizedBox(height: responsive.h(16)),
          Text(
            AppStrings.driverVehicleHeroTitle,
            style: AppTextStyles.rolesCardTitle(responsive).copyWith(
              color: AppColors.white,
              fontSize: responsive.text(20),
            ),
          ),
          SizedBox(height: responsive.h(8)),
          Text(
            AppStrings.driverVehicleHeroSubtitle,
            style: AppTextStyles.caption(responsive).copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: responsive.text(14), color: AppColors.white),
              SizedBox(width: responsive.w(6)),
              Text(
                AppStrings.driverVehicleHeroTime,
                style: AppTextStyles.caption(responsive).copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleTypeSelector extends StatelessWidget {
  const _VehicleTypeSelector({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddVehicleController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.driverVehicleTypeTitle,
            style: AppTextStyles.profileSectionTitle(responsive),
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              Expanded(
                child: _VehicleTypeCard(
                  responsive: responsive,
                  type: VehicleType.car,
                  title: 'Voiture',
                  subtitle: '4+ places',
                  icon: Icons.directions_car_rounded,
                  selected: controller.selectedVehicleType.value == VehicleType.car,
                  onTap: () => controller.selectVehicleType(VehicleType.car),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: _VehicleTypeCard(
                  responsive: responsive,
                  type: VehicleType.motorcycle,
                  title: 'Moto',
                  subtitle: '1-2 places',
                  icon: Icons.two_wheeler_rounded,
                  selected: controller.selectedVehicleType.value == VehicleType.motorcycle,
                  onTap: () => controller.selectVehicleType(VehicleType.motorcycle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  const _VehicleTypeCard({
    required this.responsive,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final AppResponsive responsive;
  final VehicleType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        child: Container(
          height: responsive.adaptive(phone: 140, smallPhone: 130, tablet: 140, desktop: 140),
          padding: EdgeInsets.all(responsive.w(16)),
          decoration: ShapeDecoration(
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: BorderSide(
                width: 2,
                color: selected ? AppColors.primary : AppColors.border,
              ),
            ),
            shadows: selected
                ? const [
                    BoxShadow(
                      color: Color(0x3300A86B),
                      blurRadius: 15,
                      offset: Offset(0, 10),
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: responsive.w(48),
                height: responsive.w(48),
                decoration: ShapeDecoration(
                  color: selected ? const Color(0x1900A86B) : AppColors.surfaceMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                ),
                child: Icon(
                  icon,
                  color: selected ? AppColors.primary : AppColors.textMuted,
                  size: responsive.text(24),
                ),
              ),
              SizedBox(height: responsive.h(12)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: responsive.h(4)),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(responsive).copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleInfoForm extends StatelessWidget {
  const _VehicleInfoForm({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddVehicleController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 24, smallPhone: 20, tablet: 24, desktop: 24)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
          side: const BorderSide(color: AppColors.border),
        ),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.driverVehicleInfoTitle,
            style: AppTextStyles.profileSectionTitle(responsive),
          ),
          SizedBox(height: responsive.h(24)),
          _FormField(
            responsive: responsive,
            label: AppStrings.driverVehicleBrand,
            hint: 'Ex: Toyota, Peugeot...',
            controller: controller.brandController,
          ),
          SizedBox(height: responsive.h(16)),
          _FormField(
            responsive: responsive,
            label: AppStrings.driverVehicleModel,
            hint: 'Ex: Corolla, 307...',
            controller: controller.modelController,
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  responsive: responsive,
                  label: AppStrings.driverVehicleColor,
                  hint: 'Blanc',
                  controller: controller.colorController,
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: _FormField(
                  responsive: responsive,
                  label: AppStrings.driverVehicleYear,
                  hint: '2020',
                  controller: controller.yearController,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          _FormField(
            responsive: responsive,
            label: AppStrings.driverVehiclePlate,
            hint: 'Ex: AB 1234 CD',
            controller: controller.licensePlateController,
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              Expanded(
                child: _FormField(
                  responsive: responsive,
                  label: AppStrings.driverVehicleSeats,
                  hint: '4 places',
                  controller: controller.seatsController,
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: _FormField(
                  responsive: responsive,
                  label: AppStrings.driverVehicleFuel,
                  hint: 'Essence',
                  controller: controller.fuelController,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.responsive,
    required this.label,
    required this.hint,
    required this.controller,
  });

  final AppResponsive responsive;
  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.profileSectionLabel(responsive).copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.h(8)),
        Container(
          height: responsive.adaptive(phone: 40, smallPhone: 38, tablet: 40, desktop: 40),
          padding: EdgeInsets.symmetric(horizontal: responsive.w(16)),
          decoration: ShapeDecoration(
            color: const Color(0xFFF9FAFB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              hintStyle: AppTextStyles.caption(responsive).copyWith(
                color: AppColors.textMuted,
              ),
            ),
            style: AppTextStyles.profileFieldValue(responsive),
          ),
        ),
      ],
    );
  }
}

class _PhotoUploadSection extends StatelessWidget {
  const _PhotoUploadSection({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddVehicleController controller;

  @override
  Widget build(BuildContext context) {
    final photoSlots = [
      ('Vue avant', Icons.camera_alt_rounded),
      ('Vue arrière', Icons.camera_alt_rounded),
      ('Intérieur', Icons.camera_alt_rounded),
      ('Plaque', Icons.image_rounded),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 24, smallPhone: 20, tablet: 24, desktop: 24)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
          side: const BorderSide(color: AppColors.border),
        ),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.driverVehiclePhotosTitle,
            style: AppTextStyles.profileSectionTitle(responsive),
          ),
          SizedBox(height: responsive.h(8)),
          Text(
            AppStrings.driverVehiclePhotosSubtitle,
            style: AppTextStyles.caption(responsive).copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: responsive.h(24)),
          Wrap(
            spacing: responsive.w(12),
            runSpacing: responsive.h(12),
            children: photoSlots
                .map(
                  (slot) => _PhotoUploadSlot(
                    responsive: responsive,
                    label: slot.$1,
                    icon: slot.$2,
                    onTap: () => controller.onAddPhoto(slot.$1),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _PhotoUploadSlot extends StatelessWidget {
  const _PhotoUploadSlot({
    required this.responsive,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final AppResponsive responsive;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final slotSize = responsive.w(142);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        child: Container(
          width: slotSize,
          height: slotSize,
          decoration: ShapeDecoration(
            color: const Color(0xFFF9FAFB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(
                width: 2,
                color: Color(0xFFD1D5DB),
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: responsive.text(24), color: AppColors.textMuted),
              SizedBox(height: responsive.h(8)),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(responsive).copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddVehicleController controller;

  @override
  Widget build(BuildContext context) {
    final documents = [
      (
        label: 'Carte grise',
        icon: Icons.description_rounded,
        color: const Color(0x192563EB),
      ),
      (
        label: 'Assurance',
        icon: Icons.shield_rounded,
        color: const Color(0x1900A86B),
      ),
      (
        label: 'Permis de conduire',
        icon: Icons.badge_rounded,
        color: const Color(0x19F4B400),
      ),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 24, smallPhone: 20, tablet: 24, desktop: 24)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
          side: const BorderSide(color: AppColors.border),
        ),
        shadows: const [
          BoxShadow(color: Color(0x0C000000), blurRadius: 2, offset: Offset(0, 1)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.driverVehicleDocumentsTitle,
            style: AppTextStyles.profileSectionTitle(responsive),
          ),
          SizedBox(height: responsive.h(8)),
          Text(
            AppStrings.driverVehicleDocumentsSubtitle,
            style: AppTextStyles.caption(responsive).copyWith(
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: responsive.h(24)),
          ...documents
              .map(
                (doc) => Column(
                  children: [
                    _DocumentRow(
                      responsive: responsive,
                      label: doc.label,
                      icon: doc.icon,
                      badgeColor: doc.color,
                      onTap: () => controller.onAddDocument(doc.label),
                    ),
                    if (doc != documents.last) SizedBox(height: responsive.h(16)),
                  ],
                ),
              )
              .toList(growable: false),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.responsive,
    required this.label,
    required this.icon,
    required this.badgeColor,
    required this.onTap,
  });

  final AppResponsive responsive;
  final String label;
  final IconData icon;
  final Color badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(16)),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(16)),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.w(48),
            height: responsive.w(48),
            decoration: ShapeDecoration(
              color: badgeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.textSecondary,
              size: responsive.text(20),
            ),
          ),
          SizedBox(width: responsive.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: responsive.h(4)),
                Text(
                  'Document obligatoire',
                  style: AppTextStyles.caption(responsive),
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.w(12)),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(responsive.radius(12)),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(16),
                  vertical: responsive.h(8),
                ),
                decoration: ShapeDecoration(
                  color: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                ),
                child: Text(
                  'Ajouter',
                  style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.adaptive(phone: 24, smallPhone: 20, tablet: 24, desktop: 24)),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0, 0.5),
          end: Alignment(1, 0.5),
          colors: [Color(0x0C2563EB), Color(0x0C00A86B)],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
          side: const BorderSide(color: Color(0x332563EB)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: responsive.w(48),
                height: responsive.w(48),
                decoration: ShapeDecoration(
                  color: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  color: AppColors.white,
                  size: responsive.text(24),
                ),
              ),
              SizedBox(width: responsive.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.driverVehicleSecurityTitle,
                      style: AppTextStyles.profileSectionTitle(responsive),
                    ),
                    SizedBox(height: responsive.h(4)),
                    Text(
                      'Votre profil est protégé',
                      style: AppTextStyles.caption(responsive),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          Wrap(
            spacing: responsive.w(12),
            runSpacing: responsive.h(12),
            children: [
              _SecurityBadge(
                responsive: responsive,
                label: 'Téléphone vérifié',
                icon: Icons.phone_rounded,
              ),
              _SecurityBadge(
                responsive: responsive,
                label: 'Identité validée',
                icon: Icons.verified_user_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({
    required this.responsive,
    required this.label,
    required this.icon,
  });

  final AppResponsive responsive;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: responsive.text(16), color: AppColors.textSecondary),
        SizedBox(width: responsive.w(8)),
        Text(
          label,
          style: AppTextStyles.caption(responsive).copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddVehicleController controller;

  @override
  Widget build(BuildContext context) {
    return AppPrimaryButton(
      responsive: responsive,
      label: AppStrings.driverVehicleRegisterButton,
      onTap: controller.onRegisterVehicle,
      height: responsive.adaptive(phone: 56, smallPhone: 52, tablet: 56, desktop: 56),
      borderRadius: responsive.radius(16),
    );
  }
}
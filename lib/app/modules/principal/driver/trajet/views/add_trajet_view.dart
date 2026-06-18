import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

import '../controllers/add_trajet_controller.dart';

class AddTrajetView extends GetView<AddTrajetController> {
  const AddTrajetView({super.key});

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
                responsive.adaptive(
                  phone: 16,
                  smallPhone: 14,
                  tablet: 20,
                  desktop: 24,
                ),
                responsive.adaptive(
                  phone: 12,
                  smallPhone: 10,
                  tablet: 14,
                  desktop: 16,
                ),
                responsive.adaptive(
                  phone: 16,
                  smallPhone: 14,
                  tablet: 20,
                  desktop: 24,
                ),
                responsive.adaptive(
                  phone: 24,
                  smallPhone: 20,
                  tablet: 28,
                  desktop: 32,
                ),
              ),
              children: [
                _TopBar(responsive: responsive),
                SizedBox(height: responsive.h(16)),
                _HeroSection(responsive: responsive),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Départ',
                  subtitle: 'D’où partez-vous ?',
                  icon: Icons.trip_origin_rounded,
                  child: _LocationForm(
                    responsive: responsive,
                    cityController: controller.departureCityController,
                    districtController: controller.departureDistrictController,
                    pointController: controller.departurePointController,
                    hintCity: 'Ex: Cotonou',
                    hintDistrict: 'Ex: Akpakpa',
                    hintPoint: 'Ex: Carrefour Étoile Rouge',
                    suggestions: controller.departureSuggestions,
                  ),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Destination',
                  subtitle: 'Où allez-vous ?',
                  icon: Icons.flag_rounded,
                  child: _LocationForm(
                    responsive: responsive,
                    cityController: controller.destinationCityController,
                    districtController:
                        controller.destinationDistrictController,
                    pointController: controller.destinationPointController,
                    hintCity: 'Ex: Parakou',
                    hintDistrict: 'Ex: Centre-ville',
                    hintPoint: 'Ex: Gare routière',
                    suggestions: controller.destinationSuggestions,
                  ),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Date et heure',
                  subtitle: 'Quand partez-vous ?',
                  icon: Icons.schedule_rounded,
                  child: _DateTimeInputs(responsive: responsive),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Type de véhicule',
                  subtitle: 'Que conduisez-vous ?',
                  icon: Icons.directions_car_rounded,
                  child: _VehicleSelector(
                    responsive: responsive,
                    controller: controller,
                  ),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Places disponibles',
                  subtitle: 'Combien de passagers ?',
                  icon: Icons.airline_seat_recline_normal_rounded,
                  child: _SeatsPicker(
                    responsive: responsive,
                    controller: controller,
                  ),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Prix par place',
                  subtitle: 'Fixez votre tarif',
                  icon: Icons.payments_rounded,
                  child: _PricingCard(
                    responsive: responsive,
                    controller: controller,
                  ),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Description',
                  subtitle: 'Optionnel',
                  icon: Icons.notes_rounded,
                  child: AppField(
                    responsive: responsive,
                    label: 'Décrivez votre trajet',
                    controller: controller.descriptionController,
                    hintText: 'Ajoutez des détails sur votre trajet',
                    textStyle: AppTextStyles.profileFieldValue(responsive),
                    hintStyle: AppTextStyles.muted(responsive),
                    labelStyle: AppTextStyles.profileSectionLabel(responsive),
                    backgroundColor: AppColors.surface,
                    borderColor: AppColors.border,
                    borderRadius: responsive.radius(16),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(16),
                      vertical: responsive.h(12),
                    ),
                  ),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Préférences',
                  subtitle: 'Configurez votre trajet',
                  icon: Icons.tune_rounded,
                  child: _PreferencesGrid(
                    responsive: responsive,
                    controller: controller,
                  ),
                ),
                SizedBox(height: responsive.h(24)),
                AppPrimaryButton(
                  responsive: responsive,
                  label: AppStrings.driverCreateTripPublish,
                  onTap: controller.publishTrip,
                  height: responsive.adaptive(
                    phone: 56,
                    smallPhone: 52,
                    tablet: 56,
                    desktop: 56,
                  ),
                  borderRadius: responsive.radius(16),
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
  const _TopBar({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(16)),
      decoration: ShapeDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(20)),
          side: const BorderSide(color: AppColors.surfaceSoft),
        ),
      ),
      child: Row(
        children: [
          AppCircularButton(
            responsive: responsive,
            icon: Icons.arrow_back_rounded,
            onTap: () =>
                Get.offAllNamed(AppRoutes.dashboardDriver, arguments: 1),
            size: responsive.w(40),
          ),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  AppStrings.driverCreateTripTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.profileSectionTitle(
                    responsive,
                  ).copyWith(fontSize: responsive.text(18)),
                ),
                SizedBox(height: responsive.h(2)),
                Text(
                  AppStrings.driverCreateTripSubtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(responsive),
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.w(12)),
          AppCircularButton(
            responsive: responsive,
            icon: Icons.save_outlined,
            onTap: () =>
                UIHelper().showSnackBar(AppStrings.appName, 'Brouillon sauvegardé.', 0),
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
      padding: EdgeInsets.all(responsive.w(20)),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.success],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
          side: const BorderSide(color: AppColors.border),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: responsive.w(64),
            height: responsive.w(64),
            decoration: ShapeDecoration(
              color: AppColors.white.withValues(alpha: 0.20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Icon(
              Icons.route_rounded,
              color: AppColors.white,
              size: responsive.text(28),
            ),
          ),
          SizedBox(height: responsive.h(16)),
          Text(
            AppStrings.driverCreateTripHeroTitle,
            style: AppTextStyles.rolesCardTitle(
              responsive,
            ).copyWith(color: AppColors.white, fontSize: responsive.text(20)),
          ),
          SizedBox(height: responsive.h(4)),
          Text(
            AppStrings.driverCreateTripHeroSubtitle,
            style: AppTextStyles.caption(
              responsive,
            ).copyWith(color: AppColors.white.withValues(alpha: 0.90)),
          ),
          SizedBox(height: responsive.h(16)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.w(12)),
            decoration: ShapeDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _HeroStat(
                    label: 'Revenus possibles',
                    value: '15 000 - 25 000 FCFA',
                    responsive: responsive,
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

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.responsive,
  });

  final String label;
  final String value;
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption(
            responsive,
          ).copyWith(color: AppColors.white.withValues(alpha: 0.85)),
        ),
        SizedBox(height: responsive.h(4)),
        Text(
          value,
          style: AppTextStyles.profileSectionTitle(
            responsive,
          ).copyWith(color: AppColors.white, fontSize: responsive.text(18)),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.responsive,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final AppResponsive responsive;
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(responsive.w(20)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: responsive.w(48),
                height: responsive.w(48),
                decoration: ShapeDecoration(
                  color: AppColors.surfaceAccentStrong,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: responsive.text(20),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.h6(responsive)),
                    Text(subtitle, style: AppTextStyles.caption(responsive)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          child,
        ],
      ),
    );
  }
}

class _LocationForm extends StatelessWidget {
  const _LocationForm({
    required this.responsive,
    required this.cityController,
    required this.districtController,
    required this.pointController,
    required this.hintCity,
    required this.hintDistrict,
    required this.hintPoint,
    required this.suggestions,
  });

  final AppResponsive responsive;
  final TextEditingController cityController;
  final TextEditingController districtController;
  final TextEditingController pointController;
  final String hintCity;
  final String hintDistrict;
  final String hintPoint;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppField(
          responsive: responsive,
          label: 'Ville',
          controller: cityController,
          hintText: hintCity,
          textStyle: AppTextStyles.profileFieldValue(responsive),
          hintStyle: AppTextStyles.muted(responsive),
          labelStyle: AppTextStyles.profileSectionLabel(responsive),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.border,
          borderRadius: responsive.radius(16),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16),
            vertical: responsive.h(12),
          ),
        ),
        SizedBox(height: responsive.h(12)),
        AppField(
          responsive: responsive,
          label: 'Quartier',
          controller: districtController,
          hintText: hintDistrict,
          textStyle: AppTextStyles.profileFieldValue(responsive),
          hintStyle: AppTextStyles.muted(responsive),
          labelStyle: AppTextStyles.profileSectionLabel(responsive),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.border,
          borderRadius: responsive.radius(16),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16),
            vertical: responsive.h(12),
          ),
        ),
        SizedBox(height: responsive.h(12)),
        AppField(
          responsive: responsive,
          label: 'Point précis',
          controller: pointController,
          hintText: hintPoint,
          textStyle: AppTextStyles.profileFieldValue(responsive),
          hintStyle: AppTextStyles.muted(responsive),
          labelStyle: AppTextStyles.profileSectionLabel(responsive),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.border,
          borderRadius: responsive.radius(16),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16),
            vertical: responsive.h(12),
          ),
        ),
        SizedBox(height: responsive.h(12)),
        Wrap(
          spacing: responsive.w(8),
          runSpacing: responsive.h(8),
          children: suggestions
              .map(
                (suggestion) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(16),
                    vertical: responsive.h(8),
                  ),
                  decoration: ShapeDecoration(
                    color: AppColors.surfaceSoft,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9999),
                      side: const BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: AppTextStyles.profileSectionLabel(responsive),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _DateTimeInputs extends StatelessWidget {
  const _DateTimeInputs({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppField(
            responsive: responsive,
            label: 'Date',
            hintText: 'mm/dd/yyyy',
            keyboardType: TextInputType.datetime,
            textStyle: AppTextStyles.profileFieldValue(responsive),
            hintStyle: AppTextStyles.muted(responsive),
            labelStyle: AppTextStyles.profileSectionLabel(responsive),
            backgroundColor: AppColors.surface,
            borderColor: AppColors.border,
            borderRadius: responsive.radius(16),
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(16),
              vertical: responsive.h(12),
            ),
          ),
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: AppField(
            responsive: responsive,
            label: 'Heure',
            hintText: '--:-- --',
            keyboardType: TextInputType.datetime,
            textStyle: AppTextStyles.profileFieldValue(responsive),
            hintStyle: AppTextStyles.muted(responsive),
            labelStyle: AppTextStyles.profileSectionLabel(responsive),
            backgroundColor: AppColors.surface,
            borderColor: AppColors.border,
            borderRadius: responsive.radius(16),
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(16),
              vertical: responsive.h(12),
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleSelector extends StatelessWidget {
  const _VehicleSelector({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: controller.vehicleCards
            .map((vehicle) {
              final bool selected =
                  controller.selectedVehicleType.value == vehicle.type;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: vehicle.type == TripVehicleType.car
                        ? responsive.w(12)
                        : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => controller.selectVehicleType(vehicle.type),
                    child: Container(
                      height: responsive.adaptive(
                        phone: 128,
                        smallPhone: 120,
                        tablet: 132,
                        desktop: 132,
                      ),
                      padding: EdgeInsets.all(responsive.w(16)),
                      decoration: ShapeDecoration(
                        gradient: selected
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0x0C00A86B), Color(0x0500A86B)],
                              )
                            : null,
                        color: selected ? null : AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            responsive.radius(16),
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: responsive.w(56),
                            height: responsive.w(56),
                            decoration: ShapeDecoration(
                              color: selected
                                  ? AppColors.surfaceAccentStrong
                                  : AppColors.surfaceSoft,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Icon(
                              vehicle.icon,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: responsive.text(24),
                            ),
                          ),
                          SizedBox(height: responsive.h(8)),
                          Text(
                            vehicle.title,
                            style: AppTextStyles.profileSectionLabel(responsive)
                                .copyWith(
                                  color: selected
                                      ? AppColors.textPrimary
                                      : AppColors.textMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

class _SeatsPicker extends StatelessWidget {
  const _SeatsPicker({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppCircularButton(
            responsive: responsive,
            icon: Icons.remove_rounded,
            onTap: controller.decrementSeats,
            size: responsive.w(56),
          ),
          SizedBox(width: responsive.w(20)),
          Column(
            children: [
              Text(
                controller.availableSeats.value.toString(),
                style: AppTextStyles.rolesCardTitle(responsive).copyWith(
                  fontSize: responsive.text(36),
                  color: AppColors.primary,
                ),
              ),
              Text('places', style: AppTextStyles.caption(responsive)),
            ],
          ),
          SizedBox(width: responsive.w(20)),
          AppCircularButton(
            responsive: responsive,
            icon: Icons.add_rounded,
            onTap: controller.incrementSeats,
            filled: true,
            size: responsive.w(56),
          ),
        ],
      ),
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prix suggéré: 5 000 FCFA',
            style: AppTextStyles.profileSectionLabel(responsive),
          ),
          SizedBox(height: responsive.h(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.w(16)),
            decoration: ShapeDecoration(
              color: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: BorderSide(width: 2, color: AppColors.surfaceAccentWeak),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    controller.pricePerSeat.value.toInt().toString(),
                    style: AppTextStyles.rolesCardTitle(responsive).copyWith(
                      fontSize: responsive.text(24),
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  AppStrings.revenuesCurrency,
                  style: AppTextStyles.profileSectionLabel(responsive),
                ),
              ],
            ),
          ),
          SizedBox(height: responsive.h(12)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.w(16)),
            decoration: ShapeDecoration(
              color: AppColors.surfaceMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text('3 places × 5 000 FCFA'),
                Text('15 000 FCFA'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferencesGrid extends StatelessWidget {
  const _PreferencesGrid({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.preferences
            .map((item) {
              final bool selected = controller.selectedOptions.contains(
                item.option,
              );

              return Padding(
                padding: EdgeInsets.only(bottom: responsive.h(12)),
                child: Container(
                  padding: EdgeInsets.all(responsive.w(12)),
                  decoration: ShapeDecoration(
                    color: selected ? const Color(0x0C00A86B) : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        responsive.radius(16),
                      ),
                      side: BorderSide(
                        color: selected ? AppColors.primary : AppColors.border,
                        width: selected ? 2 : 1,
                      ),
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
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Icon(
                          item.icon,
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
                              item.title,
                              style: AppTextStyles.profileSectionLabel(
                                responsive,
                              ).copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              item.subtitle,
                              style: AppTextStyles.caption(responsive),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: selected,
                        // ignore: deprecated_member_use
                        activeColor: AppColors.primary,
                        onChanged: (_) => controller.toggleOption(item.option),
                      ),
                    ],
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}

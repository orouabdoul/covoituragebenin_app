import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                responsive.adaptive(phone: 12, smallPhone: 10, tablet: 14, desktop: 16),
                responsive.adaptive(phone: 16, smallPhone: 14, tablet: 20, desktop: 24),
                responsive.adaptive(phone: 24, smallPhone: 20, tablet: 28, desktop: 32),
              ),
              children: [
                _TopBar(responsive: responsive),
                SizedBox(height: responsive.h(16)),
                _HeroSection(responsive: responsive),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Départ',
                  subtitle: "D'où partez-vous ?",
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
                    districtController: controller.destinationDistrictController,
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
                  child: _DateTimeInputs(
                    responsive: responsive,
                    dateController: controller.dateController,
                    timeController: controller.timeController,
                  ),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Véhicule & Capacité',
                  subtitle: 'Type, marque et modèle',
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
                  height: responsive.adaptive(phone: 56, smallPhone: 52, tablet: 56, desktop: 56),
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

// ── Top bar ────────────────────────────────────────────────────────────────────

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
            onTap: () => Get.offAllNamed(AppRoutes.dashboardDriver, arguments: 1),
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
                  style: AppTextStyles.profileSectionTitle(responsive)
                      .copyWith(fontSize: responsive.text(18)),
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
            onTap: () => UIHelper()
                .showSnackBar(AppStrings.appName, 'Brouillon sauvegardé.', 0),
            size: responsive.w(40),
          ),
        ],
      ),
    );
  }
}

// ── Hero section ───────────────────────────────────────────────────────────────

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
          BoxShadow(color: AppColors.shadow, blurRadius: 20, offset: Offset(0, 4)),
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
            child: Icon(Icons.route_rounded, color: AppColors.white, size: responsive.text(28)),
          ),
          SizedBox(height: responsive.h(16)),
          Text(
            AppStrings.driverCreateTripHeroTitle,
            style: AppTextStyles.rolesCardTitle(responsive)
                .copyWith(color: AppColors.white, fontSize: responsive.text(20)),
          ),
          SizedBox(height: responsive.h(4)),
          Text(
            AppStrings.driverCreateTripHeroSubtitle,
            style: AppTextStyles.caption(responsive)
                .copyWith(color: AppColors.white.withValues(alpha: 0.90)),
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
            child: _HeroStat(
              label: 'Revenus possibles',
              value: '15 000 - 25 000 FCFA',
              responsive: responsive,
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
          style: AppTextStyles.caption(responsive)
              .copyWith(color: AppColors.white.withValues(alpha: 0.85)),
        ),
        SizedBox(height: responsive.h(4)),
        Text(
          value,
          style: AppTextStyles.profileSectionTitle(responsive)
              .copyWith(color: AppColors.white, fontSize: responsive.text(18)),
        ),
      ],
    );
  }
}

// ── Section card wrapper ───────────────────────────────────────────────────────

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
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 2, offset: Offset(0, 1)),
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
                child: Icon(icon, color: AppColors.primary, size: responsive.text(20)),
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

// ── Location form ──────────────────────────────────────────────────────────────

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
        // Suggestion chips — tap fills the city field
        Wrap(
          spacing: responsive.w(8),
          runSpacing: responsive.h(8),
          children: suggestions
              .map(
                (s) => GestureDetector(
                  onTap: () {
                    cityController.text = s;
                    cityController.selection = TextSelection.fromPosition(
                      TextPosition(offset: s.length),
                    );
                  },
                  child: Container(
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: responsive.text(12),
                          color: AppColors.primary,
                        ),
                        SizedBox(width: responsive.w(4)),
                        Text(s, style: AppTextStyles.profileSectionLabel(responsive)),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

// ── Date / time inputs ─────────────────────────────────────────────────────────

class _DateTimeInputs extends StatelessWidget {
  const _DateTimeInputs({
    required this.responsive,
    required this.dateController,
    required this.timeController,
  });

  final AppResponsive responsive;
  final TextEditingController dateController;
  final TextEditingController timeController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: AppField(
            responsive: responsive,
            label: 'Date',
            controller: dateController,
            hintText: 'jj/mm/aaaa',
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
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(hours: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                final d = picked;
                dateController.text =
                    '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
              }
            },
            readOnly: true,
          ),
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: AppField(
            responsive: responsive,
            label: 'Heure',
            controller: timeController,
            hintText: '--:--',
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
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                timeController.text =
                    '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
              }
            },
            readOnly: true,
          ),
        ),
      ],
    );
  }
}

// ── Vehicle selector ───────────────────────────────────────────────────────────

class _VehicleSelector extends StatelessWidget {
  const _VehicleSelector({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type toggle (Voiture / Moto)
          Row(
            children: controller.vehicleCards.map((vehicle) {
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
                        phone: 112,
                        smallPhone: 100,
                        tablet: 120,
                        desktop: 120,
                      ),
                      padding: EdgeInsets.all(responsive.w(14)),
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
                          borderRadius:
                              BorderRadius.circular(responsive.radius(16)),
                          side: BorderSide(
                            color:
                                selected ? AppColors.primary : AppColors.border,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: responsive.w(48),
                            height: responsive.w(48),
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
                              size: responsive.text(22),
                            ),
                          ),
                          SizedBox(height: responsive.h(6)),
                          Text(
                            vehicle.title,
                            style:
                                AppTextStyles.profileSectionLabel(responsive)
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
            }).toList(growable: false),
          ),

          SizedBox(height: responsive.h(16)),

          // Marque
          _PickerField(
            responsive: responsive,
            label: 'Marque',
            value: controller.selectedBrand.value,
            hint: 'Sélectionner la marque',
            icon: Icons.branding_watermark_rounded,
            onTap: () => _showPicker(
              context,
              title: 'Choisir la marque',
              items: controller.brandsForType,
              selected: controller.selectedBrand.value,
              onSelect: controller.selectBrand,
              responsive: responsive,
            ),
          ),

          SizedBox(height: responsive.h(12)),

          // Modèle
          _PickerField(
            responsive: responsive,
            label: 'Modèle',
            value: controller.selectedModel.value,
            hint: controller.selectedBrand.value == null
                ? 'Choisir la marque d\'abord'
                : 'Sélectionner le modèle',
            icon: Icons.directions_car_outlined,
            disabled: controller.selectedBrand.value == null,
            onTap: controller.selectedBrand.value == null
                ? null
                : () => _showPicker(
                      context,
                      title: 'Choisir le modèle',
                      items: controller.modelsForBrand,
                      selected: controller.selectedModel.value,
                      onSelect: controller.selectModel,
                      responsive: responsive,
                    ),
          ),

          // Bandeau règlementation — visible dès qu'un modèle est choisi
          if (controller.selectedModel.value != null) ...[
            SizedBox(height: responsive.h(12)),
            _LegalBadge(
              responsive: responsive,
              label: controller.capacityLabel,
            ),
          ],
        ],
      );
    });
  }

  static void _showPicker(
    BuildContext context, {
    required String title,
    required List<String> items,
    required String? selected,
    required void Function(String) onSelect,
    required AppResponsive responsive,
  }) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(responsive.radius(24)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: responsive.h(12)),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
            SizedBox(height: responsive.h(16)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: responsive.w(20)),
              child: Text(title,
                  style: AppTextStyles.h6(responsive)),
            ),
            SizedBox(height: responsive.h(8)),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final item = items[i];
                  final isSelected = item == selected;
                  return ListTile(
                    title: Text(
                      item,
                      style: AppTextStyles.profileFieldValue(responsive)
                          .copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle_rounded,
                            color: AppColors.primary,
                            size: responsive.text(20))
                        : null,
                    onTap: () {
                      onSelect(item);
                      Get.back();
                    },
                  );
                },
              ),
            ),
            SizedBox(height: responsive.h(24)),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ── Picker field ────────────────────────────────────────────────────────────────

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.responsive,
    required this.label,
    required this.hint,
    required this.icon,
    this.value,
    this.onTap,
    this.disabled = false,
  });
  final AppResponsive responsive;
  final String label;
  final String hint;
  final IconData icon;
  final String? value;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.profileSectionLabel(responsive)),
        SizedBox(height: responsive.h(8)),
        GestureDetector(
          onTap: disabled ? null : onTap,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(16),
              vertical: responsive.h(14),
            ),
            decoration: ShapeDecoration(
              color: disabled ? AppColors.surfaceMuted : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: BorderSide(
                  width: 2,
                  color: hasValue ? AppColors.primary : AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: responsive.text(18),
                  color: hasValue ? AppColors.primary : AppColors.textGhost,
                ),
                SizedBox(width: responsive.w(10)),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: AppTextStyles.profileFieldValue(responsive).copyWith(
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textGhost,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textGhost,
                  size: responsive.text(20),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Legal capacity badge ────────────────────────────────────────────────────────

class _LegalBadge extends StatelessWidget {
  const _LegalBadge({required this.responsive, required this.label});
  final AppResponsive responsive;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(14),
        vertical: responsive.h(10),
      ),
      decoration: ShapeDecoration(
        color: const Color(0xFFFFFBEB),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          side: const BorderSide(color: Color(0xFFFDE68A)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.gavel_rounded, size: 16, color: Color(0xFFD97706)),
          SizedBox(width: responsive.w(8)),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption(responsive).copyWith(
                color: const Color(0xFF92400E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Seats picker ───────────────────────────────────────────────────────────────

class _SeatsPicker extends StatelessWidget {
  const _SeatsPicker({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final current = controller.availableSeats.value;
      final max = controller.maxPassengers;
      final atMax = current >= max;
      final atMin = current <= 1;

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppCircularButton(
                responsive: responsive,
                icon: Icons.remove_rounded,
                onTap: controller.decrementSeats,
                enabled: !atMin,
                size: responsive.w(56),
              ),
              SizedBox(width: responsive.w(24)),
              Column(
                children: [
                  Text(
                    current.toString(),
                    style: AppTextStyles.rolesCardTitle(responsive).copyWith(
                      fontSize: responsive.text(40),
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'place${current > 1 ? 's' : ''}',
                    style: AppTextStyles.caption(responsive),
                  ),
                ],
              ),
              SizedBox(width: responsive.w(24)),
              AppCircularButton(
                responsive: responsive,
                icon: Icons.add_rounded,
                onTap: controller.incrementSeats,
                filled: true,
                enabled: !atMax,
                size: responsive.w(56),
              ),
            ],
          ),
          SizedBox(height: responsive.h(14)),
          // Barre de progression max légal
          Row(
            children: [
              Text(
                '1',
                style: AppTextStyles.caption(responsive)
                    .copyWith(color: AppColors.textGhost),
              ),
              SizedBox(width: responsive.w(8)),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: max == 0 ? 0 : current / max,
                    minHeight: responsive.h(6),
                    backgroundColor: AppColors.surfaceSoft,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      atMax ? const Color(0xFFEF4444) : AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.w(8)),
              Text(
                '$max max',
                style: AppTextStyles.caption(responsive).copyWith(
                  color: atMax
                      ? const Color(0xFFEF4444)
                      : AppColors.textGhost,
                  fontWeight: atMax ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
          if (atMax) ...[
            SizedBox(height: responsive.h(8)),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: Color(0xFFEF4444)),
                SizedBox(width: responsive.w(6)),
                Expanded(
                  child: Text(
                    'Maximum atteint — ${controller.capacityLabel}',
                    style: AppTextStyles.caption(responsive)
                        .copyWith(color: const Color(0xFFEF4444)),
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

// ── Pricing card ───────────────────────────────────────────────────────────────

class _PricingCard extends StatelessWidget {
  const _PricingCard({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Suggested price hint
        Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded,
                size: responsive.text(14), color: AppColors.primary),
            SizedBox(width: responsive.w(6)),
            Text(
              'Prix suggéré: 5 000 FCFA',
              style: AppTextStyles.profileSectionLabel(responsive)
                  .copyWith(color: AppColors.primary),
            ),
          ],
        ),
        SizedBox(height: responsive.h(12)),

        // Editable price field
        AppField(
          responsive: responsive,
          label: 'Montant par place',
          labelStyle: AppTextStyles.profileSectionLabel(responsive),
          backgroundColor: AppColors.surface,
          borderColor: AppColors.primary,
          borderRadius: responsive.radius(16),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16),
            vertical: responsive.h(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTextStyles.rolesCardTitle(responsive).copyWith(
                    fontSize: responsive.text(22),
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration.collapsed(
                    hintText: '5000',
                    hintStyle: AppTextStyles.muted(responsive).copyWith(
                      fontSize: responsive.text(22),
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.w(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(10),
                  vertical: responsive.h(4),
                ),
                decoration: ShapeDecoration(
                  color: AppColors.surfaceAccentStrong,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(8)),
                  ),
                ),
                child: Text(
                  AppStrings.revenuesCurrency,
                  style: AppTextStyles.profileSectionLabel(responsive)
                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: responsive.h(12)),

        // Reactive total recap
        Obx(() {
          final seats = controller.availableSeats.value;
          final price = controller.pricePerSeat.value.toInt();
          final total = seats * price;
          final fmtPrice = _formatAmount(price);
          final fmtTotal = _formatAmount(total);
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(responsive.w(16)),
            decoration: ShapeDecoration(
              color: AppColors.surfaceAccentStrong,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$seats place${seats > 1 ? 's' : ''} × $fmtPrice FCFA',
                  style: AppTextStyles.profileSectionLabel(responsive),
                ),
                Text(
                  '$fmtTotal FCFA',
                  style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _formatAmount(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

// ── Preferences grid ───────────────────────────────────────────────────────────

class _PreferencesGrid extends StatelessWidget {
  const _PreferencesGrid({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: controller.preferences.map((item) {
          final bool selected = controller.selectedOptions.contains(item.option);
          return Padding(
            padding: EdgeInsets.only(bottom: responsive.h(12)),
            child: Container(
              padding: EdgeInsets.all(responsive.w(12)),
              decoration: ShapeDecoration(
                color: selected ? const Color(0x0C00A86B) : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(16)),
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
                    child: Icon(item.icon,
                        color: AppColors.primary, size: responsive.text(18)),
                  ),
                  SizedBox(width: responsive.w(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: AppTextStyles.profileSectionLabel(responsive)
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(item.subtitle,
                            style: AppTextStyles.caption(responsive)),
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
        }).toList(growable: false),
      ),
    );
  }
}

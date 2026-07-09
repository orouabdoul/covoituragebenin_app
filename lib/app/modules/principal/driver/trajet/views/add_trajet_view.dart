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
import 'package:covoiturage_benin_app/app/data/models/driver/vehicle_model.dart';
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
                _TopBar(responsive: responsive, isEditMode: controller.isEditMode),
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
                    controller: controller,
                    isDeparture: true,
                    hintPoint: 'Ex: Carrefour Étoile Rouge',
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
                    controller: controller,
                    isDeparture: false,
                    hintPoint: 'Ex: Gare routière',
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
                Obx(() => AppPrimaryButton(
                  responsive: responsive,
                  label: controller.isPublishing.value
                      ? (controller.isEditMode ? 'Mise à jour...' : 'Publication en cours...')
                      : (controller.isEditMode ? 'Mettre à jour' : AppStrings.driverCreateTripPublish),
                  onTap: controller.publishTrip,
                  enabled: !controller.isPublishing.value && !controller.isLoadingEdit.value,
                  height: responsive.adaptive(phone: 56, smallPhone: 52, tablet: 56, desktop: 56),
                  borderRadius: responsive.radius(16),
                )),
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
  const _TopBar({required this.responsive, this.isEditMode = false});
  final AppResponsive responsive;
  final bool isEditMode;

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
            onTap: isEditMode
                ? Get.back
                : () => Get.offAllNamed(AppRoutes.dashboardDriver, arguments: 1),
            size: responsive.w(40),
          ),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  isEditMode ? 'Modifier le trajet' : AppStrings.driverCreateTripTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.profileSectionTitle(responsive)
                      .copyWith(fontSize: responsive.text(18)),
                ),
                SizedBox(height: responsive.h(2)),
                Text(
                  isEditMode ? 'Mettez à jour les informations' : AppStrings.driverCreateTripSubtitle,
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
    required this.controller,
    required this.isDeparture,
    required this.hintPoint,
  });

  final AppResponsive responsive;
  final AddTrajetController controller;
  final bool isDeparture;
  final String hintPoint;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedCity = isDeparture
          ? controller.selectedDepartureCity.value
          : controller.selectedDestinationCity.value;
      final selectedDistrict = isDeparture
          ? controller.selectedDepartureDistrict.value
          : controller.selectedDestinationDistrict.value;
      final districts = controller.getDistricts(selectedCity);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LocationAutocompleteField(
            key: ValueKey(isDeparture ? 'dep-city' : 'dest-city'),
            responsive: responsive,
            label: 'Ville',
            controller: isDeparture
                ? controller.departureCityController
                : controller.destinationCityController,
            items: controller.beninCities,
            isSelected: selectedCity != null,
            hint: isDeparture ? 'Ex: Cotonou' : 'Ex: Parakou',
            onSelected: (v) => isDeparture
                ? controller.onDepartureCityChanged(v)
                : controller.onDestinationCityChanged(v),
            onTextChanged: isDeparture
                ? controller.onDepartureCityTyped
                : controller.onDestinationCityTyped,
          ),
          SizedBox(height: responsive.h(12)),
          _LocationAutocompleteField(
            key: ValueKey(isDeparture ? 'dep-district' : 'dest-district'),
            responsive: responsive,
            label: 'Quartier',
            controller: isDeparture
                ? controller.departureDistrictController
                : controller.destinationDistrictController,
            items: districts,
            isSelected: selectedDistrict != null,
            hint: selectedCity == null
                ? "Choisir d'abord une ville"
                : 'Ex: Akpakpa',
            enabled: selectedCity != null,
            onSelected: (v) => isDeparture
                ? controller.onDepartureDistrictChanged(v)
                : controller.onDestinationDistrictChanged(v),
            onTextChanged: isDeparture
                ? controller.onDepartureDistrictTyped
                : controller.onDestinationDistrictTyped,
          ),
          SizedBox(height: responsive.h(12)),
          AppField(
            responsive: responsive,
            label: 'Point précis',
            controller: isDeparture
                ? controller.departurePointController
                : controller.destinationPointController,
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
        ],
      );
    });
  }
}

// ── Location autocomplete field ────────────────────────────────────────────────

class _LocationAutocompleteField extends StatefulWidget {
  const _LocationAutocompleteField({
    super.key,
    required this.responsive,
    required this.label,
    required this.controller,
    required this.items,
    required this.isSelected,
    required this.onSelected,
    required this.onTextChanged,
    this.hint = 'Rechercher...',
    this.enabled = true,
  });

  final AppResponsive responsive;
  final String label;
  final TextEditingController controller;
  final List<String> items;
  final bool isSelected;
  final ValueChanged<String> onSelected;
  final VoidCallback onTextChanged;
  final String hint;
  final bool enabled;

  @override
  State<_LocationAutocompleteField> createState() =>
      _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState
    extends State<_LocationAutocompleteField> {
  final FocusNode _focusNode = FocusNode();
  bool _showList = false;
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    _filtered = _filterItems(widget.controller.text);
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(_LocationAutocompleteField old) {
    super.didUpdateWidget(old);
    if (old.items != widget.items) {
      setState(() {
        _filtered = _filterItems(widget.controller.text);
        _showList = false;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onControllerChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() {
        _showList = true;
        _filtered = _filterItems(widget.controller.text);
      });
    } else {
      // Délai pour laisser le tap sur un item s'enregistrer
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _showList = false);
      });
    }
  }

  void _onControllerChanged() {
    // Mise à jour de la liste filtrée quand le texte change de l'extérieur
    final filtered = _filterItems(widget.controller.text);
    if (filtered.length != _filtered.length && mounted) {
      setState(() => _filtered = filtered);
    }
  }

  List<String> _filterItems(String text) {
    if (text.isEmpty) return widget.items;
    final q = text.toLowerCase();
    return widget.items.where((i) => i.toLowerCase().contains(q)).toList();
  }

  void _onUserTyped(String text) {
    setState(() {
      _showList = true;
      _filtered = _filterItems(text);
    });
    widget.onTextChanged();
  }

  void _selectItem(String item) {
    widget.controller.text = item;
    widget.controller.selection =
        TextSelection.fromPosition(TextPosition(offset: item.length));
    widget.onSelected(item);
    _focusNode.unfocus();
    setState(() => _showList = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasText = widget.controller.text.isNotEmpty;
    final bool isInvalid = hasText && !widget.isSelected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: AppTextStyles.profileSectionLabel(widget.responsive)),
        SizedBox(height: widget.responsive.h(8)),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: widget.responsive.w(16),
            vertical: widget.responsive.h(12),
          ),
          decoration: ShapeDecoration(
            color: widget.enabled ? AppColors.surface : AppColors.surfaceSoft,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 2,
                color: isInvalid
                    ? const Color(0xFFEF4444)
                    : widget.isSelected
                        ? AppColors.primary
                        : widget.enabled
                            ? AppColors.border
                            : AppColors.surfaceSoft,
              ),
              borderRadius:
                  BorderRadius.circular(widget.responsive.radius(16)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  onChanged: _onUserTyped,
                  decoration: InputDecoration.collapsed(
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.muted(widget.responsive),
                  ),
                  style: AppTextStyles.profileFieldValue(widget.responsive),
                ),
              ),
              SizedBox(width: widget.responsive.w(8)),
              if (widget.isSelected)
                Icon(Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: widget.responsive.text(18))
              else if (isInvalid)
                Icon(Icons.error_outline_rounded,
                    color: const Color(0xFFEF4444),
                    size: widget.responsive.text(18))
              else
                Icon(Icons.search_rounded,
                    color: AppColors.textGhost,
                    size: widget.responsive.text(18)),
            ],
          ),
        ),
        if (isInvalid) ...[
          SizedBox(height: widget.responsive.h(4)),
          Text(
            'Sélectionnez une option dans la liste',
            style: AppTextStyles.caption(widget.responsive)
                .copyWith(color: const Color(0xFFEF4444)),
          ),
        ],
        if (_showList && widget.enabled) ...[
          SizedBox(height: widget.responsive.h(4)),
          if (_filtered.isNotEmpty)
            Container(
              constraints:
                  BoxConstraints(maxHeight: widget.responsive.h(200)),
              decoration: ShapeDecoration(
                color: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(widget.responsive.radius(16)),
                  side: const BorderSide(color: AppColors.border),
                ),
                shadows: const [
                  BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 12,
                      offset: Offset(0, 4)),
                ],
              ),
              child: ListView.builder(
                padding: EdgeInsets.symmetric(
                    vertical: widget.responsive.h(4)),
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (context, index) {
                  final item = _filtered[index];
                  return InkWell(
                    onTap: () => _selectItem(item),
                    borderRadius: BorderRadius.circular(
                        widget.responsive.radius(12)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: widget.responsive.w(16),
                        vertical: widget.responsive.h(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_rounded,
                              color: AppColors.primary,
                              size: widget.responsive.text(14)),
                          SizedBox(width: widget.responsive.w(8)),
                          Expanded(
                            child: Text(item,
                                style: AppTextStyles.profileFieldValue(
                                    widget.responsive)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          else if (widget.controller.text.isNotEmpty)
            Container(
              padding: EdgeInsets.all(widget.responsive.w(16)),
              decoration: ShapeDecoration(
                color: AppColors.surfaceSoft,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(widget.responsive.radius(16)),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      color: AppColors.textGhost,
                      size: widget.responsive.text(16)),
                  SizedBox(width: widget.responsive.w(8)),
                  Text('Aucun résultat',
                      style: AppTextStyles.caption(widget.responsive)),
                ],
              ),
            ),
        ],
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
      if (controller.isLoadingVehicles.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: responsive.h(24)),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.availableVehicles.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.w(20)),
          decoration: ShapeDecoration(
            color: AppColors.surfaceSoft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
            ),
          ),
          child: Column(
            children: [
              Icon(Icons.directions_car_rounded,
                  color: AppColors.textGhost, size: responsive.text(32)),
              SizedBox(height: responsive.h(8)),
              Text('Aucun véhicule enregistré',
                  style: AppTextStyles.profileSectionLabel(responsive)),
              SizedBox(height: responsive.h(4)),
              Text(
                'Ajoutez un véhicule dans votre profil pour publier un trajet.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(responsive),
              ),
            ],
          ),
        );
      }

      return Column(
        children: controller.availableVehicles.map((VehicleData vehicle) {
          final isSelected =
              controller.selectedVehicle.value?.uuid == vehicle.uuid;
          return Padding(
            padding: EdgeInsets.only(bottom: responsive.h(10)),
            child: GestureDetector(
              onTap: () => controller.selectVehicle(vehicle),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(responsive.w(14)),
                decoration: ShapeDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0x0C00A86B), Color(0x0500A86B)],
                        )
                      : null,
                  color: isSelected ? null : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radius(16)),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: responsive.w(44),
                      height: responsive.w(44),
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? AppColors.surfaceAccentStrong
                            : AppColors.surfaceSoft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(
                        vehicle.vehicleType == 'motorcycle'
                            ? Icons.two_wheeler_rounded
                            : Icons.directions_car_rounded,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                        size: responsive.text(20),
                      ),
                    ),
                    SizedBox(width: responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${vehicle.brand} ${vehicle.model}',
                            style: AppTextStyles.profileSectionLabel(responsive)
                                .copyWith(
                              color: isSelected
                                  ? AppColors.textPrimary
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: responsive.h(2)),
                          Text(
                            '${vehicle.licensePlate} • ${vehicle.availableSeats} places',
                            style: AppTextStyles.caption(responsive),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: responsive.text(22)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
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

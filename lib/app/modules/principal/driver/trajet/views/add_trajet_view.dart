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

  Future<bool> _confirmDiscard(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Abandonner le trajet ?'),
        content: const Text('Les informations saisies seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Continuer'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) { return; }
        if (controller.isEditMode || !controller.formTouched) {
          Get.back();
          return;
        }
        final discard = await _confirmDiscard(context);
        if (discard) Get.offAllNamed(AppRoutes.dashboardDriver, arguments: 1);
      },
      child: Scaffold(
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
                Obx(() {
                  if (controller.recentRoutes.isEmpty) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RecentRoutesSection(
                        responsive: responsive,
                        routes: controller.recentRoutes.toList(),
                        onTap: controller.applyRecentRoute,
                      ),
                      SizedBox(height: responsive.h(16)),
                    ],
                  );
                }),
                _HeroSection(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),
                _ExpressModeToggle(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(16)),
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
                _StopsSection(responsive: responsive, controller: controller),
                SizedBox(height: responsive.h(12)),
                _EstimateBanner(responsive: responsive, controller: controller),
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
                    borderColor: Colors.transparent,
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
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: 'Mode de réservation',
                  subtitle: 'Comment accepter les passagers ?',
                  icon: Icons.how_to_reg_rounded,
                  child: _BookingModeSelector(
                    responsive: responsive,
                    controller: controller,
                  ),
                ),
                SizedBox(height: responsive.h(20)),
                _SectionCard(
                  responsive: responsive,
                  title: "Politique d'annulation",
                  subtitle: 'Conditions de remboursement',
                  icon: Icons.policy_rounded,
                  child: _CancellationPolicySelector(
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
    ));
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
            onTap: () => Navigator.maybePop(context),
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
                .showSnackBar(AppStrings.appName, 'Sauvegarde de brouillon bientôt disponible.', 1),
            size: responsive.w(40),
          ),
        ],
      ),
    );
  }
}

// ── Hero section ───────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

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
          side: const BorderSide(color: Colors.transparent),
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
                side: const BorderSide(color: Colors.transparent),
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
          Obx(() {
            final net = (controller.pricePerSeat.value *
                    controller.availableSeats.value *
                    controller.driverSharePercent /
                    100)
                .toInt();
            final formatted =
                net.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]} ');
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(responsive.w(12)),
              decoration: ShapeDecoration(
                color: AppColors.white.withValues(alpha: 0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(16)),
                  side: const BorderSide(color: Colors.transparent),
                ),
              ),
              child: _HeroStat(
                label: 'Revenus nets estimés',
                value: '$formatted FCFA',
                responsive: responsive,
              ),
            );
          }),
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
      final selectedArr = isDeparture
          ? controller.selectedDepartureArrondissement.value
          : controller.selectedDestinationArrondissement.value;
      final selectedDistrict = isDeparture
          ? controller.selectedDepartureDistrict.value
          : controller.selectedDestinationDistrict.value;

      final arrItems = controller.getArrondissements(selectedCity);
      final List<String> districts = controller.getQuartiers(selectedCity, selectedArr);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isDeparture) ...[
            _GpsLocationButton(responsive: responsive, controller: controller),
            SizedBox(height: responsive.h(12)),
          ],
          _LocationAutocompleteField(
            key: ValueKey(isDeparture ? 'dep-city' : 'dest-city'),
            responsive: responsive,
            label: 'Commune',
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
            key: ValueKey(isDeparture ? 'dep-arr' : 'dest-arr'),
            responsive: responsive,
            label: 'Arrondissement',
            controller: isDeparture
                ? controller.departureArrondissementController
                : controller.destinationArrondissementController,
            items: arrItems,
            isSelected: selectedArr != null,
            hint: selectedCity == null
                ? "Choisir d'abord une commune"
                : 'Ex: 1er Arrondissement',
            enabled: selectedCity != null,
            onSelected: (v) => isDeparture
                ? controller.onDepartureArrondissementChanged(v)
                : controller.onDestinationArrondissementChanged(v),
            onTextChanged: isDeparture
                ? controller.onDepartureArrondissementTyped
                : controller.onDestinationArrondissementTyped,
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
            hint: selectedArr == null
                ? "Choisir d'abord un arrondissement"
                : selectedCity == null
                    ? "Choisir d'abord une commune"
                    : 'Ex: Akpakpa',
            enabled: selectedArr != null,
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
            borderColor: Colors.transparent,
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

// ── GPS location button ────────────────────────────────────────────────────────

class _GpsLocationButton extends StatelessWidget {
  const _GpsLocationButton({
    required this.responsive,
    required this.controller,
  });

  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoadingGpsLocation.value;
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: loading ? null : controller.fillDepartureFromGps,
          icon: loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              : const Icon(Icons.my_location_rounded, size: 18),
          label: Text(
            loading ? 'Localisation en cours…' : 'Utiliser ma position',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
            padding: EdgeInsets.symmetric(vertical: responsive.h(10)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
            ),
            textStyle: AppTextStyles.bodySmall(responsive)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
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
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) setState(() => _showList = false);
      });
    }
  }

  void _onControllerChanged() {
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
                    ? AppColors.danger
                    : widget.isSelected
                        ? AppColors.primary
                        : widget.enabled
                            ? Colors.transparent
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
                    color: AppColors.danger,
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
                .copyWith(color: AppColors.danger),
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
                  side: const BorderSide(color: Colors.transparent),
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
                  side: const BorderSide(color: Colors.transparent),
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
            borderColor: Colors.transparent,
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
            borderColor: Colors.transparent,
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
                          colors: [AppColors.primaryLight, AppColors.primaryLight],
                        )
                      : null,
                  color: isSelected ? null : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(responsive.radius(16)),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
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
                            '${vehicle.licensePlate} • ${vehicle.availableSeats} places (${vehicle.availableSeats - 1} passagers)',
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
                    'passager${current > 1 ? 's' : ''}',
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
                      atMax ? AppColors.danger : AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.w(8)),
              Text(
                '$max max',
                style: AppTextStyles.caption(responsive).copyWith(
                  color: atMax ? AppColors.danger : AppColors.textGhost,
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
                    size: 14, color: AppColors.danger),
                SizedBox(width: responsive.w(6)),
                Expanded(
                  child: Text(
                    'Maximum atteint — ${controller.capacityLabel}',
                    style: AppTextStyles.caption(responsive)
                        .copyWith(color: AppColors.danger),
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
        Obx(() {
          final suggested = controller.suggestedPrice.value;
          if (suggested == null) return const SizedBox.shrink();
          final min = controller.minPrice.value ?? suggested;
          final max = controller.maxPrice.value ?? suggested;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prix suggéré (180 FCFA/km)',
                style: AppTextStyles.caption(responsive)
                    .copyWith(color: AppColors.textMuted),
              ),
              SizedBox(height: responsive.h(8)),
              Wrap(
                spacing: responsive.w(8),
                runSpacing: responsive.h(6),
                children: [
                  _PriceChip(
                    label: '${_formatAmount(min)} min',
                    color: AppColors.success,
                    responsive: responsive,
                    onTap: () => controller.updatePrice(min.toDouble()),
                  ),
                  _PriceChip(
                    label: '${_formatAmount(suggested)} suggéré',
                    color: AppColors.primary,
                    responsive: responsive,
                    onTap: () => controller.updatePrice(suggested.toDouble()),
                  ),
                  _PriceChip(
                    label: '${_formatAmount(max)} max',
                    color: AppColors.warning,
                    responsive: responsive,
                    onTap: () => controller.updatePrice(max.toDouble()),
                  ),
                ],
              ),
              SizedBox(height: responsive.h(12)),
            ],
          );
        }),
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
                  onChanged: controller.onPriceTextChanged,
                  style: AppTextStyles.rolesCardTitle(responsive).copyWith(
                    fontSize: responsive.text(22),
                    color: AppColors.textPrimary,
                  ),
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
        Obx(() {
          final seats = controller.availableSeats.value;
          final price = controller.pricePerSeat.value.toInt();
          if (price <= 0) return const SizedBox.shrink();
          final total = seats * price;
          final net = (total * controller.driverSharePercent / 100).round();
          final fee = total - net;
          final fmtPrice = _formatAmount(price);
          final fmtTotal = _formatAmount(total);
          final fmtNet = _formatAmount(net);
          final fmtFee = _formatAmount(fee);
          return Column(
            children: [
              SizedBox(height: responsive.h(12)),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(responsive.w(16)),
                decoration: ShapeDecoration(
                  color: AppColors.surfaceAccentStrong,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
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
                    Divider(
                      height: responsive.h(16),
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded,
                                size: responsive.text(14),
                                color: AppColors.success),
                            SizedBox(width: responsive.w(6)),
                            Text(
                              'Vous recevez (${controller.driverSharePercent}%)',
                              style: AppTextStyles.caption(responsive)
                                  .copyWith(color: AppColors.success),
                            ),
                          ],
                        ),
                        Text(
                          '$fmtNet FCFA',
                          style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.h(4)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Commission plateforme (${controller.commissionRatePercent}%)',
                          style: AppTextStyles.caption(responsive),
                        ),
                        Text(
                          '$fmtFee FCFA',
                          style: AppTextStyles.caption(responsive),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
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
                color: selected ? AppColors.primaryLight : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(16)),
                  side: BorderSide(
                    color: selected ? AppColors.primary : Colors.transparent,
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

// ── Booking mode selector ─────────────────────────────────────────────────────

class _BookingModeSelector extends StatelessWidget {
  const _BookingModeSelector({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedBookingMode.value;
      return Column(
        children: controller.bookingModes.map((mode) {
          final isSelected = selected == mode.mode;
          final icon = mode.mode == 'instant'
              ? Icons.bolt_rounded
              : Icons.how_to_reg_rounded;
          return Padding(
            padding: EdgeInsets.only(bottom: responsive.h(10)),
            child: GestureDetector(
              onTap: () => controller.selectedBookingMode.value = mode.mode,
              child: Container(
                padding: EdgeInsets.all(responsive.w(14)),
                decoration: ShapeDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: isSelected ? 2 : 1,
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
                      child: Icon(icon,
                          color: AppColors.primary, size: responsive.text(18)),
                    ),
                    SizedBox(width: responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mode.title,
                            style: AppTextStyles.profileSectionLabel(responsive)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(mode.description,
                              style: AppTextStyles.caption(responsive)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: responsive.text(22))
                    else
                      Icon(Icons.radio_button_unchecked_rounded,
                          color: AppColors.border, size: responsive.text(22)),
                  ],
                ),
              ),
            ),
          );
        }).toList(growable: false),
      );
    });
  }
}

// ── Estimate banner ───────────────────────────────────────────────────────────

class _EstimateBanner extends StatelessWidget {
  const _EstimateBanner({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingEstimate.value) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16),
            vertical: responsive.h(12),
          ),
          decoration: ShapeDecoration(
            color: AppColors.surfaceAccentStrong,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: responsive.w(16),
                height: responsive.w(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: responsive.w(10)),
              Text(
                'Calcul de la distance en cours…',
                style: AppTextStyles.caption(responsive),
              ),
            ],
          ),
        );
      }

      final km = controller.estimatedDistanceKm.value;
      final label = controller.estimatedDurationLabel.value;
      if (km == null || label == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(responsive.w(16)),
        decoration: ShapeDecoration(
          color: AppColors.surfaceAccentStrong,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius(16)),
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.25)),
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
                    color: AppColors.primary.withValues(alpha: 0.10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Icon(Icons.straighten_rounded,
                      color: AppColors.primary, size: responsive.text(18)),
                ),
                SizedBox(width: responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance estimée',
                          style: AppTextStyles.caption(responsive)),
                      SizedBox(height: responsive.h(2)),
                      Text(
                        '$km km  •  $label',
                        style: AppTextStyles.profileSectionLabel(responsive)
                            .copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.gps_fixed_rounded,
                    color: AppColors.primary.withValues(alpha: 0.4),
                    size: responsive.text(16)),
              ],
            ),
            Divider(
              height: responsive.h(16),
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: responsive.text(14), color: AppColors.textMuted),
                SizedBox(width: responsive.w(6)),
                Text('Durée estimée',
                    style: AppTextStyles.caption(responsive)),
                SizedBox(width: responsive.w(8)),
                Expanded(
                  child: Container(
                    height: responsive.h(36),
                    padding: EdgeInsets.symmetric(horizontal: responsive.w(10)),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(responsive.radius(10)),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.durationController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            style: AppTextStyles.profileSectionLabel(responsive)
                                .copyWith(
                              color: AppColors.primary,
                              fontSize: responsive.text(14),
                            ),
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
                              hintText: '—',
                              hintStyle: AppTextStyles.muted(responsive),
                            ),
                          ),
                        ),
                        Text('min',
                            style: AppTextStyles.caption(responsive)
                                .copyWith(color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: responsive.w(6)),
                Icon(Icons.edit_outlined,
                    size: responsive.text(13),
                    color: AppColors.textGhost),
              ],
            ),
          ],
        ),
      );
    });
  }
}

// ── Express mode toggle ────────────────────────────────────────────────────────

class _ExpressModeToggle extends StatelessWidget {
  const _ExpressModeToggle({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpress = controller.isExpressMode.value;
      return GestureDetector(
        onTap: controller.toggleExpressMode,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16),
            vertical: responsive.h(14),
          ),
          decoration: ShapeDecoration(
            color: isExpress
                ? AppColors.warning.withValues(alpha: 0.08)
                : AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(20)),
              side: BorderSide(
                color: isExpress
                    ? AppColors.warning
                    : const Color(0xFFE5E7EB),
                width: isExpress ? 2 : 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: responsive.w(44),
                height: responsive.w(44),
                decoration: BoxDecoration(
                  color: isExpress
                      ? AppColors.warning.withValues(alpha: 0.15)
                      : AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: isExpress ? AppColors.warning : AppColors.textGhost,
                  size: responsive.text(22),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode express — départ dans ~2h',
                      style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                        fontWeight: FontWeight.w700,
                        color: isExpress
                            ? AppColors.warning
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: responsive.h(2)),
                    Text(
                      isExpress
                          ? 'Date et heure pré-remplies · réservation instantanée'
                          : 'Pré-remplit la date et heure automatiquement',
                      style: AppTextStyles.caption(responsive),
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsive.w(8)),
              Switch.adaptive(
                value: isExpress,
                // ignore: deprecated_member_use
                activeColor: AppColors.warning,
                onChanged: (_) => controller.toggleExpressMode(),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Price chip ─────────────────────────────────────────────────────────────────

class _PriceChip extends StatelessWidget {
  const _PriceChip({
    required this.label,
    required this.color,
    required this.responsive,
    required this.onTap,
  });
  final String label;
  final Color color;
  final AppResponsive responsive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(12),
          vertical: responsive.h(6),
        ),
        decoration: ShapeDecoration(
          color: color.withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9999),
            side: BorderSide(color: color.withValues(alpha: 0.4)),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption(responsive).copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ── Stops section ─────────────────────────────────────────────────────────────

class _StopsSection extends StatelessWidget {
  const _StopsSection({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stops = controller.intermediateStops;
      return Container(
        width: double.infinity,
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
                offset: Offset(0, 1)),
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
                  decoration: const ShapeDecoration(
                    color: AppColors.surfaceAccentStrong,
                    shape: OvalBorder(),
                  ),
                  child: Icon(Icons.add_location_alt_rounded,
                      color: AppColors.primary, size: responsive.text(20)),
                ),
                SizedBox(width: responsive.w(12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Étapes intermédiaires',
                          style: AppTextStyles.h6(responsive)),
                      Text('Villes d\'arrêt optionnelles',
                          style: AppTextStyles.caption(responsive)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: controller.addStop,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(12),
                      vertical: responsive.h(6),
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.surfaceAccentStrong,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded,
                            color: AppColors.primary,
                            size: responsive.text(16)),
                        SizedBox(width: responsive.w(4)),
                        Text(
                          'Ajouter',
                          style: AppTextStyles.caption(responsive)
                              .copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (stops.isEmpty) ...[
              SizedBox(height: responsive.h(12)),
              Center(
                child: Text(
                  'Aucune étape · trajet direct',
                  style: AppTextStyles.caption(responsive)
                      .copyWith(color: AppColors.textGhost),
                ),
              ),
            ] else ...[
              SizedBox(height: responsive.h(12)),
              ...stops.asMap().entries.map((e) {
                final idx = e.key;
                final stop = e.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: responsive.h(8)),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(12),
                            vertical: responsive.h(10),
                          ),
                          decoration: ShapeDecoration(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(responsive.radius(12)),
                            ),
                          ),
                          child: TextField(
                            onChanged: (v) =>
                                controller.updateStopCity(idx, v),
                            controller: TextEditingController(text: stop.city)
                              ..selection = TextSelection.fromPosition(
                                  TextPosition(offset: stop.city.length)),
                            style: AppTextStyles.profileFieldValue(responsive),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Ville étape',
                              hintStyle: AppTextStyles.muted(responsive),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.w(8)),
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: responsive.w(12),
                            vertical: responsive.h(10),
                          ),
                          decoration: ShapeDecoration(
                            color: AppColors.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(responsive.radius(12)),
                            ),
                          ),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            onChanged: (v) => controller.updateStopPrice(
                                idx, int.tryParse(v)),
                            controller: TextEditingController(
                                text: stop.price?.toString() ?? ''),
                            style: AppTextStyles.profileFieldValue(responsive),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Prix',
                              hintStyle: AppTextStyles.muted(responsive),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: responsive.w(8)),
                      GestureDetector(
                        onTap: () => controller.removeStop(idx),
                        child: Container(
                          width: responsive.w(36),
                          height: responsive.w(36),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Icon(Icons.close_rounded,
                              color: AppColors.danger,
                              size: responsive.text(16)),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      );
    });
  }
}

// ── Cancellation policy selector ──────────────────────────────────────────────

class _CancellationPolicySelector extends StatelessWidget {
  const _CancellationPolicySelector({required this.responsive, required this.controller});
  final AppResponsive responsive;
  final AddTrajetController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedCancellationPolicy.value;
      return Column(
        children: controller.cancellationPolicies.map((policy) {
          final isSelected = selected == policy.policy;
          final color = switch (policy.policy) {
            'flexible' => AppColors.success,
            'moderate' => AppColors.warning,
            _ => AppColors.danger,
          };
          return Padding(
            padding: EdgeInsets.only(bottom: responsive.h(10)),
            child: GestureDetector(
              onTap: () =>
                  controller.selectedCancellationPolicy.value = policy.policy,
              child: Container(
                padding: EdgeInsets.all(responsive.w(14)),
                decoration: ShapeDecoration(
                  color: isSelected ? color.withValues(alpha: 0.06) : AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                    side: BorderSide(
                      color: isSelected ? color : Colors.transparent,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: responsive.w(10),
                      height: responsive.w(10),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: responsive.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            policy.title,
                            style: AppTextStyles.profileSectionLabel(responsive)
                                .copyWith(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? color : AppColors.textPrimary,
                            ),
                          ),
                          Text(policy.description,
                              style: AppTextStyles.caption(responsive)),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle_rounded,
                          color: color, size: responsive.text(22))
                    else
                      Icon(Icons.radio_button_unchecked_rounded,
                          color: AppColors.border, size: responsive.text(22)),
                  ],
                ),
              ),
            ),
          );
        }).toList(growable: false),
      );
    });
  }
}

// ── Trajets récents ───────────────────────────────────────────────────────────

class _RecentRoutesSection extends StatelessWidget {
  const _RecentRoutesSection({
    required this.responsive,
    required this.routes,
    required this.onTap,
  });

  final AppResponsive responsive;
  final List<RecentRoute> routes;
  final ValueChanged<RecentRoute> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trajets récents',
          style: AppTextStyles.profileSectionTitle(responsive).copyWith(
            fontSize: responsive.text(13),
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: responsive.h(8)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: routes.map((route) {
              return Padding(
                padding: EdgeInsets.only(right: responsive.w(10)),
                child: GestureDetector(
                  onTap: () => onTap(route),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(14),
                      vertical: responsive.h(10),
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(responsive.radius(14)),
                        side: const BorderSide(color: AppColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history_rounded,
                          size: responsive.text(14),
                          color: AppColors.primary,
                        ),
                        SizedBox(width: responsive.w(6)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              route.label,
                              style: AppTextStyles.caption(responsive).copyWith(
                                fontSize: responsive.text(13),
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (route.pricePerSeat > 0)
                              Text(
                                route.priceLabel,
                                style: AppTextStyles.caption(responsive).copyWith(
                                  fontSize: responsive.text(11),
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

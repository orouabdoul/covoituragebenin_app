import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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

// ─── Top bar ─────────────────────────────────────────────────────────────────

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
          Obx(() => controller.isEditMode.value
              ? AppCircularButton(
                  responsive: responsive,
                  icon: Icons.delete_outline_rounded,
                  onTap: controller.onDeleteVehicle,
                  size: responsive.w(40),
                )
              : SizedBox(width: responsive.w(40))),
        ],
      ),
    );
  }
}

// ─── Hero section ─────────────────────────────────────────────────────────────

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
                style: AppTextStyles.caption(responsive).copyWith(color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Vehicle info form ────────────────────────────────────────────────────────

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
          SizedBox(height: responsive.h(20)),

          // ── Type de véhicule ─────────────────────────────────────────────
          Obx(() => _FieldLabel(
                responsive: responsive,
                label: AppStrings.driverVehicleTypeTitle,
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeChipField(
                        responsive: responsive,
                        label: 'Voiture',
                        icon: Icons.directions_car_rounded,
                        isSelected: controller.selectedVehicleType.value == VehicleType.car,
                        onTap: () => controller.selectVehicleType(VehicleType.car),
                      ),
                    ),
                    SizedBox(width: responsive.w(10)),
                    Expanded(
                      child: _TypeChipField(
                        responsive: responsive,
                        label: 'Moto',
                        icon: Icons.two_wheeler_rounded,
                        isSelected: controller.selectedVehicleType.value == VehicleType.motorcycle,
                        onTap: () => controller.selectVehicleType(VehicleType.motorcycle),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: responsive.h(16)),

          // ── Marque ───────────────────────────────────────────────────────
          Obx(() => _SelectField(
                responsive: responsive,
                label: AppStrings.driverVehicleBrand,
                hint: 'Sélectionner la marque',
                value: controller.selectedBrand.value,
                icon: Icons.directions_car_outlined,
                onTap: () => _showPickerSheet(
                  context: context,
                  responsive: responsive,
                  title: AppStrings.driverVehicleBrand,
                  items: controller.brandsForType,
                  selected: controller.selectedBrand.value,
                  onSelect: controller.selectBrand,
                ),
              )),
          SizedBox(height: responsive.h(16)),

          // ── Modèle ───────────────────────────────────────────────────────
          Obx(() {
            final hasBrand = controller.selectedBrand.value != null;
            return _SelectField(
              responsive: responsive,
              label: AppStrings.driverVehicleModel,
              hint: hasBrand ? 'Sélectionner le modèle' : 'Choisir la marque d\'abord',
              value: controller.selectedModel.value,
              icon: Icons.drive_eta_outlined,
              disabled: !hasBrand,
              onTap: hasBrand
                  ? () => _showPickerSheet(
                        context: context,
                        responsive: responsive,
                        title: AppStrings.driverVehicleModel,
                        items: controller.modelsForBrand,
                        selected: controller.selectedModel.value,
                        onSelect: controller.selectModel,
                      )
                  : null,
            );
          }),
          SizedBox(height: responsive.h(16)),

          // ── Couleur + Année ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(() => _ColorSelector(
                      responsive: responsive,
                      selected: controller.selectedColor.value,
                      onSelect: controller.selectColor,
                    )),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: _FormField(
                  responsive: responsive,
                  label: AppStrings.driverVehicleYear,
                  hint: '2020',
                  controller: controller.yearController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),

          // ── Plaque ───────────────────────────────────────────────────────
          _FormField(
            responsive: responsive,
            label: AppStrings.driverVehiclePlate,
            hint: 'Ex: BJ-1234-CD',
            controller: controller.licensePlateController,
          ),
          SizedBox(height: responsive.h(16)),

          // ── Places ───────────────────────────────────────────────────────
          Obx(() => _SeatsSelector(
                responsive: responsive,
                count: controller.seatsCount.value,
                isMoto: controller.selectedVehicleType.value == VehicleType.motorcycle,
                onIncrement: controller.incrementSeats,
                onDecrement: controller.decrementSeats,
              )),
        ],
      ),
    );
  }

  // ── Picker bottom sheet ──────────────────────────────────────────────────────
  static void _showPickerSheet({
    required BuildContext context,
    required AppResponsive responsive,
    required String title,
    required List<String> items,
    required String? selected,
    required void Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PickerSheet(
        responsive: responsive,
        title: title,
        items: items,
        selected: selected,
        onSelect: (value) {
          onSelect(value);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// ─── Field label wrapper ─────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.responsive,
    required this.label,
    required this.child,
  });

  final AppResponsive responsive;
  final String label;
  final Widget child;

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
        child,
      ],
    );
  }
}

// ─── Compact type chip (same height as form fields) ──────────────────────────

class _TypeChipField extends StatelessWidget {
  const _TypeChipField({
    required this.responsive,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final AppResponsive responsive;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: responsive.adaptive(phone: 40, smallPhone: 38, tablet: 40, desktop: 40),
        padding: EdgeInsets.symmetric(horizontal: responsive.w(12)),
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF9FAFB),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius(16)),
            side: BorderSide(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: responsive.text(16),
              color: isSelected ? AppColors.white : AppColors.textMuted,
            ),
            SizedBox(width: responsive.w(6)),
            Text(
              label,
              style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Select field (tappable, opens bottom sheet) ──────────────────────────────

class _SelectField extends StatelessWidget {
  const _SelectField({
    required this.responsive,
    required this.label,
    required this.hint,
    required this.value,
    required this.icon,
    required this.onTap,
    this.disabled = false,
  });

  final AppResponsive responsive;
  final String label;
  final String hint;
  final String? value;
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
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
        GestureDetector(
          onTap: disabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: responsive.adaptive(phone: 40, smallPhone: 38, tablet: 40, desktop: 40),
            padding: EdgeInsets.symmetric(horizontal: responsive.w(16)),
            decoration: ShapeDecoration(
              color: disabled ? AppColors.surfaceMuted : const Color(0xFFF9FAFB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
                side: BorderSide(
                  color: hasValue && !disabled ? AppColors.primary : AppColors.border,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasValue ? Icons.check_circle_rounded : icon,
                  size: responsive.text(16),
                  color: hasValue && !disabled ? AppColors.primary : AppColors.textMuted,
                ),
                SizedBox(width: responsive.w(8)),
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption(responsive).copyWith(
                      color: hasValue && !disabled
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: responsive.text(18),
                  color: disabled ? AppColors.textMuted : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Picker bottom sheet ─────────────────────────────────────────────────────

class _PickerSheet extends StatefulWidget {
  const _PickerSheet({
    required this.responsive,
    required this.title,
    required this.items,
    required this.selected,
    required this.onSelect,
  });

  final AppResponsive responsive;
  final String title;
  final List<String> items;
  final String? selected;
  final void Function(String) onSelect;

  @override
  State<_PickerSheet> createState() => _PickerSheetState();
}

class _PickerSheetState extends State<_PickerSheet> {
  late List<String> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchCtrl.addListener(_onSearch);
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = widget.items
          .where((e) => e.toLowerCase().contains(q))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.72,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(24))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Padding(
            padding: EdgeInsets.only(top: r.h(12)),
            child: Container(
              width: r.w(40),
              height: r.h(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          // Title
          Padding(
            padding: EdgeInsets.fromLTRB(r.w(24), r.h(16), r.w(24), r.h(4)),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTextStyles.profileSectionTitle(r),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: r.w(32),
                    height: r.w(32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded, size: r.text(16), color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          // Search
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.w(24), vertical: r.h(8)),
            child: Container(
              height: r.adaptive(phone: 40, smallPhone: 38, tablet: 40, desktop: 40),
              padding: EdgeInsets.symmetric(horizontal: r.w(14)),
              decoration: ShapeDecoration(
                color: AppColors.surfaceMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.radius(12)),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: r.text(18), color: AppColors.textMuted),
                  SizedBox(width: r.w(8)),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: AppTextStyles.caption(r)
                            .copyWith(color: AppColors.textMuted),
                      ),
                      style: AppTextStyles.caption(r)
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divider
          Divider(height: 1, color: AppColors.border),
          // List
          Flexible(
            child: _filtered.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(r.w(32)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: r.text(40), color: AppColors.textMuted),
                        SizedBox(height: r.h(12)),
                        Text('Aucun résultat',
                            style: AppTextStyles.caption(r)
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(
                        horizontal: r.w(16), vertical: r.h(8)),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 1, color: AppColors.surfaceSoft),
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final isSelected = widget.selected == item;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onSelect(item),
                          borderRadius:
                              BorderRadius.circular(r.radius(10)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: r.w(12), vertical: r.h(14)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: AppTextStyles.profileSectionLabel(r)
                                        .copyWith(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_rounded,
                                      size: r.text(18),
                                      color: AppColors.primary),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + r.h(8)),
        ],
      ),
    );
  }
}

// ─── Color selector ───────────────────────────────────────────────────────────

class _ColorSelector extends StatelessWidget {
  const _ColorSelector({
    required this.responsive,
    required this.selected,
    required this.onSelect,
  });

  final AppResponsive responsive;
  final String? selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.driverVehicleColor,
          style: AppTextStyles.profileSectionLabel(responsive).copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: responsive.h(8)),
        // Selected label
        Container(
          height: responsive.adaptive(phone: 40, smallPhone: 38, tablet: 40, desktop: 40),
          padding: EdgeInsets.symmetric(horizontal: responsive.w(12)),
          decoration: ShapeDecoration(
            color: const Color(0xFFF9FAFB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: BorderSide(
                color: selected != null ? AppColors.primary : AppColors.border,
              ),
            ),
          ),
          child: Row(
            children: [
              if (selected != null) ...[
                Container(
                  width: responsive.w(16),
                  height: responsive.w(16),
                  decoration: BoxDecoration(
                    color: AddVehicleController.colorOptions
                        .firstWhere((o) => o.label == selected,
                            orElse: () => const VehicleColorOption(
                                label: '', color: Colors.transparent))
                        .color,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                ),
                SizedBox(width: responsive.w(8)),
              ],
              Text(
                selected ?? 'Sélectionner...',
                style: AppTextStyles.caption(responsive).copyWith(
                  color: selected != null
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: responsive.h(10)),
        Wrap(
          spacing: responsive.w(8),
          runSpacing: responsive.h(8),
          children: AddVehicleController.colorOptions.map((opt) {
            final isSelected = selected == opt.label;
            return GestureDetector(
              onTap: () => onSelect(opt.label),
              child: Tooltip(
                message: opt.label,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: responsive.w(28),
                  height: responsive.w(28),
                  decoration: BoxDecoration(
                    color: opt.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [const BoxShadow(color: Color(0x3300A86B), blurRadius: 6)]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check_rounded,
                          size: responsive.text(14),
                          color: opt.color == const Color(0xFFFFFFFF)
                              ? AppColors.textPrimary
                              : AppColors.white,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Seats counter ────────────────────────────────────────────────────────────

class _SeatsSelector extends StatelessWidget {
  const _SeatsSelector({
    required this.responsive,
    required this.count,
    required this.isMoto,
    required this.onIncrement,
    required this.onDecrement,
  });

  final AppResponsive responsive;
  final int count;
  final bool isMoto;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final minSeats = isMoto ? 1 : 2;
    final maxSeats = isMoto ? 2 : 9;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              AppStrings.driverVehicleSeats,
              style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: responsive.w(8)),
            Text(
              isMoto ? '(1–2 passagers)' : '(2–9 passagers)',
              style: AppTextStyles.caption(responsive)
                  .copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
        SizedBox(height: responsive.h(8)),
        Container(
          height: responsive.adaptive(phone: 40, smallPhone: 38, tablet: 40, desktop: 40),
          decoration: ShapeDecoration(
            color: const Color(0xFFF9FAFB),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CounterBtn(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
                enabled: count > minSeats,
                responsive: responsive,
                isLeft: true,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: responsive.w(20)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_rounded,
                        size: responsive.text(14), color: AppColors.primary),
                    SizedBox(width: responsive.w(4)),
                    Text(
                      '$count',
                      style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: responsive.text(16),
                      ),
                    ),
                  ],
                ),
              ),
              _CounterBtn(
                icon: Icons.add_rounded,
                onTap: onIncrement,
                enabled: count < maxSeats,
                responsive: responsive,
                isLeft: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterBtn extends StatelessWidget {
  const _CounterBtn({
    required this.icon,
    required this.onTap,
    required this.enabled,
    required this.responsive,
    required this.isLeft,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final AppResponsive responsive;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.only(
          topLeft: isLeft ? Radius.circular(responsive.radius(16)) : Radius.zero,
          bottomLeft: isLeft ? Radius.circular(responsive.radius(16)) : Radius.zero,
          topRight: isLeft ? Radius.zero : Radius.circular(responsive.radius(16)),
          bottomRight: isLeft ? Radius.zero : Radius.circular(responsive.radius(16)),
        ),
        child: Container(
          width: responsive.w(40),
          height: double.infinity,
          decoration: BoxDecoration(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.surfaceMuted,
            borderRadius: BorderRadius.only(
              topLeft: isLeft ? Radius.circular(responsive.radius(16)) : Radius.zero,
              bottomLeft: isLeft ? Radius.circular(responsive.radius(16)) : Radius.zero,
              topRight: isLeft ? Radius.zero : Radius.circular(responsive.radius(16)),
              bottomRight: isLeft ? Radius.zero : Radius.circular(responsive.radius(16)),
            ),
          ),
          child: Icon(
            icon,
            size: responsive.text(18),
            color: enabled ? AppColors.primary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

// ─── Generic form field ───────────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  const _FormField({
    required this.responsive,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
  });

  final AppResponsive responsive;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;

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
            keyboardType: keyboardType,
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

// ─── Remaining sections ───────────────────────────────────────────────────────

class _PhotoUploadSection extends StatelessWidget {
  const _PhotoUploadSection({required this.responsive, required this.controller});

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
          Text(AppStrings.driverVehiclePhotosTitle,
              style: AppTextStyles.profileSectionTitle(responsive)),
          SizedBox(height: responsive.h(8)),
          Text(
            AppStrings.driverVehiclePhotosSubtitle,
            style: AppTextStyles.caption(responsive)
                .copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: responsive.h(20)),
          Obx(() {
            final hasPhoto = controller.hasVehiclePhoto;
            controller.filesVersion.value;
            return GestureDetector(
              onTap: () {
                _showImageSourcePicker(context, responsive).then((src) {
                  if (src != null) controller.pickVehiclePhoto(src);
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: responsive.w(120),
                decoration: ShapeDecoration(
                  color: hasPhoto ? AppColors.successLight : const Color(0xFFF9FAFB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(16)),
                    side: BorderSide(
                      width: 2,
                      color: hasPhoto ? AppColors.success : const Color(0xFFD1D5DB),
                      style: hasPhoto ? BorderStyle.solid : BorderStyle.solid,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      hasPhoto ? Icons.check_circle_rounded : Icons.add_a_photo_rounded,
                      size: responsive.text(28),
                      color: hasPhoto ? AppColors.success : AppColors.textMuted,
                    ),
                    SizedBox(width: responsive.w(12)),
                    Text(
                      hasPhoto ? 'Photo ajoutée ✓' : 'Ajouter une photo du véhicule',
                      style: AppTextStyles.profileSectionLabel(responsive).copyWith(
                        color: hasPhoto ? AppColors.success : AppColors.textMuted,
                        fontWeight: hasPhoto ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _DocumentsSection extends StatelessWidget {
  const _DocumentsSection({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final AddVehicleController controller;

  static const _docIcons = <String, IconData>{
    'registration_doc':      Icons.description_rounded,
    'insurance_doc':         Icons.shield_rounded,
    'tvm_doc':               Icons.receipt_long_rounded,
    'technical_control_doc': Icons.build_circle_outlined,
  };

  static const _docColors = <String, Color>{
    'registration_doc':      Color(0x192563EB),
    'insurance_doc':         Color(0x1900A86B),
    'tvm_doc':               Color(0x19F4B400),
    'technical_control_doc': Color(0x19E53935),
  };

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
          Text(AppStrings.driverVehicleDocumentsTitle,
              style: AppTextStyles.profileSectionTitle(responsive)),
          SizedBox(height: responsive.h(8)),
          Text(
            AppStrings.driverVehicleDocumentsSubtitle,
            style: AppTextStyles.caption(responsive)
                .copyWith(color: AppColors.textMuted),
          ),
          SizedBox(height: responsive.h(24)),
          Obx(() {
            controller.filesVersion.value;
            return Column(
              children: AddVehicleController.docSlots.asMap().entries.map((entry) {
                final i = entry.key;
                final slot = entry.value;
                final hasFile = controller.hasDoc(slot.apiKey);
                return Column(
                  children: [
                    _DocumentRow(
                      responsive: responsive,
                      label: slot.label,
                      isRequired: slot.required,
                      icon: _docIcons[slot.apiKey] ?? Icons.attach_file_rounded,
                      badgeColor: _docColors[slot.apiKey] ?? const Color(0x19000000),
                      hasFile: hasFile,
                      onTap: () {
                        _showDocSourcePicker(context, responsive).then((src) {
                          if (src == null) return;
                          if (src == _DocSource.file) {
                            controller.pickDocFromFiles(slot.apiKey);
                          } else {
                            controller.pickDoc(
                              slot.apiKey,
                              src == _DocSource.camera
                                  ? ImageSource.camera
                                  : ImageSource.gallery,
                            );
                          }
                        });
                      },
                    ),
                    if (i < AddVehicleController.docSlots.length - 1)
                      SizedBox(height: responsive.h(16)),
                  ],
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _DocumentRow extends StatelessWidget {
  const _DocumentRow({
    required this.responsive,
    required this.label,
    required this.isRequired,
    required this.icon,
    required this.badgeColor,
    required this.hasFile,
    required this.onTap,
  });

  final AppResponsive responsive;
  final String label;
  final bool isRequired;
  final IconData icon;
  final Color badgeColor;
  final bool hasFile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(responsive.w(16)),
      decoration: ShapeDecoration(
        color: hasFile ? AppColors.successLight : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(16)),
          side: BorderSide(
            color: hasFile ? AppColors.success : AppColors.border,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: responsive.w(48),
            height: responsive.w(48),
            decoration: ShapeDecoration(
              color: hasFile ? AppColors.success.withValues(alpha: 0.15) : badgeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
            ),
            child: Icon(
              hasFile ? Icons.check_rounded : icon,
              color: hasFile ? AppColors.success : AppColors.textSecondary,
              size: responsive.text(20),
            ),
          ),
          SizedBox(width: responsive.w(16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.profileSectionLabel(responsive)
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    if (isRequired) ...[
                      SizedBox(width: responsive.w(4)),
                      Text(
                        '*',
                        style: AppTextStyles.caption(responsive)
                            .copyWith(color: const Color(0xFFE53935)),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: responsive.h(4)),
                Text(
                  hasFile
                      ? 'Fichier ajouté ✓'
                      : (isRequired ? 'Document obligatoire' : 'Document optionnel'),
                  style: AppTextStyles.caption(responsive).copyWith(
                    color: hasFile ? AppColors.success : AppColors.textMuted,
                  ),
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
                  color: hasFile ? AppColors.success : AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                ),
                child: Text(
                  hasFile ? 'Modifier' : 'Ajouter',
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
                child: Icon(Icons.shield_rounded,
                    color: AppColors.white, size: responsive.text(24)),
              ),
              SizedBox(width: responsive.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.driverVehicleSecurityTitle,
                        style: AppTextStyles.profileSectionTitle(responsive)),
                    SizedBox(height: responsive.h(4)),
                    Text('Votre profil est protégé',
                        style: AppTextStyles.caption(responsive)),
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
              _SecurityBadge(responsive: responsive, label: 'Téléphone vérifié', icon: Icons.phone_rounded),
              _SecurityBadge(responsive: responsive, label: 'Identité validée', icon: Icons.verified_user_rounded),
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
        Text(label,
            style: AppTextStyles.caption(responsive)
                .copyWith(color: AppColors.textSecondary)),
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
    return Obx(() => AppPrimaryButton(
          responsive: responsive,
          label: controller.isSubmitting.value
              ? (controller.isEditMode.value ? 'Mise à jour...' : 'Enregistrement...')
              : (controller.isEditMode.value ? 'Mettre à jour' : AppStrings.driverVehicleRegisterButton),
          onTap: controller.isSubmitting.value ? () {} : controller.onRegisterVehicle,
          height: responsive.adaptive(phone: 56, smallPhone: 52, tablet: 56, desktop: 56),
          borderRadius: responsive.radius(16),
        ));
  }
}

// ─── Document source picker (camera / gallery / file) ────────────────────────

enum _DocSource { camera, gallery, file }

Future<_DocSource?> _showDocSourcePicker(
    BuildContext context, AppResponsive responsive) {
  return showModalBottomSheet<_DocSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _DocSourceSheet(responsive: responsive),
  );
}

class _DocSourceSheet extends StatelessWidget {
  const _DocSourceSheet({required this.responsive});
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          responsive.w(16), responsive.h(12), responsive.w(16), responsive.h(32)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(responsive.radius(24))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: responsive.w(40),
            height: responsive.h(4),
            margin: EdgeInsets.only(bottom: responsive.h(20)),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          Text('Ajouter un document',
              style: AppTextStyles.profileSectionTitle(responsive)),
          SizedBox(height: responsive.h(16)),
          _ImageSourceTile(
            responsive: responsive,
            icon: Icons.camera_alt_rounded,
            label: 'Prendre une photo',
            subtitle: 'Utiliser l\'appareil photo',
            onTap: () => Navigator.of(context).pop(_DocSource.camera),
          ),
          SizedBox(height: responsive.h(12)),
          _ImageSourceTile(
            responsive: responsive,
            icon: Icons.photo_library_rounded,
            label: 'Galerie',
            subtitle: 'Choisir depuis les photos',
            onTap: () => Navigator.of(context).pop(_DocSource.gallery),
          ),
          SizedBox(height: responsive.h(12)),
          _ImageSourceTile(
            responsive: responsive,
            icon: Icons.picture_as_pdf_rounded,
            label: 'Fichier (PDF)',
            subtitle: 'Choisir un PDF depuis l\'appareil',
            onTap: () => Navigator.of(context).pop(_DocSource.file),
          ),
        ],
      ),
    );
  }
}

// ─── Image source picker ─────────────────────────────────────────────────────

Future<ImageSource?> _showImageSourcePicker(
    BuildContext context, AppResponsive responsive) {
  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _ImageSourceSheet(responsive: responsive),
  );
}

class _ImageSourceSheet extends StatelessWidget {
  const _ImageSourceSheet({required this.responsive});
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          responsive.w(16), responsive.h(12), responsive.w(16), responsive.h(32)),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(responsive.radius(24))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: responsive.w(40),
            height: responsive.h(4),
            margin: EdgeInsets.only(bottom: responsive.h(20)),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          Text('Choisir une source',
              style: AppTextStyles.profileSectionTitle(responsive)),
          SizedBox(height: responsive.h(16)),
          _ImageSourceTile(
            responsive: responsive,
            icon: Icons.camera_alt_rounded,
            label: 'Prendre une photo',
            subtitle: 'Utiliser l\'appareil photo',
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          SizedBox(height: responsive.h(12)),
          _ImageSourceTile(
            responsive: responsive,
            icon: Icons.photo_library_rounded,
            label: 'Galerie',
            subtitle: 'Choisir depuis les photos',
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  const _ImageSourceTile({
    required this.responsive,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final AppResponsive responsive;
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        child: Container(
          padding: EdgeInsets.all(responsive.w(16)),
          decoration: ShapeDecoration(
            color: AppColors.surfaceMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: responsive.w(44),
                height: responsive.w(44),
                decoration: ShapeDecoration(
                  color: const Color(0xFFE8F5F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                ),
                child: Icon(icon, color: AppColors.primary, size: responsive.text(20)),
              ),
              SizedBox(width: responsive.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: AppTextStyles.profileSectionLabel(responsive)
                            .copyWith(fontWeight: FontWeight.w600)),
                    SizedBox(height: responsive.h(2)),
                    Text(subtitle,
                        style: AppTextStyles.caption(responsive)
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: responsive.text(20)),
            ],
          ),
        ),
      ),
    );
  }
}

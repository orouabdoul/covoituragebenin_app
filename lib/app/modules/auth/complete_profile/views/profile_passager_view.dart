import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/constants/benin_locations.dart';
import 'package:covoiturage_benin_app/app/modules/auth/complete_profile/controllers/profile_passager_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/face_verification_section.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/id_card_preview_tile.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/phone_field_widget.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/selfie_capture_widget.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

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

                        SizedBox(height: responsive.h(20)),
                        _PersonalCard(
                          responsive: responsive,
                          controller: controller,
                        ),
                        SizedBox(height: responsive.h(20)),
                        // Selfie section
                        _SectionContainer(
                          responsive: responsive,
                          title: AppStrings.profileSelfieSection,
                          icon: Icons.face_rounded,
                          subtitle: AppStrings.profileSelfieSectionHint,
                          child: SelfieCaptureWidget(
                            responsive: responsive,
                            onChanged: controller.onSelfiesChanged,
                          ),
                        ),
                        SizedBox(height: responsive.h(20)),
                        // ID card section
                        _SectionContainer(
                          responsive: responsive,
                          title: AppStrings.profileIdCardSection,
                          icon: Icons.credit_card_rounded,
                          child: Column(
                            children: [
                              IdCardPreviewTile(
                                responsive: responsive,
                                title: AppStrings.profileIdCardFront,
                                subtitle: AppStrings.profileIdCardFrontHint,
                                actionLabel: AppStrings.profileUploadPhoto,
                                onTap: () {
                                  _showImageSourcePicker(context, responsive).then((src) {
                                    if (src != null) controller.pickIdCard(isFront: true, source: src);
                                  });
                                },
                                imageFile: controller.idCardFrontFile,
                                faceBox: controller.idCardFaceBox,
                                imageSize: controller.idCardImageSize,
                                isDetecting: controller.isDetectingCardFace,
                                detectionError: controller.idCardDetectionError,
                              ),
                              SizedBox(height: responsive.h(16)),
                              IdCardPreviewTile(
                                responsive: responsive,
                                title: AppStrings.profileIdCardBack,
                                subtitle: AppStrings.profileIdCardBackHint,
                                actionLabel: AppStrings.profileUploadPhoto,
                                optional: true,
                                onTap: () {
                                  _showImageSourcePicker(context, responsive).then((src) {
                                    if (src != null) controller.pickIdCard(isFront: false, source: src);
                                  });
                                },
                                imageFile: controller.idCardBackFile,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.h(20)),

                        // ── Vérification d'identité ────────────────────────
                        FaceVerificationSection(
                          responsive: responsive,
                          hasSelfie: controller.selfieFront.value != null,
                          hasCni: controller.idCardFrontName.value.isNotEmpty,
                          status: controller.verificationStatus.value,
                          message: controller.verificationMessage.value,
                          score: controller.verificationScore.value,
                          onVerify: controller.runVerification,
                        ),
                        SizedBox(height: responsive.h(20)),
                        _BenefitsCard(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _TrustCard(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _EmergencyContactsRegSection(
                          responsive: responsive,
                          contacts: controller.emergencyContacts.toList(),
                          onAdd: controller.addEmergencyContact,
                          onRemove: controller.removeEmergencyContact,
                        ),
                        SizedBox(height: responsive.h(24)),
                        AppPrimaryButton(
                          responsive: responsive,
                          label: controller.isSubmitting.value
                              ? 'Envoi en cours...'
                              : AppStrings.passengerPrimaryAction,
                          enabled: !controller.isSubmitting.value,
                          onTap: controller.createProfile,
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
  static Future<ImageSource?> _showImageSourcePicker(
      BuildContext context, AppResponsive responsive) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageSourceSheet(responsive: responsive),
    );
  }
}

void _showLocationPicker({
  required BuildContext context,
  required AppResponsive responsive,
  required String title,
  required List<String> items,
  required String? selected,
  required void Function(String) onSelect,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _LocationPickerSheet(
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
          side: BorderSide(width: 1, color: Colors.transparent),
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
            onTap: () => Get.offAllNamed(AppRoutes.roles),
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
              const Icon(Icons.timer_outlined, color: AppColors.white, size: 16),
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
          _GenderSelector(
            responsive: responsive,
            selected: controller.selectedGender.value,
            onSelected: controller.selectGender,
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
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              Expanded(
                child: _LocationSelectField(
                  responsive: responsive,
                  label: AppStrings.profileFieldCity,
                  hint: AppStrings.profileFieldCityHint,
                  value: controller.selectedCity.value,
                  onTap: () => _showLocationPicker(
                    context: context,
                    responsive: responsive,
                    title: AppStrings.profileFieldCity,
                    items: BeninLocations.cities,
                    selected: controller.selectedCity.value,
                    onSelect: controller.selectCity,
                  ),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: _LocationSelectField(
                  responsive: responsive,
                  label: AppStrings.profileFieldNeighborhood,
                  hint: controller.selectedCity.value == null
                      ? 'Choisir une ville'
                      : AppStrings.profileFieldNeighborhoodHint,
                  value: controller.selectedNeighborhood.value,
                  disabled: controller.selectedCity.value == null,
                  onTap: controller.selectedCity.value == null
                      ? null
                      : () => _showLocationPicker(
                            context: context,
                            responsive: responsive,
                            title: AppStrings.profileFieldNeighborhood,
                            items: BeninLocations.neighborhoods(
                                controller.selectedCity.value!),
                            selected: controller.selectedNeighborhood.value,
                            onSelect: controller.selectNeighborhood,
                          ),
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          AppField(
            responsive: responsive,
            label: AppStrings.profileFieldAddress,
            labelStyle: AppTextStyles.profileSectionLabel(responsive),
            controller: controller.addressController,
            hintText: AppStrings.profileFieldAddressHint,
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

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({
    required this.responsive,
    required this.selected,
    required this.onSelected,
  });

  final AppResponsive responsive;
  final String? selected;
  final void Function(String) onSelected;

  static const _genders = [
    (label: AppStrings.profileFieldGenderMale, icon: Icons.male_rounded),
    (label: AppStrings.profileFieldGenderFemale, icon: Icons.female_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.profileFieldGender,
          style: AppTextStyles.profileSectionLabel(responsive),
        ),
        SizedBox(height: responsive.h(8)),
        Row(
          children: List.generate(_genders.length, (i) {
            final g = _genders[i];
            final isSelected = selected == g.label;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < _genders.length - 1 ? responsive.w(10) : 0),
                child: GestureDetector(
                  onTap: () => onSelected(g.label),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: responsive.h(44),
                    padding: EdgeInsets.symmetric(horizontal: responsive.w(12)),
                    decoration: ShapeDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surfaceMuted,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(responsive.radius(10)),
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : Colors.transparent,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(g.icon, size: responsive.text(16),
                            color: isSelected ? AppColors.white : AppColors.textMuted),
                        SizedBox(width: responsive.w(6)),
                        Text(
                          g.label,
                          style: AppTextStyles.profileFieldValue(responsive).copyWith(
                            color: isSelected ? AppColors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ── Location select field ─────────────────────────────────────────────────────

class _LocationSelectField extends StatelessWidget {
  const _LocationSelectField({
    required this.responsive,
    required this.label,
    required this.hint,
    required this.value,
    required this.onTap,
    this.disabled = false,
  });

  final AppResponsive responsive;
  final String label;
  final String hint;
  final String? value;
  final VoidCallback? onTap;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.profileSectionLabel(responsive)),
        SizedBox(height: responsive.h(8)),
        GestureDetector(
          onTap: disabled ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: responsive.h(44),
            padding: EdgeInsets.symmetric(horizontal: responsive.w(14)),
            decoration: ShapeDecoration(
              color: disabled ? AppColors.surfaceMuted : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(10)),
                side: BorderSide(
                  color: hasValue && !disabled ? AppColors.primary : Colors.transparent,
                  width: hasValue && !disabled ? 1.5 : 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasValue ? Icons.check_circle_rounded : Icons.location_on_outlined,
                  size: responsive.text(16),
                  color: hasValue && !disabled ? AppColors.primary : AppColors.textGhost,
                ),
                SizedBox(width: responsive.w(8)),
                Expanded(
                  child: Text(
                    hasValue ? value! : hint,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.profileFieldValue(responsive).copyWith(
                      color: hasValue && !disabled ? AppColors.textPrimary : AppColors.textGhost,
                      fontWeight: hasValue ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: responsive.text(20),
                  color: disabled ? AppColors.textGhost : AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Location picker bottom sheet ──────────────────────────────────────────────

class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet({
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
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  late List<String> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _filter(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? widget.items
          : widget.items
              .where((e) => e.toLowerCase().contains(q.toLowerCase()))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(r.radius(24))),
      ),
      child: Column(
        children: [
          SizedBox(height: r.h(12)),
          Container(
            width: r.w(40),
            height: r.h(4),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(r.radius(2)),
            ),
          ),
          SizedBox(height: r.h(16)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.w(16)),
            child: Text(widget.title,
                style: AppTextStyles.profileSectionTitle(r)),
          ),
          SizedBox(height: r.h(12)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: r.w(16)),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _filter,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: Icon(Icons.search_rounded, size: r.text(18),
                    color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(10)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.radius(10)),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.radius(10)),
                  borderSide: const BorderSide(color: Colors.transparent),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(r.radius(10)),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
          SizedBox(height: r.h(8)),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: r.w(8), vertical: r.h(4)),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final item = _filtered[i];
                final isSelected = item == widget.selected;
                return ListTile(
                  dense: true,
                  title: Text(item,
                      style: AppTextStyles.profileFieldValue(r).copyWith(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      )),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: AppColors.primary, size: r.text(18))
                      : null,
                  onTap: () => widget.onSelect(item),
                );
              },
            ),
          ),
          SizedBox(height: r.h(16)),
        ],
      ),
    );
  }
}

class _EmergencyContactsRegSection extends StatefulWidget {
  const _EmergencyContactsRegSection({
    required this.responsive,
    required this.contacts,
    required this.onAdd,
    required this.onRemove,
  });

  final AppResponsive responsive;
  final List<EmergencyContactEntry> contacts;
  final void Function(String, String, String) onAdd;
  final void Function(int) onRemove;

  @override
  State<_EmergencyContactsRegSection> createState() =>
      _EmergencyContactsRegSectionState();
}

class _EmergencyContactsRegSectionState
    extends State<_EmergencyContactsRegSection> {
  bool _showForm = false;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String? _selectedRelation;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final rel = _selectedRelation ?? '';
    if (name.isEmpty || phone.isEmpty || rel.isEmpty) return;
    widget.onAdd(name, phone, rel);
    _nameCtrl.clear();
    _phoneCtrl.clear();
    setState(() {
      _selectedRelation = null;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    return _SectionContainer(
      responsive: r,
      title: 'Contacts d\'urgence',
      icon: Icons.emergency_rounded,
      subtitle: 'Famille ou amis à prévenir (max 5)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.contacts.isEmpty)
            Text(
              'Aucun contact. Recommandé pour votre sécurité.',
              style: AppTextStyles.profileMeta(r),
            ),
          ...widget.contacts.asMap().entries.map((entry) {
            final i = entry.key;
            final c = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: r.h(8)),
              padding: EdgeInsets.symmetric(
                  horizontal: r.w(12), vertical: r.h(10)),
              decoration: ShapeDecoration(
                color: AppColors.surfaceMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.radius(10)),
                  side: const BorderSide(color: Colors.transparent),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: r.w(36),
                    height: r.w(36),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                      style: AppTextStyles.profileSectionLabel(r)
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  SizedBox(width: r.w(10)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.name,
                            style: AppTextStyles.profileSectionLabel(r)),
                        Text('${c.relationship} · ${c.phone}',
                            style: AppTextStyles.profileMeta(r)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onRemove(i),
                    child: Icon(Icons.close_rounded,
                        size: r.text(18), color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }),
          if (_showForm) ...[
            SizedBox(height: r.h(12)),
            AppField(
              responsive: r,
              label: 'Nom complet',
              labelStyle: AppTextStyles.profileSectionLabel(r),
              controller: _nameCtrl,
              hintText: 'Ex: Kouassi Jean',
              textStyle: AppTextStyles.profileFieldValue(r),
              hintStyle: AppTextStyles.profileFieldValue(r)
                  .copyWith(color: AppColors.textGhost),
            ),
            SizedBox(height: r.h(10)),
            _RelationSelectField(
              responsive: r,
              value: _selectedRelation,
              onSelected: (v) => setState(() => _selectedRelation = v),
            ),
            SizedBox(height: r.h(10)),
            PhoneFieldWidget(
              responsive: r,
              controller: _phoneCtrl,
              label: 'Téléphone',
              labelStyle: AppTextStyles.profileSectionLabel(r),
            ),
            SizedBox(height: r.h(12)),
            Row(
              children: [
                Expanded(
                  child: AppPrimaryButton(
                    responsive: r,
                    label: 'Ajouter',
                    onTap: _submit,
                  ),
                ),
                SizedBox(width: r.w(10)),
                AppChipButton(
                  responsive: r,
                  label: 'Annuler',
                  onTap: () => setState(() => _showForm = false),
                ),
              ],
            ),
          ] else if (widget.contacts.length < 5) ...[
            SizedBox(height: r.h(12)),
            AppChipButton(
              responsive: r,
              label: '+ Ajouter un contact',
              onTap: () => setState(() => _showForm = true),
            ),
          ],
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
          child: Icon(icon, size: responsive.text(16), color: AppColors.primary),
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
          BoxShadow(color: AppColors.shadow, blurRadius: 15, offset: Offset(0, 10)),
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 4)),
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
    this.subtitle,
  });

  final AppResponsive responsive;
  final String title;
  final IconData icon;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(24)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          side: const BorderSide(color: Colors.transparent),
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
                    borderRadius:
                        BorderRadius.circular(responsive.radius(12)),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.profileSectionTitle(responsive),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: responsive.h(2)),
                      Text(
                        subtitle!,
                        style: AppTextStyles.profileMeta(responsive),
                      ),
                    ],
                  ],
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

// ── Relation select ───────────────────────────────────────────────────────────

const _kRelations = [
  'Père', 'Mère', 'Frère', 'Sœur',
  'Époux', 'Épouse', 'Fils', 'Fille',
  'Grand-père', 'Grand-mère',
  'Oncle', 'Tante', 'Neveu', 'Nièce',
  'Cousin', 'Cousine',
  'Beau-père', 'Belle-mère', 'Beau-frère', 'Belle-sœur',
  'Ami(e)', 'Collègue', 'Voisin(e)', 'Tuteur/Tutrice', 'Autre',
];

class _RelationSelectField extends StatelessWidget {
  const _RelationSelectField({
    required this.responsive,
    required this.value,
    required this.onSelected,
  });

  final AppResponsive responsive;
  final String? value;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _RelationPickerSheet(
          responsive: r,
          selected: value,
          onSelected: onSelected,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Relation', style: AppTextStyles.profileSectionLabel(r)),
          SizedBox(height: r.h(6)),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
                horizontal: r.w(14), vertical: r.h(14)),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(r.radius(10)),
              border: Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Sélectionner une relation',
                    style: AppTextStyles.profileFieldValue(r).copyWith(
                      color: value != null ? null : AppColors.textGhost,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: r.text(18), color: AppColors.textMuted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationPickerSheet extends StatelessWidget {
  const _RelationPickerSheet({
    required this.responsive,
    required this.selected,
    required this.onSelected,
  });

  final AppResponsive responsive;
  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final r = responsive;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(r.radius(20))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: r.h(12)),
          Container(
            width: r.w(40),
            height: r.h(4),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: r.h(16)),
          Text('Relation avec le contact',
              style: AppTextStyles.profileSectionLabel(r)),
          SizedBox(height: r.h(8)),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: r.h(380)),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _kRelations.length,
              itemBuilder: (_, i) {
                final rel = _kRelations[i];
                final isSelected = rel == selected;
                return ListTile(
                  dense: true,
                  title: Text(rel,
                      style: AppTextStyles.profileFieldValue(r)),
                  trailing: isSelected
                      ? Icon(Icons.check_rounded,
                          color: AppColors.primary, size: r.text(18))
                      : null,
                  onTap: () {
                    onSelected(rel);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          SizedBox(height: r.h(24)),
        ],
      ),
    );
  }
}

// ── Image source picker ───────────────────────────────────────────────────────

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
          Text('Choisir une source', style: AppTextStyles.profileSectionTitle(responsive)),
          SizedBox(height: responsive.h(16)),
          _SourceTile(
            responsive: responsive,
            icon: Icons.camera_alt_rounded,
            label: 'Prendre une photo',
            subtitle: 'Utiliser l\'appareil photo',
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          SizedBox(height: responsive.h(12)),
          _SourceTile(
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

class _SourceTile extends StatelessWidget {
  const _SourceTile({
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
              side: const BorderSide(color: Colors.transparent),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: responsive.w(44),
                height: responsive.w(44),
                decoration: ShapeDecoration(
                  color: AppColors.surfaceAccent,
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
                    Text(label, style: AppTextStyles.profileSectionLabel(responsive)),
                    SizedBox(height: responsive.h(2)),
                    Text(subtitle, style: AppTextStyles.profileMeta(responsive)),
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

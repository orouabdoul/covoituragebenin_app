import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/auth/complete_profile/controllers/profile_passager_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/face_verification_section.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/id_card_preview_tile.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/phone_field_widget.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/selfie_capture_widget.dart';
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
                              _DocumentUploadTile(
                                responsive: responsive,
                                title: AppStrings.profileIdCardBack,
                                subtitle: AppStrings.profileIdCardBackHint,
                                actionLabel: AppStrings.profileUploadPhoto,
                                icon: Icons.photo_camera_outlined,
                                onTap: () {
                                  _showImageSourcePicker(context, responsive).then((src) {
                                    if (src != null) controller.pickIdCard(isFront: false, source: src);
                                  });
                                },
                                selectedValue:
                                    controller.idCardBackName.value,
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
  static Future<ImageSource?> _showImageSourcePicker(
      BuildContext context, AppResponsive responsive) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ImageSourceSheet(responsive: responsive),
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
          PhoneFieldWidget(
            responsive: responsive,
            controller: controller.phoneController,
            label: AppStrings.profileFieldPhone,
            labelStyle: AppTextStyles.profileSectionLabel(responsive),
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              Expanded(
                child: AppField(
                  responsive: responsive,
                  label: AppStrings.profileFieldCity,
                  labelStyle: AppTextStyles.profileSectionLabel(responsive),
                  controller: controller.cityController,
                  hintText: AppStrings.profileFieldCityHint,
                  textStyle: AppTextStyles.profileFieldValue(responsive),
                  hintStyle: AppTextStyles.profileFieldValue(
                    responsive,
                  ).copyWith(color: AppColors.textGhost),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: AppField(
                  responsive: responsive,
                  label: AppStrings.profileFieldNeighborhood,
                  labelStyle: AppTextStyles.profileSectionLabel(responsive),
                  controller: controller.neighborhoodController,
                  hintText: AppStrings.profileFieldNeighborhoodHint,
                  textStyle: AppTextStyles.profileFieldValue(responsive),
                  hintStyle: AppTextStyles.profileFieldValue(
                    responsive,
                  ).copyWith(color: AppColors.textGhost),
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
                          color: isSelected ? AppColors.primary : AppColors.border,
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
              color: selectedValue.isNotEmpty
                  ? AppColors.successLight
                  : AppColors.surfaceAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
            ),
            child: Icon(
              selectedValue.isNotEmpty ? Icons.check_rounded : icon,
              color: selectedValue.isNotEmpty
                  ? AppColors.success
                  : AppColors.primary,
              size: responsive.text(20),
            ),
          ),
          SizedBox(height: responsive.h(12)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.profileSectionTitle(
              responsive,
            ).copyWith(fontSize: responsive.text(15)),
          ),
          SizedBox(height: responsive.h(4)),
          Text(
            subtitle,
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
              ).copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          SizedBox(height: responsive.h(12)),
          AppChipButton(
            responsive: responsive,
            label: selectedValue.isNotEmpty ? 'Remplacer' : actionLabel,
            onTap: onTap,
          ),
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
  final _relCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _relCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final rel = _relCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty || rel.isEmpty) return;
    widget.onAdd(name, phone, rel);
    _nameCtrl.clear();
    _relCtrl.clear();
    _phoneCtrl.clear();
    setState(() => _showForm = false);
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
                  side: const BorderSide(color: AppColors.border),
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
            AppField(
              responsive: r,
              label: 'Relation',
              labelStyle: AppTextStyles.profileSectionLabel(r),
              controller: _relCtrl,
              hintText: 'Ex: Père, Mère, Ami...',
              textStyle: AppTextStyles.profileFieldValue(r),
              hintStyle: AppTextStyles.profileFieldValue(r)
                  .copyWith(color: AppColors.textGhost),
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
              side: const BorderSide(color: AppColors.border),
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


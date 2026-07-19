import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/auth/complete_profile/controllers/profile_driver_controller.dart';
import 'package:covoiturage_benin_app/app/modules/auth/complete_profile/controllers/profile_passager_controller.dart'
    show EmergencyContactEntry;
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/face_verification_section.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/id_card_preview_tile.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/phone_field_widget.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/selfie_capture_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileDriverView extends GetView<ProfileDriverController> {
  const ProfileDriverView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(16),
                  vertical: responsive.h(20),
                ),
                child: GetBuilder<ProfileDriverController>(
                  builder: (controller) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _TopBar(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _ProgressCard(
                          responsive: responsive,
                          progress: controller.progress.value,
                        ),
                        SizedBox(height: responsive.h(20)),
                        _HeroCard(responsive: responsive),
                        SizedBox(height: responsive.h(20)),

                        // ── Informations personnelles ──────────────────────
                        _SectionCard(
                          responsive: responsive,
                          title: AppStrings.profileSectionPersonal,
                          icon: Icons.badge_outlined,
                          child: Column(
                            children: [
                              AppField(
                                responsive: responsive,
                                label: AppStrings.profileFieldLastName,
                                labelStyle: AppTextStyles.profileSectionLabel(responsive),
                                controller: controller.lastNameController,
                                hintText: AppStrings.profileFieldLastNameHint,
                                textStyle: AppTextStyles.profileFieldValue(responsive),
                                hintStyle: AppTextStyles.profileFieldValue(responsive)
                                    .copyWith(color: AppColors.textGhost),
                              ),
                              SizedBox(height: responsive.h(16)),
                              AppField(
                                responsive: responsive,
                                label: AppStrings.profileFieldFirstName,
                                labelStyle: AppTextStyles.profileSectionLabel(responsive),
                                controller: controller.firstNameController,
                                hintText: AppStrings.profileFieldFirstNameHint,
                                textStyle: AppTextStyles.profileFieldValue(responsive),
                                hintStyle: AppTextStyles.profileFieldValue(responsive)
                                    .copyWith(color: AppColors.textGhost),
                              ),
                              SizedBox(height: responsive.h(16)),
                              _GenderSelector(
                                responsive: responsive,
                                selected: controller.selectedGender.value,
                                onSelected: controller.selectGender,
                              ),
                              SizedBox(height: responsive.h(16)),
                              PhoneFieldWidget(
                                responsive: responsive,
                                controller: controller.phoneController,
                                label: AppStrings.profileFieldPhone,
                                labelStyle: AppTextStyles.profileSectionLabel(responsive),
                                backgroundColor: AppColors.surfaceAccent,
                                borderColor: AppColors.primary,
                                helperText: AppStrings.profileSectionPhoneVerified,
                                helperStyle: AppTextStyles.profileMeta(responsive)
                                    .copyWith(color: AppColors.primary),
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
                                      hintStyle: AppTextStyles.profileFieldValue(responsive)
                                          .copyWith(color: AppColors.textGhost),
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
                                      hintStyle: AppTextStyles.profileFieldValue(responsive)
                                          .copyWith(color: AppColors.textGhost),
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
                                hintStyle: AppTextStyles.profileFieldValue(responsive)
                                    .copyWith(color: AppColors.textGhost),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.h(20)),

                        // ── Selfie ─────────────────────────────────────────
                        _SectionCard(
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

                        // ── CNI ────────────────────────────────────────────
                        _SectionCard(
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
                                selectedValue: controller.idCardBackName.value,
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

                        // ── Véhicule ───────────────────────────────────────
                        _SectionCard(
                          responsive: responsive,
                          title: AppStrings.profileSectionVehicle,
                          icon: controller.selectedDriverType.value == DriverType.moto
                              ? Icons.two_wheeler_rounded
                              : Icons.directions_car_rounded,
                          child: Column(
                            children: [
                              // Type selector — même hauteur que les champs
                              _VehicleTypeSelector(
                                responsive: responsive,
                                selected: controller.selectedDriverType.value,
                                onSelected: controller.selectDriverType,
                              ),
                              SizedBox(height: responsive.h(16)),

                              // Marque — sélecteur bottom sheet
                              _VehicleSelectField(
                                responsive: responsive,
                                label: AppStrings.profileFieldVehicleBrand,
                                hint: controller.selectedDriverType.value == DriverType.moto
                                    ? 'Honda, Yamaha, Suzuki...'
                                    : 'Toyota, Peugeot, Renault...',
                                value: controller.selectedBrand.value,
                                onTap: () => _showVehiclePicker(
                                  context: context,
                                  responsive: responsive,
                                  title: AppStrings.profileFieldVehicleBrand,
                                  items: controller.brandsForType,
                                  selected: controller.selectedBrand.value,
                                  onSelect: controller.selectBrand,
                                ),
                              ),
                              SizedBox(height: responsive.h(16)),

                              // Modèle — sélecteur bottom sheet (désactivé sans marque)
                              _VehicleSelectField(
                                responsive: responsive,
                                label: AppStrings.profileFieldVehicleModel,
                                hint: controller.selectedBrand.value != null
                                    ? 'Sélectionner le modèle'
                                    : 'Choisir la marque d\'abord',
                                value: controller.selectedModel.value,
                                disabled: controller.selectedBrand.value == null,
                                onTap: controller.selectedBrand.value != null
                                    ? () => _showVehiclePicker(
                                          context: context,
                                          responsive: responsive,
                                          title: AppStrings.profileFieldVehicleModel,
                                          items: controller.modelsForBrand,
                                          selected: controller.selectedModel.value,
                                          onSelect: controller.selectModel,
                                        )
                                    : null,
                              ),
                              SizedBox(height: responsive.h(16)),

                              // Couleur + Plaque
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: AppField(
                                      responsive: responsive,
                                      label: AppStrings.profileFieldVehicleColor,
                                      labelStyle: AppTextStyles.profileSectionLabel(responsive),
                                      backgroundColor: AppColors.surfaceMuted,
                                      controller: controller.vehicleColorController,
                                      hintText: AppStrings.profileVehicleColorValue,
                                      textStyle: AppTextStyles.profileFieldValue(responsive),
                                      hintStyle: AppTextStyles.profileFieldValue(responsive)
                                          .copyWith(color: AppColors.textGhost),
                                    ),
                                  ),
                                  SizedBox(width: responsive.w(12)),
                                  // Places: éditable voiture, fixe moto
                                  if (controller.selectedDriverType.value == DriverType.car)
                                    Expanded(
                                      child: AppField(
                                        responsive: responsive,
                                        label: AppStrings.profileFieldVehicleSeats,
                                        labelStyle: AppTextStyles.profileSectionLabel(responsive),
                                        backgroundColor: AppColors.surfaceMuted,
                                        controller: controller.vehicleSeatsController,
                                        hintText: AppStrings.profileVehicleSeatsValue,
                                        keyboardType: TextInputType.number,
                                        helperText: '4 à 7 places',
                                        helperStyle: AppTextStyles.profileMeta(responsive),
                                        textStyle: AppTextStyles.profileFieldValue(responsive),
                                        hintStyle: AppTextStyles.profileFieldValue(responsive)
                                            .copyWith(color: AppColors.textGhost),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            AppStrings.profileFieldVehicleSeats,
                                            style: AppTextStyles.profileSectionLabel(responsive),
                                          ),
                                          SizedBox(height: responsive.h(8)),
                                          Container(
                                            width: double.infinity,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: responsive.w(12),
                                              vertical: responsive.h(12),
                                            ),
                                            decoration: ShapeDecoration(
                                              color: AppColors.surfaceAccent,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(responsive.radius(10)),
                                                side: const BorderSide(color: AppColors.primary),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.person_rounded, size: 16, color: AppColors.primary),
                                                SizedBox(width: responsive.w(6)),
                                                Text(
                                                  '1 passager',
                                                  style: AppTextStyles.profileFieldValue(responsive)
                                                      .copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: responsive.h(4)),
                                          Text(
                                            'Fixé pour moto',
                                            style: AppTextStyles.profileMeta(responsive)
                                                .copyWith(color: AppColors.primary),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(height: responsive.h(16)),
                              AppField(
                                responsive: responsive,
                                label: AppStrings.profileFieldPlate,
                                labelStyle: AppTextStyles.profileSectionLabel(responsive),
                                controller: controller.plateController,
                                hintText: controller.selectedDriverType.value == DriverType.moto
                                    ? 'BJ-1234-M'
                                    : AppStrings.profileVehiclePlateValue,
                                textStyle: AppTextStyles.profileFieldValue(responsive),
                                hintStyle: AppTextStyles.profileFieldValue(responsive)
                                    .copyWith(color: AppColors.textGhost),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.h(20)),

                        // ── Documents ──────────────────────────────────────
                        _SectionCard(
                          responsive: responsive,
                          title: AppStrings.profileSectionDocuments,
                          icon: Icons.description_outlined,
                          child: Column(
                            children: [
                              AppField(
                                responsive: responsive,
                                label: AppStrings.profileLicenseNumber,
                                labelStyle: AppTextStyles.profileSectionLabel(responsive),
                                controller: controller.licenseNumberController,
                                hintText: AppStrings.profileLicenseNumberHint,
                                helperText: controller.selectedDriverType.value == DriverType.moto
                                    ? 'Permis de conduire moto (A)'
                                    : 'Permis de conduire voiture (B)',
                                helperStyle: AppTextStyles.profileMeta(responsive)
                                    .copyWith(color: AppColors.primary),
                                textStyle: AppTextStyles.profileFieldValue(responsive),
                                hintStyle: AppTextStyles.profileFieldValue(responsive)
                                    .copyWith(color: AppColors.textGhost),
                              ),
                              SizedBox(height: responsive.h(16)),
                              _DocumentUploadTile(
                                responsive: responsive,
                                title: controller.selectedDriverType.value == DriverType.moto
                                    ? 'Photo de la moto'
                                    : AppStrings.profileFieldVehiclePhoto,
                                subtitle: AppStrings.profileFieldVehiclePhotoHint,
                                actionLabel: AppStrings.profileUploadPhoto,
                                icon: controller.selectedDriverType.value == DriverType.moto
                                    ? Icons.two_wheeler_rounded
                                    : Icons.photo_camera_outlined,
                                onTap: () {
                                  _showImageSourcePicker(context, responsive).then((src) {
                                    if (src != null) controller.addVehiclePhoto(source: src);
                                  });
                                },
                                selectedValue: controller.vehiclePhotoName.value,
                              ),
                              SizedBox(height: responsive.h(16)),
                              _DocumentUploadTile(
                                responsive: responsive,
                                title: controller.selectedDriverType.value == DriverType.moto
                                    ? 'Attestation d\'immatriculation'
                                    : AppStrings.profileFieldRegistration,
                                subtitle: controller.selectedDriverType.value == DriverType.moto
                                    ? 'Document d\'enregistrement moto'
                                    : AppStrings.profileFieldRegistrationHint,
                                actionLabel: AppStrings.profileUploadDocument,
                                icon: Icons.folder_open_rounded,
                                onTap: () => controller.addRequiredDocument(isLicense: false),
                                selectedValue: controller.registrationDocumentName.value,
                              ),
                              SizedBox(height: responsive.h(16)),
                              _DocumentUploadTile(
                                responsive: responsive,
                                title: controller.selectedDriverType.value == DriverType.moto
                                    ? 'Permis moto (catégorie A)'
                                    : AppStrings.profileFieldLicense,
                                subtitle: AppStrings.profileFieldLicenseHint,
                                actionLabel: AppStrings.profileUploadDocument,
                                icon: Icons.badge_outlined,
                                onTap: () => controller.addRequiredDocument(isLicense: true),
                                selectedValue: controller.licenseDocumentName.value,
                              ),
                              SizedBox(height: responsive.h(16)),
                              _DocumentUploadTile(
                                responsive: responsive,
                                title: AppStrings.profileInsuranceDoc,
                                subtitle: AppStrings.profileInsuranceDocHint,
                                actionLabel: AppStrings.profileUploadDocument,
                                icon: Icons.security_rounded,
                                onTap: controller.addInsuranceDoc,
                                selectedValue: controller.insuranceDocName.value,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: responsive.h(20)),
                        _TrustCard(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        _EmergencyContactsRegSection(
                          responsive: responsive,
                          contacts: controller.emergencyContacts.toList(),
                          onAdd: controller.addEmergencyContact,
                          onRemove: controller.removeEmergencyContact,
                        ),
                        SizedBox(height: responsive.h(20)),
                        _ProgressSummary(responsive: responsive),
                        SizedBox(height: responsive.h(20)),
                        AppPrimaryButton(
                          responsive: responsive,
                          label: controller.isSubmitting.value
                              ? 'Envoi en cours...'
                              : AppStrings.profilePrimaryAction,
                          enabled: !controller.isSubmitting.value,
                          onTap: controller.continueProfile,
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

  static void _showVehiclePicker({
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
      builder: (_) => _VehiclePickerSheet(
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

// ─── Private widgets ──────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.responsive});
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppCircularButton(
          responsive: responsive,
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: Get.back,
          size: responsive.w(40),
        ),
        Row(
          children: [
            Container(
              width: responsive.w(32),
              height: responsive.w(32),
              alignment: Alignment.center,
              decoration: ShapeDecoration(
                color: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(responsive.radius(8)),
                ),
              ),
              child: Text(
                'M',
                style: AppTextStyles.profileSectionTitle(responsive).copyWith(
                  color: AppColors.white,
                  fontSize: responsive.text(16),
                ),
              ),
            ),
            SizedBox(width: responsive.w(8)),
            Text(AppStrings.appName, style: AppTextStyles.profileSectionTitle(responsive)),
            SizedBox(width: responsive.w(70)),
            AppCircularButton(
              responsive: responsive,
              icon: Icons.person_outline_rounded,
              onTap: () {},
              size: responsive.w(40),
              filled: false,
            ),
          ],
        ),
      ],
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
            Text(AppStrings.profileProgressLabel, style: AppTextStyles.profileMeta(responsive)),
            Text('$progress%', style: AppTextStyles.profileMeta(responsive)),
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
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.warning]),
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
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: responsive.w(56),
                height: responsive.w(56),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(responsive.radius(16)),
                ),
                child: Icon(Icons.verified_outlined, color: AppColors.white, size: responsive.text(28)),
              ),
              SizedBox(width: responsive.w(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.profileHeroTitle, style: AppTextStyles.profileHeroTitle(responsive)),
                    SizedBox(height: responsive.h(4)),
                    Text(AppStrings.profileHeroSubtitle, style: AppTextStyles.profileHeroSubtitle(responsive)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(16)),
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.white, size: 16),
              SizedBox(width: responsive.w(8)),
              Text(
                AppStrings.profileHeroTime,
                style: AppTextStyles.profileHeroSubtitle(responsive).copyWith(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Gender selector ───────────────────────────────────────────────────────────

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
        Text(AppStrings.profileFieldGender, style: AppTextStyles.profileSectionLabel(responsive)),
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

// ── Vehicle type chips (même hauteur que les champs) ─────────────────────────

class _VehicleTypeSelector extends StatelessWidget {
  const _VehicleTypeSelector({
    required this.responsive,
    required this.selected,
    required this.onSelected,
  });

  final AppResponsive responsive;
  final DriverType selected;
  final void Function(DriverType) onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Type de véhicule', style: AppTextStyles.profileSectionLabel(responsive)),
        SizedBox(height: responsive.h(8)),
        Row(
          children: [
            Expanded(child: _buildChip(DriverType.car, 'Voiture', Icons.directions_car_rounded)),
            SizedBox(width: responsive.w(10)),
            Expanded(child: _buildChip(DriverType.moto, 'Moto', Icons.two_wheeler_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(DriverType type, String label, IconData icon) {
    final isSelected = selected == type;
    return GestureDetector(
      onTap: () => onSelected(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
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
            Icon(icon, size: responsive.text(16),
                color: isSelected ? AppColors.white : AppColors.textMuted),
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

// ── Vehicle select field ──────────────────────────────────────────────────────

class _VehicleSelectField extends StatelessWidget {
  const _VehicleSelectField({
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
                  color: hasValue && !disabled ? AppColors.primary : AppColors.border,
                  width: hasValue && !disabled ? 1.5 : 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasValue ? Icons.check_circle_rounded : Icons.search_rounded,
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

// ── Vehicle picker bottom sheet ───────────────────────────────────────────────

class _VehiclePickerSheet extends StatefulWidget {
  const _VehiclePickerSheet({
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
  State<_VehiclePickerSheet> createState() => _VehiclePickerSheetState();
}

class _VehiclePickerSheetState extends State<_VehiclePickerSheet> {
  late List<String> _filtered;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = widget.items.where((e) => e.toLowerCase().contains(q)).toList();
      });
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
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.70),
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
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(r.w(24), r.h(16), r.w(24), r.h(4)),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: AppTextStyles.profileSectionTitle(r)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: r.w(32),
                    height: r.w(32),
                    decoration: const BoxDecoration(
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
              height: r.h(40),
              padding: EdgeInsets.symmetric(horizontal: r.w(14)),
              decoration: ShapeDecoration(
                color: AppColors.surfaceMuted,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.radius(10)),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: r.text(16), color: AppColors.textMuted),
                  SizedBox(width: r.w(8)),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Rechercher...',
                        border: InputBorder.none,
                        isDense: true,
                        hintStyle: AppTextStyles.profileMeta(r).copyWith(color: AppColors.textGhost),
                      ),
                      style: AppTextStyles.profileFieldValue(r),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          // List
          Flexible(
            child: _filtered.isEmpty
                ? Padding(
                    padding: EdgeInsets.all(r.w(32)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: r.text(40), color: AppColors.textMuted),
                        SizedBox(height: r.h(12)),
                        Text('Aucun résultat',
                            style: AppTextStyles.profileMeta(r).copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.symmetric(horizontal: r.w(16), vertical: r.h(8)),
                    itemCount: _filtered.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.surfaceSoft),
                    itemBuilder: (_, i) {
                      final item = _filtered[i];
                      final isSelected = widget.selected == item;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onSelect(item),
                          borderRadius: BorderRadius.circular(r.radius(10)),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: r.w(12), vertical: r.h(14)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item,
                                    style: AppTextStyles.profileSectionLabel(r).copyWith(
                                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_rounded, size: r.text(18), color: AppColors.primary),
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

// ── Emergency contacts registration section ───────────────────────────────────

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
    return _SectionCard(
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

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
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
          side: const BorderSide(color: AppColors.surfaceSoft),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 15, offset: Offset(0, 10)),
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 4)),
        ],
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
                child: Icon(icon, color: AppColors.primary, size: responsive.text(18)),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.profileSectionTitle(responsive)),
                    if (subtitle != null) ...[
                      SizedBox(height: responsive.h(2)),
                      Text(subtitle!, style: AppTextStyles.profileMeta(responsive)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(24)),
          child,
        ],
      ),
    );
  }
}

// ── Document upload tile ──────────────────────────────────────────────────────

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
              color: selectedValue.isNotEmpty ? AppColors.successLight : AppColors.surfaceAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
            ),
            child: Icon(
              selectedValue.isNotEmpty ? Icons.check_rounded : icon,
              color: selectedValue.isNotEmpty ? AppColors.success : AppColors.primary,
              size: responsive.text(20),
            ),
          ),
          SizedBox(height: responsive.h(12)),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTextStyles.profileSectionTitle(responsive)
                .copyWith(fontSize: responsive.text(15)),
          ),
          SizedBox(height: responsive.h(4)),
          Text(subtitle, textAlign: TextAlign.center, style: AppTextStyles.profileMeta(responsive)),
          if (selectedValue.isNotEmpty) ...[
            SizedBox(height: responsive.h(8)),
            Text(
              selectedValue,
              textAlign: TextAlign.center,
              style: AppTextStyles.profileMeta(responsive)
                  .copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
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

// ── Trust card ────────────────────────────────────────────────────────────────

class _TrustCard extends StatelessWidget {
  const _TrustCard({required this.responsive});
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(24)),
      decoration: ShapeDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.00, 0.50),
          end: Alignment(1.00, 0.50),
          colors: [AppColors.surfaceAccent, AppColors.surfaceWarning],
        ),
        shape: RoundedRectangleBorder(
          side: const BorderSide(width: 1, color: AppColors.surfaceAccentStrong),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
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
                borderRadius: BorderRadius.circular(responsive.radius(12)),
              ),
            ),
            child: Icon(Icons.verified_user_outlined, color: AppColors.primary, size: responsive.text(18)),
          ),
          SizedBox(width: responsive.w(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.profileSectionSecurity, style: AppTextStyles.profileSectionTitle(responsive)),
                SizedBox(height: responsive.h(4)),
                Text(AppStrings.profileSectionSecurityHint, style: AppTextStyles.profileMeta(responsive)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress summary ──────────────────────────────────────────────────────────

class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary({required this.responsive});
  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.profileSectionProgress, style: AppTextStyles.profileSectionLabel(responsive)),
            SizedBox(height: responsive.h(2)),
            Text(AppStrings.profileSectionProgressHint, style: AppTextStyles.profileMeta(responsive)),
          ],
        ),
        Container(
          width: responsive.w(48),
          height: responsive.w(48),
          decoration: ShapeDecoration(
            color: AppColors.surfaceAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(16)),
            ),
          ),
          child: Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: responsive.text(24)),
        ),
      ],
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


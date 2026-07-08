import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/services/auth/auth_service.dart';
import 'package:covoiturage_benin_app/app/core/services/driver/profile/driver_profile_service.dart';
import 'package:covoiturage_benin_app/app/core/utils/logger.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/data/models/driver/profile_model.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

class DriverProfileController extends GetxController {
  DriverProfileService get _service => Get.find<DriverProfileService>();

  // ── Reactive state ───────────────────────────────────────────────────────
  final RxBool autoAvailability = false.obs;
  final RxBool notificationsEnabled = true.obs;
  final RxBool isLoading = false.obs;
  final RxInt profileVersion = 0.obs;

  // ── Hero data ────────────────────────────────────────────────────────────
  String heroName = AppStrings.driverProfileName;
  String heroBadge = AppStrings.driverProfileBadge;
  String heroLevel = 'Niveau 1';
  String heroLocation = AppStrings.driverProfileLocation;
  double heroRating = 4.8;
  int heroTrips = 0;
  int heroTenureMonths = 0;

  // ── Performance data ─────────────────────────────────────────────────────
  String perfCurrentLevel = AppStrings.driverProfileCurrentLevelValue;
  String perfNextLevel = 'Or';
  double perfProgress = 0.75;
  int perfBadgesCount = 0;
  int perfTopPercent = 0;
  int perfBonusCount = 0;
  int perfTripsToNext = 0;

  // ── Personal info (edit form fields) ────────────────────────────────────
  String firstName = '';
  String lastName = '';
  String email = '';
  String city = '';
  String neighborhood = '';
  String addressDetails = '';
  String phone = '';

  // ── Mutable data lists ───────────────────────────────────────────────────
  List<DriverVerificationItem> verificationItems = const [
    DriverVerificationItem(
      title: AppStrings.driverProfileTrustPhone,
      status: AppStrings.driverProfileVerified,
      icon: Icons.phone_rounded,
    ),
    DriverVerificationItem(
      title: AppStrings.driverProfileTrustIdentity,
      status: AppStrings.driverProfileValidated,
      icon: Icons.badge_rounded,
    ),
    DriverVerificationItem(
      title: AppStrings.driverProfileTrustLicense,
      status: AppStrings.driverProfileValidated,
      icon: Icons.credit_card_rounded,
    ),
    DriverVerificationItem(
      title: AppStrings.driverProfileTrustVehicle,
      status: AppStrings.driverProfileVerified,
      icon: Icons.directions_car_rounded,
    ),
  ];

  List<DriverStatItem> stats = const [
    DriverStatItem(
      value: '—',
      label: AppStrings.driverProfileStatsPassengers,
      icon: Icons.people_alt_rounded,
      accentStart: AppColors.blueDark,
      accentEnd: AppColors.blue,
      emphasized: true,
    ),
    DriverStatItem(
      value: '—',
      label: AppStrings.driverProfileStatsRevenue,
      icon: Icons.payments_rounded,
      accentStart: AppColors.primary,
      accentEnd: AppColors.success,
      emphasized: true,
    ),
    DriverStatItem(
      value: '—',
      label: AppStrings.driverProfileStatsSatisfaction,
      icon: Icons.favorite_rounded,
      accentStart: AppColors.white,
      accentEnd: AppColors.white,
      emphasized: false,
    ),
    DriverStatItem(
      value: '—',
      label: AppStrings.driverProfileStatsAcceptance,
      icon: Icons.check_circle_rounded,
      accentStart: AppColors.white,
      accentEnd: AppColors.white,
      emphasized: false,
    ),
  ];

  List<DriverPersonalInfoItem> personalInfo = const [
    DriverPersonalInfoItem(
      label: 'Nom complet',
      value: '—',
      icon: Icons.person_rounded,
    ),
    DriverPersonalInfoItem(
      label: AppStrings.profileFieldPhone,
      value: '—',
      icon: Icons.phone_rounded,
    ),
    DriverPersonalInfoItem(
      label: 'Email',
      value: '—',
      icon: Icons.email_rounded,
    ),
    DriverPersonalInfoItem(
      label: 'Ville',
      value: '—',
      icon: Icons.location_city_rounded,
    ),
  ];

  List<DriverVehicleItem> vehicles = const [];

  List<DriverDocumentItem> documents = const [
    DriverDocumentItem(
      title: AppStrings.driverProfileDocumentLicense,
      subtitle: AppStrings.driverProfileDocumentLicenseMeta,
      icon: Icons.credit_card_rounded,
    ),
    DriverDocumentItem(
      title: AppStrings.driverProfileDocumentRegistration,
      subtitle: AppStrings.driverProfileDocumentRegistrationMeta,
      icon: Icons.description_rounded,
    ),
    DriverDocumentItem(
      title: AppStrings.driverProfileDocumentInsurance,
      subtitle: AppStrings.driverProfileDocumentInsuranceMeta,
      icon: Icons.verified_user_rounded,
    ),
  ];

  final RxString selectedLanguage = 'fr'.obs;
  final RxBool shareLocation = true.obs;
  final RxBool shareActivity = true.obs;

  List<DriverSettingItem> get settings => [
    DriverSettingItem(
      title: AppStrings.driverProfilePrivacy,
      icon: Icons.lock_outline_rounded,
    ),
    DriverSettingItem(
      title: AppStrings.driverProfileSecurity,
      icon: Icons.shield_outlined,
    ),
    DriverSettingItem(
      title: AppStrings.driverProfileLanguage,
      icon: Icons.language_rounded,
      trailing: selectedLanguage.value == 'fr' ? 'Français' : 'English',
    ),
  ];

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    final result = await _service.fetchProfile();
    isLoading.value = false;
    if (result.isSuccess) {
      _applyProfile(result.data!);
    } else {
      logger.w('profile load failed: ${result.error}');
    }
  }

  void _applyProfile(ProfileModel data) {
    // Hero
    heroName = data.hero.fullName;
    heroBadge = data.hero.badge;
    heroLevel = 'Niveau ${data.hero.levelNumber}';
    heroLocation = data.hero.location;
    heroRating = data.hero.rating;
    heroTrips = data.hero.tripsCount;
    heroTenureMonths = data.hero.tenureMonths;

    // Performance
    perfCurrentLevel = data.performance.currentLevel;
    perfNextLevel = data.performance.nextLevel;
    perfProgress = data.performance.progress;
    perfBadgesCount = data.performance.badgesCount;
    perfTopPercent = data.performance.topPercent;
    perfBonusCount = data.performance.bonusCount;
    perfTripsToNext = data.performance.tripsToNext;

    // Personal info (edit form)
    firstName = data.personalInfo.firstName;
    lastName = data.personalInfo.lastName;
    email = data.personalInfo.email;
    city = data.personalInfo.city;
    neighborhood = data.personalInfo.neighborhood;
    addressDetails = data.personalInfo.addressDetails;
    phone = data.personalInfo.phone;

    // Preferences
    autoAvailability.value = data.preferences.autoAvailability;
    notificationsEnabled.value = data.preferences.notificationsEnabled;

    // Verification items
    verificationItems = data.verificationItems
        .map((v) => DriverVerificationItem(
              title: v.title,
              status: v.status,
              icon: _verificationIcon(v.key),
            ))
        .toList();

    // Stats
    stats = data.stats
        .map((s) => DriverStatItem(
              value: s.value,
              label: s.label,
              icon: _statIcon(s.key),
              accentStart: _statGradientStart(s.key, s.emphasized),
              accentEnd: _statGradientEnd(s.key, s.emphasized),
              emphasized: s.emphasized,
            ))
        .toList();

    // Personal info display
    personalInfo = [
      DriverPersonalInfoItem(
        label: 'Nom complet',
        value: data.personalInfo.fullName.isNotEmpty
            ? data.personalInfo.fullName
            : '${data.personalInfo.firstName} ${data.personalInfo.lastName}'.trim(),
        icon: Icons.person_rounded,
      ),
      DriverPersonalInfoItem(
        label: AppStrings.profileFieldPhone,
        value: data.personalInfo.phone,
        icon: Icons.phone_rounded,
      ),
      DriverPersonalInfoItem(
        label: 'Email',
        value: data.personalInfo.email,
        icon: Icons.email_rounded,
      ),
      DriverPersonalInfoItem(
        label: 'Ville',
        value: data.personalInfo.city,
        icon: Icons.location_city_rounded,
      ),
    ];

    // Vehicles
    vehicles = data.vehicles
        .map((v) => DriverVehicleItem(
              title: '${v.brand} ${v.model}'.trim(),
              subtitle:
                  '${v.color}${v.year > 0 ? ' · ${v.year}' : ''} · ${v.availableSeats} places',
              plate: v.licensePlate,
              active: v.isActive,
            ))
        .toList();

    // Documents
    if (data.documents.isNotEmpty) {
      documents = data.documents
          .map((d) => DriverDocumentItem(
                title: d.title,
                subtitle: d.subtitle,
                icon: _documentIcon(d.key),
              ))
          .toList();
    }

    profileVersion.value++;
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String tenureLabel() {
    if (heroTenureMonths == 0) return '—';
    if (heroTenureMonths < 12) return '$heroTenureMonths mois';
    final years = heroTenureMonths ~/ 12;
    return '$years an${years > 1 ? 's' : ''}';
  }

  IconData _verificationIcon(String key) => switch (key) {
        'phone' => Icons.phone_rounded,
        'identity' || 'id_card' => Icons.badge_rounded,
        'license' || 'driving_license' => Icons.credit_card_rounded,
        'vehicle' => Icons.directions_car_rounded,
        _ => Icons.verified_rounded,
      };

  IconData _statIcon(String key) => switch (key) {
        'passengers' => Icons.people_alt_rounded,
        'earnings' || 'revenue' => Icons.payments_rounded,
        'satisfaction' || 'rating' => Icons.favorite_rounded,
        'acceptance' || 'acceptance_rate' => Icons.check_circle_rounded,
        'trips' => Icons.route_rounded,
        _ => Icons.bar_chart_rounded,
      };

  Color _statGradientStart(String key, bool emphasized) {
    if (!emphasized) return AppColors.white;
    return switch (key) {
      'passengers' => AppColors.blueDark,
      'earnings' || 'revenue' => AppColors.primary,
      _ => AppColors.blueDark,
    };
  }

  Color _statGradientEnd(String key, bool emphasized) {
    if (!emphasized) return AppColors.white;
    return switch (key) {
      'passengers' => AppColors.blue,
      'earnings' || 'revenue' => AppColors.success,
      _ => AppColors.blue,
    };
  }

  IconData _documentIcon(String key) => switch (key) {
        'license' || 'driving_license' => Icons.credit_card_rounded,
        'id_card' || 'identity' => Icons.badge_rounded,
        'registration' || 'vehicle_doc' => Icons.description_rounded,
        'insurance' => Icons.verified_user_rounded,
        _ => Icons.article_rounded,
      };

  // ── Actions ──────────────────────────────────────────────────────────────

  void onEditProfile() {
    final firstNameCtrl = TextEditingController(text: firstName);
    final lastNameCtrl = TextEditingController(text: lastName);
    final emailCtrl = TextEditingController(text: email);
    final cityCtrl = TextEditingController(text: city);
    final neighborhoodCtrl = TextEditingController(text: neighborhood);
    final addressCtrl = TextEditingController(text: addressDetails);

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(9999))),
                ),
                const SizedBox(height: 16),
                const Text('Modifier le profil',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                const SizedBox(height: 16),
                _ProfileField(
                    label: 'Prénom',
                    controller: firstNameCtrl,
                    icon: Icons.person_rounded),
                const SizedBox(height: 12),
                _ProfileField(
                    label: 'Nom',
                    controller: lastNameCtrl,
                    icon: Icons.person_outline_rounded),
                const SizedBox(height: 12),
                _ProfileField(
                    label: 'Email',
                    controller: emailCtrl,
                    icon: Icons.email_rounded,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _ProfileField(
                    label: 'Ville',
                    controller: cityCtrl,
                    icon: Icons.location_city_rounded),
                const SizedBox(height: 12),
                _ProfileField(
                    label: 'Quartier',
                    controller: neighborhoodCtrl,
                    icon: Icons.map_rounded),
                const SizedBox(height: 12),
                _ProfileField(
                    label: 'Adresse',
                    controller: addressCtrl,
                    icon: Icons.home_rounded),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    final fn = firstNameCtrl.text.trim();
                    final ln = lastNameCtrl.text.trim();
                    final em = emailCtrl.text.trim();
                    final ct = cityCtrl.text.trim();
                    final nb = neighborhoodCtrl.text.trim();
                    final ad = addressCtrl.text.trim();
                    firstNameCtrl.dispose();
                    lastNameCtrl.dispose();
                    emailCtrl.dispose();
                    cityCtrl.dispose();
                    neighborhoodCtrl.dispose();
                    addressCtrl.dispose();
                    Get.back();
                    final result = await _service.updateProfile(
                      firstName: fn,
                      lastName: ln,
                      email: em,
                      city: ct,
                      neighborhood: nb,
                      addressDetails: ad,
                    );
                    if (result.isSuccess) {
                      firstName = fn;
                      lastName = ln;
                      email = em;
                      city = ct;
                      neighborhood = nb;
                      addressDetails = ad;
                      heroName = '$fn $ln'.trim();
                      personalInfo = [
                        DriverPersonalInfoItem(
                            label: 'Nom complet',
                            value: heroName,
                            icon: Icons.person_rounded),
                        DriverPersonalInfoItem(
                            label: AppStrings.profileFieldPhone,
                            value: phone,
                            icon: Icons.phone_rounded),
                        DriverPersonalInfoItem(
                            label: 'Email',
                            value: em,
                            icon: Icons.email_rounded),
                        DriverPersonalInfoItem(
                            label: 'Ville',
                            value: ct,
                            icon: Icons.location_city_rounded),
                      ];
                      profileVersion.value++;
                      UIHelper().showSnackBar(
                          AppStrings.appName, 'Profil mis à jour avec succès.', 0);
                    } else {
                      UIHelper().showSnackBar(
                          AppStrings.appName, 'Erreur lors de la mise à jour.', 2);
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text('Enregistrer',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 15)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void onAddVehicle() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.directions_car_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Text('Ajouter un véhicule', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text(
          'Pour ajouter un nouveau véhicule, rendez-vous dans la section Publier un trajet et sélectionnez votre type de véhicule.',
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Fermer'))],
      ),
    );
  }

  void onVehicleTap(DriverVehicleItem item) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.active
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.directions_car_rounded,
                color: item.active ? AppColors.primary : AppColors.textMuted,
                size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(item.title,
                  style: const TextStyle(fontSize: 15))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.subtitle,
                style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text(item.plate,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 15)),
            const SizedBox(height: 6),
            if (!item.active)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x33F4B400),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('En attente de validation',
                    style: TextStyle(
                        color: Color(0xFFF4B400),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          if (!item.active)
            TextButton(
              onPressed: () {
                Get.back();
                UIHelper().showSnackBar(
                    AppStrings.appName, 'Document de validation soumis.', 0);
              },
              child: const Text('Activer',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }

  void onDocumentTap(DriverDocumentItem item) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(item.icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
              child: Text(item.title,
                  style: const TextStyle(fontSize: 15))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.subtitle,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text(
                'Pour renouveler ce document, téléchargez la nouvelle version.'),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Get.back();
              UIHelper().showSnackBar(
                  AppStrings.appName, 'Document soumis pour validation.', 0);
            },
            child: const Text('Renouveler',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void onSettingTap(DriverSettingItem item) {
    if (item.title == AppStrings.driverProfileLanguage) {
      _showLanguageDialog();
    } else if (item.title == AppStrings.driverProfilePrivacy) {
      _showPrivacySheet();
    } else if (item.title == AppStrings.driverProfileSecurity) {
      _showSecuritySheet();
    }
  }

  void _showLanguageDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.language_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Text('Langue', style: TextStyle(fontSize: 16)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              label: 'Français',
              code: 'fr',
              selected: selectedLanguage.value == 'fr',
              onTap: () => _selectLanguage('fr'),
            ),
            const SizedBox(height: 8),
            _LanguageOption(
              label: 'English',
              code: 'en',
              selected: selectedLanguage.value == 'en',
              onTap: () => _selectLanguage('en'),
            ),
          ],
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Annuler'))],
      ),
    );
  }

  Future<void> _selectLanguage(String code) async {
    Get.back();
    if (selectedLanguage.value == code) return;
    selectedLanguage.value = code;
    profileVersion.value++;
    final result = await _service.updatePreferences(
      autoAvailability: autoAvailability.value,
      notificationsEnabled: notificationsEnabled.value,
      language: code,
    );
    if (!result.isSuccess) {
      selectedLanguage.value = code == 'fr' ? 'en' : 'fr';
      profileVersion.value++;
      UIHelper().showSnackBar(AppStrings.appName, 'Erreur lors de la mise à jour.', 2);
    }
  }

  void _showPrivacySheet() {
    Get.bottomSheet(
      _PrivacySheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> savePrivacyPreferences() async {
    final result = await _service.updatePreferences(
      autoAvailability: autoAvailability.value,
      notificationsEnabled: notificationsEnabled.value,
      shareLocation: shareLocation.value,
      shareActivity: shareActivity.value,
    );
    if (result.isSuccess) {
      UIHelper().showSnackBar(AppStrings.appName, 'Confidentialité mise à jour.', 0);
    } else {
      UIHelper().showSnackBar(AppStrings.appName, 'Erreur lors de la mise à jour.', 2);
    }
  }

  void _showSecuritySheet() {
    Get.bottomSheet(
      _SecuritySheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> logoutAllDevices() async {
    Get.back();
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Se déconnecter',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Voulez-vous vraiment vous déconnecter de votre compte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Se déconnecter',
              style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await Get.find<AuthService>().logout();
    Get.offAllNamed(AppRoutes.register);
  }

  void onNotifications() => Get.toNamed(AppRoutes.driverNotifications);

  void onTune() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [
          Icon(Icons.tune_rounded, color: AppColors.primary, size: 22),
          SizedBox(width: 10),
          Text('Paramètres rapides', style: TextStyle(fontSize: 16)),
        ]),
        content: const Text(
          'Gérez vos préférences, notifications et disponibilité dans les sections ci-dessous.',
        ),
        actions: [TextButton(onPressed: Get.back, child: const Text('Fermer'))],
      ),
    );
  }

  Future<void> toggleAutoAvailability(bool value) async {
    autoAvailability.value = value;
    final result = await _service.updatePreferences(
      autoAvailability: value,
      notificationsEnabled: notificationsEnabled.value,
    );
    if (!result.isSuccess) {
      autoAvailability.value = !value;
      UIHelper().showSnackBar(
          AppStrings.appName, 'Erreur lors de la mise à jour.', 2);
    }
  }

  Future<void> toggleNotifications(bool value) async {
    notificationsEnabled.value = value;
    final result = await _service.updatePreferences(
      autoAvailability: autoAvailability.value,
      notificationsEnabled: value,
    );
    if (!result.isSuccess) {
      notificationsEnabled.value = !value;
      UIHelper().showSnackBar(
          AppStrings.appName, 'Erreur lors de la mise à jour.', 2);
    }
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
  });
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
          labelText: label,
          labelStyle:
              const TextStyle(color: AppColors.textMuted, fontSize: 13),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

class DriverVerificationItem {
  const DriverVerificationItem({
    required this.title,
    required this.status,
    required this.icon,
  });

  final String title;
  final String status;
  final IconData icon;
}

class DriverStatItem {
  const DriverStatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.accentStart,
    required this.accentEnd,
    required this.emphasized,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color accentStart;
  final Color accentEnd;
  final bool emphasized;
}

class DriverPersonalInfoItem {
  const DriverPersonalInfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;
}

class DriverVehicleItem {
  const DriverVehicleItem({
    required this.title,
    required this.subtitle,
    required this.plate,
    required this.active,
  });

  final String title;
  final String subtitle;
  final String plate;
  final bool active;
}

class DriverDocumentItem {
  const DriverDocumentItem({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class DriverSettingItem {
  const DriverSettingItem({
    required this.title,
    required this.icon,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final String? trailing;
}

// ── Settings helper widgets ───────────────────────────────────────────────────

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(children: [
          Text(label, style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : AppColors.textPrimary,
            fontSize: 15,
          )),
          const Spacer(),
          if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
        ]),
      ),
    );
  }
}

class _PrivacySheet extends StatelessWidget {
  const _PrivacySheet({required this.controller});
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999)),
          )),
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text('Confidentialité', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 20),
          Obx(() => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.shareLocation.value,
            onChanged: (v) => controller.shareLocation.value = v,
            title: const Text('Partage de localisation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: const Text('Autoriser l\'app à partager votre position', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            activeColor: AppColors.primary,
          )),
          const Divider(height: 1, color: AppColors.border),
          Obx(() => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: controller.shareActivity.value,
            onChanged: (v) => controller.shareActivity.value = v,
            title: const Text('Partage d\'activité', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            subtitle: const Text('Partager vos trajets avec les passagers', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
            activeColor: AppColors.primary,
          )),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              Get.back();
              controller.savePrivacyPreferences();
            },
            child: Container(
              width: double.infinity, height: 50,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
              child: const Center(child: Text('Enregistrer',
                  style: TextStyle(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 15))),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecuritySheet extends StatelessWidget {
  const _SecuritySheet({required this.controller});
  final DriverProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(9999)),
          )),
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.shield_outlined, color: AppColors.primary, size: 22),
            SizedBox(width: 10),
            Text('Sécurité', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 8),
          _SecurityTile(
            icon: Icons.support_agent_rounded,
            color: AppColors.primary,
            label: 'Changer le mot de passe',
            subtitle: 'Contactez le support pour modifier vos identifiants',
            onTap: () {
              Get.back();
              Get.toNamed(AppRoutes.driverSupportCenter);
            },
          ),
          const Divider(height: 1, color: AppColors.border),
          _SecurityTile(
            icon: Icons.logout_rounded,
            color: const Color(0xFFE53935),
            label: 'Se déconnecter',
            subtitle: 'Quitter votre session sur cet appareil',
            onTap: controller.logoutAllDevices,
          ),
        ],
      ),
    );
  }
}

class _SecurityTile extends StatelessWidget {
  const _SecurityTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
            ],
          )),
          Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 18),
        ]),
      ),
    );
  }
}

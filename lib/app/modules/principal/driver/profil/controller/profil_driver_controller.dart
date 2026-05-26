import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';

class DriverProfileController extends GetxController {
  final RxBool autoAvailability = true.obs;
  final RxBool notificationsEnabled = false.obs;

  final List<DriverVerificationItem> verificationItems = const [
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

  final List<DriverStatItem> stats = const [
    DriverStatItem(
      value: '568',
      label: AppStrings.driverProfileStatsPassengers,
      icon: Icons.people_alt_rounded,
      accentStart: AppColors.blueDark,
      accentEnd: AppColors.blue,
      emphasized: true,
    ),
    DriverStatItem(
      value: '2.4M',
      label: AppStrings.driverProfileStatsRevenue,
      icon: Icons.payments_rounded,
      accentStart: AppColors.primary,
      accentEnd: AppColors.success,
      emphasized: true,
    ),
    DriverStatItem(
      value: '98%',
      label: AppStrings.driverProfileStatsSatisfaction,
      icon: Icons.favorite_rounded,
      accentStart: AppColors.white,
      accentEnd: AppColors.white,
      emphasized: false,
    ),
    DriverStatItem(
      value: '96%',
      label: AppStrings.driverProfileStatsAcceptance,
      icon: Icons.check_circle_rounded,
      accentStart: AppColors.white,
      accentEnd: AppColors.white,
      emphasized: false,
    ),
  ];

  final List<DriverPersonalInfoItem> personalInfo = const [
    DriverPersonalInfoItem(
      label: 'Nom complet',
      value: AppStrings.driverProfileName,
      icon: Icons.person_rounded,
    ),
    DriverPersonalInfoItem(
      label: AppStrings.profileFieldPhone,
      value: '+229 97 45 32 10',
      icon: Icons.phone_rounded,
    ),
    DriverPersonalInfoItem(
      label: 'Email',
      value: 'kouadio.marcel@email.com',
      icon: Icons.email_rounded,
    ),
    DriverPersonalInfoItem(
      label: 'Ville',
      value: 'Cotonou',
      icon: Icons.location_city_rounded,
    ),
  ];

  final List<DriverVehicleItem> vehicles = const [
    DriverVehicleItem(
      title: AppStrings.driverProfileVehicleToyota,
      subtitle: AppStrings.driverProfileVehicleToyotaMeta,
      plate: AppStrings.driverProfileVehicleToyotaPlate,
      active: true,
    ),
    DriverVehicleItem(
      title: AppStrings.driverProfileVehicleHonda,
      subtitle: AppStrings.driverProfileVehicleHondaMeta,
      plate: AppStrings.driverProfileVehicleHondaPlate,
      active: false,
    ),
  ];

  final List<DriverDocumentItem> documents = const [
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

  final List<DriverSettingItem> settings = const [
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
      trailing: AppStrings.driverProfileFrench,
    ),
  ];

  void onEditProfile() => _showInfo(AppStrings.driverProfileEdit);

  void onAddVehicle() => _showInfo(AppStrings.driverProfileAddVehicle);

  void onVehicleTap(DriverVehicleItem item) => _showInfo(item.title);

  void onDocumentTap(DriverDocumentItem item) => _showInfo(item.title);

  void onSettingTap(DriverSettingItem item) => _showInfo(item.title);

  void toggleAutoAvailability(bool value) => autoAvailability.value = value;

  void toggleNotifications(bool value) => notificationsEnabled.value = value;

  void _showInfo(String action) {
    Get.snackbar(AppStrings.appName, '$action bientôt disponible.');
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

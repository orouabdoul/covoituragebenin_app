import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/utils/ui_helper.dart';
import 'package:covoiturage_benin_app/app/routes/app_routes.dart';

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

  void onEditProfile() {
    final nameCtrl = TextEditingController(text: AppStrings.driverProfileName);
    final phoneCtrl = TextEditingController(text: '+229 97 45 32 10');
    final cityCtrl = TextEditingController(text: 'Cotonou');

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                    decoration: BoxDecoration(color: AppColors.border,
                        borderRadius: BorderRadius.circular(9999))),
              ),
              const SizedBox(height: 16),
              const Text('Modifier le profil',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _ProfileField(label: 'Nom complet', controller: nameCtrl,
                  icon: Icons.person_rounded),
              const SizedBox(height: 12),
              _ProfileField(label: 'Téléphone', controller: phoneCtrl,
                  icon: Icons.phone_rounded, keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              _ProfileField(label: 'Ville', controller: cityCtrl,
                  icon: Icons.location_city_rounded),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  nameCtrl.dispose();
                  phoneCtrl.dispose();
                  cityCtrl.dispose();
                  Get.back();
                  UIHelper().showSnackBar(AppStrings.appName,
                      'Profil mis à jour avec succès.', 0);
                },
                child: Container(
                  width: double.infinity, height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text('Enregistrer',
                        style: TextStyle(fontWeight: FontWeight.w700,
                            color: Colors.white, fontSize: 15)),
                  ),
                ),
              ),
            ],
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
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: item.active ? AppColors.primary.withOpacity(0.12) : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.directions_car_rounded,
                color: item.active ? AppColors.primary : AppColors.textMuted, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(item.title, style: const TextStyle(fontSize: 15))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.subtitle, style: const TextStyle(color: AppColors.textMuted)),
            const SizedBox(height: 8),
            Text(item.plate,
                style: const TextStyle(fontWeight: FontWeight.w700,
                    color: AppColors.primary, fontSize: 15)),
            const SizedBox(height: 6),
            if (!item.active)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x33F4B400),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('En attente de validation',
                    style: TextStyle(color: Color(0xFFF4B400), fontSize: 12,
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
                UIHelper().showSnackBar(AppStrings.appName,
                    'Document de validation soumis.', 0);
              },
              child: const Text('Activer',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
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
          Expanded(child: Text(item.title, style: const TextStyle(fontSize: 15))),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.subtitle,
                style: const TextStyle(color: AppColors.primary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Pour renouveler ce document, téléchargez la nouvelle version.'),
          ],
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Fermer')),
          TextButton(
            onPressed: () {
              Get.back();
              UIHelper().showSnackBar(AppStrings.appName, 'Document soumis pour validation.', 0);
            },
            child: const Text('Renouveler',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void onSettingTap(DriverSettingItem item) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(item.icon, color: AppColors.textPrimary, size: 22),
          const SizedBox(width: 10),
          Text(item.title, style: const TextStyle(fontSize: 15)),
        ]),
        content: Text('La section "${item.title}" sera disponible dans la prochaine mise à jour.'),
        actions: [TextButton(onPressed: Get.back, child: const Text('OK'))],
      ),
    );
  }

  void onNotifications() {
    Get.toNamed(AppRoutes.driverNotifications);
  }

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

  void toggleAutoAvailability(bool value) => autoAvailability.value = value;

  void toggleNotifications(bool value) => notificationsEnabled.value = value;
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
          labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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

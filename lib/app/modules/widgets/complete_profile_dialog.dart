import 'package:covoiturage_benin_app/app/modules/auth/roles/controllers/roles_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';

/// A polished, responsive dialog asking the user whether they want to complete their profile now.
class CompleteProfileDialog extends StatelessWidget {
  const CompleteProfileDialog({super.key, this.onConfirm, this.onLater});
  final VoidCallback? onConfirm;
  final VoidCallback? onLater;

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: responsive.w(24)),
      child: Center(
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(responsive.radius(20)),
          child: Builder(
            builder: (context) {
              final double dialogWidth = MediaQuery.sizeOf(context).width >= 720
                  ? responsive.w(540)
                  : double.infinity;
              return Container(
                width: dialogWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(24),
                  vertical: responsive.h(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header row with title and close
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Compléter le profil',
                            style: AppTextStyles.dialogTitle(responsive),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9999),
                            onTap: () => Get.back(),
                            child: Padding(
                              padding: EdgeInsets.all(responsive.w(6)),
                              child: Icon(
                                Icons.close_rounded,
                                size: responsive.text(18),
                                color: AppColors.textHint,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: responsive.h(12)),
                    // Illustration / icon
                    Container(
                      width: responsive.w(96),
                      height: responsive.w(96),
                      decoration: ShapeDecoration(
                        color: AppColors.surfaceMuted,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            responsive.radius(16),
                          ),
                        ),
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: responsive.text(42),
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: responsive.h(16)),
                    Text(
                      'Souhaitez-vous compléter votre profil maintenant ?',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.dialogBody(responsive),
                    ),
                    SizedBox(height: responsive.h(12)),
                    Text(
                      'Compléter votre profil permet de débloquer toutes les fonctionnalités et d\'améliorer la confiance des autres utilisateurs.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.dialogHint(responsive),
                    ),
                    SizedBox(height: responsive.h(20)),
                    Row(
                      children: [
                        Expanded(
                          child: AppPrimaryButton(
                            responsive: responsive,
                            label: 'Oui, compléter',
                            onTap: () {
                              final RolesController rolesController =
                                  Get.find<RolesController>();
                              final role = rolesController.selectedRole.value;
                              if (role == RoleType.driver) {
                                Get.toNamed('/complete-profile-driver');
                              } else if (role == RoleType.passenger) {
                                Get.toNamed('/complete-profile-passenger' );
                              } else {
                                // If no role selected, go to roles selection
                                Get.toNamed('/roles');
                              }
                            },
                            backgroundColor: AppColors.primary,
                            textColor: AppColors.white,
                          ),
                        ),
                        SizedBox(width: responsive.w(12)),
                        Expanded(
                          child: AppPrimaryButton(
                            responsive: responsive,
                            label: 'Plus tard',
                            onTap: () {
                              final RolesController rolesController =
                                  Get.find<RolesController>();
                              final role = rolesController.selectedRole.value;

                              if (role == RoleType.driver) {
                                Get.offAllNamed('/dashboard-driver');
                              } else if (role == RoleType.passenger) {
                                Get.offAllNamed('/dashboard-passenger');
                              } else {
                                Get.offAllNamed('/roles');
                              }

                              onLater?.call();
                            },
                            backgroundColor: AppColors.white,
                            textColor: AppColors.primary,
                            borderColor: AppColors.border,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

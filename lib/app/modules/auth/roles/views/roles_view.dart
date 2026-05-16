import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/auth/roles/controllers/roles_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RolesView extends GetView<RolesController> {
  const RolesView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    responsive.w(24),
                    responsive.h(20),
                    responsive.w(24),
                    responsive.h(32),
                  ),
                  child: GetBuilder<RolesController>(
                    builder: (controller) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TopBar(responsive: responsive, onBack: Get.back),
                          SizedBox(height: responsive.h(32)),
                          Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: responsive.w(327),
                                  child: Text(
                                    AppStrings.rolesTitle,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.rolesTitle(responsive),
                                  ),
                                ),
                                SizedBox(height: responsive.h(12)),
                                SizedBox(
                                  width: responsive.w(295),
                                  child: Text(
                                    AppStrings.rolesSubtitle,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.rolesSubtitle(responsive),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: responsive.h(32)),
                          _RoleCard(
                            responsive: responsive,
                            data: _RoleCardData.driver(),
                            selected: controller.selectedRole.value == RoleType.driver,
                            onTap: () => controller.selectRole(RoleType.driver),
                          ),
                          SizedBox(height: responsive.h(24)),
                          _RoleCard(
                            responsive: responsive,
                            data: _RoleCardData.passenger(),
                            selected: controller.selectedRole.value == RoleType.passenger,
                            onTap: () => controller.selectRole(RoleType.passenger),
                          ),
                          SizedBox(height: responsive.h(24)),
                          AppPrimaryButton(
                            responsive: responsive,
                            label: AppStrings.rolesContinue,
                            enabled: controller.hasSelection,
                            onTap: controller.continueAction,
                          ),
                          SizedBox(height: responsive.h(12)),
                          Center(
                            child: AppTextButton(
                              responsive: responsive,
                              label: AppStrings.rolesChooseLater,
                              onTap: controller.chooseLater,
                              underlined: true,
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
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.responsive, required this.onBack});

  final AppResponsive responsive;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return AppCircularButton(
      responsive: responsive,
      icon: Icons.arrow_back_ios_new_rounded,
      onTap: onBack,
      size: responsive.w(40),
    );
  }
}

class _RoleCardData {
  const _RoleCardData({
    required this.title,
    required this.description,
    required this.gradientColors,
    required this.badgeColor,
    required this.icon,
    required this.benefits,
  });

  factory _RoleCardData.driver() => const _RoleCardData(
        title: 'Conducteur',
        description: 'Générez des revenus \nsupplémentaires en \npartageant vos trajets \nquotidiens',
        gradientColors: [Color(0xFF00A86B), Color(0xFF008F5A)],
        badgeColor: Color(0xFFF4B400),
        icon: Icons.directions_car_rounded,
        benefits: [
          'Revenus jusqu\'à 150 000 \nFCFA/mois',
          'Flexible et sans \ncontrainte',
          'Communauté de \nconducteurs vérifiés',
        ],
      );

  factory _RoleCardData.passenger() => const _RoleCardData(
        title: 'Passager',
        description: 'Voyagez confortablement et \néconomiquement vers votre \ndestination',
        gradientColors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
        badgeColor: Color(0xFFF4B400),
        icon: Icons.person_rounded,
        benefits: [
          'Économisez jusqu\'à 60% \nsur vos trajets',
          'Réservation instantanée \n24h/24',
          'Trajet sécurisé et assuré',
        ],
      );

  final String title;
  final String description;
  final List<Color> gradientColors;
  final Color badgeColor;
  final IconData icon;
  final List<String> benefits;
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.responsive,
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final AppResponsive responsive;
  final _RoleCardData data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(responsive.radius(24)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(responsive.w(24)),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: responsive.w(2),
                color: selected ? AppColors.primary : const Color(0xFFF3F4F6),
              ),
              borderRadius: BorderRadius.circular(responsive.radius(24)),
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: responsive.h(18),
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: responsive.w(24),
                  height: responsive.w(24),
                  decoration: ShapeDecoration(
                    color: selected ? AppColors.primary : Colors.white,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: responsive.w(2),
                        color: selected ? AppColors.primary : const Color(0xFFD1D5DB),
                      ),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                  ),
                  child: selected
                      ? Icon(
                          Icons.check_rounded,
                          size: responsive.text(14),
                          color: Colors.white,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoleAvatar(
                    responsive: responsive,
                    gradientColors: data.gradientColors,
                    badgeColor: data.badgeColor,
                    icon: data.icon,
                  ),
                  SizedBox(width: responsive.w(16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: responsive.w(195),
                          child: Text(
                            data.title,
                            style: AppTextStyles.rolesCardTitle(responsive),
                          ),
                        ),
                        SizedBox(height: responsive.h(16)),
                        SizedBox(
                          width: responsive.w(195),
                          child: Text(
                            data.description,
                            style: AppTextStyles.rolesCardDescription(responsive),
                          ),
                        ),
                        SizedBox(height: responsive.h(16)),
                        Column(
                          children: data.benefits
                              .map(
                                (benefit) => Padding(
                                  padding: EdgeInsets.only(bottom: responsive.h(12)),
                                  child: _BenefitItem(
                                    responsive: responsive,
                                    color: data.title == 'Passager'
                                        ? const Color(0xFFDBEAFE)
                                        : const Color(0xFFDCFCE7),
                                    text: benefit,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleAvatar extends StatelessWidget {
  const _RoleAvatar({
    required this.responsive,
    required this.gradientColors,
    required this.badgeColor,
    required this.icon,
  });

  final AppResponsive responsive;
  final List<Color> gradientColors;
  final Color badgeColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: responsive.w(64),
      height: responsive.w(64),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: responsive.w(64),
            height: responsive.w(64),
            decoration: ShapeDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(responsive.radius(16)),
              ),
            ),
            child: Icon(
              icon,
              size: responsive.text(30),
              color: Colors.white,
            ),
          ),
          Positioned(
            top: responsive.h(-4),
            right: responsive.w(-4),
            child: Container(
              width: responsive.w(24),
              height: responsive.w(24),
              decoration: ShapeDecoration(
                color: badgeColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                  side: const BorderSide(color: AppColors.border),
                ),
              ),
              child: Icon(
                Icons.star_rounded,
                size: responsive.text(14),
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({required this.responsive, required this.color, required this.text});

  final AppResponsive responsive;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: responsive.w(18),
          height: responsive.w(18),
          margin: EdgeInsets.only(top: responsive.h(1)),
          decoration: ShapeDecoration(
            color: color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
              side: const BorderSide(color: AppColors.border),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.check_rounded,
              size: responsive.text(12),
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        SizedBox(width: responsive.w(12)),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.rolesBenefit(responsive),
          ),
        ),
      ],
    );
  }
}

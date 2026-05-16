import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_images.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: [
                _OnboardingSlide(responsive: responsive, data: _SlideData.first()),
                _OnboardingSlide(responsive: responsive, data: _SlideData.second()),
                _OnboardingSlide(responsive: responsive, data: _SlideData.third()),
                _OnboardingSlide(responsive: responsive, data: _SlideData.fourth()),
              ],
            ),
            Positioned(
              top: responsive.h(16),
              right: responsive.w(24),
              child: GetBuilder<OnboardingController>(
                builder: (controller) => controller.isLastPage
                    ? const SizedBox.shrink()
                    : _SkipChip(
                        responsive: responsive,
                        onTap: controller.skip,
                        label: AppStrings.onboardingSkip,
                      ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  responsive.w(24),
                  0,
                  responsive.w(24),
                  responsive.h(20),
                ),
                child: GetBuilder<OnboardingController>(
                  builder: (controller) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: controller.isLastPage
                        ? _FinalActions(responsive: responsive, controller: controller)
                        : _PagerActions(responsive: responsive, controller: controller),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideData {
  const _SlideData({
    required this.image,
    required this.imageWidth,
    required this.imageHeight,
    required this.title,
    required this.description,
    required this.titleWidth,
    required this.descriptionWidth,
    required this.bottomPadding,
    required this.fit,
  });

  factory _SlideData.first() => const _SlideData(
        image: AppImages.onboarding1,
        imageWidth: 320,
        imageHeight: 250,
        title: AppStrings.onboarding1Title,
        description: AppStrings.onboarding1Description,
        titleWidth: 278,
        descriptionWidth: 278,
        bottomPadding: 150,
        fit: BoxFit.cover,
      );

  factory _SlideData.second() => const _SlideData(
        image: AppImages.onboarding2,
        imageWidth: 309,
        imageHeight: 262,
        title: AppStrings.onboarding2Title,
        description: AppStrings.onboarding2Description,
        titleWidth: 269,
        descriptionWidth: 269,
        bottomPadding: 150,
        fit: BoxFit.cover,
      );

  factory _SlideData.third() => const _SlideData(
        image: AppImages.onboarding3,
        imageWidth: 288,
        imageHeight: 257,
        title: AppStrings.onboarding3Title,
        description: AppStrings.onboarding3Description,
        titleWidth: 282,
        descriptionWidth: 282,
        bottomPadding: 150,
        fit: BoxFit.contain,
      );

  factory _SlideData.fourth() => const _SlideData(
        image: AppImages.onboarding4,
        imageWidth: 320,
        imageHeight: 320,
        title: AppStrings.onboarding4Title,
        description: AppStrings.onboarding4Description,
        titleWidth: 253,
        descriptionWidth: 253,
        bottomPadding: 300,
        fit: BoxFit.contain,
      );

  final String image;
  final double imageWidth;
  final double imageHeight;
  final String title;
  final String description;
  final double titleWidth;
  final double descriptionWidth;
  final double bottomPadding;
  final BoxFit fit;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.responsive, required this.data});

  final AppResponsive responsive;
  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              responsive.w(24),
              responsive.h(48),
              responsive.w(24),
              responsive.h(data.bottomPadding),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: responsive.w(data.imageWidth),
                  height: responsive.h(data.imageHeight),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(responsive.radius(24)),
                    child: Image.asset(data.image, fit: data.fit),
                  ),
                ),
                SizedBox(height: responsive.h(32)),
                SizedBox(
                  width: responsive.w(data.titleWidth),
                  child: Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.onboardingTitle(responsive),
                  ),
                ),
                SizedBox(height: responsive.h(16)),
                SizedBox(
                  width: responsive.w(data.descriptionWidth),
                  child: Text(
                    data.description,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.onboardingDescription(responsive),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipChip extends StatelessWidget {
  const _SkipChip({required this.responsive, required this.label, required this.onTap});

  final AppResponsive responsive;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(16),
          vertical: responsive.h(8),
        ),
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
        child: Text(label, style: AppTextStyles.onboardingSkip(responsive)),
      ),
    );
  }
}

class _PagerActions extends StatelessWidget {
  const _PagerActions({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DotsRow(responsive: responsive, activeIndex: controller.currentPage.value, count: 3),
        SizedBox(height: responsive.h(32)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavCircleButton(
              responsive: responsive,
              icon: Icons.arrow_back_ios_new_rounded,
              enabled: !controller.isFirstPage,
              onTap: controller.previousPage,
            ),
            _NavCircleButton(
              responsive: responsive,
              icon: Icons.arrow_forward_ios_rounded,
              enabled: true,
              onTap: controller.nextPage,
              filled: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _FinalActions extends StatelessWidget {
  const _FinalActions({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          responsive: responsive,
          label: AppStrings.onboarding4CreateAccount,
          onTap: controller.createAccount,
        ),
        SizedBox(height: responsive.h(12)),
        _ActionButton(
          responsive: responsive,
          label: AppStrings.onboarding4Login,
          onTap: controller.login,
        ),
      ],
    );
  }
}

class _DotsRow extends StatelessWidget {
  const _DotsRow({required this.responsive, required this.activeIndex, required this.count});

  final AppResponsive responsive;
  final int activeIndex;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == activeIndex;
        final double size = isActive ? responsive.w(14) : responsive.w(12);
        final Color color = isActive ? AppColors.primary : const Color(0xFFD1D5DB);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: size,
              height: size,
              decoration: ShapeDecoration(
                color: color,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: AppColors.border),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            if (index < count - 1) SizedBox(width: responsive.w(23)),
          ],
        );
      }),
    );
  }
}

class _NavCircleButton extends StatelessWidget {
  const _NavCircleButton({
    required this.responsive,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.filled = false,
  });

  final AppResponsive responsive;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color fillColor = filled ? AppColors.primary : Colors.white;
    final Color borderColor = enabled ? (filled ? AppColors.primary : const Color(0xFFD1D5DB)) : const Color(0xFFD1D5DB);
    final Color iconColor = enabled ? (filled ? Colors.white : const Color(0xFFD1D5DB)) : const Color(0xFFD1D5DB);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.50,
        child: Container(
          width: responsive.w(48),
          height: responsive.w(48),
          decoration: ShapeDecoration(
            color: fillColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: responsive.w(2), color: borderColor),
              borderRadius: BorderRadius.circular(9999),
            ),
            shadows: filled
                ? const [
                    BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
                    BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
                  ]
                : const [],
          ),
          child: Icon(icon, size: responsive.text(18), color: iconColor),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.responsive, required this.label, required this.onTap});

  final AppResponsive responsive;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: responsive.w(32),
          vertical: responsive.h(16),
        ),
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.border),
            borderRadius: BorderRadius.circular(responsive.radius(16)),
          ),
          shadows: const [
            BoxShadow(color: Color(0x19000000), blurRadius: 15, offset: Offset(0, 10)),
            BoxShadow(color: Color(0x19000000), blurRadius: 6, offset: Offset(0, 4)),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.onboardingButton(responsive),
        ),
      ),
    );
  }
}
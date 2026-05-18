import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_images.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
        backgroundColor: AppColors.white,
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
                right: responsive.w(16),
                child: Material(
                  color: AppColors.white,
                  child: GetBuilder<OnboardingController>(
                    builder: (controller) {
                      if (controller.isLastPage) {
                        return const SizedBox.shrink();
                      }

                      return AppChipButton(
                        responsive: responsive,
                        label: AppStrings.onboardingSkip,
                        onTap: controller.skip,
                      );
                    },
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
            AppCircularButton(
              responsive: responsive,
              icon: Icons.arrow_back_ios_new_rounded,
              enabled: !controller.isFirstPage,
              onTap: controller.previousPage,
            ),
            AppCircularButton(
              responsive: responsive,
              icon: Icons.arrow_forward_ios_rounded,
              enabled: true,
              filled: true,
              onTap: controller.nextPage,
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
        AppPrimaryButton(
          responsive: responsive,
          label: AppStrings.onboarding4CreateAccount,
          onTap: controller.createAccount,
        ),
        SizedBox(height: responsive.h(12)),
        AppPrimaryButton(
          responsive: responsive,
          label: AppStrings.onboarding4Login,
          onTap: controller.login,
          backgroundColor: AppColors.white,
          textColor: AppColors.primary,
          borderColor: AppColors.border,
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
            final Color color = isActive ? AppColors.primary : AppColors.borderStrong;
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

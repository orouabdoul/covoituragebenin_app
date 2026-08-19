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
            PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: OnboardingController.pagesCount,
              itemBuilder: (context, index) => _OnboardingSlide(
                responsive: responsive,
                data: _slides[index],
              ),
            ),
            Positioned(
              top: responsive.h(16),
              right: responsive.w(16),
              child: Material(
                color: Colors.transparent,
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

// ── Données d'un slide ────────────────────────────────────────────────────────

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
    required this.bgTop,
    required this.bgBottom,
    required this.imageBg,
    required this.tintColor,
  });

  final String image;
  final double imageWidth;
  final double imageHeight;
  final String title;
  final String description;
  final double titleWidth;
  final double descriptionWidth;
  final double bottomPadding;
  final BoxFit fit;

  final Color bgTop;
  final Color bgBottom;
  final Color imageBg;

  /// Teinte appliquée sur l'image via ColorFiltered + BlendMode.multiply.
  /// Blanc de l'illustration → tintColor. Couleurs → légèrement décalées.
  final Color tintColor;
}

// ── Slides de l'onboarding ────────────────────────────────────────────────────
// Couleurs : 30 % du brand color mélangé au blanc → clairement visible.
//   Slide 1+2 → Bleu primaire  #1A5FB4  → tint #BAD0E9
//   Slide 3   → Ambre warning  #F5A623  → tint #FCE5BD
//   Slide 4   → Turquoise      #17A398  → tint #B9E6E4

const List<_SlideData> _slides = [
  _SlideData(
    image: AppImages.onboarding1,
    imageWidth: 320,
    imageHeight: 250,
    title: AppStrings.onboarding1Title,
    description: AppStrings.onboarding1Description,
    titleWidth: 278,
    descriptionWidth: 278,
    bottomPadding: 150,
    fit: BoxFit.cover,
    bgTop: AppColors.onboardingBlue,
    bgBottom: AppColors.white,
    imageBg: AppColors.onboardingBlue,
    tintColor: AppColors.onboardingBlue,
  ),
  _SlideData(
    image: AppImages.onboarding2,
    imageWidth: 309,
    imageHeight: 262,
    title: AppStrings.onboarding2Title,
    description: AppStrings.onboarding2Description,
    titleWidth: 269,
    descriptionWidth: 269,
    bottomPadding: 150,
    fit: BoxFit.cover,
    bgTop: AppColors.onboardingBlue,
    bgBottom: AppColors.white,
    imageBg: AppColors.onboardingBlue,
    tintColor: AppColors.onboardingBlue,
  ),
  _SlideData(
    image: AppImages.onboarding3,
    imageWidth: 288,
    imageHeight: 257,
    title: AppStrings.onboarding3Title,
    description: AppStrings.onboarding3Description,
    titleWidth: 282,
    descriptionWidth: 282,
    bottomPadding: 150,
    fit: BoxFit.contain,
    bgTop: AppColors.onboardingAmber,
    bgBottom: AppColors.white,
    imageBg: AppColors.onboardingAmber,
    tintColor: AppColors.onboardingAmber,
  ),
  _SlideData(
    image: AppImages.onboarding4,
    imageWidth: 320,
    imageHeight: 320,
    title: AppStrings.onboarding4Title,
    description: AppStrings.onboarding4Description,
    titleWidth: 253,
    descriptionWidth: 253,
    bottomPadding: 300,
    fit: BoxFit.contain,
    bgTop: AppColors.onboardingTeal,
    bgBottom: AppColors.white,
    imageBg: AppColors.onboardingTeal,
    tintColor: AppColors.onboardingTeal,
  ),
];

// ── Slide ─────────────────────────────────────────────────────────────────────

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({required this.responsive, required this.data});

  final AppResponsive responsive;
  final _SlideData data;

  @override
  Widget build(BuildContext context) {
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final int cacheWidth = (responsive.w(data.imageWidth) * pixelRatio).round() > 512
        ? 512
        : (responsive.w(data.imageWidth) * pixelRatio).round();
    final int cacheHeight = (responsive.h(data.imageHeight) * pixelRatio).round() > 512
        ? 512
        : (responsive.h(data.imageHeight) * pixelRatio).round();

    return Stack(
      children: [
        // ── Fond dégradé (couleur charte → blanc) ──────────────────────────
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.55, 1.0],
                colors: [
                  data.bgTop,
                  data.bgTop.withValues(alpha: 0.4),
                  data.bgBottom,
                ],
              ),
            ),
          ),
        ),

        // ── Contenu du slide ───────────────────────────────────────────────
        SafeArea(
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
                    // ── Image avec fond de couleur ─────────────────────────
                    Container(
                      width: responsive.w(data.imageWidth),
                      height: responsive.h(data.imageHeight),
                      decoration: BoxDecoration(
                        color: data.imageBg,
                        borderRadius: BorderRadius.circular(responsive.radius(24)),
                        boxShadow: [
                          BoxShadow(
                            color: data.bgTop.withValues(alpha: 0.5),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(responsive.radius(24)),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            data.tintColor,
                            BlendMode.multiply,
                          ),
                          child: Image.asset(
                            data.image,
                            fit: data.fit,
                            cacheWidth: cacheWidth,
                            cacheHeight: cacheHeight,
                            filterQuality: FilterQuality.low,
                          ),
                        ),
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
        ),
      ],
    );
  }
}

// ── Actions bas de page ───────────────────────────────────────────────────────

class _PagerActions extends StatelessWidget {
  const _PagerActions({required this.responsive, required this.controller});

  final AppResponsive responsive;
  final OnboardingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _DotsRow(
          responsive: responsive,
          activeIndex: controller.currentPage.value,
          count: OnboardingController.pagesCount,
        ),
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
        _DotsRow(
          responsive: responsive,
          activeIndex: controller.currentPage.value,
          count: OnboardingController.pagesCount,
        ),
        SizedBox(height: responsive.h(24)),
        AppPrimaryButton(
          responsive: responsive,
          label: AppStrings.onboarding4Start,
          onTap: controller.start,
        ),
      ],
    );
  }
}

// ── Points de pagination ──────────────────────────────────────────────────────

class _DotsRow extends StatelessWidget {
  const _DotsRow({
    required this.responsive,
    required this.activeIndex,
    required this.count,
  });

  final AppResponsive responsive;
  final int activeIndex;
  final int count;

  /// Couleur active = couleur primaire du slide courant
  static const _dotColors = [
    AppColors.primary,    // slide 1 → bleu
    AppColors.primary,    // slide 2 → bleu
    AppColors.warning,    // slide 3 → ambre
    AppColors.success,    // slide 4 → turquoise
  ];

  @override
  Widget build(BuildContext context) {
    final activeColor = activeIndex < _dotColors.length
        ? _dotColors[activeIndex]
        : AppColors.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final bool isActive = index == activeIndex;
        final double width  = isActive ? responsive.w(24) : responsive.w(12);
        final double height = responsive.w(12);
        final Color  color  = isActive ? activeColor : AppColors.borderStrong;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: width,
          height: height,
          margin: EdgeInsets.only(
            right: index < count - 1 ? responsive.w(8) : 0,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(9999),
          ),
        );
      }),
    );
  }
}

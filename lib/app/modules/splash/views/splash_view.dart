import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_images.dart';
import 'package:covoiturage_benin_app/app/core/utils/loading_indicator.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_strings.dart';
import 'package:covoiturage_benin_app/app/modules/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: responsive.maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.w(28),
                  vertical: responsive.h(24),
                ),
                child: Obx(
                  () => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AnimatedOpacity(
                        opacity: controller.isLogoVisible.value ? 1 : 0,
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        child: AnimatedScale(
                          scale: controller.isLogoVisible.value ? 1 : 0.88,
                          duration: const Duration(milliseconds: 450),
                          curve: Curves.easeOutBack,
                          child: _LogoBlock(responsive: responsive),
                        ),
                      ),
                      SizedBox(height: responsive.h(32)),
                      AnimatedSlide(
                        offset: controller.isBrandVisible.value ? Offset.zero : const Offset(0, 0.08),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: controller.isBrandVisible.value ? 1 : 0,
                          duration: const Duration(milliseconds: 450),
                          child: _BrandBlock(responsive: responsive),
                        ),
                      ),
                      SizedBox(height: responsive.h(32)),
                      AnimatedSlide(
                        offset: controller.isContentVisible.value ? Offset.zero : const Offset(0, 0.10),
                        duration: const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: controller.isContentVisible.value ? 1 : 0,
                          duration: const Duration(milliseconds: 450),
                          child: _IllustrationBlock(responsive: responsive),
                        ),
                      ),
                      SizedBox(height: responsive.h(32)),
                      AnimatedOpacity(
                        opacity: controller.isContentVisible.value ? 1 : 0,
                        duration: const Duration(milliseconds: 550),
                        child: _TextBlock(
                          responsive: responsive,
                          splashController: controller,
                        ),
                      ),
                    ],
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

class _LogoBlock extends StatelessWidget {
  const _LogoBlock({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: responsive.w(32)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: responsive.h(24)),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: responsive.w(128),
                  height: responsive.h(128),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.w(41),
                    vertical: responsive.h(40),
                  ),
                  decoration: ShapeDecoration(
                        color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(responsive.radius(24)),
                    ),
                    shadows: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 50,
                        offset: Offset(0, 25),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'M',
                      style: AppTextStyles.splashBrand(responsive).copyWith(color: AppColors.primary, fontSize: responsive.text(48)),
                    ),
                  ),
                ),
                Positioned(
                  left: responsive.w(104),
                  top: responsive.h(-13.48),
                  child: Container(
                    width: responsive.w(32),
                    height: responsive.h(32),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.w(9),
                      vertical: responsive.h(6),
                    ),
                    decoration: ShapeDecoration(
                      color: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                    child: Container(
                      width: responsive.w(14),
                      padding: EdgeInsets.symmetric(vertical: responsive.h(3)),
                      child: Container(
                        width: responsive.w(14),
                        height: responsive.h(14),
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(),
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandBlock extends StatelessWidget {
  const _BrandBlock({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: responsive.w(191),
          child: Text(
            AppStrings.appName,
            textAlign: TextAlign.center,
              style: AppTextStyles.splashBrand(responsive),
          ),
        ),
        SizedBox(height: responsive.h(16)),
        Container(
          width: responsive.w(64),
          height: responsive.h(4),
          decoration: ShapeDecoration(
            color: AppColors.accent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
        ),
      ],
    );
  }
}

class _IllustrationBlock extends StatelessWidget {
  const _IllustrationBlock({required this.responsive});

  final AppResponsive responsive;

  @override
  Widget build(BuildContext context) {
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final int cacheWidth = (responsive.w(192) * pixelRatio).round();
    final int cacheHeight = (responsive.h(158) * pixelRatio).round();

    return Opacity(
      opacity: 0.90,
      child: Container(
        width: responsive.w(192),
        height: responsive.h(158),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius(16)),
          ),
          image: DecorationImage(
            image: ResizeImage(
              const AssetImage(AppImages.splash),
              width: cacheWidth,
              height: cacheHeight,
            ),
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.responsive, required this.splashController});

  final AppResponsive responsive;
  final SplashController splashController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: responsive.w(190),
          child: Text(
            AppStrings.splashSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.splashTagline(responsive),
          ),
        ),
        Text(
          AppStrings.splashSubtitleHighlight,
          textAlign: TextAlign.center,
          style: AppTextStyles.splashHighlight(responsive),
        ),
        SizedBox(height: responsive.h(24)),
        Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: 0.92 + (splashController.loadingProgress.value * 0.05),
                child: SizedBox(
                  width: responsive.w(58),
                  height: responsive.h(58),
                  child: const LoadingIndicator(color: AppColors.white),
                ),
              ),
              SizedBox(height: responsive.h(11)),
              Text(
                AppStrings.splashLoading,
                textAlign: TextAlign.center,
                style: AppTextStyles.splashLoading(responsive),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
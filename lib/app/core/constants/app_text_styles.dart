import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_responsive.dart';

class AppTextStyles {
  static const String _fontFamily = 'Inter';

  static TextStyle onboardingSkip(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF9CA3AF),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }

  static TextStyle onboardingTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(30),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.27,
      letterSpacing: -0.50,
    );
  }

  static TextStyle onboardingDescription(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.67,
      letterSpacing: -0.50,
    );
  }

  static TextStyle onboardingButton(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.primary,
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.56,
      letterSpacing: -0.50,
    );
  }

  static TextStyle splashBrand(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white,
      fontSize: responsive.text(36),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w900,
      height: 1.11,
      letterSpacing: -0.70,
    );
  }

  static TextStyle splashTagline(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.90),
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.67,
      letterSpacing: -0.50,
    );
  }

  static TextStyle splashHighlight(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.accent,
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.67,
      letterSpacing: -0.50,
    );
  }

  static TextStyle splashLoading(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.70),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }
}
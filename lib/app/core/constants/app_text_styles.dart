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

  static TextStyle rolesTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(24),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.33,
      letterSpacing: -0.50,
    );
  }

  static TextStyle rolesSubtitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.63,
      letterSpacing: -0.50,
    );
  }

  static TextStyle rolesCardTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(20),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.40,
      letterSpacing: -0.50,
    );
  }

  static TextStyle rolesBenefit(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF374151),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.57,
      letterSpacing: -0.50,
    );
  }

  static TextStyle rolesButton(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white,
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle registerHero(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(28),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w800,
      height: 1.21,
      letterSpacing: -0.70,
    );
  }

  static TextStyle registerBrand(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.primary,
      fontSize: responsive.text(28),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w900,
      height: 1.21,
      letterSpacing: -0.70,
    );
  }

  static TextStyle registerTagline(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF6B7280),
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle registerSection(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF374151),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }

  static TextStyle registerBody(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF374151),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.57,
      letterSpacing: -0.50,
    );
  }

  static TextStyle registerLabel(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF6B7280),
      fontSize: responsive.text(12),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle registerField(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(24),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.33,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpBody(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.63,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpPhone(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.primary,
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.63,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpDigit(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(24),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.33,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpHint(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF6B7280),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.57,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpCountdown(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.primary,
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.57,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpSecurity(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.primary,
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpSecurityTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }

  static TextStyle otpSecurityBody(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: responsive.text(12),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.67,
      letterSpacing: -0.50,
    );
  }

  static TextStyle profileSectionTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.56,
      letterSpacing: -0.50,
    );
  }

  static TextStyle profileSectionLabel(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF374151),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }

  static TextStyle profileFieldValue(AppResponsive responsive) {
    return TextStyle(
      color: Colors.black,
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle profileHeroTitle(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white,
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.56,
      letterSpacing: -0.50,
    );
  }

  static TextStyle profileHeroSubtitle(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.90),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }

  static TextStyle profileMeta(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }

  static TextStyle homeHeroTitle(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white,
      fontSize: responsive.text(20),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.40,
      letterSpacing: -0.50,
    );
  }

  static TextStyle homeMetricLabel(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white.withValues(alpha: 0.80),
      fontSize: responsive.text(10),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle homeMetricValue(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white,
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle homeSectionTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.50,
      letterSpacing: -0.50,
    );
  }

  static TextStyle homeCardTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }

  static TextStyle homeCardBody(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF6B7280),
      fontSize: responsive.text(12),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.33,
      letterSpacing: -0.50,
    );
  }

  static TextStyle homePrice(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.primary,
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.56,
      letterSpacing: -0.50,
    );
  }

  static TextStyle homeAction(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.primary,
      fontSize: responsive.text(12),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.33,
      letterSpacing: -0.50,
    );
  }

  static TextStyle body(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF374151),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.64,
      letterSpacing: -0.50,
    );
  }

  // Convenience / legacy mappings used across views
  static TextStyle title(AppResponsive responsive) => profileSectionTitle(responsive);

  static TextStyle sectionTitle(AppResponsive responsive) => profileSectionTitle(responsive);

  static TextStyle subtitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.35,
      letterSpacing: -0.50,
    );
  }

  static TextStyle muted(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF6B7280),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.43,
      letterSpacing: -0.50,
    );
  }

  static TextStyle price(AppResponsive responsive) => homePrice(responsive);

  static TextStyle button(AppResponsive responsive) {
    return TextStyle(
      color: Colors.white,
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.20,
      letterSpacing: -0.50,
    );
  }

  // ── Heading scale ──────────────────────────────────────────────────────────

  static TextStyle h2(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111827),
      fontSize: responsive.text(28),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w800,
      height: 1.25,
      letterSpacing: -0.70,
    );
  }

  static TextStyle h3(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111827),
      fontSize: responsive.text(24),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.30,
      letterSpacing: -0.60,
    );
  }

  static TextStyle h4(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111827),
      fontSize: responsive.text(20),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.35,
      letterSpacing: -0.50,
    );
  }

  static TextStyle h5(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111827),
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.40,
      letterSpacing: -0.50,
    );
  }

  // ── Body scale ─────────────────────────────────────────────────────────────

  static TextStyle bodyMedium(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111827),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.50,
      letterSpacing: -0.30,
    );
  }

  static TextStyle bodySmall(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF374151),
      fontSize: responsive.text(12),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: -0.20,
    );
  }

  static TextStyle labelSmall(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF6B7280),
      fontSize: responsive.text(11),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.45,
      letterSpacing: 0.0,
    );
  }

  static TextStyle caption(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF6B7280),
      fontSize: responsive.text(12),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: -0.20,
    );
  }

  static TextStyle rolesSecondaryAction(AppResponsive responsive) {
    return TextStyle(
      color: AppColors.primary,
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.43,
      letterSpacing: -0.30,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary,
    );
  }

  static TextStyle rolesCardDescription(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.57,
      letterSpacing: -0.30,
    );
  }

  static TextStyle rolesCardTitle2(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.40,
      letterSpacing: -0.50,
    );
  }

  static TextStyle chip(AppResponsive responsive) {
    return TextStyle(
      fontSize: responsive.text(13),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.40,
      letterSpacing: -0.30,
    );
  }

  static TextStyle h6(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111827),
      fontSize: responsive.text(16),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w600,
      height: 1.45,
      letterSpacing: -0.40,
    );
  }

  static TextStyle registerSectionTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.44,
      letterSpacing: -0.50,
    );
  }

  static TextStyle registerHeroTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(26),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w800,
      height: 1.23,
      letterSpacing: -0.60,
    );
  }

  static TextStyle registerHelp(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.57,
      letterSpacing: -0.30,
    );
  }

  static TextStyle registerMuted(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF9CA3AF),
      fontSize: responsive.text(13),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: -0.20,
    );
  }

  static TextStyle dialogTitle(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF111111),
      fontSize: responsive.text(18),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w700,
      height: 1.40,
      letterSpacing: -0.50,
    );
  }

  static TextStyle dialogBody(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF4B5563),
      fontSize: responsive.text(14),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.57,
      letterSpacing: -0.30,
    );
  }

  static TextStyle dialogHint(AppResponsive responsive) {
    return TextStyle(
      color: const Color(0xFF9CA3AF),
      fontSize: responsive.text(12),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w400,
      height: 1.50,
      letterSpacing: -0.20,
    );
  }

  static TextStyle bottomNavLabel(AppResponsive responsive, {required Color color, required FontWeight fontWeight}) {
    return TextStyle(
      fontSize: responsive.text(10),
      fontFamily: _fontFamily,
      fontWeight: FontWeight.w500,
      height: 1.40,
      letterSpacing: 0.0,
    );
  }
}

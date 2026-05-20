import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.responsive,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  final AppResponsive responsive;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final Color resolvedBackgroundColor = enabled
        ? (backgroundColor ?? AppColors.primary)
        : (backgroundColor ?? const Color(0xFFD1D5DB));
    final Color resolvedTextColor = enabled
        ? (textColor ?? Colors.white)
        : (textColor ?? const Color(0xFF6B7280));
    final Color resolvedBorderColor = borderColor ?? (enabled ? resolvedBackgroundColor : AppColors.border);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(borderRadius ?? responsive.radius(16)),
        child: Container(
          width: double.infinity,
          height: height ?? responsive.h(56),
          padding: EdgeInsets.symmetric(horizontal: responsive.w(24)),
          decoration: ShapeDecoration(
            color: resolvedBackgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? responsive.radius(16)),
              side: BorderSide(color: resolvedBorderColor),
            ),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: resolvedTextColor,
                fontSize: responsive.text(18),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                height: 1.56,
                letterSpacing: -0.50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppCircularButton extends StatelessWidget {
  const AppCircularButton({
    super.key,
    required this.responsive,
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.filled = false,
    this.size,
  });

  final AppResponsive responsive;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final bool filled;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final Color fillColor = filled ? AppColors.primary : Colors.white;
    final Color borderColor = enabled
        ? (filled ? AppColors.primary : const Color(0xFFD1D5DB))
        : const Color(0xFFD1D5DB);
    final Color iconColor = enabled
        ? (filled ? Colors.white : const Color(0xFFD1D5DB))
        : const Color(0xFFD1D5DB);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(9999),
        child: Opacity(
          opacity: enabled ? 1 : 0.50,
          child: Container(
            width: size ?? responsive.w(48),
            height: size ?? responsive.w(48),
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
      ),
    );
  }
}

class AppChipButton extends StatelessWidget {
  const AppChipButton({
    super.key,
    required this.responsive,
    required this.label,
    required this.onTap,
    this.height,
    this.borderRadius,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.shadows,
  });

  final AppResponsive responsive;
  final String label;
  final VoidCallback onTap;
  final double? height;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 9999),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(
            horizontal: responsive.w(16),
            vertical: responsive.h(8),
          ),
          decoration: ShapeDecoration(
            color: backgroundColor ?? Colors.transparent,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: borderColor ?? AppColors.border),
              borderRadius: BorderRadius.circular(borderRadius ?? 9999),
            ),
            shadows: shadows ?? const [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: textColor ?? const Color(0xFF9CA3AF),
              fontSize: responsive.text(14),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 1.43,
              letterSpacing: -0.50,
            ),
          ),
        ),
      ),
    );
  }
}

class AppTextButton extends StatelessWidget {
  const AppTextButton({
    super.key,
    required this.responsive,
    required this.label,
    required this.onTap,
    this.underlined = false,
    this.textColor,
    this.fontWeight,
  });

  final AppResponsive responsive;
  final String label;
  final VoidCallback onTap;
  final bool underlined;
  final Color? textColor;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: responsive.h(8)),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textColor ?? const Color(0xFF6B7280),
              fontSize: responsive.text(14),
              fontFamily: 'Inter',
              fontWeight: fontWeight ?? FontWeight.w400,
              decoration: underlined ? TextDecoration.underline : TextDecoration.none,
              height: 1.43,
              letterSpacing: -0.50,
            ),
          ),
        ),
      ),
    );
  }
}

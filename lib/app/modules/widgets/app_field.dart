import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:flutter/material.dart';

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.responsive,
    required this.label,
    this.child,
    this.controller,
    this.hintText,
    this.keyboardType,
    this.textStyle,
    this.hintStyle,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.onTap,
    this.helperText,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.labelStyle,
    this.helperStyle,
  });

  final AppResponsive responsive;
  final String label;
  final Widget? child;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final bool readOnly;
  final bool obscureText;
  final int? maxLines;
  final VoidCallback? onTap;
  final String? helperText;
  final double? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final TextStyle? labelStyle;
  final TextStyle? helperStyle;

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? responsive.radius(16);
    final Color resolvedBackgroundColor = backgroundColor ?? const Color(0xFFF5F5F5);
    final Color resolvedBorderColor = borderColor ?? AppColors.border;
    final Widget resolvedChild = child ?? TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: textStyle,
      readOnly: readOnly,
      obscureText: obscureText,
      maxLines: maxLines,
      onTap: onTap,
      decoration: InputDecoration.collapsed(
        hintText: hintText,
        hintStyle: hintStyle,
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: labelStyle),
        SizedBox(height: responsive.h(8)),
        Container(
          width: double.infinity,
          padding: padding ?? EdgeInsets.all(responsive.w(16)),
          decoration: ShapeDecoration(
            color: resolvedBackgroundColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: resolvedBorderColor),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: resolvedChild,
        ),
        if (helperText != null) ...[
          SizedBox(height: responsive.h(8)),
          Text(helperText!, style: helperStyle),
        ],
      ],
    );
  }
}
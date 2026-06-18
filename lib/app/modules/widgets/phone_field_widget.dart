import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneFieldWidget extends StatelessWidget {
  const PhoneFieldWidget({
    super.key,
    required this.responsive,
    required this.controller,
    required this.label,
    this.helperText,
    this.helperStyle,
    this.labelStyle,
    this.backgroundColor,
    this.borderColor,
  });

  final AppResponsive responsive;
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final TextStyle? helperStyle;
  final TextStyle? labelStyle;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return AppField(
      responsive: responsive,
      label: label,
      labelStyle: labelStyle,
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      helperText: helperText,
      helperStyle: helperStyle,
      padding: EdgeInsets.symmetric(
        horizontal: responsive.w(12),
        vertical: responsive.h(10),
      ),
      child: Row(
        children: [
          // Country code badge (Bénin only for now)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.w(8),
              vertical: responsive.h(5),
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(responsive.radius(8)),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '🇧🇯',
                  style: TextStyle(fontSize: responsive.text(15)),
                ),
                SizedBox(width: responsive.w(4)),
                Text(
                  '+229',
                  style: AppTextStyles.profileFieldValue(responsive).copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: responsive.w(2)),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: responsive.text(14),
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
          SizedBox(width: responsive.w(10)),
          Container(width: 1, height: responsive.h(22), color: AppColors.border),
          SizedBox(width: responsive.w(10)),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: AppTextStyles.profileFieldValue(responsive),
              decoration: InputDecoration.collapsed(
                hintText: '01 97 45 67 89',
                hintStyle: AppTextStyles.profileFieldValue(responsive)
                    .copyWith(color: AppColors.textGhost),
              ),
              buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            ),
          ),
        ],
      ),
    );
  }
}

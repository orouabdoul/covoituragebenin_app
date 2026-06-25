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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Country code badge — Bénin (+229) par défaut
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
          // Input : 10 chiffres, doit commencer par "01"
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [_PhoneOhOnePrefixFormatter()],
              style: AppTextStyles.profileFieldValue(responsive),
              decoration: InputDecoration.collapsed(
                hintText: '01 97 45 67 89',
                hintStyle: AppTextStyles.profileFieldValue(responsive)
                    .copyWith(color: AppColors.textGhost),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Formateur qui force le numéro à commencer par "01" et limite à 10 chiffres.
/// L'utilisateur ne peut pas modifier ni supprimer les deux premiers caractères "01".
class _PhoneOhOnePrefixFormatter extends TextInputFormatter {
  static const _prefix = '01';

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Supprimer tout caractère non numérique
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Forcer le préfixe "01"
    if (text.length < 2) {
      text = _prefix;
    } else if (!text.startsWith(_prefix)) {
      text = _prefix + (text.length > 2 ? text.substring(2) : '');
    }

    // Maximum 10 chiffres
    if (text.length > 10) text = text.substring(0, 10);

    // Le curseur ne peut pas aller avant la position 2 (protection du "01")
    final int cursor = newValue.selection.end.clamp(2, text.length);

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}

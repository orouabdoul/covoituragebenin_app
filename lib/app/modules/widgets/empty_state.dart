import 'package:flutter/material.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'app_button.dart';

/// Widget d'état vide réutilisable — emoji/icon + titre + message + CTA optionnel.
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.ctaLabel,
    this.onCta,
    this.iconBgColor,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String? ctaLabel;
  final VoidCallback? onCta;
  final Color? iconBgColor;

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: r.w(32),
          vertical: r.h(40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: r.w(100),
              height: r.w(100),
              decoration: BoxDecoration(
                color: iconBgColor ?? AppColors.surfaceAccent,
                borderRadius: BorderRadius.circular(r.radius(28)),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: TextStyle(fontSize: r.text(46)),
                ),
              ),
            ),
            SizedBox(height: r.h(24)),
            Text(
              title,
              style: AppTextStyles.h5(r),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: r.h(8)),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall(r)
                  .copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
            if (ctaLabel != null && onCta != null) ...[
              SizedBox(height: r.h(28)),
              AppPrimaryButton(
                responsive: r,
                label: ctaLabel!,
                onTap: onCta!,
                height: r.adaptive(phone: 50, smallPhone: 46, tablet: 52, desktop: 52),
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
                borderRadius: r.radius(14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

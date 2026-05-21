import 'package:flutter/material.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import '../controllers/botton_nav_controller.dart';

class BottonNavHeader extends StatelessWidget {
  const BottonNavHeader({super.key, required this.responsive, required this.controller});

  final AppResponsive responsive;
  final BottonNavController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(16)),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(responsive.radius(16)),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(color: AppColors.shadowSoft, blurRadius: 4, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: responsive.w(22),
                backgroundColor: AppColors.white,
                child: ClipOval(
                  child: Image.network(
                    'https://placehold.co/44x44.png',
                    width: responsive.w(44),
                    height: responsive.w(44),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.person_outline_rounded,
                      size: responsive.text(22),
                      color: AppColors.textGhost,
                    ),
                  ),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Bonjour Abdoulaye 👋', style: AppTextStyles.h6(responsive)),
                  SizedBox(height: responsive.h(4)),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: responsive.text(14), color: AppColors.textHint),
                      SizedBox(width: responsive.w(4)),
                      Text('Cotonou', style: AppTextStyles.caption(responsive)),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Right actions
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(9999),
                    onTap: () {},
                    child: Container(
                      width: responsive.w(40),
                      height: responsive.w(40),
                      padding: EdgeInsets.symmetric(horizontal: responsive.w(8), vertical: responsive.h(6)),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Icon(Icons.notifications_none_rounded, size: responsive.text(18), color: AppColors.textSecondary),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      width: responsive.w(8),
                      height: responsive.w(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE53935),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

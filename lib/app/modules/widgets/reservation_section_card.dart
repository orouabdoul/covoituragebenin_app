import 'package:flutter/material.dart';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';

class ReservationSectionCard extends StatelessWidget {
  const ReservationSectionCard({
    super.key,
    required this.responsive,
    required this.child,
  });

  final AppResponsive responsive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        responsive.adaptive(
          phone: 20,
          smallPhone: 18,
          tablet: 20,
          desktop: 20,
        ),
      ),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

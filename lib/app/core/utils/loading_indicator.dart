import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.color= AppColors.primary});

  final Color color ;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(color),
        strokeCap: StrokeCap.round,
      ),
    );
  }
}
import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/core/services/face_verification_service.dart';
import 'package:flutter/material.dart';

class FaceVerificationSection extends StatelessWidget {
  const FaceVerificationSection({
    super.key,
    required this.responsive,
    required this.hasSelfie,
    required this.hasCni,
    required this.status,
    required this.message,
    required this.score,
    required this.onVerify,
  });

  final AppResponsive responsive;
  final bool hasSelfie;
  final bool hasCni;
  final VerificationStatus status;
  final String message;
  final double score;
  final VoidCallback onVerify;

  bool get _canVerify => hasSelfie && hasCni;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(responsive.w(24)),
      decoration: ShapeDecoration(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: AppColors.surfaceSoft),
          borderRadius: BorderRadius.circular(responsive.radius(24)),
        ),
        shadows: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 15, offset: Offset(0, 10)),
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: responsive.w(40),
                height: responsive.w(40),
                decoration: ShapeDecoration(
                  color: AppColors.surfaceAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.radius(12)),
                  ),
                ),
                child: Icon(
                  Icons.face_retouching_natural_rounded,
                  color: AppColors.primary,
                  size: responsive.text(18),
                ),
              ),
              SizedBox(width: responsive.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vérification d\'identité',
                      style: AppTextStyles.profileSectionTitle(responsive),
                    ),
                    SizedBox(height: responsive.h(2)),
                    Text(
                      'Comparaison selfie vs CNI par IA',
                      style: AppTextStyles.profileMeta(responsive),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: responsive.h(20)),

          // Prerequisites checklist
          _PrerequisiteRow(
            responsive: responsive,
            icon: Icons.camera_front_rounded,
            label: 'Selfie (face avant)',
            met: hasSelfie,
          ),
          SizedBox(height: responsive.h(10)),
          _PrerequisiteRow(
            responsive: responsive,
            icon: Icons.credit_card_rounded,
            label: 'CNI recto uploadée',
            met: hasCni,
          ),

          // Result card
          if (status == VerificationStatus.success ||
              status == VerificationStatus.failure ||
              status == VerificationStatus.error) ...[
            SizedBox(height: responsive.h(16)),
            _ResultCard(
              responsive: responsive,
              status: status,
              message: message,
              score: score,
            ),
          ],

          SizedBox(height: responsive.h(20)),

          // Action button
          _VerifyButton(
            responsive: responsive,
            status: status,
            enabled: _canVerify,
            onVerify: onVerify,
          ),
        ],
      ),
    );
  }
}

// ── Prerequisite row ──────────────────────────────────────────────────────────

class _PrerequisiteRow extends StatelessWidget {
  const _PrerequisiteRow({
    required this.responsive,
    required this.icon,
    required this.label,
    required this.met,
  });

  final AppResponsive responsive;
  final IconData icon;
  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: responsive.w(28),
          height: responsive.w(28),
          decoration: ShapeDecoration(
            color: met ? AppColors.successLight : AppColors.surfaceMuted,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(8)),
            ),
          ),
          child: Icon(
            met ? Icons.check_rounded : icon,
            size: responsive.text(14),
            color: met ? AppColors.success : AppColors.textGhost,
          ),
        ),
        SizedBox(width: responsive.w(10)),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.profileMeta(responsive).copyWith(
              color: met ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: met ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          met ? 'Prêt' : 'En attente',
          style: AppTextStyles.profileMeta(responsive).copyWith(
            color: met ? AppColors.success : AppColors.textGhost,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ── Result card ───────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.responsive,
    required this.status,
    required this.message,
    required this.score,
  });

  final AppResponsive responsive;
  final VerificationStatus status;
  final String message;
  final double score;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == VerificationStatus.success;
    const warningBg = Color(0xFFFFF8E1);
    const warningBorder = Color(0xFFFFE082);
    const warningText = Color(0xFFE65100);

    final bgColor = isSuccess ? AppColors.successLight : warningBg;
    final borderColor =
        isSuccess ? AppColors.success.withValues(alpha: 0.3) : warningBorder;
    final textColor = isSuccess ? AppColors.success : warningText;
    final iconData =
        isSuccess ? Icons.verified_rounded : Icons.warning_amber_rounded;

    return Container(
      padding: EdgeInsets.all(responsive.w(14)),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(responsive.radius(14)),
          side: BorderSide(color: borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(iconData, color: textColor, size: responsive.text(20)),
              SizedBox(width: responsive.w(10)),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.profileMeta(responsive).copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (score > 0) ...[
            SizedBox(height: responsive.h(10)),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9999),
                    child: Stack(
                      children: [
                        Container(
                          height: responsive.h(6),
                          color: textColor.withValues(alpha: 0.15),
                        ),
                        FractionallySizedBox(
                          widthFactor: score.clamp(0.0, 1.0),
                          child: Container(
                            height: responsive.h(6),
                            decoration: BoxDecoration(
                              color: textColor,
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: responsive.w(10)),
                Text(
                  '${(score * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.profileMeta(responsive).copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Verify button ─────────────────────────────────────────────────────────────

class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
    required this.responsive,
    required this.status,
    required this.enabled,
    required this.onVerify,
  });

  final AppResponsive responsive;
  final VerificationStatus status;
  final bool enabled;
  final VoidCallback onVerify;

  bool get _isLoading => status == VerificationStatus.loading;
  bool get _isDone => status == VerificationStatus.success;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (enabled && !_isLoading && !_isDone) ? onVerify : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        height: responsive.h(50),
        decoration: ShapeDecoration(
          color: _isDone
              ? AppColors.success
              : (enabled ? AppColors.primary : AppColors.surfaceMuted),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.radius(14)),
          ),
        ),
        child: _isLoading
            ? const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isDone
                        ? Icons.check_circle_rounded
                        : Icons.face_retouching_natural_rounded,
                    size: responsive.text(18),
                    color: enabled ? AppColors.white : AppColors.textGhost,
                  ),
                  SizedBox(width: responsive.w(10)),
                  Text(
                    _isDone
                        ? 'Identité vérifiée'
                        : 'Vérifier mon identité',
                    style: AppTextStyles.profileSectionLabel(responsive)
                        .copyWith(
                      color: enabled
                          ? AppColors.white
                          : AppColors.textGhost,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

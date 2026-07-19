import 'dart:io';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_button.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/app_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class IdCardPreviewTile extends StatelessWidget {
  const IdCardPreviewTile({
    super.key,
    required this.responsive,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.onTap,
    this.imageFile,
    this.faceBox,
    this.imageSize,
    this.isDetecting = false,
    this.detectionError,
  });

  final AppResponsive responsive;
  final String title;
  final String subtitle;
  final String actionLabel;
  final VoidCallback onTap;
  final XFile? imageFile;
  final Rect? faceBox;
  final Size? imageSize;
  final bool isDetecting;
  final String? detectionError;

  bool get _hasImage => imageFile != null;
  bool get _faceFound => faceBox != null && imageSize != null && !isDetecting;
  bool get _faceMissing => !isDetecting && detectionError != null && faceBox == null;

  @override
  Widget build(BuildContext context) {
    return AppField(
      responsive: responsive,
      label: title,
      labelStyle: AppTextStyles.profileSectionLabel(responsive),
      backgroundColor: AppColors.white,
      child: _hasImage ? _buildPreview(context) : _buildUpload(),
    );
  }

  Widget _buildUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: responsive.w(48),
          height: responsive.w(48),
          decoration: ShapeDecoration(
            color: AppColors.surfaceAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(responsive.radius(12)),
            ),
          ),
          child: Icon(Icons.photo_camera_outlined,
              color: AppColors.primary, size: responsive.text(20)),
        ),
        SizedBox(height: responsive.h(12)),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.profileSectionTitle(responsive)
              .copyWith(fontSize: responsive.text(15)),
        ),
        SizedBox(height: responsive.h(4)),
        Text(subtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.profileMeta(responsive)),
        SizedBox(height: responsive.h(12)),
        AppChipButton(responsive: responsive, label: actionLabel, onTap: onTap),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Image preview with face detection overlay
        ClipRRect(
          borderRadius: BorderRadius.circular(responsive.radius(12)),
          child: AspectRatio(
            aspectRatio: 85.6 / 54.0, // ISO/IEC 7810 ID card ratio
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Card photo
                Image.file(
                  File(imageFile!.path),
                  fit: BoxFit.cover,
                ),

                // Face bounding box overlay
                if (_faceFound)
                  CustomPaint(
                    painter: _FaceBoxPainter(
                      faceBox: faceBox!,
                      imageSize: imageSize!,
                    ),
                  ),

                // Loading shimmer
                if (isDetecting)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Détection du visage…',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // No-face error badge
                if (_faceMissing)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                      color: Colors.red.shade600.withValues(alpha: 0.88),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Aucun visage détecté — reprenez la photo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Face-found badge
                if (_faceFound)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.face_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Visage détecté',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        SizedBox(height: responsive.h(10)),

        // Status row + replace button
        Row(
          children: [
            // Status icon + text
            if (isDetecting) ...[
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.textMuted,
                ),
              ),
              SizedBox(width: responsive.w(6)),
              Flexible(
                child: Text('Analyse en cours…',
                    style: AppTextStyles.profileMeta(responsive)
                        .copyWith(color: AppColors.textMuted),
                    overflow: TextOverflow.ellipsis),
              ),
            ] else if (_faceFound) ...[
              Icon(Icons.check_circle_rounded,
                  size: responsive.text(14), color: AppColors.success),
              SizedBox(width: responsive.w(6)),
              Flexible(
                child: Text('Visage identifié sur la CNI',
                    style: AppTextStyles.profileMeta(responsive)
                        .copyWith(color: AppColors.success, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ),
            ] else if (_faceMissing) ...[
              Icon(Icons.error_outline_rounded,
                  size: responsive.text(14), color: Colors.red.shade600),
              SizedBox(width: responsive.w(6)),
              Expanded(
                child: Text('Aucun visage — carte invalide',
                    style: AppTextStyles.profileMeta(responsive)
                        .copyWith(color: Colors.red.shade600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ] else
              const Spacer(),

            const Spacer(),

            AppChipButton(
              responsive: responsive,
              label: 'Remplacer',
              onTap: onTap,
            ),
          ],
        ),
      ],
    );
  }
}

// Draws a green rounded rectangle around the detected face,
// scaled from the original image dimensions to the widget display size.
class _FaceBoxPainter extends CustomPainter {
  const _FaceBoxPainter({
    required this.faceBox,
    required this.imageSize,
  });

  final Rect faceBox;
  final Size imageSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.width <= 0 || imageSize.height <= 0) return;

    // Scale factors from original image pixels to widget pixels
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    final scaled = Rect.fromLTWH(
      faceBox.left * scaleX,
      faceBox.top * scaleY,
      faceBox.width * scaleX,
      faceBox.height * scaleY,
    );

    // Outer glow
    final glowPaint = Paint()
      ..color = AppColors.success.withValues(alpha: 0.30)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scaled.inflate(4), const Radius.circular(8)),
      glowPaint,
    );

    // Main rectangle
    final paint = Paint()
      ..color = AppColors.success
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(scaled, const Radius.circular(6)),
      paint,
    );

    // Corner brackets for a professional look
    _drawCornerBracket(canvas, scaled.topLeft, 14, paint);
    _drawCornerBracket(canvas, scaled.topRight, 14, paint, flipX: true);
    _drawCornerBracket(canvas, scaled.bottomLeft, 14, paint, flipY: true);
    _drawCornerBracket(canvas, scaled.bottomRight, 14, paint, flipX: true, flipY: true);
  }

  void _drawCornerBracket(
    Canvas canvas,
    Offset corner,
    double length,
    Paint paint, {
    bool flipX = false,
    bool flipY = false,
  }) {
    final dx = flipX ? -length : length;
    final dy = flipY ? -length : length;

    final path = Path()
      ..moveTo(corner.dx + dx, corner.dy)
      ..lineTo(corner.dx, corner.dy)
      ..lineTo(corner.dx, corner.dy + dy);

    canvas.drawPath(
      path,
      paint
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_FaceBoxPainter old) =>
      old.faceBox != faceBox || old.imageSize != imageSize;
}


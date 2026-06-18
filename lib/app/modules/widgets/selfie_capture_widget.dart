import 'dart:io';

import 'package:covoiturage_benin_app/app/core/constants/app_colors.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_responsive.dart';
import 'package:covoiturage_benin_app/app/core/constants/app_text_styles.dart';
import 'package:covoiturage_benin_app/app/modules/widgets/selfie_camera_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

export 'package:covoiturage_benin_app/app/modules/widgets/selfie_camera_screen.dart'
    show SelfieStep;

class SelfieCaptureWidget extends StatefulWidget {
  const SelfieCaptureWidget({
    super.key,
    required this.responsive,
    required this.onChanged,
  });

  final AppResponsive responsive;
  final void Function(XFile? front, XFile? left, XFile? right) onChanged;

  @override
  State<SelfieCaptureWidget> createState() => _SelfieCaptureWidgetState();
}

class _SelfieCaptureWidgetState extends State<SelfieCaptureWidget>
    with SingleTickerProviderStateMixin {
  SelfieStep _currentStep = SelfieStep.front;
  XFile? _front;
  XFile? _left;
  XFile? _right;
  bool _isCapturing = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  static const _steps = [SelfieStep.front, SelfieStep.left, SelfieStep.right];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  XFile? _imageFor(SelfieStep s) => switch (s) {
        SelfieStep.front => _front,
        SelfieStep.left => _left,
        SelfieStep.right => _right,
      };

  String _labelFor(SelfieStep s) => switch (s) {
        SelfieStep.front => 'Face',
        SelfieStep.left => 'Gauche',
        SelfieStep.right => 'Droite',
      };

  String _instructionFor(SelfieStep s) => switch (s) {
        SelfieStep.front => 'Regardez droit devant la caméra',
        SelfieStep.left => 'Tournez lentement la tête vers la gauche',
        SelfieStep.right => 'Tournez lentement la tête vers la droite',
      };

  bool get _allCaptured => _front != null && _left != null && _right != null;
  XFile? get _currentImage => _imageFor(_currentStep);

  Future<void> _captureCurrentStep() async {
    setState(() => _isCapturing = true);

    XFile? picked;
    try {
      picked = await Navigator.of(context).push<XFile>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (_) => SelfieCameraScreen(step: _currentStep),
        ),
      );
    } catch (_) {
      if (mounted) setState(() => _isCapturing = false);
      return;
    }

    if (picked == null || !mounted) {
      if (mounted) setState(() => _isCapturing = false);
      return;
    }

    final capturedStep = _currentStep;
    setState(() {
      _isCapturing = false;
      switch (capturedStep) {
        case SelfieStep.front:
          _front = picked;
        case SelfieStep.left:
          _left = picked;
        case SelfieStep.right:
          _right = picked;
      }
    });
    widget.onChanged(_front, _left, _right);

    // Brief preview of captured photo, then auto-advance to next step
    await Future.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;

    setState(() {
      if (capturedStep == SelfieStep.front && _left == null) {
        _currentStep = SelfieStep.left;
      } else if (capturedStep == SelfieStep.left && _right == null) {
        _currentStep = SelfieStep.right;
      } else if (capturedStep == SelfieStep.right && _front == null) {
        _currentStep = SelfieStep.front;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.responsive;
    final hasCurrentImage = _currentImage != null;

    return Column(
      children: [
        // Each step: indicator circle + label in a Column → perfect alignment
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _steps.map((step) {
            final isActive = step == _currentStep;
            final img = _imageFor(step);
            final done = img != null;
            final circleSize =
                done ? r.w(52) : (isActive ? r.w(44) : r.w(36));

            return GestureDetector(
              onTap: () => setState(() => _currentStep = step),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: r.w(8)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: circleSize,
                      height: circleSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? AppColors.success
                            : isActive
                                ? AppColors.primary
                                : AppColors.border,
                        border: isActive && !done
                            ? Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.35),
                                width: 3,
                              )
                            : null,
                      ),
                      child: done
                          ? ClipOval(
                              child: Image.file(
                                File(img.path),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: _HeadStepIcon(
                                step: step,
                                color: AppColors.white,
                                size: circleSize * 0.58,
                              ),
                            ),
                    ),
                    SizedBox(height: r.h(6)),
                    Text(
                      _labelFor(step),
                      textAlign: TextAlign.center,
                      style: AppTextStyles.profileMeta(r).copyWith(
                        fontSize: r.text(10),
                        color: done
                            ? AppColors.success
                            : isActive
                                ? AppColors.primary
                                : AppColors.textGhost,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: r.h(20)),

        // Main capture area — tapping also opens the camera
        GestureDetector(
          onTap: _isCapturing ? null : _captureCurrentStep,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: hasCurrentImage ? 1.0 : _pulseAnimation.value,
              child: child,
            ),
            child: Container(
            width: r.w(190),
            height: r.h(220),
            decoration: BoxDecoration(
              color: AppColors.surfaceAccent,
              borderRadius: BorderRadius.circular(r.radius(20)),
              border: Border.all(
                color: hasCurrentImage
                    ? AppColors.success
                    : AppColors.primary.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (hasCurrentImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(r.radius(19)),
                    child: Image.file(
                      File(_currentImage!.path),
                      width: r.w(190),
                      height: r.h(220),
                      fit: BoxFit.cover,
                    ),
                  )
                else ...[
                  CustomPaint(
                    size: Size(r.w(190), r.h(220)),
                    painter: _FaceOvalPainter(color: AppColors.primary),
                  ),
                  _HeadGuideIllustration(
                    step: _currentStep,
                    width: r.w(190),
                    height: r.h(220),
                    faceColor: AppColors.primary.withValues(alpha: 0.20),
                    arrowColor: AppColors.primary.withValues(alpha: 0.75),
                  ),
                ],
                if (hasCurrentImage)
                  Positioned(
                    top: r.h(10),
                    right: r.w(10),
                    child: Container(
                      padding: EdgeInsets.all(r.w(4)),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check_rounded,
                          size: r.text(14), color: AppColors.white),
                    ),
                  ),
              ],
            ),
          ),
          ),
        ),
        SizedBox(height: r.h(14)),

        Text(
          _labelFor(_currentStep),
          style: AppTextStyles.profileSectionTitle(r)
              .copyWith(fontSize: r.text(15)),
        ),
        SizedBox(height: r.h(4)),
        Text(
          _instructionFor(_currentStep),
          textAlign: TextAlign.center,
          style: AppTextStyles.profileMeta(r)
              .copyWith(color: AppColors.textSecondary),
        ),
        SizedBox(height: r.h(18)),

        if (_allCaptured)
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: r.w(20), vertical: r.h(10)),
            decoration: ShapeDecoration(
              color: AppColors.successLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(r.radius(12)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded,
                    color: AppColors.success, size: 18),
                SizedBox(width: r.w(8)),
                Text(
                  'Vérification complète',
                  style: AppTextStyles.profileMeta(r).copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: _isCapturing ? null : _captureCurrentStep,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                  horizontal: r.w(28), vertical: r.h(13)),
              decoration: ShapeDecoration(
                color: _isCapturing
                    ? AppColors.primary.withValues(alpha: 0.55)
                    : AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(r.radius(12)),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isCapturing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.white),
                        strokeWidth: 2,
                      ),
                    )
                  else
                    Icon(
                      hasCurrentImage
                          ? Icons.refresh_rounded
                          : Icons.camera_alt_rounded,
                      color: AppColors.white,
                      size: r.text(18),
                    ),
                  SizedBox(width: r.w(8)),
                  Text(
                    hasCurrentImage ? 'Reprendre' : 'Capturer',
                    style: AppTextStyles.profileSectionTitle(r).copyWith(
                      color: AppColors.white,
                      fontSize: r.text(15),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Small head icon for step indicators ─────────────────────────────────────

class _HeadStepIcon extends StatelessWidget {
  const _HeadStepIcon({
    required this.step,
    required this.color,
    required this.size,
  });

  final SelfieStep step;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HeadStepPainter(step: step, color: color),
    );
  }
}

class _HeadStepPainter extends CustomPainter {
  const _HeadStepPainter({required this.step, required this.color});

  final SelfieStep step;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Shift head toward center to leave room for directional arrow
    final shiftX = switch (step) {
      SelfieStep.front => 0.0,
      SelfieStep.left => w * 0.06,
      SelfieStep.right => -w * 0.06,
    };

    final headW = step == SelfieStep.front ? w * 0.58 : w * 0.50;
    final headH = h * 0.70;
    final cx = w / 2 + shiftX;
    final cy = h * 0.46;

    // Head oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: headW, height: headH),
      stroke,
    );

    // Eyes — perspective-adjusted
    final eyeY = cy - headH * 0.10;
    switch (step) {
      case SelfieStep.front:
        final s = headW * 0.22;
        canvas.drawCircle(Offset(cx - s, eyeY), w * 0.062, fill);
        canvas.drawCircle(Offset(cx + s, eyeY), w * 0.062, fill);
      case SelfieStep.left:
        // Near eye (right) full size, far eye (left) smaller
        canvas.drawCircle(Offset(cx - headW * 0.16, eyeY), w * 0.038, fill);
        canvas.drawCircle(Offset(cx + headW * 0.13, eyeY), w * 0.062, fill);
      case SelfieStep.right:
        canvas.drawCircle(Offset(cx + headW * 0.16, eyeY), w * 0.038, fill);
        canvas.drawCircle(Offset(cx - headW * 0.13, eyeY), w * 0.062, fill);
    }

    // Nose — shifts toward turning direction
    final noseX = cx + switch (step) {
      SelfieStep.front => 0.0,
      SelfieStep.left => -headW * 0.10,
      SelfieStep.right => headW * 0.10,
    };
    canvas.drawCircle(Offset(noseX, cy + headH * 0.08), w * 0.046, fill);

    // Direction arrow
    if (step != SelfieStep.front) {
      final isLeft = step == SelfieStep.left;
      final arrowStroke = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.09
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final tipX = isLeft ? w * 0.04 : w * 0.96;
      final tailX = isLeft ? w * 0.25 : w * 0.75;
      final ay = cy;
      final hl = w * 0.12;
      final dir = isLeft ? 1.0 : -1.0;

      canvas.drawLine(
          Offset(tailX, ay), Offset(tipX + dir * hl * 0.8, ay), arrowStroke);
      canvas.drawLine(Offset(tipX, ay),
          Offset(tipX + dir * hl, ay - hl * 0.65), arrowStroke);
      canvas.drawLine(Offset(tipX, ay),
          Offset(tipX + dir * hl, ay + hl * 0.65), arrowStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _HeadStepPainter old) =>
      old.step != step || old.color != color;
}

// ─── Large head guide with animated bouncing arrow ────────────────────────────

class _HeadGuideIllustration extends StatefulWidget {
  const _HeadGuideIllustration({
    required this.step,
    required this.width,
    required this.height,
    required this.faceColor,
    required this.arrowColor,
  });

  final SelfieStep step;
  final double width;
  final double height;
  final Color faceColor;
  final Color arrowColor;

  @override
  State<_HeadGuideIllustration> createState() =>
      _HeadGuideIllustrationState();
}

class _HeadGuideIllustrationState extends State<_HeadGuideIllustration>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 680),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.0, end: 9.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.step == SelfieStep.front) {
      return CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _HeadGuidePainter(
          step: widget.step,
          faceColor: widget.faceColor,
          arrowColor: widget.arrowColor,
          arrowOffset: 0,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _HeadGuidePainter(
          step: widget.step,
          faceColor: widget.faceColor,
          arrowColor: widget.arrowColor,
          arrowOffset: _anim.value,
        ),
      ),
    );
  }
}

class _HeadGuidePainter extends CustomPainter {
  const _HeadGuidePainter({
    required this.step,
    required this.faceColor,
    required this.arrowColor,
    required this.arrowOffset,
  });

  final SelfieStep step;
  final Color faceColor;
  final Color arrowColor;
  final double arrowOffset;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = faceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.038
      ..strokeCap = StrokeCap.round;

    final fill = Paint()
      ..color = faceColor
      ..style = PaintingStyle.fill;

    final headW = step == SelfieStep.front ? w * 0.56 : w * 0.48;
    final headH = h * 0.65;
    final cx = w / 2;
    final cy = h * 0.44;

    // Head: ghost fill + outline
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: headW, height: headH),
      Paint()
        ..color = faceColor.withValues(alpha: 0.07)
        ..style = PaintingStyle.fill,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: headW, height: headH),
      stroke,
    );

    // Neck
    final neckW = headW * 0.20;
    final neckY0 = cy + headH / 2 - h * 0.005;
    canvas.drawLine(
        Offset(cx - neckW / 2, neckY0), Offset(cx - neckW / 2, h * 0.88), stroke);
    canvas.drawLine(
        Offset(cx + neckW / 2, neckY0), Offset(cx + neckW / 2, h * 0.88), stroke);

    // Eyes
    final eyeY = cy - headH * 0.09;
    final eyeR = w * 0.046;
    switch (step) {
      case SelfieStep.front:
        final s = headW * 0.22;
        canvas.drawCircle(Offset(cx - s, eyeY), eyeR, fill);
        canvas.drawCircle(Offset(cx + s, eyeY), eyeR, fill);
      case SelfieStep.left:
        canvas.drawCircle(Offset(cx - headW * 0.17, eyeY), eyeR * 0.52, fill);
        canvas.drawCircle(Offset(cx + headW * 0.14, eyeY), eyeR, fill);
      case SelfieStep.right:
        canvas.drawCircle(Offset(cx + headW * 0.17, eyeY), eyeR * 0.52, fill);
        canvas.drawCircle(Offset(cx - headW * 0.14, eyeY), eyeR, fill);
    }

    // Nose
    final noseX = cx + switch (step) {
      SelfieStep.front => 0.0,
      SelfieStep.left => -headW * 0.10,
      SelfieStep.right => headW * 0.10,
    };
    canvas.drawCircle(Offset(noseX, cy + headH * 0.08), w * 0.035, fill);

    // Animated bouncing arrow
    if (step != SelfieStep.front) {
      final isLeft = step == SelfieStep.left;
      final bounce = isLeft ? -arrowOffset : arrowOffset;
      final dir = isLeft ? 1.0 : -1.0;

      final arrowStroke = Paint()
        ..color = arrowColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.052
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final tipX = (isLeft ? w * 0.09 : w * 0.91) + bounce;
      final tailX = (isLeft ? w * 0.30 : w * 0.70) + bounce;
      final hl = w * 0.11;

      canvas.drawLine(
          Offset(tailX, cy), Offset(tipX + dir * hl, cy), arrowStroke);
      canvas.drawLine(
          Offset(tipX, cy), Offset(tipX + dir * hl, cy - hl * 0.65), arrowStroke);
      canvas.drawLine(
          Offset(tipX, cy), Offset(tipX + dir * hl, cy + hl * 0.65), arrowStroke);
    }
  }

  @override
  bool shouldRepaint(covariant _HeadGuidePainter old) =>
      old.step != step ||
      old.faceColor != faceColor ||
      old.arrowColor != arrowColor ||
      old.arrowOffset != arrowOffset;
}

// ─── Face oval alignment guide ────────────────────────────────────────────────

class _FaceOvalPainter extends CustomPainter {
  const _FaceOvalPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: size.width * 0.60,
        height: size.height * 0.78,
      ),
      Paint()
        ..color = color.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    final bracket = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    const len = 16.0;
    for (final (c, dx, dy) in [
      (Offset(size.width * 0.20, size.height * 0.14), 1.0, 1.0),
      (Offset(size.width * 0.80, size.height * 0.14), -1.0, 1.0),
      (Offset(size.width * 0.20, size.height * 0.86), 1.0, -1.0),
      (Offset(size.width * 0.80, size.height * 0.86), -1.0, -1.0),
    ]) {
      canvas.drawLine(c, c + Offset(dx * len, 0), bracket);
      canvas.drawLine(c, c + Offset(0, dy * len), bracket);
    }
  }

  @override
  bool shouldRepaint(covariant _FaceOvalPainter old) => old.color != color;
}

import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

enum SelfieStep { front, left, right }

/// Full-screen in-app camera for selfie capture.
/// Returns the captured [XFile] via [Navigator.pop], or null if cancelled.
class SelfieCameraScreen extends StatefulWidget {
  const SelfieCameraScreen({super.key, required this.step});
  final SelfieStep step;

  @override
  State<SelfieCameraScreen> createState() => _SelfieCameraScreenState();
}

class _SelfieCameraScreenState extends State<SelfieCameraScreen>
    with TickerProviderStateMixin {
  CameraController? _controller;
  bool _initialized = false;
  bool _capturing = false;

  // Oval border pulse animation
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  // Direction arrow bounce animation (left/right steps only)
  late AnimationController _arrowCtrl;
  late Animation<double> _arrowAnim;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _arrowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
    _arrowAnim = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _arrowCtrl, curve: Curves.easeInOut),
    );

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) Navigator.of(context).pop();
        return;
      }

      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final ctrl = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await ctrl.initialize();
      if (!mounted) {
        ctrl.dispose();
        return;
      }

      _controller = ctrl;
      setState(() => _initialized = true);
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _arrowCtrl.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (!_initialized || _capturing || _controller == null) return;
    setState(() => _capturing = true);
    // Capture screen size before the async gap (layout stays stable)
    final screenSize = MediaQuery.of(context).size;
    try {
      final photo = await _controller!.takePicture();
      final cropped = await _cropToHead(photo.path, screenSize);
      if (mounted) Navigator.of(context).pop(cropped);
    } catch (_) {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// Recadre l'image sur la zone de tête définie par l'ovale de l'overlay.
  ///
  /// Utilise la même géométrie que [_CameraOverlayPainter._oval] et le même
  /// mapping cover-fill que l'écran CNI pour être pixel-exact.
  Future<XFile> _cropToHead(String imagePath, Size screenSize) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final source = img.decodeImage(bytes);
      if (source == null) return XFile(imagePath);

      final imgW = source.width.toDouble();
      final imgH = source.height.toDouble();
      final scrW = screenSize.width;
      final scrH = screenSize.height;

      // Cover-fill : même formule que id_card_camera_screen
      final displayScale = math.max(scrW / imgW, scrH / imgH);
      final offsetX = (imgW - scrW / displayScale) / 2;
      final offsetY = (imgH - scrH / displayScale) / 2;

      // Géométrie identique à _CameraOverlayPainter._oval
      final ovalW = scrW * 0.72;
      final ovalH = ovalW * 1.35;
      // Marges de 10 % autour de l'ovale pour ne pas couper front/menton
      const pad = 0.10;
      final cropRect = Rect.fromCenter(
        center: Offset(scrW / 2, scrH * 0.42),
        width: ovalW * (1 + pad * 2),
        height: ovalH * (1 + pad * 2),
      );

      // Mapping écran → pixels image
      final l = (offsetX + cropRect.left / displayScale).clamp(0.0, imgW - 1);
      final t = (offsetY + cropRect.top / displayScale).clamp(0.0, imgH - 1);
      final w = (cropRect.width / displayScale).clamp(1.0, imgW - l);
      final h = (cropRect.height / displayScale).clamp(1.0, imgH - t);

      final cropped = img.copyCrop(
        source,
        x: l.round(),
        y: t.round(),
        width: w.round().clamp(1, source.width - l.round()),
        height: h.round().clamp(1, source.height - t.round()),
      );

      final outPath =
          '${Directory.systemTemp.path}/selfie_head_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(outPath).writeAsBytes(img.encodeJpg(cropped, quality: 92));
      return XFile(outPath);
    } catch (_) {
      return XFile(imagePath);
    }
  }

  String get _title => switch (widget.step) {
        SelfieStep.front => 'Photo de face',
        SelfieStep.left => 'Photo côté gauche',
        SelfieStep.right => 'Photo côté droit',
      };

  String get _instruction => switch (widget.step) {
        SelfieStep.front => 'Centrez votre visage dans l\'ovale',
        SelfieStep.left => 'Tournez doucement la tête vers la gauche',
        SelfieStep.right => 'Tournez doucement la tête vers la droite',
      };

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Live camera preview ─────────────────────────────────────────
          if (_initialized && _controller != null)
            _FullScreenPreview(controller: _controller!)
          else
            const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),

          // ── Dark vignette + oval cutout + guide ─────────────────────────
          if (_initialized)
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnim, _arrowAnim]),
              builder: (_, _) => CustomPaint(
                size: size,
                painter: _CameraOverlayPainter(
                  step: widget.step,
                  borderOpacity: _pulseAnim.value,
                  arrowOffset:
                      widget.step == SelfieStep.front ? 0 : _arrowAnim.value,
                ),
              ),
            ),

          // ── Top: back + title + instruction ────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          _title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 10)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.50),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _instruction,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Step dots (which of 3 steps we're on) ──────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Step indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: SelfieStep.values.map((s) {
                      final active = s == widget.step;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: active ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Capture button
                  _CaptureButton(
                    capturing: _capturing,
                    enabled: _initialized,
                    onTap: _capture,
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FullScreenPreview extends StatelessWidget {
  const _FullScreenPreview({required this.controller});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final preview = controller.value.previewSize;
    final displayW = preview != null
        ? (preview.height > preview.width ? preview.width : preview.height)
        : null;
    final displayH = preview != null
        ? (preview.height > preview.width ? preview.height : preview.width)
        : null;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: displayW?.toDouble() ?? 1,
          height: displayH?.toDouble() ?? 1,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 17),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.capturing,
    required this.enabled,
    required this.onTap,
  });
  final bool capturing;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (enabled && !capturing) ? onTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.80),
                width: 4,
              ),
            ),
          ),
          // Inner fill circle
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: capturing ? 52 : 64,
            height: capturing ? 52 : 64,
            decoration: BoxDecoration(
              color: capturing ? Colors.grey.shade400 : Colors.white,
              shape: BoxShape.circle,
            ),
            child: capturing
                ? const Padding(
                    padding: EdgeInsets.all(15),
                    child: CircularProgressIndicator(
                      color: Colors.black54,
                      strokeWidth: 2.5,
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CameraOverlayPainter extends CustomPainter {
  const _CameraOverlayPainter({
    required this.step,
    required this.borderOpacity,
    required this.arrowOffset,
  });

  final SelfieStep step;
  final double borderOpacity;
  final double arrowOffset;

  Rect _oval(Size s) {
    final w = s.width * 0.72;
    final h = w * 1.35;
    return Rect.fromCenter(
      center: Offset(s.width / 2, s.height * 0.42),
      width: w,
      height: h,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final oval = _oval(size);

    // Dark background with oval cutout
    final cutout = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addOval(oval),
    );
    canvas.drawPath(
      cutout,
      Paint()..color = Colors.black.withValues(alpha: 0.60),
    );

    // Pulsing oval border
    canvas.drawOval(
      oval,
      Paint()
        ..color = Colors.white.withValues(alpha: borderOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.8,
    );

    // Corner brackets
    _brackets(canvas, oval);

    // Directional arrow for profile steps
    if (step != SelfieStep.front) _arrow(canvas, size, oval);
  }

  void _brackets(Canvas canvas, Rect r) {
    const len = 22.0;
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;

    for (final corner in [
      (r.topLeft, 1.0, 1.0),
      (r.topRight, -1.0, 1.0),
      (r.bottomLeft, 1.0, -1.0),
      (r.bottomRight, -1.0, -1.0),
    ]) {
      final c = corner.$1;
      final dx = corner.$2;
      final dy = corner.$3;
      canvas.drawLine(c, c + Offset(dx * len, 0), p);
      canvas.drawLine(c, c + Offset(0, dy * len), p);
    }
  }

  void _arrow(Canvas canvas, Size size, Rect oval) {
    final isLeft = step == SelfieStep.left;
    final bounce = isLeft ? -arrowOffset : arrowOffset;
    final dir = isLeft ? 1.0 : -1.0;
    final ay = oval.center.dy;
    final hl = size.width * 0.06;

    final tipX = (isLeft ? size.width * 0.10 : size.width * 0.90) + bounce;
    final tailX = (isLeft ? size.width * 0.30 : size.width * 0.70) + bounce;

    final p = Paint()
      ..color = Colors.white.withValues(alpha: 0.90)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawLine(Offset(tailX, ay), Offset(tipX + dir * hl, ay), p);
    canvas.drawLine(
        Offset(tipX, ay), Offset(tipX + dir * hl, ay - hl * 0.75), p);
    canvas.drawLine(
        Offset(tipX, ay), Offset(tipX + dir * hl, ay + hl * 0.75), p);
  }

  @override
  bool shouldRepaint(covariant _CameraOverlayPainter o) =>
      o.step != step ||
      o.borderOpacity != borderOpacity ||
      o.arrowOffset != arrowOffset;
}

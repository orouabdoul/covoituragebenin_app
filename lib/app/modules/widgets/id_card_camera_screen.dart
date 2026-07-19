import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Résultat retourné par [IdCardCameraScreen].
/// [fullCard] = photo complète de la carte.
/// [faceZone] = recadrage de la zone visage définie par le cadre vert.
class IdCardCaptureResult {
  final XFile fullCard;
  final XFile? faceZone;

  const IdCardCaptureResult({required this.fullCard, this.faceZone});
}

/// Écran caméra plein-écran pour la capture du recto CNI.
/// Caméra arrière + cadre carte (ISO 85.6:54) + zone visage verte.
/// Retourne un [IdCardCaptureResult] via [Navigator.pop], ou null si annulé.
class IdCardCameraScreen extends StatefulWidget {
  const IdCardCameraScreen({super.key});

  @override
  State<IdCardCameraScreen> createState() => _IdCardCameraScreenState();
}

class _IdCardCameraScreenState extends State<IdCardCameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _initialized = false;
  bool _capturing = false;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
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
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final ctrl = CameraController(
        camera,
        ResolutionPreset.high,
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
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (!_initialized || _capturing || _controller == null) return;
    setState(() => _capturing = true);
    // Capture screen size before the async gap so layout is correct
    final screenSize = MediaQuery.of(context).size;
    try {
      final photo = await _controller!.takePicture();
      final result = await _extractZones(photo.path, screenSize);
      if (mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (_) {
      if (mounted) setState(() => _capturing = false);
    }
  }

  /// Recadre la zone carte (cadre blanc) et la zone visage (cadre vert)
  /// en utilisant exactement la même géométrie que [_CardOverlayPainter].
  ///
  /// Le mapping écran→image utilise le scale "cover-fill" :
  /// l'image est zoomée pour remplir l'écran, les bords excédentaires
  /// sont rognés. On inverse ce calcul pour retrouver les pixels exacts.
  Future<IdCardCaptureResult> _extractZones(
      String imagePath, Size screenSize) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final source = img.decodeImage(bytes);
      if (source == null) return IdCardCaptureResult(fullCard: XFile(imagePath));

      final imgW = source.width.toDouble();
      final imgH = source.height.toDouble();
      final scrW = screenSize.width;
      final scrH = screenSize.height;

      // Cover-fill : plus grand facteur tel que l'image couvre tout l'écran
      final displayScale = math.max(scrW / imgW, scrH / imgH);
      // Pixels image "décalés" hors de l'écran de chaque côté (clip)
      final offsetX = (imgW - scrW / displayScale) / 2;
      final offsetY = (imgH - scrH / displayScale) / 2;

      // Convertit un Rect en coordonnées écran → pixels image
      Rect toImage(Rect r) {
        final l = (offsetX + r.left / displayScale).clamp(0.0, imgW - 1);
        final t = (offsetY + r.top / displayScale).clamp(0.0, imgH - 1);
        final w = (r.width / displayScale).clamp(1.0, imgW - l);
        final h = (r.height / displayScale).clamp(1.0, imgH - t);
        return Rect.fromLTWH(l, t, w, h);
      }

      // ── Géométrie identique à _CardOverlayPainter ────────────────────────
      const cardRatio = 85.6 / 54.0;
      final cardW = scrW * 0.88;
      final cardH = cardW / cardRatio;
      final cardRect = Rect.fromCenter(
        center: Offset(scrW / 2, scrH * 0.47),
        width: cardW,
        height: cardH,
      );

      const pad = 10.0;
      final faceRect = Rect.fromLTWH(
        cardRect.left + pad,
        cardRect.top + pad,
        cardRect.width * 0.30 - pad,
        cardRect.height - pad * 2,
      );
      // ─────────────────────────────────────────────────────────────────────

      final cardImg = toImage(cardRect);
      final faceImg = toImage(faceRect);

      final ts = DateTime.now().millisecondsSinceEpoch;
      final tmp = Directory.systemTemp.path;

      // Recadrage carte complète (cadre blanc)
      final cardCrop = img.copyCrop(
        source,
        x: cardImg.left.round(),
        y: cardImg.top.round(),
        width: cardImg.width.round().clamp(1, source.width - cardImg.left.round()),
        height: cardImg.height.round().clamp(1, source.height - cardImg.top.round()),
      );
      final cardPath = '$tmp/card_full_$ts.jpg';
      await File(cardPath).writeAsBytes(img.encodeJpg(cardCrop, quality: 95));

      // Recadrage zone visage (cadre vert)
      final faceCrop = img.copyCrop(
        source,
        x: faceImg.left.round(),
        y: faceImg.top.round(),
        width: faceImg.width.round().clamp(1, source.width - faceImg.left.round()),
        height: faceImg.height.round().clamp(1, source.height - faceImg.top.round()),
      );
      final facePath = '$tmp/card_face_$ts.jpg';
      await File(facePath).writeAsBytes(img.encodeJpg(faceCrop, quality: 95));

      return IdCardCaptureResult(
        fullCard: XFile(cardPath),   // seulement la zone carte (cadre blanc)
        faceZone: XFile(facePath),   // seulement la zone visage (cadre vert)
      );
    } catch (_) {
      return IdCardCaptureResult(fullCard: XFile(imagePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Caméra en direct ───────────────────────────────────────────────
          if (_initialized && _controller != null)
            _FullScreenPreview(controller: _controller!)
          else
            const Center(
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            ),

          // ── Overlay : cadre carte + zone visage ────────────────────────────
          if (_initialized)
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, _) => CustomPaint(
                size: size,
                painter:
                    _CardOverlayPainter(borderOpacity: _pulseAnim.value),
              ),
            ),

          // ── Haut : retour + titre + instruction ────────────────────────────
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
                        const Text(
                          'Photo de la carte d\'identité',
                          style: TextStyle(
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
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Placez le recto de votre CNI dans le cadre\n'
                      'La photo du visage doit être dans la zone verte',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bas : conseils + bouton capture ───────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _TipChip(
                          icon: Icons.wb_sunny_outlined,
                          label: 'Bonne lumière'),
                      SizedBox(width: 8),
                      _TipChip(
                          icon: Icons.not_interested_outlined,
                          label: 'Sans reflet'),
                      SizedBox(width: 8),
                      _TipChip(
                          icon: Icons.straighten_rounded,
                          label: 'Bien plat'),
                    ],
                  ),
                  const SizedBox(height: 20),
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
    // previewSize est en pixels capteur (paysage sur Android) ;
    // on permute width/height pour obtenir les dimensions portrait effectives.
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
// Overlay : vignette sombre + cadre carte (85.6:54) + zone visage verte
// ─────────────────────────────────────────────────────────────────────────────

class _CardOverlayPainter extends CustomPainter {
  const _CardOverlayPainter({required this.borderOpacity});

  final double borderOpacity;

  static const _cardRatio = 85.6 / 54.0;

  Rect _cardRect(Size s) {
    final w = s.width * 0.88;
    final h = w / _cardRatio;
    return Rect.fromCenter(
      center: Offset(s.width / 2, s.height * 0.47),
      width: w,
      height: h,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final card = _cardRect(size);
    final cardRRect =
        RRect.fromRectAndRadius(card, const Radius.circular(12));

    // Vignette avec découpe carte
    final cutout = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(cardRRect),
    );
    canvas.drawPath(
        cutout, Paint()..color = Colors.black.withValues(alpha: 0.72));

    // Bordure carte pulsante
    canvas.drawRRect(
      cardRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: borderOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Coins de cadrage
    _drawCorners(canvas, card);

    // Zone visage (gauche de la carte)
    _drawFaceZone(canvas, card);
  }

  void _drawCorners(Canvas canvas, Rect card) {
    const len = 22.0;
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    for (final rec in [
      (card.topLeft, 1.0, 1.0),
      (card.topRight, -1.0, 1.0),
      (card.bottomLeft, 1.0, -1.0),
      (card.bottomRight, -1.0, -1.0),
    ]) {
      final c = rec.$1;
      canvas.drawLine(c, c + Offset(rec.$2 * len, 0), p);
      canvas.drawLine(c, c + Offset(0, rec.$3 * len), p);
    }
  }

  void _drawFaceZone(Canvas canvas, Rect card) {
    const pad = 10.0;
    final zone = Rect.fromLTWH(
      card.left + pad,
      card.top + pad,
      card.width * 0.30 - pad,
      card.height - pad * 2,
    );
    final zoneRRect =
        RRect.fromRectAndRadius(zone, const Radius.circular(8));

    // Fond vert translucide
    canvas.drawRRect(
      zoneRRect,
      Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: 0.18)
        ..style = PaintingStyle.fill,
    );

    // Bordure verte
    canvas.drawRRect(
      zoneRRect,
      Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: 0.80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8,
    );

    // Silhouette visage
    _drawFaceSilhouette(canvas, zone);

    // Label "Visage"
    _drawLabel(canvas, zone);
  }

  void _drawFaceSilhouette(Canvas canvas, Rect zone) {
    final cx = zone.center.dx;
    final headR = zone.width * 0.28;
    final headCy = zone.top + zone.height * 0.38;

    final paint = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Tête
    canvas.drawCircle(Offset(cx, headCy), headR, paint);

    // Yeux
    final eyeY = headCy - headR * 0.15;
    final eyeX = headR * 0.38;
    canvas.drawCircle(Offset(cx - eyeX, eyeY), headR * 0.12,
        paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx + eyeX, eyeY), headR * 0.12, paint);

    // Épaules
    paint.style = PaintingStyle.stroke;
    final shoulderPath = Path()
      ..arcTo(
        Rect.fromCenter(
          center: Offset(cx, headCy + headR * 2.1),
          width: zone.width * 0.78,
          height: headR * 2.0,
        ),
        math.pi,
        math.pi,
        false,
      );
    canvas.drawPath(shoulderPath, paint);
  }

  void _drawLabel(Canvas canvas, Rect zone) {
    final tp = TextPainter(
      text: const TextSpan(
        text: 'Visage',
        style: TextStyle(
          color: Color(0xFF22C55E),
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        zone.center.dx - tp.width / 2,
        zone.bottom - tp.height - 6,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CardOverlayPainter old) =>
      old.borderOpacity != borderOpacity;
}

// ─────────────────────────────────────────────────────────────────────────────

class _TipChip extends StatelessWidget {
  const _TipChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.85), size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

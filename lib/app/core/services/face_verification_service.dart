import 'dart:io';
import 'dart:ui';
import 'dart:math';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

enum VerificationStatus { idle, loading, success, failure, error }

class FaceValidationResult {
  final bool hasFace;
  final bool isWellPositioned;
  final bool eyesOpen;
  final String? errorMessage;

  const FaceValidationResult({
    required this.hasFace,
    this.isWellPositioned = false,
    this.eyesOpen = false,
    this.errorMessage,
  });

  bool get isValid => hasFace && isWellPositioned && eyesOpen;
}

/// Result of detecting a face on an ID card photo — used for UI overlay.
class IdCardFaceResult {
  final bool found;
  final Rect? boundingBox;
  final Size? imageSize;
  final String? error;

  const IdCardFaceResult({
    required this.found,
    this.boundingBox,
    this.imageSize,
    this.error,
  });
}

class IdentityVerificationResult {
  final bool passed;
  final double similarityScore;
  final String message;

  const IdentityVerificationResult({
    required this.passed,
    required this.similarityScore,
    required this.message,
  });
}

class FaceVerificationService {
  static FaceDetector? _basicDetector;
  static FaceDetector? _landmarkDetector;

  static FaceDetector get _faceDetector {
    _basicDetector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.10,
      ),
    );
    return _basicDetector!;
  }

  static FaceDetector get _landmarkFaceDetector {
    _landmarkDetector ??= FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.04,
      ),
    );
    return _landmarkDetector!;
  }

  static Future<void> initialize() async {
    _faceDetector;
    _landmarkFaceDetector;
  }

  // ── Selfie validation ────────────────────────────────────────────────────────

  static Future<FaceValidationResult> validateSelfie(XFile selfie) async {
    try {
      final faces = await _faceDetector
          .processImage(InputImage.fromFilePath(selfie.path));

      if (faces.isEmpty) {
        return const FaceValidationResult(
          hasFace: false,
          errorMessage: 'Aucun visage détecté. Réessayez dans un meilleur éclairage.',
        );
      }
      if (faces.length > 1) {
        return const FaceValidationResult(
          hasFace: true,
          isWellPositioned: false,
          errorMessage: "Plusieurs visages détectés. Assurez-vous d'être seul.",
        );
      }

      final face = faces.first;
      final bytes = await File(selfie.path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded != null) {
        final faceArea = face.boundingBox.width * face.boundingBox.height;
        final imageArea = decoded.width * decoded.height;
        if (faceArea / imageArea < 0.04) {
          return const FaceValidationResult(
            hasFace: true,
            isWellPositioned: false,
            errorMessage: 'Visage trop éloigné. Rapprochez-vous.',
          );
        }
      }

      final leftOpen = face.leftEyeOpenProbability ?? 1.0;
      final rightOpen = face.rightEyeOpenProbability ?? 1.0;
      final eyesOpen = leftOpen > 0.4 && rightOpen > 0.4;

      return FaceValidationResult(
        hasFace: true,
        isWellPositioned: true,
        eyesOpen: eyesOpen,
        errorMessage: eyesOpen ? null : 'Yeux fermés détectés. Gardez les yeux ouverts.',
      );
    } catch (e) {
      return FaceValidationResult(hasFace: false, errorMessage: 'Erreur analyse: $e');
    }
  }

  // ── ID card face detection (returns bounding box for UI overlay) ──────────────

  static Future<IdCardFaceResult> detectFaceOnCard(XFile card) async {
    try {
      final bytes = await File(card.path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return const IdCardFaceResult(found: false, error: 'Image invalide ou corrompue.');
      }
      final imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());

      final faces = await _landmarkFaceDetector
          .processImage(InputImage.fromFilePath(card.path));

      if (faces.isEmpty) {
        return IdCardFaceResult(
          found: false,
          imageSize: imageSize,
          error: 'Aucun visage détecté sur la CNI.\nAssurez-vous que le recto est bien visible.',
        );
      }

      // Pick best candidate: reasonable ID-card-photo size (not a selfie-sized face)
      Face? bestFace;
      double bestScore = -1;
      for (final f in faces) {
        final faceArea = f.boundingBox.width * f.boundingBox.height;
        final imageArea = decoded.width.toDouble() * decoded.height.toDouble();
        final areaRatio = faceArea / imageArea;
        final widthRatio = f.boundingBox.width / decoded.width;
        if (areaRatio < 0.03 || widthRatio > 0.85) continue;
        if (areaRatio > bestScore) {
          bestScore = areaRatio;
          bestFace = f;
        }
      }
      bestFace ??= faces.reduce((a, b) =>
          a.boundingBox.width * a.boundingBox.height >
                  b.boundingBox.width * b.boundingBox.height
              ? a
              : b);

      return IdCardFaceResult(
        found: true,
        boundingBox: bestFace.boundingBox,
        imageSize: imageSize,
      );
    } catch (e) {
      return IdCardFaceResult(found: false, error: 'Erreur de détection: $e');
    }
  }

  // ── ID card validation (standalone) ─────────────────────────────────────────

  static Future<FaceValidationResult> validateIdCard(XFile idCard) async {
    final result = await detectFaceOnCard(idCard);
    if (!result.found) {
      return FaceValidationResult(
          hasFace: false, errorMessage: result.error ?? 'Aucun visage sur la CNI');
    }
    return const FaceValidationResult(hasFace: true, isWellPositioned: true, eyesOpen: true);
  }

  // ── Full verification pipeline ───────────────────────────────────────────────

  static Future<IdentityVerificationResult> verify({
    required XFile selfieFront,
    required XFile idCardFront,
  }) async {
    try {
      final selfieVal = await validateSelfie(selfieFront);
      if (!selfieVal.hasFace || !selfieVal.isWellPositioned) {
        return IdentityVerificationResult(
          passed: false,
          similarityScore: 0,
          message: selfieVal.errorMessage ?? 'Selfie invalide',
        );
      }

      final results = await Future.wait([
        _landmarkFaceDetector
            .processImage(InputImage.fromFilePath(selfieFront.path)),
        _landmarkFaceDetector
            .processImage(InputImage.fromFilePath(idCardFront.path)),
      ]);

      final sf = results[0].firstOrNull;

      Face? idf;
      if (results[1].isNotEmpty) {
        final cardBytes = await File(idCardFront.path).readAsBytes();
        final cardImg = img.decodeImage(cardBytes);
        if (cardImg != null) {
          Face? bestFace;
          double bestScore = -1;
          for (final f in results[1]) {
            final widthRatio = f.boundingBox.width / cardImg.width;
            if (widthRatio > 0.85) continue;
            final score = (f.boundingBox.width * f.boundingBox.height).toDouble();
            if (score > bestScore) {
              bestScore = score;
              bestFace = f;
            }
          }
          idf = bestFace ?? results[1].first;
        } else {
          idf = results[1].first;
        }
      }

      if (idf == null) {
        return const IdentityVerificationResult(
          passed: false,
          similarityScore: 0,
          message: 'Aucun visage détecté sur la CNI. Reprenez la photo du recto.',
        );
      }
      if (sf == null) {
        return const IdentityVerificationResult(
          passed: false,
          similarityScore: 0,
          message: 'Visage du selfie introuvable. Reprenez le selfie.',
        );
      }

      return _compareFaces(sf, idf);
    } catch (e) {
      return IdentityVerificationResult(
        passed: false,
        similarityScore: 0,
        message: 'Erreur lors de la vérification: $e',
      );
    }
  }

  // ── Multi-metric biometric comparison ────────────────────────────────────────
  //
  // Each metric uses _strictSimilarity() — score 1.0 within tolerance, 0.0 at 3x.
  // Requires >=60% of metrics to individually score >=0.82 AND average >=0.82.

  static IdentityVerificationResult _compareFaces(Face sf, Face idf) {
    final scores = <double>[];

    final sfLE = sf.landmarks[FaceLandmarkType.leftEye];
    final sfRE = sf.landmarks[FaceLandmarkType.rightEye];
    final idfLE = idf.landmarks[FaceLandmarkType.leftEye];
    final idfRE = idf.landmarks[FaceLandmarkType.rightEye];
    final sfNose = sf.landmarks[FaceLandmarkType.noseBase];
    final idfNose = idf.landmarks[FaceLandmarkType.noseBase];
    final sfMouth = sf.landmarks[FaceLandmarkType.bottomMouth];
    final idfMouth = idf.landmarks[FaceLandmarkType.bottomMouth];
    final sfLC = sf.landmarks[FaceLandmarkType.leftCheek];
    final sfRC = sf.landmarks[FaceLandmarkType.rightCheek];
    final idfLC = idf.landmarks[FaceLandmarkType.leftCheek];
    final idfRC = idf.landmarks[FaceLandmarkType.rightCheek];

    // M1: inter-ocular distance / face width
    if (sfLE != null && sfRE != null && idfLE != null && idfRE != null) {
      final sfIOD = _dist(sfLE.position, sfRE.position) / sf.boundingBox.width;
      final idfIOD = _dist(idfLE.position, idfRE.position) / idf.boundingBox.width;
      if (sfIOD > 0 && idfIOD > 0) scores.add(_strictSimilarity(sfIOD, idfIOD, tolerance: 0.07));
    }

    // M2: eye midpoint to nose / face height
    if (sfLE != null && sfRE != null && sfNose != null &&
        idfLE != null && idfRE != null && idfNose != null) {
      final sfEY = (sfLE.position.y + sfRE.position.y) / 2.0;
      final idfEY = (idfLE.position.y + idfRE.position.y) / 2.0;
      final sfEN = (sfNose.position.y - sfEY).abs() / sf.boundingBox.height;
      final idfEN = (idfNose.position.y - idfEY).abs() / idf.boundingBox.height;
      if (sfEN > 0 && idfEN > 0) scores.add(_strictSimilarity(sfEN, idfEN, tolerance: 0.06));
    }

    // M3: nose to mouth / face height
    if (sfNose != null && sfMouth != null && idfNose != null && idfMouth != null) {
      final sfNM = _dist(sfNose.position, sfMouth.position) / sf.boundingBox.height;
      final idfNM = _dist(idfNose.position, idfMouth.position) / idf.boundingBox.height;
      if (sfNM > 0 && idfNM > 0) scores.add(_strictSimilarity(sfNM, idfNM, tolerance: 0.06));
    }

    // M4: cheek span / face width
    if (sfLC != null && sfRC != null && idfLC != null && idfRC != null) {
      final sfCW = _dist(sfLC.position, sfRC.position) / sf.boundingBox.width;
      final idfCW = _dist(idfLC.position, idfRC.position) / idf.boundingBox.width;
      if (sfCW > 0 && idfCW > 0) scores.add(_strictSimilarity(sfCW, idfCW, tolerance: 0.07));
    }

    // M5: eye midpoint to mouth / face height
    if (sfLE != null && sfRE != null && sfMouth != null &&
        idfLE != null && idfRE != null && idfMouth != null) {
      final sfEY = (sfLE.position.y + sfRE.position.y) / 2.0;
      final idfEY = (idfLE.position.y + idfRE.position.y) / 2.0;
      final sfEM = (sfMouth.position.y - sfEY).abs() / sf.boundingBox.height;
      final idfEM = (idfMouth.position.y - idfEY).abs() / idf.boundingBox.height;
      if (sfEM > 0 && idfEM > 0) scores.add(_strictSimilarity(sfEM, idfEM, tolerance: 0.06));
    }

    // M6: left eye aspect ratio from contour
    final sfLEC = sf.contours[FaceContourType.leftEye];
    final idfLEC = idf.contours[FaceContourType.leftEye];
    if (sfLEC != null && idfLEC != null) {
      final a = _computeEAR(sfLEC.points);
      final b = _computeEAR(idfLEC.points);
      if (a > 0 && b > 0) scores.add(_strictSimilarity(a, b, tolerance: 0.10));
    }

    // M7: right eye aspect ratio from contour
    final sfREC = sf.contours[FaceContourType.rightEye];
    final idfREC = idf.contours[FaceContourType.rightEye];
    if (sfREC != null && idfREC != null) {
      final a = _computeEAR(sfREC.points);
      final b = _computeEAR(idfREC.points);
      if (a > 0 && b > 0) scores.add(_strictSimilarity(a, b, tolerance: 0.10));
    }

    // M8: nose bottom width / face width
    final sfNB = sf.contours[FaceContourType.noseBottom];
    final idfNB = idf.contours[FaceContourType.noseBottom];
    if (sfNB != null && idfNB != null &&
        sfNB.points.length >= 2 && idfNB.points.length >= 2) {
      final a = _contourWidth(sfNB.points) / sf.boundingBox.width;
      final b = _contourWidth(idfNB.points) / idf.boundingBox.width;
      if (a > 0 && b > 0) scores.add(_strictSimilarity(a, b, tolerance: 0.08));
    }

    // M9: upper lip width / face width
    final sfUL = sf.contours[FaceContourType.upperLipTop];
    final idfUL = idf.contours[FaceContourType.upperLipTop];
    if (sfUL != null && idfUL != null &&
        sfUL.points.length >= 2 && idfUL.points.length >= 2) {
      final a = _contourWidth(sfUL.points) / sf.boundingBox.width;
      final b = _contourWidth(idfUL.points) / idf.boundingBox.width;
      if (a > 0 && b > 0) scores.add(_strictSimilarity(a, b, tolerance: 0.08));
    }

    if (scores.isEmpty) {
      return const IdentityVerificationResult(
        passed: false,
        similarityScore: 0,
        message: "Impossible d'extraire les traits biométriques. "
            'Reprenez les photos avec plus de luminosité.',
      );
    }

    final matchCount = scores.where((s) => s >= 0.82).length;
    final avgScore = scores.reduce((a, b) => a + b) / scores.length;
    final finalScore = avgScore.clamp(0.0, 1.0);
    final pct = (finalScore * 100).toStringAsFixed(0);
    final required = (scores.length * 0.60).ceil();

    if (matchCount >= required && finalScore >= 0.82) {
      return IdentityVerificationResult(
        passed: true,
        similarityScore: finalScore,
        message: 'Identité confirmée — $matchCount/${scores.length} critères ($pct%)',
      );
    }
    return IdentityVerificationResult(
      passed: false,
      similarityScore: finalScore,
      message: 'Identité non confirmée — $matchCount/${scores.length} critères ($pct%). '
          "Vérifiez la qualité et l'éclairage des photos.",
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  // Score 1.0 when |a-b|/max <= tolerance, drops linearly to 0.0 at 3x tolerance.
  static double _strictSimilarity(double a, double b, {required double tolerance}) {
    if (a <= 0 || b <= 0) return 0;
    final diff = (a - b).abs() / max(a, b);
    if (diff <= tolerance) return 1.0;
    if (diff >= tolerance * 3) return 0.0;
    return 1.0 - ((diff - tolerance) / (tolerance * 2)).clamp(0.0, 1.0);
  }

  static double _computeEAR(List<Point<int>> pts) {
    if (pts.length < 4) return 0;
    double minX = pts[0].x.toDouble(), maxX = pts[0].x.toDouble();
    double minY = pts[0].y.toDouble(), maxY = pts[0].y.toDouble();
    for (final p in pts) {
      if (p.x < minX) minX = p.x.toDouble();
      if (p.x > maxX) maxX = p.x.toDouble();
      if (p.y < minY) minY = p.y.toDouble();
      if (p.y > maxY) maxY = p.y.toDouble();
    }
    final w = maxX - minX;
    final h = maxY - minY;
    return w > 0 ? h / w : 0;
  }

  static double _contourWidth(List<Point<int>> pts) {
    if (pts.isEmpty) return 0;
    double minX = pts[0].x.toDouble(), maxX = pts[0].x.toDouble();
    for (final p in pts) {
      if (p.x < minX) minX = p.x.toDouble();
      if (p.x > maxX) maxX = p.x.toDouble();
    }
    return maxX - minX;
  }

  static double _dist(Point<int> a, Point<int> b) {
    final dx = (a.x - b.x).toDouble();
    final dy = (a.y - b.y).toDouble();
    return sqrt(dx * dx + dy * dy);
  }
}


import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:face_detection_tflite/face_detection_tflite.dart' as fdt;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

enum VerificationStatus { idle, loading, success, failure, error }

/// Result of detecting a face on an ID card — used for UI overlay.
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
  // face_detection_tflite — embedding-based matching (~8 ms/face, 192-dim vectors)
  static fdt.FaceDetector? _embedder;

  // google_mlkit — precise bounding boxes in image coords for the UI overlay
  static FaceDetector? _mlkitDetector;

  static Future<void> initialize() async {
    _embedder ??= await fdt.FaceDetector.create(
      model: fdt.FaceDetectionModel.full,
    );
    _mlkitDetector ??= FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.04,
      ),
    );
  }

  static FaceDetector get _mlkit {
    _mlkitDetector ??= FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.04,
      ),
    );
    return _mlkitDetector!;
  }

  // ── ID card face detection (bounding box for UI overlay) ─────────────────────
  //
  // Uses ML Kit which returns pixel-accurate Rect in image coordinates.

  static Future<IdCardFaceResult> detectFaceOnCard(XFile card) async {
    try {
      final bytes = await File(card.path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        return const IdCardFaceResult(
            found: false, error: 'Image invalide ou corrompue.');
      }
      final imageSize =
          Size(decoded.width.toDouble(), decoded.height.toDouble());

      final faces =
          await _mlkit.processImage(InputImage.fromFilePath(card.path));

      if (faces.isEmpty) {
        return IdCardFaceResult(
          found: false,
          imageSize: imageSize,
          error:
              'Aucun visage détecté sur la CNI.\nAssurez-vous que le recto est bien visible.',
        );
      }

      // Prefer the photo-sized face (not a selfie filling the whole card)
      Face? bestFace;
      double bestArea = -1;
      for (final f in faces) {
        final area = f.boundingBox.width * f.boundingBox.height;
        final imageArea =
            decoded.width.toDouble() * decoded.height.toDouble();
        final areaRatio = area / imageArea;
        final widthRatio = f.boundingBox.width / decoded.width;
        if (areaRatio < 0.03 || widthRatio > 0.85) continue;
        if (area > bestArea) {
          bestArea = area;
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

  // ── Full verification — embedding-based comparison ────────────────────────────
  //
  // face_detection_tflite extracts 192-dim face vectors.
  // FaceDetector.compareFaces returns cosine similarity: >0.6 = same person.

  static Future<IdentityVerificationResult> verify({
    required XFile selfieFront,
    required XFile idCardFront,
    XFile? idCardFaceZone, // recadrage pré-extrait depuis IdCardCameraScreen
  }) async {
    try {
      if (_embedder == null) await initialize();
      final embedder = _embedder!;

      final selfieBytes = await File(selfieFront.path).readAsBytes();

      // Si une zone visage pré-découpée est disponible, on l'utilise directement
      // (plus rapide et plus fiable car le visage est déjà isolé).
      final Uint8List cardBytes;
      if (idCardFaceZone != null) {
        cardBytes = await File(idCardFaceZone.path).readAsBytes();
      } else {
        cardBytes = await File(idCardFront.path).readAsBytes();
      }

      final selfieFaces = await embedder.detectFacesFromBytes(
        selfieBytes,
        mode: fdt.FaceDetectionMode.full,
      );
      final cardFaces = await embedder.detectFacesFromBytes(
        cardBytes,
        mode: fdt.FaceDetectionMode.full,
      );

      if (selfieFaces.isEmpty) {
        return const IdentityVerificationResult(
          passed: false,
          similarityScore: 0,
          message: 'Aucun visage détecté dans le selfie. Reprenez la photo.',
        );
      }
      if (cardFaces.isEmpty) {
        // Fallback : essayer sur la carte complète si la zone recadrée a échoué
        if (idCardFaceZone != null) {
          return verify(
              selfieFront: selfieFront, idCardFront: idCardFront);
        }
        return const IdentityVerificationResult(
          passed: false,
          similarityScore: 0,
          message:
              'Aucun visage détecté sur la CNI. Reprenez la photo du recto.',
        );
      }

      // Selfie: largest face
      final selfieFace =
          selfieFaces.reduce((a, b) => _area(a) >= _area(b) ? a : b);

      // Card face: largest face (zone already pre-cropped if faceZone provided)
      final cardFace = idCardFaceZone != null
          ? cardFaces.reduce((a, b) => _area(a) >= _area(b) ? a : b)
          : _pickCardFace(cardFaces, cardBytes);

      final selfieEmb =
          await embedder.getFaceEmbedding(selfieFace, selfieBytes);
      final cardEmb = await embedder.getFaceEmbedding(cardFace, cardBytes);

      // Cosine similarity: -1.0 to 1.0
      // >0.6 = very likely same person, >0.5 = probably, <0.3 = different
      final similarity = fdt.FaceDetector.compareFaces(selfieEmb, cardEmb);
      final score = similarity.clamp(0.0, 1.0);
      final pct = (score * 100).toStringAsFixed(0);

      if (similarity > 0.6) {
        return IdentityVerificationResult(
          passed: true,
          similarityScore: score,
          message: 'Identité confirmée ($pct% de similarité)',
        );
      }
      if (similarity > 0.5) {
        return IdentityVerificationResult(
          passed: true,
          similarityScore: score,
          message: 'Identité probablement confirmée ($pct%)',
        );
      }
      return IdentityVerificationResult(
        passed: false,
        similarityScore: score,
        message: 'Identité non confirmée ($pct%). '
            "Vérifiez la qualité et l'éclairage des photos.",
      );
    } catch (e) {
      return IdentityVerificationResult(
        passed: false,
        similarityScore: 0,
        message: 'Erreur lors de la vérification: $e',
      );
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  static double _area(fdt.Face f) =>
      f.boundingBox.width * f.boundingBox.height;

  static fdt.Face _pickCardFace(List<fdt.Face> faces, Uint8List imageBytes) {
    if (faces.length == 1) return faces.first;
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      return faces.reduce((a, b) => _area(a) >= _area(b) ? a : b);
    }
    fdt.Face? best;
    double bestArea = -1;
    for (final f in faces) {
      final area = _area(f);
      final widthRatio = f.boundingBox.width / decoded.width;
      if (widthRatio > 0.85) continue;
      if (area > bestArea) {
        bestArea = area;
        best = f;
      }
    }
    return best ?? faces.reduce((a, b) => _area(a) >= _area(b) ? a : b);
  }
}

import 'package:flutter/material.dart';

class AppColors {
  // ── Primaire — Bleu profond (marque, headers, boutons secondaires) ──────────
  static const Color primary            = Color(0xFF1A5FB4);
  static const Color primaryLight       = Color(0x1A1A5FB4); // primary à 10 %
  static const Color primaryMedium      = Color(0x331A5FB4); // primary à 20 %
  static const Color primarySurface     = Color(0xFFEBF2FF); // bleu très clair

  // ── Accent / CTA — Orange corail (1 CTA visible par écran max) ─────────────
  static const Color accent             = Color(0xFFFF7A45);
  static const Color accentLight        = Color(0x1AFF7A45); // accent à 10 %
  static const Color accentMedium       = Color(0x33FF7A45); // accent à 20 %

  // ── Succès / Badge vérifié — Turquoise ─────────────────────────────────────
  static const Color success            = Color(0xFF17A398);
  static const Color successLight       = Color(0x1A17A398); // success à 10 %
  static const Color successSurface     = Color(0xFFE6F7F6); // turquoise très clair
  static const Color successDark        = Color(0xFF0D6E66); // texte sur fond success

  // ── Alerte / Litige — Ambre ────────────────────────────────────────────────
  static const Color warning            = Color(0xFFF5A623);
  static const Color warningLight       = Color(0x1AF5A623); // warning à 10 %
  static const Color warningSurface     = Color(0xFFFEF6E4); // ambre très clair
  static const Color warningDark        = Color(0xFF92400E); // texte sur fond warning

  // ── Erreur — Rouge discret ─────────────────────────────────────────────────
  static const Color danger             = Color(0xFFE5484D);
  static const Color dangerLight        = Color(0x1AE5484D);
  static const Color dangerSurface      = Color(0xFFFFF1F1);
  static const Color dangerBorder       = Color(0xFFFFCDD2);
  static const Color dangerDark         = Color(0xFF991B1B); // texte sur fond danger

  // ── Neutres & Fonds ────────────────────────────────────────────────────────
  static const Color white              = Color(0xFFFFFFFF);
  static const Color surface            = Color(0xFFF2F4F7); // gris très clair
  static const Color surfaceMuted       = Color(0xFFF2F4F7);
  static const Color surfaceSoft        = Color(0xFFF2F4F7);
  static const Color surfaceCard        = white;
  static const Color border             = Color(0xFFE2E6EA);
  static const Color borderStrong       = Color(0xFFCDD2D9);

  // ── Textes ─────────────────────────────────────────────────────────────────
  static const Color textPrimary        = Color(0xFF1F2933); // gris anthracite
  static const Color textStrong         = textPrimary;
  static const Color textSecondary      = Color(0xFF6B7684); // gris moyen
  static const Color textMuted          = Color(0xFF6B7684);
  static const Color textHint           = Color(0xFF9AA5B1);
  static const Color textGhost          = Color(0xFFBDC7CF);

  // ── Ombres ─────────────────────────────────────────────────────────────────
  static const Color shadow             = Color(0x19000000);
  static const Color shadowSoft         = Color(0x0C000000);

  // ── Surfaces contextuelles ─────────────────────────────────────────────────
  static const Color surfaceAccent          = Color(0x1AFF7A45); // corail 10 %
  static const Color surfaceAccentStrong    = Color(0x33FF7A45); // corail 20 %
  static const Color surfaceAccentWeak      = surfaceAccent;
  static const Color surfaceAccentVeryWeak  = surfaceAccent;
  static const Color surfaceSuccess         = successSurface;
  static const Color surfaceInfo            = primarySurface;  // bleu clair = info
  static const Color surfaceWarning         = warningSurface;
  static const Color surfaceWarningStrong   = warning;

  // ── Teintes onboarding (dérivées de la palette marque) ────────────────────
  static const Color onboardingBlue  = Color(0xFFBAD0E9); // primary × 30 %
  static const Color onboardingAmber = Color(0xFFFCE5BD); // warning × 30 %
  static const Color onboardingTeal  = Color(0xFFB9E6E4); // success × 30 %

  // ── Overlays semi-transparents ─────────────────────────────────────────────
  static const Color overlayLight    = Color(0x7FF5F5F5); // surface 50 % opaque
  static const Color overlayMedium   = Color(0x4CF5F5F5); // surface 30 % opaque

  // ── Dégradé splash ────────────────────────────────────────────────────────
  static const Color splashDeep      = Color(0xFF0A2F5C); // bleu nuit (bas du gradient)

  // ── Badges niveaux chauffeur ───────────────────────────────────────────────
  static const Color badgeGold       = Color(0xFFD4AF37); // or
  static const Color badgeBronze     = Color(0xFFCD7F32); // bronze
  static const Color badgeSilver     = Color(0xFF795548); // brun/argent mat
  static const Color badgeYellow     = Color(0xFFFFCC00); // jaune (MTN / badge)

  // ── Blanc semi-transparent (overlays carte / boutons) ─────────────────────
  static const Color white50         = Color(0x80FFFFFF); // blanc 50 %
  static const Color white31         = Color(0x50FFFFFF); // blanc 31 %
  static const Color white25         = Color(0x40FFFFFF); // blanc 25 %

  // ── Alias de compatibilité ─────────────────────────────────────────────────
  static const Color info           = primary;         // notifications info → bleu
  static const Color blue           = primary;
  static const Color blueDark       = Color(0xFF154E96); // bleu plus sombre
  static const Color blueLight      = primarySurface;
  static const Color orange         = accent;           // CTA = orange corail
  static const Color purpleLight    = successSurface;   // ex-purple → turquoise clair
  static const Color completedLight = primaryLight;
}

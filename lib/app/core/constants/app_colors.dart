import 'package:flutter/material.dart';

class AppColors {
	static const Color primary = Color(0xFF7C3AED);
	static const Color success = Color(0xFF6D28D9);
	static const Color accent = Color(0xFFF4B400);
	static const Color warning = Color(0xFFF59E0B);
	static const Color info = Color(0xFF6366F1);
	static const Color blue = Color(0xFF3B82F6);
	static const Color blueDark = Color(0xFF2563EB);

	static const Color white = Color(0xFFFFFFFF);
	static const Color border = Color(0xFFE5E7EB);
	static const Color borderStrong = Color(0xFFD1D5DB);
	static const Color surface = Color(0xFFF9FAFB);
	static const Color surfaceMuted = Color(0xFFF5F5F5);
	static const Color surfaceSoft = Color(0xFFF3F4F6);

	static const Color textPrimary = Color(0xFF111827);
	static const Color textStrong = textPrimary;
	static const Color textSecondary = Color(0xFF374151);
	static const Color textMuted = Color(0xFF4B5563);
	static const Color textHint = Color(0xFF6B7280);
	static const Color textGhost = Color(0xFF9CA3AF);

	static const Color shadow = Color(0x19000000);
	static const Color shadowSoft = Color(0x0C000000);

	static const Color surfaceCard = white;
	static const Color surfaceAccent = Color(0x0C7C3AED);
	static const Color surfaceAccentStrong = Color(0x197C3AED);
	static const Color surfaceAccentWeak = Color(0x337C3AED);
	static const Color surfaceAccentVeryWeak = surfaceAccent;
	static const Color surfaceSuccess = Color(0xFFDCFCE7);
	static const Color surfaceInfo = Color(0xFFDBEAFE);
	static const Color surfaceWarning = Color(0xFFF3E8FF);
	static const Color surfaceWarningStrong = warning;

	static const Color blueLight = surfaceInfo;
	static const Color successLight = surfaceSuccess;
	static const Color purpleLight = surfaceWarning;

	// ── Danger (rouge) ─────────────────────────────────────────────────────────
	static const Color danger       = Color(0xFFE53935);
	static const Color dangerLight  = Color(0x1AE53935);
	static const Color dangerSurface = Color(0xFFFFF1F1);
	static const Color dangerBorder  = Color(0xFFFFCDD2);

	// ── Orange ─────────────────────────────────────────────────────────────────
	static const Color orange       = Color(0xFFFB923C);

	// ── Accent (ambre/jaune) avec opacité pré-calculée ────────────────────────
	static const Color accentLight  = Color(0x1AF4B400); // accent à 10 %
	static const Color accentMedium = Color(0x33F4B400); // accent à 20 %

	// ── Completed (bleu) ──────────────────────────────────────────────────────
	static const Color completedLight = Color(0x193B82F6); // blue à 10 %
}

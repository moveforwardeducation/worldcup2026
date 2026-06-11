import 'package:flutter/material.dart';

/// Core palette for the Road to World Cup 2026 app.
/// Dark navy football theme with bright green CTAs and gold rewards.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color bgDeep = Color(0xFF0A1230);
  static const Color bgTop = Color(0xFF0E1B3D);
  static const Color surface = Color(0xFF16234A);
  static const Color surfaceAlt = Color(0xFF1B2C5C);
  static const Color surfaceHigh = Color(0xFF223568);
  static const Color divider = Color(0xFF2A3D70);

  // Brand accents
  static const Color primaryGreen = Color(0xFF22C55E);
  static const Color primaryGreenDark = Color(0xFF16A34A);
  static const Color gold = Color(0xFFFBBF24);
  static const Color goldDark = Color(0xFFD97706);
  static const Color streakOrange = Color(0xFFF97316);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFFB8C2DC);
  static const Color textMuted = Color(0xFF7A88B0);

  // Rarity
  static const Color rarityCommon = Color(0xFF94A3B8);
  static const Color rarityRare = Color(0xFF3B82F6);
  static const Color rarityEpic = Color(0xFFA855F7);
  static const Color rarityLegendary = Color(0xFFFBBF24);

  // Translucent "glass" panels that float on the background.
  static final Color glassFill = const Color(0xFF1A2A55).withValues(alpha: 0.55);
  static final Color glassFillStrong =
      const Color(0xFF1A2A55).withValues(alpha: 0.72);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.08);

  // Gradients
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF15265C), bgTop, bgDeep],
    stops: [0.0, 0.35, 1.0],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E3A8A), Color(0xFF0F1E48)],
  );

  static const LinearGradient greenCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF15803D)],
  );

  static const LinearGradient goldCta = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
  );
}

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum Rarity { common, rare, epic, legendary }

extension RarityX on Rarity {
  String get label {
    switch (this) {
      case Rarity.common:
        return 'Common';
      case Rarity.rare:
        return 'Rare';
      case Rarity.epic:
        return 'Epic';
      case Rarity.legendary:
        return 'Legendary';
    }
  }

  Color get color {
    switch (this) {
      case Rarity.common:
        return AppColors.rarityCommon;
      case Rarity.rare:
        return AppColors.rarityRare;
      case Rarity.epic:
        return AppColors.rarityEpic;
      case Rarity.legendary:
        return AppColors.rarityLegendary;
    }
  }

  /// Card face gradient for this rarity.
  List<Color> get cardGradient {
    switch (this) {
      case Rarity.common:
        return const [Color(0xFF3A4A6B), Color(0xFF26334F)];
      case Rarity.rare:
        return const [Color(0xFF2B5BA6), Color(0xFF1B3666)];
      case Rarity.epic:
        return const [Color(0xFF7E3FC0), Color(0xFF4A2374)];
      case Rarity.legendary:
        return const [Color(0xFFFDE68A), Color(0xFFD97706)];
    }
  }

  /// Whether to use dark text on the card face (legendary is light gold).
  bool get darkText => this == Rarity.legendary;

  /// Drop chance weight when opening packs (higher = more common).
  int get dropWeight {
    switch (this) {
      case Rarity.common:
        return 50;
      case Rarity.rare:
        return 30;
      case Rarity.epic:
        return 15;
      case Rarity.legendary:
        return 5;
    }
  }
}

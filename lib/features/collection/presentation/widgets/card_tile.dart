import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/collectible_card.dart';
import '../../../../data/models/rarity.dart';

/// A 3D, game-style collectible card: beveled frame, glossy top sheen and a
/// drop shadow for depth.
class CardTile extends StatelessWidget {
  const CardTile({
    super.key,
    required this.card,
    required this.unlocked,
    required this.onTap,
  });

  final CollectibleCard card;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = card.rarity.darkText ? const Color(0xFF5B3A00) : Colors.white;
    final frameColor =
        unlocked ? card.rarity.color : const Color(0xFF3A4A6B);
    return _build(fg, frameColor);
  }

  Widget _build(Color fg, Color frameColor) {
    final faceColors = unlocked
        ? card.rarity.cardGradient
        : const [Color(0xFF243152), Color(0xFF18233E)];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          // Beveled metal frame (light top-left → dark bottom-right).
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_lighten(frameColor, 0.45), _darken(frameColor, 0.32)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.40),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
            if (unlocked && card.rarity == Rarity.legendary)
              BoxShadow(
                color: card.rarity.color.withValues(alpha: 0.45),
                blurRadius: 18,
              ),
          ],
        ),
        padding: const EdgeInsets.all(4.5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Stack(
            children: [
              // Card face.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: faceColors,
                    ),
                  ),
                ),
              ),
              // Glossy top sheen.
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0.30),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.5],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: unlocked ? _unlocked(fg) : _locked(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unlocked(Color fg) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              card.ratingLabel,
              style: TextStyle(
                  color: fg, fontWeight: FontWeight.w900, fontSize: 13),
            ),
            const Spacer(),
            Icon(_typeIcon, color: fg.withValues(alpha: 0.85), size: 14),
          ],
        ),
        Expanded(child: Center(child: _emblem(fg))),
        // Name plate for readability.
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                card.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: fg, fontWeight: FontWeight.w800, fontSize: 12),
              ),
              const SizedBox(height: 1),
              Text(
                card.rarity.label.toUpperCase(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: fg.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w800,
                  fontSize: 8,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _emblem(Color fg) {
    switch (card.type) {
      case CardType.team:
        return Text(card.emoji ?? '⚽', style: const TextStyle(fontSize: 42));
      case CardType.player:
        return Icon(Icons.person_rounded, color: fg, size: 48);
      case CardType.stadium:
        return Icon(Icons.stadium_rounded, color: fg, size: 44);
    }
  }

  Widget _locked() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(_typeIcon, color: AppColors.textMuted, size: 16),
        const Spacer(),
        Icon(Icons.lock_rounded,
            color: Colors.white.withValues(alpha: 0.30), size: 34),
        const Spacer(),
        const Text(
          '???',
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 6),
      ],
    );
  }

  IconData get _typeIcon {
    switch (card.type) {
      case CardType.team:
        return Icons.flag_rounded;
      case CardType.player:
        return Icons.person_rounded;
      case CardType.stadium:
        return Icons.stadium_rounded;
    }
  }

  Color _lighten(Color c, double a) => Color.lerp(c, Colors.white, a) ?? c;
  Color _darken(Color c, double a) => Color.lerp(c, Colors.black, a) ?? c;
}

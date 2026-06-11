import 'package:flutter/material.dart';

import '../../../../data/models/rarity.dart';

/// A fanned trio of mini cards — the Collection screen's banner illustration.
class CardFanEmblem extends StatelessWidget {
  const CardFanEmblem({super.key, this.size = 104});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Transform.translate(
            offset: Offset(-size * 0.26, size * 0.04),
            child: Transform.rotate(
              angle: -0.34,
              child: _mini(Rarity.rare, Icons.flag_rounded),
            ),
          ),
          Transform.translate(
            offset: Offset(size * 0.26, size * 0.04),
            child: Transform.rotate(
              angle: 0.34,
              child: _mini(Rarity.epic, Icons.person_rounded),
            ),
          ),
          Transform.translate(
            offset: Offset(0, -size * 0.06),
            child: _mini(Rarity.legendary, Icons.emoji_events_rounded),
          ),
        ],
      ),
    );
  }

  Widget _mini(Rarity rarity, IconData icon) {
    final fg = rarity.darkText ? const Color(0xFF5B3A00) : Colors.white;
    return Container(
      width: size * 0.5,
      height: size * 0.72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: rarity.cardGradient,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: rarity.color, width: 1.4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: fg, size: size * 0.24),
    );
  }
}

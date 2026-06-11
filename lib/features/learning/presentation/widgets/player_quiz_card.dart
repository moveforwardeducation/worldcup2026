import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// A FUT-style player card with the name hidden behind a "?". Players are
/// identified by their stats, position and rating.
class PlayerQuizCard extends StatelessWidget {
  const PlayerQuizCard({
    super.key,
    required this.overall,
    required this.position,
    required this.goals,
    required this.matches,
    required this.assists,
    this.width = 210,
  });

  final int overall;
  final String position;
  final int goals;
  final int matches;
  final int assists;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFDE68A), Color(0xFFD97706)],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$overall',
                    style: const TextStyle(
                      color: Color(0xFF5B3A00),
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    _posShort(position),
                    style: const TextStyle(
                      color: Color(0xFF7A4E00),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.sports_soccer_rounded,
                  color: Color(0xFF7A4E00), size: 22),
            ],
          ),
          const SizedBox(height: 8),
          // Silhouette / hidden identity.
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xFF5B3A00).withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                  color: const Color(0xFF5B3A00).withValues(alpha: 0.4), width: 2),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person_rounded,
                color: Color(0xFF7A4E00), size: 56),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF5B3A00).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '? ? ?',
              style: TextStyle(
                color: Color(0xFF5B3A00),
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 3,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(label: 'Goals', value: '$goals'),
              _divider(),
              _Stat(label: 'Apps', value: '$matches'),
              _divider(),
              _Stat(label: 'Assists', value: '$assists'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: const Color(0xFF5B3A00).withValues(alpha: 0.25),
      );

  String _posShort(String position) {
    switch (position.toLowerCase()) {
      case 'forward':
        return 'FWD';
      case 'midfielder':
        return 'MID';
      case 'defender':
        return 'DEF';
      case 'goalkeeper':
        return 'GK';
      default:
        return position.toUpperCase();
    }
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF5B3A00),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7A4E00),
            fontWeight: FontWeight.w700,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

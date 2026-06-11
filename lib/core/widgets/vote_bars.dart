import 'package:flutter/material.dart';

import '../services/vote_math.dart';
import '../theme/app_colors.dart';

/// Renders a community-vote split: one row per option with a label, an
/// animated fill bar and a percentage. The user's choice is highlighted.
class VoteBars extends StatelessWidget {
  const VoteBars({
    super.key,
    required this.labels,
    required this.counts,
    this.userChoice,
    this.optionColors,
    this.onSelect,
  });

  final List<String> labels;
  final List<int> counts;
  final int? userChoice;
  final List<Color>? optionColors;

  /// When provided, each row is tappable (to cast/change a vote).
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    final pcts = VoteMath.percentages(counts);
    final total = VoteMath.total(counts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          onSelect == null
              ? _row(i, pcts[i])
              : GestureDetector(
                  onTap: () => onSelect!(i),
                  behavior: HitTestBehavior.opaque,
                  child: _row(i, pcts[i]),
                ),
          if (i != labels.length - 1) const SizedBox(height: 8),
        ],
        const SizedBox(height: 8),
        Text(
          '${_fmt(total)} votes',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _row(int i, int pct) {
    final mine = userChoice == i;
    final color = optionColors != null && i < optionColors!.length
        ? optionColors![i]
        : (mine ? AppColors.primaryGreen : AppColors.info);

    return LayoutBuilder(
      builder: (context, c) {
        return Stack(
          children: [
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: mine
                      ? color.withValues(alpha: 0.8)
                      : Colors.white.withValues(alpha: 0.08),
                  width: mine ? 1.6 : 1,
                ),
              ),
            ),
            // Fill.
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              height: 38,
              width: (c.maxWidth) * (pct / 100),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(
              height: 38,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    if (mine) ...[
                      Icon(Icons.check_circle_rounded, color: color, size: 16),
                      const SizedBox(width: 6),
                    ],
                    Expanded(
                      child: Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: mine ? FontWeight.w800 : FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '$pct%',
                      style: TextStyle(
                        color: mine ? color : AppColors.textSecondary,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

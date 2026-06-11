import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/vote_math.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vote_bars.dart';
import '../../../../data/remote/firebase_providers.dart';
import '../predictions_providers.dart';

/// A unified prediction card (match or group): shows the crowd vote split,
/// lets the user pick/change while open, locks at kickoff, and shows the
/// graded result once resolved.
class PredictionCard extends ConsumerWidget {
  const PredictionCard({
    super.key,
    required this.pollId,
    required this.title,
    required this.statusLine,
    required this.optionLabels,
    required this.status,
    required this.pick,
    required this.rewardText,
    this.correctIndex,
    this.onSelect,
  });

  final String pollId;
  final String title;
  final String statusLine;
  final List<String> optionLabels;
  final PredStatus status;
  final int? pick;
  final String rewardText;
  final int? correctIndex; // for resolved
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(pollCountsProvider(pollId)).valueOrNull ?? const {};
    final counts = VoteMath.blend(
        pollId: pollId,
        options: optionLabels.length,
        live: live,
        userChoice: pick);
    final resolved = status == PredStatus.resolved;
    final correct = resolved && pick != null && pick == correctIndex;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15),
                ),
              ),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 4),
          Text(statusLine,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 14),
          VoteBars(
            labels: optionLabels,
            counts: counts,
            userChoice: pick,
            onSelect: status == PredStatus.open ? onSelect : null,
          ),
          const SizedBox(height: 10),
          if (status == PredStatus.open)
            Row(
              children: [
                Icon(
                  pick == null
                      ? Icons.how_to_vote_rounded
                      : Icons.edit_rounded,
                  color: AppColors.gold,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  pick == null
                      ? 'Tap to predict · $rewardText if correct'
                      : 'Tap another option to change your pick',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            )
          else if (status == PredStatus.locked)
            Row(
              children: const [
                Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 14),
                SizedBox(width: 6),
                Text('Locked · awaiting result',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            )
          else
            _resolvedBanner(correct, pick != null),
        ],
      ),
    );
  }

  Widget _statusChip() {
    final (label, color) = switch (status) {
      PredStatus.open => ('OPEN', AppColors.primaryGreen),
      PredStatus.locked => ('LOCKED', AppColors.textMuted),
      PredStatus.resolved => ('FINAL', AppColors.gold),
      PredStatus.hidden => ('', AppColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w900, fontSize: 10)),
    );
  }

  Widget _resolvedBanner(bool correct, bool didPick) {
    final actual =
        correctIndex != null ? optionLabels[correctIndex!] : '—';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (correct ? AppColors.primaryGreen : AppColors.danger)
            .withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: correct ? AppColors.primaryGreen : AppColors.danger,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              !didPick
                  ? 'Result: $actual'
                  : correct
                      ? 'Correct! $rewardText · Result: $actual'
                      : 'Wrong · Result: $actual',
              style: TextStyle(
                color: correct ? AppColors.primaryGreen : AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

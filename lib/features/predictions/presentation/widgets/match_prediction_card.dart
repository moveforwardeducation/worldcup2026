import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/vote_math.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vote_bars.dart';
import '../../../../data/remote/firebase_providers.dart';
import '../predictions_providers.dart';

/// Match prediction card: Flag A  vs  Flag B, three pick buttons
/// (A Win / Draw / B Win), and once picked the community vote split appears.
class MatchPredictionCard extends ConsumerWidget {
  const MatchPredictionCard({
    super.key,
    required this.pollId,
    required this.dateLabel,
    required this.statusLine,
    required this.flagA,
    required this.nameA,
    required this.flagB,
    required this.nameB,
    required this.scoreA,
    required this.scoreB,
    required this.status,
    required this.pick,
    this.onSelect,
  });

  final String pollId;
  final String dateLabel;
  final String statusLine;
  final String flagA;
  final String nameA;
  final String flagB;
  final String nameB;
  final int scoreA;
  final int scoreB;
  final PredStatus status;
  final int? pick;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(pollCountsProvider(pollId)).valueOrNull ?? const {};
    final counts = VoteMath.blend(
        pollId: pollId, options: 3, live: live, userChoice: pick);
    final resolved = status == PredStatus.resolved;
    final correctIndex = scoreA > scoreB ? 0 : (scoreA == scoreB ? 1 : 2);
    final correct = resolved && pick != null && pick == correctIndex;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(dateLabel,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12)),
              ),
              _statusChip(),
            ],
          ),
          const SizedBox(height: 14),
          // Matchup.
          Row(
            children: [
              Expanded(child: _teamSide(flagA, nameA)),
              Column(
                children: [
                  if (resolved)
                    Text('$scoreA - $scoreB',
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 22))
                  else
                    const Text('VS',
                        style: TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w900,
                            fontSize: 20)),
                ],
              ),
              Expanded(child: _teamSide(flagB, nameB)),
            ],
          ),
          const SizedBox(height: 14),
          _body(counts, correct, correctIndex),
        ],
      ),
    );
  }

  Widget _teamSide(String flag, String name) {
    return Column(
      children: [
        Text(flag, style: const TextStyle(fontSize: 46)),
        const SizedBox(height: 6),
        Text(name.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 13)),
      ],
    );
  }

  Widget _body(List<int> counts, bool correct, int correctIndex) {
    // Open + not yet picked → three pick buttons.
    if (status == PredStatus.open && pick == null) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _pickButton('$flagA Win', 0)),
              const SizedBox(width: 8),
              Expanded(child: _pickButton('Draw', 1)),
              const SizedBox(width: 8),
              Expanded(child: _pickButton('$flagB Win', 2)),
            ],
          ),
          const SizedBox(height: 10),
          Text('$statusLine · +$kPredictionXp XP if correct',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      );
    }

    // Otherwise show the vote split.
    final labels = [nameA.toUpperCase(), 'Draw', nameB.toUpperCase()];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VoteBars(
          labels: labels,
          counts: counts,
          userChoice: pick,
          onSelect: status == PredStatus.open ? onSelect : null,
        ),
        const SizedBox(height: 10),
        if (status == PredStatus.open)
          Text('Tap to change · $statusLine',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12))
        else if (status == PredStatus.locked)
          Row(
            children: const [
              Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 14),
              SizedBox(width: 6),
              Text('Locked · awaiting result',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          )
        else
          _resolvedBanner(correct),
      ],
    );
  }

  Widget _pickButton(String label, int option) {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onSelect == null ? null : () => onSelect!(option),
          child: Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.glassFillStrong,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
        ),
      ),
    );
  }

  Widget _resolvedBanner(bool correct) {
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
          Icon(correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: correct ? AppColors.primaryGreen : AppColors.danger,
              size: 18),
          const SizedBox(width: 8),
          Text(
            correct ? 'Correct!  +$kPredictionXp XP' : 'Not this time',
            style: TextStyle(
              color: correct ? AppColors.primaryGreen : AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 13,
            ),
          ),
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
}

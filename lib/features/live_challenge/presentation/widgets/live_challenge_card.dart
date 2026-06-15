import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/progression_service.dart';
import '../../../../core/services/vote_math.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/vote_bars.dart';
import '../../../../data/models/live_challenge.dart';
import '../../../../data/remote/firebase_providers.dart';
import '../live_challenge_providers.dart';

const int kLiveVoteXp = 5;

/// Live "Fan Pulse" card for a single in-play match. Lists every Fan-Pulse
/// moment for the match: unanswered ones show YES/NO buttons; answered ones
/// lock into a read-only result (your pick + the crowd split). The card stays
/// visible for as long as the match is live.
class LiveMatchCard extends ConsumerWidget {
  const LiveMatchCard({super.key, required this.match});

  final LiveMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(answeredLiveProvider);
    final allAnswered = match.moments.every((m) => state.isAnswered(m.id));

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A2A55), Color(0xFF0F1E48)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.info.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.info,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 5),
                    Text('LIVE',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 1)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(match.matchLabel.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Text(match.moments.first.minute,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          for (var i = 0; i < match.moments.length; i++) ...[
            const SizedBox(height: 16),
            if (i > 0)
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
            if (i > 0) const SizedBox(height: 16),
            _MomentBlock(challenge: match.moments[i]),
          ],
          if (allAnswered) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.primaryGreen, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "You've made all your calls — match still live",
                    style: TextStyle(
                        color: AppColors.textSecondary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// One Fan-Pulse moment: interactive (YES/NO buttons) until answered, then a
/// read-only result showing the user's pick and the crowd split.
class _MomentBlock extends ConsumerWidget {
  const _MomentBlock({required this.challenge});

  final LiveChallenge challenge;

  void _vote(WidgetRef ref, int option) {
    HapticFeedback.lightImpact();
    ref.read(progressionServiceProvider).awardXp(kLiveVoteXp);
    ref.read(voteRepositoryProvider).recordVote(
          pollId: 'live_${challenge.id}',
          option: option,
        );
    ref.read(answeredLiveProvider.notifier).mark(
          id: challenge.id,
          answeredYes: option == 0,
          correct: false,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(answeredLiveProvider);
    final answered = state.isAnswered(challenge.id);
    final choice = state.choiceFor(challenge.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          challenge.question,
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (!answered)
          _voteButtons(ref)
        else
          _result(ref, choice),
      ],
    );
  }

  Widget _voteButtons(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What do fans think?  +$kLiveVoteXp XP to vote',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
                child: _voteButton(
                    'YES', AppColors.primaryGreen, () => _vote(ref, 0))),
            const SizedBox(width: 12),
            Expanded(
                child:
                    _voteButton('NO', AppColors.danger, () => _vote(ref, 1))),
          ],
        ),
      ],
    );
  }

  Widget _result(WidgetRef ref, int? choice) {
    final pollId = 'live_${challenge.id}';
    final live = ref.watch(pollCountsProvider(pollId)).valueOrNull ?? const {};
    final counts = VoteMath.blend(
      pollId: pollId,
      options: 2,
      live: live,
      userChoice: choice,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VoteBars(
          labels: const ['Yes', 'No'],
          counts: counts,
          userChoice: choice,
          optionColors: const [AppColors.primaryGreen, AppColors.danger],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.how_to_vote_rounded,
                color: AppColors.gold, size: 14),
            const SizedBox(width: 6),
            Text(
              'Your call: ${choice == 1 ? 'NO' : 'YES'}',
              style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                  fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _voteButton(String label, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 16)),
        ),
      ),
    );
  }
}

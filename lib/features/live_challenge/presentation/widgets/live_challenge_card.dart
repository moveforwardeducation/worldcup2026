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

/// Live "Fan Pulse": cast a YES/NO vote and instantly see the crowd split.
/// No grading — it's social sentiment, not a graded prediction.
class LiveChallengeCard extends ConsumerStatefulWidget {
  const LiveChallengeCard({super.key, required this.challenge});

  final LiveChallenge challenge;

  @override
  ConsumerState<LiveChallengeCard> createState() => _LiveChallengeCardState();
}

class _LiveChallengeCardState extends ConsumerState<LiveChallengeCard> {
  int? _choice; // 0 = YES, 1 = NO

  void _vote(int option) {
    setState(() => _choice = option);
    HapticFeedback.lightImpact();
    ref.read(progressionServiceProvider).awardXp(kLiveVoteXp);
    ref.read(voteRepositoryProvider).recordVote(
          pollId: 'live_${widget.challenge.id}',
          option: option,
        );
  }

  Future<void> _dismiss() async {
    await ref.read(answeredLiveProvider.notifier).mark(
          id: widget.challenge.id,
          answeredYes: _choice == 0,
          correct: false,
        );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.challenge;
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
                child: Text(c.matchLabel.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 14)),
              ),
              const SizedBox(width: 8),
              Text(c.minute,
                  style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            c.question,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 17),
          ),
          const SizedBox(height: 14),
          _choice == null ? _voteButtons() : _result(),
        ],
      ),
    );
  }

  Widget _voteButtons() {
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
                child:
                    _voteButton('YES', AppColors.primaryGreen, () => _vote(0))),
            const SizedBox(width: 12),
            Expanded(
                child: _voteButton('NO', AppColors.danger, () => _vote(1))),
          ],
        ),
      ],
    );
  }

  Widget _result() {
    final pollId = 'live_${widget.challenge.id}';
    final live = ref.watch(pollCountsProvider(pollId)).valueOrNull ?? const {};
    final counts = VoteMath.blend(
      pollId: pollId,
      options: 2,
      live: live,
      userChoice: _choice,
    );
    return Column(
      children: [
        VoteBars(
          labels: const ['Yes', 'No'],
          counts: counts,
          userChoice: _choice,
          optionColors: const [AppColors.primaryGreen, AppColors.danger],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _dismiss,
          child: const Text('Continue →',
              style: TextStyle(
                  color: AppColors.gold, fontWeight: FontWeight.w800)),
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

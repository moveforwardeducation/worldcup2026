import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/player.dart';
import '../../../../data/models/question.dart';
import '../../../../data/models/team_jersey.dart';
import '../../../../data/providers.dart';
import 'player_quiz_card.dart';
import 'team_jersey_view.dart';

/// Renders the artwork for a question based on its type, looking up the
/// referenced team/player/stadium from the seed catalogues.
class QuestionVisual extends ConsumerWidget {
  const QuestionVisual({super.key, required this.question});

  final Question question;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    switch (question.type) {
      case QuestionType.team:
        final team = ref.watch(teamByIdProvider(question.subjectId ?? ''));
        if (team == null) return const _Fallback();
        final specs = ref.watch(jerseysByCodeProvider).valueOrNull;
        final spec = specs?[team.code.toUpperCase()] ??
            TeamJersey.fromColors(
              name: team.name,
              body: team.primaryColor,
              accent: team.secondaryColor,
            );
        return JerseyView(spec: spec, size: 200);
      case QuestionType.player:
        final players = ref.watch(playersProvider).valueOrNull ?? const [];
        Player? player;
        for (final p in players) {
          if (p.id == question.subjectId) {
            player = p;
            break;
          }
        }
        if (player == null) return const _Fallback();
        return PlayerQuizCard(
          overall: player.overall,
          position: player.position,
          goals: player.goals,
          matches: player.matches,
          assists: player.assists,
        );
      case QuestionType.stadium:
        return const _StadiumBadge();
      case QuestionType.history:
        return _HistoryVisual(category: question.historyCategory ?? 'History');
    }
  }
}

class _HistoryVisual extends StatelessWidget {
  const _HistoryVisual({required this.category});
  final String category;

  @override
  Widget build(BuildContext context) {
    final icon = switch (category) {
      'Champions' => Icons.emoji_events_rounded,
      'Records' => Icons.timeline_rounded,
      'Top Scorers' => Icons.sports_soccer_rounded,
      'Famous Moments' => Icons.auto_awesome_rounded,
      'Hosts' => Icons.public_rounded,
      _ => Icons.menu_book_rounded,
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.3),
                blurRadius: 24,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.gold, size: 56),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _StadiumBadge extends StatelessWidget {
  const _StadiumBadge();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGreen, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                blurRadius: 24,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.stadium_rounded,
              color: AppColors.primaryGreen, size: 56),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'STADIUM',
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _Fallback extends StatelessWidget {
  const _Fallback();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 120,
      child: Icon(Icons.sports_soccer_rounded,
          color: AppColors.textMuted, size: 64),
    );
  }
}

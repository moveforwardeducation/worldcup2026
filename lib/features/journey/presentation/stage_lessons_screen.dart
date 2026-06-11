import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../../data/models/lesson.dart';
import '../../../data/models/stage.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../domain/journey_config.dart';
import 'journey_providers.dart';
import 'widgets/lesson_card.dart';
import 'widgets/stage_visuals.dart';

/// The lesson list for one stage — a column of level-select cards.
class StageLessonsScreen extends ConsumerWidget {
  const StageLessonsScreen({super.key, required this.stageIndex});

  final int stageIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stages = ref.watch(journeyProvider);
    final repo = ref.watch(journeyRepositoryProvider);

    if (stageIndex < 0 || stageIndex >= stages.length) {
      return const Scaffold(
        backgroundColor: AppColors.bgDeep,
        body: Center(
          child: Text('Stage not found',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
      );
    }

    final stage = stages[stageIndex];
    final kind = stage.kind;
    final lessonCount = JourneyConfig.lessonsIn(kind);
    const maxXpPerLesson = JourneyConfig.questionsPerLesson * 10 + 50;

    var earnedStars = 0;
    for (var i = 0; i < lessonCount; i++) {
      earnedStars +=
          repo.starsFor(Lesson(stage: kind, index: i, questionCount: 0).id);
    }

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                itemCount: lessonCount + 1,
                separatorBuilder: (_, i) =>
                    SizedBox(height: i == 0 ? 16 : 12),
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return _StageHeader(
                      stage: stage,
                      earnedStars: earnedStars,
                      maxStars: lessonCount * 3,
                    );
                  }
                  final lessonIndex = i - 1;
              final lessonId =
                  Lesson(stage: kind, index: lessonIndex, questionCount: 0).id;
              final completed = repo.isCompleted(lessonId);
              final unlocked =
                  repo.isLessonUnlocked(kind, lessonIndex, stage.unlocked);
              final state = completed
                  ? LessonCardState.completed
                  : unlocked
                      ? LessonCardState.play
                      : LessonCardState.locked;
              return LessonCard(
                number: lessonIndex + 1,
                state: state,
                stars: repo.starsFor(lessonId),
                questionCount: JourneyConfig.questionsPerLesson,
                maxXp: maxXpPerLesson,
                onTap: () => context.push(
                  '/lesson',
                  extra: Lesson(
                    stage: kind,
                    index: lessonIndex,
                    questionCount: JourneyConfig.questionsPerLesson,
                  ),
                ),
              );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stage header: a full-bleed BannerHeader (consistent with other screens)
/// plus a progress row + bar.
class _StageHeader extends StatelessWidget {
  const _StageHeader({
    required this.stage,
    required this.earnedStars,
    required this.maxStars,
  });

  final JourneyStage stage;
  final int earnedStars;
  final int maxStars;

  @override
  Widget build(BuildContext context) {
    final kind = stage.kind;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BannerHeader(
          title: kind.title,
          subtitle: '$earnedStars / $maxStars stars earned',
          backdrop: const Confetti(),
          emblem: _StageEmblem(icon: kind.icon),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '${stage.completedLessons} of ${stage.totalLessons} complete',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${(stage.progress * 100).round()}%',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppProgressBar(progress: stage.progress),
      ],
    );
  }
}

class _StageEmblem extends StatelessWidget {
  const _StageEmblem({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 86,
      height: 86,
      decoration: BoxDecoration(
        gradient: AppColors.goldCta,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: Colors.white, size: 44),
    );
  }
}

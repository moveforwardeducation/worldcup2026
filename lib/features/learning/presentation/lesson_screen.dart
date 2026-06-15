import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/xp_rules.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/services/progression_service.dart';
import '../../../core/services/stats_repository.dart';
import '../../packs/presentation/packs_providers.dart';
import '../../../data/models/lesson.dart';
import '../../../data/models/question.dart';
import '../../journey/presentation/journey_providers.dart';
import 'widgets/option_button.dart';
import 'widgets/question_visual.dart';

/// Loads the question factory, then hands off to the interactive player.
class LessonScreen extends ConsumerWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryAsync = ref.watch(questionFactoryProvider);
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: factoryAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          ),
          error: (e, _) => Center(
            child: Text('Could not load lesson.\n$e',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          data: (factory) {
            final questions = factory.buildLesson(
              stage: lesson.stage,
              lessonIndex: lesson.index,
              count: lesson.questionCount,
            );
            return _LessonPlayer(lesson: lesson, questions: questions);
          },
        ),
      ),
    );
  }
}

const int _maxLives = 3;
const Duration _questionTime = Duration(seconds: 20);

class _LessonPlayer extends ConsumerStatefulWidget {
  const _LessonPlayer({required this.lesson, required this.questions});

  final Lesson lesson;
  final List<Question> questions;

  @override
  ConsumerState<_LessonPlayer> createState() => _LessonPlayerState();
}

class _LessonPlayerState extends ConsumerState<_LessonPlayer>
    with TickerProviderStateMixin {
  int _current = 0;
  int? _selected;
  bool _revealed = false;
  int _correct = 0;
  int _xpEarned = 0;
  int _lives = _maxLives;
  final Set<int> _eliminated = {};
  int _fiftyLeft = 1;
  int _extraTimeLeft = 1;

  bool _leveledUp = false;
  int _newLevel = 0;
  bool _navigating = false;

  late final AnimationController _timer;
  late final AnimationController _xpPop;

  Question get _q => widget.questions[_current];
  int get _total => widget.questions.length;

  @override
  void initState() {
    super.initState();
    _timer = AnimationController(vsync: this, duration: _questionTime)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed && !_revealed) {
          _answer(null); // time ran out
        }
      });
    _xpPop = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _startTimer();
  }

  @override
  void dispose() {
    _timer.dispose();
    _xpPop.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer
      ..reset()
      ..forward();
  }

  void _answer(int? index) {
    if (_revealed) return;
    _timer.stop();
    final correct = index != null && index == _q.correctIndex;
    setState(() {
      _selected = index;
      _revealed = true;
      if (correct) {
        _correct++;
        final r = ref.read(progressionServiceProvider).awardXp(
              XpRules.xpCorrectAnswer,
            );
        _xpEarned += XpRules.xpCorrectAnswer;
        if (r.leveledUp) {
          _leveledUp = true;
          _newLevel = r.newLevel;
        }
        _xpPop
          ..reset()
          ..forward();
        HapticFeedback.lightImpact();
      } else {
        _lives = (_lives - 1).clamp(0, _maxLives);
        HapticFeedback.heavyImpact();
      }
    });

    final outOfLives = _lives <= 0;
    Future.delayed(Duration(milliseconds: outOfLives ? 1200 : 1000), () {
      if (!mounted) return;
      if (outOfLives) {
        _finish(failed: true);
      } else {
        _next();
      }
    });
  }

  void _next() {
    if (_current >= _total - 1) {
      _finish(failed: false);
      return;
    }
    setState(() {
      _current++;
      _selected = null;
      _revealed = false;
      _eliminated.clear();
    });
    _startTimer();
  }

  void _useFiftyFifty() {
    if (_fiftyLeft <= 0 || _revealed) return;
    final wrong = <int>[];
    for (var i = 0; i < _q.options.length; i++) {
      if (i != _q.correctIndex) wrong.add(i);
    }
    wrong.shuffle();
    setState(() {
      _eliminated
        ..add(wrong[0])
        ..add(wrong[1]);
      _fiftyLeft--;
    });
  }

  void _useExtraTime() {
    if (_extraTimeLeft <= 0 || _revealed) return;
    // Wind the timer back by ~10s (capped at full).
    final back = 10 / _questionTime.inSeconds;
    setState(() {
      _extraTimeLeft--;
      _timer.value = (_timer.value - back).clamp(0.0, 1.0);
    });
  }

  Future<void> _finish({required bool failed}) async {
    if (_navigating) return;
    _navigating = true;
    _timer.stop();

    final stars = failed ? 0 : LessonResult.starsFor(_correct, _total);
    final perfectBonus = (!failed && _correct == _total) ? XpRules.xpPerfectLesson : 0;

    if (perfectBonus > 0) {
      final r = ref.read(progressionServiceProvider).awardXp(perfectBonus);
      _xpEarned += perfectBonus;
      if (r.leveledUp) {
        _leveledUp = true;
        _newLevel = r.newLevel;
        // Reward a mystery pack for each level gained.
        await ref.read(packsCountProvider.notifier).add(1);
      }
    }

    // Record lifetime stats regardless of pass/fail.
    await ref
        .read(statsProvider.notifier)
        .recordLesson(correct: _correct, total: _total);

    // Maybe show an interstitial (every Nth lesson).
    ref.read(adsServiceProvider).onLessonCompleted();

    if (!failed) {
      ref.read(progressionServiceProvider).registerStreakActivity();
      final result = LessonResult(
        lessonId: widget.lesson.id,
        correct: _correct,
        total: _total,
        xpEarned: _xpEarned,
        stars: stars,
        leveledUp: _leveledUp,
        newLevel: _newLevel,
      );
      await ref.read(journeyRepositoryProvider).recordResult(result);
      ref.read(journeyProvider.notifier).refresh();
      if (!mounted) return;
      context.pushReplacement('/lesson-result', extra: result);
    } else {
      final result = LessonResult(
        lessonId: widget.lesson.id,
        correct: _correct,
        total: _total,
        xpEarned: _xpEarned,
        stars: 0,
        leveledUp: _leveledUp,
        newLevel: _newLevel,
      );
      if (!mounted) return;
      context.pushReplacement('/lesson-result', extra: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          children: [
            _header(),
            const SizedBox(height: 12),
            _timerBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    _showcase(),
                    const SizedBox(height: 18),
                    ..._options(),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _powerUps(),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    final progress = _current / _total;
    return Row(
      children: [
        InkResponse(
          onTap: () => _confirmQuit(),
          child: const Icon(Icons.close_rounded,
              color: AppColors.textSecondary, size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.surfaceHigh,
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.primaryGreen),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: List.generate(_maxLives, (i) {
            final on = i < _lives;
            return Padding(
              padding: const EdgeInsets.only(left: 2),
              child: Icon(
                on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: on ? AppColors.danger : AppColors.textMuted,
                size: 20,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _timerBar() {
    return AnimatedBuilder(
      animation: _timer,
      builder: (context, _) {
        final remaining = (1 - _timer.value).clamp(0.0, 1.0);
        final color = remaining < 0.25
            ? AppColors.danger
            : remaining < 0.5
                ? AppColors.gold
                : AppColors.info;
        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: remaining,
            minHeight: 5,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        );
      },
    );
  }

  /// Framed "stage" that holds the question meta, prompt and artwork on a
  /// soft spotlight so the visual doesn't float on raw background.
  Widget _showcase() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment(0, -0.7),
          radius: 1.2,
          colors: [Color(0xFF26407F), Color(0xFF14224A)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _metaChip(
                'QUESTION ${_current + 1}/$_total',
                AppColors.textSecondary,
                AppColors.surfaceHigh,
              ),
              _metaChip(
                '+${XpRules.xpCorrectAnswer} XP',
                AppColors.primaryGreen,
                AppColors.primaryGreen.withValues(alpha: 0.18),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _q.prompt,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 19,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 18),
          Stack(
            alignment: Alignment.center,
            children: [
              // Soft pedestal glow behind the subject.
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: QuestionVisual(question: _q),
              ),
              _xpPopup(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaChip(String text, Color fg, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  List<Widget> _options() {
    const letters = ['A', 'B', 'C', 'D'];
    return List.generate(_q.options.length, (i) {
      OptionState state;
      if (_eliminated.contains(i)) {
        state = OptionState.eliminated;
      } else if (!_revealed) {
        state = OptionState.idle;
      } else if (i == _q.correctIndex) {
        state = (i == _selected)
            ? OptionState.selectedCorrect
            : OptionState.revealedCorrect;
      } else if (i == _selected) {
        state = OptionState.selectedWrong;
      } else {
        state = OptionState.idle;
      }
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OptionButton(
          letter: letters[i],
          label: _q.options[i],
          state: state,
          onTap: _revealed ? null : () => _answer(i),
        ),
      );
    });
  }

  Widget _xpPopup() {
    return AnimatedBuilder(
      animation: _xpPop,
      builder: (context, _) {
        if (_xpPop.isDismissed) return const SizedBox.shrink();
        final t = _xpPop.value;
        return Opacity(
          opacity: (1 - t).clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, -60 * t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.greenCta,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '+${XpRules.xpCorrectAnswer} XP',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _powerUps() {
    return Row(
      children: [
        Expanded(
          child: _PowerUpButton(
            icon: Icons.call_split_rounded,
            label: '50 / 50',
            count: _fiftyLeft,
            enabled: _fiftyLeft > 0 && !_revealed,
            onTap: _useFiftyFifty,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PowerUpButton(
            icon: Icons.more_time_rounded,
            label: 'Extra Time',
            count: _extraTimeLeft,
            enabled: _extraTimeLeft > 0 && !_revealed,
            onTap: _useExtraTime,
          ),
        ),
      ],
    );
  }

  Future<void> _confirmQuit() async {
    final quit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Quit lesson?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Your progress in this lesson will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep playing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Quit',
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (quit == true && mounted) context.pop();
  }
}

class _PowerUpButton extends StatelessWidget {
  const _PowerUpButton({
    required this.icon,
    required this.label,
    required this.count,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.glassFillStrong,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

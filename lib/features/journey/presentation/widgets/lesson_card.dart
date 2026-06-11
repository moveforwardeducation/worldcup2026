import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/star_row.dart';

enum LessonCardState { locked, play, completed }

/// A premium level-select card for a single lesson.
class LessonCard extends StatelessWidget {
  const LessonCard({
    super.key,
    required this.number,
    required this.state,
    required this.stars,
    required this.questionCount,
    required this.maxXp,
    required this.onTap,
  });

  final int number;
  final LessonCardState state;
  final int stars;
  final int questionCount;
  final int maxXp;
  final VoidCallback onTap;

  bool get _locked => state == LessonCardState.locked;
  bool get _play => state == LessonCardState.play;
  bool get _done => state == LessonCardState.completed;

  Color get _accent => _done
      ? AppColors.primaryGreen
      : _play
          ? AppColors.gold
          : AppColors.textMuted;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _locked ? 0.55 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _locked ? null : onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: _play
                    ? AppColors.gold.withValues(alpha: 0.6)
                    : _done
                        ? AppColors.primaryGreen.withValues(alpha: 0.4)
                        : AppColors.glassBorder,
                width: _play ? 1.6 : 1,
              ),
              boxShadow: _play
                  ? [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.22),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            // Clip so the inner gradient + accent strip follow the rounded
            // corners cleanly (no mis-fit against the border).
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.5),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _play
                        ? const [Color(0xFF223A78), Color(0xFF172A57)]
                        : _done
                            ? [
                                AppColors.primaryGreen.withValues(alpha: 0.16),
                                AppColors.primaryGreen.withValues(alpha: 0.04),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.10),
                                Colors.white.withValues(alpha: 0.03),
                              ],
                  ),
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left accent strip — plain rectangle, corners clipped.
                      Container(width: 6, color: _accent),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              _badge(),
                              const SizedBox(width: 14),
                              Expanded(child: _info()),
                              const SizedBox(width: 10),
                              _action(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge() {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        gradient: _play
            ? AppColors.goldCta
            : _done
                ? AppColors.greenCta
                : null,
        color: _locked ? AppColors.surfaceHigh : null,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: _locked
          ? const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 24)
          : _done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 28)
              : Text(
                  '$number',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                ),
    );
  }

  Widget _info() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'Lesson $number',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
            if (_play) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'NEXT UP',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        if (_done)
          StarRow(filled: stars, size: 16, spacing: 1)
        else
          Row(
            children: [
              Icon(Icons.help_outline_rounded,
                  size: 13, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                '$questionCount questions',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.bolt_rounded,
                  size: 13, color: AppColors.primaryGreen),
              const SizedBox(width: 2),
              Text(
                'up to $maxXp',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
      ],
    );
  }

  Widget _action() {
    if (_locked) {
      return const Icon(Icons.lock_outline_rounded,
          color: AppColors.textMuted, size: 20);
    }
    final label = _done ? 'REPLAY' : 'PLAY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        gradient: _done ? null : AppColors.greenCta,
        color: _done ? AppColors.surfaceHigh : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: _done ? AppColors.textSecondary : Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            _done ? Icons.refresh_rounded : Icons.play_arrow_rounded,
            color: _done ? AppColors.textSecondary : Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}

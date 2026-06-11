import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/stage.dart';
import 'stage_visuals.dart';

/// A single row in the journey list — number badge, title, progress and state.
class StageTile extends StatelessWidget {
  const StageTile({
    super.key,
    required this.stage,
    required this.onTap,
  });

  final JourneyStage stage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locked = !stage.unlocked;
    final completed = stage.isCompleted;

    final Color accent = completed
        ? AppColors.primaryGreen
        : locked
            ? AppColors.textMuted
            : AppColors.gold;

    // Frosted-glass surface that lets the background gradient show through.
    final List<Color> glass;
    final Color borderColor;
    if (completed) {
      glass = [
        AppColors.primaryGreen.withValues(alpha: 0.20),
        AppColors.primaryGreen.withValues(alpha: 0.05),
      ];
      borderColor = AppColors.primaryGreen.withValues(alpha: 0.45);
    } else if (locked) {
      glass = [
        Colors.white.withValues(alpha: 0.05),
        Colors.white.withValues(alpha: 0.015),
      ];
      borderColor = Colors.white.withValues(alpha: 0.08);
    } else {
      glass = [
        Colors.white.withValues(alpha: 0.12),
        Colors.white.withValues(alpha: 0.03),
      ];
      borderColor = Colors.white.withValues(alpha: 0.16);
    }

    return Opacity(
      opacity: locked ? 0.7 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: locked ? null : onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: glass,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                _badge(accent, locked, completed),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage.kind.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        locked
                            ? 'Locked'
                            : '${stage.completedLessons} / ${stage.totalLessons} lessons',
                        style: TextStyle(
                          color: locked ? AppColors.textMuted : accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                _trailing(locked, completed),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _badge(Color accent, bool locked, bool completed) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: locked ? 0.15 : 0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: Icon(
        completed ? Icons.check_rounded : stage.kind.icon,
        color: accent,
        size: 24,
      ),
    );
  }

  Widget _trailing(bool locked, bool completed) {
    if (locked) {
      return const Icon(Icons.lock_rounded,
          color: AppColors.textMuted, size: 22);
    }
    if (completed) {
      return const Icon(Icons.verified_rounded,
          color: AppColors.primaryGreen, size: 22);
    }
    return const Icon(Icons.chevron_right_rounded,
        color: AppColors.textSecondary, size: 26);
  }
}

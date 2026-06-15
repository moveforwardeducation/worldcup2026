import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/gradient_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/star_row.dart';
import '../../../data/models/lesson.dart';
import '../../home/presentation/widgets/confetti.dart';

class LessonResultScreen extends StatefulWidget {
  const LessonResultScreen({super.key, required this.result});

  final LessonResult result;

  @override
  State<LessonResultScreen> createState() => _LessonResultScreenState();
}

class _LessonResultScreenState extends State<LessonResultScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    if (widget.result.leveledUp) {
      HapticFeedback.heavyImpact();
    } else if (widget.result.stars > 0) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final passed = r.stars > 0;

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            if (passed) const Positioned.fill(child: IgnorePointer(child: Confetti())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    Text(
                      passed ? (r.isPerfect ? 'Perfect!' : 'Lesson Complete!') : 'Out of Lives',
                      style: TextStyle(
                        color: passed ? AppColors.primaryGreen : AppColors.danger,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      passed
                          ? 'You answered ${r.correct}/${r.total} correctly'
                          : 'You answered ${r.correct}/${r.total}. Try again!',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ScaleTransition(
                      scale: CurvedAnimation(parent: _c, curve: Curves.elasticOut),
                      child: StarRow(filled: r.stars, size: 52, spacing: 6),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _RewardTile(
                            icon: Icons.bolt_rounded,
                            color: AppColors.primaryGreen,
                            value: '+${r.xpEarned}',
                            label: 'XP Earned',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _RewardTile(
                            icon: Icons.check_circle_rounded,
                            color: AppColors.info,
                            value: '${r.correct}/${r.total}',
                            label: 'Correct',
                          ),
                        ),
                      ],
                    ),
                    if (r.leveledUp) ...[
                      const SizedBox(height: 16),
                      GradientCard(
                        gradient: AppColors.goldCta,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.arrow_circle_up_rounded,
                                color: Colors.white),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Level ${r.newLevel}!  +1 Mystery Pack',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const Spacer(),
                    PrimaryButton(
                      label: 'Continue',
                      trailingIcon: Icons.arrow_forward_rounded,
                      onPressed: () => context.pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      color: AppColors.glassFill,
      borderColor: AppColors.glassBorder,
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

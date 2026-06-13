import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_ad_slot.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/help_button.dart';
import '../../../core/widgets/progress_bar.dart';
import '../../help/help_content.dart';
import '../../home/presentation/widgets/confetti.dart';
import 'journey_providers.dart';
import 'widgets/journey_mascot.dart';
import 'widgets/stage_tile.dart';

class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stages = ref.watch(journeyProvider);
    final progress = ref.watch(journeyProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _JourneyBanner(progress: progress),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 18)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                sliver: SliverList.separated(
                  itemCount: stages.length + 1,
                  itemBuilder: (context, i) {
                    const adAfter = 3; // show banner after stage index 2
                    if (i == adAfter) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: BannerAdSlot()),
                      );
                    }
                    final stage = stages[i < adAfter ? i : i - 1];
                    return StageTile(
                      stage: stage,
                      onTap: () => context.push('/stage/${stage.index}'),
                    );
                  },
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                ),
              ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-bleed banner (no card) — mascot + title sit directly on the
/// background, matching the Home hero treatment.
class _JourneyBanner extends StatelessWidget {
  const _JourneyBanner({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 144,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Positioned.fill(child: Confetti()),
              Positioned(
                top: 0,
                right: 0,
                child: HelpButton(topic: AppHelp.journey),
              ),
              Positioned.fill(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Journey',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w900,
                              fontSize: 28,
                              height: 1.05,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete all stages and\nbecome a Football Champion!',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const JourneyMascot(size: 118),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text(
              'Journey Progress',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            Text(
              '$pct%',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppProgressBar(progress: progress, gradient: AppColors.goldCta),
      ],
    );
  }
}

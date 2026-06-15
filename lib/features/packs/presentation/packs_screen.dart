import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/banner_header.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/help_button.dart';
import '../../../core/widgets/primary_button.dart';
import '../../help/help_content.dart';
import '../../home/presentation/widgets/confetti.dart';
import 'packs_providers.dart';
import 'widgets/pack_box.dart';

class PacksScreen extends ConsumerWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(packsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            const Positioned.fill(child: GlowBackground()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    BannerHeader(
                      title: 'Mystery Packs',
                      subtitle: count > 0
                          ? 'You have $count pack${count == 1 ? '' : 's'} to open'
                          : 'Earn packs by leveling up',
                      backdrop: const Confetti(),
                      emblem: const _GiftEmblem(),
                      action: HelpButton(topic: AppHelp.packs),
                    ),
                    const Spacer(),
                    PackBox(count: count, width: 200),
                    const Spacer(),
                    PrimaryButton(
                      label: count > 0 ? 'Open Pack' : 'No Packs Available',
                      icon: Icons.auto_awesome_rounded,
                      gradient: count > 0
                          ? AppColors.goldCta
                          : AppColors.greenCta,
                      onPressed: count > 0
                          ? () => context.push('/packs/open')
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _InfoRow(),
                    const SizedBox(height: 16),
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

class _GiftEmblem extends StatelessWidget {
  const _GiftEmblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        gradient: AppColors.goldCta,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Icon(Icons.card_giftcard_rounded,
          color: Colors.white, size: 46),
    );
  }
}

class _InfoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded,
              color: AppColors.textSecondary, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Each pack contains cards and XP. Level up to earn more!',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

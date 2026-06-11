import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/xp_rules.dart';
import '../../../core/services/progression_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../data/providers.dart';
import '../../home/presentation/widgets/confetti.dart';
import 'battle_providers.dart';

class BattleResultScreen extends ConsumerStatefulWidget {
  const BattleResultScreen({
    super.key,
    required this.opponent,
    required this.you,
    required this.opp,
  });

  final String opponent;
  final int you;
  final int opp;

  @override
  ConsumerState<BattleResultScreen> createState() => _BattleResultScreenState();
}

class _BattleResultScreenState extends ConsumerState<BattleResultScreen> {
  late final bool _won = widget.you > widget.opp;
  late final bool _draw = widget.you == widget.opp;
  int _xp = 0;
  int _trophies = 0;

  @override
  void initState() {
    super.initState();
    if (_won) {
      _xp = XpRules.xpBattleWin;
      _trophies = 20;
    } else if (_draw) {
      _xp = 30;
      _trophies = 8;
    } else {
      _xp = 10;
      _trophies = 2;
    }
    // Apply rewards once after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(progressionServiceProvider).awardXp(_xp);
      final name = ref.read(userProfileProvider)?.username ?? 'You';
      ref.read(trophiesProvider.notifier).add(_trophies, name: name);
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _won ? 'Victory!' : (_draw ? 'Draw' : 'Defeated');
    final color = _won
        ? AppColors.primaryGreen
        : (_draw ? AppColors.gold : AppColors.danger);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            if (_won)
              const Positioned.fill(child: IgnorePointer(child: Confetti())),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Spacer(),
                    Icon(
                      _won
                          ? Icons.emoji_events_rounded
                          : (_draw
                              ? Icons.handshake_rounded
                              : Icons.shield_rounded),
                      color: color,
                      size: 88,
                    ),
                    const SizedBox(height: 16),
                    Text(title,
                        style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 34)),
                    const SizedBox(height: 8),
                    Text(
                      'You ${widget.you} — ${widget.opp} ${widget.opponent}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 15),
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: _reward(Icons.bolt_rounded,
                              AppColors.primaryGreen, '+$_xp', 'XP'),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _reward(Icons.emoji_events_rounded,
                              AppColors.gold, '+$_trophies', 'Trophies'),
                        ),
                      ],
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Back to Battle',
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

  Widget _reward(IconData icon, Color color, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 22)),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

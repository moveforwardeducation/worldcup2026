import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../collection/presentation/widgets/card_tile.dart';
import '../../home/presentation/widgets/confetti.dart';
import '../data/pack_reward.dart';
import 'packs_providers.dart';
import 'widgets/pack_box.dart';

enum _Phase { idle, bursting, revealed }

class PackOpenScreen extends ConsumerStatefulWidget {
  const PackOpenScreen({super.key});

  @override
  ConsumerState<PackOpenScreen> createState() => _PackOpenScreenState();
}

class _PackOpenScreenState extends ConsumerState<PackOpenScreen>
    with TickerProviderStateMixin {
  _Phase _phase = _Phase.idle;
  List<PackReward> _rewards = const [];

  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  )..addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        setState(() => _phase = _Phase.revealed);
        _reveal.forward();
      }
    });

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void dispose() {
    _burst.dispose();
    _reveal.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_phase != _Phase.idle) return;
    final rewards = await openMysteryPack(ref);
    if (rewards == null) {
      if (mounted) context.pop();
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _rewards = rewards;
      _phase = _Phase.bursting;
    });
    _burst.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: Stack(
          children: [
            if (_phase == _Phase.revealed)
              const Positioned.fill(child: IgnorePointer(child: Confetti())),
            SafeArea(
              child: _phase == _Phase.revealed ? _revealView() : _openingView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _openingView() {
    return Center(
      child: GestureDetector(
        onTap: _open,
        child: AnimatedBuilder(
          animation: _burst,
          builder: (context, child) {
            final t = _burst.value;
            return Opacity(
              opacity: (1 - t).clamp(0.0, 1.0),
              child: Transform.scale(
                scale: 1 + t * 0.6,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PackBox(width: 210),
              const SizedBox(height: 28),
              AnimatedOpacity(
                opacity: _phase == _Phase.idle ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Text(
                  'TAP TO OPEN',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _revealView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 12),
          const Text(
            'Pack Opened!',
            style: TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Here\'s what you got',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    for (var i = 0; i < _rewards.length; i++)
                      _RewardTile(reward: _rewards[i], anim: _tileAnim(i)),
                  ],
                ),
              ),
            ),
          ),
          PrimaryButton(
            label: 'Awesome!',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Animation<double> _tileAnim(int i) {
    final n = _rewards.length;
    final start = (i / n) * 0.6;
    return CurvedAnimation(
      parent: _reveal,
      curve: Interval(start, (start + 0.4).clamp(0.0, 1.0),
          curve: Curves.easeOutBack),
    );
  }
}

class _RewardTile extends StatelessWidget {
  const _RewardTile({required this.reward, required this.anim});
  final PackReward reward;
  final Animation<double> anim;

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: anim,
      child: SizedBox(width: 104, height: 144, child: _content()),
    );
  }

  Widget _content() {
    switch (reward.kind) {
      case RewardKind.card:
        return Stack(
          children: [
            CardTile(card: reward.card!, unlocked: true, onTap: () {}),
            if (reward.isNew)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: AppColors.greenCta,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text('NEW',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 9)),
                ),
              ),
          ],
        );
      case RewardKind.xp:
        return _SimpleReward(
          icon: Icons.bolt_rounded,
          color: AppColors.primaryGreen,
          label: '+${reward.amount}',
          sub: 'XP',
        );
    }
  }
}

class _SimpleReward extends StatelessWidget {
  const _SimpleReward({
    required this.icon,
    required this.color,
    required this.label,
    required this.sub,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.4),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 40),
          const SizedBox(height: 10),
          Text(label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 20)),
          Text(sub,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

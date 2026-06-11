import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/question.dart';
import '../../journey/presentation/journey_providers.dart';
import '../../learning/presentation/widgets/option_button.dart';
import '../../learning/presentation/widgets/question_visual.dart';

const int kBattleRounds = 5;

class BattleMatchScreen extends ConsumerWidget {
  const BattleMatchScreen({super.key, required this.opponent});
  final String opponent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final factoryAsync = ref.watch(questionFactoryProvider);
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: factoryAsync.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen)),
          error: (e, _) => Center(
              child: Text('$e',
                  style: const TextStyle(color: AppColors.textSecondary))),
          data: (factory) => _BattlePlayer(
            opponent: opponent,
            questions: factory.randomMix(kBattleRounds),
          ),
        ),
      ),
    );
  }
}

class _BattlePlayer extends ConsumerStatefulWidget {
  const _BattlePlayer({required this.opponent, required this.questions});
  final String opponent;
  final List<Question> questions;

  @override
  ConsumerState<_BattlePlayer> createState() => _BattlePlayerState();
}

class _BattlePlayerState extends ConsumerState<_BattlePlayer> {
  final _rnd = math.Random();
  int _current = 0;
  int? _selected;
  bool _revealed = false;
  int _you = 0;
  int _opp = 0;
  bool _oppCorrect = false;
  bool _navigating = false;

  Question get _q => widget.questions[_current];

  void _answer(int index) {
    if (_revealed) return;
    final youCorrect = index == _q.correctIndex;
    // Opponent: ~62% accuracy.
    final oppCorrect = _rnd.nextDouble() < 0.62;
    setState(() {
      _selected = index;
      _revealed = true;
      _oppCorrect = oppCorrect;
      if (youCorrect) _you++;
      if (oppCorrect) _opp++;
    });
    HapticFeedback.lightImpact();
    Future.delayed(const Duration(milliseconds: 1400), _next);
  }

  void _next() {
    if (!mounted) return;
    if (_current >= widget.questions.length - 1) {
      _finish();
      return;
    }
    setState(() {
      _current++;
      _selected = null;
      _revealed = false;
    });
  }

  void _finish() {
    if (_navigating) return;
    _navigating = true;
    context.pushReplacement('/battle/result', extra: {
      'opponent': widget.opponent,
      'you': _you,
      'opp': _opp,
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          children: [
            _scoreboard(),
            const SizedBox(height: 12),
            Text('ROUND ${_current + 1} / ${widget.questions.length}',
                style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 1)),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Text(_q.prompt,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 18)),
                    const SizedBox(height: 16),
                    QuestionVisual(question: _q),
                    const SizedBox(height: 16),
                    ..._options(),
                    if (_revealed) ...[
                      const SizedBox(height: 10),
                      _oppResult(),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scoreboard() {
    return Row(
      children: [
        Expanded(child: _scoreSide('You', _you, AppColors.primaryGreen)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('VS',
              style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w900,
                  fontSize: 16)),
        ),
        Expanded(child: _scoreSide(widget.opponent, _opp, AppColors.danger)),
      ],
    );
  }

  Widget _scoreSide(String name, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13)),
          const SizedBox(height: 2),
          Text('$score',
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 24)),
        ],
      ),
    );
  }

  List<Widget> _options() {
    const letters = ['A', 'B', 'C', 'D'];
    return List.generate(_q.options.length, (i) {
      OptionState state;
      if (!_revealed) {
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

  Widget _oppResult() {
    return Text(
      _oppCorrect
          ? '${widget.opponent} answered correctly'
          : '${widget.opponent} got it wrong',
      style: TextStyle(
        color: _oppCorrect ? AppColors.danger : AppColors.textSecondary,
        fontWeight: FontWeight.w700,
        fontSize: 13,
      ),
    );
  }
}

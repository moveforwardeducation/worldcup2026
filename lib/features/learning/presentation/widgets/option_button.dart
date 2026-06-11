import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

enum OptionState { idle, selectedCorrect, selectedWrong, revealedCorrect, eliminated }

/// A single answer choice with a letter badge and feedback states.
class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.letter,
    required this.label,
    required this.state,
    required this.onTap,
  });

  final String letter;
  final String label;
  final OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg, badge) = _styles();
    final dim = state == OptionState.eliminated;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: dim ? 0.35 : 1,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: dim ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: badge,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    letter,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
                _trailingIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _trailingIcon() {
    switch (state) {
      case OptionState.selectedCorrect:
      case OptionState.revealedCorrect:
        return const Icon(Icons.check_circle_rounded,
            color: Colors.white, size: 22);
      case OptionState.selectedWrong:
        return const Icon(Icons.cancel_rounded, color: Colors.white, size: 22);
      default:
        return const SizedBox(width: 22);
    }
  }

  (Color, Color, Color, Color) _styles() {
    switch (state) {
      case OptionState.selectedCorrect:
      case OptionState.revealedCorrect:
        return (
          AppColors.primaryGreen,
          AppColors.primaryGreenDark,
          Colors.white,
          Colors.white.withValues(alpha: 0.25),
        );
      case OptionState.selectedWrong:
        return (
          AppColors.danger,
          const Color(0xFFB91C1C),
          Colors.white,
          Colors.white.withValues(alpha: 0.25),
        );
      case OptionState.idle:
      case OptionState.eliminated:
        return (
          AppColors.glassFillStrong,
          AppColors.glassBorder,
          AppColors.textPrimary,
          AppColors.surfaceHigh,
        );
    }
  }
}

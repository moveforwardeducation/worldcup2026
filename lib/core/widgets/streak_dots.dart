import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Last-7-days indicator. Active days show a green check, missed days show
/// an outline, today (last cell) is highlighted in orange.
class StreakDots extends StatelessWidget {
  const StreakDots({super.key, required this.last7Days});

  /// oldest -> newest, length 7. Last entry is "today".
  final List<bool> last7Days;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = i < last7Days.length && last7Days[i];
        final isToday = i == last7Days.length - 1;
        return _Dot(active: active, isToday: isToday);
      }),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active, required this.isToday});
  final bool active;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Widget child;
    if (active) {
      bg = AppColors.primaryGreen;
      child = const Icon(Icons.check_rounded, color: Colors.white, size: 18);
    } else if (isToday) {
      bg = AppColors.streakOrange;
      child = const Icon(Icons.local_fire_department_rounded,
          color: Colors.white, size: 18);
    } else {
      bg = AppColors.surfaceHigh;
      child = const SizedBox.shrink();
    }
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: !active && !isToday
            ? Border.all(color: AppColors.divider, width: 1)
            : null,
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

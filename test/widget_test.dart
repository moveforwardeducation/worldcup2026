import 'package:flutter_test/flutter_test.dart';

import 'package:road_to_wc2026/core/constants/xp_rules.dart';

void main() {
  test('XP -> level math is monotonic', () {
    final l1 = XpRules.levelFromTotalXp(0);
    expect(l1.level, 1);

    final l2 = XpRules.levelFromTotalXp(100);
    expect(l2.level, 2);

    final l3 = XpRules.levelFromTotalXp(300); // 100 + 200
    expect(l3.level, 3);
  });
}

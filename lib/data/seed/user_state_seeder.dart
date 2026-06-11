import 'package:hive_ce_flutter/hive_flutter.dart';

import '../local/hive/hive_boxes.dart';

/// First-launch setup for a brand-new user. Real users start fresh (Level 1,
/// no XP/coins/cards) — their profile is created during onboarding. We only
/// grant a single welcome Mystery Pack so there's something to open.
class UserStateSeeder {
  Future<void> ensureSeeded() async {
    final settings = Hive.box(HiveBoxes.settings);
    if (settings.get('welcomed') == true) return;
    await settings.put('welcomed', true);
    await settings.put('packs', 1); // welcome pack
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../../data/local/hive/hive_boxes.dart';

/// Whether the user has completed the onboarding flow.
bool readOnboardingDone() {
  return (Hive.box(HiveBoxes.settings).get('onboardingDone') as bool?) ?? false;
}

class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier() : super(readOnboardingDone());

  Future<void> complete() async {
    await Hive.box(HiveBoxes.settings).put('onboardingDone', true);
    state = true;
  }
}

final onboardingDoneProvider =
    StateNotifierProvider<OnboardingNotifier, bool>((ref) {
  return OnboardingNotifier();
});

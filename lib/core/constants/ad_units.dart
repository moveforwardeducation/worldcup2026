import 'package:flutter/foundation.dart';

/// AdMob unit ids. These are Google's official **test** ids so ads work in
/// development without a real AdMob account.
///
/// TODO before publishing with ads:
///  1. Create real ad units in AdMob and paste their ids below (release values).
///  2. Replace the APPLICATION_ID in AndroidManifest.xml with your real one.
class AdUnits {
  AdUnits._();

  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _testInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const _testRewarded = 'ca-app-pub-3940256099942544/5224354917';

  // Swap these to your real release ids when ready.
  static const _releaseBanner = _testBanner;
  static const _releaseInterstitial = _testInterstitial;
  static const _releaseRewarded = _testRewarded;

  static String get banner => kReleaseMode ? _releaseBanner : _testBanner;
  static String get interstitial =>
      kReleaseMode ? _releaseInterstitial : _testInterstitial;
  static String get rewarded => kReleaseMode ? _releaseRewarded : _testRewarded;

  /// Show an interstitial after every N lessons.
  static const int interstitialEveryLessons = 3;
}

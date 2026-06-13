import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_units.dart';
import 'remote_config_service.dart';

/// Set true once the Mobile Ads SDK initialised.
bool adsReady = false;

Future<void> initAds() async {
  try {
    await MobileAds.instance.initialize();
    adsReady = true;
  } catch (e) {
    adsReady = false;
    if (kDebugMode) debugPrint('Ads init failed: $e');
  }
}

/// Owns interstitial loading/showing and the lesson counter that decides when
/// to show one. Banners are created per-widget (see [BannerAdSlot]).
class AdsService {
  AdsService();

  InterstitialAd? _interstitial;
  int _lessonsSinceAd = 0;
  int _predictionsSinceAd = 0;

  void preloadInterstitial() {
    if (!adsReady || !adsEnabled || _interstitial != null) return;
    InterstitialAd.load(
      adUnitId: AdUnits.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  /// Call after a lesson completes. Shows an interstitial every N lessons.
  void onLessonCompleted() {
    if (!adsReady || !adsEnabled) return;
    _lessonsSinceAd++;
    if (_lessonsSinceAd >= AdUnits.interstitialEveryLessons) {
      _lessonsSinceAd = 0;
      _showInterstitial();
    } else {
      preloadInterstitial();
    }
  }

  /// Call after a prediction (match or group) grades. Shows an interstitial
  /// every N graded predictions.
  void onPredictionCompleted() {
    if (!adsReady || !adsEnabled) return;
    _predictionsSinceAd++;
    if (_predictionsSinceAd >= AdUnits.interstitialEveryPredictions) {
      _predictionsSinceAd = 0;
      _showInterstitial();
    } else {
      preloadInterstitial();
    }
  }

  void _showInterstitial() {
    final ad = _interstitial;
    if (ad == null) {
      preloadInterstitial();
      return;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
    );
    ad.show();
  }
}

final adsServiceProvider = Provider<AdsService>((ref) => AdsService());

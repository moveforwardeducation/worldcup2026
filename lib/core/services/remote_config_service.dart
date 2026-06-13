import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Master kill-switch for all ads. Read from Firebase Remote Config.
/// True by default — so ads keep working if RC ever fails to fetch.
bool _adsEnabled = true;

/// Public accessor used by [BannerAdSlot] and [AdsService] to gate ad
/// loading/showing. Cheap to call (just a bool read).
bool get adsEnabled => _adsEnabled;

/// Initialise Firebase Remote Config, register defaults, then
/// fetch-and-activate the latest server values. Safe to call once at app
/// start. Best-effort: failures leave the in-app defaults intact.
Future<void> initRemoteConfig() async {
  try {
    final rc = FirebaseRemoteConfig.instance;
    await rc.setConfigSettings(RemoteConfigSettings(
      // Block fetches for at most 10s on cold start.
      fetchTimeout: const Duration(seconds: 10),
      // Minimum interval between fetches in production (RC default is 12h).
      minimumFetchInterval: const Duration(hours: 12),
    ));
    await rc.setDefaults(const {
      'ads_enabled': true,
    });
    await rc.fetchAndActivate();
    _adsEnabled = rc.getBool('ads_enabled');
    if (kDebugMode) debugPrint('Remote Config: ads_enabled = $_adsEnabled');
  } catch (e) {
    if (kDebugMode) debugPrint('Remote Config init failed: $e');
    // Leave _adsEnabled at its default (true).
  }
}

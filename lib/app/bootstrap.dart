import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../core/services/ads_service.dart';
import '../data/local/hive/hive_boxes.dart';
import '../firebase_options.dart';

/// Set to true once Firebase initialised successfully. Features degrade
/// gracefully to local behaviour when this is false.
bool firebaseReady = false;

/// Initialize all platform/storage prerequisites before runApp().
/// Hive (local) is required; Firebase is best-effort so the app still runs
/// if the backend services aren't reachable.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await HiveBoxes.openAll();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;

    // Route uncaught Flutter + platform errors to Crashlytics (release only).
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      }
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kDebugMode) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      return true;
    };
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
  } catch (e) {
    firebaseReady = false;
    if (kDebugMode) {
      debugPrint('Firebase init failed (running offline): $e');
    }
  }

  // Best-effort ads init (non-blocking for the rest of the app).
  await initAds();
}

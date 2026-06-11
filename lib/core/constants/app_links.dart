/// External links + app metadata used by the Settings screen.
/// TODO: replace the stubbed URLs/email with your real ones before launch.
class AppLinks {
  AppLinks._();

  static const String appName = 'Football Champions 2026';
  static const String appVersion = '1.0.0';
  static const String packageId = 'com.moveforwardeducation.wcfootball';

  // Legal (you have these URLs — paste them here).
  static const String privacyUrl = 'https://example.com/privacy';
  static const String termsUrl = 'https://example.com/terms';

  // Support.
  static const String supportEmail = 'support@roadtowc2026.app';

  // Store listing (works once the app is published under this id).
  static String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$packageId';

  static String get shareMessage =>
      'Play $appName — learn, predict and battle your way to football glory! $playStoreUrl';
}

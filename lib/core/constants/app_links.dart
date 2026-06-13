/// External links + app metadata used by the Settings screen.
/// TODO: replace the stubbed URLs/email with your real ones before launch.
class AppLinks {
  AppLinks._();

  static const String appName = 'Football Champions 2026';
  static const String appVersion = '1.0.0';
  static const String packageId = 'com.moveforwardeducation.wcfootball';

  // Legal (you have these URLs — paste them here).
  static const String privacyUrl = 'https://moveforwardeducation.github.io/privacy_policy.html';
  static const String termsUrl = 'https://moveforwardeducation.github.io/terms_of_service.html';

  // Support.
  static const String supportEmail = 'moveforwardeducation@gmail.com';

  // Store listing (works once the app is published under this id).
  static String get playStoreUrl =>
      'https://play.google.com/store/apps/details?id=$packageId';

  static String get shareMessage =>
      '⚽ $appName ⚽\n\n'
      'Learn teams & players, predict live matches, collect cards and '
      'battle fans worldwide — all free!\n\n'
      '🏆 Join the action:\n$playStoreUrl';
}

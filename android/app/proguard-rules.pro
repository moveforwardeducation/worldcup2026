# Flutter / Dart
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Firebase (Auth, Firestore, Core) — libraries ship their own rules; keep models.
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Google Mobile Ads
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**

# Keep Play Core (used by deferred components / split installs)
-dontwarn com.google.android.play.core.**

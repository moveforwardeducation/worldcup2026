# Football Champions 2026 — Project Guide

A gamified, Duolingo-style Flutter football app (themed around the 2026 tournament).
Dark navy theme, XP/levels/streaks, collectible cards, predictions, live "Fan
Pulse" votes, fan-club leaderboards, and battle mode. **Android-first.**

> **Branding (legal):** user-facing brand is **"Football Champions 2026"** —
> deliberately NOT "FIFA"/"World Cup" (trademarks). Keep all artwork generic
> (vector only, no real crests/logos/photos). Factual trivia ("won the World
> Cup", "World Cup Wins") is kept as nominative use.

---

## ⚠️ Build / Run / Install workflow (IMPORTANT)

- **ASK THE USER before running any `flutter build` / APK / AAB.** (User instruction.)
  Make code changes + `flutter analyze --no-pub` (expect **0 issues**), then stop
  and ask before building.
- Test device: **Redmi Note 8 Pro (arm64, Android 9)**, id `9sknivpnr85daiws`.
- **Ship the small release APK**, not debug (debug ~170 MB hangs on this phone):
  ```
  flutter build apk --release --target-platform android-arm64
  ```
  Now ~33 MB (the Google Mobile Ads SDK adds ~10 MB; was ~19 MB before ads).
  Signed with the **release upload key** (see signing below).
- **Play upload:** `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab`.
- **adb** not on PATH: `C:\Users\SAM\AppData\Local\Android\Sdk\platform-tools\adb.exe`
- **MIUI blocks `adb install`** (`INSTALL_FAILED_USER_RESTRICTED`). Push to Downloads:
  ```
  & $adb -s 9sknivpnr85daiws push "build\app\outputs\flutter-apk\app-release.apk" "/sdcard/Download/road_to_wc2026.apk"
  ```
  User installs via Files → Downloads. If "App not installed": uninstall old first,
  ensure the file manager has "install unknown apps" permission.
- Transient `classes.dex ... used by another process` (R8) or pub "rename" locks =
  AV/stale-daemon/concurrent file scan. Just re-run.

### Release signing
- `android/key.properties` (gitignored) → release `signingConfig` in
  `android/app/build.gradle.kts`. Keystore: **`C:/keystore/wcfootball-keystore.jks`**,
  alias `wcfootball` (CN=wcfootball). R8 `isMinifyEnabled=true`, `proguard-rules.pro`
  keeps Firebase/Ads. Falls back to debug key if key.properties is absent.

---

## Identity
- **applicationId / namespace:** `com.moveforwardeducation.wcfootball`
- **Launcher label:** "Football Champions". MainActivity at
  `android/app/src/main/kotlin/com/moveforwardeducation/wcfootball/`.
- **minSdk 23** (Firebase). App icon/splash generated via `flutter_launcher_icons`
  + `flutter_native_splash` from `assets/icon/app_icon.png`.

---

## Tech stack
- Flutter stable (3.41 / Dart 3.11), Material 3, `google_fonts` (Plus Jakarta Sans)
- State: **flutter_riverpod** (plain providers / StateNotifier — **no code-gen**)
- Routing: **go_router** (`StatefulShellRoute` for 6 tabs + full-screen pushes +
  an onboarding redirect)
- Local KV: **hive_ce** + `hive_ce_flutter`
- Backend: **firebase_core / firebase_auth (anonymous) / cloud_firestore /
  firebase_crashlytics / firebase_analytics**
- Ads: **google_mobile_ads** (test IDs)
- Misc: **url_launcher**, **share_plus**, **intl**
- Static content = bundled JSON in `assets/seed/` via `SeedLoader`.
- **No Drift/SQLite, no freezed/json/riverpod/hive generators.** Plain Dart + hand `fromJson`.

---

## Architecture (feature-first)
`lib/app` (app, bootstrap, router, nav_shell) · `lib/core` (theme, constants,
services, widgets, help) · `lib/data` (models, local/hive, remote, seed,
providers) · `lib/features/<f>/{data,domain,presentation}`.

Features: home, journey, learning, collection, packs, predictions,
live_challenge, fan_club, battle, achievements, onboarding, profile,
**schedule**, **settings**, **help**.

`bootstrap()` = Hive init → Firebase init (sets `firebaseReady`) + Crashlytics
error handlers → `initAds()`. `main()` runs `UserStateSeeder().ensureSeeded()`
(welcome pack only — see Persistence).

---

## Navigation
Bottom nav: `Home · Journey · Predict · Battle · Club · Profile`.
First launch (no `onboardingDone` flag) → redirect to **`/onboarding`**.
Full-screen pushes (`parentNavigatorKey: _rootKey`, args via `state.extra`):
`/onboarding`, `/stage/:index`, `/lesson`, `/lesson-result`, `/collection`,
`/collection/card`, `/packs`, `/packs/open`, `/achievements`, `/schedule`,
`/settings`, `/battle/match`, `/battle/result`.
(Predict no longer has an instant `/predict/result` — resolution is deferred.)

---

## Theme & shared widgets
Screen pattern: `DecoratedBox(bgGradient)` → `Stack` with `GlowBackground()` →
`SafeArea`. Headers are full-bleed **`BannerHeader`** (title+subtitle+emblem+
optional `Confetti` backdrop + optional top-right `action`). `GlassBackButton`,
`GradientCard`, `PrimaryButton`, `AppProgressBar`, `StreakDots`, `StatPill`,
`AvatarChip`, `StarRow`, `HelpButton`/`showHelpSheet`, `VoteBars`, `BannerAdSlot`.
All artwork is vector/CustomPainter. Use `withValues(alpha:)`, not `withOpacity`.

**Help system** (`features/help/help_content.dart` → `AppHelp.*`): `HelpButton`
opens a bottom sheet with a sample-widget **preview** + bullets. "?" on Home cards
(streak/fanClub/dailyGoal) and every screen banner's `action`.

---

## Gamification
`core/services/progression_service.dart` (`progressionServiceProvider`):
`awardXp(amount,{coins})` (daily-goal reset, level-up detect) + `registerStreakActivity()`.
XP rules (`core/constants/xp_rules.dart`): correct +10, perfect +50, streak +25,
prediction +50, group +75, live vote +5, battle win +100. Level = triangular.
Lessons grant a **pack on level-up** + interstitial every 3 lessons (`AdsService`).
**Coins are earned but have no spend sink yet** (no shop) — known gap.
`stats_repository` tracks lessons/correct/answered + predictionsMade/Correct.

---

## Persistence
**Hive boxes** (`data/local/hive/hive_boxes.dart`): user_profile, xp_state, streak,
unlocked_cards, completed_lessons, prediction_history, achievement_progress,
settings (holds packs, trophies, stats, liveAnswered, votes, predictAnchorMs,
predictionGraded, onboardingDone, welcomed). Plain Maps — no adapters.

**First launch:** `UserStateSeeder.ensureSeeded()` only sets `welcomed=true` +
1 welcome pack. **Demo seed REMOVED** — new users start fresh (Level 1, empty);
**onboarding creates the real profile** (username default "Football Fan", chosen
favorite/followed teams + avatar). `UserProfile.favoriteTeamId` = primary club,
`followedTeamIds` = all followed (multi-team).

**Firestore** (project `roadtowc2026`):
- `users/{uid}/predictions/{id}`, `users/{uid}/liveAnswers/{id}`, `users/{uid}/votes/{id}`
- `teamLeaderboard/{teamId}` ({name,flag,baseXp}) + `_meta`
- `fanClubMembers/{teamId}/members/{uid}` ({name,xp})
- `battleLeaderboard/{uid}` ({name,trophies})
- `polls/{pollId}` ({opt_0,opt_1,…}) — community vote tallies
- `fixtures/{id}` — real schedule + results, **written by the sync pipeline**
  (read-only to clients). `liveChallenges` reserved.
Rules: `firestore.rules` (deploy: `firebase deploy --only firestore:rules`).

---

## Firebase setup (done)
- Project **roadtowc2026**; Android app registered for the new package.
- Firebase CLI logged in. FlutterFire CLI at
  `C:\Users\SAM\AppData\Local\Pub\Cache\bin\flutterfire.bat` (not on PATH).
- `gcloud` NOT installed → Firestore API + Anonymous Auth were enabled via console.
- Delete Account (Settings) wipes Firestore user data + auth user + local Hive
  + resets state (Play compliance).

---

## Feature behavior (current)
- **Journey** = evergreen learning curriculum (stage names are difficulty tiers,
  NOT a live bracket; no future data needed). Lessons unlock sequentially.
- **Predict tab** = 3 tabs **Live · Next · Groups**:
  - **Live** = "Fan Pulse" community **vote** (YES/NO) → crowd % + **+5 XP**, **no grading**
    (sidesteps live-results API). Only shows matches whose window is in-play.
  - **Next** = match predictions within 24h: flag-vs-flag card, 3 buttons
    (A Win/Draw/B Win), pick→shows crowd %, **editable until kickoff, locks**, then
    **deferred resolution** (grades vs real score → +50 XP). Sections Open/In-Play/Results.
  - **Groups** = pick group winner (+75 XP), crowd %, resolves at conclude.
  - Vote % = `VoteMath.blend(baseline + live Firestore counts + user pick)`.
  - Resolution is client-side via a 15s timer in the Predict screen
    (`resolveDuePredictions`); grades once, awards XP, updates stats.
- **Schedule** (`/schedule`, linked from Home card + Predict calendar icon):
  tabs **Fixtures / Results** + **All / My Teams ⭐** toggle. Reads real `fixtures`
  from Firestore (absolute `kickoffMs`+`status`), else bundled demo (relative offsets).
- **Fan Club** = Global/Country/Fan-Clubs; team totals + members from Firestore,
  blended with filler when sparse; your XP feeds your primary club.
- **Battle** = best-of-5 vs a **bot** (~62%); winner +100 XP +20 trophies;
  leaderboard from Firestore `battleLeaderboard` + filler.

---

## Jersey system (data-driven, 3D)
`assets/seed/jersey_specs.json` (40 teams, keyed by FIFA code) → `TeamJersey`
model (body/collar/trim/shoulder/number/patternColor + `JerseyPattern` enum:
solid/stripes/halves/sash/checker/hoops). `JerseyView` (`team_jersey_view.dart`)
is a shaded 3D CustomPainter on a light "kit card" panel with drop shadow; used
in the team quiz + collection detail. `jerseysByCodeProvider` maps code→spec.
Collection cards (`CardTile`) are 3D beveled/glossy; grid aspect 0.72.

---

## Results pipeline (free, no server)
`tools/sync_fixtures/` (Node + firebase-admin) + `.github/workflows/sync-fixtures.yml`
(cron 30m + manual). Pulls Football-Data.org `WC` matches → writes Firestore
`fixtures`. **Needs GitHub secrets** `FOOTBALL_API_KEY` + `FIREBASE_SERVICE_ACCOUNT`
(see `tools/sync_fixtures/README.md`). App prefers Firestore fixtures, else bundled.
Team-name→id map in `sync.js` (`NAME_TO_ID`); confirm after the draw.

---

## Real vs simulated
Real/cloud: anonymous auth, team/battle leaderboards, fan-club membership,
prediction/live/vote records, poll tallies, fixtures+results (once pipeline runs).
Simulated: battle opponent = bot, leaderboard "rivals" = filler blended with real,
bundled fixtures until the pipeline runs.

---

## ⚠️ Before launch — swap these (data only)
- `lib/core/constants/app_links.dart`: real **Privacy/Terms URLs** + support email.
- `lib/core/constants/ad_units.dart` + AndroidManifest: real **AdMob app id + unit ids**
  (currently Google **test** ids).
- Add **GitHub secrets** for the fixtures pipeline.
- Enable Firebase **Google + Email/Password** providers + add **SHA-1/256** (for sign-in, #6).

---

## Status
- **Phases 1–4 ✅** (foundation, journey/learning, collection/packs/achievements/profile,
  Firebase + predictions/live/fanclub/battle).
- **Phase 5 ✅** (icon+splash, release signing, AdMob, polish, R8/AAB).
- **Production-readiness done:** rebrand, demo-seed removed, expanded content
  (32 teams/28 players/28 Qs), live Firestore vote%/leaderboards, Crashlytics+Analytics,
  real-schedule wiring + results pipeline scaffold.
- **Pending:** **#6 Account sign-in (Google + Email)** linked to anonymous (not started);
  plus the "before launch" swaps above. Coin spend-sink (optional).

When asked to build a phase/feature: plan briefly, build feature-by-feature, keep
`flutter analyze` clean, then **ask before building** the APK/AAB.

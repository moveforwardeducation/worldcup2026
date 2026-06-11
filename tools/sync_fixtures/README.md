# Fixtures & results sync (free, no server)

Populates the Firestore `fixtures` collection (real schedule + live scores) that
the app reads. Runs on **GitHub Actions** — no server to host, $0.

The app prefers Firestore `fixtures` when present and falls back to the bundled
demo fixtures otherwise. Prediction resolution is **client-side**: when a
fixture's `status` becomes `finished`, the app grades picks against the real
score (no Cloud Function needed → stays on the free plan).

## One-time setup

### 1. Get a free football API key
- Sign up at https://www.football-data.org/client/register
- Copy your API token. (Free tier covers the World Cup, competition code `WC`.)

### 2. Create a Firebase service account
- Firebase console → project **roadtowc2026** → ⚙ Project settings → **Service accounts**
- **Generate new private key** → downloads a JSON file. Keep it secret (never commit it).

### 3. Add GitHub repo secrets
Repo → **Settings → Secrets and variables → Actions → New repository secret**:
- `FOOTBALL_API_KEY` → your football-data.org token
- `FIREBASE_SERVICE_ACCOUNT` → paste the **entire contents** of the service-account JSON

### 4. Done
The workflow `.github/workflows/sync-fixtures.yml` runs every 30 min and on
demand (Actions tab → **Sync fixtures & results** → *Run workflow*). It writes
each match to `fixtures/{id}` with: `teamA/teamB` (mapped to app team ids),
`teamAName/teamBName`, `dateLabel`, `kickoffMs`, `status`
(`scheduled`/`in_play`/`finished`), `scoreA/scoreB`.

## Run locally (optional test)
```bash
cd tools/sync_fixtures
npm install
FOOTBALL_API_KEY=xxx FIREBASE_SERVICE_ACCOUNT="$(cat service-account.json)" node sync.js
```

## Notes
- Team-name → app-id mapping lives in `sync.js` (`NAME_TO_ID`). Add teams there
  as the field is confirmed after the draw; unmapped teams still sync (display
  only, without a flag/jersey until mapped).
- Lower the cron to `*/5 * * * *` during match windows for near-live scores;
  mind the free tier's rate limits.
- The service-account JSON grants admin access to your Firebase project — keep
  it only in GitHub secrets, never in the repo.

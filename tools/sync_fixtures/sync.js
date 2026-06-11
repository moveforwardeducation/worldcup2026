/**
 * Football Champions 2026 — fixtures/results sync.
 *
 * Pulls matches from Football-Data.org (free tier) and writes them to the
 * Firestore `fixtures` collection that the app reads. Runs from GitHub Actions
 * on a schedule (see .github/workflows/sync-fixtures.yml).
 *
 * Required env vars (set as GitHub Actions secrets):
 *   FOOTBALL_API_KEY          — Football-Data.org API token (free).
 *   FIREBASE_SERVICE_ACCOUNT  — Firebase service-account JSON (whole file).
 * Optional:
 *   COMPETITION               — competition code (default "WC").
 *
 * The Firebase Admin SDK bypasses Firestore security rules, so `fixtures`
 * stays read-only to app clients while this server job writes it.
 */
const admin = require('firebase-admin');

const API_KEY = process.env.FOOTBALL_API_KEY;
const COMPETITION = process.env.COMPETITION || 'WC';
const SVC = process.env.FIREBASE_SERVICE_ACCOUNT;

if (!API_KEY || !SVC) {
  console.error('Missing FOOTBALL_API_KEY or FIREBASE_SERVICE_ACCOUNT.');
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(JSON.parse(SVC)),
});
const db = admin.firestore();

// Map the API's full team names to the app's team ids (so flags/jerseys work).
// Unmapped teams still sync (display-only); add new ones here as needed.
const NAME_TO_ID = {
  Argentina: 'arg', Brazil: 'bra', France: 'fra', Germany: 'ger',
  Spain: 'esp', England: 'eng', Portugal: 'por', Netherlands: 'ned',
  Italy: 'ita', Uruguay: 'uru', Belgium: 'bel', Colombia: 'col',
  'United States': 'usa', USA: 'usa', Mexico: 'mex', Canada: 'can',
  Japan: 'jpn', Switzerland: 'sui', Denmark: 'den', Poland: 'pol',
  Morocco: 'mar', Senegal: 'sen', Nigeria: 'nga', Ghana: 'gha',
  'South Korea': 'kor', 'Korea Republic': 'kor', Australia: 'aus',
  Iran: 'irn', 'Saudi Arabia': 'ksa', Ecuador: 'ecu', Peru: 'per',
  Chile: 'chi', Serbia: 'srb', 'Costa Rica': 'crc', Croatia: 'cro',
};

function teamId(name) {
  if (!name) return '';
  return NAME_TO_ID[name] || name.toLowerCase().replace(/[^a-z]/g, '').slice(0, 12);
}

function mapStatus(s) {
  switch (s) {
    case 'IN_PLAY':
    case 'PAUSED':
      return 'in_play';
    case 'FINISHED':
      return 'finished';
    default:
      return 'scheduled'; // SCHEDULED / TIMED / POSTPONED / etc.
  }
}

async function main() {
  const url = `https://api.football-data.org/v4/competitions/${COMPETITION}/matches`;
  const res = await fetch(url, { headers: { 'X-Auth-Token': API_KEY } });
  if (!res.ok) {
    console.error(`API error ${res.status}: ${await res.text()}`);
    process.exit(1);
  }
  const data = await res.json();
  const matches = data.matches || [];
  console.log(`Fetched ${matches.length} matches for ${COMPETITION}.`);

  let batch = db.batch();
  let ops = 0;
  for (const m of matches) {
    const id = `f_${m.id}`;
    const home = m.homeTeam && m.homeTeam.name;
    const away = m.awayTeam && m.awayTeam.name;
    const stage = (m.stage || '').replace(/_/g, ' ');
    const md = m.matchday ? ` · MD${m.matchday}` : '';
    const ft = (m.score && m.score.fullTime) || {};
    const doc = {
      teamA: teamId(home),
      teamB: teamId(away),
      teamAName: home || '',
      teamBName: away || '',
      dateLabel: `${stage}${md}`.trim(),
      kickoffMs: m.utcDate ? Date.parse(m.utcDate) : null,
      status: mapStatus(m.status),
      scoreA: ft.home != null ? ft.home : 0,
      scoreB: ft.away != null ? ft.away : 0,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };
    batch.set(db.collection('fixtures').doc(id), doc, { merge: true });
    if (++ops >= 400) {
      await batch.commit();
      batch = db.batch();
      ops = 0;
    }
  }
  if (ops > 0) await batch.commit();
  console.log('Firestore fixtures updated.');
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});

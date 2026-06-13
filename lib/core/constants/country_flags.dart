/// Fallback flag/code/name lookup by 3-letter FIFA code, used when a team
/// isn't in the full `teams.json` catalog. Kept in sync with the sync
/// pipeline's `NAME_TO_ID` (tools/sync_fixtures/sync.js).
class CountryInfo {
  const CountryInfo(this.flag, this.code, this.name);
  final String flag;
  final String code;
  final String name;
}

const Map<String, CountryInfo> kCountryFlags = {
  // CONMEBOL
  'arg': CountryInfo('🇦🇷', 'ARG', 'Argentina'),
  'bra': CountryInfo('🇧🇷', 'BRA', 'Brazil'),
  'uru': CountryInfo('🇺🇾', 'URU', 'Uruguay'),
  'col': CountryInfo('🇨🇴', 'COL', 'Colombia'),
  'ecu': CountryInfo('🇪🇨', 'ECU', 'Ecuador'),
  'per': CountryInfo('🇵🇪', 'PER', 'Peru'),
  'chi': CountryInfo('🇨🇱', 'CHI', 'Chile'),
  'par': CountryInfo('🇵🇾', 'PAR', 'Paraguay'),
  'bol': CountryInfo('🇧🇴', 'BOL', 'Bolivia'),
  'ven': CountryInfo('🇻🇪', 'VEN', 'Venezuela'),
  // CONCACAF
  'usa': CountryInfo('🇺🇸', 'USA', 'United States'),
  'mex': CountryInfo('🇲🇽', 'MEX', 'Mexico'),
  'can': CountryInfo('🇨🇦', 'CAN', 'Canada'),
  'crc': CountryInfo('🇨🇷', 'CRC', 'Costa Rica'),
  'slv': CountryInfo('🇸🇻', 'SLV', 'El Salvador'),
  'gua': CountryInfo('🇬🇹', 'GUA', 'Guatemala'),
  'hon': CountryInfo('🇭🇳', 'HON', 'Honduras'),
  'jam': CountryInfo('🇯🇲', 'JAM', 'Jamaica'),
  'pan': CountryInfo('🇵🇦', 'PAN', 'Panama'),
  'hai': CountryInfo('🇭🇹', 'HAI', 'Haiti'),
  'tri': CountryInfo('🇹🇹', 'TRI', 'Trinidad and Tobago'),
  'cuw': CountryInfo('🇨🇼', 'CUW', 'Curaçao'),
  // UEFA
  'fra': CountryInfo('🇫🇷', 'FRA', 'France'),
  'ger': CountryInfo('🇩🇪', 'GER', 'Germany'),
  'esp': CountryInfo('🇪🇸', 'ESP', 'Spain'),
  'eng': CountryInfo('🏴󠁧󠁢󠁥󠁮󠁧󠁿', 'ENG', 'England'),
  'por': CountryInfo('🇵🇹', 'POR', 'Portugal'),
  'ned': CountryInfo('🇳🇱', 'NED', 'Netherlands'),
  'ita': CountryInfo('🇮🇹', 'ITA', 'Italy'),
  'bel': CountryInfo('🇧🇪', 'BEL', 'Belgium'),
  'sui': CountryInfo('🇨🇭', 'SUI', 'Switzerland'),
  'den': CountryInfo('🇩🇰', 'DEN', 'Denmark'),
  'pol': CountryInfo('🇵🇱', 'POL', 'Poland'),
  'cro': CountryInfo('🇭🇷', 'CRO', 'Croatia'),
  'srb': CountryInfo('🇷🇸', 'SRB', 'Serbia'),
  'aut': CountryInfo('🇦🇹', 'AUT', 'Austria'),
  'swe': CountryInfo('🇸🇪', 'SWE', 'Sweden'),
  'nor': CountryInfo('🇳🇴', 'NOR', 'Norway'),
  'hun': CountryInfo('🇭🇺', 'HUN', 'Hungary'),
  'cze': CountryInfo('🇨🇿', 'CZE', 'Czechia'),
  'rou': CountryInfo('🇷🇴', 'ROU', 'Romania'),
  'svk': CountryInfo('🇸🇰', 'SVK', 'Slovakia'),
  'svn': CountryInfo('🇸🇮', 'SVN', 'Slovenia'),
  'gre': CountryInfo('🇬🇷', 'GRE', 'Greece'),
  'tur': CountryInfo('🇹🇷', 'TUR', 'Türkiye'),
  'ukr': CountryInfo('🇺🇦', 'UKR', 'Ukraine'),
  'alb': CountryInfo('🇦🇱', 'ALB', 'Albania'),
  'wal': CountryInfo('🏴󠁧󠁢󠁷󠁬󠁳󠁿', 'WAL', 'Wales'),
  'sco': CountryInfo('🏴󠁧󠁢󠁳󠁣󠁴󠁿', 'SCO', 'Scotland'),
  'irl': CountryInfo('🇮🇪', 'IRL', 'Ireland'),
  'fin': CountryInfo('🇫🇮', 'FIN', 'Finland'),
  'isl': CountryInfo('🇮🇸', 'ISL', 'Iceland'),
  'mkd': CountryInfo('🇲🇰', 'MKD', 'North Macedonia'),
  'bih': CountryInfo('🇧🇦', 'BIH', 'Bosnia and Herzegovina'),
  // CAF
  'mar': CountryInfo('🇲🇦', 'MAR', 'Morocco'),
  'sen': CountryInfo('🇸🇳', 'SEN', 'Senegal'),
  'nga': CountryInfo('🇳🇬', 'NGA', 'Nigeria'),
  'gha': CountryInfo('🇬🇭', 'GHA', 'Ghana'),
  'rsa': CountryInfo('🇿🇦', 'RSA', 'South Africa'),
  'alg': CountryInfo('🇩🇿', 'ALG', 'Algeria'),
  'tun': CountryInfo('🇹🇳', 'TUN', 'Tunisia'),
  'egy': CountryInfo('🇪🇬', 'EGY', 'Egypt'),
  'cmr': CountryInfo('🇨🇲', 'CMR', 'Cameroon'),
  'civ': CountryInfo('🇨🇮', 'CIV', "Côte d'Ivoire"),
  'mli': CountryInfo('🇲🇱', 'MLI', 'Mali'),
  'cpv': CountryInfo('🇨🇻', 'CPV', 'Cape Verde'),
  'cod': CountryInfo('🇨🇩', 'COD', 'DR Congo'),
  'ang': CountryInfo('🇦🇴', 'ANG', 'Angola'),
  'bfa': CountryInfo('🇧🇫', 'BFA', 'Burkina Faso'),
  'zam': CountryInfo('🇿🇲', 'ZAM', 'Zambia'),
  // AFC
  'kor': CountryInfo('🇰🇷', 'KOR', 'South Korea'),
  'jpn': CountryInfo('🇯🇵', 'JPN', 'Japan'),
  'aus': CountryInfo('🇦🇺', 'AUS', 'Australia'),
  'irn': CountryInfo('🇮🇷', 'IRN', 'Iran'),
  'ksa': CountryInfo('🇸🇦', 'KSA', 'Saudi Arabia'),
  'qat': CountryInfo('🇶🇦', 'QAT', 'Qatar'),
  'uae': CountryInfo('🇦🇪', 'UAE', 'United Arab Emirates'),
  'irq': CountryInfo('🇮🇶', 'IRQ', 'Iraq'),
  'jor': CountryInfo('🇯🇴', 'JOR', 'Jordan'),
  'uzb': CountryInfo('🇺🇿', 'UZB', 'Uzbekistan'),
  'chn': CountryInfo('🇨🇳', 'CHN', 'China'),
  'prk': CountryInfo('🇰🇵', 'PRK', 'North Korea'),
  'oma': CountryInfo('🇴🇲', 'OMA', 'Oman'),
  'lbn': CountryInfo('🇱🇧', 'LBN', 'Lebanon'),
  'vie': CountryInfo('🇻🇳', 'VIE', 'Vietnam'),
  'idn': CountryInfo('🇮🇩', 'IDN', 'Indonesia'),
  'tha': CountryInfo('🇹🇭', 'THA', 'Thailand'),
  // OFC
  'nzl': CountryInfo('🇳🇿', 'NZL', 'New Zealand'),
};

/// Aliases for raw lowercased team names that the sync pipeline may have
/// written to Firestore before NAME_TO_ID covered them.
const Map<String, String> _kFlagAliases = {
  'paraguay': 'par',
  'bolivia': 'bol',
  'venezuela': 'ven',
  'southafrica': 'rsa',
  'newzealand': 'nzl',
  'unitedstates': 'usa',
  'costarica': 'crc',
  'elsalvador': 'slv',
  'ivorycoast': 'civ',
  'cotedivoire': 'civ',
  'capeverde': 'cpv',
  'drcongo': 'cod',
  'northkorea': 'prk',
  'koreadpr': 'prk',
  'koreasouth': 'kor',
  'koreanorth': 'prk',
  'unitedarabemirates': 'uae',
  'saudiarabia': 'ksa',
  'burkinafaso': 'bfa',
  'czechrepublic': 'cze',
  'northmacedonia': 'mkd',
  'bosniaandherzegovina': 'bih',
  'republicofireland': 'irl',
  'trinidadandtobago': 'tri',
  'chinapr': 'chn',
};

/// Built once: maps a raw lowercased-name key (and its 12-char truncation,
/// matching the old sync's `slice(0, 12)`) to a FIFA code. This catches
/// fixtures that the sync pipeline wrote *before* `NAME_TO_ID` covered the
/// nation — e.g. `qatar` → `qat`, `haiti` → `hai`, `turkey`/`trkiye` → `tur`.
final Map<String, String> _kNameAliases = _buildNameAliases();

Map<String, String> _buildNameAliases() {
  String strip(String s) => s.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
  final map = <String, String>{};
  kCountryFlags.forEach((code, info) {
    final n = strip(info.name);
    if (n.isNotEmpty) {
      map[n] = code;
      if (n.length > 12) map[n.substring(0, 12)] = code; // old-sync truncation
    }
  });
  // Manual extras for name variants the API may emit differently.
  map.addAll(const {
    'turkey': 'tur',
    'trkiye': 'tur',
    'ivorycoast': 'civ',
    'czechrepublic': 'cze',
    'irrian': 'irn',
    'koreadpr': 'prk',
    'curaao': 'cuw',
    'capeverdeisl': 'cpv', // "Cape Verde Islands" truncated to 12 chars
    'capeverdeislands': 'cpv',
    'congodr': 'cod',
    'drcongo': 'cod',
    'bosniaherzeg': 'bih', // "Bosnia-Herzegovina" truncated to 12 chars
    'bosniaherzegovina': 'bih',
  });
  return map;
}

CountryInfo? _lookup(String id) {
  final key = id.toLowerCase();
  final direct = kCountryFlags[key];
  if (direct != null) return direct;
  final alias = _kFlagAliases[key];
  if (alias != null) return kCountryFlags[alias];
  final nameAlias = _kNameAliases[key];
  if (nameAlias != null) return kCountryFlags[nameAlias];
  return null;
}

/// Returns the flag emoji for an id, falling back to a generic white flag.
String flagForId(String id) => _lookup(id)?.flag ?? '🏳️';

/// Returns the display name for an id, falling back to the id itself.
String nameForId(String id) => _lookup(id)?.name ?? id;

/// Returns the FIFA short code for an id, falling back to upper-case id.
String codeForId(String id) => _lookup(id)?.code ?? id.toUpperCase();

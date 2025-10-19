// team_codes.dart (예: lib/constants/team_codes.dart)
const Map<String, String> teamShortCodesByName = {
  'LG 트윈스': 'LG',
  '두산 베어스': 'OB',
  'SSG 랜더스': 'SK',
  '한화 이글스': 'HH',
  '삼성 라이온즈': 'SS',
  'KT 위즈': 'KT',
  '롯데 자이언츠': 'LT',
  '기아 타이거즈': 'HT',
  'NC 다이노스': 'NC',
  '키움 히어로즈': 'WO',
};

final Map<String, String> teamFullNameByCode = {
  for (final e in teamShortCodesByName.entries) e.value: e.key
};

String teamNameFromCode(String code) => teamFullNameByCode[code] ?? code;

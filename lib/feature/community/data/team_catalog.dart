import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/team_item.dart';

const kboTeams = <TeamItem>[
  TeamItem(
    code: 'HT',
    label: '기아 타이거즈 🐯',
    imagePath: 'assets/images/card_kia.svg',
  ),
  TeamItem(
    code: 'HH',
    label: '한화 이글스 🦅',
    imagePath: 'assets/images/card_hanhwa.svg',
  ),
  TeamItem(
    code: 'WO',
    label: '키움 히어로즈 🦸🏻️',
    imagePath: 'assets/images/card_kw.png',
  ),
  TeamItem(
    code: 'LG',
    label: 'LG 트윈스 👶🏻👶🏻',
    imagePath: 'assets/images/card_lg.svg',
  ),
  TeamItem(
    code: 'NC',
    label: 'NC 다이노스 🦖',
    imagePath: 'assets/images/card_nc.svg',
  ),
  TeamItem(
    code: 'SK',
    label: 'SSG 랜더스 🗺️',
    imagePath: 'assets/images/card_ssg.png',
  ),
  TeamItem(
    code: 'SS',
    label: '삼성 라이온즈 🦁',
    imagePath: 'assets/images/card_samsung.svg',
  ),
  TeamItem(
    code: 'LT',
    label: '롯데 자이언츠 🌊️',
    imagePath: 'assets/images/card_lotte.svg',
  ),
  TeamItem(
    code: 'KT',
    label: 'KT 위즈 🧙🏻',
    imagePath: 'assets/images/card_kt.svg',
  ),
  TeamItem(
    code: 'OB',
    label: '두산 베어스 🐻',
    imagePath: 'assets/images/card_doosan.svg',
  ),
];

final Map<String, TeamItem> kboTeamCatalog = {
  for (final team in kboTeams) team.code: team,
};

final Map<String, String> kboTeamBannerCatalog = {
  'HT': 'assets/images/mydoo_banner.png',
  'HH': 'assets/images/mydoo_banner.png',
  'WO': 'assets/images/mydoo_banner.png',
  'LG': 'assets/images/mydoo_banner.png',
  'NC': 'assets/images/mydoo_banner.png',
  'SK': 'assets/images/mydoo_banner.png',
  'SS': 'assets/images/mydoo_banner.png',
  'LT': 'assets/images/mydoo_banner.png',
  'KT': 'assets/images/mydoo_banner.png',
  'OB': 'assets/images/mydoo_banner.png',
};

TeamItem? kboTeamOf(String code) => kboTeamCatalog[code];

String kboTeamLabelOf(String code) => kboTeamCatalog[code]?.label ?? code;

const Map<String, Color> kboTeamColors = {
  'WO': Color(0xFF7E0022), // 키움
  'HT': Color(0xFFE10822), // 기아
  'LG': Color(0xFFC30136), // LG
  'LT': Color(0xFFD10F31), // 롯데
  'SK': Color(0xFFC81431), // SSG
  'SS': Color(0xFF0064B2), // 삼성
  'OB': Color(0xFF010039), // 두산
  'NC': Color(0xFF1F477A), // NC
  'HH': Color(0xFFFC4E00), // 한화
  'KT': Color(0xFF000000), // KT
};

Color kboTeamColorOf(String code) =>
    kboTeamColors[code] ?? const Color(0xFF1A1A1A);

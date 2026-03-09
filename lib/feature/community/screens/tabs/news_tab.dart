import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/widgets/news/news_card.dart';
import 'package:inninglog/feature/community/widgets/news/news_section.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class NewsTab extends StatelessWidget {
  final String teamCode;

  const NewsTab({super.key, required this.teamCode});

  String get _teamHighlightText {
    if (teamCode == 'ALL') return '전체';
    final label = kboTeamLabelOf(teamCode);
    final sanitized = label.replaceAll(RegExp(r'[^0-9A-Za-z가-힣 ]'), '').trim();
    return sanitized.replaceAll(' ', '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary50,
      child: ListView(
        padding: const EdgeInsets.only(top: 20, bottom: 24),
        children: [
          _TeamNewsSection(highlightText: _teamHighlightText),
          SizedBox(height: 32),
          const _KboNewsSection(),
        ],
      ),
    );
  }
}

class _TeamNewsSection extends StatelessWidget {
  final String highlightText;

  const _TeamNewsSection({required this.highlightText});

  static const _items = <NewsCardItemData>[
    NewsCardItemData(
      title: '두산, 최근 10년 FA 지출 1위 기록',
      summaryBullets: [
        '두산, 최근 10년 FA 시장에서 830억 원 지출로 1위',
        '내부 핵심 선수 재계약 + 박찬호 영입 등 공격적 투자 기조',
      ],
      tags: ['FA시장', '박찬호'],
    ),
    NewsCardItemData(
      title: '두산, 최근 10년 FA 지출 1위 기록',
      summaryBullets: [
        '두산, 최근 10년 FA 시장에서 830억 원 지출로 1위',
        '내부 핵심 선수 재계약 + 박찬호 영입 등 공격적 투자 기조',
      ],
      tags: ['FA시장', '박찬호'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NewsSection(
      highlightText: highlightText,
      showInfoIcon: true,
      items: _items,
    );
  }
}

class _KboNewsSection extends StatelessWidget {
  const _KboNewsSection();

  static const _items = <NewsCardItemData>[
    NewsCardItemData(
      title: '토론토, 폰세 영입으로 ‘KBO 파이프라인’ 본격 가동',
      summaryBullets: [
        '토론토, KBO MVP 코디 폰세와 3년 3,000만 달러 계약...KBO 출신 영입 확대',
        '라우어 성공·문서준 영입 등 사례 누적되며 KBO 시장을 새로운 전력 루트로 활용',
      ],
      tags: ['FA시장', '박찬호'],
    ),
    NewsCardItemData(
      title: '두산, 최근 10년 FA 지출 1위 기록',
      summaryBullets: [
        '두산, 최근 10년 FA 시장에서 830억 원 지출로 1위',
        '내부 핵심 선수 재계약 + 박찬호 영입 등 공격적 투자 기조',
      ],
      tags: ['FA시장', '박찬호'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return const NewsSection(highlightText: 'KBO', items: _items);
  }
}

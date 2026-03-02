import 'package:inninglog/feature/community/screens/teamboard_page.dart';
import 'package:inninglog/feature/community/widgets/shared/segmented_tabs.dart';

const normalTabs = <CommunityTabItem>[
  CommunityTabItem(type: BoardTab.onlywan, label: '오직완'),
  CommunityTabItem(type: BoardTab.free, label: '자유 게시판'),
  CommunityTabItem(type: BoardTab.news, label: '오늘의 뉴스'),
];

const myActivityTabs = <CommunityTabItem>[
  CommunityTabItem(type: BoardTab.onlywan, label: '오늘의 직관'),
  CommunityTabItem(type: BoardTab.free, label: '자유 게시판'),
];

List<CommunityTabItem> communityTabsByMode(BoardMode mode) {
  switch (mode) {
    case BoardMode.normal:
      return normalTabs;
    case BoardMode.myPosts:
    case BoardMode.myComments:
    case BoardMode.scraps:
    case BoardMode.popular:
      return myActivityTabs;
  }
}

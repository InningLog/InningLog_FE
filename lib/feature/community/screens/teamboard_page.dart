import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/feature/community/data/tabs_config.dart';
import 'package:inninglog/feature/community/data/team_catalog.dart';
import 'package:inninglog/feature/community/widgets/shared/segmented_tabs.dart';
import 'package:inninglog/router/app_routes.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/widgets/common_header.dart';
import 'tabs/free_board_tab.dart';
import 'tabs/news_tab.dart';
import 'tabs/onlywan_tab.dart';

enum BoardMode { normal, myPosts, myComments, scraps, popular }

class TeamBoardPage extends StatefulWidget {
  /// normal 모드에서만 필수. 그 외 모드(myPosts, myComments, scraps, popular)는 null 가능.
  final String? teamCode;
  final BoardTab? activeTab;
  final BoardMode mode;

  const TeamBoardPage({
    super.key,
    this.teamCode,
    this.activeTab,
    this.mode = BoardMode.normal,
  }) : assert(
         mode != BoardMode.normal || teamCode != null,
         'teamCode is required for BoardMode.normal',
       );

  @override
  State<TeamBoardPage> createState() => _TeamBoardPageState();
}

class _TeamBoardPageState extends State<TeamBoardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final List<CommunityTabItem> _tabs;
  bool _isSyncingRoute = false;

  @override
  void initState() {
    super.initState();

    _tabs = communityTabsByMode(widget.mode);

    final safeIndex = _resolveTabIndex(widget.activeTab);

    _tabController = TabController(
      length: _tabs.length,
      vsync: this,
      initialIndex: safeIndex,
    );

    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TeamBoardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeTab != widget.activeTab) {
      final nextIndex = _resolveTabIndex(widget.activeTab);
      if (_tabController.index != nextIndex) {
        _isSyncingRoute = true;
        _tabController.index = nextIndex;
        _isSyncingRoute = false;
      }
    }
  }

  int _resolveTabIndex(BoardTab? tab) {
    final resolvedTab = tab ?? BoardTab.onlywan;
    final index = _tabs.indexWhere((item) => item.type == resolvedTab);
    if (index >= 0) return index;
    return 0;
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging || _isSyncingRoute) return;
    if (widget.mode != BoardMode.normal) return;
    final tabType = _tabs[_tabController.index].type;
    final tabPath = boardTabPath(tabType);
    context.replace(
      AppRoutePaths.boardLocation(widget.teamCode!, tab: tabPath),
    );
  }

  String get _headerTitle {
    switch (widget.mode) {
      case BoardMode.myPosts:
        return '내가 쓴 글';
      case BoardMode.myComments:
        return '댓글 단 글';
      case BoardMode.scraps:
        return '스크랩';
      case BoardMode.popular:
        return '인기 게시물';
      case BoardMode.normal:
        return widget.teamCode == 'ALL'
            ? 'KBO 전체게시판'
            : kboTeamLabelOf(widget.teamCode!);
    }
  }

  BoardTab get _searchInitialTab {
    final current = _tabs[_tabController.index].type;
    return current == BoardTab.free ? BoardTab.free : BoardTab.onlywan;
  }

  @override
  Widget build(BuildContext context) {
    final isNormal = widget.mode == BoardMode.normal;
    final isFreeTab = _tabs[_tabController.index].type == BoardTab.free;
    return Scaffold(
      backgroundColor: AppColors.primary50,
      floatingActionButton:
          isNormal && isFreeTab
              ? SizedBox(
                width: 56,
                height: 56,
                child: FloatingActionButton(
                  backgroundColor: AppColors.primary700,
                  shape: const CircleBorder(),
                  onPressed: () {
                    // 기존 게시판 글쓰기
                    context.push(
                      AppRoutePaths.boardPostWriteLocation(widget.teamCode!),
                    );
                    debugPrint(
                      '[Team Board Page] teamCode: ${widget.teamCode}',
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    size: 40,
                    color: AppColors.primary50,
                  ),
                ),
              )
              : null,

      body: SafeArea(
        child: Column(
          children: [
            // 상단 헤더 (뒤로가기 포함)
            CommonHeader(
              title: _headerTitle,
              onSearchPressed:
                  isNormal
                      ? () => context.push(
                        AppRoutePaths.searchLocation(
                          teamCode: widget.teamCode ?? 'ALL',
                          tab: boardTabPath(_searchInitialTab),
                        ),
                      )
                      : null,
            ),

            SegmentedTabs(controller: _tabController, items: _tabs),

            // 구분선
            const Divider(height: 1, thickness: 0.8, color: AppColors.gray400),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isActive = index == _tabController.index;
                  switch (tab.type) {
                    case BoardTab.onlywan:
                      return OnlyWanTab(
                        isActive: isActive,
                        teamCode: widget.teamCode ?? '',
                        mode: widget.mode,
                      );
                    case BoardTab.free:
                      return FreeBoardTab(
                        teamCode: widget.teamCode,
                        isActive: isActive,
                        mode: widget.mode,
                      );
                    case BoardTab.news:
                      return NewsTab(teamCode: widget.teamCode ?? 'ALL');
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

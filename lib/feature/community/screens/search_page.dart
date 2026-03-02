import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inninglog/app_scope.dart';
import 'package:inninglog/feature/community/model/comment_domain_type.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/viewmodel/comment_view_model.dart';
import 'package:inninglog/feature/community/viewmodel/community_search_view_model.dart';
import 'package:inninglog/feature/community/viewmodel/journal_action_view_model.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_bottom_sheet.dart';
import 'package:inninglog/feature/community/widgets/search/recent_search_section.dart';
import 'package:inninglog/feature/community/widgets/search/search_result_section.dart';
import 'package:inninglog/feature/community/widgets/search/search_top_bar.dart';
import 'package:inninglog/feature/community/widgets/shared/segmented_tabs.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:provider/provider.dart';

class CommunitySearchPage extends StatefulWidget {
  final String? initialTeamCode;
  final BoardTab? initialTab;

  const CommunitySearchPage({
    super.key,
    this.initialTeamCode = 'ALL',
    this.initialTab = BoardTab.onlywan,
  });

  @override
  State<CommunitySearchPage> createState() => _CommunitySearchPageState();
}

class _CommunitySearchPageState extends State<CommunitySearchPage>
    with SingleTickerProviderStateMixin {
  static const _hint = '제목 또는 내용을 검색해 보세요!';

  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  TabController? _tabController;
  CommunitySearchViewModel? _vm;
  JournalActionsViewModel? _journalActionsVm;
  bool _didRequestFocus = false;

  @override
  void initState() {
    super.initState();
    _ensureInitialized();
    _ctrl.addListener(_handleInputChange);
    _requestFocusOnce();
  }

  @override
  void dispose() {
    _ctrl.removeListener(_handleInputChange);
    _ctrl.dispose();
    _focus.dispose();
    _tabController
      ?..removeListener(_handleTabChange)
      ..dispose();
    _vm?.dispose();
    _journalActionsVm?.dispose();
    super.dispose();
  }

  void _ensureInitialized() {
    if (_tabController != null && _vm != null) return;

    final initialTab =
        (widget.initialTab == BoardTab.free) ? BoardTab.free : BoardTab.onlywan;
    final appScope = context.read<AppScope>();
    _journalActionsVm = JournalActionsViewModel(repo: appScope.diaryRepository);

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTab == BoardTab.free ? 1 : 0,
    )..addListener(_handleTabChange);

    _vm = CommunitySearchViewModel(
      teamCode: widget.initialTeamCode ?? 'ALL',
      initialTab: initialTab,
      diaryRepository: appScope.diaryRepository,
      postRepository: appScope.communityPostRepository,
      journalActions: _journalActionsVm!,
    )..init();
  }

  void _requestFocusOnce() {
    if (_didRequestFocus) return;
    _didRequestFocus = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focus.requestFocus();
      }
    });
  }

  void _handleInputChange() {
    if (_ctrl.text.trim().isNotEmpty) return;
    _vm?.clearQuery();
  }

  void _handleTabChange() {
    final tabController = _tabController;
    final vm = _vm;
    if (tabController == null || vm == null) return;
    if (tabController.indexIsChanging) return;
    final nextTab = tabController.index == 1 ? BoardTab.free : BoardTab.onlywan;
    vm.changeTab(nextTab);
  }

  Future<void> _submitSearch(String raw) async {
    final term = raw.trim();
    if (term.isEmpty) return;

    _ctrl.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );

    final vm = _vm;
    if (vm == null) return;
    await vm.submitQuery(term);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  Future<void> _tapHistoryTerm(String term) async {
    _ctrl.value = TextEditingValue(
      text: term,
      selection: TextSelection.collapsed(offset: term.length),
    );
    await _submitSearch(term);
  }

  @override
  Widget build(BuildContext context) {
    _ensureInitialized();
    final vm = _vm;
    final tabController = _tabController;
    if (vm == null || tabController == null) {
      return const SizedBox.shrink();
    }

    return ChangeNotifierProvider<CommunitySearchViewModel>.value(
      value: vm,
      child: Consumer<CommunitySearchViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.primary50,
            body: SafeArea(
              child: Column(
                children: [
                  SearchTopBar(
                    controller: _ctrl,
                    focusNode: _focus,
                    hintText: _hint,
                    onSubmitted: _submitSearch,
                    onBack: () => context.pop(),
                    onClear: () {
                      _ctrl.clear();
                      vm.clearQuery();
                      _focus.requestFocus();
                    },
                  ),

                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child:
                          vm.hasQuery
                              ? SearchResultSection(
                                controller: tabController,
                                onlywanResults: vm.onlywanResults,
                                freeResults: vm.freeResults,
                                isLoading: vm.isLoading,
                                hasNext: vm.hasNext,
                                onLoadMore: vm.loadMore,
                                query: vm.query,
                                teamCode: vm.teamCode,
                                onToggleJournalLike: vm.toggleJournalLike,
                                onToggleJournalScrap: vm.toggleJournalScrap,
                                onTapJournalComment: (DiaryItemModel item) {
                                  final repo =
                                      context
                                          .read<AppScope>()
                                          .commentRepository;
                                  final commentVm = CommentViewModel(
                                    domainType: CommentDomainType.feed,
                                    domainId: item.journalId,
                                    repo: repo,
                                  );
                                  showCommentBottomSheet(
                                    context,
                                    viewModel: commentVm,
                                    onCommentCountChanged:
                                        (count) => vm.updateJournalCommentCount(
                                          journalId: item.journalId,
                                          count: count,
                                        ),
                                  );
                                },
                                isJournalLikePending: vm.isJournalLikePending,
                                isJournalScrapPending: vm.isJournalScrapPending,
                              )
                              : RecentSearchSection(
                                history: vm.history,
                                onTapTerm: _tapHistoryTerm,
                                onDeleteTerm: vm.removeHistoryTerm,
                                onClearAll: vm.clearHistory,
                              ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/board_tab.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/repositories/diary_repository.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';
import 'package:inninglog/feature/community/repositories/search_history_repository.dart';
import 'package:inninglog/feature/community/viewmodel/journal_action_view_model.dart';

class CommunitySearchViewModel extends ChangeNotifier {
  final String teamCode;
  final DiaryRepository diaryRepository;
  final CommunityPostRepository postRepository;
  final SearchHistoryRepository _searchHistoryRepository;
  final JournalActionsViewModel _journalActions;
  final int pageSize;
  BoardTab _selectedTab;

  CommunitySearchViewModel({
    required this.teamCode,
    required BoardTab initialTab,
    required this.diaryRepository,
    required this.postRepository,
    required SearchHistoryRepository searchHistoryRepository,
    required JournalActionsViewModel journalActions,
    this.pageSize = 10,
  }) : _selectedTab = _normalizeTab(initialTab),
       _searchHistoryRepository = searchHistoryRepository,
       _journalActions = journalActions;

  String _query = '';
  List<String> _history = [];

  final List<DiaryItemModel> _onlywanResults = [];
  final List<CommunityPostItem> _freeResults = [];

  final Set<BoardTab> _loadedTabs = {};

  int _onlywanPage = -1;
  int _freePage = -1;
  bool _onlywanHasNext = false;
  bool _freeHasNext = false;

  bool _isLoading = false;
  String? _error;

  String get query => _query;
  bool get hasQuery => _query.trim().isNotEmpty;
  List<String> get history => List.unmodifiable(_history);
  BoardTab get selectedTab => _selectedTab;

  List<DiaryItemModel> get onlywanResults => List.unmodifiable(_onlywanResults);
  List<CommunityPostItem> get freeResults => List.unmodifiable(_freeResults);

  bool get isLoading => _isLoading;
  bool get hasNext {
    if (_selectedTab == BoardTab.onlywan) return _onlywanHasNext;
    if (_selectedTab == BoardTab.free) return _freeHasNext;
    return false;
  }

  String? get error => _error;

  bool isJournalLikePending(String journalId) =>
      _journalActions.isLikePending(journalId);
  bool isJournalScrapPending(String journalId) =>
      _journalActions.isScrapPending(journalId);

  static BoardTab _normalizeTab(BoardTab tab) {
    return tab == BoardTab.free ? BoardTab.free : BoardTab.onlywan;
  }

  Future<void> init() async {
    await _loadHistory();
  }

  Future<void> submitQuery(String raw) async {
    final term = raw.trim();
    if (term.isEmpty) return;

    _query = term;
    await _addHistory(term);

    _loadedTabs.clear();
    await refreshCurrentTab();
  }

  Future<void> selectHistory(String term) async {
    await submitQuery(term);
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    _loadedTabs.clear();
    _onlywanResults.clear();
    _freeResults.clear();
    _journalActions.clearPending();
    _onlywanPage = -1;
    _freePage = -1;
    _onlywanHasNext = false;
    _freeHasNext = false;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  Future<void> changeTab(BoardTab tab) async {
    final next = _normalizeTab(tab);
    if (_selectedTab == next) return;

    _selectedTab = next;
    notifyListeners();

    if (!hasQuery || _loadedTabs.contains(next)) return;
    await refreshCurrentTab();
  }

  Future<void> refreshCurrentTab() async {
    if (!hasQuery) return;
    await _loadCurrentTab(reset: true);
  }

  Future<void> loadMore() async {
    if (!hasQuery || _isLoading || !hasNext) return;
    await _loadCurrentTab(reset: false);
  }

  Future<void> toggleJournalLike(String journalId) async {
    final index = _onlywanResults.indexWhere((i) => i.journalId == journalId);
    if (index < 0) return;
    await _journalActions.toggleLike(
      journalId: journalId,
      currentItem: _onlywanResults[index],
      onUpdate: (updated) {
        _onlywanResults[index] = updated;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> toggleJournalScrap(String journalId) async {
    final index = _onlywanResults.indexWhere((i) => i.journalId == journalId);
    if (index < 0) return;
    await _journalActions.toggleScrap(
      journalId: journalId,
      currentItem: _onlywanResults[index],
      onUpdate: (updated) {
        _onlywanResults[index] = updated;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void updateJournalCommentCount({
    required String journalId,
    required int count,
  }) {
    final index = _onlywanResults.indexWhere((i) => i.journalId == journalId);
    if (index < 0) return;
    _journalActions.updateCommentCount(
      journalId: journalId,
      count: count,
      currentItem: _onlywanResults[index],
      onUpdate: (updated) {
        _onlywanResults[index] = updated;
        notifyListeners();
      },
    );
  }

  Future<void> removeHistoryTerm(String term) async {
    _history.remove(term);
    notifyListeners();
    await _searchHistoryRepository.save(_history);
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _searchHistoryRepository.clear();
  }

  Future<void> _loadCurrentTab({required bool reset}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    if (reset) {
      _resetTabState(_selectedTab);
    }
    notifyListeners();

    try {
      switch (_selectedTab) {
        case BoardTab.onlywan:
          await _searchOnlywan(reset: reset);
          break;
        case BoardTab.free:
          await _searchFree(reset: reset);
          break;
        case BoardTab.news:
          break;
      }
      _loadedTabs.add(_selectedTab);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _searchOnlywan({required bool reset}) async {
    final nextPage = reset ? 0 : _onlywanPage + 1;
    final response = await diaryRepository.searchJournals(
      teamShortCode: teamCode,
      keyword: _query,
      page: nextPage,
      size: pageSize,
    );
    final mapped = response.content.map((item) => item.toModel()).toList();

    if (reset) {
      _onlywanResults
        ..clear()
        ..addAll(mapped);
    } else {
      _onlywanResults.addAll(mapped);
    }

    _onlywanPage = response.page;
    _onlywanHasNext = response.hasNext;
  }

  Future<void> _searchFree({required bool reset}) async {
    final nextPage = reset ? 0 : _freePage + 1;
    final response = await postRepository.searchPosts(
      teamShortCode: teamCode,
      keyword: _query,
      page: nextPage,
      size: pageSize,
    );

    if (reset) {
      _freeResults
        ..clear()
        ..addAll(response.content);
    } else {
      _freeResults.addAll(response.content);
    }

    _freePage = response.page;
    _freeHasNext = response.hasNext;
  }

  void _resetTabState(BoardTab tab) {
    if (tab == BoardTab.onlywan) {
      _onlywanResults.clear();
      _journalActions.clearPending();
      _onlywanPage = -1;
      _onlywanHasNext = false;
      return;
    }
    if (tab == BoardTab.free) {
      _freeResults.clear();
      _freePage = -1;
      _freeHasNext = false;
    }
  }

  Future<void> _addHistory(String term) async {
    _history.remove(term);
    _history.insert(0, term);
    if (_history.length > SearchHistoryRepository.maxHistory) {
      _history = _history.sublist(0, SearchHistoryRepository.maxHistory);
    }
    notifyListeners();
    await _searchHistoryRepository.save(_history);
  }

  Future<void> _loadHistory() async {
    _history = await _searchHistoryRepository.load();
    notifyListeners();
  }
}

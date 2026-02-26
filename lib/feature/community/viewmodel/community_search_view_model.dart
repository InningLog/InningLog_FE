import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/widgets/shared/segmented_tabs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommunitySearchViewModel extends ChangeNotifier {
  static const _prefsKey = 'community_search_history';
  static const _maxHistory = 15;

  final String teamCode;
  BoardTab _selectedTab;

  CommunitySearchViewModel({
    required this.teamCode,
    required BoardTab initialTab,
  }) : _selectedTab = _normalizeTab(initialTab);

  String _query = '';
  List<String> _history = [];

  final List<DiaryItemModel> _onlywanResults = [];
  final List<CommunityPostItem> _freeResults = [];

  final Set<BoardTab> _loadedTabs = {};

  bool _isLoading = false;
  bool _hasNext = false;

  String get query => _query;
  bool get hasQuery => _query.trim().isNotEmpty;
  List<String> get history => List.unmodifiable(_history);
  BoardTab get selectedTab => _selectedTab;

  List<DiaryItemModel> get onlywanResults => List.unmodifiable(_onlywanResults);
  List<CommunityPostItem> get freeResults => List.unmodifiable(_freeResults);

  bool get isLoading => _isLoading;
  bool get hasNext => _hasNext;

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
    _isLoading = false;
    _hasNext = false;
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
    if (!hasQuery || _isLoading || !_hasNext) return;
    await _loadCurrentTab(reset: false);
  }

  Future<void> removeHistoryTerm(String term) async {
    _history.remove(term);
    notifyListeners();
    await _saveHistory();
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  Future<void> _loadCurrentTab({required bool reset}) async {
    if (_isLoading) return;

    _isLoading = true;
    if (reset) {
      _hasNext = false;
      if (_selectedTab == BoardTab.onlywan) {
        _onlywanResults.clear();
      } else {
        _freeResults.clear();
      }
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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _searchOnlywan({required bool reset}) async {
    // TODO(API): teamCode + query + tab(onlywan) 조건으로 검색 API 연결
    // TODO(API): 페이징(loadMore) 처리 시 _hasNext와 리스트 append 적용
    _hasNext = false;
  }

  Future<void> _searchFree({required bool reset}) async {
    // TODO(API): teamCode + query + tab(free) 조건으로 검색 API 연결
    // TODO(API): 페이징(loadMore) 처리 시 _hasNext와 리스트 append 적용
    _hasNext = false;
  }

  Future<void> _addHistory(String term) async {
    _history.remove(term);
    _history.insert(0, term);
    if (_history.length > _maxHistory) {
      _history = _history.sublist(0, _maxHistory);
    }
    notifyListeners();
    await _saveHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList(_prefsKey) ?? [];
    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _history);
  }
}

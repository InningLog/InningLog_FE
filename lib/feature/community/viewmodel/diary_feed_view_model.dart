import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/model/dto/diary_dtos.dart';
import 'package:inninglog/feature/community/viewmodel/journal_action_view_model.dart';

typedef DiaryFetcher = Future<DiaryFeedResponse> Function(int page, int size);

class DiaryFeedViewModel extends ChangeNotifier {
  final DiaryFetcher _fetcher;
  final int pageSize;
  final JournalActionsViewModel _journalActions;

  DiaryFeedViewModel({
    required DiaryFetcher fetcher,
    required JournalActionsViewModel journalActions,
    this.pageSize = 10,
  }) : _fetcher = fetcher,
       _journalActions = journalActions;

  final List<DiaryItemModel> _items = [];
  List<DiaryItemModel> get items => List.unmodifiable(_items);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasNext = true;
  bool get hasNext => _hasNext;

  int _page = 0;
  String? _error;
  String? get error => _error;
  bool _hasLoadedOnce = false;
  bool get hasLoadedOnce => _hasLoadedOnce;
  bool isJournalLikePending(String journalId) =>
      _journalActions.isLikePending(journalId);
  bool isJournalScrapPending(String journalId) =>
      _journalActions.isScrapPending(journalId);

  Future<void> refresh() => loadInitial();

  Future<void> loadInitial() async {
    _items.clear();
    _page = 0;
    _hasNext = true;
    _error = null;
    await _fetch();
  }

  Future<void> ensureLoaded() async {
    if (_hasLoadedOnce || _isLoading) return;
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_isLoading || !_hasNext) return;
    _page += 1;
    await _fetch();
  }

  Future<void> toggleLike({required String journalId}) async {
    final index = _items.indexWhere((i) => i.journalId == journalId);
    if (index < 0) return;
    await _journalActions.toggleLike(
      journalId: journalId,
      currentItem: _items[index],
      onUpdate: (updated) {
        _items[index] = updated;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  Future<void> toggleScrap({required String journalId}) async {
    final index = _items.indexWhere((i) => i.journalId == journalId);
    if (index < 0) return;
    await _journalActions.toggleScrap(
      journalId: journalId,
      currentItem: _items[index],
      onUpdate: (updated) {
        _items[index] = updated;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );
  }

  void updateCommentCount({required String journalId, required int count}) {
    final index = _items.indexWhere((i) => i.journalId == journalId);
    if (index < 0) return;
    _journalActions.updateCommentCount(
      journalId: journalId,
      count: count,
      currentItem: _items[index],
      onUpdate: (updated) {
        _items[index] = updated;
        notifyListeners();
      },
    );
  }

  Future<void> _fetch() async {
    _isLoading = true;
    notifyListeners();
    try {
      final DiaryFeedResponse res = await _fetcher(_page, pageSize);

      final mapped = res.content.map((e) => e.toModel()).toList();
      if (_page == 0) {
        _items
          ..clear()
          ..addAll(mapped);
      } else {
        _items.addAll(mapped);
      }

      _hasNext = res.hasNext;
      _error = null;
    } catch (e) {
      if (_page > 0) _page -= 1;
      _error = e.toString();
    } finally {
      _hasLoadedOnce = true;
      _isLoading = false;
      notifyListeners();
    }
  }
}

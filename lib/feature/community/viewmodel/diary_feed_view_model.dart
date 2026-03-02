import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/model/dto/diary_dtos.dart';
import 'package:inninglog/feature/community/repositories/diary_repository.dart';
import 'package:inninglog/feature/community/viewmodel/journal_action_view_model.dart';

class DiaryFeedViewModel extends ChangeNotifier {
  final DiaryRepository repo;
  final String teamCode;
  final int pageSize;
  final JournalActionsViewModel _journalActions;

  DiaryFeedViewModel({
    required this.repo,
    required this.teamCode,
    required JournalActionsViewModel journalActions,
    this.pageSize = 10,
  }) : _journalActions = journalActions;

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
    await _journalActions.toggleLike(
      items: _items,
      journalId: journalId,
      notifyItems: notifyListeners,
      onError: (error) {
        _error = error.toString();
      },
    );
  }

  Future<void> toggleScrap({required String journalId}) async {
    await _journalActions.toggleScrap(
      items: _items,
      journalId: journalId,
      notifyItems: notifyListeners,
      onError: (error) {
        _error = error.toString();
      },
    );
  }

  void updateCommentCount({required String journalId, required int count}) {
    _journalActions.updateCommentCount(
      items: _items,
      journalId: journalId,
      count: count,
      notifyItems: notifyListeners,
    );
  }

  Future<void> _fetch() async {
    _isLoading = true;
    notifyListeners();
    try {
      final DiaryFeedResponse res = await repo.getDiaryFeed(
        teamCode: teamCode,
        page: _page,
        size: pageSize,
      );

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

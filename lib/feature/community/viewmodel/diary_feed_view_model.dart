import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/model/dto/diary_dtos.dart';
import 'package:inninglog/feature/community/repositories/diary_repository.dart';

class DiaryFeedViewModel extends ChangeNotifier {
  final DiaryRepository repo;
  final String teamCode;
  final int pageSize;

  DiaryFeedViewModel({
    required this.repo,
    required this.teamCode,
    this.pageSize = 10,
  });

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

  Future<void> toggleScrap({required String journalId}) async {
    final index = _items.indexWhere((item) => item.journalId == journalId);
    if (index == -1) return;

    final prev = _items[index];
    final nextScraped = !prev.scrapedByMe;
    final nextCount = (prev.scrapCount + (nextScraped ? 1 : -1));

    _items[index] = prev.copyWith(
      scrapedByMe: nextScraped,
      scrapCount: nextCount < 0 ? 0 : nextCount,
    );
    notifyListeners();

    try {
      if (nextScraped) {
        await repo.scrapJournal(journalId: journalId);
      } else {
        await repo.unscrapJournal(journalId: journalId);
      }
    } catch (e) {
      _items[index] = prev;
      notifyListeners();
    }
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

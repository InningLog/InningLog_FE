import 'package:flutter/foundation.dart';
import 'package:inninglog/feature/community/model/diary_item.dart';
import 'package:inninglog/feature/community/repositories/diary_repository.dart';

class JournalActionsViewModel extends ChangeNotifier {
  final DiaryRepository _repo;

  JournalActionsViewModel({required DiaryRepository repo}) : _repo = repo;

  final Set<String> _likePendingJournalIds = {};
  final Set<String> _scrapPendingJournalIds = {};

  bool isLikePending(String journalId) =>
      _likePendingJournalIds.contains(journalId);
  bool isScrapPending(String journalId) =>
      _scrapPendingJournalIds.contains(journalId);

  void clearPending() {
    _likePendingJournalIds.clear();
    _scrapPendingJournalIds.clear();
    notifyListeners();
  }

  Future<void> toggleLike({
    required List<DiaryItemModel> items,
    required String journalId,
    required VoidCallback notifyItems,
    void Function(Object error)? onError,
  }) async {
    if (_likePendingJournalIds.contains(journalId)) return;
    final index = items.indexWhere((item) => item.journalId == journalId);
    if (index < 0) return;

    final before = items[index];
    final nextLiked = !before.likedByMe;
    final nextLikeCount = _safeCount(before.likeCount + (nextLiked ? 1 : -1));

    _likePendingJournalIds.add(journalId);
    items[index] = before.copyWith(
      likedByMe: nextLiked,
      likeCount: nextLikeCount,
    );
    notifyItems();
    notifyListeners();

    try {
      if (nextLiked) {
        await _repo.likeJournal(journalId: journalId);
      } else {
        await _repo.unlikeJournal(journalId: journalId);
      }
    } catch (e) {
      items[index] = before;
      notifyItems();
      onError?.call(e);
    } finally {
      _likePendingJournalIds.remove(journalId);
      notifyItems();
      notifyListeners();
    }
  }

  Future<void> toggleScrap({
    required List<DiaryItemModel> items,
    required String journalId,
    required VoidCallback notifyItems,
    void Function(Object error)? onError,
  }) async {
    if (_scrapPendingJournalIds.contains(journalId)) return;
    final index = items.indexWhere((item) => item.journalId == journalId);
    if (index < 0) return;

    final before = items[index];
    final nextScraped = !before.scrapedByMe;
    final nextScrapCount = _safeCount(
      before.scrapCount + (nextScraped ? 1 : -1),
    );

    _scrapPendingJournalIds.add(journalId);
    items[index] = before.copyWith(
      scrapedByMe: nextScraped,
      scrapCount: nextScrapCount,
    );
    notifyItems();
    notifyListeners();

    try {
      if (nextScraped) {
        await _repo.scrapJournal(journalId: journalId);
      } else {
        await _repo.unscrapJournal(journalId: journalId);
      }
    } catch (e) {
      items[index] = before;
      notifyItems();
      onError?.call(e);
    } finally {
      _scrapPendingJournalIds.remove(journalId);
      notifyItems();
      notifyListeners();
    }
  }

  void updateCommentCount({
    required List<DiaryItemModel> items,
    required String journalId,
    required int count,
    required VoidCallback notifyItems,
  }) {
    final index = items.indexWhere((item) => item.journalId == journalId);
    if (index < 0) return;
    items[index] = items[index].copyWith(commentCount: count);
    notifyItems();
  }

  int _safeCount(int value) => value < 0 ? 0 : value;
}

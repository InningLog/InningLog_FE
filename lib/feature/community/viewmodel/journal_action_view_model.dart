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
    required String journalId,
    required DiaryItemModel currentItem,
    required void Function(DiaryItemModel updated) onUpdate,
    void Function(Object error)? onError,
  }) async {
    if (_likePendingJournalIds.contains(journalId)) return;

    final nextLiked = !currentItem.likedByMe;
    final optimistic = currentItem.copyWith(
      likedByMe: nextLiked,
      likeCount: _safeCount(currentItem.likeCount + (nextLiked ? 1 : -1)),
    );

    _likePendingJournalIds.add(journalId);
    onUpdate(optimistic);
    notifyListeners();

    try {
      if (nextLiked) {
        await _repo.likeJournal(journalId: journalId);
      } else {
        await _repo.unlikeJournal(journalId: journalId);
      }
    } catch (e) {
      onUpdate(currentItem);
      onError?.call(e);
    } finally {
      _likePendingJournalIds.remove(journalId);
      notifyListeners();
    }
  }

  Future<void> toggleScrap({
    required String journalId,
    required DiaryItemModel currentItem,
    required void Function(DiaryItemModel updated) onUpdate,
    void Function(Object error)? onError,
  }) async {
    if (_scrapPendingJournalIds.contains(journalId)) return;

    final nextScraped = !currentItem.scrapedByMe;
    final optimistic = currentItem.copyWith(
      scrapedByMe: nextScraped,
      scrapCount: _safeCount(currentItem.scrapCount + (nextScraped ? 1 : -1)),
    );

    _scrapPendingJournalIds.add(journalId);
    onUpdate(optimistic);
    notifyListeners();

    try {
      if (nextScraped) {
        await _repo.scrapJournal(journalId: journalId);
      } else {
        await _repo.unscrapJournal(journalId: journalId);
      }
    } catch (e) {
      onUpdate(currentItem);
      onError?.call(e);
    } finally {
      _scrapPendingJournalIds.remove(journalId);
      notifyListeners();
    }
  }

  void updateCommentCount({
    required String journalId,
    required int count,
    required DiaryItemModel currentItem,
    required void Function(DiaryItemModel updated) onUpdate,
  }) {
    onUpdate(currentItem.copyWith(commentCount: count));
  }

  int _safeCount(int value) => value < 0 ? 0 : value;
}

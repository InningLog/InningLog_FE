import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/model/dto/post_dtos.dart';

typedef PostFetcher = Future<PostListResponse> Function(int page, int size);

class PostListViewModel extends ChangeNotifier {
  final PostFetcher _fetcher;
  final int pageSize;

  PostListViewModel({
    required PostFetcher fetcher,
    this.pageSize = 10,
  }) : _fetcher = fetcher;

  final List<CommunityPostItem> _items = [];
  List<CommunityPostItem> get items => List.unmodifiable(_items);

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

  Future<void> _fetch() async {
    _isLoading = true;
    notifyListeners();
    try {
      final PostListResponse res = await _fetcher(_page, pageSize);

      if (_page == 0) {
        _items
          ..clear()
          ..addAll(res.content);
      } else {
        _items.addAll(res.content);
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

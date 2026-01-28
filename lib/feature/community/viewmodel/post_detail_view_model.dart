import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';

class PostDetailViewModel extends ChangeNotifier {
  final CommunityPostRepository repo;
  final int postId;

  PostDetailViewModel({required this.repo, required this.postId});

  CommunityPostItem? _post;
  CommunityPostItem? get post => _post;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _likedByMe = false;
  bool get likedByMe => _likedByMe;

  int _likeCount = 0;
  int get likeCount => _likeCount;

  bool _scrapedByMe = false;
  bool get scrapedByMe => _scrapedByMe;

  int _scrapCount = 0;
  int get scrapCount => _scrapCount;

  int _commentCount = 0;
  int get commentCount => _commentCount;

  Future<void> fetch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await repo.getPostDetail(postId: postId);
      _post = res;
      _likedByMe = res.likedByMe;
      _likeCount = res.likeCount;
      _scrapedByMe = res.scrapedByMe;
      _scrapCount = res.scrapCount;
      _commentCount = res.commentCount;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike() async {
    final prevLiked = _likedByMe;
    final prevCount = _likeCount;
    _likedByMe = !_likedByMe;
    _likeCount += _likedByMe ? 1 : -1;
    if (_likeCount < 0) _likeCount = 0;
    notifyListeners();

    try {
      if (_likedByMe) {
        await repo.likePost(postId: postId);
      } else {
        await repo.unlikePost(postId: postId);
      }
    } catch (e) {
      _likedByMe = prevLiked;
      _likeCount = prevCount;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleScrap() async {
    final prevScraped = _scrapedByMe;
    final prevCount = _scrapCount;
    _scrapedByMe = !_scrapedByMe;
    _scrapCount += _scrapedByMe ? 1 : -1;
    if (_scrapCount < 0) _scrapCount = 0;
    notifyListeners();

    try {
      if (_scrapedByMe) {
        await repo.scrapPost(postId: postId);
      } else {
        await repo.unscrapPost(postId: postId);
      }
    } catch (e) {
      _scrapedByMe = prevScraped;
      _scrapCount = prevCount;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> deletePost() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await repo.deletePost(postId: postId);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

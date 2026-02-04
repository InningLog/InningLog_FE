import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/model/comment_like_state.dart';
import 'package:inninglog/feature/community/model/comment_domain_type.dart';
import 'package:inninglog/feature/community/model/dto/comment_dtos.dart';
import 'package:inninglog/feature/community/repositories/comment_repository.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentDomainType domainType;
  final int domainId;
  final CommentRepository repo;
  final TextEditingController commentController = TextEditingController();
  final TextEditingController replyController = TextEditingController();
  final FocusNode replyFocusNode = FocusNode();
  final FocusNode commentFocusNode = FocusNode();

  final List<Comment> _comments = [];
  final Map<int, List<Comment>> _replies = {};
  int? _activeReplyIndex;
  bool _isLoading = false;

  CommentViewModel({
    required this.domainType,
    required this.domainId,
    required this.repo,
    List<Comment>? initialComments,
  }) {
    if (initialComments != null) {
      _comments.addAll(initialComments);
    }
  }

  List<Comment> get comments => List.unmodifiable(_comments);

  List<Comment> repliesFor(int index) =>
      List.unmodifiable(_replies[index] ?? const <Comment>[]);

  int? get activeReplyIndex => _activeReplyIndex;

  bool get isReplyMode => _activeReplyIndex != null;

  bool get isLoading => _isLoading;

  String? get activeReplyNickname {
    final index = _activeReplyIndex;
    if (index == null || index < 0 || index >= _comments.length) return null;
    return _comments[index].nickName;
  }

  Future<void> fetchComments() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final commentDtos = await _fetchCommentsByDomain();
      _applyCommentDtos(commentDtos);
    } catch (e) {
      debugPrint('[Comment] fetch error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startReply(int index) {
    if (index < 0 || index >= _comments.length) return;
    _activeReplyIndex = index;
    replyController.clear();
    replyFocusNode.requestFocus();
    notifyListeners();
  }

  void cancelReply() {
    if (_activeReplyIndex == null) return;
    _activeReplyIndex = null;
    replyController.clear();
    notifyListeners();
  }

  Future<void> submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await _createCommentByDomain(
        request: CreateCommentRequest(content: text, rootCommentId: null),
      );
      commentController.clear();
      await fetchComments();
    } catch (e) {
      debugPrint('[Comment] submit comment error: $e');
    }
  }

  Future<void> submitReply() async {
    final index = _activeReplyIndex;
    if (index == null || index < 0 || index >= _comments.length) return;
    final text = replyController.text.trim();
    if (text.isEmpty) return;

    try {
      final rootCommentId = _comments[index].id;
      await _createCommentByDomain(
        request: CreateCommentRequest(
          content: text,
          rootCommentId: rootCommentId,
        ),
      );
      _activeReplyIndex = null;
      replyController.clear();
      await fetchComments();
    } catch (e) {
      debugPrint('[Comment] submit reply error: $e');
    }
  }

  Future<void> toggleCommentLike(int index) async {
    if (index < 0 || index >= _comments.length) return;
    final current = _comments[index];
    final prevState = CommentLikeState.fromComment(current);
    final nextState = prevState.toggled();
    _comments[index] = _applyLikeState(current, nextState);
    notifyListeners();

    try {
      if (nextState.likedByMe) {
        await repo.likeComment(commentId: current.id);
      } else {
        await repo.unlikeComment(commentId: current.id);
      }
    } catch (e) {
      _comments[index] = _applyLikeState(current, prevState);
      notifyListeners();
    }
  }

  Future<void> toggleReplyLike(int index, Comment reply) async {
    final replies = List<Comment>.from(_replies[index] ?? const []);
    final replyIndex = replies.indexOf(reply);
    if (replyIndex == -1) return;

    final current = replies[replyIndex];
    final prevState = CommentLikeState.fromComment(current);
    final nextState = prevState.toggled();
    replies[replyIndex] = _applyLikeState(current, nextState);
    _replies[index] = replies;
    notifyListeners();

    try {
      if (nextState.likedByMe) {
        await repo.likeComment(commentId: current.id);
      } else {
        await repo.unlikeComment(commentId: current.id);
      }
    } catch (e) {
      replies[replyIndex] = _applyLikeState(current, prevState);
      _replies[index] = replies;
      notifyListeners();
    }
  }

  Future<bool> deleteComment(Comment target) async {
    final previousComments = List<Comment>.from(_comments);
    final previousReplies = _cloneReplies();
    final previousActiveReplyIndex = _activeReplyIndex;
    final previousReplyText = replyController.text;

    final removed = _removeLocalCommentById(target.id);
    if (!removed) return false;
    notifyListeners();

    try {
      await repo.deleteComment(commentId: target.id);
      return true;
    } catch (e) {
      debugPrint('[Comment] delete error: $e');
      _comments
        ..clear()
        ..addAll(previousComments);
      _replies
        ..clear()
        ..addAll(previousReplies);
      _activeReplyIndex = previousActiveReplyIndex;
      replyController.text = previousReplyText;
      notifyListeners();
      return false;
    }
  }

  Comment _applyLikeState(Comment current, CommentLikeState state) {
    return Comment(
      id: current.id,
      nickName: current.nickName,
      content: current.content,
      createdAt: current.createdAt,
      profileUrl: current.profileUrl,
      likeCount: state.likeCount,
      likedByMe: state.likedByMe,
      writeByMe: current.writeByMe,
      replies: current.replies,
    );
  }

  bool _removeLocalCommentById(int commentId) {
    final rootIndex = _comments.indexWhere((comment) => comment.id == commentId);
    if (rootIndex != -1) {
      _comments.removeAt(rootIndex);
      _replies
        ..clear()
        ..addAll(_shiftRepliesAfterRemoval(rootIndex));

      if (_activeReplyIndex != null) {
        if (_activeReplyIndex == rootIndex) {
          _activeReplyIndex = null;
          replyController.clear();
        } else if (_activeReplyIndex! > rootIndex) {
          _activeReplyIndex = _activeReplyIndex! - 1;
        }
      }
      return true;
    }

    for (final key in _replies.keys.toList()) {
      final replies = _replies[key];
      if (replies == null) continue;
      final replyIndex =
          replies.indexWhere((reply) => reply.id == commentId);
      if (replyIndex == -1) continue;

      final nextReplies = List<Comment>.from(replies)..removeAt(replyIndex);
      if (nextReplies.isEmpty) {
        _replies.remove(key);
      } else {
        _replies[key] = nextReplies;
      }
      return true;
    }
    return false;
  }

  Map<int, List<Comment>> _shiftRepliesAfterRemoval(int removedIndex) {
    final shifted = <int, List<Comment>>{};
    for (final entry in _replies.entries) {
      final index = entry.key;
      if (index == removedIndex) continue;
      final nextIndex = index > removedIndex ? index - 1 : index;
      shifted[nextIndex] = entry.value;
    }
    return shifted;
  }

  Map<int, List<Comment>> _cloneReplies() {
    final snapshot = <int, List<Comment>>{};
    for (final entry in _replies.entries) {
      snapshot[entry.key] = List<Comment>.from(entry.value);
    }
    return snapshot;
  }

  Future<List<CommentResDto>> _fetchCommentsByDomain() {
    switch (domainType) {
      case CommentDomainType.post:
        return repo.getPostComments(postId: domainId);
      case CommentDomainType.feed:
        throw UnsupportedError('Feed comments are not supported yet.');
    }
  }

  Future<void> _createCommentByDomain({
    required CreateCommentRequest request,
  }) async {
    switch (domainType) {
      case CommentDomainType.post:
        await repo.createPostComment(postId: domainId, request: request);
        return;
      case CommentDomainType.feed:
        throw UnsupportedError('Feed comments are not supported yet.');
    }
  }

  void _applyCommentDtos(List<CommentResDto> dtos) {
    _comments
      ..clear()
      ..addAll(dtos.map((dto) => dto.toDomain()));
    _replies.clear();
    for (var i = 0; i < dtos.length; i++) {
      final replies = dtos[i].replies.map((r) => r.toDomain()).toList();
      if (replies.isNotEmpty) {
        _replies[i] = replies;
      }
    }
  }

  @override
  void dispose() {
    commentController.dispose();
    replyController.dispose();
    replyFocusNode.dispose();
    commentFocusNode.dispose();
    super.dispose();
  }
}

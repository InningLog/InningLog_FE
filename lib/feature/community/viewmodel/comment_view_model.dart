import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/model/comment_like_state.dart';
import 'package:inninglog/feature/community/model/comment_domain_type.dart';
import 'package:inninglog/feature/community/model/dto/comment_dtos.dart';
import 'package:inninglog/feature/community/repositories/comment_repository.dart';

class CommentViewModel extends ChangeNotifier {
  final CommentDomainType domainType;
  final String domainId;
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

  int get totalCount {
    var count = _comments.length;
    for (final replies in _replies.values) {
      count += replies.length;
    }
    return count;
  }

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

  void startReply(
    int index, {
    bool requestFocus = true,
    bool clearController = true,
  }) {
    if (index < 0 || index >= _comments.length) return;
    _activeReplyIndex = index;
    if (clearController) {
      replyController.clear();
    }
    if (requestFocus) {
      replyFocusNode.requestFocus();
    }
    notifyListeners();
  }

  void cancelReply({bool clearController = true}) {
    if (_activeReplyIndex == null) return;
    _activeReplyIndex = null;
    if (clearController) {
      replyController.clear();
    }
    notifyListeners();
  }

  Future<void> submitComment({String? text}) async {
    final content = (text ?? commentController.text).trim();
    if (content.isEmpty) return;
    try {
      await _createCommentByDomain(
        request: CreateCommentRequest(content: content, rootCommentId: null),
      );
      if (text == null) {
        commentController.clear();
      }
      await fetchComments();
    } catch (e) {
      debugPrint('[Comment] submit comment error: $e');
    }
  }

  Future<void> submitReply({String? text}) async {
    final index = _activeReplyIndex;
    if (index == null || index < 0 || index >= _comments.length) return;
    final content = (text ?? replyController.text).trim();
    if (content.isEmpty) return;

    try {
      final rootCommentId = _comments[index].id;
      await _createCommentByDomain(
        request: CreateCommentRequest(
          content: content,
          rootCommentId: rootCommentId,
        ),
      );
      _activeReplyIndex = null;
      if (text == null) {
        replyController.clear();
      }
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
    try {
      await repo.deleteComment(commentId: target.id);
      await fetchComments();
      return true;
    } catch (e) {
      debugPrint('[Comment] delete error: $e');
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

  Future<List<CommentResDto>> _fetchCommentsByDomain() {
    switch (domainType) {
      case CommentDomainType.post:
        final postId = int.tryParse(domainId);
        if (postId == null) {
          throw FormatException('Invalid post id: $domainId');
        }
        return repo.getPostComments(postId: postId);
      case CommentDomainType.feed:
        return repo.getJournalComments(journalId: domainId);
    }
  }

  Future<void> _createCommentByDomain({
    required CreateCommentRequest request,
  }) async {
    switch (domainType) {
      case CommentDomainType.post:
        final postId = int.tryParse(domainId);
        if (postId == null) {
          throw FormatException('Invalid post id: $domainId');
        }
        await repo.createPostComment(postId: postId, request: request);
        return;
      case CommentDomainType.feed:
        await repo.createJournalComment(journalId: domainId, request: request);
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

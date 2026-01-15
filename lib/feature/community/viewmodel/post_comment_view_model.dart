import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/model/dto/comment_dtos.dart';
import 'package:inninglog/feature/community/repositories/post_repository.dart';

class PostCommentViewModel extends ChangeNotifier {
  final int postId;
  final CommunityPostRepository repo;
  final TextEditingController commentController = TextEditingController();
  final TextEditingController replyController = TextEditingController();
  final FocusNode replyFocusNode = FocusNode();
  final FocusNode commentFocusNode = FocusNode();

  final List<Comment> _comments = [];
  final Map<int, List<Comment>> _replies = {};
  int? _activeReplyIndex;
  bool _isLoading = false;

  PostCommentViewModel({
    required this.postId,
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
      final commentDtos = await repo.getPostComments(postId: postId);
      _applyCommentDtos(commentDtos);
    } catch (e) {
      debugPrint('[PostComment] fetch error: $e');
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

  Future<void> submitComment() async {
    final text = commentController.text.trim();
    if (text.isEmpty) return;
    try {
      await repo.createPostComment(
        postId: postId,
        request: CreateCommentRequest(content: text, rootCommentId: null),
      );
      commentController.clear();
      await fetchComments();
    } catch (e) {
      debugPrint('[PostComment] submit comment error: $e');
    }
  }

  Future<void> submitReply() async {
    final index = _activeReplyIndex;
    if (index == null || index < 0 || index >= _comments.length) return;
    final text = replyController.text.trim();
    if (text.isEmpty) return;

    try {
      final rootCommentId = _comments[index].id;
      await repo.createPostComment(
        postId: postId,
        request: CreateCommentRequest(
          content: text,
          rootCommentId: rootCommentId,
        ),
      );
      _activeReplyIndex = null;
      replyController.clear();
      await fetchComments();
    } catch (e) {
      debugPrint('[PostComment] submit reply error: $e');
    }
  }

  void toggleCommentLike(int index) {
    if (index < 0 || index >= _comments.length) return;
    final current = _comments[index];
    final liked = !current.likedByMe;
    final likeCount = liked ? current.likeCount + 1 : current.likeCount - 1;
    _comments[index] = Comment(
      id: current.id,
      nickName: current.nickName,
      content: current.content,
      createdAt: current.createdAt,
      profileUrl: current.profileUrl,
      likeCount: likeCount,
      likedByMe: liked,
    );
    notifyListeners();
  }

  void toggleReplyLike(int index, Comment reply) {
    final replies = List<Comment>.from(_replies[index] ?? const []);
    final replyIndex = replies.indexOf(reply);
    if (replyIndex == -1) return;

    final current = replies[replyIndex];
    final liked = !current.likedByMe;
    final likeCount = liked ? current.likeCount + 1 : current.likeCount - 1;
    replies[replyIndex] = Comment(
      id: current.id,
      nickName: current.nickName,
      content: current.content,
      createdAt: current.createdAt,
      profileUrl: current.profileUrl,
      likeCount: likeCount,
      likedByMe: liked,
    );
    _replies[index] = replies;
    notifyListeners();
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

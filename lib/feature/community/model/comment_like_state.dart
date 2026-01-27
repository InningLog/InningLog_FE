import 'package:inninglog/feature/community/model/comment.dart';

class CommentLikeState {
  final bool likedByMe;
  final int likeCount;

  const CommentLikeState({required this.likedByMe, required this.likeCount});

  factory CommentLikeState.fromComment(Comment comment) {
    return CommentLikeState(
      likedByMe: comment.likedByMe,
      likeCount: comment.likeCount,
    );
  }

  CommentLikeState toggled() {
    final nextLiked = !likedByMe;
    final nextCount = likeCount + (nextLiked ? 1 : -1);
    return CommentLikeState(
      likedByMe: nextLiked,
      likeCount: nextCount < 0 ? 0 : nextCount,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/widgets/comment/comment_item.dart';
import 'package:inninglog/feature/community/widgets/comment/empty_comment.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class CommentList extends StatelessWidget {
  final List<Comment> comments;
  final int? activeReplyIndex;
  final List<Comment> Function(int index) repliesFor;
  final void Function(int index) onTapReply;
  final void Function(int index) onToggleLike;
  final void Function(Comment reply, int index) onToggleReplyLike;
  final void Function(Comment comment) onTapMore;
  final void Function(Comment reply) onTapReplyMore;

  const CommentList({
    super.key,
    required this.comments,
    required this.activeReplyIndex,
    required this.repliesFor,
    required this.onTapReply,
    required this.onToggleLike,
    required this.onToggleReplyLike,
    required this.onTapMore,
    required this.onTapReplyMore,
  });

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) return const EmptyComment();

    return Column(
      children:
          comments.asMap().entries.expand((entry) {
            final index = entry.key;
            final comment = entry.value;
            return [
              if (index > 0)
                const Divider(height: 8, color: AppColors.gray200),
              CommentItem(
                comment: comment,
                isReplying: activeReplyIndex == index,
                onTapReply: () => onTapReply(index),
                onToggleLike: () => onToggleLike(index),
                onTapMore: () => onTapMore(comment),
                replies: repliesFor(index),
                onToggleReplyLike: (reply) => onToggleReplyLike(reply, index),
                onTapReplyMore: onTapReplyMore,
              ),
            ];
          }).toList(),
    );
  }
}

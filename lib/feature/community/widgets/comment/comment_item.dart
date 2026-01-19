import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/feature/community/widgets/post/post_action_counts.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

import 'comment_shared_widgets.dart';
import 'reply_item.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isReplying;
  final VoidCallback onTapReply;
  final VoidCallback onToggleLike;
  final VoidCallback onTapMore;
  final List<Comment> replies;
  final void Function(Comment reply) onToggleReplyLike;
  final void Function(Comment reply) onTapReplyMore;

  const CommentItem({
    super.key,
    required this.comment,
    required this.isReplying,
    required this.onTapReply,
    required this.onToggleLike,
    required this.onTapMore,
    required this.replies,
    required this.onToggleReplyLike,
    required this.onTapReplyMore,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: isReplying ? AppColors.primary100 : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8,
                children: [
                  //프로필 이미지
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppColors.gray200,
                    backgroundImage:
                        (comment.profileUrl != null &&
                                comment.profileUrl!.isNotEmpty)
                            ? NetworkImage(comment.profileUrl!)
                            : null,
                  ),
                  Expanded(
                    child: Text(
                      comment.nickName,
                      style: AppTextStyles.headHead8Sb.copyWith(
                        color: AppColors.gray800,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //대댓글 버튼
                        CommentReplyButton(onTap: onTapReply),
                        const CommentVBar(),
                        //좋아요 버튼
                        CommentLikeButton(
                          isActive: comment.likedByMe,
                          onTap: onToggleLike,
                        ),
                        const CommentVBar(),
                        //더보기 버튼
                        CommentMoreButton(onTap: onTapMore),
                      ],
                    ),
                  ),
                ],
              ),
              //댓글 내용
              Text(
                comment.content,
                style: AppTextStyles.bodyBody2Rg.copyWith(
                  color: AppColors.gray800,
                ),
              ),
              Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //작성 시간
                  Text(
                    comment.createdAt ?? '',
                    style: AppTextStyles.bodyBody4M.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                  if (comment.likeCount > 0)
                    LikeCount(count: comment.likeCount),
                ],
              ),
            ],
          ),
        ),
        if (replies.isNotEmpty) ...[
          Column(
            spacing: 12,
            children:
                replies
                    .map(
                      (reply) => ReplyItem(
                        reply: reply,
                        onToggleLike: () => onToggleReplyLike(reply),
                        onTapMore: () => onTapReplyMore(reply),
                      ),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }
}

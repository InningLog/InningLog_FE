import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:inninglog/feature/community/model/comment.dart';
import 'package:inninglog/shared/theme/app_colors.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

import 'comment_shared_widgets.dart';

class ReplyItem extends StatelessWidget {
  final Comment reply;
  final VoidCallback onToggleLike;
  final VoidCallback onTapMore;

  const ReplyItem({
    super.key,
    required this.reply,
    required this.onToggleLike,
    required this.onTapMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
          //대댓글 화살표
          SvgPicture.asset(
            'assets/icons/board_reply.svg',
            width: 11,
            height: 15,
            colorFilter: const ColorFilter.mode(
              AppColors.gray600,
              BlendMode.srcIn,
            ),
          ),
          //대댓글 아이템
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(8),
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
                            (reply.profileUrl != null &&
                                    reply.profileUrl!.isNotEmpty)
                                ? NetworkImage(reply.profileUrl!)
                                : null,
                      ),
                      Expanded(
                        child: Text(
                          reply.nickName,
                          style: AppTextStyles.headHead8Sb.copyWith(
                            color: AppColors.gray800,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            //좋아요 버튼
                            CommentLikeButton(
                              isActive: reply.likedByMe,
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
                    reply.content,
                    style: AppTextStyles.bodyBody2Rg.copyWith(
                      color: AppColors.gray800,
                    ),
                  ),
                  //작성 시간
                  Text(
                    reply.createdAt ?? '',
                    style: AppTextStyles.bodyBody4M.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

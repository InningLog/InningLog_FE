import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/widgets/post_detail/post_action_button.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class PostActionBar extends StatelessWidget {
  final bool likeActive;
  final int likeCount;
  final VoidCallback onTapLike;

  final bool scrapActive;
  final int scrapCount;
  final VoidCallback onTapScrap;

  final int commentCount;

  const PostActionBar({
    super.key,
    required this.likeActive,
    required this.likeCount,
    required this.onTapLike,
    required this.scrapActive,
    required this.scrapCount,
    required this.onTapScrap,
    required this.commentCount,
  });

  String _labelWithCount(String base, int count) {
    // 0이면 숫자 미표시, 그 외엔 "base n"
    return count <= 0 ? base : '$base $count';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray300, width: 1)),
      ),
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          // 공감
          Expanded(
            child: Center(
              child: PostActionButton(
                asset: 'assets/icons/board_heart.svg',
                color: likeActive ? AppColors.primary700 : AppColors.gray500,
                label: _labelWithCount('공감', likeCount),
                onTap: onTapLike,
                iconSize: 18,
              ),
            ),
          ),

          // 댓글 (항상 회색, 숫자만 변화)
          Expanded(
            child: Center(
              child: PostActionButton(
                asset: 'assets/icons/board_comment.svg',
                color: AppColors.gray500,
                label: _labelWithCount('댓글', commentCount),
                onTap: null,
                iconSize: 18,
              ),
            ),
          ),

          // 스크랩
          Expanded(
            child: Center(
              child: PostActionButton(
                asset: 'assets/icons/board_scrap.svg',
                color: scrapActive ? AppColors.primary700 : AppColors.gray500,
                label: _labelWithCount('스크랩', scrapCount),
                onTap: onTapScrap,
                iconSize: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

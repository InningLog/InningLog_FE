import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/post_preview.dart';
import 'package:inninglog/feature/community/widgets/post/post_action_counts.dart';
import 'package:inninglog/feature/community/widgets/post/post_texts.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class PopularPostCard extends StatelessWidget {
  final PostPreview post;

  const PopularPostCard({required this.post, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: PostTitle(text: post.title, isPreview: true)),
              const SizedBox(width: 8),
              PostDateTimeText(text: post.dateTime),
            ],
          ),
          const SizedBox(height: 4),

          PostBody(text: post.preview, isPreview: true),
          const SizedBox(height: 8),

          Row(
            children: [
              LikeCount(count: post.likeCount),
              const SizedBox(width: 11),
              CommentCount(count: post.commentCount),
              const SizedBox(width: 11),
              ScrapCount(count: post.bookmarkCount),
            ],
          ),
        ],
      ),
    );
  }
}

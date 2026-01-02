import 'package:flutter/material.dart';
import 'package:inninglog/feature/community/model/community_post.dart';
import 'package:inninglog/feature/community/widgets/post/post_action_counts.dart';
import 'package:inninglog/feature/community/widgets/post/post_texts.dart';
import 'package:inninglog/shared/theme/app_text_styles.dart';

import 'package:inninglog/shared/utils/date_time_utils.dart';
import 'package:inninglog/shared/theme/app_colors.dart';

class PostItemCard extends StatelessWidget {
  final CommunityPostItem item;
  final VoidCallback onTap;

  const PostItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE5E7EB),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.nickName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            PostDateTimeText(
                              text: DateTimeUtils.formatToKoreanDateTime(
                                item.createdAt,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    PostTitle(text: item.title),
                    const SizedBox(height: 4),
                    PostBody(text: item.content, isPreview: true),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        LikeCount(
                          count: item.likeCount,
                          variant: CountVariant.neutral,
                        ),
                        const SizedBox(width: 11),
                        CommentCount(
                          count: item.commentCount,
                          variant: CountVariant.neutral,
                        ),
                        const SizedBox(width: 11),
                        ScrapCount(
                          count: item.scrapCount,
                          variant: CountVariant.neutral,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              if (item.images.isNotEmpty)
                ImageThumbnailWithBadge(
                  imageUrl: item.images.first.url,
                  count: item.images.length,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageThumbnailWithBadge extends StatelessWidget {
  final String imageUrl;
  final int count;

  const ImageThumbnailWithBadge({
    super.key,
    required this.imageUrl,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 85,
            height: 85,
            color: const Color(0xFFE5E7EB),
            child:
                imageUrl.isEmpty
                    ? null
                    : Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 4,
          bottom: 4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.headHead8Sb.copyWith(
                color: AppColors.gray300,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
